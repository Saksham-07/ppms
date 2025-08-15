import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VerificationReport extends StatefulWidget {
  const VerificationReport({super.key});

  @override
  State<VerificationReport> createState() => _VerificationReportState();
}

class _VerificationReportState extends State<VerificationReport> with TickerProviderStateMixin {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  List<Map<String, dynamic>> _tableData =
  [];
  int _totalTailor = 0;
  int _totalHelper = 0;
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
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
    _fetchDropDownOptions();
    _dateController.text = _formatDate(selectedDate); // Set initial date
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
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
    var shortText = 'Manpower Verification';

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
          _currentMaxLength = 'Manpower Verification'.length;
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

  Future<void> _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 9, 16),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = _formatDate(selectedDate);
      });
      if (_selectedUnitCode != null) {
        _fetchTableData(_selectedUnitCode!, selectedDate);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month
        .toString()
        .padLeft(2, '0')}-${date.year}';
  }

  //unit
  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
          for (var item in data)
            item['UnitShortCode'].toString(): item['UnitCode'].toString()
        };

        if (_dropDownOptions.isNotEmpty) {
          _selectedUnit = _dropDownOptions[0];
          _selectedUnitCode = _unitMap[_selectedUnit];
          if (kDebugMode) {
            print(selectedDate);
          }
          _fetchTableData(
              _selectedUnitCode!, selectedDate);
          _fetchTotalPresent(_selectedUnitCode!);
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  //manpower verified data
  Future<void> _fetchTableData(String unitCode, DateTime date) async {
    final String url = '${TBaseURL.baseUrl}verify_report_vg?unit=$unitCode&date=$date';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(_tableData);
      setState(() {
        _tableData = data.map((e) =>
        {
          'LineName': e['LineName'],
          'TotalCount': e['TotalCount'],
          'VerifyMnpwr': e['VerifyMnpwr'],
          'Remarks': e['Remarks'],
        }).toList();

        // Initialize the remarks list with empty strings

        _filteredData = List.from(_tableData);
        _totalTailor = _tableData.fold(
            0, (sum, row) => sum + ((row['TotalCount'] ?? 0) as int));
        _totalHelper = _tableData.fold(
            0, (sum, row) => sum + ((row['VerifyMnpwr'] ?? 0) as int));
      });
    }
  }

  void navigateToVerifReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VerificationReport(), //fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }

//Total manpower present vs allocated {Done}
  Future<void> _fetchTotalPresent(String unitCode) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitCode&dated='));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.isNotEmpty) {
            setState(() {
              _allocMnpwr = data[0]['AllocMnpwr'].toString();
              _totalMnpwr = data[0]['TotalMnpwr'].toString();

              if (kDebugMode) {
                print('AllocMnpwr: $_allocMnpwr, TotalMnpwr: $_totalMnpwr');
              }
            });
            success = true;
          }
        } else {
          throw Exception('Failed to load table data');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(Duration(seconds: 1)); // Optional delay between retries
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
        elevation: 2,
      ),
      body:  InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: SizedBox(
                          height: 30,
                          child: DropdownButtonFormField<String>(
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            decoration: InputDecoration(
                              labelText: 'Select Unit',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary),
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary),
                              ),
                              isDense: true, // Reduces the height
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal:
                                  10.0), // Controls the internal padding
                            ),
                            value: _selectedUnit,
                            items: _dropDownOptions.map((String unitShortCode) {
                              return DropdownMenuItem<String>(
                                value: unitShortCode,
                                child: Text(unitShortCode),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue;
                                _selectedUnitCode = _unitMap[newValue!];
                                _fetchTableData(_selectedUnitCode!, selectedDate);
                                _fetchTotalPresent(_selectedUnitCode!);
                              });
                            },
                          ),
                        )),

                    SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        height: 30,
                        child: TextFormField(
                          controller: _dateController,
                          style: TextStyle( color: Theme.of(context).colorScheme.secondary),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                            suffixIcon: const Icon(Icons.date_range_outlined),
                            suffixIconColor: Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () {
                            _selectDate(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 10),
              // TextField(
              //   decoration: InputDecoration(
              //     labelText: 'Search',
              //     border: OutlineInputBorder(),
              //   ),
              //   onChanged: _filterTableData,
              // ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.6),
                      // color: Colors.yellowAccent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Total Manpower Present : $_totalMnpwr" ,textAlign: TextAlign.center, style: TextStyle(
                      // color: Colors.black,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FixedColumnWidth(100),
                        1: FixedColumnWidth(65),
                        2: FixedColumnWidth(60),
                        3: FixedColumnWidth(140),// New column for Remark
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[400]
                          ),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Line',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Total\nAllocated',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Verified\nMnpwr',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Center(
                                  child: Text(
                                    'Remarks',textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                        ..._filteredData.map((row) {
                          _filteredData.indexOf(row);

                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['LineName'],
                          style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary),),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['TotalCount'] ?? 0).toString(),textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['VerifyMnpwr'] ?? 0).toString(),textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text((row['Remarks'] ?? '').toString(),textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightGreen[200],
                          ),
                          children: [
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Total',textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalTailor.toString(),textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _totalHelper.toString(),textAlign: TextAlign.right,
                                  style: const TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    ''
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
            ],
          ),
        ),
      ),
    );
  }
}