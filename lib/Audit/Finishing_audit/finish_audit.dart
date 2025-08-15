import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Installation/dio.dart';
import '../../common/utils/constants/baseurl.dart';

class FinishingAuditPage extends StatefulWidget {
  final Map<String, dynamic> tableData;
  final Map<String, dynamic> textFieldData;
  final Map<String, dynamic> allData;

  const FinishingAuditPage({super.key, required this.tableData, required this.textFieldData, required this.allData});

  @override
  FinishingAuditPageState createState() => FinishingAuditPageState();
}

class FinishingAuditPageState extends State<FinishingAuditPage> {
  late TextEditingController receivedQty,sampleSize,sampleAccept,pcsChecked,remark;
  int pass = 0,reject = 0,detailDocId = 0,docId = 0;
  bool isReject = false,isFinish = false,isFinal = true,isLoading = true,isOutHouse= false;
  late List<Map<String, String>> defectOptions = [],reasonOptions = [],checkerOptions = [];
  List<String> selectedDefects = [],selectedReasons = [],selectedCheckers = [];
  Map<String, List<String>> selectedReasonsWithDefects = {};
  List<Map<String, dynamic>>  defectFinalData = [];
  Map<dynamic,dynamic> defectData = {};
  List<dynamic> dataMap = [];
  String appVersion = '',version = '',fileName = '';
  Timer? _apiTimer,_versionTimer;
  bool showSaveButton = false;
  Timer? _saveButtonTimer;
  int orderQty = 0,issueQty = 0,pcsChkd = 0;

  @override
  void initState() {
    super.initState();
    runFunction();
    buttonTimer();
  }

  void runFunction() async {
    await fetchPermDataAndCheckDate();
    fetchData();
    String? reAuditNo = widget.allData['ReAuditNo']?.toString();
    receivedQty = TextEditingController(text: widget.textFieldData['Received Qty']);
    pcsChecked = TextEditingController();
    sampleSize = TextEditingController(text: '');
    sampleAccept = TextEditingController(text: '');
    remark = TextEditingController(text: '');

    await _fetchQtyOptions(widget.textFieldData['Buyer'], widget.textFieldData['Received Qty']);
    await _fetchDefectOptionsAndReasons();
    Future.delayed(const Duration(milliseconds: 300), () async {
      await startTimer();
      await checkReAuditNo(reAuditNo);
    });
    await _fetchAppVersion();
    _versionTimer = Timer.periodic(const Duration(minutes: 30), (timer)
    async {
      await _fetchAppVersion();
    });
  }

  Future<void> buttonTimer() async{
    print('start');
    sampleAccept.addListener(() {
      if (sampleAccept.text.isEmpty) {
        _startSaveButtonTimer();
      } else {
        _saveButtonTimer?.cancel(); // cancel timer if user starts typing again
        if (showSaveButton) {
          setState(() {
            showSaveButton = false;
          });
        }
      }
    });
  }

  void _startSaveButtonTimer() {
    _saveButtonTimer?.cancel();
    _saveButtonTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        showSaveButton = true;
      });
    });
  }

  Future<void> startTimer() async {
    _apiTimer?.cancel();
    _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      print('Start');
      if (dataMap.isNotEmpty) {
        await sendDataToApis(dataMap,'Main');
      }
    });
  }

  @override
  void dispose() {
    receivedQty.dispose();
    sampleSize.dispose();
    sampleAccept.dispose();
    pcsChecked.dispose();
    _apiTimer?.cancel();
    _versionTimer?.cancel();
    _saveButtonTimer?.cancel();
    super.dispose();
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Update code Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> getVersionNo() async{
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      if (kDebugMode) {
      }
    });
  }

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      if (kDebugMode) {
      }
      getVersion(appVersion);
    });
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http.get(Uri.parse('${TBaseURL.baseUrl}version?version=$version'));
      if (kDebugMode) {
        print('${TBaseURL.baseUrl}version?version=$version');
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          bool isVersionValid = data[0]['IsActive'];
          if (!isVersionValid) {
            await getFile();
            _showUpdateDialog();
          }
        } else {
          if (kDebugMode) {
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to check version with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getFile() async {
    try {
      final response = await http.get(Uri.parse('${TBaseURL.baseUrl}version_file_path'));
      if (kDebugMode) {
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
        }
        fileName = data[0]['VersionFile'] ?? ''; // Set fileName if available
      } else {
        if (kDebugMode) {
          print('Failed to fetch file with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching file: $e');
      }
    }
  }

  void _showUpdateDialog() {
    String apkUrl = 'http://14.96.24.164:10004/assets/media/$fileName';
    if (kDebugMode) {
    }
    if (kDebugMode) {
      print("Apk: $apkUrl");
    }
    Uri appStoreUrl = Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text('Please update the app to the latest version.'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    // If on Android, download the APK
                    downloadApk(context, apkUrl);
                  } else if (Platform.isIOS) {
                    // If on iOS, launch the App Store URL
                    if (await canLaunchUrl(appStoreUrl)) {
                      await launchUrl(appStoreUrl);
                    } else {
                      if (kDebugMode) {
                        print('Could not launch $appStoreUrl');
                      }
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Update Code End-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> getVariable()async {
    int? sampleValue = int.tryParse(sampleAccept.text);
    int? sampleS = int.tryParse(sampleSize.text);
    if((pass + reject) == sampleS){
      setState(() {
        isFinish = true;
      });
    }
    if(reject > sampleValue!){
      setState(() {
        isReject = true;
      });
    }
  }

  Future<void> checkReAuditNo(reAuditNo) async{
    if (reAuditNo != null) {
      isReAuditNoPresent(reAuditNo).then((exists) {
        if (exists) {
          // Do something if present
          if (kDebugMode) {
            print('ReAuditNo $reAuditNo is present in FinishData');
            if (dataMap.isNotEmpty) {
              sendDataToApis(dataMap,'Main');
            }
            // Future.delayed(const Duration(milliseconds: 400),(){
            //   Navigator.pop(context);
            // });
          }
        } else {
          // Do something else if not present
          if (kDebugMode) {
            print('ReAuditNo $reAuditNo is NOT present in FinishData');
          }
        }
      });
    }
  }

  Future<void> _fetchQtysOptions() async {
    String url = '';
    if(widget.allData['Type'] == 'Apps') {
      if(!isOutHouse) {
        url = '${TBaseURL.auditUrl}finishing_audit_new?type=Qty&unit=${widget
            .allData['UnitShCode']}&style=${widget
            .allData['Style']}&color=${widget
            .allData['Color']}&line_Id=${widget
            .allData['LineId']}&lineId=${widget
            .allData['Line']}&orderNo=${widget.allData['Order']}&vendor=';
      }
      else{
        url = '${TBaseURL.auditUrl}finishing_audit_new?type=Qty&unit=${widget
            .allData['UnitShCode']}&style=${widget
            .allData['Style']}&color=${widget
            .allData['Color']}&line_Id=&lineId=${widget
            .allData['VendorId']}&orderNo=${widget.allData['Order']}&vendor=${widget.allData['VendorId']}';
      }
    }
    else if(widget.allData['Type'] == 'VG'){
      if(!isOutHouse) {
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Qty&Unit=${widget
            .allData['Unit']}&style=${widget.allData['Style']}&color=${widget
            .allData['Color']}&line=${widget.allData['Line']}&order=${widget
            .allData['Order']}&Vendor=${widget.allData['Vendor']}&Party=';
      }
      else{
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Qty&Unit=${widget
            .allData['Unit']}&style=${widget.allData['Style']}&color=${widget
            .allData['Color']}&line=&order=${widget
            .allData['Order']}&Vendor=${widget.allData['Vendor']}&Party=${widget.allData['VendorId']}';
      }
    }
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      setState(() {
        orderQty = data[0]['ORDER_QTY'];
        issueQty = data[0]['ISSUE_QTY'];
        pcsChkd = data[0]['PCS_CHKED'];
      });
      print('issue $issueQty');
      print('pcs $pcsChkd');
    } else {
      if (kDebugMode) {
        print('Failed to load Qty');
      }
    }
  }

  void fetchData() async {
    List<dynamic> dataMaps = await fetchDataMap();
    if (dataMaps.isNotEmpty) {
      dataMap = dataMaps; // Don't need setState just for this

      int? docIds = getDocId(
        style: widget.allData['Style'],
        line: widget.allData['LineId'],
        color: widget.allData['Color'],
        order: widget.allData['Order'],
        floor: widget.allData['Floor'],
      );

      if (kDebugMode) {
        print('dataMap $dataMap');
        print("Matching DocId: $docIds");
      }

      if (docIds != null) {
        setState(() {
          docId = docIds;
          isLoading = false;
        });
      } else {
        _fetchDocId(); // Only fetch from API if no matching docId in cache
      }
    }
    else {
      _fetchDocId();
    }
  }

  Future<bool> isReAuditNoPresent(String reAuditNo) async {
    final prefs = await SharedPreferences.getInstance();
    final finishDataString = prefs.getString('FinishData');

    if (finishDataString == null) return false;

    // Decode JSON string to List
    final List<dynamic> finishDataList = jsonDecode(finishDataString);

    // Check if any map in the list has the matching ReAuditNo
    return finishDataList.any((item) =>
    item is Map && item['ReAuditNo'] == reAuditNo
    );
  }

  Future<List<dynamic>> fetchDataMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('FinishData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      return List<dynamic>.from(decodedData);
    } else {
      return [];
    }
  }

  int? getDocId({
    required String style,
    required String line,
    required String color,
    required String order,
    required String floor,
  }) {
    List<int> matchingDocIds = [];
    for (var item in dataMap) {
      if (item["Style"] == style &&
          item["LineId"] == line &&
          item["Color"] == color &&
          item["Order"] == order &&
          item["Floor"] == floor) {
        if (item["docId"] != null) {
          matchingDocIds.add(item["docId"]);
        }
      }
    }
    if (matchingDocIds.isNotEmpty) {
      return matchingDocIds.reduce((curr, next) => curr > next ? curr : next);
    }
    return null;
  }

  Future<void> saveCatchData(List<dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('FinishData', json.encode(data));
    String currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('saved_date', currentDate);
  }

  Future<void> fetchPermDataAndCheckDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedDate = prefs.getString('saved_date');
    String currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate == null || savedDate != currentDate) {
      await prefs.remove('saved_date');
      await prefs.remove('FinishData');
      dataMap.clear();
      if (kDebugMode) {
        print("Data has been cleared because the day has changed.");
      }
    } else {
      if (kDebugMode) {
        print('done');
      }
    }
  }

  Future<List<Map<String, String>>> _fetchDefectOptions() async {
    final data = widget.allData;
    String? lineId;
    setState(() {
      lineId = (data['LineId']).toString();
    });
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}sewing_operation?type=defect&defectType=S'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}sewing_operation?type=defect&defectType=S');
    }
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
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}sewing_operation?type=operation&defectType='));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}sewing_operation?type=operation&defectType=');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'OperationName': item['OperationName'] as String,
          'OperationCode': item['OperationCode'] as String,
        };
      }).toList();
    } else {
      throw Exception('Failed to load reasons options');
    }
  }

  Future<List<Map<String, String>>> _fetchCheckerOptions() async {
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}finish_audit_vg?type=Checker&Unit=${widget.allData['UnitShCode']}'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}finish_audit_vg?type=Checker&Unit=${widget.allData['UnitShCode']}');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'Name': '${item['NAME']}(${item['PAY_CODE']})',
          'PayCode': item['PAY_CODE'] as String,
        };
      }).toList();
    } else {
      throw Exception('Failed to load checker options');
    }
  }


  Future<void> _fetchDefectOptionsAndReasons() async {
    defectOptions = await _fetchDefectOptions();
    reasonOptions = await _fetchReasonsOptions();
    checkerOptions = await _fetchCheckerOptions();
  }

  Future<void> _showReasonPopup() async {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredDefectOptions = List.from(defectOptions);
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WillPopScope(
              onWillPop: () async => false, // Prevent back button dismissal
              child: AlertDialog(
                title: const Text('Select Defect'),
                content: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredDefectOptions = defectOptions
                              .where((defect) => defect['DefectName']!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredDefectOptions.map((reason) {
                            bool isSelected = selectedReasonsWithDefects.containsKey(reason['DefectCode']);
                            return RadioListTile<String>(
                              title: Text(reason['DefectName']!),
                              value: reason['DefectCode']!,
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
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      _showCheckerPopup();
                    },

                    child: const Text('Done'),
                  ),
                ],
              ),

            );
          },///
        );
      },
    );
  }

  Future<void> _showDefectPopup() async {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredDefectOptions = List.from(reasonOptions);

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WillPopScope(
              onWillPop: () async => false, // Prevent back button dismissal
              child: AlertDialog(
                title: const Text('Select Operations'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredDefectOptions = reasonOptions
                              .where((defect) => defect['OperationName']!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredDefectOptions.map((defect) {
                            return CheckboxListTile(
                              title: Text(defect['OperationName']!),
                              value: selectedDefects.contains(defect['OperationCode']),
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selectedDefects.add(defect['OperationCode']!);
                                  } else {
                                    selectedDefects.remove(defect['OperationCode']!);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (selectedDefects.isNotEmpty && selectedReasons.isNotEmpty) {
                        String currentReason = selectedReasons.first;
                        selectedReasonsWithDefects[currentReason] = selectedDefects.toList();
                        Navigator.pop(context);
                        _showReasonPopup(); // Go back to reason popup
                      }
                      else {
                      }
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCheckerPopup() async {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredCheckerOptions = List.from(checkerOptions);
    String? selectedCheckerPayCode;

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WillPopScope(
              onWillPop: () async => false, // Prevent back button dismissal
              child: AlertDialog(
                title: const Text('Select Checker'),
                content: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setDialogState(() {
                          filteredCheckerOptions = checkerOptions
                              .where((checker) => checker['Name']!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredCheckerOptions.map((checker) {
                            return RadioListTile<String>(
                              title: Text(checker['Name']!),
                              value: checker['PayCode']!,
                              groupValue: selectedCheckerPayCode,
                              onChanged: (String? value) {
                                setDialogState(() {
                                  selectedCheckerPayCode = value!;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (selectedCheckerPayCode != null) {
                        setState(() {
                          if (selectedReasonsWithDefects.isNotEmpty) {
                            int newDocId = detailDocId + 1;
                            defectData['defectData $newDocId'] = {
                              'selectedReasonsWithDefects': Map.from(selectedReasonsWithDefects),
                              'defectCounter': newDocId
                            };

                            String date = DateTime.now().toString();

                            selectedReasonsWithDefects.forEach((comp, defects) {
                              defectFinalData.add({
                                'defect': comp,
                                'operation': List.from(defects),
                                'defectCounter': newDocId,
                                'date': date,
                                'defectChecker' : selectedCheckerPayCode,
                                'auditType' : 'F'
                              });
                            });

                            print('Defect Data: $defectFinalData');
                          }

                          if (selectedReasonsWithDefects.isNotEmpty) {
                            detailDocId++;
                            reject++;
                            pcsChecked.text = (pass + reject).toString();

                            Future.delayed(Duration(milliseconds: 400), () {
                              getVariable();
                              selectedReasons.clear();
                              selectedDefects.clear();
                              selectedCheckers.clear();
                              selectedReasonsWithDefects = {};
                            });
                          }
                          Navigator.pop(context);
                        });

                      }
                        else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a checker.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onDataReceived() {
    setState(() {
      print('reauditno');
      print(widget.allData['ReAuditNo']);
      widget.allData['ReAuditNo'] = null;
      widget.allData['ReAuditNo'] = '';
      widget.allData['IsReAudit'] = 0;
      selectedReasons.clear();
      selectedDefects = [];
      selectedReasons = [];
      defectData = {};
      defectData.clear();
      selectedDefects.clear();
      selectedReasonsWithDefects = {};
      defectFinalData.clear();
      defectFinalData = [];
    });
  }

  Future<void> _fetchQtyOptions(String buyer, String qty) async {
    String url = '';
    if(widget.allData['Type'] == 'Apps') {
      url = '${TBaseURL
          .auditUrl}sewing_sample_accept?type=SampleAccept&buyerCode=$buyer&qty=$qty';
    }
    else if(widget.allData['Type'] == 'VG') {
      url = '${TBaseURL
          .auditUrl}finish_audit_vg?type=SampleAccept&buyer=$buyer&qty=$qty&Unit=';
    }
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      setState(() {
        sampleSize.text = data[0]['SampleQty'].toString();
        sampleAccept.text = data[0]['AcceptNum'].toString();
        pcsChecked.text = '0';
      });
      isFinal = true;
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchDocId() async {
    String url = '';
    if(!isOutHouse) {
      url =
      '${TBaseURL.auditUrl}sewing_audit_new?type=Doc&unit=&style=${widget
          .allData['Style']}&color=${widget.allData['Color']}&lineId=${widget
          .allData['LineId']}&line_Id=&orderNo=${widget
          .allData['Order']}&AuditNo=&vendor=&vendorType=${widget.allData['Vendor']}';
    }
    else{
      url =
      '${TBaseURL.auditUrl}sewing_audit_new?type=Doc&unit=&style=${widget
          .allData['Style']}&color=${widget.allData['Color']}&lineId=&line_Id=&orderNo=${widget
          .allData['Order']}&AuditNo=&vendor=${widget
          .allData['VendorId']}&vendorType=${widget.allData['Vendor']}';
    }

    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      setState(() {
        docId = data[0]['DocId'] ?? 0;
        print(docId);
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> sendTransformedData(List<dynamic> data) async {

    String jsonPayload = jsonEncode(data);


    String apiUrl = "${TBaseURL.auditUrl}insert_audit";
    Map<String, dynamic> data1 = {
      "key1": jsonPayload,
    };
    log(jsonPayload);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonPayload,
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData);
        int msgType = responseData['MsgType'] ?? 'Unknown';

        if (kDebugMode) {
          print(' $msgType');
        }

        var auditNo = responseData['auditNo'];
        if (auditNo != null && auditNo['Fail'] != null && (auditNo['Fail'] as List).isNotEmpty) {
          // Show alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Failed Audit'),
                content: Text('Failed audit number: ${auditNo['Fail'].join(", ")}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }

        if(msgType == 1){
          setState(() {
            dataMap.clear();
            dataMap = [];
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('FinishData');
        }
        else if(msgType == 2){
          _fetchAppVersion();
        }
      }
      else {
        if (kDebugMode) {
          print("Error: ${response.statusCode}, ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred:$e");
      }
    }
  }

  Future<void> sendDefectedData(List<dynamic> data) async {

    String jsonPayload = jsonEncode(data);

    String apiUrl = "${TBaseURL.auditUrl}insert_audit_defected";
    print('swhjcfikdec');
    Map<String, dynamic> data1 = {
      "key1": jsonPayload,
    };
    log(jsonPayload);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonPayload,
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print(responseData);
        int msgType = responseData['MsgType'] ?? 'Unknown';

        if (kDebugMode) {
          print(' $msgType');
        }

        if(msgType == 1){
          setState(() {
            dataMap.clear();
            dataMap = [];
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('FinishData');
        }
        else if(msgType == 2){
          _fetchAppVersion();
        }
      }
      else {
        if (kDebugMode) {
          print("Error: ${response.statusCode}, ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred:$e");
      }
    }
  }

  Future<void> sendDataToApis(List<dynamic> data,String type) async {
    int len = data.length;
    if (dataMap.isNotEmpty) {
      if (kDebugMode) {
        print('running');
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if(type == 'Main') {
          sendTransformedData(data);
        }
        else{
          sendDefectedData(data);
        }
      });
      setState(() {
        Future.delayed(Duration(seconds: len), () async {
          if (kDebugMode) {
            print('Removing');
          }
        });
      });
    } else {
      if (kDebugMode) {
        print('Empty');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    int totalPass = 0;
    int totalFail = 0;

    if (dataMap.isNotEmpty) {
      for (var line in dataMap) {
        totalPass += int.tryParse(line['Pass'].toString()) ?? 0;
        totalFail += int.tryParse(line['Fail'].toString()) ?? 0;
      }
    }
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
          'Finishing Audit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          if(dataMap.length > 1)
            IconButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldClear = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Data'),
                  content: const Text('Do you want to clear the data?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              );

              // If OK is pressed, clear SewingData
              if (shouldClear == true) {
                if (dataMap.isNotEmpty) {
                  sendDataToApis(dataMap, 'Defect');
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SewingData has been cleared!'))
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
      body: isLoading ? const Center(child : CircularProgressIndicator()) :Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dataMap.isNotEmpty)
                  Container(
                    height: 30,
                    color: Colors.grey[300],
                    child: Marquee(
                      text: '(Pass: $totalPass/Fail: $totalFail)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      scrollAxis: Axis.horizontal,
                      blankSpace: 100.0,
                      velocity: 70.0,
                      showFadingOnlyWhenScrolling: true,
                      startPadding: 10.0, // Padding at the start
                      accelerationDuration: const Duration(seconds: 1), // Speed up time
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500), // Slow down time
                      decelerationCurve: Curves.easeOut,
                    ),
                  ),
                const SizedBox(height: 10,),

                Table(
                  border: TableBorder.all(color: Colors.black),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  children: [
                    // First row: Keys
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFF5FE3D3),),
                      children: widget.tableData.keys.map((key) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                    TableRow(
                      children: widget.tableData.values.map((value) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          readOnly: isFinal ? true : false,
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            _fetchQtysOptions();

                          },
                          onEditingComplete: (){
                            FocusScope.of(context).unfocus();
                            if(receivedQty.text.isNotEmpty || receivedQty.text != '') {
                              _fetchQtyOptions(widget.textFieldData['Buyer'],
                                  receivedQty.text);
                            }
                            if(issueQty <= pcsChkd){
                              Navigator.of(context).pop();
                            }
                          },
                          // onTapOutside: (event) {
                          //     FocusScope.of(context).unfocus();
                          //     if(receivedQty.text.isNotEmpty || receivedQty.text != '') {
                          //       _fetchQtyOptions(widget.textFieldData['Buyer'],
                          //           receivedQty.text);
                          //     }
                          //   },
                          controller: receivedQty,
                          decoration: const InputDecoration(
                            labelText: 'Received Qty',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          readOnly: true,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          controller: sampleSize,
                          decoration: const InputDecoration(
                            labelText: 'Sample Size',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          readOnly: true,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          controller: sampleAccept,
                          decoration: const InputDecoration(
                            labelText: 'Sample Accept',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          readOnly: true,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          controller: pcsChecked,
                          decoration: const InputDecoration(
                            labelText: 'PCS Checked',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: TextField(
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          controller: remark,
                          decoration: const InputDecoration(
                            labelText: 'Remark',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if(sampleAccept.text != '')
                  if(!isFinish)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                pass++;
                                pcsChecked.text = (pass + reject).toString();
                              });
                              getVariable();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Green for Pass
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button size
                            ),
                            child: Text(
                              'Pass : $pass',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              _showReasonPopup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Red for Reject
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              'Fail : $reject',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                if(isFinish)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isReject)
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              final data = widget.allData;
                              showConfirmationDialog(context,'Pass', () {
                                setState(() {
                                  data.addAll({
                                    'ReceivedQty': receivedQty.text,
                                    'FinalResult': 'Pass',
                                    'Pass' : 1,
                                    'Fail' : 0,
                                    'PassQty' : pass,
                                    'FailQty' : reject,
                                    'Remark': remark.text,
                                    'SampleSize' : sampleSize.text,
                                    'SampleAccept' : sampleAccept.text,
                                    'Time': DateTime.now().toString(),
                                    'defectData': List.from(defectFinalData),
                                    'docId' : docId + 1
                                  });

                                  receivedQty.text = '';
                                  sampleSize.text = '';
                                  sampleAccept.text = '';
                                  pcsChecked.text = '';
                                  detailDocId = 0;
                                  remark.text = '';
                                  isFinal = false;
                                  isFinish = false;
                                  pass = 0;
                                  reject = 0;
                                  docId = docId + 1;
                                });
                                setState(() {
                                  dataMap.add(Map<String, dynamic>.from(data));
                                });
                                log('$dataMap');
                                saveCatchData(dataMap);
                                Future.delayed(const Duration(milliseconds: 300),(){
                                  onDataReceived();
                                  Future.delayed(const Duration(milliseconds: 200),(){
                                    if (dataMap.isNotEmpty) {
                                      sendDataToApis(dataMap,'Main');
                                      startTimer();
                                    }
                                  });
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Final Pass',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            final data = Map<String, dynamic>.from(widget.allData);
                            showConfirmationDialog(context, 'Reject', () {
                              setState(() {
                                data.addAll({
                                  'ReceivedQty': receivedQty.text,
                                  'FinalResult': 'Fail',
                                  'Pass': 0,
                                  'Fail': 1,
                                  'PassQty': pass,
                                  'FailQty': reject,
                                  'Remark': remark.text,
                                  'SampleSize': sampleSize.text,
                                  'SampleAccept': sampleAccept.text,
                                  'Time': DateTime.now().toString(),
                                  'defectData': List.from(defectFinalData),
                                  'docId' : docId + 1
                                });

                                receivedQty.text = '';
                                sampleSize.text = '';
                                sampleAccept.text = '';
                                pcsChecked.text = '';
                                detailDocId = 0;
                                isFinal = false;
                                isFinish = false;
                                isReject = false;
                                remark.text = '';
                                pass = 0;
                                reject = 0;
                                docId = docId + 1;
                              });
                              setState(() {
                                dataMap.add(Map<String, dynamic>.from(data)); // Add a new copy of data
                              });

                              log('$dataMap');
                              saveCatchData(dataMap);
                              Future.delayed(Duration(milliseconds: 300),(){
                                onDataReceived();
                                Future.delayed(const Duration(milliseconds: 200),(){
                                  if (dataMap.isNotEmpty) {
                                    sendDataToApis(dataMap,'Main');
                                    startTimer();
                                  }
                                });
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Final Fail',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if(widget.allData['IsReAudit'] == 1)
                        const SizedBox(width: 10),
                      if(widget.allData['IsReAudit'] == 1 && isReject)
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              final data = Map<String, dynamic>.from(widget.allData); // Clone the map
                              showConfirmationDialog(context, 'Reject', () {
                                setState(() {
                                  data.addAll({
                                    'ReceivedQty': receivedQty.text,
                                    'FinalResult': 'Rejected',
                                    'Pass': 0,
                                    'Fail': 1,
                                    'PassQty': pass,
                                    'FailQty': reject,
                                    'Remark': remark.text,
                                    'SampleSize': sampleSize.text,
                                    'SampleAccept': sampleAccept.text,
                                    'Time': DateTime.now().toString(),
                                    'defectData': List.from(defectFinalData),
                                    'docId' : docId + 1
                                  });

                                  receivedQty.text = '';
                                  sampleSize.text = '';
                                  sampleAccept.text = '';
                                  pcsChecked.text = '';
                                  detailDocId = 0;
                                  isFinal = false;
                                  isFinish = false;
                                  isReject = false;
                                  remark.text = '';
                                  pass = 0;
                                  reject = 0;
                                  docId = docId + 1;
                                });

                                setState(() {
                                  dataMap.add(Map<String, dynamic>.from(data));
                                });
                                log('$dataMap');
                                saveCatchData(dataMap);
                                Future.delayed(const Duration(milliseconds: 300),(){
                                  onDataReceived();
                                  Future.delayed(const Duration(milliseconds: 200),(){
                                    if (dataMap.isNotEmpty) {
                                      sendDataToApis(dataMap,'Main');
                                      startTimer();
                                    }
                                  });
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              'Final Reject',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 90,),
                if(showSaveButton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (dataMap.isNotEmpty) {
                            sendDataToApis(dataMap, 'Main');
                            startTimer();
                          }

                          setState(() {
                            showSaveButton = false;
                          });
                          _startSaveButtonTimer(); // restart the timer after pressing Save
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Save Data',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFF5FE3D3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding : const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)
                      ),
                      child: Text(
                        'Supervisor\n${widget.allData['SupervisorName']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding : const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)
                      ),
                      child: Text(
                        'QA\n${widget.allData['QAName']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  void showConfirmationDialog(BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text("Are you sure you want to Final $title?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                setState(() {
                  isLoading = true; // Start loading
                });

                onConfirm(); // Run the action immediately (not waiting for loading)

                // Keep showing loading for 3 seconds, even if function is done
                await Future.delayed(const Duration(seconds: 4));

                setState(() {
                  isLoading = false; // Stop loading
                });
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

}
