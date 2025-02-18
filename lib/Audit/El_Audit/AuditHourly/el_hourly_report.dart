import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/utils/constants/baseurl.dart';

class HourlyData {
  final int hour;
  final int pass;
  final int defect;
  final int rejected;
  final int rectified;
  final int total;

  HourlyData({
    required this.hour,
    required this.pass,
    required this.defect,
    required this.rejected,
    required this.rectified,
    required this.total,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      hour: json['Hrs'] ?? 0,
      pass: json['Pass'] ?? 0,
      defect: json['Defect'] ?? 0,
      rejected: json['Rejected'] ?? 0,
      rectified: json['Rectified'] ?? 0,
      total: json['Total'] ?? 0,
    );
  }
}

class GroupedData {
  final String styleNo;
  final String lineName;
  final String color;
  final Map<int, HourlyData> hours;

  GroupedData({
    required this.styleNo,
    required this.lineName,
    required this.color,
    required this.hours,
  });

  static Map<int, HourlyData> _initializeHourlyData() {
    return { for (var hour in List.generate(16, (index) => index + 1)) hour : HourlyData(
        hour: hour,
        pass: 0,
        defect: 0,
        rejected: 0,
        rectified: 0,
        total: 0,
      ) };
  }

  factory GroupedData.fromJson(List<Map<String, dynamic>> jsonList) {
    if (jsonList.isEmpty) {
      throw Exception("Empty data for group");
    }

    final first = jsonList.first;

    final hourlyData = _initializeHourlyData();

    for (var item in jsonList) {
      final hour = item['Hrs'];
      if (hour != null && hour >= 1 && hour <= 16) {
        hourlyData[hour] = HourlyData.fromJson(item);
      }
    }

    return GroupedData(
      styleNo: first['StyleNo'] ?? '',
      lineName: first['LineName'] ?? '',
      color: first['Color'] ?? '',
      hours: hourlyData,
    );
  }
}

class HourlyReportPage extends StatefulWidget {
  const HourlyReportPage({super.key});

  @override
  HourlyReportPageState createState() => HourlyReportPageState();
}

class HourlyReportPageState extends State<HourlyReportPage> {
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  DateTime selectedDate = DateTime.now();
  Future<List<Map<String, dynamic>>>? _futureData;
  bool isLinewise = false;
  bool isLinePresent = false;
  int line = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDropDownOptions();
    _checkLineId();
    Future.delayed(const Duration(milliseconds: 400),(){
      print(_selectedUnit);
      if(!isLinePresent) {
        if (_selectedUnit != null && _selectedUnit != '') {
          final unitCode = _unitMap[_selectedUnit];
          fetchLineDataFromApi(_selectedUnit!);
          _futureData = fetchData('all', selectedDate, unitCode!, '$line');
        }
      }
      else{
        if (_selectedUnit != null && _selectedUnit != '') {
          final unitCode = _unitMap[_selectedUnit];
          _futureData = fetchData('linewise',selectedDate,unitCode!,'$line');
        }
      }
    });
  }

  Future<bool> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic lineId = prefs.getInt('line_ids'); // Fetch the line_id as an int
    line = lineId;
    if (kDebugMode) {
      print(lineId);
    }
    if (lineId != 0) {
      isLinePresent = true;
      return true;
    }
    isLinePresent = false;
    return false;
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
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

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
        } else {
          _selectedUnit =
          _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
      });
    } else {
      debugPrint('Failed to load options');
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(
            Uri.parse('http://14.142.248.34:10008/line?unit=$unit&ot=0'));

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) {
              return {
                'LineName': item['LineName'].toString(),
                'LineID': item['LineId'].toString(),
              };
            }).toList();
          });
          success = true;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Error fetching data (Attempt $retryCount): $e');
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String vise,DateTime date , String unit , String line) async {
    final apiUrl = Uri.parse(
        "${TBaseURL.auditUrl}el_report_hrly?report_type=$vise&date=$date&unit=$unit&line=$line");

    print('${TBaseURL.auditUrl}el_report_hrly?report_type=$vise&date=$date&unit=$unit&line=$line');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      // Grouping data by StyleNo, LineName, and Color
      final groupedData = <String, Map<String, dynamic>>{};
      for (var item in jsonData) {
        final key = '${item["StyleNo"]}-${item["LineName"]}-${item["Color"]}';
        groupedData.putIfAbsent(key, () => {
          'StyleNo': item['StyleNo'],
          'LineName': item['LineName'],
          'Color': item['Color'],
          'Entries': List.generate(16, (hour) => <String, dynamic>{
            'Hrs': hour + 1,
            'Pass': 0,
            'Defect': 0,
            'Rejected': 0,
            'Rectified': 0,
            'Total': 0,
          }),
        });

        if (item['Hrs'] != null) {
          final hourIndex = item['Hrs'] - 1;
          if (hourIndex >= 0 && hourIndex < 16) {
            groupedData[key]?['Entries'][hourIndex] = {
              'Hrs': item['Hrs'],
              'Pass': item['Pass'] ?? 0,
              'Defect': item['Defect'] ?? 0,
              'Rejected': item['Rejected'] ?? 0,
              'Rectified': item['Rectified'] ?? 0,
              'Total': item['Total'] ?? 0,
            };
          }
        }
      }
      setState(() {
        isLoading = false;
      });
      log("${groupedData.values.toList()}");

      return groupedData.values.toList();
    } else {
      throw Exception("Failed to load data: ${response.statusCode}");
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
          'End Line Hourly Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Column(
          children: [
            // Dropdowns and Date Picker
            Padding(
              padding: const EdgeInsets.only(bottom: 4,top: 8.0,left: 8,right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: DropdownSearch<String>(
                        selectedItem: _selectedUnit,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: false),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Unit',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                          ),
                        ),
                        items: _dropDownOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedUnit = newValue;
                            selectedValue4 = newValue;
                            selectedValue3 = null;
                            dropdownData3.clear();
                            dropdownData5.clear();
                            fetchLineDataFromApi(_selectedUnit!);
                            selectedLineID = '';
                          });
                          final unitCode = _unitMap[_selectedUnit];
                          _futureData = fetchData(isLinewise ? 'linewise' : 'all', selectedDate, unitCode!, selectedLineID!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Visibility(
                    visible: isLinewise,
                    child: Expanded(
                      child: SizedBox(
                        height: 35,
                        child: DropdownSearch<String>(
                          dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                          popupProps: const PopupProps.menu(showSearchBox: true),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Line',
                              labelStyle: TextStyle(fontSize: 12),
                              floatingLabelStyle: TextStyle(fontSize: 16),
                              contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                              ),
                            ),
                          ),
                          items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(),
                          itemAsString: (item) => item,
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue3 = newValue;
                              selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                            });
                            if (_selectedUnit != null && selectedLineID != null) {
                              final unitCode = _unitMap[_selectedUnit];

                              _futureData = fetchData(isLinewise ? 'linewise' : 'all', selectedDate, unitCode!, selectedLineID!);
                            }
                          },
                          selectedItem: selectedValue3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4,bottom: 8.0,left: 8,right: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5, // Adjust flex value for proportionate spacing
                    child: GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                          if (_selectedUnit != null && selectedLineID != null) {
                            final unitCode = _unitMap[_selectedUnit];
                            _futureData = fetchData(
                                isLinewise ? 'linewise' : 'all',
                                selectedDate,
                                unitCode!,
                                selectedLineID!);
                          }
                        }
                      },
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate.toLocal().toString().split(' ')[0],
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if(!isLinePresent)
                  Expanded(
                    flex: 2, // Adjust flex value for spacing
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isLinewise,
                          onChanged: (bool? value) {
                            setState(() {
                              isLinewise = value ?? false;
                            });
                            final unitCode = _unitMap[_selectedUnit];
                            _futureData = fetchData(
                                isLinewise ? 'linewise' : 'all',
                                selectedDate,
                                unitCode!,
                                selectedLineID ?? '0');
                            if (_selectedUnit != null && selectedLineID != null) {
                              final unitCode = _unitMap[_selectedUnit];
                              _futureData = fetchData(
                                  isLinewise ? 'linewise' : 'all',
                                  selectedDate,
                                  unitCode!,
                                  selectedLineID!);
                            }
                          },
                        ),
                        const Text(
                          'Linewise',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2CA496),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white)
                          )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Line',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                     Expanded(
                      flex: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white),
                            )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Style',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                left: BorderSide(color: Colors.white),
                              bottom: BorderSide(color: Colors.white),
                            )
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Color',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: SelectableText("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Data Available"));
                }

                final data = snapshot.data!;

                // Initialize totals for each hour
                Map<int, Map<String, num>> hourlyTotals = {};

                for (var unit in data) {
                  for (var entry in unit['Entries']) {
                    int hour = entry['Hrs'];

                    // Initialize if not exists
                    if (!hourlyTotals.containsKey(hour)) {
                      hourlyTotals[hour] = {
                        'Pass': 0,
                        'Defect': 0,
                        'Rejected': 0,
                        'Rectified': 0,
                      };
                    }
                    // Sum up values
                    hourlyTotals[hour]!['Pass'] = (hourlyTotals[hour]!['Pass'] ?? 0) + (entry['Pass'] ?? 0);
                    hourlyTotals[hour]!['Defect'] = (hourlyTotals[hour]!['Defect'] ?? 0) + (entry['Defect'] ?? 0);
                    hourlyTotals[hour]!['Rejected'] = (hourlyTotals[hour]!['Rejected'] ?? 0) + (entry['Rejected'] ?? 0);
                    hourlyTotals[hour]!['Rectified'] = (hourlyTotals[hour]!['Rectified'] ?? 0) + (entry['Rectified'] ?? 0);
                  }
                }

                return Column(
                  children: [
                    for (var unit in data) ...[
                      Center(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2CA496),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.white))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${unit['LineName']}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${unit['StyleNo']}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      border: Border(left: BorderSide(color: Colors.white))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${unit['Color']}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildSimpleTable(unit['Entries']),
                      SizedBox(height: 10,)
                    ],

                    // Display Totals Row at Bottom
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2CA496),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Total',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            border: TableBorder.all(color: Colors.black),
                            columnWidths: {
                              0: const FixedColumnWidth(70), // First column width = 70
                              for (int i = 1; i <= 16; i++) i: const FixedColumnWidth(45), // Next 16 columns width = 40
                              17: const FixedColumnWidth(60), // Last column width = 60
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(color: Color(0xFF5FE3D3)),
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                  ),
                                  for (var hour in List.generate(16, (index) => 'H${index + 1}'))
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(hour,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                    ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ],
                              ),
                              // Table Data Rows
                              _buildTableRow("Pass", hourlyTotals, "Pass"),
                              _buildTableRow("Defect", hourlyTotals, "Defect"),
                              _buildTableRow("Rejected", hourlyTotals, "Rejected"),
                              _buildTableRow("Rectified", hourlyTotals, "Rectified"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, Map<int, Map<String, num>> totals, String key) {
    // Define colors based on key
    Color getColor(String key) {
      switch (key) {
        case "Pass":
          return Colors.green.withOpacity(0.4); // Light green
        case "Defect":
          return Colors.orange.withOpacity(0.4); // Light orange
        case "Rejected":
          return Colors.red.withOpacity(0.4); // Light red
        case "Rectified":
          return Colors.blue.withOpacity(0.4); // Light blue
        default:
          return Colors.white; // Default white
      }
    }

    // Calculate total for the row
    int totalSum = 0;
    for (int hour = 1; hour <= 16; hour++) {
      totalSum += (totals[hour]?[key] ?? 0) as int;
    }

    return TableRow(
      children: [
        Container(
          color: getColor(key), // Apply color dynamically
          padding: const EdgeInsets.all(6.0),
          child: Text(label, style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        for (int hour = 1; hour <= 16; hour++)
          Container(
            color: getColor(key), // Apply color dynamically
            padding: const EdgeInsets.all(6.0),
            child: Text(
              "${totals[hour]?[key] ?? 0}",
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        // Total Column at the right
        Container(
          color: getColor(key), // Apply color dynamically
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "$totalSum", // Display total
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTable(List<dynamic> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: const FixedColumnWidth(70), // First column width = 70
          for (int i = 1; i <= 16; i++) i: const FixedColumnWidth(45), // Next 16 columns width = 40
          17: const FixedColumnWidth(60), // Last column width = 60
        },
        border: TableBorder.all(),
        children: [
          // Table header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFF5FE3D3)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Hrs', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
              ),
              for (var hour in List.generate(16, (index) => 'H${index + 1}'))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(hour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
              ),
            ],
          ),
          // Table rows for each metric
          _buildDataRow('Pass', entries, 'Pass'),
          _buildDataRow('Defect', entries, 'Defect'),
          _buildDataRow('Rejected', entries, 'Rejected'),
          _buildDataRow('Rectified', entries, 'Rectified'),
          _buildDataRow('Total', entries, 'Total', isTotalColumn: true),
        ],
      ),
    );
  }

  TableRow _buildDataRow(String label, List<dynamic> entries, String key,
      {bool isTotalColumn = false}) {
    // Calculate total for the row
    num total = entries.fold(0, (sum, entry) {
      return sum + (entry[key] is int ? entry[key] : int.tryParse(entry[key]?.toString() ?? '0') ?? 0);
    });

    return TableRow(
      decoration: BoxDecoration(
        color: isTotalColumn ? Colors.green[300] : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        for (var entry in entries)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(entry[key]?.toString() ?? '0', textAlign: TextAlign.right),
          ),
        // Append total at the end
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            total.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
