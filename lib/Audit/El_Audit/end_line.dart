import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ExtraFunction/uuid.dart';
import '../../Installation/dio.dart';
import '../../common/utils/constants/baseurl.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> {
  List<Map<String, dynamic>> _tableData = [];
  int passCounter = 0;
  int rejectCounter = 0;
  int defectCounter = 0;
  int rectifiedCounter = 0;
  int docId = 0;
  int detailDocId = 0;
  int selectedRadioIndex = 0;
  bool _areButtonsDisabled = false;
  List<String> selectedDefects = [];
  List<String> selectedReasons = [];
  Map<String, List<String>> selectedReasonsWithDefects = {};
  List<dynamic> dataMap = [];
  List<dynamic> permMap = [];
  List<dynamic> hourlyMap = [];
  Map<String,dynamic> finalD = {};
  Map<String,dynamic> permData = {};
  Map<String,dynamic> hourlyData = {};
  Map<dynamic,dynamic> defectData = {};
  bool _isLoading = false;
  String? line;
  String? unit;
  String? user;
  late int lineId;
  final FocusNode _focusNode = FocusNode();
  bool popUp = false;
  Timer? _apiTimer;
  Timer? _versionTimer;
  bool isSucHdr = false;
  bool isSucDtl = false;
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  late List<Map<String, String>> defectOptions = [];
  late List<Map<String, String>> reasonOptions = [];
  ValueNotifier<bool> isPageDisabledNotifier = ValueNotifier(false);
  String appVersion = '';
  String version = '';
  String fileName = '';
  String currAuditNo = '';
  bool isRectify = false;
  List<Map<String, dynamic>>  defectFinalData = [];
  Set<int> disabledRows = {};
  String uuid = '';

  @override
  initState() {
    super.initState();
    _isLoading = true;
    getUid();
    _deleteSharedPrefOnce();
    Future.delayed(const Duration(milliseconds: 300),() {
      getVersionNo();
      fetchPermDataAndCheckDate();
      Future.delayed(const Duration(milliseconds:300),() async {
        await _loadSelectedRadioIndex();
        _fetchTableData().then((_) {
          if (_tableData.isNotEmpty) {
            _onRadioButtonChanged(selectedRadioIndex);
          }
        });
        fetchData();
        await _fetchDefectOptionsAndReasons();
        _isLoading = false;
        Future.delayed(const Duration(milliseconds: 200), () {
          _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
            setState(() {
              isPageDisabledNotifier.value = true;
            });
            Future.delayed(const Duration(milliseconds: 800),(){
              saveData();
            });
            Future.delayed(const Duration(seconds: 5), () {
              setState(() {
                isPageDisabledNotifier.value = false;
              });
            });
          });
        });
      });
      _versionTimer = Timer.periodic(const Duration(minutes: 30), (timer)
      {
        _fetchAppVersion();
      });
    });
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  Future<void> saveData() async {
    await sendDataToApis();
    Future.delayed(Duration(milliseconds: 800),(){
      _fetchTableData();
    });
  }

  @override
  void dispose() {
    _apiTimer?.cancel();
    _versionTimer?.cancel();
    super.dispose();
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Button Delay*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  void _handleButtonClick(Function action) {
    if (_areButtonsDisabled) return; /// Prevent any button clicks if already disabled

    setState(() {
      _areButtonsDisabled = true; /// Disable all buttons
    });

    // Execute the button action
    action();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _areButtonsDisabled = false;
      });
    });
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Button Delay-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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
      final response = await http.get(Uri.parse('http://14.142.248.34:10008/version?version=$version'));
      print('http://14.142.248.34:10008/version?version=$version');
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
      final response = await http.get(Uri.parse('http://14.142.248.34:10008/version_file_path'));
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
    String apkUrl = 'http://14.142.248.34:10004/assets/media/$fileName';
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

  ///*-*-*-*-*-*-*-*-*-*-*-*-Delete SharedPref-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _deleteSharedPrefOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lineId = prefs.getInt('line_ids')!;
    print(lineId);
    user = prefs.getString('login_id')!;
    unit = prefs.getString('unitCode');
    String? lastRunDate = prefs.getString('lastRunDate');

    String currentDate = DateTime.now().toIso8601String().split('T').first;

    if (lastRunDate != currentDate) {
      await deleteSharedPref();

      await prefs.setString('lastRunDate', currentDate);
    }
  }

  Future<void> deleteSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('PermData');
    await prefs.remove('saved_date');
    await prefs.remove('dataKey');
    await prefs.remove('HourlyData');
    dataMap.clear();
    permMap.clear();
    hourlyMap.clear();
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Delete SharedPref End-*-*-*-*-*-*-*-*-*-*-*-*-*-*


  Future<void> _fetchDefectOptionsAndReasons() async {
    defectOptions = await _fetchDefectOptions();
    reasonOptions = await _fetchReasonsOptions();
  }

  void fetchData() async {
    List<dynamic> dataMaps = await fetchDataMap();
    List<dynamic> permDatas = await fetchPermMap();
    List<dynamic> hourlyDatas = await fetchHourlyMap();
    if(dataMaps.isNotEmpty){
      dataMap = dataMaps;
    }if(permDatas.isNotEmpty){
      permMap = permDatas;
    }if(hourlyDatas.isNotEmpty){
      hourlyMap = hourlyDatas;
    }
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Save SharedPref Start-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> saveCatchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('dataKey', json.encode(dataMap));
    await prefs.setString('PermData', json.encode(permMap));
    await prefs.setString('HourlyData', json.encode(hourlyMap));
    String currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('saved_date', currentDate);
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Save SharedPref End-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  ///*-*-*-*-*-*-*-*-*-*-*-*-Fetch SharedPref Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> fetchPermDataAndCheckDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the saved date from SharedPreferences
    String? savedDate = prefs.getString('saved_date');
    String currentDate = DateTime.now().toIso8601String().split('T')[0];

    // Check if the date has changed
    if (savedDate == null || savedDate != currentDate) {
      await prefs.remove('PermData');
      await prefs.remove('saved_date');
      await prefs.remove('dataKey');
      await prefs.remove('HourlyData');
      dataMap.clear();
      permMap.clear();
      hourlyMap.clear();
      if (kDebugMode) {
        print("PermData has been cleared because the day has changed.");
      }
    } else {
      // If the date is the same, fetch the PermData
      String? permDataJson = prefs.getString('PermData');
      if (permDataJson != null) {
        permMap = List<Map<String, dynamic>>.from(json.decode(permDataJson));
      }
      print('done');
    }
  }

  Future<List<dynamic>> fetchDataMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('dataKey');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      return List<dynamic>.from(decodedData);
    } else {
      return [];
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

  Future<List<dynamic>> fetchHourlyMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hourData = prefs.getString('HourlyData');

    if (hourData != null) {
      List<dynamic> decodedData = jsonDecode(hourData);
      return List<dynamic>.from(decodedData);
    } else {
      return [];
    }
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Fetch SharedPref End-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  ///*-*-*-*-*-*-*-*-*-*-*-*-Table Data Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _fetchTableData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    line = prefs.getString('line_name');
    int? lineId = prefs.getInt('line_ids');
    String? unit = prefs.getString('unit_code');
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}line_data?unit_code=$unit&dated=$todayDate&line_id=$lineId&version=$version'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}line_data?unit_code=$unit&dated=$todayDate&line_id=$lineId&version=$version');
    }
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
        print('table $_tableData');
      });
    } else {
      throw Exception('Failed to load table data');
    }
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Table Data End-*-*-*-*-*-*-*-*-*-*-*-*-*-*


  int _calculateTotal(String field) {
    return _tableData.fold(0, (sum, item) {
      int value = int.tryParse(item[field]?.toString() ?? '0') ?? 0;
      return sum + value;
    });
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Fetch Counter Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  Future<void> _fetchCounter(String order, String style, String color, int lineId) async {
    try {
      if (permMap.isNotEmpty) {

        var matchingEntry = permMap.firstWhere(
              (entry) => entry['style'] == style && entry['order'] == order && entry['color'] == color,
          orElse: () => {},
        );

        if(matchingEntry['style'] == style && matchingEntry['order'] == order && matchingEntry['color'] == color) {
          if (matchingEntry.isNotEmpty) {
            setState(() {
              passCounter = matchingEntry['pass'] ?? 0;
              defectCounter = matchingEntry['defect'] ?? 0;
              rectifiedCounter = matchingEntry['rectified'] ?? 0;
              rejectCounter = matchingEntry['reject'] ?? 0;
              docId = matchingEntry['doc'] ?? 0;
              detailDocId = matchingEntry['detailDoc'] ?? 0;
            });
          } else {
            _resetCounters();
          }
        }
        else {
          _resetCounters();

          final url = Uri.parse('${TBaseURL.auditUrl}el_counter?order=$order&style=$style&color=$color&line_id=$lineId');

          if (kDebugMode) print('Fetching from API: $url');

          final response = await http.get(url);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (kDebugMode) {
              print('object $data');
            }
            if(data.isNotEmpty) {
              setState(() {
                if (kDebugMode) {
                  print(data[0]['PassQty']);
                }
                passCounter = data[0]['PassQty'] ?? 0;
                defectCounter = data[0]['DefectQty'] ?? 0;
                rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
                rejectCounter = data[0]['RejectedQty'] ?? 0;
                docId = data[0]['Doc'] ?? 0;
                detailDocId = data[0]['DetailDoc'] ?? 0;
                if (kDebugMode) {
                  print(docId + detailDocId);
                  print(detailDocId);
                }
              });
            }
            else{
              detailDocId = 0;
              docId = 0;
            }
            if (kDebugMode) {
              print('fhgf');
              print('$detailDocId $docId');
            }

          } else {
            throw Exception('Failed to load counter data. HTTP Status: ${response.statusCode}');
          }
        }
      }
      else {
        _resetCounters();

        final url = Uri.parse('${TBaseURL.auditUrl}el_counter?order=$order&style=$style&color=$color&line_id=$lineId');

        if (kDebugMode) print('Fetching from API: $url');

        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (kDebugMode) {
            print(data);
          }
          if(data != [] || data.isNotEmpty) {
            setState(() {
            passCounter = data[0]['PassQty'] ?? 0;
            defectCounter = data[0]['DefectQty'] ?? 0;
            rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
            rejectCounter = data[0]['RejectedQty'] ?? 0;
            docId = data[0]['Doc'] ?? 0;
            detailDocId = data[0]['DetailDoc'] ?? 0;
            if (kDebugMode) {
              print('$docId + $detailDocId fdgdfg');
            print('$detailDocId deg');
            }
          });
          }
          else{
            passCounter = 0;
            rejectCounter = 0;
            rectifiedCounter = 0;
            defectCounter = 0;
            detailDocId = 0;
            docId = 0;
          }

          if (kDebugMode) {
            print(docId + detailDocId);
          }
        } else {
          throw Exception('Failed to load counter data. HTTP Status: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      if (kDebugMode) print('SocketException: $e');
      _resetCounters();
    } on FormatException catch (e) {
      if (kDebugMode) print('FormatException: $e');
      _resetCounters();
    } catch (e) {
      if (kDebugMode) print('Unexpected Error: $e');
      _resetCounters();
    }
  }

  Future<void> getCounterOnRefresh() async {
    final newRow = _tableData[selectedRadioIndex];
    String order = newRow['OrderNo'];
    String style = newRow['StyleNo'];
    String color = newRow['Color'];

    final url = Uri.parse(
      '${TBaseURL.auditUrl}el_counter?order=$order&style=$style&color=$color&line_id=$lineId',
    );

    if (kDebugMode) print('Fetching from API: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          passCounter = data[0]['PassQty'] ?? 0;
          defectCounter = data[0]['DefectQty'] ?? 0;
          rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
          rejectCounter = data[0]['RejectedQty'] ?? 0;
          docId = data[0]['Doc'] ?? 0;
          detailDocId = data[0]['DetailDoc'] ?? 0;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (kDebugMode) print(permMap);
          saveCatchData();
        });
      }
      else{
        if (kDebugMode) {
          print('fasdsdv $passCounter');
        }
        setState(() {
          passCounter = 0;
          rejectCounter = 0;
          rectifiedCounter = 0;
          defectCounter = 0;
          detailDocId = 0;
          docId = 0;
        });
      }
    } else {
      throw Exception('Failed to load counter data. HTTP Status: ${response.statusCode}');
    }
  }


  void _resetCounters() {
    setState(() {
      passCounter = 0;
      defectCounter = 0;
      rectifiedCounter = 0;
      rejectCounter = 0;
      docId = 0;
      detailDocId = 0;
    });
  }

  void _updateCountersFromApi(dynamic data) {
    if (data != null && data.isNotEmpty) {
      setState(() {
        passCounter = data[0]['PassQty'] ?? 0;
        defectCounter = data[0]['DefectQty'] ?? 0;
        rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
        rejectCounter = data[0]['RejectedQty'] ?? 0;
      });
    } else {
      _resetCounters();
    }
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Fetch Counter End-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  ///*-*-*-*-*-*-*-*-*-*-*-*-Defect/Comp Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<List<Map<String, String>>> _fetchDefectOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lineId = prefs.getInt('line_ids');
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}defect?type=defect&line_id=$lineId'));
    print('${TBaseURL.auditUrl}defect?type=defect&line_id=$lineId');
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
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}defect?type=comp'));
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
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: isPageDisabledNotifier,
          builder: (context, isPageDisabled, child) {
            return WillPopScope(
              onWillPop: () async => false, // Prevent back button dismissal
              child: IgnorePointer(
                ignoring: isPageDisabled,
                child: Opacity(
                  opacity: isPageDisabled ? 0.8 : 1.0, // Adjust opacity when disabled
                  child: AlertDialog(
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
                            onChanged: isPageDisabled
                                ? null
                                : (String? value) {
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
                      if (!isPageDisabled)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              if(
                              selectedReasonsWithDefects.isNotEmpty) {
                                defectData['defectData ${docId + 1}'] = {
                                  'selectedReasonsWithDefects': selectedReasonsWithDefects,
                                  'defectCounter': docId + 1
                                };
                                defectFinalData.clear();
                                String date = DateTime.now().toString();

                                // Transform defectData
                                defectData.forEach((key, value) {
                                  value['selectedReasonsWithDefects'].forEach((
                                      comp, defects) {
                                    defectFinalData.add({
                                      'comp': comp,
                                      'defect': defects,
                                      'defectCounter': value['defectCounter'],
                                      'date': date,
                                    });
                                  });
                                });

                                print('defecttttttt $defectFinalData');
                              }
                            });
                            if (defectData.isNotEmpty &&
                                selectedReasonsWithDefects.isNotEmpty) {
                              docId = docId + 1;

                              hourlyDataToDict(0, 0, 1, 0);
                              finalD['defectData'] = defectData;
                              Future.delayed(const Duration(milliseconds: 200),() async {
                                await performSequentialTasks('1');
                              });
                              onDataReceived();

                            }
                          },
                          child: const Text('Done'),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDefectPopup() async {
    TextEditingController searchController = TextEditingController();
    List<Map<String, String>> filteredDefectOptions = List.from(defectOptions);

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ValueListenableBuilder<bool>(
              valueListenable: isPageDisabledNotifier,
              builder: (context, isPageDisabled, child) {
                return WillPopScope(
                  onWillPop: () async => false, // Prevent back button dismissal
                  child: IgnorePointer(
                    ignoring: isPageDisabled,
                    child: Opacity(
                      opacity: isPageDisabled ? 0.8 : 1.0, // Dim the UI when disabled
                      child: AlertDialog(
                        title: const Text('Select Defect'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                  children: filteredDefectOptions.map((defect) {
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
                            ),
                          ],
                        ),
                        actions: [
                          if (!isPageDisabled)
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
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Defect/Comp End-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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
    int? lineId = prefs.getInt('line_ids');
    sendDataToApis();

    setState(() {
      _resetCounters();
      _saveSelectedRadioIndex();
      disabledRows = {};
      selectedRadioIndex = index;
      final newRow = _tableData[selectedRadioIndex];
      if (newRow['BalanceQty'] <= 0) {
        _areButtonsDisabled = true; // Disable buttons if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAlertDialog(
              "Alert",
              "No Balance for Audit,you can only rectify"
          );
        });
      } else {
        _areButtonsDisabled = false; // Enable buttons for other cases
      }
      Future.delayed(const Duration(milliseconds: 300),() async {
        await _fetchCounter(newRow['OrderNo'], newRow['StyleNo'].toString(), newRow['Color'], lineId!);
        await getCounterOnRefresh();
        if (kDebugMode) {
          print('${TBaseURL.auditUrl}el_counter?order=${newRow['OrderNo']}&style=${newRow['StyleNo']}&color=${newRow['Color']}&line=$lineId');
        }
      });
    });

    setState(() {
      defectData = {};
      finalD = {};
    });

    if (dataMap.isNotEmpty) {
      for (var item in dataMap) {
        if (item['style'] == _tableData[index]['StyleNo'] &&
            item['order'] == _tableData[index]['OrderNo'] &&
            item['color'] == _tableData[index]['Color']) {
          setState(() {
            finalD = item;
            defectData = item['defectData'] ?? {};
          });
          break;
        }
      }
    }
  }


  ///*-*-*-*-*-*-*-*-Data From Variable To Dict Start-*-*-*-*-*-*-*-*-*-*

  Future<void> hourlyDataToDict(int passCounterH, int rejectCounterH,int defectCounterH,int rectifiedCounterH,) async {
    String date = DateTime.now().toString();
    final previousRow = _tableData[selectedRadioIndex];
    hourlyData['docId'] = detailDocId++;
    hourlyData['style'] = previousRow['StyleNo'];
    hourlyData['order'] = previousRow['OrderNo'];
    hourlyData['color'] = previousRow['Color'];
    hourlyData['pass'] = passCounterH;
    hourlyData['reject'] = rejectCounterH;
    hourlyData['defect'] = defectCounterH;
    hourlyData['rectified'] = rectifiedCounterH;
    hourlyData['date'] = date;
  }

  Future<void> saveDataToDict() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // int? lineId = prefs.getInt('line_ids');
    String date = DateTime.now().toIso8601String().split('T')[0];
    String time = DateTime.now().toIso8601String().split('T')[1];
    if (kDebugMode) {
      print(time);
    }

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
      finalD['date'] = date;

      permData['style'] = previousRow['StyleNo'];
      permData['order'] = previousRow['OrderNo'];
      permData['color'] = previousRow['Color'];
      permData['pass'] = passCounter;
      permData['reject'] = rejectCounter;
      permData['defect'] = defectCounter;
      permData['rectified'] = rectifiedCounter;
      permData['date'] = date;
      permData['doc'] = docId;
      permData['detailDoc'] = detailDocId;
    }
  }

  ///*-*-*-*-*-*-*-*-Data From Variable To Dict End-*-*-*-*-*-*-*-*-*-*

  ///*-*-*-*-*-*-*-*-Data From Dict To Map Start-*-*-*-*-*-*-*-*-*-*

  Future<void> mainDataToMap() async {
    bool isExist = false;

    for (var i = 0; i < dataMap.length; i++) {
      if (dataMap[i]['style'] == finalD['style'] &&
          dataMap[i]['order'] == finalD['order'] &&
          dataMap[i]['color'] == finalD['color']) {
        dataMap[i]['pass'] = finalD['pass'];
        dataMap[i]['defect'] = finalD['defect'];
        dataMap[i]['reject'] = finalD['reject'];
        dataMap[i]['rectified'] = finalD['rectified'];
        isExist = true;
        break;
      }
    }

    if (!isExist && finalD.isNotEmpty) {
      setState(() {
        dataMap.add(finalD); // Add new data if it doesn't exist
      });
    }
    log('DataMap: $dataMap');
  }

  Future<void> catchDataToMap() async {
    bool isExistP = false;

    for (var i = 0; i < permMap.length; i++) {
      if (permMap[i]['style'] == permData['style'] &&
          permMap[i]['order'] == permData['order'] &&
          permMap[i]['color'] == permData['color'] &&
          permMap[i]['date'] == permData['date'])  {
        permMap[i]['pass'] = permData['pass'];
        permMap[i]['defect'] = permData['defect'];
        permMap[i]['reject'] = permData['reject'];
        permMap[i]['rectified'] = permData['rectified'];
        permMap[i]['doc'] = permData['doc'];
        permMap[i]['detailDoc'] = permData['detailDoc'];
        isExistP = true;
        break;
      }
    }

    if (!isExistP && permData.isNotEmpty) {
      setState(() {
        permMap.add(permData); // Add a new copy of permData
      });
    }

    // Logging to check results
  }

  List<dynamic> transformData(List<dynamic> data) {
    // Create a map to store the transformed structure
    Map<String, dynamic> result = {};
    String dates = DateTime.now().toIso8601String().split('T')[0];

    for (var entry in data) {
      if(entry['style'] != null && entry['order'] != null  && entry['color'] != null ) {
        // Extract the key details to group by
        String key = '${entry['style']}_${entry['order']}_${entry['color']}_$lineId';

        if (!result.containsKey(key)) {
          result[key] = {
            'style': entry['style'],
            'order': entry['order'],
            'color': entry['color'],
            'line': lineId,
            'defectData': defectFinalData,
            'user': user,
            'version': version,
            'unit': unit,
            'date': dates,
            'passFinal': 0,
            'rejectFinal': 0,
            'defectFinal': 0,
            'rectifyFinal': 0,
            'details': [],
            'device_id' : uuid,
          };
        }

        // Aggregate the final counts
        result[key]['passFinal'] = passCounter;
        result[key]['rejectFinal'] = rejectCounter;
        result[key]['defectFinal'] = defectCounter;
        result[key]['rectifyFinal'] = rectifiedCounter;

        // Add the current entry to the details list
        if (entry['docId'] != null) {
          result[key]['details'].add({
            'docId': entry['docId'],
            'pass': entry['pass'],
            'reject': entry['reject'],
            'defect': entry['defect'],
            'rectify': entry['rectified'],
            'time': entry['date'],
            'qty': 1,
          });
        }
      }
    }
    print('result $result');

    List<dynamic> finalData = result.values.toList();

    return finalData;
  }

  Future<void> sendTransformedData(List<dynamic> data) async {
    // Transform the data
    List<dynamic> transformedData = transformData(data);

    String jsonPayload = jsonEncode(transformedData);


    String apiUrl = "${TBaseURL.auditUrl}insert_endline_new";
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
        int msgType = responseData['MsgType'] ?? 'Unknown';

        if (kDebugMode) {
          print('mbjfbhjsd $msgType');
        }
        isRectify = true;
        if(msgType == 1){
          setState(() {
            hourlyMap.clear();
            hourlyMap = [];
            defectFinalData.clear();
            defectFinalData = [];
            defectData.clear();
            defectData = {};
            dataMap.clear();
            dataMap = [];
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('HourlyData');
          await prefs.remove('dataKey');
          getCounterOnRefresh();
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

  Future<void> hourlyDictToMap() async {

    if (hourlyData.isNotEmpty) {
      setState(() {
        hourlyMap.insert(0, Map.from(hourlyData));
        hourlyData.clear();
        hourlyData = {};
      });
      transformData(hourlyMap);
    }

    // Logging to check results
  }

  ///*-*-*-*-*-*-*-*-Data From Dict To Map End-*-*-*-*-*-*-*-*-*-*

  ///*-*-*-*-*-*-*-*-*-*-*-*-Send Data To DB Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> sendDataToApis() async {
    print('in');

    if (hourlyMap.isNotEmpty) {
      if (kDebugMode) {
        print('running');
      }
      Future.delayed(const Duration(milliseconds: 500),(){
        sendTransformedData(hourlyMap);
      });
    }else {
      if (kDebugMode) {
        print('Empty');
      }
    }
  }


  void _handlePassOrReject({required Map<String, dynamic> defect, required bool isPass,}) async {
    if (kDebugMode) {
      print(defect);
    }
    // String auditNo = defect['AuditNo'];
    String color = defect['Color'];
    String style = defect['StyleNo'];
    int docId = defect['DocId'];
    String order = defect['OrderNo'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('login_id');
    String? unit = prefs.getString('unitCode');
    int? line = prefs.getInt('line_ids');
    String date = DateTime.now().toIso8601String().split('T')[0];

    String action = isPass ? 'Pass' : 'Reject';

    String apiUrl = "${TBaseURL.auditUrl}insert_defect_new";
    Uri uri = Uri.parse(
        "$apiUrl?flag=Rectified&dtlDocId=$docId&audit_no="
            "&rectify_status=$action&user=$userId&auditDate=$date&color=$color&style=$style&order=$order&line=$line&unit=$unit"
    );

    print("$apiUrl?flag=Rectified&dtlDocId=$docId&audit_no="
        "&rectify_status=$action&user=$userId&auditDate=$date&color=$color&style=$style&order=$order&line=$line&unit=$unit");

    try {
      var response = await http.post(uri);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Defect updated successfully.');
        }
        setState(() {
          if (isPass) {
            passCounter++;
            rectifiedCounter++;
            if(defectCounter > 0){
              defectCounter--;
            }else{
              defectCounter = 0;
            }
            Future.delayed(const Duration(milliseconds: 200),(){
              hourlyDataToDict(1,0,-1,1);
            });
          } else {
            rejectCounter++;
            rectifiedCounter++;
            if(defectCounter > 0){
              defectCounter--;
            }else{
              defectCounter = 0;
            }
            Future.delayed(const Duration(milliseconds: 200),(){
              hourlyDataToDict(0,1,-1,1);
            });
          }
        });

        Future.delayed(const Duration(milliseconds: 200),() async {
          await performSequentialTasks('r');
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

  ///*-*-*-*-*-*-*-*-*-*-*-*-Send Data To DB End-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _saveSelectedRadioIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedRadioIndex', selectedRadioIndex);
    if (kDebugMode) {
      print(selectedRadioIndex);
    }
  }

  Future<void> _loadSelectedRadioIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedRadioIndex = prefs.getInt('selectedRadioIndex') ?? 0;
    if (kDebugMode) {
      print(selectedRadioIndex);
    }
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-*-*-Rectify Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  void _showRectifiedPopup() async {
    if (kDebugMode) {
      print(selectedRadioIndex);
    }

    var defectData = await _rectifiedDataTable();

    if (defectData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No defects found!')),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside the dialog
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> reloadData() async {
              var updatedData = await _rectifiedDataTable();
              setState(() {
                defectData = updatedData;
              });
              _saveSelectedRadioIndex();
            }

            Future<void> showLoaderAndReload(bool isPass) async {
              // Show loading dialog with back button disabled
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () async => false, // Prevent back button
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              );

              try {
                await Future.delayed(const Duration(seconds: 4)); // Simulate data reload delay
                await reloadData(); // Ensure data reload happens here
                await Future.delayed(const Duration(seconds: 2)); // Ensure smooth UX
              } finally {
                Navigator.of(context, rootNavigator: true).pop();
              }
            }

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text("Rectified Defects"),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
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
                            final docId = defect['DocId']; // Unique identifier for the row
                            final isDisabled = disabledRows.contains(docId);

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 150),
                                    child: Text(
                                      defect['ComponentIds'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 150),
                                    child: Text(
                                      defect['DefectIds'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: isDisabled
                                        ? [] // Hide buttons if row is disabled
                                        : [
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, color: Colors.green),
                                        onPressed: () async {
                                          bool confirm = await _showConfirmationDialog(
                                            context,
                                            "Do you want to pass this Qty?",
                                          );
                                          if (confirm) {
                                            _handlePassOrReject(defect: defect, isPass: true);
                                            setState(() {
                                              disabledRows.add(docId); // Disable the row
                                            });
                                            await showLoaderAndReload(true);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () async {
                                          bool confirm = await _showConfirmationDialog(
                                            context,
                                            "Do you want to reject this Qty?",
                                          );
                                          if (confirm) {
                                            _handlePassOrReject(defect: defect, isPass: false);
                                            setState(() {
                                              disabledRows.add(docId); // Disable the row
                                            });
                                            await showLoaderAndReload(false);
                                          }
                                        },
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
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      sendDataToApis();
                      Navigator.pop(context); // Only close via this button
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
    bool isButtonPressed = false; // Flag to prevent double-click

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder<bool>(
          valueListenable: isPageDisabledNotifier,
          builder: (context, isPageDisabled, _) {
            return IgnorePointer(
              ignoring: isPageDisabled, // Disable interaction if page is disabled
              child: Opacity(
                opacity: isPageDisabled ? 0.8 : 1.0, // Dim UI when disabled
                child: AlertDialog(
                  title: const Text('Confirmation'),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: isPageDisabled
                          ? null // Disable Cancel button if page is disabled
                          : () {
                        Navigator.pop(context, false); // Cancel action
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isPageDisabled || isButtonPressed
                          ? null // Disable OK button if page is disabled or already pressed
                          : () {
                        isButtonPressed = true; // Set flag to true
                        Navigator.pop(context, true); // Confirm action
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ) ??
        false;
  }


  Future<List<Map<String, dynamic>>> _rectifiedDataTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? unit = prefs.getString('unitCode');
    int? line = prefs.getInt('line_ids');
    final newRow = _tableData[selectedRadioIndex];
    String apiUrl = "${TBaseURL.auditUrl}el_rectify?lineid=$line&order=${newRow['OrderNo']}&style=${newRow['StyleNo'].toString()}&color=${newRow['Color']}&unit=$unit";  // Replace with your actual API URL
    print(apiUrl);

    if (kDebugMode) {
      print(apiUrl);
      print(selectedRadioIndex);
    }
    try {
      Uri uri = Uri.parse(apiUrl);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

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

  ///*-*-*-*-*-*-*-*-*-*-*-*-*-*-Rectify End-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
  @override
  Widget build(BuildContext context) {
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

    return IgnorePointer(
        ignoring: isPageDisabledNotifier.value,
        child: Opacity(
            opacity: isPageDisabledNotifier.value ? 0.5 : 1.0, // Optional: Dim the UI when disabled
            child: Scaffold(
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
                    _saveSelectedRadioIndex();
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text(
                  'End Line Audit',
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
                                    Navigator.of(context).pop(false); // Confirm refresh
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
              body: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(), // Show loading spinner
              )
                  :Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (_isPageDisabled)
                      //   const ModalBarrier(
                      //     color: Colors.black38,
                      //     dismissible: false,
                      //   ),
                      if (dataMap.isNotEmpty)
                        Container(
                          height: 30,
                          color: Colors.grey[300],
                          child: Marquee(
                            text: 'Pass: $totalPass, Reject: $totalReject, Defect: $totalDefect, Rectified: $totalRectified',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            scrollAxis: Axis.horizontal,
                            blankSpace: 200.0,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(),
                          columnWidths: const {
                            0: FixedColumnWidth(50),
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
                              bool isSelected = selectedRadioIndex == index;
                              final newRow = _tableData[selectedRadioIndex];
                              if(newRow['BalanceQty'] <= 0){
                                _areButtonsDisabled = true;
                              }
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.red[100] : Colors.transparent,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child:
                                      Radio<int>(
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
                                    child: SelectableText(item['Color'].toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: SelectableText((item['IssueQty']??0).toString(), textAlign: TextAlign.right),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text((item['AuditQty']??0).toString(), textAlign: TextAlign.right),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text((item['BalanceQty']??0).toString(), textAlign: TextAlign.right),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SelectableText(item['BuyerName'] != null && item['BuyerName']!.length > 15
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
                                  child: SelectableText(''),
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
                      Row(
                        children: [
                          _buildCounterButton('Pass', Colors.green, passCounter, () {
                            _handleButtonClick(() async {
                              setState(() {
                                passCounter++;
                                hourlyDataToDict(1, 0, 0, 0);
                              });
                              Future.delayed(const Duration(milliseconds: 200),() async {
                                await performSequentialTasks('1');
                              });
                            });
                          }, () {
                            _handleButtonClick(() async {
                              bool confirm = await _showRejectDialog(
                                context,
                                "Do you want to remove the piece?",
                              );

                              if (confirm) {
                                setState(() {
                                  passCounter = (passCounter > 0) ? passCounter - 1 : 0;
                                  if (passCounter > 0) {
                                    hourlyDataToDict(-1, 0, 0, 0);
                                  }
                                });
                                Future.delayed(const Duration(milliseconds: 200),() async {
                                  await performSequentialTasks('1');
                                });
                              }
                            });
                          }),
                          _buildCounterButton('Reject', Colors.red, rejectCounter, () {
                            _handleButtonClick(() {
                              setState(() {
                                rejectCounter++;
                                hourlyDataToDict(0,1,0,0);
                              });
                              Future.delayed(const Duration(milliseconds: 200),() async {
                                await performSequentialTasks('1');
                              });
                            });
                          }, () {
                            _handleButtonClick(() async {
                              bool confirm = await _showRejectDialog(
                                context,
                                "Do you want to remove the piece?",
                              );

                              if (confirm) {
                                setState(() {
                                  rejectCounter = (rejectCounter > 0) ? rejectCounter - 1 : 0;
                                  if (rejectCounter > 0) {
                                    hourlyDataToDict(0,-1, 0, 0);
                                  }
                                });
                                Future.delayed(const Duration(milliseconds: 200),() async {
                                  await performSequentialTasks('1');
                                });
                              }
                            });
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                         _buildSimpleButton('Defect', Colors.orange, defectCounter, () {
                        _handleButtonClick(() async {
                            setState(() {
                              _saveSelectedRadioIndex();
                            });
                            _showReasonPopup();
                        });
                          }),
                          _buildSimpleButton('Rectified', Colors.blue, rectifiedCounter, () async {
                              setState(() {
                                _saveSelectedRadioIndex();
                              });
                                await saveDataToDict();
                                await saveCatchData();
                                await sendDataToApis();
                                _checkAndOpenPopup();
                          }),
                        ],
                      ),
                      const SizedBox( height: 80,),
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
            )
        )
    );
  }

  void _checkAndOpenPopup() {
    if(hourlyMap.isNotEmpty || hourlyMap == []) {
      if (isRectify) {
        Future.delayed(const Duration(milliseconds: 200),(){
          _showRectifiedPopup();
        });
      }
      else {
        // Retry after a short delay if the variable is not true yet
        Future.delayed(const Duration(milliseconds: 200), _checkAndOpenPopup);
      }
    }
    else{
      _showRectifiedPopup();
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> performSequentialTasks(String task) async {
    try {
      await hourlyDictToMap();
      await saveDataToDict();
      await mainDataToMap();
      await catchDataToMap();
      await saveCatchData();
      if(task == 'r'){
        await sendDataToApis();
      }
    } catch (e) {
      debugPrint("Error during tasks: $e");
    }
  }

  Future<bool> _showRejectDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Return false on No
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Return true on Yes
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if the dialog is dismissed
  }

  Widget _buildCounterButton(String label, Color color, int counter, Function onIncrement, Function onDecrement) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: _areButtonsDisabled ? Colors.grey : color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black),
                onPressed: () => onDecrement(), // Always enabled
              ),
              Text(
                '$label: $counter',
                style: const TextStyle(color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () => onIncrement(), // Always enabled
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton(String label, Color color, int counter, Function onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () => onTap(), // Always enabled
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