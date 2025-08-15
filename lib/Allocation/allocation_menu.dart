import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/Allocation/allocation.dart';
import 'package:ppms/Allocation/manpower_verify.dart';
import 'package:ppms/Allocation/verification_report_all.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';
import 'ot_vertification.dart';

class AllocationMenu extends StatefulWidget {
  const AllocationMenu({super.key});

  @override
  State<AllocationMenu> createState() => _AllocationMenu();
}

class _AllocationMenu extends State<AllocationMenu>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String appVersion = '';
  bool isLineIdPresent = false;
  bool _isAllocation = false;
  bool _isVerify = false,isZooming = false;
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
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    _lottieController = AnimationController(vsync: this);
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
    var shortText = 'Line Allocation';

    final newText = _showFullTitle
        ? fullText.substring(0, _typingAnimation.value)
        : shortText!.substring(0, _typingAnimation.value.clamp(0, shortText.length));

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
          _currentMaxLength = 'Line Allocation'.length;
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

  Future<bool> checkForAllocate(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=kpi&page=$page';
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}base?user=$loginId&module=kpi&page=LineAllocation');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isAllocation = data.any((item) => item['shortname'] == 'W' || item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isAllocation);
        }
      });
      return _isAllocation;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> verifyManpower(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=$page';
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=ManpowerVerification');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isVerify = data.any((item) => item['shortname'] == 'W' || item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isVerify);
        }
      });
      return _isVerify;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showNoRightsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Access Denied', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        content: Text('You do not have the rights for $title.', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
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
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          16, 2, 16, 2),
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
    );
  }

  List<Item> _getVisibleItems() {
    return [
      Item(
        imagePath: 'assets/images/allocation.png',
        label: 'Allocation',
        onTap: () async {
          if (await checkForAllocate('LineAllocation')) {
            _playZoomAnimationAndNavigate('assets/images/allocation.png',
                const Allocation(), 'Welcome to Line Allocation');
          } else {
            _showNoRightsDialog('Line Allocation');
          }
        },
      ),
      Item(
        imagePath: 'assets/images/check-mark.png',
        label: 'Manpower Verification',
        onTap: () async {
          if (await verifyManpower('ManpowerVerification')) {
            _playZoomAnimationAndNavigate('assets/images/check-mark.png',
                const ManpowerVerify(), 'Welcome to Manpower Verification');
          } else {
            _showNoRightsDialog('Manpower Verification');
          }
        },
      ),
      Item(
        imagePath: 'assets/images/clipboard.png',
        label: 'Allocation Report',
        onTap: () async {
          if (await verifyManpower('ManpowerVerification')) {
            _playZoomAnimationAndNavigate('assets/images/clipboard.png',
                const VerificationReportAll(), 'Welcome to Verification Report');
          } else {
            _showNoRightsDialog('Manpower Report');
          }
        },
      ),
      Item(
        imagePath: 'assets/images/overtime.png',
        label: 'OT Verification',
        onTap: () async {
          if (await verifyManpower('OTApproval')) {
            _playZoomAnimationAndNavigate('assets/images/overtime.png',
                const LinewiseOTVerification(), 'Welcome to OT Verification');
          } else {
            _showNoRightsDialog('OT Verification');
          }
        },
      ),
    ];
  }
  void _playZoomAnimationAndNavigate(
      String imagePath, Widget nextPage, String text) async {
    setState(() {
      isZooming = true;
    });
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.white,
          child: _DelayedZoom(
            imagePath: imagePath,
            text: text,
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 500));

    overlayEntry.remove();

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: nextPage,
            ),
          );
        },
      ),
    );

    setState(() => isZooming = false);
  }
}

class Item {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  Item({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });
}

class _DelayedZoom extends StatefulWidget {
  final String imagePath;
  final String text;

  const _DelayedZoom({required this.imagePath, required this.text});

  @override
  State<_DelayedZoom> createState() => _DelayedZoomState();
}

class _DelayedZoomState extends State<_DelayedZoom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Delay the start of the animation by one frame (to let white background paint)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Image.asset(
                widget.imagePath,
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.contain,
                color: Colors.lightBlue[400],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              widget.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: 'Tahoma',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}