import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class VerificationReportAll extends StatefulWidget {
  const VerificationReportAll({super.key});

  @override
  State<VerificationReportAll> createState() => _VerificationReportAllState();
}

class _VerificationReportAllState extends State<VerificationReportAll> with TickerProviderStateMixin {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  List<Map<String, dynamic>> _tableData =
  [];
  late List<dynamic> globalData = [];// To store remarks for each row
  final TextEditingController _dateController = TextEditingController(); // Controller for date field
  DateTime selectedDate = DateTime.now(); // Default to current date
  late Future<List<String>> futureUnits;
  bool noDataFound = false;
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
    _loadLoginIdAndFetchData();
    _fetchDropDownOptions();
    _dateController.text = _formatDate(selectedDate);
    Future.delayed(const Duration(seconds: 16), () {
      if (_tableData.isEmpty) {
        setState(() {
          noDataFound = true;
        });
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
    var shortText = 'Allocation Summary';

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
          _currentMaxLength = 'Allocation Summary'.length;
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
        _dateController.text = _formatDate(selectedDate); // Update the date field
      });

      if (_selectedUnitCode != null) {
        await _fetchTotalPresent(selectedDate);
        Future.delayed(const Duration(milliseconds: 500),() async {
          await _fetchTableData(selectedDate);
        });
      }
      noDataFound = false;
      Future.delayed(const Duration(seconds: 16), () {
        if (_tableData.isEmpty) {
          setState(() {
            noDataFound = true;
          });
        }
      });
    }
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString()
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
          // print(selectedDate);
          loadData();
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> loadData() async{
    await _fetchTotalPresent(selectedDate);
    Future.delayed(const Duration(milliseconds: 500),() async {
      await _fetchTableData(selectedDate);
    });
  }

  Future<void> _loadLoginIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    if (_loginId != null) {
      await fetchUnits();
    }
  }

  //unit for the data
  Future<List<String>> fetchUnits() async {
    final response = await http.get(
        Uri.parse('${TBaseURL.baseUrl}unit_vg?type=lookUpUnit&user='));
    // final response = await http.get(Uri.parse('http://172.16.10.11:8000/unit?type=pnl2&user=$_loginId'));
    print('${TBaseURL.baseUrl}unit_vg?type=lookUpUnit&user=');
    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> units = unitsJson.map((unit) =>
          unit['UnitCode'].toString()).toList();
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> _fetchTableData(DateTime date) async {
    setState(() {
      _tableData = [];
    });
    futureUnits = fetchUnits();
    futureUnits.then((units) async {
      final unitsString = units.join(',');
      final String url = '${TBaseURL.baseUrl}verify_report_vg?unit=$unitsString&date=$date';

      if (kDebugMode) {
        print(url);
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> groupedData = {};
        print('shagged $data');
        for (var entry in data) {
          for (var item in globalData) {
            // print('sdgbfsgakfdjsdhkfljnsdjfn $item');
            if(entry['HomeLocation'] == item['UnitCode']){
              entry['TotalMnpwr'] = item['TotalMnpwr'];
            }
          }
        }
        for (var entry in data) {
          final unitCode = entry['UnitShortCode'];
          // String? totalMnpwr = await _fetchTotalPresent(unitSCode);
          if (groupedData[unitCode] == null) {
            groupedData[unitCode] = {
              'UnitShortCode': unitCode,
              'entries': [],
            };
          }
          groupedData[unitCode]['entries'].add({
            'LineName': entry['LineName'],
            'TotalCount': entry['TotalCount'],
            'VerifyMnpwr': entry['VerifyMnpwr'],
            'Remarks': entry['Remarks'],
            'Helper': entry['HelperCount'],
            'Tailor': entry['TailorCount'],
            'UnitCode': entry['UnitCode'],
            'TotalMnpwr': entry['TotalMnpwr']
          });
        }

        // Converting the grouped data into a list
        setState(() {
          _tableData = groupedData.values.map((unit) => {
            'UnitShortCode': unit['UnitShortCode'],
            'Entries': unit['entries'], // Include total manpower
          }).toList();

        });

      }
    });
  }


  void navigateToVerifReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VerificationReportAll(),
      ),
    );
  }


  Future<void> _fetchTotalPresent(DateTime date) async {

    {
      {
        futureUnits = fetchUnits();
        final units = await futureUnits; // Await here instead of using then
        final unitsString = units.join(',');

        final response = await http.get(Uri.parse(
            '${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitsString&dated=$date'));
        print('${TBaseURL.baseUrl}allocation_tailor_vg?type=totalAllocated&data=$unitsString&dated=$date');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.isNotEmpty) {
            // Assign the fetched data to the global variable
            setState(() {
              globalData = data;
            });
            print('global $globalData');// Adjust as needed based on the structure of data
          }
        } else {
          throw Exception('Failed to load table data');
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
      body: SafeArea(
        child:  InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          panAxis: PanAxis.free,
          minScale: 1.0,
          maxScale: 4.0,
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
                              controller: _dateController,
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
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
                  if (_tableData.isEmpty && !noDataFound)
                    const Center(child: LottieLoading(animationPath: 'assets/animation/alocationLoading.json',size: 300,))
                  else if (noDataFound)
                    const Center(
                      child: LottieLoading(animationPath: 'assets/animation/allNoData.json',size: 300,)
                    )
                  else
                    for (var unit in _tableData) ...[
                      const SizedBox(height: 20,),
                      Center(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey[600],
                              // color: Colors.yellowAccent,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                )
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Present Mnpwr: ${unit['Entries'][0]['TotalMnpwr']}  |  Unit: ${unit['UnitShortCode']}',
                                  textAlign: TextAlign.center, style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildSimpleTable(unit['Entries']),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTable(List<dynamic> entries) {
    num totalCount = 0;
    num totalVerified = 0;
    num helper = 0;
    num tailor = 0;

    // Calculate totals
    for (var entry in entries) {
      totalCount += entry['TotalCount'] ?? 0;
      totalVerified += entry['VerifyMnpwr'] ?? 0;
      helper += entry['Helper'] ?? 0;
      tailor += entry['Tailor'] ?? 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Allows vertical scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allows horizontal scrolling
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allow the column to shrink-wrap its children
          children: [
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FixedColumnWidth(80),
                1: FixedColumnWidth(40),
                2: FixedColumnWidth(40),
                3: FixedColumnWidth(70),
                4: FixedColumnWidth(60),
                5: FixedColumnWidth(90),
              },
              children: [
                // Table header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[400]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Line', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Talr', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Hlpr', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Allocated', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.black)),
                    ),
                  ],
                ),
                for (var entry in entries)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['LineName'] ?? '',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Tailor'].toString(),textAlign: TextAlign.right,style: TextStyle(
                            fontSize: 13,color: Theme.of(context).colorScheme.secondary)),
                      ),Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Helper'].toString(),textAlign: TextAlign.right,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                      ),Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['TotalCount'].toString(),textAlign: TextAlign.right,style: TextStyle(
                            fontSize: 13,color: Theme.of(context).colorScheme.secondary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['VerifyMnpwr']?.toString() ?? '',textAlign: TextAlign.right,style: TextStyle(
                            fontSize: 13,color: Theme.of(context).colorScheme.secondary),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry['Remarks']?.toString() ?? '',style: TextStyle(
                            fontSize: 13,color: Theme.of(context).colorScheme.secondary),),
                      ),
                    ],
                  ),
                TableRow(
                  decoration: BoxDecoration(color: Colors.lightGreen[200]),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(tailor.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black)),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(helper.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black)),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(totalCount.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(totalVerified.toString(),textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.black)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(''),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
