import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../ExtraFunction/uuid.dart';
import '../../Installation/dio.dart';
import '../../Theme/app_theme.dart';
import '../../common/utils/constants/baseurl.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key});

  @override
  AuditPageState createState() => AuditPageState();
}

class AuditPageState extends State<AuditPage> with TickerProviderStateMixin {
  // State variables
  final List<Map<String, dynamic>> _tableData = [];
  int passCounter = 0;
  int rejectCounter = 0;
  int defectCounter = 0;
  int rectifiedCounter = 0;
  int docId = 0;
  int detailDocId = 0;
  int selectedRadioIndex = 0;
  bool _areButtonsDisabled = false;
  late List<String> selectedDefects = [];
  late List<String> selectedReasons = [];
  final Map<String, List<String>> selectedReasonsWithDefects = {};
  final List<dynamic> dataMap = [];
  final List<dynamic> permMap = [];
  final List<dynamic> hourlyMap = [];
  final Map<String, dynamic> finalD = {};
  final Map<String, dynamic> permData = {};
  final Map<String, dynamic> hourlyData = {};
  final Map<dynamic, dynamic> defectData = {};
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
  final List<Map<String, String>> dropdownData3 = [];
  final List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  late List<Map<String, String>> defectOptions = [];
  late List<Map<String, String>> reasonOptions = [];
  final ValueNotifier<bool> isPageDisabledNotifier = ValueNotifier(false);
  String appVersion = '';
  String version = '';
  String fileName = '';
  String currAuditNo = '';
  bool isRectify = false;
  final List<Map<String, dynamic>> defectFinalData = [];
  final Set<int> disabledRows = {};
  String uuid = '';
  final Map<String, String> _unitMapVg = {};
  final CancelToken _cancelToken = CancelToken();
  bool _isSaving = false;
  bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
      _fromDateFocused = false,_toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,_backButtonController,_scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;
  bool _isTableDataLoaded = false,_showLine = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _scaleController.dispose();
    _apiTimer?.cancel();
    _versionTimer?.cancel();
    _cancelToken.cancel('Disposed');
    _focusNode.dispose();
    super.dispose();
  }

  void backAnimation(){
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Longer duration for two-part animation
    );
  }

  void buttonAnimation(){
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
        tween: Tween(begin: 0.2, end: -1.5), // Then move left (forward) off screen
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
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  void _updateText() {
    if (!mounted) return;

    const fullText = 'Paramount Product Management System';
    var shortText = 'End Line Audit';

    final newText = _showFullTitle
        ? fullText.substring(0, _typingAnimation.value)
        : shortText.substring(0, _typingAnimation.value.clamp(0, shortText.length));

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

    final shouldShowCursor = _typingController.value > 0 &&
        _typingController.value < 1.0;

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
          _currentMaxLength = 'End Line Audit'.length;
          _showLine = true;
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

  Future<void> _initializeApp() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        getUid(),
        _deleteSharedPrefOnce(),
        getVersionNo(),
        fetchPermDataAndCheckDate(),
        _fetchDropDownOptions(),
      ]);

      await Future.wait([
        fetchData(),
        _fetchDefectOptionsAndReasons(),
        _loadSelectedRadioIndex(),
      ]);

      if (_tableData.isNotEmpty) {
        await _onRadioButtonChanged(selectedRadioIndex);
      }
    } catch (e) {
      debugPrint("Initialization error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _startApiTimer();
    }
  }

  void _startApiTimer() {
    _apiTimer?.cancel();
    _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isSaving) return;
      _isSaving = true;

      try {
        if (mounted) {
          setState(() => isPageDisabledNotifier.value = true);
        }
        await Future.wait([
          saveData(),
          Future.delayed(const Duration(milliseconds: 800)),
        ]);
        await Future.delayed(const Duration(seconds: 5));
      } finally {
        if (mounted) {
          setState(() => isPageDisabledNotifier.value = false);
        }
        _isSaving = false;
      }
    });
  }

  Future<void> getUid() async {
    WidgetsFlutterBinding.ensureInitialized();
    String id = await PersistentUUID.getOrCreateUUID();
    if (mounted) {
      setState(() => uuid = id);
    }
    debugPrint('Persistent UUID: $uuid');
  }

  Future<void> saveData() async {
    await sendDataToApis();
    await Future.delayed(const Duration(milliseconds: 800), () {
      _fetchTableData();
    });
  }

  void _handleButtonClick(Function action) {
    if (_areButtonsDisabled) return;

    if (mounted) {
      setState(() => _areButtonsDisabled = true);
    }

    action();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _areButtonsDisabled = false);
      }
    });
  }

  Future<void> getVersionNo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => version = packageInfo.version);
    }
  }

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => appVersion = packageInfo.version);
    }
    await getVersion(appVersion);
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http.get(
        Uri.parse('${TBaseURL.baseUrl}version?version=$version'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0]['IsActive'] == false) {
          await getFile();
          _showUpdateDialog();
        }
      }
    } catch (e) {
      debugPrint('Error fetching version: $e');
    }
  }

  Future<void> getFile() async {
    try {
      final response = await http.get(
        Uri.parse('${TBaseURL.baseUrl}version_file_path'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() => fileName = data[0]['VersionFile'] ?? '');
        }
      }
    } catch (e) {
      debugPrint('Error fetching file: $e');
    }
  }

  void _showUpdateDialog() {
    final apkUrl = 'http://14.96.24.164:10004/assets/media/$fileName';
    final appStoreUrl =
        Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');

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
                    downloadApk(context, apkUrl);
                  } else if (Platform.isIOS) {
                    if (await canLaunchUrl(appStoreUrl)) {
                      await launchUrl(appStoreUrl);
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

  Future<void> _deleteSharedPrefOnce() async {
    final prefs = await SharedPreferences.getInstance();
    lineId = prefs.getInt('line_ids')!;
    user = prefs.getString('login_id')!;
    unit = prefs.getString('unitCode');
    final lastRunDate = prefs.getString('lastRunDate');
    final currentDate = DateTime.now().toIso8601String().split('T').first;

    if (lastRunDate != currentDate) {
      await deleteSharedPref();
      await prefs.setString('lastRunDate', currentDate);
    }
  }

  Future<void> deleteSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('PermData'),
      prefs.remove('saved_date'),
      prefs.remove('dataKey'),
      prefs.remove('HourlyData'),
    ]);
    dataMap.clear();
    permMap.clear();
    hourlyMap.clear();
  }

  Future<void> _fetchDefectOptionsAndReasons() async {
    defectOptions = await _fetchDefectOptions();
    reasonOptions = await _fetchReasonsOptions();
  }

  Future<void> fetchData() async {
    final dataMaps = await fetchDataMap();
    final permDatas = await fetchPermMap();
    final hourlyDatas = await fetchHourlyMap();

    if (dataMaps.isNotEmpty) dataMap.addAll(dataMaps);
    if (permDatas.isNotEmpty) permMap.addAll(permDatas);
    if (hourlyDatas.isNotEmpty) hourlyMap.addAll(hourlyDatas);
  }

  Future<void> saveCatchData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('dataKey', json.encode(dataMap)),
      prefs.setString('PermData', json.encode(permMap)),
      prefs.setString('HourlyData', json.encode(hourlyMap)),
      prefs.setString(
          'saved_date', DateTime.now().toIso8601String().split('T')[0]),
    ]);
  }

  Future<void> fetchPermDataAndCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('saved_date');
    final currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate == null || savedDate != currentDate) {
      await deleteSharedPref();
    } else {
      final permDataJson = prefs.getString('PermData');
      if (permDataJson != null) {
        permMap
            .addAll(List<Map<String, dynamic>>.from(json.decode(permDataJson)));
      }
    }
  }

  Future<List<dynamic>> fetchDataMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('dataKey');
    return jsonData != null ? List<dynamic>.from(jsonDecode(jsonData)) : [];
  }

  Future<List<dynamic>> fetchPermMap() async {
    final prefs = await SharedPreferences.getInstance();
    final permTData = prefs.getString('PermData');
    return permTData != null ? List<dynamic>.from(jsonDecode(permTData)) : [];
  }

  Future<List<dynamic>> fetchHourlyMap() async {
    final prefs = await SharedPreferences.getInstance();
    final hourData = prefs.getString('HourlyData');
    return hourData != null ? List<dynamic>.from(jsonDecode(hourData)) : [];
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final loginId = prefs.getString('login_id');
    final url = '${TBaseURL.baseUrl}unit_vg?type=lookUpUnit&user=$loginId';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _unitMapVg.addAll({
              for (var item in data)
                item['UnitCode1'].toString(): item['UnitCode'].toString()
            });
          });
          await _fetchTableData();
        }
      }
    } catch (e) {
      debugPrint('Error fetching dropdown options: $e');
    }
  }


  Future<void> _fetchTableData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isTableDataLoaded = false;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      line = prefs.getString('line_name');
      lineId = prefs.getInt('line_ids')!;
      unit = prefs.getString('unit_code');
      final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final vgUnit = _unitMapVg[unit];

      // Make both API calls
      final response1 = await http.get(
        Uri.parse('${TBaseURL.auditUrl}line_data?unit_code=$unit&dated=$todayDate&line_id=$lineId&version=$version'),
      );

      final response2 = await http.get(
        Uri.parse('${TBaseURL.auditUrl}endline_vg_data?unit_code=$vgUnit&line_id=$lineId'),
      );

      print('${TBaseURL.auditUrl}endline_vg_data?unit_code=$vgUnit&line_id=$lineId');

      // Process responses only after both complete
      if (response1.statusCode == 200 && response2.statusCode == 200) {
        final data1 = jsonDecode(response1.body);
        final data2 = jsonDecode(response2.body);
        print('data $data2');

        if (mounted) {
          setState(() {
            _tableData.clear();
            _tableData.addAll([...List<Map<String, dynamic>>.from(data1)]);
            _tableData.addAll([...List<Map<String, dynamic>>.from(data2)]);
            _isTableDataLoaded = true;
            _isLoading = false;
            log(_tableData.toString());
          });
        }
      } else {
        throw Exception('One or both API calls failed');
      }
    } catch (e) {
      if (mounted && !_cancelToken.isCancelled) {
        setState(() {
          _isLoading = false;
          _isTableDataLoaded = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
    }
  }

  int _calculateTotal(String field) {
    return _tableData.fold(0, (sum, item) {
      final value = int.tryParse(item[field]?.toString() ?? '0') ?? 0;
      return sum + value;
    });
  }

  Future<void> _fetchCounter(
      String order, String style, String color, int lineId) async {
    try {
      if (permMap.isNotEmpty) {
        final matchingEntry = permMap.firstWhere(
          (entry) =>
              entry['style'] == style &&
              entry['order'] == order &&
              entry['color'] == color,
          orElse: () => {},
        );

        if (matchingEntry.isNotEmpty &&
            matchingEntry['style'] == style &&
            matchingEntry['order'] == order &&
            matchingEntry['color'] == color) {
          if (mounted) {
            setState(() {
              passCounter = matchingEntry['pass'] ?? 0;
              defectCounter = matchingEntry['defect'] ?? 0;
              rectifiedCounter = matchingEntry['rectified'] ?? 0;
              rejectCounter = matchingEntry['reject'] ?? 0;
              docId = matchingEntry['doc'] ?? 0;
              detailDocId = matchingEntry['detailDoc'] ?? 0;
            });
          }
          return;
        }
      }

      final url = Uri.parse(
          '${TBaseURL.auditUrl}el_counter?order=$order&style=$style&color=$color&line_id=$lineId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            passCounter = data[0]['PassQty'] ?? 0;
            defectCounter = data[0]['DefectQty'] ?? 0;
            rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
            rejectCounter = data[0]['RejectedQty'] ?? 0;
            docId = data[0]['Doc'] ?? 0;
            detailDocId = data[0]['DetailDoc'] ?? 0;
          });
        } else if (mounted) {
          _resetCounters();
        }
      }
    } catch (e) {
      if (!_cancelToken.isCancelled && mounted) {
        _resetCounters();
      }
    }
  }

  Future<void> getCounterOnRefresh() async {
    final newRow = _tableData[selectedRadioIndex];
    final order = newRow['OrderNo'];
    final style = newRow['StyleNo'];
    final color = newRow['Color'];
    final url = Uri.parse(
        '${TBaseURL.auditUrl}el_counter?order=$order&style=$style&color=$color&line_id=$lineId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty && mounted) {
          setState(() {
            passCounter = data[0]['PassQty'] ?? 0;
            defectCounter = data[0]['DefectQty'] ?? 0;
            rectifiedCounter = data[0]['RectifiedQty'] ?? 0;
            rejectCounter = data[0]['RejectedQty'] ?? 0;
            docId = data[0]['Doc'] ?? 0;
            detailDocId = data[0]['DetailDoc'] ?? 0;
          });
          await saveCatchData();
        } else if (mounted) {
          _resetCounters();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing counter: $e');
    }
  }

  void _resetCounters() {
    if (mounted) {
      setState(() {
        passCounter = 0;
        defectCounter = 0;
        rectifiedCounter = 0;
        rejectCounter = 0;
        docId = 0;
        detailDocId = 0;
      });
    }
  }

  Future<List<Map<String, String>>> _fetchDefectOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final lineId = prefs.getInt('line_ids');
    final response = await http.get(
        Uri.parse('${TBaseURL.auditUrl}defect?type=defect&line_id=$lineId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'DefectName': item['DefectName'] as String,
          'DefectCode': item['DefectCode'] as String,
        };
      }).toList();
    }
    throw Exception('Failed to load defect options');
  }

  Future<List<Map<String, String>>> _fetchReasonsOptions() async {
    final response =
        await http.get(Uri.parse('${TBaseURL.auditUrl}defect?type=comp'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'CompName': item['CompName'] as String,
          'CompCode': item['CompCode'] as String,
        };
      }).toList();
    }
    throw Exception('Failed to load reasons options');
  }

  Future<void> _showReasonPopup() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ValueListenableBuilder<bool>(
          valueListenable: isPageDisabledNotifier,
          builder: (context, isPageDisabled, child) {
            return WillPopScope(
              onWillPop: () async => false,
              child: IgnorePointer(
                ignoring: isPageDisabled,
                child: Opacity(
                  opacity: isPageDisabled ? 0.8 : 1.0,
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    title: Text(
                      'Select Component',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: reasonOptions.map((reason) {
                          final isSelected = selectedReasonsWithDefects
                              .containsKey(reason['CompCode']);
                          return Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Theme.of(context).colorScheme.secondary, // White border when not selected
                            ),
                            child: RadioListTile<String>(
                              title: Text(
                                reason['CompName']!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              value: reason['CompCode']!,
                              groupValue: selectedReasons.isEmpty
                                  ? null
                                  : selectedReasons.first,
                              onChanged: isPageDisabled
                                  ? null
                                  : (value) {
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
                            ),
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
                              if (selectedReasonsWithDefects.isNotEmpty) {
                                defectData['defectData ${docId + 1}'] = {
                                  'selectedReasonsWithDefects':
                                  selectedReasonsWithDefects,
                                  'defectCounter': docId + 1
                                };
                                defectFinalData.clear();
                                final date = DateTime.now().toString();

                                defectData.forEach((key, value) {
                                  value['selectedReasonsWithDefects']
                                      .forEach((comp, defects) {
                                    defectFinalData.add({
                                      'comp': comp,
                                      'defect': defects,
                                      'defectCounter': value['defectCounter'],
                                      'date': date,
                                    });
                                  });
                                });

                                if (defectData.isNotEmpty &&
                                    selectedReasonsWithDefects.isNotEmpty) {
                                  docId = docId + 1;
                                  hourlyDataToDict(0, 0, 1, 0);
                                  finalD['defectData'] = defectData;
                                  performSequentialTasks('1');
                                  onDataReceived();
                                }
                              }
                            });
                          },
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
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
    final searchController = TextEditingController();
    List<Map<String, String>> filteredDefectOptions = List.from(defectOptions);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ValueListenableBuilder<bool>(
              valueListenable: isPageDisabledNotifier,
              builder: (context, isPageDisabled, child) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: IgnorePointer(
                    ignoring: isPageDisabled,
                    child: Opacity(
                      opacity: isPageDisabled ? 0.8 : 1.0,
                      child: AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        title: Text(
                          'Select Defect',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              controller: searchController,
                              cursorColor: Theme.of(context).colorScheme.secondary,
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
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: filteredDefectOptions.map((defect) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        unselectedWidgetColor: Theme.of(context).colorScheme.secondary,
                                      ),
                                      child: CheckboxListTile(
                                        tileColor: Theme.of(context).colorScheme.primary,
                                        title: Text(
                                          defect['DefectName']!,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                        value: selectedDefects
                                            .contains(defect['DefectCode']),
                                        onChanged: (bool? value) {
                                          setDialogState(() {
                                            if (value == true) {
                                              selectedDefects
                                                  .add(defect['DefectCode']!);
                                            } else {
                                              selectedDefects
                                                  .remove(defect['DefectCode']!);
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
                                      ),
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
                                if (selectedDefects.isNotEmpty &&
                                    selectedReasons.isNotEmpty) {
                                  final currentReason = selectedReasons.first;
                                  selectedReasonsWithDefects[currentReason] =
                                      selectedDefects.toList();
                                  Navigator.pop(context);
                                  _showReasonPopup();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Done',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
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

  void onDataReceived() {
    if (mounted) {
      setState(() {
        selectedReasons.clear();
        selectedDefects.clear();
        if (selectedReasonsWithDefects.isNotEmpty) {
          defectCounter++;
        }
        selectedReasonsWithDefects.clear();
      });
    }
  }

  Future<void> _onRadioButtonChanged(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final lineId = prefs.getInt('line_ids')!;
    await sendDataToApis();

    if (mounted) {
      setState(() {
        _resetCounters();
        _saveSelectedRadioIndex();
        disabledRows.clear();
        selectedRadioIndex = index;
        final newRow = _tableData[selectedRadioIndex];
        _areButtonsDisabled = newRow['BalanceQty'] <= 0;

        if (_areButtonsDisabled) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAlertDialog(
                "Alert", "No Balance for Audit,you can only rectify");
          });
        }
      });
    }

    final newRow = _tableData[selectedRadioIndex];
    await Future.wait([
      _fetchCounter(newRow['OrderNo'], newRow['StyleNo'].toString(),
          newRow['Color'], lineId),
      getCounterOnRefresh(),
    ]);

    if (mounted) {
      setState(() {
        defectData.clear();
        finalD.clear();
      });
    }

    if (dataMap.isNotEmpty) {
      for (final item in dataMap) {
        if (item['style'] == _tableData[index]['StyleNo'] &&
            item['order'] == _tableData[index]['OrderNo'] &&
            item['color'] == _tableData[index]['Color']) {
          if (mounted) {
            setState(() {
              finalD.addAll(item);
              defectData.addAll(item['defectData'] ?? {});
            });
          }
          break;
        }
      }
    }
  }

  Future<void> hourlyDataToDict(int passCounterH, int rejectCounterH,
      int defectCounterH, int rectifiedCounterH) async {
    final date = DateTime.now().toString();
    final previousRow = _tableData[selectedRadioIndex];

    hourlyData.clear();
    hourlyData.addAll({
      'docId': detailDocId++,
      'style': previousRow['StyleNo'],
      'order': previousRow['OrderNo'],
      'color': previousRow['Color'],
      'component': previousRow['Component'],
      'type': previousRow['DataType'],
      'pass': passCounterH,
      'reject': rejectCounterH,
      'defect': defectCounterH,
      'rectified': rectifiedCounterH,
      'date': date,
    });
  }

  Future<void> saveDataToDict() async {
    final date = DateTime.now().toIso8601String().split('T')[0];
    final time = DateTime.now().toIso8601String().split('T')[1];

    if (selectedRadioIndex != -1) {
      final previousRow = _tableData[selectedRadioIndex];

      finalD.clear();
      finalD.addAll({
        'style': previousRow['StyleNo'],
        'order': previousRow['OrderNo'],
        'color': previousRow['Color'],
        'pass': passCounter,
        'reject': rejectCounter,
        'defect': defectCounter,
        'rectified': rectifiedCounter,
        'date': date,
      });

      permData.clear();
      permData.addAll({
        'style': previousRow['StyleNo'],
        'order': previousRow['OrderNo'],
        'color': previousRow['Color'],
        'pass': passCounter,
        'reject': rejectCounter,
        'defect': defectCounter,
        'rectified': rectifiedCounter,
        'date': date,
        'doc': docId,
        'detailDoc': detailDocId,
      });
    }
  }

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
      dataMap.add(Map.from(finalD));
    }
    debugPrint('DataMap: $dataMap');
  }

  Future<void> catchDataToMap() async {
    bool isExistP = false;

    for (var i = 0; i < permMap.length; i++) {
      if (permMap[i]['style'] == permData['style'] &&
          permMap[i]['order'] == permData['order'] &&
          permMap[i]['color'] == permData['color'] &&
          permMap[i]['date'] == permData['date']) {
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
      permMap.add(Map.from(permData));
    }
  }

  List<dynamic> transformData(List<dynamic> data) {
    final result = <String, dynamic>{};
    final dates = DateTime.now().toIso8601String().split('T')[0];

    for (final entry in data) {
      if (entry['style'] != null &&
          entry['order'] != null &&
          entry['color'] != null) {
        final key =
            '${entry['style']}_${entry['order']}_${entry['color']}_$lineId';
        final vgUnit = _unitMapVg[unit];

        if (!result.containsKey(key)) {
          result[key] = {
            'style': entry['style'],
            'order': entry['order'],
            'color': entry['color'],
            'component': entry['component'],
            'line': lineId,
            'defectData': defectFinalData,
            'user': user,
            'version': version,
            'unit': entry['type'] == 'APPS' ? unit : vgUnit,
            'date': dates,
            'passFinal': 0,
            'rejectFinal': 0,
            'defectFinal': 0,
            'rectifyFinal': 0,
            'details': [],
            'device_id': uuid,
          };
        }

        result[key]['passFinal'] = passCounter;
        result[key]['rejectFinal'] = rejectCounter;
        result[key]['defectFinal'] = defectCounter;
        result[key]['rectifyFinal'] = rectifiedCounter;

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

    return result.values.toList();
  }

  Future<void> sendTransformedData(List<dynamic> data) async {
    final transformedData = transformData(data);
    final jsonPayload = jsonEncode(transformedData);
    final apiUrl = "${TBaseURL.auditUrl}insert_endline_new";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final msgType = responseData['MsgType'] ?? 0;

        isRectify = true;
        if (msgType == 1 && mounted) {
          setState(() {
            hourlyMap.clear();
            defectFinalData.clear();
            defectData.clear();
            dataMap.clear();
          });
          final prefs = await SharedPreferences.getInstance();
          await Future.wait([
            prefs.remove('HourlyData'),
            prefs.remove('dataKey'),
          ]);
          await getCounterOnRefresh();
        } else if (msgType == 2) {
          _fetchAppVersion();
        }
      }
    } catch (e) {
      debugPrint("Error sending transformed data: $e");
    }
  }

  Future<void> hourlyDictToMap() async {
    if (hourlyData.isNotEmpty) {
      hourlyMap.insert(0, Map.from(hourlyData));
      hourlyData.clear();
    }
    transformData(hourlyMap);
  }

  Future<void> sendDataToApis() async {
    if (hourlyMap.isNotEmpty) {
      await sendTransformedData(hourlyMap);
    }
  }

  Future<void> _handlePassOrReject(
      {required Map<String, dynamic> defect, required bool isPass}) async {
    final color = defect['Color'];
    final style = defect['StyleNo'];
    final docId = defect['DocId'];
    final order = defect['OrderNo'];
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('login_id');
    final unit = prefs.getString('unitCode');
    final vgUnit = _unitMapVg[unit];
    final line = prefs.getInt('line_ids');
    final date = DateTime.now().toIso8601String().split('T')[0];
    final row = _tableData[selectedRadioIndex];
    final action = isPass ? 'Pass' : 'Reject';

    String apiUrl = "${TBaseURL.auditUrl}insert_defect_new";
    Uri uri;

    if (row['DataType'] != 'VG') {
      uri = Uri.parse("$apiUrl?flag=Rectified&dtlDocId=$docId&audit_no="
          "&rectify_status=$action&user=$userId&auditDate=$date&color=$color&style=$style&order=$order&line=$line&unit=$unit");
    } else {
      uri = Uri.parse("$apiUrl?flag=Rectified&dtlDocId=$docId&audit_no="
          "&rectify_status=$action&user=$userId&auditDate=$date&color=$color&style=$style&order=$order&line=$line&unit=$vgUnit");
    }

    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            if (isPass) {
              passCounter++;
              rectifiedCounter++;
              defectCounter = defectCounter > 0 ? defectCounter - 1 : 0;
              hourlyDataToDict(1, 0, -1, 1);
            } else {
              rejectCounter++;
              rectifiedCounter++;
              defectCounter = defectCounter > 0 ? defectCounter - 1 : 0;
              hourlyDataToDict(0, 1, -1, 1);
            }
          });
        }
        await performSequentialTasks('r');
      }
    } catch (error) {
      debugPrint('Error updating defect: $error');
    }
  }

  Future<void> _saveSelectedRadioIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedRadioIndex', selectedRadioIndex);
  }

  Future<void> _loadSelectedRadioIndex() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
          () => selectedRadioIndex = prefs.getInt('selectedRadioIndex') ?? 0);
    }
  }

  Future<void> _showRectifiedPopup() async {
    var defectData = await _rectifiedDataTable();
    if (defectData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No defects found!')),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> reloadData() async {
              final updatedData = await _rectifiedDataTable();
              setState(() => defectData = updatedData);
              _saveSelectedRadioIndex();
            }

            Future<void> showLoaderAndReload(bool isPass) async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );

              try {
                await Future.wait([
                  Future.delayed(const Duration(seconds: 4)),
                  reloadData(),
                  Future.delayed(const Duration(seconds: 2)),
                ]);
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
                            decoration:
                                BoxDecoration(color: Colors.lightBlue[200]),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Component',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Defect',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Action',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...defectData.map((defect) {
                            final docId = defect['DocId'];
                            final isDisabled = disabledRows.contains(docId);

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    child: Text(
                                      defect['ComponentIds'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
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
                                        ? []
                                        : [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green),
                                              onPressed: () async {
                                                final confirm =
                                                    await _showConfirmationDialog(
                                                  context,
                                                  "Do you want to pass this Qty?",
                                                );
                                                if (confirm) {
                                                  _handlePassOrReject(
                                                      defect: defect,
                                                      isPass: true);
                                                  setState(() =>
                                                      disabledRows.add(docId));
                                                  await showLoaderAndReload(
                                                      true);
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors.red),
                                              onPressed: () async {
                                                final confirm =
                                                    await _showConfirmationDialog(
                                                  context,
                                                  "Do you want to reject this Qty?",
                                                );
                                                if (confirm) {
                                                  _handlePassOrReject(
                                                      defect: defect,
                                                      isPass: false);
                                                  setState(() =>
                                                      disabledRows.add(docId));
                                                  await showLoaderAndReload(
                                                      false);
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
                      Navigator.pop(context);
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

  Future<bool> _showConfirmationDialog(
      BuildContext context, String message) async {
    bool isButtonPressed = false;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ValueListenableBuilder<bool>(
              valueListenable: isPageDisabledNotifier,
              builder: (context, isPageDisabled, _) {
                return IgnorePointer(
                  ignoring: isPageDisabled,
                  child: Opacity(
                    opacity: isPageDisabled ? 0.8 : 1.0,
                    child: AlertDialog(
                      title: const Text('Confirmation'),
                      content: Text(message),
                      actions: [
                        TextButton(
                          onPressed: isPageDisabled
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: isPageDisabled || isButtonPressed
                              ? null
                              : () {
                                  isButtonPressed = true;
                                  Navigator.pop(context, true);
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
    final prefs = await SharedPreferences.getInstance();
    final unit = prefs.getString('unitCode');
    final vgUnit = _unitMapVg[unit];
    final line = prefs.getInt('line_ids');
    final newRow = _tableData[selectedRadioIndex];

    final apiUrl = newRow['DataType'] != 'Apps'
        ? "${TBaseURL.auditUrl}el_rectify?lineid=$line&order=${newRow['OrderNo']}&style=${newRow['StyleNo']}&color=${newRow['Color']}&unit=$unit"
        : "${TBaseURL.auditUrl}el_rectify?lineid=$line&order=${newRow['OrderNo']}&style=${newRow['StyleNo']}&color=${newRow['Color']}&unit=$vgUnit";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      throw Exception('Failed to load defects');
    } catch (error) {
      debugPrint('Error fetching defects: $error');
      return [];
    }
  }

  Future<void> performSequentialTasks(String task) async {
    try {
      await Future.wait([
        hourlyDictToMap(),
        saveDataToDict(),
        mainDataToMap(),
        catchDataToMap(),
        saveCatchData(),
        if (task == 'r') sendDataToApis(),
      ]);
    } catch (e) {
      debugPrint("Error during tasks: $e");
    }
  }

  void _checkAndOpenPopup() {
    if (hourlyMap.isNotEmpty || hourlyMap.isEmpty) {
      if (isRectify) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _showRectifiedPopup();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200), _checkAndOpenPopup);
      }
    } else {
      _showRectifiedPopup();
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(title,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text(message,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: [
            TextButton(
              child: Text("OK",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showRejectDialog(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text('Confirmation',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              content: Text(message,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _confirmRefresh() async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Refresh'),
          content: const Text('Are you sure you want to refresh the page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldRefresh == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuditPage()),
      );
    }
  }

  Map<String, int> _calculateTotals() {
    int totalPass = 0;
    int totalReject = 0;
    int totalDefect = 0;
    int totalRectified = 0;

    if (dataMap.isNotEmpty) {
      for (final line in dataMap) {
        totalPass += int.tryParse(line['pass'].toString()) ?? 0;
        totalReject += int.tryParse(line['reject'].toString()) ?? 0;
        totalDefect += int.tryParse(line['defect'].toString()) ?? 0;
        totalRectified += int.tryParse(line['rectified'].toString()) ?? 0;
      }
    }

    return {
      'pass': totalPass,
      'reject': totalReject,
      'defect': totalDefect,
      'rectified': totalRectified,
    };
  }

  Widget _buildCounterButton(String label, Color color, int counter,
      Function onIncrement, Function onDecrement) {
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
                onPressed: () => onDecrement(),
              ),
              Text(
                '$label: $counter',
                style: const TextStyle(color: Colors.black),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () => onIncrement(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleButton(
      String label, Color color, int counter, Function onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () => onTap(),
            child: Text(
              '$label: $counter',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(Map<String, int> totals) {
    final totalIssueQty = _calculateTotal('IssueQty');
    final totalAuditQty = _calculateTotal('AuditQty');
    final totalBalQty = _calculateTotal('BalanceQty');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey[500]!),
        columnWidths: const {
          0: FixedColumnWidth(50),
          1: FixedColumnWidth(100),
          2: IntrinsicColumnWidth(),
          3: FixedColumnWidth(130),
          4: FixedColumnWidth(60),
          5: FixedColumnWidth(60),
          6: FixedColumnWidth(60),
          7: FixedColumnWidth(150),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[400]),
            children: const [
              Padding(padding: EdgeInsets.all(8.0), child: Text('')),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Style No',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Component',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Color',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Issue Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Audit Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Bal Qty',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Buyer Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))),
            ],
          ),
          ..._tableData.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = selectedRadioIndex == index;
            final newRow = _tableData[selectedRadioIndex];
            if (newRow['BalanceQty'] <= 0) {
              _areButtonsDisabled = true;
            }

            return TableRow(
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[200] : Colors.transparent,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Radio<int>(
                      fillColor: WidgetStateColor.resolveWith(
                        (states) =>
                            isSelected ? Colors.black : Theme.of(context).colorScheme.secondary,),
                      value: index,
                      groupValue: selectedRadioIndex,
                      onChanged: (value) => _onRadioButtonChanged(index),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    item['StyleNo'].toString(),
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    item['Component']?.toString() ?? '',
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    item['Color'].toString(),
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SelectableText(
                    (item['IssueQty'] ?? 0).toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    (item['AuditQty'] ?? 0).toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    (item['BalanceQty'] ?? 0).toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SelectableText(
                    item['BuyerName'] != null && item['BuyerName']!.length > 15
                        ? '${item['BuyerName']!.substring(0, 15)}..'
                        : item['BuyerName'] ?? '',
                    style: TextStyle(
                        color: isSelected ? Colors.black : Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            );
          }),
          TableRow(
            decoration: BoxDecoration(color: Colors.green[300]),
            children: [
              const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Total',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black))),
              const Padding(
                  padding: EdgeInsets.all(8.0), child: SelectableText('')),
              const Padding(
                  padding: EdgeInsets.all(8.0), child: SelectableText('')),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(totalIssueQty.toString(),
                      textAlign: TextAlign.right,style: TextStyle(color: Colors.black),)),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(totalAuditQty.toString(),
                      textAlign: TextAlign.right,style: TextStyle(color: Colors.black))),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child:
                      Text(totalBalQty.toString(), textAlign: TextAlign.right,style: TextStyle(color: Colors.black),)),
              const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButtons() {
    return Row(
      children: [
        _buildCounterButton('Pass', Colors.green, passCounter, () {
          _handleButtonClick(() async {
            setState(() {
              passCounter++;
              hourlyDataToDict(1, 0, 0, 0);
            });
            await performSequentialTasks('1');
          });
        }, () {
          _handleButtonClick(() async {
            final confirm = await _showRejectDialog(
              context,
              "Do you want to remove the piece?",
            );
            if (confirm) {
              setState(() {
                passCounter = passCounter > 0 ? passCounter - 1 : 0;
                if (passCounter > 0) {
                  hourlyDataToDict(-1, 0, 0, 0);
                }
              });
              await performSequentialTasks('1');
            }
          });
        }),
        _buildCounterButton('Reject', Colors.red, rejectCounter, () {
          _handleButtonClick(() {
            setState(() {
              rejectCounter++;
              hourlyDataToDict(0, 1, 0, 0);
            });
            performSequentialTasks('1');
          });
        }, () {
          _handleButtonClick(() async {
            final confirm = await _showRejectDialog(
              context,
              "Do you want to remove the piece?",
            );
            if (confirm) {
              setState(() {
                rejectCounter = rejectCounter > 0 ? rejectCounter - 1 : 0;
                if (rejectCounter > 0) {
                  hourlyDataToDict(0, -1, 0, 0);
                }
              });
              await performSequentialTasks('1');
            }
          });
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();
    final totalIssueQty = _calculateTotal('IssueQty');
    final totalAuditQty = _calculateTotal('AuditQty');
    final totalBalQty = _calculateTotal('BalanceQty');

    return IgnorePointer(
      ignoring: isPageDisabledNotifier.value,
      child: Opacity(
        opacity: isPageDisabledNotifier.value ? 0.5 : 1.0,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          appBar: AppBar(
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
                double offset;

                // Custom easing for the two-part motion
                if (value < 0.4) {
                  // First part - move right (backward)
                  offset = Curves.easeOut.transform(value / 0.4) * 0.2;
                } else {
                  // Second part - move left (forward)
                  offset = 0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
                }

                return Transform.translate(
                  offset: Offset(offset * 30, 0), // Multiply by approximate pixel value
                  child: Container(
                    margin: const EdgeInsets.only(left: 12, top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
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
                if (_showCursor && _typingController.value < 1.0 && _typingController.value > 0)
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
              // Consumer<ThemeProvider>(
              //   builder: (context, themeProvider, child) {
              //     return CupertinoSwitch(
              //       activeTrackColor: Colors.indigo.shade400,
              //       thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
              //               (Set<WidgetState> states) {
              //             if (states.contains(WidgetState.selected)) {
              //               return const Icon(
              //                 Icons.mode_night_rounded,
              //                 color: Colors.white,
              //               );
              //             }
              //             return const Icon(Icons
              //                 .sunny); // All other states will use the default thumbIcon.
              //           }),
              //       thumbColor: themeProvider.themeMode != ThemeMode.dark
              //           ? Colors.white
              //           : Colors.black,
              //       value: themeProvider.themeMode == ThemeMode.dark,
              //       onChanged: (value) {
              //         themeProvider.toggleTheme(value);
              //       },
              //     );
              //   },
              // ),
              if(_showLine)
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: GestureDetector(
                  onTap: _confirmRefresh,
                  child: Text(
                    line ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],

          ),
          body: _isLoading
              ? const Center(child: LottieLoading(animationPath: 'assets/animation/auditLoading.json',size: 400,))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      if (dataMap.isNotEmpty)
                        Container(
                          height: 30,
                          color: Colors.grey[400],
                          child: Marquee(
                            text: 'Pass: ${totals['pass']}, Reject: ${totals['reject']}, '
                                'Defect: ${totals['defect']}, Rectified: ${totals['rectified']}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
                            scrollAxis: Axis.horizontal,
                            blankSpace: 200.0,
                            velocity: 70.0,
                          ),
                        ),
                      if(dataMap.isNotEmpty)
                      const SizedBox(height: 10),
                      if (_isTableDataLoaded) ... [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                _buildDataTable(totals),
                              ],
                            )),
                      ),
                      ],
                      Divider(color: Theme.of(context).colorScheme.secondary,),
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildCounterButton('Pass', Colors.green, passCounter, () {
                                _handleButtonClick(() async {
                                  setState(() {
                                    passCounter++;
                                    hourlyDataToDict(1, 0, 0, 0);
                                  });
                                  await performSequentialTasks('1');
                                });
                              }, () {
                                _handleButtonClick(() async {
                                  final confirm = await _showRejectDialog(
                                    context,
                                    "Do you want to remove the piece?",
                                  );
                                  if (confirm) {
                                    setState(() {
                                      passCounter = passCounter > 0 ? passCounter - 1 : 0;
                                      if (passCounter > 0) {
                                        hourlyDataToDict(-1, 0, 0, 0);
                                      }
                                    });
                                    await performSequentialTasks('1');
                                  }
                                });
                              }),
                              _buildCounterButton('Reject', Colors.red, rejectCounter, () {
                                _handleButtonClick(() {
                                  setState(() {
                                    rejectCounter++;
                                    hourlyDataToDict(0, 1, 0, 0);
                                  });
                                  performSequentialTasks('1');
                                });
                              }, () {
                                _handleButtonClick(() async {
                                  final confirm = await _showRejectDialog(
                                    context,
                                    "Do you want to remove the piece?",
                                  );
                                  if (confirm) {
                                    setState(() {
                                      rejectCounter = rejectCounter > 0 ? rejectCounter - 1 : 0;
                                      if (rejectCounter > 0) {
                                        hourlyDataToDict(0, -1, 0, 0);
                                      }
                                    });
                                    await performSequentialTasks('1');
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
                                  setState(() { _saveSelectedRadioIndex();});
                                  _showReasonPopup();
                                });
                              }),
                              _buildSimpleButton('Rectified', Colors.blue, rectifiedCounter, () async {
                                setState((){ _saveSelectedRadioIndex();});
                                await saveDataToDict();
                                await saveCatchData();
                                await sendDataToApis();
                                _checkAndOpenPopup();
                              }),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                              onPressed: sendDataToApis,
                              child: const Text(
                                "    Save    ",
                                style: TextStyle(color: Colors.black, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
        ),
      ),
    );
  }
}
