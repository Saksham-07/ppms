import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Theme/app_theme.dart';
import '../../../common/utils/constants/baseurl.dart';

class HourlyData {
  final int hour;
  final int pass;
  final int defect;
  final int rejected;
  final int rectified;
  final int total;

  HourlyData({
    required this.hour,
    required this.pass,
    required this.defect,
    required this.rejected,
    required this.rectified,
    required this.total,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      hour: json['Hrs'] ?? 0,
      pass: json['Pass'] ?? 0,
      defect: json['Defect'] ?? 0,
      rejected: json['Rejected'] ?? 0,
      rectified: json['Rectified'] ?? 0,
      total: json['Total'] ?? 0,
    );
  }
}

class GroupedData {
  final String styleNo;
  final String lineName;
  final String color;
  final Map<int, HourlyData> hours;

  GroupedData({
    required this.styleNo,
    required this.lineName,
    required this.color,
    required this.hours,
  });

  static Map<int, HourlyData> _initializeHourlyData() {
    return {
      for (var hour in List.generate(16, (index) => index + 1))
        hour: HourlyData(
          hour: hour,
          pass: 0,
          defect: 0,
          rejected: 0,
          rectified: 0,
          total: 0,
        )
    };
  }

  factory GroupedData.fromJson(List<Map<String, dynamic>> jsonList) {
    if (jsonList.isEmpty) {
      throw Exception("Empty data for group");
    }

    final first = jsonList.first;

    final hourlyData = _initializeHourlyData();

    for (var item in jsonList) {
      final hour = item['Hrs'];
      if (hour != null && hour >= 1 && hour <= 16) {
        hourlyData[hour] = HourlyData.fromJson(item);
      }
    }

    return GroupedData(
      styleNo: first['StyleNo'] ?? '',
      lineName: first['LineName'] ?? '',
      color: first['Color'] ?? '',
      hours: hourlyData,
    );
  }
}

class HourlyReportPage extends StatefulWidget {
  const HourlyReportPage({super.key});

  @override
  HourlyReportPageState createState() => HourlyReportPageState();
}

class HourlyReportPageState extends State<HourlyReportPage>
    with TickerProviderStateMixin {
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {}, _unitCodeMap = {};
  String? _selectedUnit;
  DateTime selectedDate = DateTime.now();
  Future<List<Map<String, dynamic>>>? _futureData;
  bool isLinewise = false;
  bool isLinePresent = false;
  int line = 0;
  bool isLoading = true;
  bool _isRVisible = false,
      _showFullTitle = true,
      _isReversing = false,
      _showCursor = true,
      _fromDateFocused = false,
      _toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,
      _backButtonController,
      _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;

  @override
  void initState() {
    super.initState();
    runFunction();
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

  void backAnimation() {
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500), // Longer duration for two-part animation
    );
  }

  void buttonAnimation() {
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
        tween:
            Tween(begin: 0.2, end: -1.5), // Then move left (forward) off screen
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
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  void _updateText() {
    if (!mounted) return;

    const fullText = 'Paramount Product Management System';
    var shortText = 'End Line Hourly Report';

    final newText = _showFullTitle
        ? fullText.substring(0, _typingAnimation.value)
        : shortText.substring(
            0, _typingAnimation.value.clamp(0, shortText.length));

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

    final shouldShowCursor =
        _typingController.value > 0 && _typingController.value < 1.0;

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
          _currentMaxLength = 'End Line Hourly Report'.length;
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

  Future<void> runFunction() async {
    await _fetchDropDownOptions();
    await _unitMapFunction();
    await _checkLineId();
    await Future.delayed(const Duration(milliseconds: 400), () async {
      print(_selectedUnit);
      if (!isLinePresent) {
        if (_selectedUnit != null && _selectedUnit != '') {
          final unitCode = _unitMap[_selectedUnit];
          final vgUnit = _unitMapVg[unitCode];
          await fetchLineDataFromApi(_selectedUnit!);
          _futureData =
              fetchData('all', selectedDate, unitCode!, vgUnit!, '$line');
        }
      } else {
        if (_selectedUnit != null && _selectedUnit != '') {
          final unitCode = _unitMap[_selectedUnit];
          final vgUnit = _unitMapVg[unitCode];
          _futureData =
              fetchData('linewise', selectedDate, unitCode!, vgUnit!, '$line');
        }
      }
    });
  }

  Future<bool> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic lineId = prefs.getInt('line_ids'); // Fetch the line_id as an int
    line = lineId;
    if (kDebugMode) {
      print(lineId);
    }
    if (lineId != 0) {
      isLinePresent = true;
      return true;
    }
    isLinePresent = false;
    return false;
  }

  Future<void> _unitMapFunction() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}unit_vg?type=lookUpUnit&user=$_loginId';
    final response = await http.get(Uri.parse(url));
    print(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _unitMapVg = {
          for (var item in data)
            item['UnitCode1'].toString(): item['UnitCode'].toString()
        };
      });
    } else {
      debugPrint('Failed to load options');
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
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

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
        } else {
          _selectedUnit =
              _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
      });
    } else {
      debugPrint('Failed to load options');
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http
            .get(Uri.parse('${TBaseURL.baseUrl}line?unit=$unit&ot=0'));

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) {
              return {
                'LineName': item['LineName'].toString(),
                'LineID': item['LineId'].toString(),
              };
            }).toList();
          });
          success = true;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Error fetching data (Attempt $retryCount): $e');
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String vise, DateTime date,
      String unit, String vgUnit, String line) async {
    try {
      // Define the URLs for both unit and vgUnit
      final unitApiUrl = Uri.parse(
          "${TBaseURL.auditLocalUrl}el_report_hrly?report_type=$vise&date=$date&unit=$unit&line=$line");
      final vgUnitApiUrl = Uri.parse(
          "${TBaseURL.auditUrl}el_report_hrly?report_type=$vise&date=$date&unit=$vgUnit&line=$line");

      print(unitApiUrl);
      print(vgUnitApiUrl);

      // Fetch both APIs concurrently
      final responses = await Future.wait([
        http.get(unitApiUrl),
        http.get(vgUnitApiUrl),
      ]);

      // Check the status of both responses
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        // Decode both responses
        final List<dynamic> jsonDataUnit = jsonDecode(responses[0].body);
        final List<dynamic> jsonDataVgUnit = jsonDecode(responses[1].body);

        // Combine both datasets
        final combinedData = [...jsonDataUnit, ...jsonDataVgUnit];

        // Grouping data by StyleNo, LineName, and Color
        final groupedData = <String, Map<String, dynamic>>{};
        for (var item in combinedData) {
          final key = '${item["StyleNo"]}-${item["LineName"]}-${item["Color"]}';
          groupedData.putIfAbsent(
              key,
              () => {
                    'StyleNo': item['StyleNo'],
                    'LineName': item['LineName'],
                    'Color': item['Color'],
                    'Entries': List.generate(
                        16,
                        (hour) => <String, dynamic>{
                              'Hrs': hour + 1,
                              'Pass': 0,
                              'Defect': 0,
                              'Rejected': 0,
                              'Rectified': 0,
                              'Total': 0,
                            }),
                  });

          if (item['Hrs'] != null) {
            final hourIndex = item['Hrs'] - 1;
            if (hourIndex >= 0 && hourIndex < 16) {
              groupedData[key]?['Entries'][hourIndex] = {
                'Hrs': item['Hrs'],
                'Pass': item['Pass'] ?? 0,
                'Defect': item['Defect'] ?? 0,
                'Rejected': item['Rejected'] ?? 0,
                'Rectified': item['Rectified'] ?? 0,
                'Total': item['Total'] ?? 0,
              };
            }
          }
        }

        setState(() {
          isLoading = false;
        });
        log("${groupedData.values.toList()}");

        return groupedData.values.toList();
      } else {
        throw Exception(
            "Failed to load data: ${responses[0].statusCode}, ${responses[1].statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
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
              offset =
                  0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
            }

            return Transform.translate(
              offset:
                  Offset(offset * 30, 0), // Multiply by approximate pixel value
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
            if (_showCursor &&
                _typingController.value < 1.0 &&
                _typingController.value > 0)
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
      body: isLoading
          ? const Center(
              child: LottieLoading(
                animationPath: 'assets/animation/auditLoading.json',
                size: 300,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Dropdowns and Date Picker
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 4, top: 8.0, left: 8, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: DropdownSearch<String>(
                              selectedItem: _selectedUnit,
                              dropdownButtonProps: DropdownButtonProps(
                                  padding: const EdgeInsets.all(0),
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              popupProps: PopupProps.menu(
                                  showSearchBox: false,
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      color: isSelected
                                          ? Colors.orange.withOpacity(
                                              0.2) // Optional: highlight selected item
                                          : Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 12.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary, // Text color for all items
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  menuProps: MenuProps(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shadowColor: Colors.grey[400],
                                  )),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                baseStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Unit',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  floatingLabelStyle: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 8.0),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 2.0),
                                  ),
                                ),
                              ),
                              items: _dropDownOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedUnit = newValue;
                                  selectedValue4 = newValue;
                                  selectedValue3 = null;
                                  dropdownData3.clear();
                                  dropdownData5.clear();
                                  fetchLineDataFromApi(_selectedUnit!);
                                  selectedLineID = '';
                                });
                                final unitCode = _unitMap[_selectedUnit];
                                final vgUnit = _unitMapVg[unitCode];
                                _futureData = fetchData(
                                    isLinewise ? 'linewise' : 'all',
                                    selectedDate,
                                    unitCode!,
                                    vgUnit!,
                                    selectedLineID!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Visibility(
                          visible: isLinewise,
                          child: Expanded(
                            child: SizedBox(
                              height: 35,
                              child: DropdownSearch<String>(
                                dropdownButtonProps: DropdownButtonProps(
                                    padding: EdgeInsets.all(0),
                                color: Theme.of(context).colorScheme.secondary
                                ),
                                popupProps: PopupProps.menu(
                                  searchFieldProps: TextFieldProps(
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                    cursorColor: Theme.of(context).colorScheme.secondary,
                                    decoration: InputDecoration(
                                      hintText: "Search...",
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
                                      ),
                                    )
                                  ),
                                  showSearchBox: true,
                                  menuProps: MenuProps(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shadowColor: Colors.grey[400],
                                  ),
                                  itemBuilder: (context, item, isSelected) {
                                    return Container(
                                      color: isSelected
                                          ? Colors.orange.withOpacity(
                                              0.2) // Optional: highlight selected item
                                          : Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 12.0),
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary, // Text color for all items
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  baseStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Line',
                                    labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    floatingLabelStyle: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 8.0),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 2.0),
                                    ),
                                  ),
                                ),
                                items: dropdownData3
                                    .map((Map<String, String> value) =>
                                        value['LineName']!)
                                    .toList(),
                                itemAsString: (item) => item,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedValue3 = newValue;
                                    selectedLineID = dropdownData3.firstWhere(
                                        (element) =>
                                            element['LineName'] ==
                                            newValue)['LineID'];
                                  });
                                  if (_selectedUnit != null &&
                                      selectedLineID != null) {
                                    final unitCode = _unitMap[_selectedUnit];
                                    final vgUnit = _unitMapVg[unitCode];
                                    _futureData = fetchData(
                                        isLinewise ? 'linewise' : 'all',
                                        selectedDate,
                                        unitCode!,
                                        vgUnit!,
                                        selectedLineID!);
                                  }
                                },
                                selectedItem: selectedValue3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4, bottom: 8.0, left: 8, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex:
                              5, // Adjust flex value for proportionate spacing
                          child: GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
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
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                                if (_selectedUnit != null &&
                                    selectedLineID != null) {
                                  final unitCode = _unitMap[_selectedUnit];
                                  final vgUnit = _unitMapVg[unitCode];
                                  _futureData = fetchData(
                                      isLinewise ? 'linewise' : 'all',
                                      selectedDate,
                                      unitCode!,
                                      vgUnit!,
                                      selectedLineID!);
                                }
                              }
                            },
                            child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                    ),
                                    Icon(Icons.calendar_today,color: Theme.of(context).colorScheme.secondary,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isLinePresent)
                          Expanded(
                            flex: 2, // Adjust flex value for spacing
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                  checkColor: Colors.white,
                                  activeColor: Colors.orange,
                                  value: isLinewise,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isLinewise = value ?? false;
                                    });
                                    final unitCode = _unitMap[_selectedUnit];
                                    final vgUnit = _unitMapVg[unitCode];
                                    _futureData = fetchData(
                                        isLinewise ? 'linewise' : 'all',
                                        selectedDate,
                                        unitCode!,
                                        vgUnit!,
                                        selectedLineID ?? '0');
                                    if (_selectedUnit != null &&
                                        selectedLineID != null) {
                                      final unitCode = _unitMap[_selectedUnit];
                                      _futureData = fetchData(
                                          isLinewise ? 'linewise' : 'all',
                                          selectedDate,
                                          unitCode!,
                                          vgUnit,
                                          selectedLineID!);
                                    }
                                  },
                                ),
                                Text(
                                  'Linewise',
                                  style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                      bottom: BorderSide(color: Theme.of(context).colorScheme.secondary))),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Line',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(color: Theme.of(context).colorScheme.secondary),
                              )),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Style',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                left: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                bottom: BorderSide(color: Theme.of(context).colorScheme.secondary),
                              )),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Color',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: SelectableText("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No Data Available"));
                      }

                      final data = snapshot.data!;

                      // Initialize totals for each hour
                      Map<int, Map<String, num>> hourlyTotals = {};

                      for (var unit in data) {
                        for (var entry in unit['Entries']) {
                          int hour = entry['Hrs'];

                          // Initialize if not exists
                          if (!hourlyTotals.containsKey(hour)) {
                            hourlyTotals[hour] = {
                              'Pass': 0,
                              'Defect': 0,
                              'Rejected': 0,
                              'Rectified': 0,
                            };
                          }
                          // Sum up values
                          hourlyTotals[hour]!['Pass'] =
                              (hourlyTotals[hour]!['Pass'] ?? 0) +
                                  (entry['Pass'] ?? 0);
                          hourlyTotals[hour]!['Defect'] =
                              (hourlyTotals[hour]!['Defect'] ?? 0) +
                                  (entry['Defect'] ?? 0);
                          hourlyTotals[hour]!['Rejected'] =
                              (hourlyTotals[hour]!['Rejected'] ?? 0) +
                                  (entry['Rejected'] ?? 0);
                          hourlyTotals[hour]!['Rectified'] =
                              (hourlyTotals[hour]!['Rectified'] ?? 0) +
                                  (entry['Rectified'] ?? 0);
                        }
                      }

                      return Column(
                        children: [
                          for (var unit in data) ...[
                            Center(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    color: Theme.of(context).colorScheme.secondary))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${unit['LineName']}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${unit['StyleNo']}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left: BorderSide(
                                                    color: Theme.of(context).colorScheme.secondary))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${unit['Color']}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildSimpleTable(unit['Entries']),
                            SizedBox(
                              height: 10,
                            )
                          ],

                          // Display Totals Row at Bottom
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration:  BoxDecoration(
                                  color: Colors.grey[400]!,
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Total',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  border: TableBorder.all(color: Colors.black),
                                  columnWidths: {
                                    0: const FixedColumnWidth(
                                        70), // First column width = 70
                                    for (int i = 1; i <= 16; i++)
                                      i: const FixedColumnWidth(
                                          45), // Next 16 columns width = 40
                                    17: const FixedColumnWidth(
                                        60), // Last column width = 60
                                  },
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF379186),),
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Action',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                        for (var hour in List.generate(
                                            16, (index) => 'H${index + 1}'))
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(hour,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                          ),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Total',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                    // Table Data Rows
                                    _buildTableRow(
                                        "Pass", hourlyTotals, "Pass"),
                                    _buildTableRow(
                                        "Defect", hourlyTotals, "Defect"),
                                    _buildTableRow(
                                        "Rejected", hourlyTotals, "Rejected"),
                                    _buildTableRow(
                                        "Rectified", hourlyTotals, "Rectified"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  TableRow _buildTableRow(
      String label, Map<int, Map<String, num>> totals, String key) {
    // Define colors based on key
    Color getColor(String key) {
      switch (key) {
        case "Pass":
          return Colors.green.shade200; // Light green
        case "Defect":
          return Colors.orange.shade200; // Light orange
        case "Rejected":
          return Colors.red.shade200; // Light red
        case "Rectified":
          return Colors.blue.shade200; // Light blue
        default:
          return Colors.white; // Default white
      }
    }

    // Calculate total for the row
    int totalSum = 0;
    for (int hour = 1; hour <= 16; hour++) {
      totalSum += (totals[hour]?[key] ?? 0) as int;
    }

    return TableRow(
      children: [
        Container(
          color: getColor(key), // Apply color dynamically
          padding: const EdgeInsets.all(6.0),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        for (int hour = 1; hour <= 16; hour++)
          Container(
            color: getColor(key), // Apply color dynamically
            padding: const EdgeInsets.all(6.0),
            child: Text(
              "${totals[hour]?[key] ?? 0}",
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
        // Total Column at the right
        Container(
          color: getColor(key), // Apply color dynamically
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "$totalSum", // Display total
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTable(List<dynamic> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: const FixedColumnWidth(70), // First column width = 70
          for (int i = 1; i <= 16; i++)
            i: const FixedColumnWidth(45), // Next 16 columns width = 40
          17: const FixedColumnWidth(60), // Last column width = 60
        },
        border: TableBorder.all(),
        children: [
          // Table header
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFF379186)),
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Hrs',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              for (var hour in List.generate(16, (index) => 'H${index + 1}'))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(hour,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          // Table rows for each metric
          _buildDataRow('Pass', entries, 'Pass'),
          _buildDataRow('Defect', entries, 'Defect'),
          _buildDataRow('Rejected', entries, 'Rejected'),
          _buildDataRow('Rectified', entries, 'Rectified'),
          _buildDataRow('Total', entries, 'Total', isTotalColumn: true),
        ],
      ),
    );
  }

  TableRow _buildDataRow(String label, List<dynamic> entries, String key,
      {bool isTotalColumn = false}) {
    // Calculate total for the row
    num total = entries.fold(0, (sum, entry) {
      return sum +
          (entry[key] is int
              ? entry[key]
              : int.tryParse(entry[key]?.toString() ?? '0') ?? 0);
    });

    return TableRow(
      decoration: BoxDecoration(
        color: isTotalColumn ? Colors.green[300] : null,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child:
              Text(label, style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.secondary)),
        ),
        for (var entry in entries)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child:
                Text(entry[key]?.toString() ?? '0', textAlign: TextAlign.right,style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ),
        // Append total at the end
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            total.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
