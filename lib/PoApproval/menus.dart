import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/PoApproval/po_approvals.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class PoApprovalMenus extends StatefulWidget {
  final Map<String, dynamic> fetchedCounters;
  const PoApprovalMenus({super.key, required this.fetchedCounters});

  @override
  State<PoApprovalMenus> createState() => _PoApprovalMenusState();
}

class _PoApprovalMenusState extends State<PoApprovalMenus> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _poApprovalList = [];
  Map<String, List<Map<String, dynamic>>> groupedMenuItems = {};
  Map<String, int> submenuCounters = {};
  int _expandedTileIndex = -1;
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
    _permData();
    Future.delayed(const Duration(milliseconds: 200), () {
      updateCounters();
    });
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    super.initState();
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
    var shortText = 'PO Approval';

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
          _currentMaxLength = 'PO Approval'.length;
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

  Future<void> updateCounters() async {
    try {
      submenuCounters = widget.fetchedCounters.map((key, value) =>
          MapEntry(key, int.tryParse(value.toString()) ?? 0));
      print('Updated submenuCounters: $submenuCounters');
    } catch (e) {
      print('Error updating counters: $e');
    }
  }

  void _navigatePoApproval(BuildContext context, String approvalFor, String pageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PoApproval(approvalFor: approvalFor, pageName: pageName)
      ),
    );
  }

  Future<void> _permData() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}menu_rights?user=$loginId&page=PoApprovals';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> poApprovalList = json.decode(response.body);

      setState(() {
        _poApprovalList = List<Map<String, dynamic>>.from(poApprovalList);
        int i = 0;
        for (var item in _poApprovalList) {
          String menuType = item['MenuType'];
          if (!groupedMenuItems.containsKey(menuType)) {
            groupedMenuItems[menuType] = [];
            i++;
          }
          item['index'] = i;
          groupedMenuItems[menuType]?.add(item);
        }
        log('$groupedMenuItems');
      });
    } else {
      throw Exception('Unable to get permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:  Theme.of(context).primaryColor,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groupedMenuItems.entries.map((entry) {
          return _buildExpandableCard(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildExpandableCard(String title, List<Map<String, dynamic>> subMenus) {
    bool isExpanded = _expandedTileIndex == subMenus[0]['index'];
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withValues(alpha: 0.2),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[400]!, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
            ),
            onTap: () {
              setState(() {
                _expandedTileIndex = isExpanded ? -1 : subMenus[0]['index'];
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: isExpanded ? null : 0,
              child: Column(
                children: subMenus.map((menu) {
                  String menuCode = menu['MenuCode'];
                  int counter = submenuCounters[menuCode] ?? 0;

                  return _buildMenuItem(
                    title: menu['Name'].toString(),
                    counter: counter,
                    onTap: () => _navigatePoApproval(
                        context,
                        menu['Name'].toString(),
                        menu['MenuCode'].toString()
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required int counter,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        clipBehavior: Clip.none, // Allows the badge to overflow
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[400]!, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Theme.of(context).cardColor,
            title: Align(
              alignment: Alignment.topCenter,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            onTap: onTap,
          ),
          if (counter > 0)
            Positioned(
              right: -4, // Adjust position as needed
              top: -8,   // Adjust position as needed
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    counter.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounterBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}