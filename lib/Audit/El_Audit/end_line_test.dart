import 'dart:async';
// import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/utils/constants/baseurl.dart';

class AuditTestPage extends StatefulWidget {
  const AuditTestPage({super.key});

  @override
  _AuditTestPageState createState() => _AuditTestPageState();
}

class _AuditTestPageState extends State<AuditTestPage> {
  List<Map<String, dynamic>> _tableData = [];
  int passCounter = 0;
  int rejectCounter = 0;
  int defectCounter = 0;
  int rectifiedCounter = 0;
  int selectedRadioIndex = -1;
  String? previousValue;
  List<String> selectedDefects = [];
  List<String> selectedReasons = [];
  Map<String, List<String>> selectedReasonsWithDefects = {};
  List<dynamic> dataMap = [];
  List<dynamic> permMap = [];
  Map<String,dynamic> finalD = {};
  Map<String,dynamic> permData = {};
  Map<dynamic,dynamic> defectData = {};
  String dataKey = 'DataMap';
  String? line;
  final FocusNode _focusNode = FocusNode();
  bool popUp = false;
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  Timer? _apiTimer;
  bool isSuc = false;
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  late List<Map<String, String>> defectOptions = [];
  late List<Map<String, String>> reasonOptions = [];
  String version= '';


  @override
  initState() {
    super.initState();setState(() {
      getVersionNo();
    });
    fetchPermDataAndCheckDate();
    _fetchDropDownOptions();
    Future.delayed(const Duration(milliseconds: 300),(){
      fetchLineDataFromApi(_selectedUnit!);
    });
    Future.delayed(const Duration(milliseconds: 500),(){
      if (_selectedUnit != null && selectedValue3 != null) {
        final unitCode = _unitMap[_selectedUnit]; // Use UnitCode for getData
        _fetchTableData(selectedLineID!,unitCode!); // Pass UnitCode and LineId

        _fetchTableData(selectedLineID! , unitCode)
      .then((_) {
      if (_tableData.isNotEmpty) {
      setState(() {
      selectedRadioIndex = 0;
      });
      _onRadioButtonChanged(0);
      }
      });
    }
    });
    fetchData();
    _fetchDefectOptionsAndReasons();
    _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      sendDataToApis();  // This function will be called every 30 seconds
    });
  }
  Future<void> _fetchDefectOptionsAndReasons() async {
    defectOptions = await _fetchDefectOptions();
    reasonOptions = await _fetchReasonsOptions();
  }

  Future<void> getVersionNo() async{
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      if (kDebugMode) {
      }
    });
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
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('${TBaseURL.baseUrl}line?unit=$unit&ot=0'));
        if (kDebugMode) {
          print('${TBaseURL.baseUrl}line?unit=$unit');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) => {
              'LineName': item['LineName'].toString(),
              'LineID': item['LineId'].toString(),
            }).toList();
          });
          success = true;
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
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void fetchData() async {
    List<dynamic> dataMaps = await fetchDataMap();
    List<dynamic> permDatas = await fetchPermMap();
    if (kDebugMode) {
      print('dataMap: $dataMaps');
      print('permData: $permDatas');
    }
    if(dataMaps.isNotEmpty){
      dataMap = dataMaps;
    }if(permDatas.isNotEmpty){
      permMap = permDatas;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _apiTimer?.cancel();
    super.dispose();
  }

  Future<void> saveCatchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('dataKey', json.encode(dataMap));
    await prefs.setString('PermData', json.encode(permMap));
    String currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('saved_date', currentDate);
  }

  Future<void> fetchPermDataAndCheckDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the saved date from SharedPreferences
    String? savedDate = prefs.getString('saved_date');
    String currentDate = DateTime.now().toIso8601String().split('T')[0];

    // Check if the date has changed
    if (savedDate == null || savedDate != currentDate) {
      // If the date has changed, clear the PermData
      await prefs.remove('PermData');
      await prefs.remove('saved_date');
      permMap.clear();
      if (kDebugMode) {
        print("PermData has been cleared because the day has changed.");
      }
    } else {
      // If the date is the same, fetch the PermData
      String? permDataJson = prefs.getString('PermData');
      if (permDataJson != null) {
        permMap = List<Map<String, dynamic>>.from(json.decode(permDataJson));
        if (kDebugMode) {
          print("PermData loaded: $permMap");
        }
      }
    }
  }

  Future<List<dynamic>> fetchDataMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('DataMap');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData); // Decode JSON string back to List
      return List<dynamic>.from(decodedData); // Convert to List<Map<String, dynamic>>
    } else {
      return []; // Return empty list if no data found
    }
  }

  Future<List<dynamic>> fetchPermMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? permTData = prefs.getString('PermData');

    if (permTData != null) {
      List<dynamic> decodedData = jsonDecode(permTData); // Decode JSON string back to List
      return List<dynamic>.from(decodedData); // Convert to List<Map<String, dynamic>>
    } else {
      return []; // Return empty list if no data found
    }
  }

  Future<void> _fetchTableData(String line , String unit) async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}line_data?unit_code=$unit&dated=$todayDate&line_id=$line&version=$version'));
    // final response = await http.get(Uri.parse('${TBaseURL.baseUrl}line_data?unit_code=$unit&dated=$todayDate&line_id=$lineId'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}line_data?unit_code=$unit&dated=2024-09-02&line_id=$line');
    }
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load table data');
    }
  }

  int _calculateTotal(String field) {
    return _tableData.fold(0, (sum, item) {
      // Ensure the value is an integer or can be parsed as an integer
      int value = int.tryParse(item[field]?.toString() ?? '0') ?? 0;
      return sum + value;
    });
  }

  Future<void> _fetchCounter(String order, String style, String color) async {
    if(permMap.isNotEmpty){
      if (kDebugMode) {
        print('In Perm Map');
      }
      var matchingEntry = permMap.firstWhere(
              (entry) => entry['style'] == style && entry['order'] == order && entry['color'] == color,
          orElse: () => {}
      );
      if (kDebugMode) {
        print('in');
        print('pass : ${matchingEntry['pass']}');
        print('${matchingEntry['defect']}');
        print('${matchingEntry['rectified']}');
        print('${matchingEntry['reject']}');
      }
      if (matchingEntry.isNotEmpty) {
        setState(() {
          passCounter = matchingEntry['pass'] ?? 0;
          defectCounter = matchingEntry['defect'] ?? 0;
          rectifiedCounter = matchingEntry['rectified'] ?? 0;
          rejectCounter = matchingEntry['reject'] ?? 0;
        });
      }
      else{
        setState(() {
          passCounter = 0;
          defectCounter = 0;
          rectifiedCounter = 0;
          rejectCounter = 0;
        });
      }
    }
    else{
      if (kDebugMode) {
        print('Out Of Perm');
      }
      try {
        final response = await http.get(Uri.parse('${TBaseURL.baseUrl}el_counter?order=$order&style=$style&color=$color&line_id=$selectedLineID'));

        if (kDebugMode) {
          print('${TBaseURL.baseUrl}el_counter?order=$order&style=$style&color=$color&line_id=$selectedLineID');
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (kDebugMode) {
            print('Success1');
          }
          {
            setState(() {
              if (kDebugMode) {
                print('Success2');
              }
              if (dataMap.isNotEmpty) {
                if (kDebugMode) {
                  print('Success3');
                }
                var matchingEntry = dataMap.firstWhere(
                        (entry) => entry['style'] == style && entry['order'] == order && entry['color'] == color,
                    orElse: () => {}
                );
                if (kDebugMode) {
                  print('in');
                  print('pass : ${matchingEntry['pass']}');
                  print('${matchingEntry['defect']}');
                  print('${matchingEntry['rectified']}');
                  print('${matchingEntry['reject']}');
                }
                if (matchingEntry.isNotEmpty) {
                  setState(() {
                    passCounter = matchingEntry['pass'] ?? 0;
                    defectCounter = matchingEntry['defect'] ?? 0;
                    rectifiedCounter = matchingEntry['rectified'] ?? 0;
                    rejectCounter = matchingEntry['reject'] ?? 0;
                  });
                }
              } else {
                if (data != null && data.isNotEmpty) {
                  if (kDebugMode) {
                    print('out');
                    print('pass : ${data[0]['PassQty'] ?? 0}');
                    print(data[0]['DefectQty'] ?? 0);
                    print(data[0]['RectifiedQty'] ?? 0);
                    print(data[0]['RejectedQty'] ?? 0);
                  }
                  setState(() {
                    passCounter = data[0]['PassQty'] ?? 0;
                    defectCounter = data[0]['DefectQty'] ?? 0;
                    rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
                    rejectCounter = data[0]['RejectedQty'] ?? 0;
                  });

                }
                else{
                  setState(() {
                    passCounter = 0;
                    defectCounter = 0;
                    rectifiedCounter = 0;
                    rejectCounter = 0;
                  });

                }
              }
            });
          }
        } else {
          throw Exception('Failed to load counter data');

        }
      } catch (e) {
        setState(() {
          passCounter = 0;
          defectCounter = 0;
          rectifiedCounter = 0;
          rejectCounter = 0;
        });
        if (kDebugMode) {
          print('Error fetching counter data: $e');
        }
      }
    }
  }

  Future<List<Map<String, String>>> _fetchDefectOptions() async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}defect?type=defect'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'DefectName': item['DefectName'] as String,
          'DefectCode': item['DefectCode'] as String,
        };
      }).toList();
    } else {
      throw Exception('Failed to load defect options');
    }
  }

  Future<List<Map<String, String>>> _fetchReasonsOptions() async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}defect?type=comp'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'CompName': item['CompName'] as String,
          'CompCode': item['CompCode'] as String,
        };
      }).toList();
    } else {
      throw Exception('Failed to load reasons options');
    }
  }

  Future<void> _showReasonPopup() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Component'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasonOptions.map((reason) {
                bool isSelected = selectedReasonsWithDefects.containsKey(reason['CompCode']);
                return RadioListTile<String>(
                  title: Text(reason['CompName']!),
                  value: reason['CompCode']!,
                  groupValue: selectedReasons.isEmpty ? null : selectedReasons.first,
                  onChanged: (String? value) {
                    setState(() {
                      selectedDefects.clear();
                      selectedReasons = [value!];

                      if (selectedReasonsWithDefects.containsKey(value)) {
                        selectedDefects = selectedReasonsWithDefects[value]!.toList();
                      }
                      Navigator.pop(context);
                      _showDefectPopup();
                    });
                  },
                  activeColor: isSelected ? Colors.grey : null,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                defectData['defectData ${defectCounter + 1}'] = {
                  'selectedReasonsWithDefects': selectedReasonsWithDefects,
                  'defectCounter': defectCounter + 1
                };
                finalD['defectData'] = defectData;
                onDataReceived();
                saveData();
                Future.delayed(const Duration(milliseconds: 200), () {
                  printData();
                  catchData();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    saveCatchData();
                  });
                });
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDefectPopup() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Defect'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: defectOptions.map((defect) {
                    return CheckboxListTile(
                      title: Text(defect['DefectName']!),
                      value: selectedDefects.contains(defect['DefectCode']),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedDefects.add(defect['DefectCode']!);
                          } else {
                            selectedDefects.remove(defect['DefectCode']!);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedDefects.isNotEmpty && selectedReasons.isNotEmpty) {
                      String currentReason = selectedReasons.first;
                      selectedReasonsWithDefects[currentReason] = selectedDefects.toList();
                      Navigator.pop(context);
                      _showReasonPopup(); // Go back to reason popup
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void onDataReceived() {
    setState(() {
      selectedReasons.clear();
      selectedDefects.clear();
      if(selectedReasonsWithDefects.isNotEmpty) {
        defectCounter++;
      }
      selectedReasonsWithDefects = {};
    });
  }

  Future<void> _onRadioButtonChanged(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getInt('line_ids');
    sendDataToApis();

    setState(() {
      selectedRadioIndex = index;
      final newRow = _tableData[selectedRadioIndex];
      Future.delayed(const Duration(milliseconds: 400),(){

        _fetchCounter(newRow['OrderNo'], newRow['StyleNo'].toString(), newRow['Color']);
      });
    });

    // Clear the data to make room for new data for the selected radio button
    setState(() {
      defectData = {};
      finalD = {};
    });

    if (dataMap.isNotEmpty) {
      for (var item in dataMap) {
        if (item['style'] == _tableData[index]['StyleNo'] &&
            item['order'] == _tableData[index]['OrderNo'] &&
            item['color'] == _tableData[index]['Color']) {
          // Load the existing data into finalD and defectData
          setState(() {
            finalD = item;
            defectData = item['defectData'] ?? {};
          });
          break;
        }
      }
    }
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getInt('line_ids');
    if (selectedRadioIndex != -1) {
      final previousRow = _tableData[selectedRadioIndex];
      // finalD['line'] = lineId;
      finalD['style'] = previousRow['StyleNo'];
      finalD['order'] = previousRow['OrderNo'];
      finalD['color'] = previousRow['Color'];
      finalD['pass'] = passCounter;
      finalD['reject'] = rejectCounter;
      finalD['defect'] = defectCounter;
      finalD['rectified'] = rectifiedCounter;

      permData['style'] = previousRow['StyleNo'];
      permData['order'] = previousRow['OrderNo'];
      permData['color'] = previousRow['Color'];
      permData['pass'] = passCounter;
      permData['reject'] = rejectCounter;
      permData['defect'] = defectCounter;
      permData['rectified'] = rectifiedCounter;
      if (kDebugMode) {
        print(finalD);
      }
    }
  }

  Future<void> printData() async {
    bool isExist = false;

    for (var i = 0; i < dataMap.length; i++) {
      if (dataMap[i]['style'] == finalD['style'] &&
          dataMap[i]['order'] == finalD['order'] &&
          dataMap[i]['color'] == finalD['color']) {
        dataMap[i]['pass'] = finalD['pass'];
        dataMap[i]['defect'] = finalD['defect'];
        dataMap[i]['reject'] = finalD['reject'];
        dataMap[i]['rectified'] = finalD['rectified'];
        dataMap[i]['defectData'] = finalD['defectData'];
        isExist = true;
        break;
      }
    }

    if (kDebugMode) {
      print(isExist);
    }

    if (!isExist && finalD.isNotEmpty) {
      setState(() {
        dataMap.add(finalD); // Add new data if it doesn't exist
      });
    }
    log('DataMap: $dataMap');
  }

  Future<void> catchData() async {
    bool isExistP = false;

    for (var i = 0; i < permMap.length; i++) {
      // Check if the current entry matches the style, order, and color
      if (permMap[i]['style'] == permData['style'] &&
          permMap[i]['order'] == permData['order'] &&
          permMap[i]['color'] == permData['color']) {
        // If it exists, update the data for the matching entry
        permMap[i]['pass'] = permData['pass'];
        permMap[i]['defect'] = permData['defect'];
        permMap[i]['reject'] = permData['reject'];
        permMap[i]['rectified'] = permData['rectified'];
        isExistP = true;
        break;
      }
    }

    if (!isExistP && permData.isNotEmpty) {
      setState(() {
        permMap.add(Map.from(permData));
      });
    }

    // Logging to check results
    if (kDebugMode) {
      print('permMap: $permMap');
      print('permData: $permData');
      print('Data Exists: $isExistP');
    }
  }

  Future<void> sendDataToApis() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? userId = prefs.getString('login_id');
    // String? unit =_unitMap[_selectedUnit];
    // String? line = selectedLineID!;
    //
    // if (dataMap.isNotEmpty) {
    //   for (var entry in dataMap) {
    //     if (entry['style'] != null && entry['order'] != null &&
    //         entry['color'] != null) {
    //       String style = entry['style'];
    //       String order = entry['order'];
    //       String color = entry['color'];
    //       int pass = entry['pass'];
    //       int reject = entry['reject'];
    //       int defect = entry['defect'];
    //       int rectified = entry['rectified'];
    //       Map? defectData = entry['defectData'];
    //
    //       Map<String, dynamic> headerData = await sendHeaderData(
    //         unit!,
    //         line,
    //         style,
    //         order,
    //         color,
    //         pass,
    //         reject,
    //         defect,
    //         rectified,
    //         userId!,
    //       );
    //
    //       // Extract auditNo from headerData response
    //       String auditNo = headerData['auditNo'];
    //       // Store auditNo in dataMap to prevent duplicate header API calls
    //       entry['auditNo'] = auditNo;
    //       // Now, handle defectData if present
    //       if (defectData == null || defectData.isEmpty) {
    //         if (kDebugMode) {
    //           print(
    //             'No defect data found for this entry. Skipping component and defect code API calls.');
    //         }
    //         continue; // Skip to the next entry if no defect data is found
    //       }
    //
    //       // Now, handle defectData if present
    //       defectData.forEach((key, value) async {
    //         int defectCounter = value['defectCounter'];
    //         Map<String,
    //             List<
    //                 String>> selectedReasonsWithDefects = value['selectedReasonsWithDefects'];
    //
    //         // Second API Call (Component Data)
    //         for (var component in selectedReasonsWithDefects.keys) {
    //           int componentId = await sendComponentData(
    //             defectCounter,
    //             auditNo,
    //             component,
    //             userId,
    //           );
    //
    //           // Third API Call (Defect Codes Data)
    //           for (var defectCode in selectedReasonsWithDefects[component]!) {
    //             await sendDefectCodeData(
    //               auditNo,
    //               defectCounter,
    //               componentId,
    //               defectCode,
    //               userId,
    //             );
    //           }
    //         }
    //       });
    //
    //     }
    //   }
    //   if (isSuc) {
    //     if (kDebugMode) {
    //       print('datamap $dataMap');
    //     }
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     bool isRemoved = await prefs.remove(dataKey);
    //
    //     if (isRemoved) {
    //       if (kDebugMode) {
    //         print('dataMap cleared successfully');
    //       }
    //     } else {
    //       if (kDebugMode) {
    //         print('Failed to clear dataMap');
    //       }
    //     }
    //     setState(() {
    //       dataMap.clear();
    //       if (kDebugMode) {
    //         print(dataMap);
    //       }
    //     });
    //   }
    // }else {
    //   if (kDebugMode) {
    //     print('Empty');
    //   }
    // }
  }

  Future<Map<String, dynamic>> sendHeaderData(String unit, String line, String style, String order, String color,
      int pass, int reject, int defect, int rectified, String userId) async {

    String apiUrl = "${TBaseURL.baseUrl}insert_endline";
    Uri uri = Uri.parse(
        "$apiUrl?flag=Hdr&unit=$unit&line_id=$line&style=$style&order=$order"
            "&color=$color&pass=$pass&defect=$defect&reject=$reject&rectified=$rectified&user=$userId"
    );
    if (kDebugMode) {
      print(uri);
    }

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) { // Check if the request was successful
        var responseBody = json.decode(response.body);
        if (kDebugMode) {
          print(responseBody);
        }
        String auditNo = responseBody[0]['AuditNo'];
        isSuc = true; // Set isSuc to true if success
        return {'auditNo': auditNo};
      } else {
        throw Exception('Failed to send header data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      isSuc = false; // Set isSuc to false if an error occurs
      rethrow;
    }
  }

  Future<int> sendComponentData(int auditId, String auditNo, String component, String userId) async {

    String apiUrl = "${TBaseURL.baseUrl}insert_defect";
    Uri uri = Uri.parse(
        "$apiUrl?flag=Component&audit_no=$auditNo&docId=$auditId"
            "&component=$component&defect=&dtlDocId=&user=$userId"
    );
    if (kDebugMode) {
      print(uri);
    }

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) { // Check if the request was successful
        var responseBody = json.decode(response.body);
        if (kDebugMode) {
          print(responseBody);
        }
        int componentId = responseBody[0]['componentId'];
        isSuc = true; // Set isSuc to true if success
        return componentId;
      } else {
        throw Exception('Failed to send component data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      isSuc = false; // Set isSuc to false if an error occurs
      rethrow;
    }
  }

  Future<void> sendDefectCodeData(String auditNo, int docId, int componentId, String defectCode, String userId) async {

    String apiUrl = "${TBaseURL.baseUrl}insert_defect";
    Uri uri = Uri.parse(
        "$apiUrl?flag=Defect&audit_no=$auditNo&docId=$docId"
            "&component=&defect=$defectCode&dtlDocId=$componentId&user=$userId"
    );
    if (kDebugMode) {
      print(uri);
    }

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) { // Check if the request was successful
        isSuc = true; // Set isSuc to true if success
      } else {
        throw Exception('Failed to send defect code data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      isSuc = false; // Set isSuc to false if an error occurs
      rethrow;
    }
  }

  void _handlePassOrReject({required Map<String, dynamic> defect, required bool isPass,}) async {
    String auditNo = defect['AuditNo'];
    String color = defect['Color'];
    String style = defect['StyleNo'];
    int docId = defect['DocId'];
    String order = defect['OrderNo'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('login_id');
    String? unit = _unitMap[_selectedUnit];
    String? line = selectedLineID!;

    // Determine pass or reject
    String action = isPass ? 'Pass' : 'Reject';

    String apiUrl = "${TBaseURL.baseUrl}insert_defect";
    Uri uri = Uri.parse(
        "$apiUrl?flag=Rectified&dtlDocId=$docId&audit_no=$auditNo"
            "&rectify_status=$action&user=$userId"
    );

    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Defect updated successfully.');
        }
        setState(() {
          if (isPass) {
            passCounter++;
            rectifiedCounter++;
            defectCounter--;
          } else {
            rejectCounter++;
            rectifiedCounter++;
            defectCounter--;
          }
          sendHeaderData(unit!, line, style, order, color, passCounter, rejectCounter, defectCounter, rectifiedCounter, userId!);
        });
      } else {
        throw Exception('Failed to update defect');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating defect: $error');
      }
    }
  }

  void _showRectifiedPopup() async {
    var defectData = await _rectifiedDataTable();

    if (defectData.isEmpty) {
      ScaffoldMessenger.of(mounted as BuildContext).showSnackBar(
        const SnackBar(content: Text('No defects found!')),
      );
      return;
    }

    await showDialog(
      context: mounted as BuildContext,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> reloadData() async {
              var updatedData = await _rectifiedDataTable();
              setState(() {
                defectData = updatedData;
              });
            }

            return AlertDialog(
              title: const Text("Rectified Defects"),
              content: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: Table(
                    border: TableBorder.all(),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.lightBlue[200]),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Component',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Defect',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Action',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...defectData.map((defect) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(defect['ComponentIds']),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(defect['DefectIds']),
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () async {
                                        bool confirm = await _showConfirmationDialog(
                                          context,
                                          "Do you want to pass this Qty?",
                                        );
                                        if (confirm) {
                                          _handlePassOrReject(
                                            defect: defect,
                                            isPass: true,
                                          );
                                          setState(() async {
                                            await reloadData();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 35,
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () async {
                                        bool confirm = await _showConfirmationDialog(
                                          context,
                                          "Do you want to reject this Qty?",
                                        );
                                        if (confirm) {
                                          _handlePassOrReject(
                                            defect: defect,
                                            isPass: false,
                                          );
                                          setState(() async {
                                            await reloadData();
                                          }); // Reload data after reject
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Refresh the entire page after closing the popup
      Navigator.pushReplacement(
        mounted as BuildContext,
        MaterialPageRoute(
          builder: (BuildContext context) => widget,
        ),
      );
    });
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);  // Cancel action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);  // Confirm action
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ) ?? false;  // Return false if the dialog is dismissed
  }

  Future<List<Map<String, dynamic>>> _rectifiedDataTable() async {
    String? unit = _unitMap[_selectedUnit];
    String? line = selectedLineID;
    final newRow = _tableData[selectedRadioIndex];
    String apiUrl = "${TBaseURL.baseUrl}el_rectify?lineid=$line&order=${newRow['OrderNo']}&style=${newRow['StyleNo'].toString()}&color=${newRow['Color']}&unit=$unit";  // Replace with your actual API URL
    if (kDebugMode) {
      print(apiUrl);
    }

    try {
      Uri uri = Uri.parse(apiUrl);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Assuming API returns a list of defects as JSON objects
        List<Map<String, dynamic>> defectData = List<Map<String, dynamic>>.from(data);

        return defectData;
      } else {
        throw Exception('Failed to load defects');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching defects: $error');
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the sum of pass, reject, defect, and rectified from dataMap
    int totalPass = 0;
    int totalReject = 0;
    int totalDefect = 0;
    int totalRectified = 0;

    if (dataMap.isNotEmpty) {
      for (var line in dataMap) {
        totalPass += int.tryParse(line['pass'].toString()) ?? 0;
        totalReject += int.tryParse(line['reject'].toString()) ?? 0;
        totalDefect += int.tryParse(line['defect'].toString()) ?? 0;
        totalRectified += int.tryParse(line['rectified'].toString()) ?? 0;
      }
    }

    int totalIssueQty = _calculateTotal('IssueQty');
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
          'End Line Audit Testing',
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
                  // Perform your refresh logic here
                  // You can call a method to reload data or rebuild the page
                  Navigator.pushReplacement(
                    mounted as BuildContext,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dataMap.isNotEmpty)
                Container(
                  height: 30, // Height for the moving text
                  color: Colors.grey[300], // Background color of the text area
                  child: Marquee(
                    text: 'Pass: $totalPass, Reject: $totalReject, Defect: $totalDefect, Rectified: $totalRectified',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 200.0, // Spacing between repeats
                    velocity: 70.0,
                    showFadingOnlyWhenScrolling: true,
                    startPadding: 10.0, // Padding at the start
                    accelerationDuration: const Duration(seconds: 1), // Speed up time
                    accelerationCurve: Curves.linear,
                    decelerationDuration: const Duration(milliseconds: 500), // Slow down time
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              const SizedBox(height: 20,),
              // Unit Dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<String>(
                      selectedItem: _selectedUnit,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Unit',
                        ),
                      ),
                      items: _dropDownOptions, // Displays the UnitShortCode
                      itemAsString: (item) => item, // Display UnitShortCode
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          selectedValue4 = newValue;
                          // Fetch UnitCode from _unitMap and use it in getData
                          selectedValue3 = null; // Clear previous line selection
                          dropdownData3.clear(); // Clear line data
                          dropdownData5.clear(); // Clear tailor data
                          fetchLineDataFromApi(_selectedUnit!); // Fetch line data based on UnitCode
                        });
                        // Call getData if needed
                        if (_selectedUnit != null && selectedValue3 != null) {
                          final unitCode = _unitMap[_selectedUnit]; // Use UnitCode for getData
                          _fetchTableData(selectedLineID!, unitCode!); // Pass UnitCode and LineId
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Add space between the two dropdowns
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        constraints: BoxConstraints(
                          maxHeight: 350.0,
                        ),
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            border: OutlineInputBorder(),
                            hintText: 'Search...',
                          ),
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Line',
                        ),
                      ),
                      items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(), // Display LineName
                      itemAsString: (item) => item,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue3 = newValue;
                          // Fetch LineID from dropdownData3 and use it in getData
                          selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                        });
                        // Call getData with selected UnitCode and LineID
                        if (_selectedUnit != null && selectedLineID != null) {
                          final unitCode = _unitMap[_selectedUnit]; // Use UnitCode for getData
                          _fetchTableData(selectedLineID!, unitCode!); // Pass UnitCode and LineId
                        }
                      },
                      selectedItem: selectedValue3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FixedColumnWidth(30),
                    1: FixedColumnWidth(100),
                    2: FixedColumnWidth(130),
                    3: FixedColumnWidth(60),
                    4: FixedColumnWidth(60),
                    5: FixedColumnWidth(60),
                    6: FixedColumnWidth(150),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[200],
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Style No', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Color', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Issue Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Audit Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Bal Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Buyer Name', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    ..._tableData.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> item = entry.value;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Radio<int>(
                                value: index,
                                groupValue: selectedRadioIndex,
                                onChanged: (value) => _onRadioButtonChanged(index),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SelectableText(item['StyleNo'].toString(), textAlign: TextAlign.left),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['Color'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(item['IssueQty'].toString(), textAlign: TextAlign.right),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(item['AuditQty'].toString(), textAlign: TextAlign.right),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Text(item['BalanceQty'].toString(), textAlign: TextAlign.right),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['BuyerName'] != null && item['BuyerName']!.length > 15
                                ? '${item['BuyerName']!.substring(0, 15)}..'
                                : item['BuyerName'] ?? ''),
                          ),
                        ],
                      );
                    }),
                    // Add the total row at the end
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                      ),
                      children: [

                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(''),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(''),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(totalIssueQty.toString(), textAlign: TextAlign.right),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(totalAuditQty.toString(), textAlign: TextAlign.right),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(totalBalQty.toString(), textAlign: TextAlign.right),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(''),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Counter buttons
              Row(
                children: [
                  _buildCounterButton('Pass', Colors.green, passCounter, () {
                    setState(() {
                      passCounter++;
                      saveData();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        printData();
                        catchData();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          saveCatchData();
                        });
                      });
                    });
                                    }, () {
                    setState(() {
                      passCounter = (passCounter > 0) ? passCounter - 1 : 0;
                    });
                                    }, enabled: selectedRadioIndex != null),
                  _buildCounterButton('Reject', Colors.red, rejectCounter, () {
                    setState(() {
                      rejectCounter++;
                      saveData();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        printData();
                        catchData();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          saveCatchData();
                        });
                      });
                    });
                                    }, () {
                    setState(() {
                      rejectCounter = (rejectCounter > 0) ? rejectCounter - 1 : 0;
                    });
                                    }, enabled: selectedRadioIndex != null),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  _buildSimpleButton('Defect', Colors.orange, defectCounter, () {
                    _showReasonPopup();
                    saveData();
                                    }, enabled: selectedRadioIndex != null),
                  _buildSimpleButton('Rectified', Colors.blue, rectifiedCounter, () {
                    setState(() {
                      saveData();
                      Future.delayed(const Duration(milliseconds: 200), () {
                        printData();
                        catchData();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          saveCatchData();
                          Future.delayed(const Duration(milliseconds: 200), () {
                            sendDataToApis();
                          });
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _showRectifiedPopup();
                          });
                        });
                      });
                    });
                                    }, enabled: selectedRadioIndex != null),
                ],
              ),
              const SizedBox( height: 120,),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                  onPressed:()=> sendDataToApis(),
                  child: const Text("    Save    ",style: TextStyle(
                      color: Colors.black,
                      fontSize: 15
                  ),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterButton(String label, Color color, int counter, Function onIncrement, Function onDecrement, {required bool enabled}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black),
                onPressed: enabled ? () => onDecrement() : null, // Disable if not enabled
              ),
              Text(
                '$label: $counter',
                style: const TextStyle(color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: enabled ? () => onIncrement() : null, // Disable if not enabled
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton(String label, Color color, int counter, Function onTap, {required bool enabled}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: enabled ? () => onTap() : null, // Disable if not enabled
            child: Text(
              '$label: $counter',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}