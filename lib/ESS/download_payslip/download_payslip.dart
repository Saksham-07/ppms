import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ppms/ESS/download_payslip/test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Theme/app_theme.dart';

class DownloadPayslip extends StatefulWidget {
  const DownloadPayslip({super.key});

  @override
  State<DownloadPayslip> createState() => _DownloadPayslipState();
}

class _DownloadPayslipState extends State<DownloadPayslip> with TickerProviderStateMixin{
  int? _selectedMonth;
  int? _selectedYear;
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

  final List<Map<String, dynamic>> _months = [
    {'name': 'January', 'value': 01},
    {'name': 'February', 'value': 02},
    {'name': 'March', 'value': 03},
    {'name': 'April', 'value': 04},
    {'name': 'May', 'value': 05},
    {'name': 'June', 'value': 06},
    {'name': 'July', 'value': 07},
    {'name': 'August', 'value': 08},
    {'name': 'September', 'value': 09},
    {'name': 'October', 'value': 10},
    {'name': 'November', 'value': 11},
    {'name': 'December', 'value': 12},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    final now = DateTime.now();
    _selectedYear = now.year;

    // Apply your condition: before 7th shows previous month
    if (now.day < 7) {
      _selectedMonth = now.month == 1 ? 12 : now.month - 2;
      // Adjust year if we wrapped to previous year
      if (now.month == 1) {
        _selectedYear = now.year - 1;
      }
    } else {
      _selectedMonth = now.month;
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
    var shortText = 'Payslip';

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
          _currentMaxLength = 'Payslip'.length;
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

  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

  // void navigateToReport(BuildContext context) {
  //   if (_selectedMonth == null || _selectedYear == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please select both month and year')),
  //     );
  //     return;
  //   }
  //
  //   String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DownloadPayslipView(
  //         month: formattedMonth,
  //         year: _selectedYear,
  //       ),
  //     ),
  //   );
  // }

  Future<void> _launchPayslipWebpage() async {
    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both month and year')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('login_id') ?? '';
    final formattedMonth = _selectedMonth!.toString().padLeft(2, '0');

    // Replace with your actual payslip web URL
    final payslipUrl = 'https://your-payslip-website.com/payslip?'
        'user_id=$userId&month=$formattedMonth&year=$_selectedYear';

    if (await canLaunchUrl(Uri.parse(payslipUrl))) {
      await launchUrl(
        Uri.parse(payslipUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch payslip webpage')),
      );
    }
  }

  Future<void> _fetchPayslip() async {
    if (_selectedMonth == null || _selectedYear == null) {
      return;
    }

    // Your download logic here
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('login_id');

    // Add actual download implementation
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month and Year Dropdowns
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<int>(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary
                      ),
                      decoration: InputDecoration(
                        iconColor: Theme.of(context).colorScheme.secondary,
                        labelText: 'Month',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary
                        ),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                      ),
                      value: _selectedMonth,
                      items: _months.map((month) {
                        return DropdownMenuItem<int>(
                          value: month['value'],
                          child: Text(month['name']),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedMonth = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<int>(
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary
                        ),
                        border: OutlineInputBorder(),
                        iconColor: Theme.of(context).colorScheme.secondary,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                      ),
                      value: _selectedYear,
                      items: _years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedYear = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Download Button (removed as per your request)
                  // View Button
                  AnimatedBuilder(
                    animation: _scaleController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800], // Dark grey color
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            side: BorderSide(
                              color: Colors.grey[700]!,
                              width: 1,
                            ),
                          ),
                          onPressed: () {
                            _scaleController.forward();
                            _launchPayslipWebpage();
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Payslip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}