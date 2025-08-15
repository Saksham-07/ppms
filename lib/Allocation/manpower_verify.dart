import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/Allocation/verification_report.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/uuid.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class ManpowerVerify extends StatefulWidget {
  const ManpowerVerify({super.key});

  @override
  State<ManpowerVerify> createState() => _ManpowerVerifyState();
}

class _ManpowerVerifyState extends State<ManpowerVerify>
    with TickerProviderStateMixin {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {};
  String? _selectedUnit;
  String? _selectedUnitCode, _selectedUnitCodeVg;
  List<Map<String, dynamic>> _tableData = [];
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  int _totalTailor = 0;
  int _totalHelper = 0;
  int _totalManpower = 0;
  int _totalVerified = 0;
  List<Map<String, dynamic>> _filteredData = [];
  List<String> _remarks = []; // To store remarks for each row
  TextEditingController _dateController =
      TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
  Timer? _timer;
  String uuid = '';
  bool _showFullTitle = true,
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
    deleteDouble();

    Future.delayed(Duration(milliseconds: 200), () {
      _fetchDropDownOptions();
    });
    _dateController.text = _formatDate(selectedDate);
    _timer?.cancel(); // Cancel any previous timer if it exists
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchTableData(_selectedUnitCodeVg!);
    });
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
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
    var shortText = 'Manpower Verification';

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
          _currentMaxLength = 'Manpower Verification'.length;
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

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode1'].toString()).toList();
        _unitMap = {
          for (var item in data)
            item['UnitShortCode1'].toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data)
            item['UnitShortCode1'].toString(): item['UnitCode'].toString()
        };

        if (_dropDownOptions.isNotEmpty) {
          _selectedUnit = _dropDownOptions[0];
          _selectedUnitCode = _unitMap[_selectedUnit];
          _selectedUnitCodeVg = _unitMapVg[_selectedUnit];
          _fetchTableData(_selectedUnitCodeVg!);
          Future.delayed(const Duration(milliseconds: 200), () {
            _fetchTotalPresent(_selectedUnitCodeVg!);
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
    final String url = '${TBaseURL.baseUrl}manpwr_data_vg?unit_code=$unitCode';
    // final String url = '${TBaseURL.baseUrl}fetch_mnpwr_verify?unit_code=$unitCode';
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      setState(() {
        _tableData = data
            .map((e) => {
                  'LineName': e['LineName'],
                  'Mnpwr': e['Mnpwr'],
                  'TailorCount': e['TailorCount'],
                  'HelperCount': e['HelperCount'],
                  'LineId': e['LineId'],
                  'VerifyMnpwr': e['VerifyMnpwr'],
                  'isVerify': e['IsVerified'],
                  'Remarks': e['Remarks'],
                })
            .toList();

        // Initialize the remarks list with empty strings
        _remarks = List.generate(_tableData.length, (_) => '');

        _filteredData = List.from(_tableData);
        _totalTailor =
            _tableData.fold(0, (sum, row) => sum + (row['TailorCount'] as int));
        _totalHelper =
            _tableData.fold(0, (sum, row) => sum + (row['HelperCount'] as int));
        _totalManpower =
            _tableData.fold(0, (sum, row) => sum + (row['Mnpwr'] as int));
        _totalVerified = _tableData.fold(
            0, (sum, row) => sum + ((row['VerifyMnpwr'] ?? 0) as int));
      });
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

  void navigateToReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VerificationReport(), //fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }

  Future<void> _verifyRow(int index) async {
    final lineId = _tableData[index]['LineId'];
    final unitCode = _selectedUnitCode;
    final unitCodeVg = _selectedUnitCodeVg;
    final created = _loginId;
    final manpower = _tableData[index]['Mnpwr'];
    final remark = _remarks[index]; // Get the remark for the row
    String fy = getFinancialYear(DateTime.now());

    // Construct the URLs for both APIs
    final String url1 =
        '${TBaseURL.baseUrl}insert_verify_mnpwr_vg?line=$lineId&unit=$unitCode&created=$created&mnpwr=$manpower&remark=$remark&device_id=$uuid&bussLocation=$unitCodeVg&fy=$fy';

    final String url2 =
        '${TBaseURL.baseUrl}insert_verify_mnpwr?line=$lineId&unit=$unitCode&created=$created&mnpwr=$manpower&remark=$remark&device_id=$uuid';

    if (kDebugMode) {
      print('URL 1: $url1');
      print('URL 2: $url2');
    }

    try {
      // Execute both API calls concurrently
      final responses = await Future.wait([
        http.get(Uri.parse(url1)),
        http.get(Uri.parse(url2)),
      ]);

      // Handle the responses from both APIs
      for (int i = 0; i < responses.length; i++) {
        final response = responses[i];
        if (response.statusCode == 200) {
          if (response.body.contains("Kindly re-verify mnpwr.")) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Verification Required'),
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
            if (i == 0) {
              // Update SharedPreferences only for the first API
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('verified_$lineId', true);
            }

            if (kDebugMode) {
              print('Response body (API ${i + 1}): ${response.body}');
            }

            // Reload table data after a delay (only for the first API)
            if (i == 0) {
              Future.delayed(Duration(milliseconds: 300), () {
                _fetchTableData(unitCodeVg!);
              });
            }

            if (kDebugMode) {
              print(
                  'Successfully inserted data for line ID: $lineId (API ${i + 1})');
            }
          }
        } else {
          // Handle non-200 status codes for each API
          print(
              'Failed to insert data for line ID: $lineId (API ${i + 1}). Status code: ${response.statusCode}');
          if (kDebugMode) {
            print('Response body (API ${i + 1}): ${response.body}');
          }

          // Show dialog box with the actual response message
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
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      // Handle request error
      print(
          'Error occurred while inserting data for line ID: $lineId. Error: $e');
    }
  }

  Future<void> deleteDouble() async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;

    {
      try {
        final response = await http
            .get(Uri.parse('${TBaseURL.baseUrl}delete_double_line_alloc'));

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
      await Future.delayed(
          Duration(seconds: 1)); // Optional delay between retries
    }
  }

  void _filterTableData(String query) {
    setState(() {
      _filteredData = _tableData.where((row) {
        return row['LineName'].toLowerCase().contains(query.toLowerCase()) ||
            row['TailorCount']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            row['HelperCount']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            row['Mnpwr'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _fetchTotalPresent(String unitCode) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse(
            '${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitCode&dated='));
        print(
            '${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitCode&dated=');

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
          success = true; // Exit the loop if data is fetched successfully
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
          Duration(seconds: 1)); // Optional delay between retries
    }
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
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: 30,
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          labelText: 'Select Unit',
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          isDense: true, // Reduces the height
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal:
                                  10.0), // Controls the internal padding
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
                            _selectedUnitCodeVg = _unitMapVg[newValue];
                            deleteDouble();
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _fetchTotalPresent(_selectedUnitCodeVg!);
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                _fetchTableData(_selectedUnitCodeVg!);
                              });
                            });
                          });
                        },
                      ),
                    )),
                    SizedBox(
                      width: 14,
                    ),
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
                        height: 30,
                        width: 100,
                        child: _buildApprovalButton(
                          onPressed: () => navigateToReport(context),
                          label: 'Report',
                          color: Colors.orange,
                        ))
                  ],
                ),
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
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.6),
                      // color: Colors.yellowAccent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Total Manpower Present : $_totalMnpwr",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // color: Colors.black,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
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
                            color: Colors.grey[400],
                          ),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Line',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Talr',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Hlpr',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Man\npower',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Veri\nfied',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
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
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Review',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
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
                                  child: Text(
                                    row['LineName'],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    row['TailorCount'].toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    row['HelperCount'].toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    row['Mnpwr'].toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    (row['VerifyMnpwr'] ?? 0).toString(),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
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
                                        backgroundColor: row['isVerify'] == 1
                                            ? Colors.grey
                                            : Colors.green,
                                      ),
                                      onPressed: row['isVerify'] == 1
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirmation'),
                                                    content: const Text(
                                                        'Are you sure you want to verify this row?'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Confirm'),
                                                        onPressed: () {
                                                          _verifyRow(index);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                      child: Text(
                                        row['isVerify'] == 1
                                            ? 'Verified'
                                            : 'Verify',
                                        style: TextStyle(
                                          color: row['isVerify'] == 1
                                              ? Colors.black
                                              : Colors.white,
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
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                        cursorColor: Theme.of(context).colorScheme.secondary,
                                        decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            ),
                                            hintText: row['isVerify'] == 1
                                                ? row['Remarks']
                                                : 'Enter Remark',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 7),
                                            hintStyle: TextStyle(
                                              color: row['isVerify'] == 1
                                                  ? Colors.black
                                                  : Colors.grey,
                                            )),
                                        readOnly:
                                            row['isVerify'] == 1 ? true : false,
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
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Total',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                        color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalTailor.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalHelper.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalManpower.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalVerified.toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(),
                              ),
                            ),
                            TableCell(
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

  Widget _buildApprovalButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      iconAlignment: IconAlignment.end,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }
}
