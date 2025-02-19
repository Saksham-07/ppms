import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/uuid.dart';
import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LinewiseOTVerification extends StatefulWidget {
  const LinewiseOTVerification({super.key});

  @override
  State<LinewiseOTVerification> createState() => LinewiseOTVerificationState();
}

class LinewiseOTVerificationState extends State<LinewiseOTVerification> {
  List<Map<String, dynamic>> _tableData =
  [];
  String? _loginId;
  final TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
  late Future<List<String>> futureUnits;
  String? uuid = '';

  @override
  void initState() {
    super.initState();
    getUid();
    _dateController.text = _formatDate(selectedDate);
    futureUnits = fetchUnits();
    Future.delayed(const Duration(milliseconds: 200),(){
      _loadTableData();
    });
    rightsFunction('OTApproval');
  }
  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  void _loadTableData() {
      futureUnits.then((units) {
        final unitsString = units.join(',');
        setState(() {
          _fetchTableData(unitsString);
        });
      }).catchError((error) {
        if (kDebugMode) {
          print('Error fetching units: $error');
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
        _dateController.text = _formatDate(selectedDate);
        _loadTableData();
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  Future<void> _verifyRow(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final lineId = _tableData[index]['LineId'];
    final unitCode = _tableData[index]['UnitCode'];
    final created = _loginId;
    DateTime date = selectedDate;

    // Construct the API URL
    final String url =
        '${TBaseURL.baseUrl}update_linewise_ot_approval?lineid=$lineId&unit=$unitCode&userid=$created&dated=$date&device_id=$uuid';
    if (kDebugMode) {
      print(url);
    }
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('verified_$lineId', true);

        if (kDebugMode) {
          print('Response body: ${response.body}');
        }

        // Successfully inserted data, refresh the table
        _loadTableData();

        if (kDebugMode) {
          print('Successfully inserted data for line ID: $lineId');
        }
      } else {
        // Handle non-200 status codes
        if (kDebugMode) {
          print('Failed to insert data for line ID: $lineId. Status code: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
        // Show the dialog box with the actual response message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Required'),
              content: Text(response.body), // Display the actual API response
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle request error
      if (kDebugMode) {
        print('Error occurred while inserting data for line ID: $lineId. Error: $e');
      }
    }
  }
  bool _isRead = false;
  Future<bool> rightsFunction(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = 'http://14.142.248.34:10008/base?user=$loginId&module=MobileApplication&page=$page';
    if (kDebugMode) {
      print('http://14.142.248.34:10008/base?user=$loginId&module=MobileApplication&page=$page');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isRead = data.any((item) => item['shortname'] == 'W');
        if (kDebugMode) {
          print(_isRead);
        }
      });
      if(_isRead){
        return true;
      }
      else{
        return false;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> fetchUnits() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final response = await http.get(Uri.parse('http://14.142.248.34:10008/unit?type=pnl2&user=$_loginId'));
    if (kDebugMode) {
      print(response);
    }
    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> units = unitsJson.map((unit) => unit['UnitCode'].toString()).toList();
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> _fetchTableData(String unitCode) async {
    final String url = '${TBaseURL.baseUrl}linewise_ot_approval?unit=$unitCode&date=${_dateController.text}';
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      setState(() {
        _tableData = data.map((e) => {
          'LineName': e['LineName'],
          'UnitShortCode': e['UnitShortCode'],
          'OtHrs': e['OtHrs'],
          'LineId': e['LineId'],
          'UnitCode': e['UnitCode'],
          'StyleNo': e['StyleNo'],
        }).toList();
        if (kDebugMode) {
          print(_tableData);
        }
      });
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
          'Linewise OT Verification',
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
                    child: SizedBox(
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
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[200],
                          ),
                          children:const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Unit',
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
                                    'Style No',
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
                                    'OT Hrs',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(''),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ..._tableData.map((row) {
                          final index = _tableData.indexOf(row);

                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['UnitShortCode']),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    row['StyleNo'].length > 15
                                        ? row['StyleNo'].substring(0, 15)
                                        : row['StyleNo'],
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['LineName'].toString(),textAlign: TextAlign.left),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['OtHrs'].toString(),textAlign: TextAlign.right),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Visibility(
                                    visible: _isRead,
                                    child: SizedBox(
                                      width: 80,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: row['isVerify'] == 1 ? Colors.grey : Colors.green,
                                        ),
                                        onPressed: row['isVerify'] == 1 ? null : () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Confirmation'),
                                                content: const Text('Are you sure you want to verify this row?'),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Confirm'),
                                                    onPressed: () {
                                                      _verifyRow(index);
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
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