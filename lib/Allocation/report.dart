import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class Report extends StatefulWidget {
  final String? selectedUnit;

  const Report({Key? key, this.selectedUnit}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<Report> with TickerProviderStateMixin {
  String? _selectedUnit;
  List<Map<String, dynamic>> _pendingAllocData = [];
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  bool _isLoading = false;bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
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
    _fetchDropDownOptions();
    _selectedUnit = widget.selectedUnit;
    Future.delayed(Duration(milliseconds: 200), () {
      if (_selectedUnit != null) {
        _fetchPendingAllocData(_unitMap[_selectedUnit]!);
      }
    });
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
    var shortText = 'Unallocated Persons';

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
          _currentMaxLength = 'Unallocated Persons'.length;
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

  void runFunction() async{
    await _fetchDropDownOptions();
    _selectedUnit = widget.selectedUnit;
    Future.delayed(Duration(milliseconds: 200), () async {
      if (_selectedUnit != null) {
        await _fetchPendingAllocData(_unitMap[_selectedUnit]!);
      }
    });
  }

  Future<void> _fetchDropDownOptions() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final String? _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _dropDownOptions = data.map((e) => e['UnitShortCode1'].toString()).toList();
          _unitMap = {for (var item in data) item['UnitShortCode1'].toString(): item['UnitCode'].toString()};
          _selectedUnit = widget.selectedUnit ?? (_dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null);
        });
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load options: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPendingAllocData(String unitCode) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${TBaseURL.baseUrl}pending_mnpwr_vg?unit=$unitCode'));
      print('${TBaseURL.baseUrl}pending_mnpwr_vg?unit=$unitCode');
      if (response.statusCode == 200) {
        setState(() {
          _pendingAllocData = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      if (kDebugMode) print('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.grey[800]!;
    final Color accentColor = isDark ? Colors.tealAccent : Colors.indigo;

    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          // Unit Selection Card
          Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildSearchableDropdown(
              context: context,
              label: 'Select Unit',
              value: _selectedUnit,
              items: _dropDownOptions,
              onChanged: (newValue) {
                setState(() => _selectedUnit = newValue);
                if (newValue != null) {
                  _fetchPendingAllocData(_unitMap[newValue]!);

                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Data Table Card
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? const Center(child: LottieLoading(animationPath: 'assets/animation/alocationLoading.json',size: 250,))
                  : _pendingAllocData.isEmpty
                  ? const Center(
                child: LottieLoading(animationPath: 'assets/animation/allNoData.json',size: 250,)
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                    columnWidths: const {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(2.5),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(3),
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      // Table Header
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                        ),
                        children: [
                          _buildTableHeaderCell(''),
                          _buildTableHeaderCell('Pay\nCode'),
                          _buildTableHeaderCell('Emp\nCode'),
                          _buildTableHeaderCell('Name'),
                          _buildTableHeaderCell('Desg'),
                        ],
                      ),
                      // Table Rows
                      ..._pendingAllocData.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        var item = entry.value;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? cardColor.withOpacity(0.5)
                                : cardColor,
                          ),
                          children: [
                            _buildTableCell(index.toString()),
                            _buildTableCell(item['PAY_CODE'].toString()),
                            _buildTableCell(item['EMP_CODE'].toString()),
                            _buildTableCell(
                              item['NAME'] != null && item['NAME']!.length > 12
                                  ? '${item['NAME']!.substring(0, 12)}..'
                                  : item['NAME'] ?? '',
                            ),
                            _buildTableCell(item['DesignationName'].toString()),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField2<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ))
          .toList(),
      onChanged: onChanged,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 14,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
        ),
      ),
      dropdownSearchData: DropdownSearchData(
        searchController: TextEditingController(),
        searchInnerWidgetHeight: 50,
        searchInnerWidget: Container(
          height: 50,
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 4,
            right: 8,
            left: 8,
          ),
          child: TextFormField(
            cursorColor: Theme.of(context).colorScheme.secondary,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              hintText: 'Search...',
              hintStyle: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            style: TextStyle(
              fontSize: 12,
            )
          ),
        ),
        searchMatchFn: (item, searchValue) {
          return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
        },
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 13,color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
