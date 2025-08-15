import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/attendance/monthly_attendance_view.dart';
import 'package:ppms/ESS/download_payslip/download_payslip.dart';
import 'package:ppms/ESS/leave_approval/screens/leave_approval.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'leave_application/screens/leave_application.dart';
import 'leave_approval/models/userprofilemodel.dart';
import 'models/pendingapprovalmodel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EssDashBoard extends StatefulWidget {
  const EssDashBoard({super.key});

  @override
  State<EssDashBoard> createState() => _EssDashBoardState();
}

class _EssDashBoardState extends State<EssDashBoard> with TickerProviderStateMixin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String pendingLeave = "0", pendingMngtApproval = "0";
  String previousPendingLeave = "0", previousPendingMngtApproval = "0";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _notificationTimer;
  late AnimationController _splashController;
  late Animation<double> _splashScaleAnimation;
  late Animation<double> _splashFadeAnimation;
  OverlayEntry? _splashOverlay;
  IconData? _selectedIcon;
  Color? _selectedIconColor;
  GlobalKey? _selectedIconKey;
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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Slightly faster animation
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Splash animations
    _splashScaleAnimation = Tween<double>(begin: 1, end: 50).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: Curves.easeInToLinear,
      ),
    );

    _splashFadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
    GetePendingForApproval();

    _notificationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isDisposed) {
        GetePendingForApproval();
      }
    });
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    getEmployeeProfileByEmployeeCode();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _isDisposed = true;
    _animationController.dispose();
    _splashController.dispose();
    _notificationTimer?.cancel();
    _removeSplashOverlay();
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

  //App bar typing animation
  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'Employee Self Service';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  //App bar typing animation
  void _toggleCursor(Timer timer) {
    if (mounted) {
      // Show cursor during both forward and reverse typing
      final shouldShowCursor = _typingController.value > 0 &&
          _typingController.value < 1.0;

      if (shouldShowCursor || _showCursor != shouldShowCursor) {
        setState(() => _showCursor = shouldShowCursor);
      }
    }
  }

  //App bar typing animation
  Future<void> _startTypingSequence() async {
    // Type out full title
    _currentMaxLength = 'Paramount Product Management System'.length;
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);

    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Reverse type full title
    setState(() => _isReversing = true);
    await _typingController.reverse(from: 1.0);

    // Switch to short title
    if (mounted) {
      setState(() {
        _showFullTitle = false;
        _isReversing = false;
        _currentMaxLength = 'Employee Self Service'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  void _removeSplashOverlay() {
    if (_splashOverlay != null && _splashOverlay!.mounted) {
      _splashOverlay!.remove();
      _splashOverlay = null;
    }
  }

  Future<void> getEmployeeProfileByEmployeeCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url =
          '${TBaseURL.essBaseUrl}api/HRISM/GetEmployeeProfileByEmployeeCode';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('login_id').toString()
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var newProfiledata = Userprofilemodel.fromJson(data);
        prefs.setString('employeeId', newProfiledata.employeeid.toString());
        prefs.setString('unitId', newProfiledata.unit.toString());
        prefs.setString('unitlocation', newProfiledata.unitlocation.toString());
        prefs.setString('department', newProfiledata.department.toString());
        prefs.setString('designation', newProfiledata.designation.toString());
        prefs.setString(
            'reportingperson', newProfiledata.reportingperson.toString());
        prefs.setString('reportingpersonname',
            newProfiledata.reportingpersonname.toString());
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

  Future<void> GetePendingForApproval() async {
    if (_isDisposed) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetePendingForApproval';
      String empId = prefs.getString('employeeId').toString();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, dynamic> body = {
        "employeeId": empId
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var resData = Pendingapprovalmodel.fromJson(data);

        String newPendingLeave = resData.pendingLeaveApproval.toString();
        String newPendingMngtApproval = resData.pendingManagementApp.toString();

        if (!_isDisposed) {
          setState(() {
            pendingLeave = newPendingLeave;
            pendingMngtApproval = newPendingMngtApproval;
            previousPendingLeave = newPendingLeave;
            previousPendingMngtApproval = newPendingMngtApproval;
          });
        }
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in GetePendingForApproval: $e');
      }
    }
  }

  Future<void> _navigateWithSplashAnimation(BuildContext context, Widget page, IconData icon, Color iconColor, GlobalKey iconKey) async {
    if (_isDisposed) return;

    final renderBox = iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _selectedIcon = icon;
      _selectedIconColor = iconColor;
      _selectedIconKey = iconKey;
    });

    // Create splash overlay
    _splashOverlay = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _splashController,
          builder: (context, child) {
            return IgnorePointer(
              child: Stack(
                children: [
                  // Background fade
                  Container(
                    color: Colors.black.withOpacity(_splashController.value * 0.3),
                  ),
                  // Expanding icon
                  Positioned(
                    left: position.dx + size.width/2,
                    top: position.dy + size.height/2,
                    child: Transform.translate(
                      offset: Offset(-_splashScaleAnimation.value/2, -_splashScaleAnimation.value/2),
                      child: Opacity(
                        opacity: _splashFadeAnimation.value,
                        child: Container(
                          width: _splashScaleAnimation.value,
                          height: _splashScaleAnimation.value,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_splashScaleAnimation.value),
                          ),
                          child: Center(
                            child: Icon(
                              _selectedIcon,
                              color: _selectedIconColor,
                              size: 40 * (_splashScaleAnimation.value/50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_splashOverlay!);

    try {
      // Start splash animation
      await _splashController.forward(from: 0);

      if (_isDisposed) return;

      // Remove overlay before navigation
      _removeSplashOverlay();

      // Navigate with custom transition
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                ),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Navigation error: $e');
      }
    } finally {
      if (!_isDisposed) {
        _splashController.reset();
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
                  fontFamily: 'tahoma'
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildListItem(
                      icon: Icons.supervisor_account,
                      title: "Management Approval",
                      count: pendingMngtApproval,
                    ),
                    const SizedBox(height: 12),
                    _buildListItem(
                      icon: Icons.touch_app_rounded,
                      title: "Leave Approval",
                      count: pendingLeave,
                    ),
                    const SizedBox(height: 12),
                    _buildListItem(
                      icon: Iconsax.level,
                      title: "Leave Application",
                      count: null,
                    ),
                    const SizedBox(height: 12),
                    _buildListItem(
                      icon: Icons.calendar_month_outlined,
                      title: "Monthly Attendance",
                      count: null,
                    ),
                    const SizedBox(height: 12),
                    _buildListItem(
                      icon: Icons.attach_money,
                      title: "Download Payslip",
                      count: null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String? count,
  }) {
    final iconKey = GlobalKey();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            Widget page;
            switch(title) {
              case "Management Approval":
                page = const ManagementApproval(title: 'ESS-Management Approval');
                break;
              case "Leave Approval":
                page = const LeaveApproval(title: 'ESS- Leave Approval');
                break;
              case "Leave Application":
                page = const LeaveApplication(title: "ESS-Leave Application History");
                break;
              case "Monthly Attendance":
                page = const MonthlyAttendance();
                break;
              case "Download Payslip":
                page = const DownloadPayslip();
                break;
              default:
                page = Container();
            }
            _navigateWithSplashAnimation(
              context,
              page,
              icon,
              Colors.grey[700]!,
              iconKey,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  key: iconKey,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
        if (count != null && count != "")
          Positioned(
            top: -12,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}