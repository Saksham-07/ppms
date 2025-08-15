import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../ExtraFunction/lottie_loading.dart';
import '../../../ExtraFunction/uuid.dart';
import '../../../Theme/app_theme.dart';
import '../models/appaprovalnewmodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LeaveApproval extends StatefulWidget {
  const LeaveApproval({super.key, required this.title});

  final String title;

  @override
  State<LeaveApproval> createState() => _LeaveApproval();
}

class _LeaveApproval extends State<LeaveApproval> with TickerProviderStateMixin {
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  DateTimeRange selectedDates = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(const Duration(days: 10)));
  final List<String> items = [
    'All',
    'Applied',
    'Approved',
    'Rejected',
  ];
  String? selectedValue = "All";
  var outputFormat = DateFormat('dd-MM-yyyy');
  List<Appaprovalnewmodel> lstAppData = [];
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

  String uuid = '';
  Future<List<Appaprovalnewmodel>>? _futureAppData;

  @override
  void initState() {
    super.initState();
    getUid();
    _futureAppData = getApplicationApprovalSub();
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
    _refreshController.dispose();
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
    const shortText = 'Application Approval';

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
          _currentMaxLength = 'Application Approval'.length;
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
  }

  void _onRefresh() async {
    try {
      setState(() {
        _futureAppData = getApplicationApprovalSub();
      });
      await _futureAppData;
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void approveLeaveApp(String appId, String remarks) async {
    await approveRejectApplication(appId, "Approved", remarks);
  }

  void rejectLeaveApp(String appId, String remarks) async {
    await approveRejectApplication(appId, "Rejected", remarks);
  }

  Future<void> approveRejectApplication(
      String appId, String appStatus, String approvalRemarks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstAppData = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectApplication';
      if (kDebugMode) {
        print('Approving Application Approval of Subordinate: $url');
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "appId": appId,
        "appStatus": appStatus,
        "approvalRemarks": approvalRemarks,
        "deviceId": uuid,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          lstAppData = [];
          selectedValue = "Applied";
          selectedValue = "All";
        });
        await showErrorDialog(context, response.body, Colors.lightBlue);
      } else {
        await showErrorDialog(context, response.body, Colors.redAccent);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> showErrorDialog(BuildContext context, String message, Color color) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: color),
            const SizedBox(width: 8),
            Text("Alert", style: TextStyle(color: color)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        actions: [
          TextButton(
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {
                  _futureAppData = getApplicationApprovalSub();
                });
              });
              Navigator.of(context).pop();
            },
            child: const Text("OK", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  showConfirmDialog(String message, String appId, int appType) async {
    String remarks;
    bool isAccept = false;
    if (appType == 1) {
      remarks = "Approved By Mobile Application";
      isAccept = true;
    } else {
      remarks = "Rejected By Mobile Application";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Confirmation Leave Approval",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).primaryColor,
                hintText: isAccept
                    ? 'Approved By Mobile Application'
                    : 'Rejected By Mobile Application',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
                labelText: "Enter Remarks",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              onChanged: (value) {
                remarks = value;
              },
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor
                ),
                onPressed: () {
                  if (remarks.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Remarks cannot be empty.")),
                    );
                    return;
                  }
                  if (appType == 1) {
                    approveLeaveApp(appId, remarks);
                  } else if (appType == 2) {
                    rejectLeaveApp(appId, remarks);
                  }
                  Navigator.of(context).pop();
                },
                child: Text("Yes", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<Appaprovalnewmodel>> getApplicationApprovalSub() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstAppData = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetApplicationApprovalSub';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "dFrom": "2024-06-11",
        "dTo": "2024-06-22",
        "appStatus": selectedValue
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          lstAppData.add(Appaprovalnewmodel.fromJson(i));
        }
        return lstAppData;
      } else {
        return lstAppData;
      }
    } catch (e) {
      rethrow;
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
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
        enablePullUp: false,
        header: ClassicHeader(
          idleText: 'Pull down to refresh',
          releaseText: 'Release to refresh',
          refreshingText: 'Refreshing...',
          completeText: 'Refresh complete',
          failedText: 'Refresh failed',
          textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: _futureAppData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LottieLoading(size: 300,animationPath: 'assets/animation/essLoading.json',);
                    } else if (snapshot.hasError) {
                      return Center(
                        child: SizedBox(
                          height: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const LottieLoading(size: 300,animationPath: 'assets/animation/error.json'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Please Reload the page or check after some time',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,),
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || lstAppData.isEmpty) {
                      return Center(
                        child: SizedBox(
                          height: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const LottieLoading(size: 300,animationPath: 'assets/animation/noData.json',),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No Application Found for Approval',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                  textAlign: TextAlign.center,),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: lstAppData.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            color: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow(
                                          "Emp. Name", lstAppData[index].employeename!),
                                      Divider(height: 16, thickness: 0.5,color: Colors.grey[300],),
                                      _buildInfoRow(
                                          "App Type", lstAppData[index].apptype!),
                                      Divider(height: 16, thickness: 0.5,color: Colors.grey[300],),
                                      _buildInfoRow("App. Period",
                                          "${lstAppData[index].fromdt} - ${lstAppData[index].todt}"),
                                      Divider(height: 16, thickness: 0.5,color: Colors.grey[300],),
                                      _buildInfoRow("Duration",
                                          "${lstAppData[index].dayscount.toString()} Days"),
                                      Divider(height: 16, thickness: 0.5,color: Colors.grey[300],),
                                      _buildInfoRow(
                                          "Remarks", lstAppData[index].appremarks!),
                                    ],
                                  ),
                                ),
                                Container(width: double.infinity,height: 1,color: Colors.grey[300],),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildBottomTextButton(
                                          text: "APPROVE",
                                          value: 'approve',
                                          color: Colors.green,
                                          icon: Icons.check_circle_outline,
                                          onPressed: () {
                                            showConfirmDialog(
                                              "Are you sure you want to Approve",
                                              lstAppData[index].appid.toString(),
                                              1,
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 48,
                                        color: Colors.grey[300],
                                      ),
                                      Expanded(
                                        child: _buildBottomTextButton(
                                          text: "REJECT",
                                          value: 'reject',
                                          color: Colors.red,
                                          icon: Icons.cancel_outlined,
                                          onPressed: () {
                                            showConfirmDialog(
                                              "Are you sure you want to Reject",
                                              lstAppData[index].appid.toString(),
                                              2,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTextButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    required IconData icon,
    required String value,
  }) {
    final isDarkMode = Theme.of(context).brightness;
    return SizedBox(
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isDarkMode == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: value == 'approve' ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight: value == 'reject' ? const Radius.circular(12) : const Radius.circular(0),
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}