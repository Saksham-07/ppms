import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VerificationReport extends StatefulWidget {
  const VerificationReport({super.key});

  @override
  State<VerificationReport> createState() => _VerificationReportState();
}

class _VerificationReportState extends State<VerificationReport> {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  List<Map<String, dynamic>> _tableData =
  [];
  int _totalTailor = 0;
  int _totalHelper = 0;
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date

  @override
  void initState() {
    super.initState();
    _fetchDropDownOptions();
    _dateController.text = _formatDate(selectedDate); // Set initial date
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
        _fetchTableData(_selectedUnitCode!, selectedDate); // Fetch table data based on the new date
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url =
        TBaseURL.baseUrl + 'unit?type=permissions&user=$_loginId';
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
          print(selectedDate);
          _fetchTableData(
              _selectedUnitCode!,selectedDate);
          _fetchTotalPresent(_selectedUnitCode!);
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> _fetchTableData(String unitCode , DateTime date) async {
    final String url = 'http://14.142.248.34:10008/verify_report?unit=$unitCode&date=$date';
    // final String url = 'http://172.16.10.11:8000/verify_report?unit_code=$unitCode&date=$date';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(_tableData);
      setState(() {
        _tableData = data.map((e) => {
          'LineName': e['LineName'],
          'TotalCount': e['TotalCount'],
          'VerifyMnpwr': e['VerifyMnpwr'],
          'Remarks': e['Remarks'],
        }).toList();

        // Initialize the remarks list with empty strings

        _filteredData = List.from(_tableData);
        _totalTailor = _tableData.fold(0, (sum, row) => sum + ((row['TotalCount'] ?? 0) as int));
        _totalHelper = _tableData.fold(0, (sum, row) => sum + ((row['VerifyMnpwr'] ?? 0) as int));
      });
    }
  }

  void navigateToVerifReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationReport(),//fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }


  Future<void> _fetchTotalPresent(String unitCode) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/total_alloc?unit=$unitCode'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.isNotEmpty) {
            setState(() {
              _allocMnpwr = data[0]['AllocMnpwr'].toString();
              _totalMnpwr = data[0]['TotalMnpwr'].toString();

              if (kDebugMode) {
                print('AllocMnpwr: $_allocMnpwr, TotalMnpwr: $_totalMnpwr');
              }
            });
            success = true;
          }
        } else {
          throw Exception('Failed to load table data');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
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
          'Manpower Verification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body:  InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Unit',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      ),
                      value: _selectedUnit,
                      items: _dropDownOptions.map((String unitShortCode) {
                        return DropdownMenuItem<String>(
                          value: unitShortCode,
                          child: Text(unitShortCode),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          _selectedUnitCode = _unitMap[newValue!];
                          _fetchTableData(_selectedUnitCode!, selectedDate);
                          _fetchTotalPresent(_selectedUnitCode!);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
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
              // const SizedBox(height: 10),
              // TextField(
              //   decoration: InputDecoration(
              //     labelText: 'Search',
              //     border: OutlineInputBorder(),
              //   ),
              //   onChanged: _filterTableData,
              // ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF2CA496),
                    // color: Colors.yellowAccent,
                    shape: BoxShape.rectangle,

                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Total Manpower Present : $_totalMnpwr" ,textAlign: TextAlign.center, style: TextStyle(
                      // color: Colors.black,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(65),
                        2: FixedColumnWidth(60),
                        3: FixedColumnWidth(140),// New column for Remark
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[200],
                          ),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Line',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Total\nAllocated',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Verified\nMnpwr',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Remarks',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        ..._filteredData.map((row) {
                          _filteredData.indexOf(row);

                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['LineName']),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['TotalCount'] ?? 0).toString(),textAlign: TextAlign.right),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['VerifyMnpwr'] ?? 0).toString(),textAlign: TextAlign.right),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['Remarks'] ?? '').toString(),textAlign: TextAlign.left),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[200],
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Total',textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalTailor.toString(),textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalHelper.toString(),textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  ''
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}