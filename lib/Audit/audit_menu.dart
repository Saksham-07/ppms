import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/Audit/El_Audit/end_line_new.dart';
import 'package:ppms/Audit/Finishing_audit/finish_audit_report.dart';
import 'package:ppms/Audit/Sampling/sampling_selection.dart';
import 'package:ppms/Audit/Sewing_Audit/sewing_audit_report.dart';
import 'package:ppms/Audit/Sewing_Audit/sewing_audit_selection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';
import 'El_Audit/AuditHourly/el_hourly_report.dart';
import 'El_Audit/el_audit_report.dart';
import 'El_Audit/end_line.dart';
import 'El_Audit/end_line_test.dart';

import 'package:http/http.dart' as http;

import 'Finishing_audit/finish_audit_selection.dart';

class AuditMenu extends StatefulWidget {
  const AuditMenu({super.key});

  @override
  State<AuditMenu> createState() => _AuditMenuState();
}

class _AuditMenuState extends State<AuditMenu>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String appVersion = '';
  String? id;
  bool isLineIdPresent = false;
  bool _isAllocation = false;bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
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
    _checkLineId(); // Check for line_id when the widget is initialized
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
    var shortText = 'Audit';

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
          _currentMaxLength = 'Audit'.length;
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

  Future<bool> checkRights(String mod, String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=$mod&page=$page';
    if (kDebugMode) {
      print(url);
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isAllocation = data.any((item) => item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isAllocation);
        }
      });
      if(_isAllocation){
        return true;
      }
      else{
        return false;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showNoRightsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You do not have the rights to access this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to check if line_id exists in SharedPreferences
  Future<void> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lineId = prefs.getString('line_id');
    setState(() {

    id = prefs.getString('login_id');
    });
    // Fetch the line_id as an int
    if (lineId != '') {
      setState(() {
        isLineIdPresent = true; // Set to true if line_id exists
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
            // if (loginId == '0552482' || loginId == '0552297')
            //   Padding(
            //     padding: const EdgeInsets.all(14.0),
            //     child: GestureDetector(
            //         onTap: () {
            //           _showSearchDialog(context);
            //         },
            //         child: const SizedBox(
            //           width: 50,
            //           height: 50,
            //           child: Text(
            //             '.',
            //             style: TextStyle(color: Color(0xFF5FE3D3)),
            //           ),
            //         )),
            //   ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return CupertinoSwitch(
                  activeTrackColor: Colors.indigo.shade400,
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return const Icon(
                            Icons.mode_night_rounded,
                            color: Colors.white,
                          );
                        }
                        return const Icon(Icons
                            .sunny); // All other states will use the default thumbIcon.
                      }),
                  thumbColor: themeProvider.themeMode != ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
          ],
        ),
        key: scaffoldKey,
        body: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 2),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount:
                        _getVisibleItems().length,
                        itemBuilder: (context, index) {
                          final item =
                          _getVisibleItems()[index];
                          return GestureDetector(
                            onTap: item.onTap,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiary,
                                borderRadius:
                                BorderRadius.circular(
                                    16),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: [
                                  Image.asset(
                                    item.imagePath,
                                    height: 60,
                                    color: Colors.lightBlue[400],),
                                  const SizedBox(
                                      height: 10),
                                  Text(item.label,
                                      style: TextStyle(
                                          color: Theme.of(
                                              context)
                                              .colorScheme
                                              .secondary)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 40,
                                    height: 3,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary, // soft orange accent bar
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Item> _getVisibleItems() {
    final items = <Item>[];

    if (isLineIdPresent) {
      items.add(
        Item(
          imagePath: 'assets/images/clean.png',
          label: 'End Line Audit',
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditPage(),
              ),
            );
          },
        ),
      );
    }

    if (id == '0552482' || id == '0552445' || id == '0552297' ||
        id == '0551723') {
      items.add(
        Item(
          imagePath: 'assets/images/clean.png',
          label: 'End Line Audit Test',
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditTestPage(),
              ),
            );
          },
        ),
      );
    }

    items.add(
      Item(
        imagePath: 'assets/images/sale-report.png',
        label: 'EL Audit Report',
        onTap: () async {
          if (await checkRights('MobileApplication', 'MobileAuditReport')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditELReport(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

    items.add(
      Item(
        imagePath: 'assets/images/sale-report.png',
        label: 'EL Hourly Report',
        onTap: () async {
          if (await checkRights('MobileApplication', 'MobileAuditReport')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HourlyReportPage(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

      items.add(
        Item(
          imagePath: 'assets/images/fashion.png',
          label: 'Sewing Audit',
          onTap: () async {
            if (await checkRights('MobileApplication', 'MobileSewingAudit')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SewingAuditSelection(),
                ),
              );
            }
            else {
              _showNoRightsDialog();
            }
          },
        ),
      );

      items.add(
        Item(
          imagePath: 'assets/images/fashion.png',
          label: 'Sewing Audit Report',
          onTap: () async {
            if (await checkRights(
                'MobileApplication', 'MobileSewingAuditReport')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SewingReportPage(),
                ),
              );
            }
            else {
              _showNoRightsDialog();
            }
          },
        ),
      );

    items.add(
      Item(
        imagePath: 'assets/images/trade-show.png',
        label: 'Finish Audit',
        onTap: () async {
          if (await checkRights(
              'MobileApplication', 'MobileFinishingAudit')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinishingAuditSelection(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

    items.add(
      Item(
        imagePath: 'assets/images/trade-show.png',
        label: 'Finish Audit Report',
        onTap: () async {
          if (await checkRights(
              'MobileApplication', 'MobileFinishAuditReport')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FinishReportPage(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

    if(id == '0552482' || id == '0552445' || id == '0552297' || id == '0551723') {
      items.add(
        Item(
          imagePath: 'assets/images/fashion.png',
          label: 'Sampling Audit',
          onTap: () async {
            if (await checkRights(
                'MobileApplication', 'MobileSamplingAudit')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SamplingAuditSelection(),
                ),
              );
            }
            else {
              _showNoRightsDialog();
            }
          },
        ),
      );
    }

    return items;
  }
}
class Item {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  Item({required this.imagePath, required this.label, required this.onTap});
}
