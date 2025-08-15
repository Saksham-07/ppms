import 'dart:async';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Allocation/report.dart';
import 'package:ppms/Allocation/scan_qr.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/utils/constants/baseurl.dart';
import '../ExtraFunction/uuid.dart';
import '../Installation/dio.dart';
import '../Theme/app_theme.dart';

class Allocation extends StatefulWidget {
  const Allocation({super.key});

  @override
  _AllocationState createState() => _AllocationState();
}

class _AllocationState extends State<Allocation> with TickerProviderStateMixin {
  List<Map<String, dynamic>> scannedDataList = [];
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3,
      selectedLineID,
      selectedValue4,
      selectedValue5,
      userId,
      fetchedTailorName,
      fetchedTailorUnit,
      fetchedTailorCode,
      paycodes,
      prevLine;
  int? fetchedTailorDept;
  int? fetchedTailorSDept;
  int? fetchedTailorDesg;
  bool _isAllocation = false;
  bool _isR = false;
  String appVersion = '';
  String fileName = '';
  Timer? _versionTimer;
  TextEditingController textController = TextEditingController();

  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {};
  String? _selectedUnit;
  String? _loginId;
  String? previousValue;
  bool isOTSelected = false;
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  bool isData = false;
  String uuid = '';
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
    getUid();
    _versionTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _fetchAppVersion();
    });
    previousValue = selectedValue3;
    _fetchDropDownOptions();
    _getUserIdFromSharedPreferences();
    _getSelectedUnitFromSharedPreferences();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_selectedUnit != null) {
        _fetchTotalAllocated(_unitMapVg[_selectedUnit]!);
        // Fetch pending allocation data
        if (selectedLineID != null) {
          if (kDebugMode) {
            print(selectedLineID);
          }
          _isLineVerified(selectedLineID);
        }
      }
    });
    checkForAllocate();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _versionTimer?.cancel();
    super.dispose();
  }

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
    var shortText = 'Allocation';

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
          _currentMaxLength = 'Allocation'.length;
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

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  //*-*-*-*-*-*-*-*-*-*-*-*-Update code Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      print(appVersion);
      getVersion(appVersion);
    });
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http
          .get(Uri.parse('${TBaseURL.baseUrl}version?version=$version'));
      print('${TBaseURL.baseUrl}version?version=$version');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          bool isVersionValid = data[0]['IsActive'];
          if (!isVersionValid) {
            await getFile();
            _showUpdateDialog(); // Only show dialog if fileName is available
          }
        } else {
          if (kDebugMode) {
            print('No data found');
          }
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
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data[0]['VersionFile']);
        }
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
    print(apkUrl);
    if (kDebugMode) {
      print(apkUrl);
    }
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
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Update Required',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            content: Text('Please update the app to the latest version.',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            actions: [
              TextButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    downloadApk(context, apkUrl);
                  } else if (Platform.isIOS) {
                    if (await canLaunchUrl(appStoreUrl)) {
                      await launchUrl(appStoreUrl);
                    } else {
                      if (kDebugMode) {
                        print('Could not launch $appStoreUrl');
                      }
                    }
                  }
                },
                child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        );
      },
    );
  }

  //*-*-*-*-*-*-*-*-*-*-*-*-Update Code End-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _isLineVerified(String? line) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    int ot = isOTSelected ? 1 : 0;
    String? unit = _unitMap[_selectedUnit]!;

    if (ot == 0) {
      try {
        final response = await http.get(Uri.parse(
            '${TBaseURL.baseUrl}chk_line_verification?line_id=$line&ot=$ot&unit=$unit'));
        if (kDebugMode) {
          print(
              '${TBaseURL.baseUrl}chk_line_verification?line_id=$line&ot=$ot&unit=$unit');
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.isNotEmpty) {
            setState(() {
              isData = true;
              if (kDebugMode) {
                print('isData $isData');
              }
            });
          } else {
            isData = false;
          }
        } else {
          setState(() {
            isData = false;
            if (kDebugMode) {
              print('$isData iieir');
            }
          });
          throw Exception('Failed to load table data');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    } else {
      isData = false;
      if (kDebugMode) {
        print('isData $isData');
      }
    }
  }

  Future<void> _fetchTotalAllocated(String unitCode) async {
    const int maxRetries = 5;
    int retryCount = 0;
    String date = DateTime.now().toString();
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse(
            '${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitCode&dated=$date'));

        if (kDebugMode) {
          print(
              '${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitCode&dated=$date');
        }

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
          }
          success = true;
        } else {
          throw Exception('Failed to load table data');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(
          const Duration(seconds: 1)); // Optional delay between retries
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedUnit = prefs.getString('selectedUnit');
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            ['----'] + data.map((e) => e['UnitShortCode1'].toString()).toList();
        _unitMap = {
          for (var item in data)
            item['UnitShortCode1'].toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data)
            item['UnitShortCode1'].toString(): item['UnitCode'].toString()
        };

        print(_dropDownOptions);
        print(selectedUnit);
        Future.delayed(Duration(microseconds: 400), () {
          if (_dropDownOptions.contains(selectedUnit)) {
            _selectedUnit = selectedValue4;
          } else {
            _selectedUnit =
                _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : '';
          }
          saveUnitMapToSharedPreferences(_unitMap);
        });
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
    int ot = isOTSelected ? 1 : 0;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http
            .get(Uri.parse('${TBaseURL.baseUrl}line_vg?unit=$unit&ot=$ot'));
        // final response = await http.get(Uri.parse('http://172.16.10.11:8001/line?unit=$unit&ot=$ot'));
        if (kDebugMode) {
          print('${TBaseURL.baseUrl}line_vg?unit=$unit&ot=$ot');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse
                .map((item) => {
                      'LineName': item['LineName'].toString(),
                      'LineID': item['LineId'].toString(),
                    })
                .toList();
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

      await Future.delayed(
          const Duration(seconds: 2)); // Optional delay between retries
    }
  }

  Future<void> fetchTailorDataFromApi(String unit) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        String yesterday = DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 1)));
        final response = await http.get(Uri.parse(
            '${TBaseURL.baseUrl}allocation_tailor_vg?type=dropdown&data=$unit&dated=$yesterday'));
        if (kDebugMode) {
          print(
              '${TBaseURL.baseUrl}allocation_tailor_vg?type=dropdown&data=$unit&dated=$yesterday');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData5 = jsonResponse.map((item) {
              String paycode = item['PAY_CODE'].toString();
              String name = item['NAME'].toString();
              return '$paycode[$name]';
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

      await Future.delayed(
          const Duration(seconds: 2)); // Optional delay between retries
    }
  }

  Future<void> _getUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullUserId = prefs.getString('name');
    setState(() {
      userId = (fullUserId != null && fullUserId.length > 15)
          ? fullUserId.substring(0, 15)
          : fullUserId;
    });
  }

  Future<void> _getSelectedUnitFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedUnit = prefs.getString('selectedUnit');
    setState(() {
      selectedValue4 = selectedUnit ?? '-';
      if (selectedUnit != null) {
        dropdownData3.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          fetchLineDataFromApi(_unitMapVg[_selectedUnit]!);
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          fetchTailorDataFromApi(selectedUnit);
        });
      }
    });
  }

  Future<void> fetchTailorDataByCode(String code) async {
    try {
      final response = await http.get(Uri.parse(
          '${TBaseURL.baseUrl}allocation_tailor_vg?type=single&data=$code&dated='));
      print(
          '${TBaseURL.baseUrl}allocation_tailor_vg?type=single&data=$code&dated=');
      // final response = await http.get(Uri.parse('http://172.16.10.11:8000/tailor_data?code=$code'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          var data = jsonResponse[0];
          print(data);
          setState(() {
            paycodes = data['PAY_CODE'];
            if (kDebugMode) {
              print(paycodes);
            }
            fetchedTailorCode = data['NAME'];
            if (kDebugMode) {
              print(fetchedTailorCode);
            }
            fetchedTailorName = data['EMP_CODE'];
            if (kDebugMode) {
              print(fetchedTailorName);
            }
            fetchedTailorDept = data['DEPT'];
            if (kDebugMode) {
              print(fetchedTailorDept);
            }
            fetchedTailorSDept = data['SDEPT'];
            fetchedTailorDesg = data['DESG'];
            fetchedTailorUnit = data['UnitShortCode'];
          });
        } else {
          if (kDebugMode) {
            print('No data found');
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void _addSelectedData() {
    if (selectedValue5 == null) {
      _showTailorSelectionAlert();
      return;
    }
    bool ot = isOTSelected;

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (selectedValue5 != null &&
        selectedValue3 != null &&
        selectedValue4 != null) {
      print(1);
      fetchTailorDataByCode(selectedValue5!).then((_) {
        print(2);
        if (fetchedTailorName != null &&
            !_isNameDuplicate(fetchedTailorName!)) {
          print(3);
          if (fetchedTailorUnit == selectedValue4) {
            print(4);
            checkDataInApi(todayDate, paycodes!).then((alreadyExists) {
              print(5);
              if (alreadyExists) {
                print('already');
                if (ot) {
                  _showDataExistsAlert(() {
                    print(6);
                    _addDataToList();
                  });
                } else {
                  print(7);
                  if (_isAllocation) {
                    print(8);
                    _showDataExistsAlert(() {
                      print(9);
                      _addDataToList();
                    });
                  } else {
                    _showRights();
                  }
                }
              } else {
                print('add');
                _addDataToList();
              }
            });
          } else {
            _showUnitMismatchAlert();
          }
        }
      });
    } else if (selectedValue3 == null) {
      _showLineSelectionAlert();
    }
  }

  void _navigateToScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QR()),
    );
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool ot = isOTSelected;

    if (result != null) {
      await fetchTailorDataByCode(result);

      if (selectedValue3 != null) {
        if (fetchedTailorUnit == selectedValue4) {
          fetchTailorDataByCode(selectedValue3!).then((_) {
            if (fetchedTailorName != null &&
                !_isNameDuplicate(fetchedTailorName!)) {
              checkDataInApi(todayDate, paycodes!).then((alreadyExists) {
                if (alreadyExists) {
                  if (ot) {
                    _showDataExistsAlert(() {
                      _addDataToList();
                    });
                  } else {
                    if (_isAllocation) {
                      _showDataExistsAlert(() {
                        _addDataToList();
                      });
                    } else {
                      _showRights();
                    }
                  }
                } else {
                  _addDataToList();
                }
              });
            }
          });
        } else {
          _showUnitMismatchAlert();
        }
      }
    }
  }

  void navigateToReport(BuildContext context) {
    if (kDebugMode) {
      print('Navigating to report');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Report(selectedUnit: _selectedUnit),
      ),
    );
  }

  void _showDataExistsAlert(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Data Already Present',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text(
                'The data you are trying to add already exists. Do you want to update it?',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Reject',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  onConfirm(); // Call the onConfirm callback to add the data
                },
                child: Text('Confirm',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRights() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Access Denied',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text('You do not have rights to modify data',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addDataToList() {
    bool ot = isOTSelected;
    if (kDebugMode) {
      print(ot);
    }
    setState(() {
      scannedDataList.add({
        'tailor': fetchedTailorCode!,
        'line': selectedValue3!,
        'LineID': selectedLineID!,
        'unit': fetchedTailorUnit!,
        'UnitCode': _unitMap[fetchedTailorUnit] ?? '',
        'VgUnit': _unitMapVg[fetchedTailorUnit] ?? '',
        'EMP_CODE': fetchedTailorName!,
        'DEPT': fetchedTailorDept!,
        'SDEPT': fetchedTailorSDept!,
        'DESG': fetchedTailorDesg!,
        'PayCode': paycodes!,
      });
    });
  }

  void _showLineSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Line Not Selected',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text('Please select a line before adding.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTailorSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Tailor Not Selected',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text('Please select a tailor before adding.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUnitMismatchAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Unit Mismatch',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            content: Text(
                'User unit does not match the Selected unit. Please select the appropriate unit.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isNameDuplicate(String name) {
    bool isDuplicate =
        scannedDataList.any((element) => element['EMP_CODE'] == name);

    if (isDuplicate) {
      _showDuplicateAlert();
    }

    return isDuplicate;
  }

  void _showDuplicateAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Duplicate Data",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text("This data is already present.",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: <Widget>[
            TextButton(
              child: Text("OK",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearList() {
    setState(() {
      scannedDataList.clear();
    });
  }

  Future<void> _saveAllocationData(
      String tailor,
      String fy,
      String pay,
      String lineID,
      String unitCode,
      int dept,
      int sDept,
      int desg,
      String emp,
      String vgUnit) async {
    // Define URLs for both APIs
    final apiUrl1 = Uri.parse(
        '${TBaseURL.baseUrl}allocate?line=$lineID&fy=$fy&empC=$emp&payC=$pay'
        '&empN=$tailor&dept=$dept&sDept=$sDept&desg=$desg&unit=$unitCode&created=$_loginId&device_id=$uuid');

    final apiUrl2 = Uri.parse(
        '${TBaseURL.baseUrl}insert_allocation_vg?line=$lineID&fy=$fy&empC=$emp&payC=$pay'
        '&empN=$tailor&dept=$dept&sDept=$sDept&desg=$desg&unit=$unitCode&created=$_loginId&device_id=$uuid&bussLocation=$vgUnit');

    if (kDebugMode) {
      print('Request URL 1: $apiUrl1');
      print('Request URL 2: $apiUrl2');
    }

    try {
      // Execute both API calls concurrently
      final responses = await Future.wait([
        http.get(apiUrl1),
        http.get(apiUrl2),
      ]);

      // Handle responses
      if (responses[0].statusCode == 200) {
        if (kDebugMode) {
          print(
              'API 1: Data sent successfully: Tailor: $tailor, LineID: $lineID, Unit: $unitCode');
        }
      } else {
        if (kDebugMode) {
          print('API 1: Failed to send data: ${responses[0].body}');
        }
      }

      if (responses[1].statusCode == 200) {
        if (kDebugMode) {
          print(
              'API 2: Data sent successfully: Tailor: $tailor, LineID: $lineID, Unit: $unitCode');
        }
      } else {
        if (kDebugMode) {
          print('API 2: Failed to send data: ${responses[1].body}');
        }
      }
    } catch (e) {
      // Handle any errors that occur during the requests
      if (kDebugMode) {
        print('Error occurred while sending data: $e');
      }
    }
  }

  Future<void> checkForAllocate() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}base?user=$loginId&module=kpi&page=LineAllocation';

    if (kDebugMode) {
      print(
          '${TBaseURL.baseUrl}base?user=$loginId&module=kpi&page=LineAllocation');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // If all items are 'R', hide the buttons
        bool allR = data.every((item) => item['shortname'] == 'R');
        _isR =
            !allR; // _isAllocation will be true if there is any 'M' or other than 'R'
        _isAllocation = data.any((item) => item['shortname'] == 'M');
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _updateAllocationData(String lineID, String pay, String date,
      bool isOt, String otLine, String vgUnit) async {
    // Define URLs for both APIs
    final url1 = isOt
        ? '${TBaseURL.baseUrl}update_line_alloc?type=2&line=&otLine=$lineID&paycode=$pay&date=$date&modified=$_loginId'
        : '${TBaseURL.baseUrl}update_line_alloc?type=1&line=$lineID&otLine=&paycode=$pay&date=$date&modified=$_loginId';

    final url2 = isOt
        ? '${TBaseURL.baseUrl}update_allocation_vg?type=2&line=&otLine=$lineID&paycode=$pay&date=$date&modified=$_loginId&bussLocation=$vgUnit'
        : '${TBaseURL.baseUrl}update_allocation_vg?type=1&line=$lineID&otLine=&paycode=$pay&date=$date&modified=$_loginId&bussLocation=$vgUnit';

    if (kDebugMode) {
      print('Request URL 1: $url1');
      print('Request URL 2: $url2');
    }

    try {
      // Execute both API calls concurrently
      final responses = await Future.wait([
        http.get(Uri.parse(url1)),
        http.get(Uri.parse(url2)),
      ]);

      // Handle responses for the first API
      if (responses[0].statusCode == 200) {
        if (kDebugMode) {
          print(
              'API 1: Data updated successfully: LineID: $lineID, Paycode: $pay');
        }
      } else {
        if (kDebugMode) {
          print('API 1: Failed to update data: ${responses[0].body}');
        }
      }

      // Handle responses for the second API
      if (responses[1].statusCode == 200) {
        if (kDebugMode) {
          print(
              'API 2: Data updated successfully: LineID: $lineID, Paycode: $pay');
        }
      } else {
        if (kDebugMode) {
          print('API 2: Failed to update data: ${responses[1].body}');
        }
      }
    } catch (e) {
      // Handle errors during the API requests
      if (kDebugMode) {
        print('Error occurred while updating data: $e');
      }
    }
  }

  String getFinancialYear(DateTime date) {
    int year = date.year;
    if (date.isBefore(DateTime(year, 4, 1))) {
      return '${(year - 1)}-$year';
    } else {
      return '$year-${(year + 1)}';
    }
  }

  Future<bool> checkDataInApi(String date, String paycode) async {
    final response = await http.get(Uri.parse(
        '${TBaseURL.baseUrl}check_line_alloc?date=$date&paycode=$paycode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (data is List && data.isNotEmpty) {
        prevLine = data[0]['LineId'].toString();
        if (kDebugMode) {
          print(prevLine);
        }
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('Failed to check data');
    }
  }

  bool isLoading = false;

  Future<void> _allocate() async {
    setState(() {
      isLoading = true;
    });

    String fy = getFinancialYear(DateTime.now());
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool ot = isOTSelected;

    int successCount = 0; // Track successful allocations
    int failureCount = 0; // Track failed allocations

    for (var data in scannedDataList) {
      try {
        // Check if the data is present in the first API
        bool isDataPresent = await checkDataInApi(todayDate, data['PayCode']);

        if (kDebugMode) {
          print('Is data present: $isDataPresent');
        }

        if (isDataPresent) {
          await _updateAllocationData(
            data['LineID'],
            data['PayCode']!,
            todayDate,
            ot,
            data['LineID'],
            data['VgUnit']!,
          );
          successCount++; // Increment success for update
        } else {
          if (kDebugMode) {
            print('Allocating');
            print(data);
          }
          await _saveAllocationData(
            data['tailor']!,
            fy,
            data['PayCode'],
            data['LineID']!,
            data['UnitCode']!,
            data['DEPT']!,
            data['SDEPT']!,
            data['DESG']!,
            data['EMP_CODE'],
            data['VgUnit']!,
          );
          successCount++; // Increment success for new allocation
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error in _allocate: $e');
        }
        failureCount++;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: successCount == scannedDataList.length
              ? Text('Allocation Successful',style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
              : Text('Allocation Partially Successful',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text(successCount == scannedDataList.length
              ? 'All data allocations were successful.'
              : '$successCount allocations succeeded, $failureCount failed.',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
          ],
        );
      },
    );

    // Clear the list regardless of success or failure
    _clearList();
    _fetchTotalAllocated(_unitMapVg[_selectedUnit]!);

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Data already exists",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text("Do you want to update the existing data?", style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: <Widget>[
            TextButton(
              child: Text("Reject",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Confirm",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String _getTailorName(String payCode) {
    // Find the name corresponding to the PAY_CODE in your dropdownData5
    final item = dropdownData5.firstWhere(
      (element) => element.startsWith(payCode),
      orElse: () => '',
    );
    return item.split('[').last.replaceAll(']', '');
  }

  Future<void> saveUnitMapToSharedPreferences(
      Map<String, String> unitMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  Future<void> _saveSelectedUnitToSharedPreferences(String selectedUnit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedUnit', selectedUnit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              offset =
                  0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
            }

            return Transform.translate(
              offset:
                  Offset(offset * 30, 0), // Multiply by approximate pixel value
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
        // actions: [
        //   Consumer<ThemeProvider>(
        //     builder: (context, themeProvider, child) {
        //       return CupertinoSwitch(
        //         activeTrackColor: Colors.indigo.shade400,
        //         thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
        //             (Set<WidgetState> states) {
        //           if (states.contains(WidgetState.selected)) {
        //             return const Icon(
        //               Icons.mode_night_rounded,
        //               color: Colors.white,
        //             );
        //           }
        //           return const Icon(Icons
        //               .sunny); // All other states will use the default thumbIcon.
        //         }),
        //         thumbColor: themeProvider.themeMode != ThemeMode.dark
        //             ? Colors.white
        //             : Colors.black,
        //         value: themeProvider.themeMode == ThemeMode.dark,
        //         onChanged: (value) {
        //           themeProvider.toggleTheme(value);
        //         },
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Column(
              children: [
                // Unit and Line Selection Row
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 30,
                                child: _buildSearchableDropdown(
                                  context: context,
                                  label: 'Unit',
                                  value: _selectedUnit,
                                  items: _dropDownOptions,
                                  onChanged: (newValue) {
                                    _clearList();
                                    setState(() {
                                      selectedValue4 = newValue;
                                      _selectedUnit = newValue;
                                      selectedValue3 = null;
                                      selectedValue5 = null;
                                      dropdownData3.clear();
                                      dropdownData5.clear();
                                      _saveSelectedUnitToSharedPreferences(newValue!);
                                    });
                                    fetchLineDataFromApi(_unitMapVg[newValue]!);
                                    _fetchTotalAllocated(_unitMapVg[newValue]!);
                                    Future.delayed(const Duration(milliseconds: 300), () {
                                      fetchTailorDataFromApi(newValue!);
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: _buildSearchableDropdown(
                                  context: context,
                                  label: 'Line',
                                  value: selectedValue3,
                                  items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(),
                                  onBeforePopupOpening: (popupProps) async {
                                    bool? shouldOpen = true;
                                    if(scannedDataList.isNotEmpty) {
                                      shouldOpen = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Theme.of(context).cardColor,
                                            title: Text("Confirm Change",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                            content: Text("Changing the line will clear all your data. Are you sure?",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: Text("No",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                  _clearList();
                                                },
                                                child: Text("Yes",style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                    return shouldOpen == true;
                                  },
                                  onChanged: (newValue) {
                                    previousValue = selectedValue3;
                                    setState(() {
                                      previousValue = newValue;
                                      selectedValue3 = newValue;
                                      selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                                      _isLineVerified(selectedLineID);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: _buildSearchableDropdown(
                                  context: context,
                                  label: 'Tailor',
                                  value: selectedValue5 != null ? '$selectedValue5[${_getTailorName(selectedValue5!)}]' : null,
                                  items: dropdownData5,
                                  onChanged: (newValue) {
                                    setState(() {
                                      if (newValue != null) {
                                        selectedValue5 = newValue.split('[').first;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).cardColor.withValues(alpha: 2),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isOTSelected,
                                    checkColor: Theme.of(context).colorScheme.primary,
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    activeColor: Theme.of(context).colorScheme.secondary,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isOTSelected = value ?? false;
                                        // Instead of setting to empty string, set to null
                                        selectedValue3 = null;
                                      });
                                      setState(() {
                                        if (_selectedUnit != null) {
                                          dropdownData3.clear();
                                          fetchLineDataFromApi(_unitMapVg[_selectedUnit]!);
                                        }
                                        if (selectedLineID != null) {
                                          _isLineVerified(selectedLineID);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    'OT',
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_isR) ...[
                              SizedBox(
                                height: 30,
                                child: _buildActionButton(
                                  context: context,
                                  text: 'Add',
                                  icon: Icons.add,
                                  color: Colors.green,
                                  onPressed: _addSelectedData,
                                ),
                              ),
                              const SizedBox(width: 8,),
                              SizedBox(
                                height: 30,
                                child: _buildActionButton(
                                  context: context,
                                  text: 'Scan',
                                  icon: Icons.qr_code_scanner,
                                  color: Colors.blue,
                                  onPressed: () {
                                    if (selectedValue3 == null ||
                                        selectedValue3!.isEmpty) {
                                      _showLineSelectionAlert();
                                    } else {
                                      _navigateToScanner(context);
                                    }
                                  },
                                ),
                              ),
                            ],

                            const SizedBox(width: 8,),
                            // Present/Allocated Info
                            Expanded(
                              child: Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5))
                                ),
                                child: Center(
                                  child: Text(
                                    'Present/Allocated : $_totalMnpwr/$_allocMnpwr',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Data Table
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: scannedDataList.isEmpty? Center(child: LottieLoading(animationPath: 'assets/animation/allNoData.json',size: 250,),) : SingleChildScrollView(
                        child: Table(
                          border: TableBorder.symmetric(
                              inside: BorderSide(
                                  color: Colors.grey.withOpacity(0.5))),
                          columnWidths: const {
                            0: FixedColumnWidth(40),
                            1: FlexColumnWidth(2.3),
                            2: FlexColumnWidth(2.5),
                            3: FlexColumnWidth(4.2),
                            4: FixedColumnWidth(50),
                          },
                          children: [
                            // Table Header
                            TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8))),
                              children: [
                                _buildTableHeaderCell(''),
                                _buildTableHeaderCell('Pay Code'),
                                _buildTableHeaderCell('Emp Code'),
                                _buildTableHeaderCell('Name'),
                                const TableCell(child: SizedBox.shrink()),
                              ],
                            ),
                            // Table Rows
                            ...scannedDataList.asMap().entries.map((entry) {
                              int index = entry.key;
                              var data = entry.value;
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor
                                ),
                                children: [
                                  _buildTableCell((index + 1).toString()),
                                  _buildTableCell(data['PayCode'] ?? ''),
                                  _buildTableCell(data['EMP_CODE'] ?? ''),
                                  _buildTableCell(
                                    data['tailor'] != null &&
                                            data['tailor']!.length > 13
                                        ? '${data['tailor']!.substring(0, 14)}..'
                                        : data['tailor'] ?? '',
                                  ),
                                  TableCell(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          scannedDataList.remove(data);
                                        });
                                      },
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
                ),

                const SizedBox(height: 8),

                // Bottom Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isR) ...[
                      SizedBox(
                        height: 30,
                        child: _buildBottomButton(
                          context: context,
                          text: 'Allocate',
                          icon: Icons.check_circle,
                          color: Colors.green,
                          onPressed: () {
                            if (!isLoading) {
                              if (!isData) {
                                if (scannedDataList.isEmpty) {
                                  showEmptyListAlert(context);
                                } else {
                                  _allocate();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Can't Allocate, Line Manpower Already Verified")),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 30,
                        child: _buildBottomButton(
                          context: context,
                          text: 'Clear All',
                          icon: Icons.delete_sweep,
                          color: Colors.red,
                          onPressed: _clearList,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 30,
                      child: _buildBottomButton(
                        context: context,
                        text: 'Report',
                        icon: Icons.assignment,
                        color: Colors.orange,
                        onPressed: () => navigateToReport(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5,)
              ],
            ),

            // Loading Indicator
            if (isLoading)
              Center(
                child: Container(
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: LottieLoading(animationPath: 'assets/animation/allocation.json',size: 300,)
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// Helper Widgets
  Widget _buildSearchableDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    Future<bool?> Function(bool?)? onBeforePopupOpening,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ))
          .toList(),
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 14,
      ),
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 2),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey.shade600,
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dropdownSearchData: DropdownSearchData(
        searchController: TextEditingController(),
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Container(
          height: 50,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 4,
            right: 8,
            left: 8,
          ),
          child: TextFormField(
            cursorColor: Theme.of(context).colorScheme.secondary,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            controller: TextEditingController(),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: 'Search...',
              hintStyle: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
        searchMatchFn: (item, searchValue) {
          return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
        },
      ),
      onMenuStateChange: (isOpen) {
        if (!isOpen) {
          // Clear search when dropdown closes
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 15),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildBottomButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: 13,color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  void showEmptyListAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('No Data Available',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text('Add Some Data before Allocating.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showChangeLineAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Are You Sure',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text('This will Clear All Data.',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
