import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/Allocation/verification_report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/uuid.dart';
import '../common/utils/constants/baseurl.dart';

class ManpowerVerify extends StatefulWidget {
  const ManpowerVerify({super.key});

  @override
  State<ManpowerVerify> createState() => _ManpowerVerifyState();
}

class _ManpowerVerifyState extends State<ManpowerVerify> {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  List<Map<String, dynamic>> _tableData = [];
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  int _totalTailor = 0;
  int _totalHelper = 0;
  int _totalManpower = 0;
  int _totalVerified = 0;
  List<Map<String, dynamic>> _filteredData = [];
  List<String> _remarks = []; // To store remarks for each row
  TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
  Timer? _timer;
  String uuid = '';

  @override
  void initState() {
    super.initState();
    getUid();
    deleteDouble();
    Future.delayed(Duration(milliseconds: 200),(){
      _fetchDropDownOptions();
    });
    _dateController.text = _formatDate(selectedDate);
    _timer?.cancel(); // Cancel any previous timer if it exists
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchTableData(_selectedUnitCode!);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
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
          _fetchTableData(_selectedUnitCode!);
          Future.delayed(Duration(milliseconds: 200),(){

          _fetchTotalPresent(_selectedUnitCode!);
          });
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> _fetchTableData(String unitCode) async {
    final String url = 'http://14.142.248.34:10008/fetch_mnpwr_verify?unit_code=$unitCode';
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _tableData = data.map((e) => {
          'LineName': e['LineName'],
          'Mnpwr': e['Mnpwr'],
          'TailorCount': e['TailorCount'],
          'HelperCount': e['HelperCount'],
          'LineId': e['LineId'],
          'VerifyMnpwr' : e['VerifyMnpwr'],
          'isVerify': e['IsVerified'],
          'Remarks' : e['Remarks'],
        }).toList();

        // Initialize the remarks list with empty strings
        _remarks = List.generate(_tableData.length, (_) => '');

        _filteredData = List.from(_tableData);
        _totalTailor = _tableData.fold(0, (sum, row) => sum + (row['TailorCount'] as int));
        _totalHelper = _tableData.fold(0, (sum, row) => sum + (row['HelperCount'] as int));
        _totalManpower = _tableData.fold(0, (sum, row) => sum + (row['Mnpwr'] as int));
        _totalVerified = _tableData.fold(0, (sum, row) => sum + ((row['VerifyMnpwr'] ?? 0) as int));
      });
    }
  }

  void navigateToReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationReport(),//fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }

  Future<void> _verifyRow(int index) async {
    final lineId = _tableData[index]['LineId'];
    final unitCode = _selectedUnitCode;
    final created = _loginId;
    final manpower = _tableData[index]['Mnpwr'];
    final remark = _remarks[index]; // Get the remark for the row

    // Construct the API URL
    final String url =
        'http://14.142.248.34:10008/insert_verify_mnpwr?line=$lineId&unit=$unitCode&created=$created&mnpwr=$manpower&remark=$remark&device_id=$uuid';
    if (kDebugMode) {
      print(url);
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (response.body.contains("Kindly re-verify mnpwr.")) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Verification Required'),
                content: Text(response.body),
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
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('verified_$lineId', true);

          if (kDebugMode) {
            print('Response body: ${response.body}');
          }

          // Reload table data after a delay
          Future.delayed(Duration(milliseconds: 300), () {
            _fetchTableData(unitCode!);
          });

          if (kDebugMode) {
            print('Successfully inserted data for line ID: $lineId');
          }
        }
      } else {
        // Handle non-200 status codes
        print('Failed to insert data for line ID: $lineId. Status code: ${response.statusCode}');
        if (kDebugMode) {
          print('Response body: ${response.body}');
          {
            // Show the dialog box with the actual response message
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Verification Required'),
                  content: Text(response.body), // Display the actual API response
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      // Handle request error
      print('Error occurred while inserting data for line ID: $lineId. Error: $e');
    }
  }

  Future<void> _fetchTotalPresent(String unitCode) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/total_alloc?unit=$unitCode&dated='));

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
            success = true; // Exit the loop if data is fetched successfully
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

  Future<void> deleteDouble() async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;

    {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/delete_double_line_alloc'));

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('Done');
          }
        } else {
          throw Exception('Failed');
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

  void _filterTableData(String query) {
    setState(() {
      _filteredData = _tableData.where((row) {
        return row['LineName'].toLowerCase().contains(query.toLowerCase()) ||
            row['TailorCount'].toString().toLowerCase().contains(query.toLowerCase()) ||
            row['HelperCount'].toString().toLowerCase().contains(query.toLowerCase()) ||
            row['Mnpwr'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
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
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Center(
        //       child: Container(
        //         decoration: BoxDecoration(
        //           color: Color(0xFF2CA496),
        //           // color: Colors.yellowAccent,
        //           shape: BoxShape.rectangle,
        //
        //         ),
        //         child: Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Text("Mnpwr : $_totalMnpwr" ,textAlign: TextAlign.center, style: TextStyle(
        //             // color: Colors.black,
        //             color: Colors.white,
        //             fontWeight: FontWeight.bold
        //           ),),
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
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
                      decoration: InputDecoration(
                        labelText: 'Select Unit',
                        border: OutlineInputBorder(),
                        isDense: true, // Reduces the height
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0), // Controls the internal padding
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
                          deleteDouble();
                          Future.delayed(Duration(milliseconds: 100),(){
                            _fetchTotalPresent(_selectedUnitCode!);
                            Future.delayed(Duration(milliseconds: 200), () {
                              _fetchTableData(_selectedUnitCode!);
                            });
                          });
                        });
                      },
                    )

                  ),
                  SizedBox(width: 20,),
                  // Expanded(
                  //   child: TextFormField(
                  //     controller: _dateController,
                  //     readOnly: true,
                  //     decoration: const InputDecoration(
                  //       labelText: 'Select Date',
                  //       border: OutlineInputBorder(),
                  //       suffixIcon: Icon(Icons.date_range_outlined),
                  //     ),
                  //     onTap: () {
                  //       _selectDate(context);
                  //     },
                  //   ),
                  // ),
                  Container(
                      height :30,
                      child: ElevatedButton(onPressed: ()=> navigateToReport(context), child: Text('Report',style: TextStyle(color: Colors.white),) , style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),))
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
                        0: FixedColumnWidth(80),
                        1: FixedColumnWidth(40),
                        2: FixedColumnWidth(40),
                        3: FixedColumnWidth(50),
                        4: FixedColumnWidth(50),
                        5: FixedColumnWidth(105),
                        6: FixedColumnWidth(160), // New column for Remark
                      },
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
                                    'Talr',textAlign: TextAlign.center,
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
                                    'Hlpr',textAlign: TextAlign.center,
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
                                    'Man\npower',textAlign: TextAlign.center,
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
                                    'Veri\nfied',textAlign: TextAlign.center,
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
                            ),TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Review',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        ..._filteredData.map((row) {
                          final index = _filteredData.indexOf(row);

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
                                  child: Text(row['TailorCount'].toString(),textAlign: TextAlign.right),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['HelperCount'].toString(),textAlign: TextAlign.right),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['Mnpwr'].toString(),textAlign: TextAlign.right),
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
                                  child: SizedBox(
                                    width: 50,
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
                                      child: Text(
                                        row['isVerify'] == 1 ? 'Verified' : 'Verify',
                                        style: TextStyle(
                                          color: row['isVerify'] == 1 ? Colors.black : Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            _remarks[index] = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          hintText: row['isVerify'] == 1 ? row['Remarks'] : 'Enter Remark',
                                          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
                                          hintStyle: TextStyle(
                                            color: row['isVerify'] == 1 ? Colors.black : Colors.grey,
                                          )
                                        ),
                                        readOnly: row['isVerify'] == 1 ? true : false,
                                      ),
                                    ),
                                  ),
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
                                  _totalManpower.toString(),textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalVerified.toString(),textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(),
                              ),
                            ),TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(),
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