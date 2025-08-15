import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/uuid.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LinewiseOTVerification extends StatefulWidget {
  const LinewiseOTVerification({super.key});

  @override
  State<LinewiseOTVerification> createState() => LinewiseOTVerificationState();
}

class LinewiseOTVerificationState extends State<LinewiseOTVerification> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tableData =
  [];
  String? _loginId;
  final TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  late Future<List<String>> futureUnitsVG,futureUnits;
  String? uuid = '';
  bool _isLoading = true;
  String unit= '',vgUnit='';
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

  @override
  void initState() {
    super.initState();
    getUid();
    _dateController.text = _formatDate(selectedDate);
    futureUnits = fetchUnits();
    futureUnitsVG = fetchUnitsVG();
    Future.delayed(const Duration(milliseconds: 200),(){
      _loadTableData();
    });
    rightsFunction('OTApproval');
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
    var shortText = 'OT Verification';

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
          _currentMaxLength = 'OT Verification'.length;
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

  void _loadTableData() {
    setState(() {
      futureUnits.then((units) {
        unit = units.join(',');

      }).catchError((error) {
        if (kDebugMode) {
          print('Error fetching units: $error');
        }
      });
      futureUnitsVG.then((units) {
        vgUnit = units.join(',');

      }).catchError((error) {
        if (kDebugMode) {
          print('Error fetching units: $error');
        }
      });
      Future.delayed(Duration(milliseconds: 500),(){
        _fetchTableData(unit,vgUnit);
      });

    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 9, 16),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Theme.of(context).colorScheme.secondary,
              surface: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              onSurface: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          child: child!,
        );
      },
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
    final type = _tableData[index]['Type'];
    final created = _loginId;
    DateTime date = selectedDate;

    // '${TBaseURL.baseUrl}update_linewise_ot_approval?lineid=$lineId&unit=$unitCode&userid=$created&dated=$date&device_id=$uuid';
    // Construct the API URL
    String url = '';
    if(type == 'VG') {
      url =
          '${TBaseURL
          .baseUrl}ot_update_vg?lineid=$lineId&unit=$unitCode&userid=$created&dated=$date&device_id=$uuid';
    }
    else{
      url = '${TBaseURL.baseUrl}update_linewise_ot_approval?lineid=$lineId&unit=$unitCode&userid=$created&dated=$date&device_id=$uuid';
    }
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
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=$page';
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=$page');
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

  Future<List<String>> fetchUnitsVG() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId'));

    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      print(unitsJson);
      final List<String> units = unitsJson.map((unit) => unit['UnitCode'].toString()).toList();
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<List<String>> fetchUnits() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId'));

    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      print(unitsJson);
      final List<String> units = unitsJson.map((unit) => unit['UnitCode1'].toString()).toList();
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> _fetchTableData(String unitCode, String vgUnit) async {
    setState(() => _isLoading = true);
    // URLs for both APIs
    final String url1 = '${TBaseURL.baseUrl}linewise_ot_approval?unit=$unitCode&date=${_dateController.text}';
    final String url2 = '${TBaseURL.baseUrl}ot_data_vg?unit=$vgUnit&date=${_dateController.text}';

    if (kDebugMode) {
      print('Fetching from URL 1: $url1');
      print('Fetching from URL 2: $url2');
    }

    try {
      // Fetch data from both APIs concurrently
      final responses = await Future.wait([
        http.get(Uri.parse(url1)),
        http.get(Uri.parse(url2)),
      ]);

      // Check the response status for both APIs
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> data1 = jsonDecode(responses[0].body); // Data from linewise_ot_approval
        final List<dynamic> data2 = jsonDecode(responses[1].body); // Data from ot_data_vg

        if (kDebugMode) {
          print('Data from URL 1: $data1');
          print('Data from URL 2: $data2');
        }

        // Combine data from both APIs into a single list
        final List<Map<String, dynamic>> combinedData = [
          ...data1.map((entry) => {
            'LineName': entry['LineName'],
            'UnitShortCode': entry['UnitShortCode'],
            'OtHrs': entry['OtHrs'],
            'LineId': entry['LineId'],
            'UnitCode': entry['UnitCode'],
            'StyleNo': entry['StyleNo'],
            'Type' : 'Apps',
            'Source': 'API 1', // Add metadata to identify the source
          }),
          ...data2.map((entry) => {
            'LineName': entry['LineName'],
            'UnitShortCode': entry['UnitShortCode'],
            'OtHrs': entry['OtHrs'],
            'LineId': entry['LineId'],
            'UnitCode': entry['UnitCode'],
            'StyleNo': '', // Include fields specific to API 2
            'Type' : 'VG',
            'Source': 'API 2', // Add metadata to identify the source
          }),
        ];

        setState(() {
          _tableData = combinedData;
          _isLoading = false;
          if (kDebugMode) {
            print('Combined Data: $_tableData');
          }
        });
      } else {
        if (kDebugMode) {
          print('Failed to fetch data. Status Codes: ${responses[0].statusCode}, ${responses[1].statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data: $error');
      }
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
        // actions: [
        //   // if (loginId == '0552482' || loginId == '0552297')
        //   //   Padding(
        //   //     padding: const EdgeInsets.all(14.0),
        //   //     child: GestureDetector(
        //   //         onTap: () {
        //   //           _showSearchDialog(context);
        //   //         },
        //   //         child: const SizedBox(
        //   //           width: 50,
        //   //           height: 50,
        //   //           child: Text(
        //   //             '.',
        //   //             style: TextStyle(color: Color(0xFF5FE3D3)),
        //   //           ),
        //   //         )),
        //   //   ),
        //   Consumer<ThemeProvider>(
        //     builder: (context, themeProvider, child) {
        //       return CupertinoSwitch(
        //         activeTrackColor: Colors.indigo.shade400,
        //         thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
        //                 (Set<WidgetState> states) {
        //               if (states.contains(WidgetState.selected)) {
        //                 return const Icon(
        //                   Icons.mode_night_rounded,
        //                   color: Colors.white,
        //                 );
        //               }
        //               return const Icon(Icons
        //                   .sunny); // All other states will use the default thumbIcon.
        //             }),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Select Date',
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                          suffixIcon: const Icon(Icons.date_range_outlined),
                          suffixIconColor: Theme.of(context).colorScheme.secondary,
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
                child: _tableData.isEmpty
                    ? _isLoading
                    ? const Center(
                  child: LottieLoading(animationPath: 'assets/animation/alocationLoading.json',size: 250,)
                )
                    : const Center(
                  child: LottieLoading(animationPath: 'assets/animation/allNoData.json',size: 250,)
                )
                    : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                          ),
                          children:const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Unit',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13,color: Colors.black),
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
                                        fontWeight: FontWeight.bold, fontSize: 13,color: Colors.black),
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
                                        fontWeight: FontWeight.bold, fontSize: 13,color: Colors.black),
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
                                        fontWeight: FontWeight.bold, fontSize: 12,color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('',style: TextStyle(color: Colors.black),),
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
                                  child: Text(row['UnitShortCode'],style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    row['StyleNo'].length > 15
                                        ? row['StyleNo'].substring(0, 15)
                                        : row['StyleNo'],
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['LineName'].toString(),textAlign: TextAlign.left,style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['OtHrs'].toString(),textAlign: TextAlign.right,style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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
                                        child: Text(
                                          'Verify',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
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