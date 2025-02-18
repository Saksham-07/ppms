import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'elAuditReportTable.dart';

class AuditELReport extends StatefulWidget {
  const AuditELReport({super.key});

  @override
  State<AuditELReport> createState() => _AuditELReportState();
}

class _AuditELReportState extends State<AuditELReport> {
  String? _loginId;
  List<String> _dropDownOptions = [];
  String? selectedLineID;
  List<Map<String, String>> dropdownData3 = [];
  String? selectedValue3;
  String? selectedValue4;
  List<String> dropdownData5 = [];
  String? previousValue;
  String? _selectedUnit;
  List<Map<String, dynamic>> _tableData = [];
  late List<dynamic> globalData = [];
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late Future<List<String>> futureUnits;
  List<dynamic> dataMap = [];
  int? lineId = 0;
  String? line = '';
  String? date;
  String? _selectedMonth;
  final Map<String, String> _monthValues = {};
  List<String> _months = [];
  bool isChecked =  true;
  bool isLineWise = false;

  @override
  void initState() {
    super.initState();
    _fetchDropDownOptions();
    _generateMonthValues();
    _fromDateController.text = _formatDate(fromDate);
    _toDateController.text = _formatDate(toDate);
    Future.delayed(const Duration(milliseconds: 800),(){
      _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
    });
  }
  void _generateMonthValues() {
    final now = DateTime.now();
    final year = now.year;
    final currentMonthIndex = now.month - 1;
    // Generate months with formatted values
    _months = List.generate(12, (index) {
      final monthName = DateFormat.MMMM().format(DateTime(year, index + 1)).substring(0,3);
      final firstDate = DateFormat('yyyy-MM-dd').format(DateTime(year, index + 1, 1));
      final lastDate = DateFormat('yyyy-MM-dd').format(DateTime(year, index + 2, 0));
      _monthValues[monthName] = '$firstDate, $lastDate';
      if (index == currentMonthIndex) {
        setState(() {
          _selectedMonth = monthName;
        });
      }
      return monthName;
    });
  }

  Future<void> _selectDate(BuildContext context , bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2022, 1, 1), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          _fromDateController.text = _formatDate(fromDate);
        } else {
          toDate = picked;
          _toDateController.text = _formatDate(toDate);
        }
      });
      _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}';
  }

  String _formatDate2(DateTime date) {
    return '${date.year}-${date.month.toString()
        .padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchTableData(String fromDate , String toDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lineId = prefs.getInt('line_ids');
    line = prefs.getString('line_name');
    String? unit = selectedValue4;
    String wise = isChecked ? 'datewise' : 'summary';
    if(!isChecked && isLineWise){
      wise = 'linewise_summary';
    }
    if (kDebugMode) {
      print(wise);
    }
    DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}el_report?fromDate=$toDate&toDate=$fromDate&unit=$unit&line=$lineId&report_type=$wise'));
    // final response = await http.get(Uri.parse('http://172.16.2.168:8001/el_report?fromDate=$fromDate&toDate=$toDate&unit=$unit'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}el_report?fromDate=$toDate&toDate=$fromDate&unit=$unit&line=$lineId&report_type=$wise');
    }
    if (response.statusCode == 200){
      final data = json.decode(response.body);
      setState(() {
        _tableData = List<Map<String, dynamic>>.from(data).map((row) {
          // Parse and format the AuditDate
          if (row.containsKey('AuditDate') && row['AuditDate'] != null) {
            try {
              DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
              DateFormat outputFormat = DateFormat('dd-MM-yy');
              DateTime parsedDate = inputFormat.parse(row['AuditDate']);
              String formattedDate = outputFormat.format(parsedDate);
              row['AuditDate'] = formattedDate; // Update the AuditDate field
            } catch (e) {
              print('Error parsing date: ${row['AuditDate']}');
            }
          }
          return row;
        }).toList();
        if (kDebugMode) {
          print(_tableData);
        }
      });
    } else {
      throw Exception('Failed to load table data');
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions = data.map((e) => e['UnitShortCode'].toString()).toList();

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
          selectedValue4 = _selectedUnit;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
          selectedValue4 = _selectedUnit;
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/line?unit=$unit&ot=0'));
        // final response = await http.get(Uri.parse('http://172.16.10.11:8001/line?unit=$unit&ot=$ot'));
        if (kDebugMode) {
          print('http://14.142.248.34:10008/line?unit=$unit&ot=0');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) => {
              'LineName': item['LineName'].toString(),
              'LineID': item['LineId'].toString(),
            }).toList();
          });
          success = true; // Data successfully fetched, exit loop
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('Error fetching data (Attempt $retryCount): $e');
        }
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }

      await Future.delayed(const Duration(seconds: 2)); // Optional delay between retries
    }
  }


  int _calculateTotal(String field) {
    return _tableData.fold(0, (sum, item) {
      int value = int.tryParse(item[field]?.toString() ?? '0') ?? 0;
      return sum + value;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPassQty = _calculateTotal('PassQty');
    int totalRejectQty = _calculateTotal('RejectQty');
    int totalDefectQty = _calculateTotal('DefectQty');
    int totalRectQty = _calculateTotal('RectifiedQty');
    int totalAuditQty = _calculateTotal('AuditQty');
    int totalBalQty = _calculateTotal('BalanceQty');
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
          'EL Audit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: GestureDetector( // Wrap with GestureDetector for onTap functionality
              onTap: () async {
                bool shouldRefresh = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Refresh'),
                      content: const Text('Are you sure you want to refresh the page?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Cancel refresh
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Confirm refresh
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldRefresh) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => widget,
                    ),
                  );
                }
              },
              child: Text(
                '$line',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: isChecked ? 4 : 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54), // Border color
                                borderRadius: BorderRadius.circular(4.0), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0), // Padding inside the border
                              child: DropdownSearch<String>(
                                selectedItem: _selectedUnit,
                                dropdownDecoratorProps: const DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0), // Reduce padding for height adjustment
                                    border: InputBorder.none, // Remove inner border
                                  ),
                                ),
                                items: _dropDownOptions,
                                itemAsString: (item) => item, // Display unit names
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue4 = newValue;
                                    _selectedUnit = newValue;
                                    selectedValue3 = null; // Clear line value
                                    dropdownData3.clear(); // Clear line data
                                  });
                                  fetchLineDataFromApi(newValue!);
                                  _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: -4, // Adjust position
                            left: 10, // Adjust horizontal position if needed
                            child: Container(
                              color: Colors.white, // Background color for label text
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                'Unit',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey[700]), // Label style
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if(!isChecked)
                    Expanded(
                      flex: 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children : [
                          Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            child: DropdownSearch<String>(
                              selectedItem: _selectedMonth,
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                                  border: InputBorder.none,
                                ),
                              ),
                              items: _months,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedMonth = newValue;
                                  String? dateRange = _monthValues[newValue];
                                  List<String>? dates = dateRange?.split(',');
                                  String? startDate = dates?[0].trim();
                                  String? endDate = dates?[1].trim();
                                  _fetchTableData(startDate!,endDate!);
                                });
                              },
                            ),
                          ),
                        ),
                          Positioned(
                            top: -4, // Adjust position
                            left: 10, // Adjust horizontal position if needed
                            child: Container(
                              color: Colors.white, // Background color for label text
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                'Month',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey[700]), // Label style
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),


                    Expanded(
                      flex: 1,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Checkbox(
                              activeColor: Colors.orange,
                              value: isChecked,
                              onChanged: (bool? value) {
                                _tableData = [];
                                setState(() {
                                  isChecked = value ?? false;
                                });
                                if(isChecked){
                                  _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                                  isLineWise = false;
                                }
                                else {
                                  String? dateRange = _monthValues[_selectedMonth];
                                  List<String>? dates = dateRange?.split(',');
                                  String? startDate = dates?[0].trim();
                                  String? endDate = dates?[1].trim();
                                  _fetchTableData(startDate!,endDate!);
                                }
                              },
                            ),
                          ),
                          Positioned(
                            top: -4, // Adjust position
                            left: 0, // Adjust horizontal position if needed
                            child: Container(
                              color: Colors.white, // Background color for label text
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                'Date Wise',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey[700]), // Label style
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Checkbox(
                              activeColor: Colors.blue,
                              value: isLineWise,
                              onChanged: (bool? value) {
                                _tableData = [];
                                setState(() {
                                  isLineWise = value ?? false;
                                });
                                if(!isLineWise){
                                  _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                                }
                                else{
                                  isChecked = false;
                                  String? dateRange = _monthValues[_selectedMonth];
                                  List<String>? dates = dateRange?.split(',');
                                  String? startDate = dates?[0].trim();
                                  String? endDate = dates?[1].trim();
                                  _fetchTableData(startDate!,endDate!);
                                }
                              },
                            ),
                          ),
                          Positioned(
                            top: -4, // Adjust position
                            left: 0, // Adjust horizontal position if needed
                            child: Container(
                              color: Colors.white, // Background color for label text
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                'Line Wise',
                                style: TextStyle(fontSize: 12.0, color: Colors.grey[700]), // Label style
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


        const SizedBox(height: 10,),
        Row(

          children: [
            if(isChecked)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(fontSize: 14),
                    controller: _fromDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      suffixIcon: Icon(Icons.date_range_outlined),
                    ),
                    onTap: () {
                      _selectDate(context,true);
                    },
                  ),
                ),
              ),
            ),

            if(isChecked)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    style: TextStyle(fontSize: 14),
                    controller: _toDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      suffixIcon: Icon(Icons.date_range_outlined),
                    ),
                    onTap: () {
                      _selectDate(context,false);
                    },
                  ),
                ),
              ),
            ),


          ],
        ),
        const SizedBox(height: 10,),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width, // Ensures the table spans the full width
                child: CustomDataGrid(
                  tableData: _tableData,
                  isChecked: isChecked,
                  isLineWise: isLineWise,
                  totalPassQty: totalPassQty,
                  totalRejectQty: totalRejectQty,
                  totalDefectQty: totalDefectQty,
                  totalRectQty: totalRectQty,
                  totalAuditQty: totalAuditQty,
                  totalBalQty: totalBalQty,
                ),
              ),
            )
        ]
            )
        ),
      )
    );
  }

}


// CustomDataGrid(tableData: _tableData, isChecked: isChecked , isLineWise: isLineWise,
//                  totalPassQty: totalPassQty, totalRejectQty: totalRejectQty,
//                  totalDefectQty: totalDefectQty, totalRectQty: totalRectQty,
//                  totalAuditQty: totalAuditQty, totalBalQty: totalBalQty,)