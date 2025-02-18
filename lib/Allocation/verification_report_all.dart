import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class VerificationReportAll extends StatefulWidget {
  const VerificationReportAll({super.key});

  @override
  State<VerificationReportAll> createState() => _VerificationReportAllState();
}

class _VerificationReportAllState extends State<VerificationReportAll> {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  List<Map<String, dynamic>> _tableData =
  [];
  late List<dynamic> globalData = [];// To store remarks for each row
  final TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
  late Future<List<String>> futureUnits;
  bool noDataFound = false;

  @override
  void initState() {
    super.initState();
    _loadLoginIdAndFetchData();
    _fetchDropDownOptions();
    _dateController.text = _formatDate(selectedDate);
    Future.delayed(const Duration(seconds: 16), () {
      if (_tableData.isEmpty) {
        setState(() {
          noDataFound = true;
        });
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 9, 16), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = _formatDate(selectedDate); // Update the date field
      });

      if (_selectedUnitCode != null) {
        await _fetchTotalPresent(selectedDate);
        Future.delayed(const Duration(milliseconds: 500),() async {
          await _fetchTableData(selectedDate);
        });
      }
      noDataFound = false;
      Future.delayed(const Duration(seconds: 16), () {
        if (_tableData.isEmpty) {
          setState(() {
            noDataFound = true;
          });
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}';
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
          for (var item in data)
            item['UnitShortCode'].toString(): item['UnitCode'].toString()
        };

        if (_dropDownOptions.isNotEmpty) {
          _selectedUnit = _dropDownOptions[0];
          _selectedUnitCode = _unitMap[_selectedUnit];
          // print(selectedDate);
          loadData();
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> loadData() async{
    await _fetchTotalPresent(selectedDate);
    Future.delayed(const Duration(milliseconds: 500),() async {
      await _fetchTableData(selectedDate);
    });
  }

  Future<void> _loadLoginIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    if (_loginId != null) {
      await fetchUnits();
    }
  }

  Future<List<String>> fetchUnits() async {
    final response = await http.get(
        Uri.parse('http://14.142.248.34:10008/unit?type=pnl2&user=$_loginId'));
    // final response = await http.get(Uri.parse('http://172.16.10.11:8000/unit?type=pnl2&user=$_loginId'));
    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> units = unitsJson.map((unit) =>
          unit['UnitCode'].toString()).toList();
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> _fetchTableData(DateTime date) async {
    setState(() {
      _tableData = [];
    });
    futureUnits = fetchUnits();
    futureUnits.then((units) async {
      final unitsString = units.join(',');
      final String url = 'http://14.142.248.34:10008/verify_report?unit=$unitsString&date=$date';

      if (kDebugMode) {
        print(url);
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> groupedData = {};
        // print('shagged $globalData');
        for (var entry in data) {
          for (var item in globalData) {
            // print('sdgbfsgakfdjsdhkfljnsdjfn $item');
            if(entry['UnitCode'] == item['UnitCode']){
              entry['TotalMnpwr'] = item['TotalMnpwr'];
            }
          }
        }
              for (var entry in data) {
          final unitCode = entry['UnitShortCode'];
          // String? totalMnpwr = await _fetchTotalPresent(unitSCode);
          if (groupedData[unitCode] == null) {
            groupedData[unitCode] = {
              'UnitShortCode': unitCode,
              'entries': [],
            };
          }
          groupedData[unitCode]['entries'].add({
            'LineName': entry['LineName'],
            'TotalCount': entry['TotalCount'],
            'VerifyMnpwr': entry['VerifyMnpwr'],
            'Remarks': entry['Remarks'],
            'Helper': entry['HelperCount'],
            'Tailor': entry['TailorCount'],
            'UnitCode': entry['UnitCode'],
            'TotalMnpwr': entry['TotalMnpwr']
          });
        }

        // Converting the grouped data into a list
        setState(() {
          _tableData = groupedData.values.map((unit) => {
            'UnitShortCode': unit['UnitShortCode'],
            'Entries': unit['entries'], // Include total manpower
          }).toList();

        });

      }
    });
  }


  void navigateToVerifReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VerificationReportAll(),
      ),
    );
  }


  Future<void> _fetchTotalPresent(DateTime date) async {

    {
      {
        futureUnits = fetchUnits();
        final units = await futureUnits; // Await here instead of using then
        final unitsString = units.join(',');

        final response = await http.get(Uri.parse(
            'http://14.142.248.34:10008/total_alloc?unit=$unitsString&dated=$date'));
        print('http://14.142.248.34:10008/total_alloc?unit=$unitsString&dated=$date');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.isNotEmpty) {
            // Assign the fetched data to the global variable
            setState(() {
              globalData = data;
            });
            print('global $globalData');// Adjust as needed based on the structure of data
          }
        } else {
          throw Exception('Failed to load table data');
        }
      }
      await Future.delayed(Duration(seconds: 1)); // Optional delay between retries
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5FE3D3),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Line Allocation Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child:  InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          panAxis: PanAxis.free,
          minScale: 1.0,
          maxScale: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Date',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                suffixIcon: Icon(Icons.date_range_outlined),
                              ),
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_tableData.isEmpty && !noDataFound)
                    CircularProgressIndicator()
                  else if (noDataFound)
                    Center(
                      child: Text(
                        'No data available for the Date selected',
                        style: TextStyle(fontSize: 18,),
                      ),
                    )
                  else
                    for (var unit in _tableData) ...[
                      SizedBox(height: 20,),
                      Center(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF2CA496),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Present Mnpwr: ${unit['Entries'][0]['TotalMnpwr']}  |  Unit: ${unit['UnitShortCode']}',
                                  textAlign: TextAlign.center, style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildSimpleTable(unit['Entries']),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTable(List<dynamic> entries) {
    num totalCount = 0;
    num totalVerified = 0;
    num helper = 0;
    num tailor = 0;

    // Calculate totals
    for (var entry in entries) {
      totalCount += entry['TotalCount'] ?? 0;
      totalVerified += entry['VerifyMnpwr'] ?? 0;
      helper += entry['Helper'] ?? 0;
      tailor += entry['Tailor'] ?? 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Allows vertical scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allows horizontal scrolling
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allow the column to shrink-wrap its children
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(40),
                2: FixedColumnWidth(40),
                3: FixedColumnWidth(70),
                4: FixedColumnWidth(60),
                5: FixedColumnWidth(90),
              },
              children: [
                // Table header
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFF5FE3D3)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Line', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Talr', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hlpr', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Allocated', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12)),
                    ),
                  ],
                ),
                for (var entry in entries)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['LineName'] ?? ''),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Tailor'].toString(),textAlign: TextAlign.right,style: TextStyle(
                        fontSize: 13
                        ),),
                      ),Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Helper'].toString(),textAlign: TextAlign.right,),
                      ),Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['TotalCount'].toString(),textAlign: TextAlign.right,style: TextStyle(
                            fontSize: 13
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['VerifyMnpwr']?.toString() ?? '',textAlign: TextAlign.right,style: TextStyle(
                            fontSize: 13
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Remarks']?.toString() ?? '',style: TextStyle(
                            fontSize: 13
                        ),),
                      ),
                    ],
                  ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.lightGreen[200]),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(tailor.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(helper.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(totalCount.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(totalVerified.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(''),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
