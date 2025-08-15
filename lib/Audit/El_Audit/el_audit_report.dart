import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Theme/app_theme.dart';
import '../../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'elAuditReportTable.dart';

class AuditELReport extends StatefulWidget {
  const AuditELReport({super.key});

  @override
  State<AuditELReport> createState() => _AuditELReportState();
}

class _AuditELReportState extends State<AuditELReport> with TickerProviderStateMixin {
  String? _loginId;
  List<String> _dropDownOptions = [];
  String? selectedLineID;
  List<Map<String, String>> dropdownData3 = [];
  String? selectedValue3;
  String? selectedValue4;
  List<String> dropdownData5 = [];
  String? previousValue;
  String? _selectedUnit;
  List<Map<String, dynamic>> _tableData = [];
  late List<dynamic> globalData = [];
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  late Future<List<String>> futureUnits;
  List<dynamic> dataMap = [];
  int? lineId = 0;
  String? line = '';
  String? date;
  String? _selectedMonth;
  final Map<String, String> _monthValues = {};
  List<String> _months = [];
  bool isChecked =  true;
  bool isLineWise = false;bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
      _fromDateFocused = false,_toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,_backButtonController,_scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;
  bool _showLine = false;

  @override
  void initState() {
    super.initState();
    _fetchDropDownOptions();
    _generateMonthValues();
    _fromDateController.text = _formatDate(fromDate);
    _toDateController.text = _formatDate(toDate);
    Future.delayed(const Duration(milliseconds: 800),(){
      _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
    });
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
    var shortText = 'End Line Audit';

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
          _currentMaxLength = 'EL Audit Report'.length;
          _showLine = true;
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

  void _generateMonthValues() {
    final now = DateTime.now();
    final year = now.year;
    final currentMonthIndex = now.month - 1;
    // Generate months with formatted values
    _months = List.generate(12, (index) {
      final monthName = DateFormat.MMMM().format(DateTime(year, index + 1)).substring(0,3);
      final firstDate = DateFormat('yyyy-MM-dd').format(DateTime(year, index + 1, 1));
      final lastDate = DateFormat('yyyy-MM-dd').format(DateTime(year, index + 2, 0));
      _monthValues[monthName] = '$firstDate, $lastDate';
      if (index == currentMonthIndex) {
        setState(() {
          _selectedMonth = monthName;
        });
      }
      return monthName;
    });
  }

  Future<void> _selectDate(BuildContext context , bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2022, 1, 1), // 16-Sep-2024
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
    if (picked != null && picked != fromDate) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          _fromDateController.text = _formatDate(fromDate);
        } else {
          toDate = picked;
          _toDateController.text = _formatDate(toDate);
        }
      });
      _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString()
        .padLeft(2, '0')}-${date.year}';
  }

  String _formatDate2(DateTime date) {
    return '${date.year}-${date.month.toString()
        .padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchTableData(String fromDate , String toDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lineId = prefs.getInt('line_ids');
    line = prefs.getString('line_name');
    String? unit = selectedValue4;
    String wise = isChecked ? 'datewise' : 'summary';
    if(!isChecked && isLineWise){
      wise = 'linewise_summary';
    }
    if (kDebugMode) {
      print(wise);
    }
    DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await http.get(Uri.parse('${TBaseURL.auditUrl}el_report?fromDate=$toDate&toDate=$fromDate&unit=$unit&line=$lineId&report_type=$wise'));
    // final response = await http.get(Uri.parse('http://172.16.2.168:8001/el_report?fromDate=$fromDate&toDate=$toDate&unit=$unit'));
    if (kDebugMode) {
      print('${TBaseURL.auditUrl}el_report?fromDate=$toDate&toDate=$fromDate&unit=$unit&line=$lineId&report_type=$wise');
    }
    if (response.statusCode == 200){
      final data = json.decode(response.body);
      setState(() {
        _tableData = List<Map<String, dynamic>>.from(data).map((row) {
          // Parse and format the AuditDate
          if (row.containsKey('AuditDate') && row['AuditDate'] != null) {
            try {
              DateFormat inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
              DateFormat outputFormat = DateFormat('dd-MM-yy');
              DateTime parsedDate = inputFormat.parse(row['AuditDate']);
              String formattedDate = outputFormat.format(parsedDate);
              row['AuditDate'] = formattedDate; // Update the AuditDate field
            } catch (e) {
              print('Error parsing date: ${row['AuditDate']}');
            }
          }
          return row;
        }).toList();
        if (kDebugMode) {
          print(_tableData);
        }
      });
    } else {
      throw Exception('Failed to load table data');
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions = data.map((e) => e['UnitShortCode'].toString()).toList();

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
          selectedValue4 = _selectedUnit;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
          selectedValue4 = _selectedUnit;
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('${TBaseURL.baseUrl}line?unit=$unit&ot=0'));
        // final response = await http.get(Uri.parse('http://172.16.10.11:8001/line?unit=$unit&ot=$ot'));
        if (kDebugMode) {
          print('${TBaseURL.baseUrl}line?unit=$unit&ot=0');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) => {
              'LineName': item['LineName'].toString(),
              'LineID': item['LineId'].toString(),
            }).toList();
          });
          success = true; // Data successfully fetched, exit loop
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('Error fetching data (Attempt $retryCount): $e');
        }
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }

      await Future.delayed(const Duration(seconds: 2)); // Optional delay between retries
    }
  }


  int _calculateTotal(String field) {
    return _tableData.fold(0, (sum, item) {
      int value = int.tryParse(item[field]?.toString() ?? '0') ?? 0;
      return sum + value;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalPassQty = _calculateTotal('PassQty');
    int totalRejectQty = _calculateTotal('RejectQty');
    int totalDefectQty = _calculateTotal('DefectQty');
    int totalRectQty = _calculateTotal('RectifiedQty');
    int totalAuditQty = _calculateTotal('AuditQty');
    int totalBalQty = _calculateTotal('BalanceQty');
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
            // if(_showLine)
            // Padding(
            //   padding: const EdgeInsets.all(14.0),
            //   child: GestureDetector( // Wrap with GestureDetector for onTap functionality
            //     onTap: () async {
            //       bool shouldRefresh = await showDialog(
            //         context: context,
            //         builder: (BuildContext context) {
            //           return AlertDialog(
            //             title: const Text('Confirm Refresh'),
            //             content: const Text('Are you sure you want to refresh the page?'),
            //             actions: [
            //               TextButton(
            //                 onPressed: () {
            //                   Navigator.of(context).pop(false); // Cancel refresh
            //                 },
            //                 child: const Text('No'),
            //               ),
            //               TextButton(
            //                 onPressed: () {
            //                   Navigator.of(context).pop(true); // Confirm refresh
            //                 },
            //                 child: const Text('Yes'),
            //               ),
            //             ],
            //           );
            //         },
            //       );
            //
            //       if (shouldRefresh) {
            //         Navigator.pushReplacement(
            //           context,
            //           MaterialPageRoute(
            //             builder: (BuildContext context) => widget,
            //           ),
            //         );
            //       }
            //     },
            //     child: Text(
            //       '$line',
            //       style: const TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: isChecked ? 4 : 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.secondary), // Border color
                              borderRadius: BorderRadius.circular(4.0), // Rounded corners
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0), // Padding inside the border
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                itemBuilder: (context, item, isSelected) {
                                  return Container(
                                    color: isSelected
                                        ? Colors.orange // Optional: highlight selected item
                                        : Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary, // Text color for all items
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                menuProps: MenuProps(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shadowColor: Colors.grey[400],
                                )
                              ),
                              selectedItem: _selectedUnit,
                              dropdownButtonProps: DropdownButtonProps(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                color: Theme.of(context).colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 1.0),
                              ),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                baseStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                dropdownSearchDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0), // Reduce padding for height adjustment
                                  border: InputBorder.none, // Remove inner border
                                ),
                              ),
                              items: _dropDownOptions,

                              itemAsString: (item) => item, // Display unit names
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValue4 = newValue;
                                  _selectedUnit = newValue;
                                  selectedValue3 = null; // Clear line value
                                  dropdownData3.clear(); // Clear line data
                                });
                                fetchLineDataFromApi(newValue!);
                                _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4, // Adjust position
                          left: 10, // Adjust horizontal position if needed
                          child: Container(
                            color: Theme.of(context).primaryColor, // Background color for label text
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              'Unit',
                              style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.secondary), // Label style
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if(!isChecked)
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children : [
                        Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.secondary),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: DropdownSearch<String>(
                            selectedItem: _selectedMonth,
                            dropdownButtonProps: DropdownButtonProps(
                              icon: const Icon(Icons.keyboard_arrow_down),
                              color: Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 1.0),
                            ),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              baseStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              dropdownSearchDecoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                                border: InputBorder.none,
                              ),
                            ),
                            items: _months,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedMonth = newValue;
                                String? dateRange = _monthValues[newValue];
                                List<String>? dates = dateRange?.split(',');
                                String? startDate = dates?[0].trim();
                                String? endDate = dates?[1].trim();
                                _fetchTableData(startDate!,endDate!);
                              });
                            },
                          ),
                        ),
                      ),
                        Positioned(
                          top: -4, // Adjust position
                          left: 10, // Adjust horizontal position if needed
                          child: Container(
                            color: Theme.of(context).primaryColor, // Background color for label text
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              'Month',
                              style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.secondary), // Label style
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),


                  Expanded(
                    flex: 1,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Checkbox(
                            side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                            activeColor: Colors.orange,
                            checkColor: Colors.white,
                            value: isChecked,
                            onChanged: (bool? value) {
                              _tableData = [];
                              setState(() {
                                isChecked = value ?? false;
                              });
                              if(isChecked){
                                _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                                isLineWise = false;
                              }
                              else {
                                String? dateRange = _monthValues[_selectedMonth];
                                List<String>? dates = dateRange?.split(',');
                                String? startDate = dates?[0].trim();
                                String? endDate = dates?[1].trim();
                                _fetchTableData(startDate!,endDate!);
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: -4, // Adjust position
                          left: 0, // Adjust horizontal position if needed
                          child: Container(
                            color: Theme.of(context).primaryColor, // Background color for label text
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              'Date Wise',
                              style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.secondary), // Label style
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Checkbox(
                            side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                            activeColor: Colors.blue,
                            value: isLineWise,
                            onChanged: (bool? value) {
                              _tableData = [];
                              setState(() {
                                isLineWise = value ?? false;
                              });
                              if(!isLineWise){
                                _fetchTableData(_formatDate2(fromDate),_formatDate2(toDate));
                              }
                              else{
                                isChecked = false;
                                String? dateRange = _monthValues[_selectedMonth];
                                List<String>? dates = dateRange?.split(',');
                                String? startDate = dates?[0].trim();
                                String? endDate = dates?[1].trim();
                                _fetchTableData(startDate!,endDate!);
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: -4, // Adjust position
                          left: 0, // Adjust horizontal position if needed
                          child: Container(
                            color: Theme.of(context).primaryColor, // Background color for label text
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              'Line Wise',
                              style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.secondary), // Label style
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


      const SizedBox(height: 10,),
      Row(

        children: [
          if(isChecked)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                  controller: _fromDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    suffixIcon: Icon(Icons.date_range_outlined,color: Theme.of(context).colorScheme.secondary,),
                  ),
                  onTap: () {
                    _selectDate(context,true);
                  },
                ),
              ),
            ),
          ),

          if(isChecked)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                  controller: _toDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    suffixIcon: Icon(Icons.date_range_outlined,color: Theme.of(context).colorScheme.secondary,),
                  ),
                  onTap: () {
                    _selectDate(context,false);
                  },
                ),
              ),
            ),
          ),


        ],
      ),
      const SizedBox(height: 10,),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width, // Ensures the table spans the full width
              child: CustomDataGrid(
                tableData: _tableData,
                isChecked: isChecked,
                isLineWise: isLineWise,
                totalPassQty: totalPassQty,
                totalRejectQty: totalRejectQty,
                totalDefectQty: totalDefectQty,
                totalRectQty: totalRectQty,
                totalAuditQty: totalAuditQty,
                totalBalQty: totalBalQty,
              ),
            ),
          )
      ]
          )
      )
    );
  }

}


// CustomDataGrid(tableData: _tableData, isChecked: isChecked , isLineWise: isLineWise,
//                  totalPassQty: totalPassQty, totalRejectQty: totalRejectQty,
//                  totalDefectQty: totalDefectQty, totalRectQty: totalRectQty,
//                  totalAuditQty: totalAuditQty, totalBalQty: totalBalQty,)