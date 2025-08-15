import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class RunProcedures extends StatefulWidget {
  const RunProcedures({super.key});

  @override
  State<RunProcedures> createState() => _RunProceduresState();
}

class _RunProceduresState extends State<RunProcedures> with TickerProviderStateMixin {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  late List<dynamic> globalData = [];
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  bool _isLoading = false; // Track loading state
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
    _fromDateController.text = _formatDate(_selectedFromDate);
    _toDateController.text = _formatDate(_selectedToDate);
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
    var shortText = 'Procedures';

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
          _currentMaxLength = 'Procedures'.length;
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

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate,
      firstDate: DateTime(2023, 9, 16), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Theme.of(context).colorScheme.secondary,
              surface: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              onSurface: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
        _fromDateController.text = _formatDate(_selectedFromDate);
        print(_fromDateController.text);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate,
      firstDate: DateTime(2023, 9, 16), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Theme.of(context).colorScheme.secondary,
              surface: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              onSurface: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
        _toDateController.text = _formatDate(_selectedToDate);
        print(_toDateController.text);
      });
    }
  }

  Future<void> _runProcedure(String type) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final String apiUrl =
        '${TBaseURL.baseUrl}get_procedure?type=$type&from_date=${_fromDateController.text}&to_date=${_toDateController.text}';
    print(apiUrl);

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 600));

      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Access the first element in the list and get 'type'
        if (responseData.isNotEmpty && responseData[0] is Map) {
          final String type = responseData[0]['type']?.toString() ?? '';
          print(type);
          _showSuccessDialog(type);
        } else {
          _showErrorDialog('Unexpected data format');
        }
      } else {
        // Show error dialog if there was an issue
        _showErrorDialog('Failed to run procedure');
      }
    } on TimeoutException catch (_) {
      _showErrorDialog('Request timed out. Please try again later.');
    } catch (e) {
      _showErrorDialog('Some error occurred while running the procedure');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }


  void _showSuccessDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
          title: Text('Procedure Status',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text('$type Procedure run successfully!',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.5),
          title: Text('Error',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          content: Text(message,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
            ),
          ],
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    // return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            controller: _fromDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              suffixIcon:  Icon(Icons.date_range_outlined,color: Theme.of(context).colorScheme.secondary,),
                            ),
                            onTap: () {
                              _selectFromDate(context);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0), // Space between fields
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            controller: _toDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              suffixIcon: Icon(Icons.date_range_outlined,color: Theme.of(context).colorScheme.secondary,),
                            ),
                            onTap: () {
                              _selectToDate(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _isLoading ? const Center(
                    child: LottieLoading(animationPath: 'assets/animation/alocationLoading.json',size: 300,)
                ) :
                Column(
                  children: [
                _buildSimpleButton('Employee Cost', Colors.blue, () {
                  _runProcedure('EmployeeCost');
                },),
                _buildSimpleButton('Cutting & Finish', Colors.green,  ()
                {
                  _runProcedure('CutFinishPnL');
                }
                ,),
                _buildSimpleButton('Stitching', Colors.red, () {
                  _runProcedure('StitchPnL');
                },),
                _buildSimpleButton('Auto Allocation', Colors.orange, () {
                  _runProcedure('StitchPnLAuto');
                },),
                _buildSimpleButton('Runday', Colors.indigo, () {
                  _runProcedure('Runday');
                },),
          ]
      )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSimpleButton(String label, Color color, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () => onTap(),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
