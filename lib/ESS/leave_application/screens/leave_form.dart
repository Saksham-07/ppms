import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ppms/ESS/leave_application/screens/leave_application.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Theme/app_theme.dart';
import '../../../common/utils/constants/baseurl.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({super.key, required this.title, required this.reqType});
  final String title;
  final String reqType;
  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> with TickerProviderStateMixin {
  TimeOfDay selectedIntTime = TimeOfDay.now();
  TimeOfDay selectedOuttTime = TimeOfDay.now();
  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  var outputFormat = DateFormat('dd-MM-yyyy');
  var outputFormatymd = DateFormat('yyyy-MM-dd');
  final List<String> lstReqType = ['OD', 'Leave', 'Mispunch', 'WFH'];
  String? selectedReqType;
  List<bool> isHalfOrFullDay = [true, false];
  List<bool> isFirstOrSecondHalf = [true, false];
  final List<String> lstVisitLocation = ['Outside Unit'];
  String? selectedVisitLocation;
  final List<String> lstmispunchReason = [
    'Forgot to punch',
    'Finger punching issue due to Mehndi / cut',
    'Other'
  ];
  Color _currentShadowColor = Colors.blueGrey;
  final List<Color> _shadowColors = [
    // Colors.red.shade500,
    // Colors.green.shade500,
    // Colors.blue.shade500,
    // Colors.orange.shade500,
    // Colors.purple.shade500,
    // Colors.pinkAccent.shade400,
    // Colors.amber.shade500,
  ];
  int _currentColorIndex = 0;
  Timer? _colorChangeTimer;
  String? selectedmisPunchReason;
  var daysCount = 0.0;
  bool isHalfDay = false;
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

  TextEditingController addressController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController visitLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedReqType = widget.reqType.toString();
    calculateTotalDays(selectedDates.start, selectedDates.end);
    isHalfDay = false;
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    _startColorAnimation(300);
  }

  @override
  void dispose() {
    _disposeFormInput();
    _typingController.removeListener(_updateText);
    _typingController.dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _scaleController.dispose();
    _colorChangeTimer?.cancel();
    super.dispose();
  }

  void _startColorAnimation(int d) {
    _colorChangeTimer = Timer.periodic(Duration(milliseconds: d), (timer) {
      setState(() {
        _shadowColors.add(Theme.of(context).colorScheme.secondary);
        _shadowColors.add(Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2));
        _shadowColors.add(Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4));
        _shadowColors.add(Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6));
        _shadowColors.add(Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8));
        _currentColorIndex = (_currentColorIndex + 1) % _shadowColors.length;
        _currentShadowColor = _shadowColors[_currentColorIndex];
      });
    });
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
    var shortText = widget.title;

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
          _currentMaxLength = widget.title.length;
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

  _disposeFormInput() {
    addressController.dispose();
    mobileController.dispose();
    reasonController.dispose();
    visitLocationController.dispose();
  }

  calculateTotalDays(DateTime start, DateTime end) {
    setState(() {
      daysCount = end.difference(start).inDays + 1.0;
      if (kDebugMode) {
        print("Total Days $daysCount");
      }
    });
  }

  submitApplication() {
    if ((selectedReqType == "Leave" ||
            selectedReqType == "OD" ||
            selectedReqType == "WFH") &&
        (reasonController.text.trim().isEmpty)) {
      ShowDialog("Please enter purpose", "Warning");
      return;
    }
    if (selectedReqType == "OD" &&
        (selectedVisitLocation == null || selectedVisitLocation!.isEmpty)) {
      ShowDialog("Please select visit location Type", "Warning");
      return;
    }
    if (selectedReqType == "OD" && (visitLocationController.text.isEmpty)) {
      ShowDialog("Please enter visit location details", "Warning");
      return;
    }
    if (selectedReqType == "Mispunch" &&
        (selectedmisPunchReason == null || selectedmisPunchReason!.isEmpty)) {
      ShowDialog("Please select mispunch reason", "Warning");
      return;
    }
    saveApplication();
  }

  Future<void> saveApplication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url =
          '${TBaseURL.essBaseUrl}api/HRISM/SendLeaveApplicationApproval';
      if (kDebugMode) {
        print('Approving Application Approval of Subbordinate: $url');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      String hulfOrFullDay = "";
      String firstOrSecondHalf = "0";
      double finalDaysCount = daysCount;
      if ((selectedReqType == "Leave" || selectedReqType == "OD")) {
        if (isHalfOrFullDay[1] == true) {
          finalDaysCount = 0.5;
          hulfOrFullDay = "Half Day";
          if (isFirstOrSecondHalf[0] == true) {
            firstOrSecondHalf = "First Half";
          } else {
            firstOrSecondHalf = "Second Half";
          }
        } else {
          hulfOrFullDay = "Full Day";
        }
      }
      String inTime = "";
      String outTime = "";
      if (selectedReqType == "Mispunch") {
        if (isFirstOrSecondHalf[0] == true) {
          firstOrSecondHalf = "First Half";
          inTime = ("${selectedIntTime.hour} : ${selectedIntTime.minute}");
        } else {
          firstOrSecondHalf = "Second Half";
          outTime = ("${selectedOuttTime.hour} : ${selectedOuttTime.minute}");
        }
      }

      Map<String, dynamic> body = {
        "employeeId": prefs.getString('employeeId').toString(),
        "employeeCode": prefs.getString('login_id').toString(),
        "unitId": prefs.getString('unitId').toString(),
        "appType": selectedReqType.toString(),
        "fromDt": outputFormatymd.format(selectedDates.start).toString(),
        "toDt": outputFormatymd.format(selectedDates.end).toString(),
        "daysCount": finalDaysCount,
        "fullOrHalf": hulfOrFullDay,
        "dayPart": firstOrSecondHalf,
        "inTime": inTime,
        "outTime": outTime,
        "appRemarks": reasonController.text.toString(),
        "address": addressController.text.toString(),
        "mobileNo": mobileController.text.toString(),
        "appStatus": "Sent for Approval",
        "visitLocation": visitLocationController.text.toString(),
        "visitLocationType":
            selectedVisitLocation != null && selectedVisitLocation!.isNotEmpty
                ? selectedVisitLocation.toString()
                : "",
        "misPunchRemarks":
            selectedmisPunchReason != null && selectedmisPunchReason!.isNotEmpty
                ? selectedmisPunchReason.toString()
                : "",
      };

      if (kDebugMode) {
        print("Req Body ${jsonEncode(body)}");
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print(response.body);
      }

      if (response.statusCode == 200) {
        ShowDialog(response.body, "Success");
      } else {
        ShowDialog(response.body, "Error");
      }
    } catch (e) {
      rethrow;
    }
  }

  ShowDialog(String message, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (title == "Success") {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(true);
              }
            },
            child: Text("Close", style: TextStyle(color: Colors.grey[800])),
          )
        ],
        title: Text(title,
            style: TextStyle(
                color: Colors.grey[800], fontWeight: FontWeight.bold)),
        contentPadding: const EdgeInsets.all(20),
        content: Text(message, style: TextStyle(color: Colors.grey[700])),
      ),
    );
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
        //   Container(
        //     margin: const EdgeInsets.only(right: 8),
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       border: Border.all(
        //         color: Colors.grey[700]!,
        //         width: 0.5,
        //       ),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(
        //         Icons.menu_rounded,
        //         color: Colors.white,
        //         size: 22,
        //       ),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //       style: IconButton.styleFrom(
        //         backgroundColor: Colors.black54,
        //         shape: const CircleBorder(),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Date Range Card
            Card(
              color: Theme.of(context).cardColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'From Date',
                        date: selectedDates.start,
                        onTap: _selectDateRange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        label: 'To Date',
                        date: selectedDates.end,
                        onTap: _selectDateRange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Day Type & Half Day Selection
            if ((selectedReqType == "Leave" ||
                    selectedReqType == "OD" ||
                    selectedReqType == "WFH") &&
                daysCount == 1.0)
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        constraints: const BoxConstraints(
                            minHeight: 30),
                        fillColor: Colors.blue.shade300,
                        color: Theme.of(context).colorScheme.secondary,
                        selectedColor: Colors.grey[800],
                        borderColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                        selectedBorderColor: Colors.grey[500],
                        borderRadius: BorderRadius.circular(8),
                        isSelected: isHalfOrFullDay,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text("Full Day",style: TextStyle(color: Theme.of(context).colorScheme.secondary ),)),
                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text("Half Day",style: TextStyle(color: Theme.of(context).colorScheme.secondary ),)),
                        ],
                        onPressed: (index) => setState(() {
                          isHalfOrFullDay = [index == 0, index == 1];
                          isHalfDay = isHalfOrFullDay[1];
                        }),
                      ),
                      // First/Second Half Toggle
                      if (isHalfDay) const SizedBox(width: 20),
                      if (isHalfDay)
                        ToggleButtons(
                          constraints: const BoxConstraints( minHeight: 30),
                          fillColor: Colors.orange.shade300,
                          color: Theme.of(context).colorScheme.secondary,
                          selectedColor: Colors.grey[800],
                          borderColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                          selectedBorderColor: Colors.grey[500],
                          borderRadius: BorderRadius.circular(8),
                          isSelected: isFirstOrSecondHalf,
                          children: [
                            Padding(
                                padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("First Half",style: TextStyle(color: Theme.of(context).colorScheme.secondary ),)),
                            Padding(
                                padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("Second Half",style: TextStyle(color: Theme.of(context).colorScheme.secondary ),)),
                          ],
                          onPressed: (index) => setState(() {
                            isFirstOrSecondHalf = [index == 0, index == 1];
                          }),
                        ),
                    ],
                  ),
                ),
              ),

            // Mispunch Time Selection
            if (selectedReqType == "Mispunch")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // First/Second Half Toggle
                      Row(
                        children: [
                          Text('Missed:',
                              style:
                                  TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
                          const Spacer(),
                          ToggleButtons(
                            constraints: const BoxConstraints(
                                minHeight: 30),
                            fillColor: Colors.blue.shade300,
                            color: Theme.of(context).colorScheme.secondary,
                            selectedColor: Colors.grey[800],
                            borderColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                            selectedBorderColor: Colors.grey[500],
                            borderRadius: BorderRadius.circular(8),
                            isSelected: isFirstOrSecondHalf,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text("First Half",style: TextStyle(color: Theme.of(context).colorScheme.secondary),)),
                              Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text("Second Half",style: TextStyle(color: Theme.of(context).colorScheme.secondary),)),
                            ],
                            onPressed: (index) => setState(() {
                              isFirstOrSecondHalf = [index == 0, index == 1];
                            }),
                          ),
                        ],
                      ),

                      // Time Picker
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            isFirstOrSecondHalf[0] ? 'In Time:' : 'Out Time:',
                            style: TextStyle(
                                fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 30,
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: isFirstOrSecondHalf[0]
                                      ? selectedIntTime
                                      : selectedOuttTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.grey[500]!,
                                          onPrimary: Theme.of(context).colorScheme.primary,
                                          surface: Theme.of(context).colorScheme.secondary,
                                          onSurface: Theme.of(context).colorScheme.secondary,
                                        ),
                                        timePickerTheme: TimePickerThemeData(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          hourMinuteTextColor: Theme.of(context).colorScheme.secondary,
                                          hourMinuteColor: Theme.of(context).cardColor,
                                          dayPeriodTextColor: Theme.of(context).colorScheme.secondary,
                                          dayPeriodColor: Theme.of(context).cardColor,
                                          dialHandColor: Colors.grey[800],
                                          dialBackgroundColor: Theme.of(context).cardColor,
                                          dialTextColor: Theme.of(context).colorScheme.secondary,
                                          entryModeIconColor: Theme.of(context).colorScheme.secondary

                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (time != null) {
                                  setState(() {
                                    if (isFirstOrSecondHalf[0]) {
                                      selectedIntTime = time;
                                    } else {
                                      selectedOuttTime = time;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _currentShadowColor),
                                ),
                                child: Text(
                                  isFirstOrSecondHalf[0]
                                      ? "${selectedIntTime.hour}:${selectedIntTime.minute.toString().padLeft(2, '0')}"
                                      : "${selectedOuttTime.hour}:${selectedOuttTime.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
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

            // Mispunch Reason Dropdown
            if (selectedReqType == "Mispunch")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason for Mispunch',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        items: lstmispunchReason,
                        value: selectedmisPunchReason,
                        onChanged: (value) {
                          setState(() {
                            selectedmisPunchReason = value;
                          });
                        },
                        hint: 'Select reason',
                      ),
                    ],
                  ),
                ),
              ),

            // Address During Leave
            if (selectedReqType == "Leave")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                        ),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[600]!,
                                width: 2
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.5
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          labelText: 'Address During Leave',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Mobile Number
            if (selectedReqType == "Leave")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                        ),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[600]!,
                                width: 2
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1.5
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          labelText: 'Mobile number',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Visit Location Type
            if (selectedReqType == "OD" || selectedReqType == "WFH")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Location Type',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDropdown(
                        items: lstVisitLocation,
                        value: selectedVisitLocation,
                        onChanged: (value) {
                          setState(() {
                            selectedVisitLocation = value;
                          });
                        },
                        hint: 'Select location type',
                      ),
                    ],
                  ),
                ),
              ),

            // Visit Location Details
            if (selectedReqType == "OD" || selectedReqType == "WFH")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary
                      ),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: visitLocationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[600]!,
                                width: 2
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1.5
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          labelText: 'Visit Location',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Purpose/Reason
            if (selectedReqType == "Leave" ||
                selectedReqType == "OD" ||
                selectedReqType == "WFH")
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary
                        ),
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.primary,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[600]!,
                                width: 2
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1.5
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          labelText: 'Reason',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                          ),
                          floatingLabelAlignment: FloatingLabelAlignment.start
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Submit Button
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Send for Approval",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? dateTimeRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.grey[800]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (dateTimeRange != null) {
      setState(() {
        selectedDates = dateTimeRange;
        calculateTotalDays(selectedDates.start, selectedDates.end);
      });
    }
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[500]!),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: 16, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  outputFormat.format(date),
                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ))
              .toList(),
          value: value,
          onChanged: onChanged,
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 48,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }
}
