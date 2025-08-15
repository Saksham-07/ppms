import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ppms/ESS/leave_application/screens/leave_form.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Theme/app_theme.dart';
import '../../../common/models/monthmodel.dart';
import '../../../common/utils/constants/baseurl.dart';
import '../models/leavebalancedto.dart';
import '../models/selfleaveapp.dart';
import '../models/yeardto.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication(
      {super.key, required this.title, this.isRefresh = false});
  final String title;
  final bool isRefresh;
  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> with TickerProviderStateMixin {
  String reportingPerson = "", reportingPersonaName = "";

  List<YearDto> lstYear = [];
  String? selectedYear = DateTime.now().year.toString();
  List<Monthmodel> lstMonth = [];
  String? selectedMonth = DateTime.now().month.toString();
  List<Selfleaveapp> lstLeaveApp = [];
  String? leaveCL = "0";
  String? leaveSL = "0";
  String? leaveEL = "0";
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
    if (kDebugMode) {
      print("Back to List Leave Application ");
    }
    super.initState();
    getSharedPrefs();
    getYearList();
    getMonthList();
    getLeaveBalance();
    getLeaveAppList();
    if (kDebugMode) {
      print("Month Number ${DateTime.now().month.toString()}");
    }
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
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
    const shortText = 'Application';

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
          _currentMaxLength = 'Application'.length;
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

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reportingPersonaName = prefs.getString("reportingpersonname").toString();
    setState(() {});
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

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

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

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

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
          print('Response body Month List: ${response.body.toString()}');
        }
        return lstMonth;
      } else {
        return lstMonth;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Selfleaveapp>> getLeaveAppList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstLeaveApp = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GeteLeaveApplicationHistory';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "yearNo": selectedYear.toString(),
        "monthNo": selectedMonth.toString(),
        "appStatus": "All"
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstLeaveApp.add(Selfleaveapp.fromJson(i));
          });
        }
        if (kDebugMode) {
          print('Response body Self Leave List: ${response.body.toString()}');
        }
        return lstLeaveApp;
      } else {
        return lstLeaveApp;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLeaveBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function Leave Balance");
    }
    try {
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GeteLeaveBalance';
      if (kDebugMode) {
        print('Fetching data Leave Balance: $url');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "unitCode": prefs.getString('unitId').toString(),
      };
      print(body);

      print(prefs.getString('employeeId').toString());
      print(prefs.getString('unitId').toString());

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
        var leaveBal = Leavebalancedto.fromJson(data);
        setState(() {
          leaveCL = leaveBal.clbal.toString();
          leaveSL = leaveBal.slbal.toString();
          leaveEL = leaveBal.elbal.toString();
        });

        if (kDebugMode) {
          print('Response body Self Leave List: ${response.body.toString()}');
        }
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  showConfirmDialog(String message, String appId, int appType) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (appType == 2) {
                            cancelLeaveApp(appId);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Yes",
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                    const SizedBox(
                      width: 5,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[500]!),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("No",
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                  ],
                )
              ],
              title: Text("Cancel Leave",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
              titleTextStyle: const TextStyle(fontSize: 20,),
              titlePadding: const EdgeInsets.only(left: 20,top: 20),
              contentPadding: const EdgeInsets.only(left: 20,top: 15,bottom: 30),
              content:
                  Text(message, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ));
  }

  void cancelLeaveApp(String appId) async {
    await cancelApplication(appId, "Cancelled");
  }

  Future<void> cancelApplication(String appId, String appStatus) async {
    try {
      lstLeaveApp = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/CancelLeaveApplication';
      if (kDebugMode) {
        print('Approving Application Approval of Subbordinate: $url');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {"appId": appId, "appStatus": appStatus};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print(response.body);
      }

      if (response.statusCode == 200) {
        showAlert(response.body, 1);
        setState(() {
          selectedYear = DateTime.now().year.toString();
          getLeaveAppList();
        });
      } else {
        showAlert(response.body, 2);
      }
    } catch (e) {
      rethrow;
    }
  }

  showAlert(String message, int msgType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: msgType == 1 ? Colors.blueGrey : Color(0xFFC72C41),
      content: Container(
        padding: const EdgeInsets.all(16),
        height: 60,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ));
  }

  Future<void> _navigateToPage(String title, String req) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LeaveForm(title: title, reqType: req)));
    if (result == true) {
      getLeaveAppList();
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
        elevation: 0,
        shadowColor: Colors.transparent,
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
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reporting Manager Card
                Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Reporting Manager",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                reportingPersonaName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLeaveBalanceItem("CL", leaveCL!, Colors.blue),
                      Container(
                        color: Colors.white,
                        width: 1.5,
                        height: 36,
                      ),
                      _buildLeaveBalanceItem("SL", leaveSL!, Colors.green),
                      Container(
                        color: Colors.white,
                        width: 1.5,
                        height: 36,
                      ),
                      _buildLeaveBalanceItem("EL", leaveEL!, Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Request Buttons Grid
                GridView.count(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 4.8,
                  children: [
                    _buildRequestButton(
                        "Leave", Icons.calendar_today, Colors.blue, "Leave"),
                    _buildRequestButton("MisPunch", Icons.access_time,
                        Colors.orange, "Mispunch"),
                    _buildRequestButton(
                        "OD", Icons.directions, Colors.indigo, "OD"),
                    _buildRequestButton("WFH", Icons.home, Colors.teal, "WFH"),
                  ],
                ),

                const SizedBox(height: 12,),

                Card(
                  color: Theme.of(context).cardColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            "Year",
                            lstYear.map((e) => e.yearNo!).toList(),
                            selectedYear,
                            (value) {
                              setState(() {
                                selectedYear = value;
                                getLeaveAppList();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            "Month",
                            lstMonth.map((e) => e.monthNo!).toList(),
                            selectedMonth,
                            (value) {
                              setState(() {
                                selectedMonth = value;
                                getLeaveAppList();
                              });
                            },
                            displayItems:
                                lstMonth.map((e) => e.monthName!).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lstLeaveApp.length,
                  itemBuilder: (context, index) {
                    return _buildApplicationCard(lstLeaveApp[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceItem(String type, String balance, Color color) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 4),
            Text(
              ': $balance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            Container(
              width: 1,
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRequestButton(
      String title, IconData icon, Color color, String reqType) {
    return ElevatedButton(
      onPressed: () => _navigateToPage('$title Request', reqType),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value,
      Function(String?) onChanged,
      {List<String>? displayItems}) {
    return Card(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 1.3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            items: List.generate(items.length, (index) {
              return DropdownMenuItem<String>(
                value: items[index],
                child: Text(
                  displayItems != null ? displayItems[index] : items[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary
                  ),
                ),
              );
            }),
            value: value,
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 12),
              height: 40,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ));
  }

  Widget _buildApplicationCard(Selfleaveapp application) {
    Color statusColor = Colors.grey;
    if (application.appstatus == "Approved") statusColor = Colors.green;
    if (application.appstatus == "Rejected") statusColor = Colors.red;
    if (application.appstatus == "Sent for Approval")
      statusColor = Colors.orange;

    return Card(
      color: Theme.of(context).cardColor,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  application.apptype ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    application.appstatus ?? "",
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Text(
                  "${application.fromdt} - ${application.todt}",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 16, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    application.appremarks ?? "No remarks",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            if (application.appstatus == "Accepted" ||
                application.appstatus == "Rejected")
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, size: 16, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        application.approvalremarks ?? 'No comments',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            if (application.apptype == "Mispunch")
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(width: 8),
                    Text(
                      application.intime == null || application.intime!.isEmpty
                          ? "Out Time: ${application.outtime}"
                          : "In Time: ${application.intime}",
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ),
            if (application.appstatus == "Sent for Approval")
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    showConfirmDialog(
                      "Are you sure want to Cancel?",
                      application.appid.toString(),
                      2,
                    );
                  },
                  icon: Icon(Icons.cancel, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
