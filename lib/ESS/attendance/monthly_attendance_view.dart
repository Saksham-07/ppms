import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Theme/app_theme.dart';
import '../../common/models/monthmodel.dart';
import '../../common/utils/constants/baseurl.dart';
import 'package:http/http.dart' as http;
import '../leave_application/models/yeardto.dart';
import 'models/attendancemodel.dart';

class MonthlyAttendance extends StatefulWidget {
  const MonthlyAttendance({super.key});

  @override
  State<MonthlyAttendance> createState() => _MonthlyAttendanceState();
}

class _MonthlyAttendanceState extends State<MonthlyAttendance> with TickerProviderStateMixin {
  List<YearDto> lstYear = [];
  String? selectedYear = DateTime.now().year.toString();
  List<Monthmodel> lstMonth = [];
  String? selectedMonth = DateTime.now().month.toString();
  List<Attendancemodel> lstAttendanceDetails = [];
  late Future<List<Attendancemodel>> _attendanceFuture;

  LinkedScrollControllerGroup controllerGroup = LinkedScrollControllerGroup();

  ScrollController? headerScrollController;
  ScrollController? dataScrollController;
  String? unit, id, loginId;
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

    ///Initialize individual Controller to Group
    headerScrollController = controllerGroup.addAndGet();
    dataScrollController = controllerGroup.addAndGet();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();

    getYearList();
    getMonthList();
    _attendanceFuture = getAttendanceDetails();

  }

  @override
  void dispose() {
    _typingController.removeListener(_updateText);
    _typingController.dispose();
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
    var shortText = 'Attendance';

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
          _currentMaxLength = 'Attendance'.length;
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

  Future<List<YearDto>> getYearList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstYear = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetyearList';
      if (kDebugMode) {
        print('Fetching data Year List: $url');
      }

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstYear.add(YearDto.fromJson(i));
          });
        }
        if (kDebugMode) {
          print('Response body Year List: ${response.body.toString()}');
        }
        return lstYear;
      } else {
        return lstYear;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Monthmodel>> getMonthList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstMonth = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetmonthList';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstMonth.add(Monthmodel.fromJson(i));
          });
        }
        if (kDebugMode) {
          print('Response body MOnth List: ${response.body.toString()}');
        }
        return lstMonth;
      } else {
        return lstMonth;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Attendancemodel>> getAttendanceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unit = prefs.getString('unit');
    try {
      lstAttendanceDetails = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetMonthlyAttendance';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": id ?? prefs.getString('login_id').toString(),
        "yearNo": selectedYear.toString(),
        "monthNo": selectedMonth.toString(),
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print(jsonEncode(body));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        log('Data : ${response.body.toString()}');
        for (Map i in data) {
          setState(() {
            lstAttendanceDetails.add(Attendancemodel.fromJson(i));
            loginId = prefs.getString('login_id').toString();
          });
        }
        return lstAttendanceDetails;
      } else {
        return lstAttendanceDetails;
      }
    } catch (e) {
      rethrow;
    }
  }

  int calculateTotalLateMinutes() {
    int totalLateMinutes = 0;
    for (var detail in lstAttendanceDetails) {
      if (detail.status == 'cl1' || detail.status == 'sl1' || detail.status == 'od1' || detail.status == 'el1') continue;

      if (detail.latehrs != null) {
        final parts = detail.latehrs!.split(':');
        int hours = 00;
        int minutes = 00;

        if (parts.length >= 2) {
          hours = int.tryParse(parts[0]) ?? 0;
          minutes = int.tryParse(parts[1]) ?? 0;
        } else if (parts.length == 2) {
          if (parts[1] == 'HRS') {
            hours = int.tryParse(parts[0]) ?? 0;
          } else if (parts[1] == 'MINS') {
            minutes = int.tryParse(parts[0]) ?? 0;
          }
        }

        totalLateMinutes += hours * 60 + minutes;
      }
    }
    return totalLateMinutes;
  }

  int calculateTotalEarlyOutMinutes() {
    int totalEarlyOutMinutes = 0;
    for (var detail in lstAttendanceDetails) {
      if (detail.status == 'cl2' || detail.status == 'sl2' || detail.status == 'od2' || detail.status == 'el2') continue;

      if (detail.earlyhrs != null) {
        totalEarlyOutMinutes += int.tryParse(detail.earlyhrs!) ?? 0;
      }
    }
    return totalEarlyOutMinutes;
  }

  void _updateAttendanceDetails() {
    setState(() {
      lstAttendanceDetails.clear();
      _attendanceFuture = getAttendanceDetails();
    });
  }

  void _showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200],
          title: const Text("Enter Employee ID", style: TextStyle(color: Colors.black87)),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Type Here...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  id = searchController.text.trim();
                });
                Navigator.pop(context);
                _updateAttendanceDetails();
              },
              child: const Text("OK", style: TextStyle(color: Colors.black87)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLateMinutes = calculateTotalLateMinutes();
    final totalEarlyMinutes = calculateTotalEarlyOutMinutes();

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
        actions: [
          if (loginId == '0552482' || loginId == '0552297')
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: GestureDetector(
                  onTap: () {
                    _showSearchDialog(context);
                  },
                  child: const SizedBox(
                    width: 50,
                    height: 50,
                    child: Text(
                      '',
                      style: TextStyle(color: Color(0xFF5FE3D3)),
                    ),
                  )),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        maintainBottomViewPadding: false,
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          panAxis: PanAxis.free,
          minScale: 1.0,
          maxScale: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Year',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          items: lstYear
                              .map((YearDto item) => DropdownMenuItem<String>(
                            value: item.yearNo,
                            child: Text(
                              item.yearNo.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary
                              ),
                            ),
                          ))
                              .toList(),
                          value: selectedYear,
                          onChanged: (String? value) {
                            setState(() {
                              selectedYear = value;
                              _updateAttendanceDetails();
                            });
                          },
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 8,right: 0),
                            height: 40,
                            width: 30,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          items: lstMonth
                              .map(
                                  (Monthmodel item) => DropdownMenuItem<String>(
                                value: item.monthNo,
                                child: Text(
                                  item.monthName.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.secondary
                                  ),
                                ),
                              ))
                              .toList(),
                          value: selectedMonth,
                          onChanged: (String? value) {
                            setState(() {
                              selectedMonth = value;
                              _updateAttendanceDetails();
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 8),
                            height: 40,
                            width: 140,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (unit == 'A-55')
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0,top: 4),
                                child: Text('Total Min : 420',
                                    style: TextStyle(fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.secondary)),
                              ),
                            ),
                            Container(
                              width: 150,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                                border: Border(
                                  top: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                                    width: 0.5,
                                  ),
                                ),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0,top: 4),
                                child: Text(
                                  'Total Min Used : ${-totalEarlyMinutes + totalLateMinutes}',
                                  style: TextStyle(fontWeight: FontWeight.w500,color: Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Attendancemodel>>(
                    future: _attendanceFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: LottieLoading(animationPath: 'assets/animation/calender_grey.json',size: 300,));
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.black87)));
                      } else if (snapshot.hasData) {
                        lstAttendanceDetails = snapshot.data!;
                        final totalLateMinutes = calculateTotalLateMinutes();
                        final totalEarlyMinutes = calculateTotalEarlyOutMinutes();

                        return InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: true,
                          panAxis: PanAxis.free,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Table(
                                    border: TableBorder.all(
                                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),
                                      width: 1.0,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    columnWidths: const {
                                      0: FixedColumnWidth(100),
                                      1: FixedColumnWidth(60),
                                      2: FixedColumnWidth(60),
                                      3: FixedColumnWidth(55),
                                      4: FixedColumnWidth(55),
                                      5: FixedColumnWidth(55),
                                      6: FixedColumnWidth(50),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Date',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'In',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Out',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Status',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Total Hr',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Late In',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Early Out',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ...lstAttendanceDetails.map((detail) {
                                        return TableRow(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                DateFormat('dd/MM/yyyy').format(
                                                  DateFormat('dd-MMM-yyyy').parse(detail.date!),
                                                ),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.intm.toString(),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.outtm.toString(),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.status.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: detail.status == 'A' ||
                                                      detail.status == 'MS'
                                                      ? Colors.red
                                                      : detail.status == 'P' ||
                                                      detail.status ==
                                                          'WO'
                                                      ? Colors.green
                                                      : Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.totalwhrs == '0'
                                                    ? ''
                                                    : detail.totalwhrs.toString(),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.latehrs == '0'
                                                    ? ''
                                                    : detail.latehrs.toString(),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                detail.earlyhrs == '0'
                                                    ? ''
                                                    : detail.earlyhrs.toString(),
                                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade200,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Total',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox.shrink(),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox.shrink(),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox.shrink(),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: SizedBox.shrink(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              totalLateMinutes.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              totalEarlyMinutes.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text('No data available',
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary)));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}