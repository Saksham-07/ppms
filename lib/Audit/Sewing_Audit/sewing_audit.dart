import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Installation/dio.dart';
import '../../common/utils/constants/baseurl.dart';

class SewingAuditPage extends StatefulWidget {
  final Map<String, dynamic> tableData;
  final Map<String, dynamic> textFieldData;
  final Map<String, dynamic> allData;

  const SewingAuditPage(
      {super.key,
      required this.tableData,
      required this.textFieldData,
      required this.allData});

  @override
  SewingAuditPageState createState() => SewingAuditPageState();
}

class SewingAuditPageState extends State<SewingAuditPage>
    with TickerProviderStateMixin {
  late TextEditingController receivedQty,
      sampleSize,
      sampleAccept,
      pcsChecked,
      remark;
  int pass = 0, reject = 0, detailDocId = 0, docId = 0;
  bool isReject = false,
      isFinish = false,
      isFinal = true,
      isOutHouse = false,
      isLoading = true;
  late List<Map<String, String>> defectOptions = [], reasonOptions = [];
  List<String> selectedDefects = [], selectedReasons = [];
  Map<String, List<String>> selectedReasonsWithDefects = {};
  List<Map<String, dynamic>> defectFinalData = [];
  Map<dynamic, dynamic> defectData = {};
  List<dynamic> dataMap = [];
  String appVersion = '', version = '', fileName = '';
  Timer? _apiTimer, _versionTimer;
  bool showSaveButton = false;
  Timer? _saveButtonTimer;
  int orderQty = 0, issueQty = 0, pcsChkd = 0;
  bool _isRVisible = false,
      _showFullTitle = true,
      _isReversing = false,
      _showCursor = true,
      _fromDateFocused = false,
      _toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,
      _backButtonController,
      _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;

  @override
  void initState() {
    super.initState();
    runFunction();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  void runFunction() async {
    await fetchPermDataAndCheckDate();
    fetchData();
    String? reAuditNo = widget.allData['ReAuditNo']?.toString();
    receivedQty =
        TextEditingController(text: widget.textFieldData['Received Qty']);
    pcsChecked = TextEditingController();
    sampleSize = TextEditingController(text: '');
    sampleAccept = TextEditingController(text: '');
    remark = TextEditingController(text: '');
    await _fetchQtyOptions(
        widget.textFieldData['Buyer'], widget.textFieldData['Received Qty']);
    await _fetchDefectOptionsAndReasons();
    await buttonTimer();
    Future.delayed(const Duration(milliseconds: 300), () async {
      await startTimer();
      await checkReAuditNo(reAuditNo);
    });
    await _fetchAppVersion();
    _versionTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      await _fetchAppVersion();
    });
  }

  Future<void> buttonTimer() async {
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
        await sendDataToApis(dataMap, 'Main');
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
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  ///
  void backAnimation() {
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500), // Longer duration for two-part animation
    );
  }

  void buttonAnimation() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleController.reverse();
      }
    });
  }

  //back button animation
  Future<void> _handleBack() async {
    final animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.2), // Move right (backward) 20%
        weight: 40, // 40% of total duration
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: 0.2, end: -1.5), // Then move left (forward) off screen
        weight: 60, // 60% of total duration
      ),
    ]).animate(_backButtonController);

    await _backButtonController.forward(); // Start animation
    if (mounted) Navigator.of(context).pop(); // Pop after animation completes
  }

  //App bar typing animation
  void _setupAnimations() {
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _typingAnimation = IntTween(begin: 0, end: _currentMaxLength).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );

    _typingAnimation.addListener(_updateText);
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  void _updateText() {
    if (!mounted) return;

    const fullText = 'Paramount Product Management System';
    var shortText = 'Sewing Audit';

    final newText = _showFullTitle
        ? fullText.substring(0, _typingAnimation.value)
        : shortText.substring(
            0, _typingAnimation.value.clamp(0, shortText.length));

    if (_displayText != newText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _displayText = newText;
          });
        }
      });
    }
  }

// 2. Update the _toggleCursor method
  void _toggleCursor(Timer timer) {
    if (!mounted) {
      _cursorTimer.cancel();
      return;
    }

    final shouldShowCursor =
        _typingController.value > 0 && _typingController.value < 1.0;

    if (shouldShowCursor != _showCursor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showCursor = shouldShowCursor);
        }
      });
    }
  }

  //App bar typing animation
  Future<void> _startTypingSequence() async {
    try {
      // Type out full title
      _currentMaxLength = 'Paramount Product Management System'.length;
      _typingController.duration = const Duration(milliseconds: 3000);
      await _typingController.forward(from: 0);

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Reverse type full title
      if (mounted) {
        setState(() => _isReversing = true);
      }
      await _typingController.reverse(from: 1.0);

      // Switch to short title
      if (mounted) {
        setState(() {
          _showFullTitle = false;
          _isReversing = false;
          _currentMaxLength = 'Sewing Audit'.length;
        });
      }

      // Adjust duration for shorter text
      _typingController.duration = const Duration(milliseconds: 3000);
      await _typingController.forward(from: 0);
    } catch (e) {
      if (kDebugMode) {
        print('Animation error: $e');
      }
    }
  }

  ///

  ///*-*-*-*-*-*-*-*-*-*-*-*-Update code Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> getVersionNo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      if (kDebugMode) {}
    });
  }

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      if (kDebugMode) {}
      getVersion(appVersion);
    });
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http
          .get(Uri.parse('${TBaseURL.baseUrl}version?version=$version'));
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
          if (kDebugMode) {}
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to check version with status code: ${response.statusCode}');
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
      final response =
          await http.get(Uri.parse('${TBaseURL.baseUrl}version_file_path'));
      if (kDebugMode) {}
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {}
        fileName = data[0]['VersionFile'] ?? ''; // Set fileName if available
      } else {
        if (kDebugMode) {
          print(
              'Failed to fetch file with status code: ${response.statusCode}');
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
    if (kDebugMode) {}
    if (kDebugMode) {
      print("Apk: $apkUrl");
    }
    Uri appStoreUrl =
        Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text('Update Required',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text('Please update the app to the latest version.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
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
                child: Text('Update',style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
              ),
            ],
          ),
        );
      },
    );
  }

  ///*-*-*-*-*-*-*-*-*-*-*-*-Update Code End-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> getVariable() async {
    final sampleValue = int.tryParse(sampleAccept.text);
    final sampleS = int.tryParse(sampleSize.text);

    if (mounted) {
      setState(() {
        isFinish = (pass + reject) == sampleS;
        isReject = sampleValue != null && reject > sampleValue;
      });
    }
  }

  Future<void> checkReAuditNo(reAuditNo) async {
    if (reAuditNo != null) {
      isReAuditNoPresent(reAuditNo).then((exists) {
        if (exists) {
          // Do something if present
          if (kDebugMode) {
            print('ReAuditNo $reAuditNo is present in SewingData');
            if (dataMap.isNotEmpty) {
              sendDataToApis(dataMap, 'Main');
            }
            Future.delayed(const Duration(milliseconds: 400), () {});
          }
        } else {
          // Do something else if not present
          if (kDebugMode) {
            print('ReAuditNo $reAuditNo is NOT present in SewingData');
          }
        }
      });
    }
  }

  Future<void> _fetchQtysOptions() async {
    String url = '';
    if (widget.allData['Type'] == 'Apps') {
      if (!isOutHouse) {
        url =
            '${TBaseURL.auditUrl}sewing_audit_new?type=Qty&unit=${widget.allData['UnitShCode']}&style=${widget.allData['Style']}&color=${widget.allData['Color']}&line_Id=${widget.allData['LineId']}&lineId=${widget.allData['Line']}&orderNo=${widget.allData['Order']}&vendor=';
      } else {
        url =
            '${TBaseURL.auditUrl}sewing_audit_new?type=Qty&unit=${widget.allData['UnitShCode']}&style=${widget.allData['Style']}&color=${widget.allData['Color']}&line_Id=&lineId=${widget.allData['VendorId']}&orderNo=${widget.allData['Order']}&vendor=${widget.allData['VendorId']}';
      }
    } else if (widget.allData['Type'] == 'VG') {
      if (!isOutHouse) {
        url =
            '${TBaseURL.auditUrl}sewing_audit_vg_new?type=Qty&Unit=${widget.allData['Unit']}&style=${widget.allData['Style']}&color=${widget.allData['Color']}&line=${widget.allData['Line']}&order=${widget.allData['Order']}&Vendor=${widget.allData['Vendor']}&Party=';
      } else {
        url =
            '${TBaseURL.auditUrl}sewing_audit_vg_new?type=Qty&Unit=${widget.allData['Unit']}&style=${widget.allData['Style']}&color=${widget.allData['Color']}&line=&order=${widget.allData['Order']}&Vendor=${widget.allData['Vendor']}&Party=${widget.allData['VendorId']}';
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
      if (kDebugMode) {
        print('issue $issueQty');
        print('pcs $pcsChkd');
      }
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
    } else {
      _fetchDocId();
    }
  }

  Future<List<dynamic>> fetchDataMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('SewingData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      return List<dynamic>.from(decodedData);
    } else {
      return [];
    }
  }

  Future<bool> isReAuditNoPresent(String reAuditNo) async {
    final prefs = await SharedPreferences.getInstance();
    final finishDataString = prefs.getString('SewingData');

    if (finishDataString == null) return false;

    // Decode JSON string to List
    final List<dynamic> finishDataList = jsonDecode(finishDataString);

    // Check if any map in the list has the matching ReAuditNo
    return finishDataList
        .any((item) => item is Map && item['ReAuditNo'] == reAuditNo);
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
    return null; // Return null if no match found
  }

  Future<List<Map<String, String>>> _fetchDefectOptions() async {
    final data = widget.allData;
    String? lineId;
    setState(() {
      lineId = (data['LineId']).toString();
    });
    final response = await http.get(Uri.parse(
        '${TBaseURL.auditUrl}sewing_operation?type=defect&defectType=S'));
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
    final response = await http.get(Uri.parse(
        '${TBaseURL.auditUrl}sewing_operation?type=operation&defectType='));
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

  Future<void> saveCatchData(List<dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('SewingData', json.encode(data));
    String currentDate = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('saved_date', currentDate);
  }

  Future<void> fetchPermDataAndCheckDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? savedDate = prefs.getString('saved_date');
    String currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate == null || savedDate != currentDate) {
      await prefs.remove('saved_date');
      await prefs.remove('SewingData');
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

  Future<void> _fetchDefectOptionsAndReasons() async {
    defectOptions = await _fetchDefectOptions();
    reasonOptions = await _fetchReasonsOptions();
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
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                title: Text('Select Defect',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                content: Column(
                  children: [
                    TextField(
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.secondary,),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredDefectOptions.map((reason) {
                            bool isSelected = selectedReasonsWithDefects
                                .containsKey(reason['DefectCode']);
                            return RadioListTile<String>(
                              title: Text(reason['DefectName']!,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                              value: reason['DefectCode']!,
                              groupValue: selectedReasons.isEmpty
                                  ? null
                                  : selectedReasons.first,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedDefects.clear();
                                  selectedReasons = [value!];

                                  if (selectedReasonsWithDefects
                                      .containsKey(value)) {
                                    selectedDefects =
                                        selectedReasonsWithDefects[value]!
                                            .toList();
                                  }
                                  Navigator.pop(context);
                                  _showDefectPopup();
                                });
                              },
                              activeColor: Colors.orange, // Orange when selected
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                    (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.orange; // Selected color
                                  }
                                  return Theme.of(context).colorScheme.secondary; // Unselected color
                                },
                              ),
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
                      setState(() {
                        if (selectedReasonsWithDefects.isNotEmpty) {
                          int newDocId = detailDocId + 1;
                          defectData['defectData $newDocId'] = {
                            'selectedReasonsWithDefects':
                                Map.from(selectedReasonsWithDefects),
                            'defectCounter': newDocId
                          };

                          String date = DateTime.now().toString();

                          selectedReasonsWithDefects.forEach((comp, defects) {
                            defectFinalData.add({
                              'defect': comp,
                              'operation': List.from(defects),
                              'defectCounter': newDocId,
                              'date': date,
                              // 'defectChecker': ''
                              'auditType': 'S'
                            });
                          });

                          if (kDebugMode) {
                            print('Defect Data: $defectFinalData');
                          }
                        }

                        if (selectedReasonsWithDefects.isNotEmpty) {
                          detailDocId++;
                          reject++;
                          pcsChecked.text = (pass + reject).toString();

                          Future.delayed(const Duration(milliseconds: 400), () {
                            getVariable();
                            selectedReasons.clear();
                            selectedDefects.clear();
                            selectedReasonsWithDefects = {};
                          });
                        }
                      });
                    },
                    child: Text('Done',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  ),
                ],
              ),
            );
          },

          ///
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
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                title: Text('Select Operations',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.secondary,),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: filteredDefectOptions.map((defect) {
                              return Theme(
                                  data: Theme.of(context).copyWith(
                                    unselectedWidgetColor: Theme.of(context).colorScheme.secondary,
                                  ),
                              child:  CheckboxListTile(
                                tileColor: Theme.of(context).colorScheme.primary,
                                title: Text(defect['OperationName']!,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                value: selectedDefects
                                    .contains(defect['OperationCode']),
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      selectedDefects
                                          .add(defect['OperationCode']!);
                                    } else {
                                      selectedDefects
                                          .remove(defect['OperationCode']!);
                                    }
                                  });
                                },
                                activeColor: Colors.orange,
                                checkColor: Colors.white,
                                fillColor: WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.orange;
                                    }
                                    return Theme.of(context).colorScheme.secondary;
                                  },
                                ),
                              )
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (selectedDefects.isNotEmpty &&
                          selectedReasons.isNotEmpty) {
                        String currentReason = selectedReasons.first;
                        selectedReasonsWithDefects[currentReason] =
                            selectedDefects.toList();
                        Navigator.pop(context);
                        _showReasonPopup();
                      } else {}
                    },
                    child: Text('Done',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
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
    if (widget.allData['Type'] == 'Apps') {
      url =
          '${TBaseURL.auditUrl}sewing_sample_accept?type=SampleAccept&buyerCode=$buyer&qty=$qty';
    } else if (widget.allData['Type'] == 'VG') {
      url =
          '${TBaseURL.auditUrl}sewing_audit_vg?type=SampleAccept&buyer=$buyer&qty=$qty&Unit=';
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
        if (widget.allData['Vendor'] == 'OH-WORK' ||
            widget.allData['Vendor'] == 'OutHouse' ||
            widget.allData['Vendor'] == 'PR-WORK' ||
            widget.allData['Vendor'] == 'PieceRate') {
          isOutHouse = true;
        } else {
          isOutHouse = false;
        }
        print(isOutHouse);
      });
      isFinal = true;
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

//7348047
  Future<void> _fetchDocId() async {
    String url = '';
    if (!isOutHouse) {
      url =
          '${TBaseURL.auditUrl}sewing_audit_new?type=Doc&unit=&style=${widget.allData['Style']}&color=${widget.allData['Color']}&lineId=${widget.allData['LineId']}&line_Id=&orderNo=${widget.allData['Order']}&AuditNo=&vendor=&vendorType=${widget.allData['Vendor']}';
    } else {
      url =
          '${TBaseURL.auditUrl}sewing_audit_new?type=Doc&unit=&style=${widget.allData['Style']}&color=${widget.allData['Color']}&lineId=&line_Id=&orderNo=${widget.allData['Order']}&AuditNo=&vendor=${widget.allData['VendorId']}&vendorType=${widget.allData['Vendor']}';
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
        if (kDebugMode) {
          print(docId);
        }
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
          print(responseData);
        }
        var auditNo = responseData['auditNo'];
        if (auditNo != null &&
            auditNo['Fail'] != null &&
            (auditNo['Fail'] as List).isNotEmpty) {
          // Show alert dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
                title: Text('Failed Audit',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                content:
                    Text('Failed audit number: ${auditNo['Fail'].join(", ")}',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                  ),
                ],
              );
            },
          );
        }

        if (msgType == 1) {
          setState(() {
            dataMap.clear();
            dataMap = [];
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('SewingData');
        } else if (msgType == 2) {
          _fetchAppVersion();
        }
      } else {
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

        if (msgType == 1) {
          setState(() {
            dataMap.clear();
            dataMap = [];
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('SewingData');
        } else if (msgType == 2) {
          _fetchAppVersion();
        }
      } else {
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

  void showConfirmationDialog(
      BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
          title: Text("Confirmation",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text("Are you sure you want to Final $title?",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
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
              child: Text("Yes",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendDataToApis(List<dynamic> data, String type) async {
    int len = data.length;
    if (dataMap.isNotEmpty) {
      if (kDebugMode) {
        print('running');
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (type == 'Main') {
          sendTransformedData(data);
        } else {
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
    if (isLoading) {
      return const Center(child: LottieLoading(animationPath: 'assets/animation/auditLoading.json',size: 300,));
    }

    final totalPass = dataMap.fold(
        0, (sum, item) => sum + (int.tryParse(item['Pass'].toString()) ?? 0));
    final totalFail = dataMap.fold(
        0, (sum, item) => sum + (int.tryParse(item['Fail'].toString()) ?? 0));

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataTable(totalPass, totalFail),
                  const SizedBox(height: 15),
                  _buildInputFields(),
                  const SizedBox(height: 15),
                  _buildRemarkField(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  if (showSaveButton) _buildSaveButton(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      bottom: const PreferredSize(
                        preferredSize: Size(7, 7),
                        child: Divider(
                          color: Colors.white,
                          indent: 16,
                          endIndent: 16,
                        )),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      leading: AnimatedBuilder(
        animation: _backButtonController,
        builder: (context, child) {
          final value = _backButtonController.value;
          final offset = value < 0.4
              ? Curves.easeOut.transform(value / 0.4) * 0.2
              : 0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;

          return Transform.translate(
            offset: Offset(offset * 30, 0),
            child: Container(
              margin: const EdgeInsets.only(left: 12, top: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.black, size: 20),
                  onPressed: _handleBack,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _displayText,
              key: ValueKey(_showFullTitle),
              style: TextStyle(
                color: Colors.white,
                fontSize: _showFullTitle ? 14 : 18,
                fontWeight: FontWeight.bold,
                letterSpacing: _showFullTitle ? 0.0 : 1.5,
              ),
            ),
          ),
          if (_showCursor &&
              _typingController.value < 1.0 &&
              _typingController.value > 0)
            Container(
              width: 6,
              height: 20,
              margin: const EdgeInsets.only(left: 2),
              color: Colors.grey,
            ),
        ],
      ),
      centerTitle: true,
      elevation: 2,
      actions: [
        if (dataMap.length > 1)
          IconButton(
            onPressed: () async {
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

              if (shouldClear == true && dataMap.isNotEmpty) {
                await sendDataToApis(dataMap, 'Defect');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('SewingData has been cleared!')));
                }
              }
            },
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildDataTable(int totalPass, int totalFail) {
    return Column(
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
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey[600]!),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[400]),
              children: widget.tableData.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    key,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                );
              }).toList(),
            ),
            TableRow(
              children: widget.tableData.values.map((value) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(value.toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: receivedQty,
            label: 'Received Qty',
            readOnly: isFinal,
            onTap: () async {
              FocusScope.of(context).unfocus();
              await _fetchQtysOptions();
              fetchData();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: sampleSize,
            label: 'Sample Size',
            readOnly: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: sampleAccept,
            label: 'Sample Accept',
            readOnly: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: pcsChecked,
            label: 'PCS Checked',
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 30,
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.secondary,
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onEditingComplete: (){
          FocusScope.of(context).unfocus();
          if(receivedQty.text.isNotEmpty || receivedQty.text != '') {
            _fetchQtyOptions(widget.textFieldData['Buyer'],
                receivedQty.text);
          }
          if (issueQty - pcsChkd <= int.parse(receivedQty.text)) {
            Navigator.of(context).pop();
          }
        },
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary),
          floatingLabelStyle: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.secondary),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildRemarkField() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: remark,
            label: 'Remark',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (sampleAccept.text.isEmpty) return const SizedBox();

    if (!isFinish) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    pass++;
                    pcsChecked.text = (pass + reject).toString();
                  });
                  getVariable();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Pass : $pass',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: _showReasonPopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Fail : $reject',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!isReject)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => _handleFinalAction('Pass'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Final Pass',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (isReject) const SizedBox(width: 10),
          if (isReject)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => _handleFinalAction('Fail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Final Fail',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (widget.allData['IsReAudit'] == 1) const SizedBox(width: 10),
          if (widget.allData['IsReAudit'] == 1 && isReject)
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () => _handleFinalAction('Rejected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Final Reject',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      );
    }
  }

  void _handleFinalAction(String result) {
    final data = Map<String, dynamic>.from(widget.allData);
    showConfirmationDialog(context, result, () {
      data.addAll({
        'ReceivedQty': receivedQty.text,
        'FinalResult': result,
        'Pass': result == 'Pass' ? 1 : 0,
        'Fail': result == 'Pass' ? 0 : 1,
        'PassQty': pass,
        'FailQty': reject,
        'Remark': remark.text,
        'SampleSize': sampleSize.text,
        'SampleAccept': sampleAccept.text,
        'Time': DateTime.now().toString(),
        'defectData': List.from(defectFinalData),
        'docId': docId + 1
      });

      if (mounted) {
        setState(() {
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
          dataMap.add(Map<String, dynamic>.from(data));
        });
      }

      saveCatchData(dataMap);
      Future.delayed(const Duration(milliseconds: 200), () {
        onDataReceived();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (dataMap.isNotEmpty) {
            sendDataToApis(dataMap, 'Main');
            startTimer();
          }
        });
      });
    });
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (dataMap.isNotEmpty) {
              sendDataToApis(dataMap, 'Main');
              startTimer();
            }
            if (mounted) {
              setState(() => showSaveButton = false);
            }
            _startSaveButtonTimer();
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
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFooterItem('Supervisor', widget.allData['SupervisorName']),
          _buildFooterItem('QA', widget.allData['QAName']),
          _buildFooterItem('Checker', widget.allData['CheckerName']),
        ],
      ),
    );
  }

  Widget _buildFooterItem(String title, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        child: Text(
          '$title\n${value ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
