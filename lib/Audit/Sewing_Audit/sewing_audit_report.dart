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
import '../../ExtraFunction/TooltipIcon.dart';
import '../../Theme/app_theme.dart';
import '../../common/utils/constants/baseurl.dart';


class SewingReportPage extends StatefulWidget {
  const SewingReportPage({super.key});

  @override
  SewingReportPageState createState() => SewingReportPageState();
}

class SewingReportPageState extends State<SewingReportPage> with TickerProviderStateMixin {
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;

  List<String> styleOptions = [];
  Map<String, String> styleMap = {};
  String? selectedStyleNo;

  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {},_unitCodeMap = {};
  String? _selectedUnit;
  DateTime selectedDate = DateTime.now();
  bool isLineWise = false,isStyleWise = false;
  bool isLinePresent = false;
  int line = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> sewingData = [];
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
    var shortText = 'Sewing Audit Report';

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
          _currentMaxLength = 'Sewing Audit Report'.length;
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

  void runFunction() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });

    await _fetchDropDownOptions();
    await _checkLineId();

    // Delay to ensure dependent values are set
    await Future.delayed(const Duration(milliseconds: 400), () async {
      if (_selectedUnit != null && _selectedUnit != '') {
        await fetchLineDataFromApi(_unitCodeMap[_selectedUnit!]!);
        final unitCode = _unitMap[_selectedUnit];
        final unitCodeVg = _unitMapVg[_selectedUnit];
        await _fetchStyleOptions();

        if (!isLinePresent) {
          // Fetch data without line
          await fetchData('all', selectedDate, unitCode!, unitCodeVg!, '$line');
        } else {
          // Fetch data with line
          await fetchData('linewise', selectedDate, unitCode!, unitCodeVg!, '$line');
        }
      }
    });

    setState(() {
      isLoading = false; // Hide loading spinner
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

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    final response = await http.get(Uri.parse(url));
    print(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode'].toString()
        };
        _unitCodeMap = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitShortCode1'].toString()
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

  Future<void> _fetchStyleOptions() async {
    final unitCode = _unitMap[_selectedUnit];
    final unitCodeVg = _unitMapVg[_selectedUnit];
    String url1 = '${TBaseURL.auditUrl}sewing_audit_new?type=ReportStyle&unit=$unitCode&style=&color=&lineId=&line_Id=&orderNo=&date=$selectedDate';
    // If you want to use a different unit value for the second call, adjust here:

    String url2 = '${TBaseURL.auditUrl}sewing_audit_new?type=ReportStyle&unit=$unitCodeVg&style=&color=&lineId=&line_Id=&orderNo=&date=$selectedDate';


    if (kDebugMode) {
      print(url1);
      print(url2);
    }

    try {
      // Fire both requests in parallel
      final responses = await Future.wait([
        http.get(Uri.parse(url1)),
        http.get(Uri.parse(url2)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> data1 = jsonDecode(responses[0].body);
        final List<dynamic> data2 = jsonDecode(responses[1].body);

        // Combine and deduplicate by STYLE_NO
        print(data1);
        print(data2);
        final allData = [...data1, ...data2];
        final styleSet = <String>{};
        final styleList = <String>[];
        final styleMapTemp = <String, String>{};
        for (var item in allData) {
          final styleNo = item['StyleNo'].toString();
          if (styleSet.add(styleNo)) {
            styleList.add(styleNo);
            styleMapTemp[styleNo] = styleNo;
          }
        }
        setState(() {
          styleOptions = ['----'] + styleList;
          styleMap = styleMapTemp;
          selectedStyleNo = styleOptions.isNotEmpty ? styleOptions[0] : null;
        });
        print(styleOptions);
      } else {
        if (kDebugMode) {
          print('Failed to load Buyer options');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching style options: $e');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(
            Uri.parse('${TBaseURL.baseUrl}line?unit=$unit&ot=0'));

        print('${TBaseURL.baseUrl}line?unit=$unit&ot=0');
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

  Future<String> fetchSupervisorData(String supervisor) async {
    final String url = "${TBaseURL.auditUrl}sewing_report?type=user&date=&unit=&line=&subtype=$supervisor";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          return data[0]["Name"] ?? "No Name Found";
        }
        return "Unexpected Data Format";
      } else {
        throw Exception('Failed to fetch supervisor info');
      }
    } catch (e) {
      debugPrint('Error fetching supervisor data: $e');
      return "Error Fetching Data";
    }
  }

  Future<void> updateSewingDataWithSupervisorInfo() async {
    List<Map<String, dynamic>> updatedData = [];

    for (var item in sewingData) {
      String sup = item['Supervisor'].toString();
      String qa = item['QA'].toString();
      String checker = item['Checker'].toString();
      String supervisorName = await fetchSupervisorData(sup);
      String qaName = await fetchSupervisorData(qa);
      String checkerName = await fetchSupervisorData(checker);

      print(qaName);

      setState(() {
        updatedData.add({
          ...item,
          'SupervisorName': supervisorName,
          'QaName': qaName,
          'CheckerName': checkerName,
        });
      });
    }

    setState(() {
      sewingData = updatedData;
    });
  }

  Future<void> fetchData(String vise, DateTime date, String unit, String vgUnit, String line) async {
    try {
      String formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // URLs for both API calls
      final unitUrl = "${TBaseURL.auditUrl}sewing_report_new?type=$vise&date=$formattedDate&unit=$unit&line=$line&subtype=S&style=$selectedStyleNo";
      final vgUnitUrl = "${TBaseURL.auditUrl}sewing_report_new?type=$vise&date=$formattedDate&unit=$vgUnit&line=$line&subtype=S&style=$selectedStyleNo";

      // Print both URLs in debug mode
      if (kDebugMode) {
        print(unitUrl);
        print(vgUnitUrl);
      }

      // Make both API calls concurrently
      final responses = await Future.wait([
        http.get(Uri.parse(unitUrl)),
        http.get(Uri.parse(vgUnitUrl)),
      ]);

      // Check the status of both responses
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final data1 = json.decode(responses[0].body); // Data from first API
        final data2 = json.decode(responses[1].body); // Data from second API

        // Merge the data from both APIs
        final mergedData = [
          ...List<Map<String, dynamic>>.from(data1),
          ...List<Map<String, dynamic>>.from(data2),
        ];

        setState(() {
          sewingData = mergedData;
          isLoading = false;
        });

        await updateSewingDataWithSupervisorInfo();
      } else {
        throw Exception('Failed to load data from one or both APIs');
      }
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to load sewing data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = sewingData.where((item) =>
    item['ReAuditNo'] == null ||
        item['ReAuditNo'].toString().isEmpty
    ).toList();

    final int totalReceivedQty = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['ReceivedQty'].toString()) ?? 0));
    final int totalSampleSize = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['SampleSize'].toString()) ?? 0));
    final int totalPcsChecked = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['PcsChecked'].toString()) ?? 0));

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
      body: isLoading ? const Center(child: LottieLoading(animationPath: 'assets/animation/auditLoading.json',size: 300,),) : Column(
        children: [
          // Dropdowns and Date Picker
          Padding(
            padding: const EdgeInsets.only(bottom: 4,top: 8.0,left: 8,right: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: DropdownSearch<String>(
                      selectedItem: _selectedUnit,
                      dropdownButtonProps: DropdownButtonProps(
                          padding: EdgeInsets.all(0),
                          color: Theme.of(context).colorScheme.secondary,
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchDelay: Duration.zero,
                        searchFieldProps: TextFieldProps(
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            cursorColor: Theme.of(context).colorScheme.secondary,
                            decoration: InputDecoration(
                              labelText: 'Search',
                              labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary,
                                    width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.secondary,
                                    width: 1.0),
                              ),
                            )),
                        menuProps: MenuProps(
                          backgroundColor: Theme.of(context).primaryColor,
                          shadowColor: Colors.grey[400],
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),itemBuilder: (context, item, isSelected) {
                        return Container(
                          color: isSelected
                              ? Colors.orange
                              .withOpacity(0.2) // Optional: highlight selected item
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
                        baseStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Unit',
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary),
                          floatingLabelStyle: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary, width: 2.0),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.5),
                                width: 1.0),
                          ),
                          // ... other decoration properties
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
                          fetchLineDataFromApi(_unitCodeMap[_selectedUnit!]!);
                          selectedLineID = '';
                        });
                        final unitCode = _unitMap[_selectedUnit];
                        final unitCodeVg = _unitMapVg[_selectedUnit];
                        fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode!,unitCodeVg!, selectedLineID!);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Visibility(
                  visible: isLineWise,
                  child: Expanded(
                    child: SizedBox(
                      height: 35,
                      child: DropdownSearch<String>(
                        dropdownButtonProps: DropdownButtonProps(
                          padding: EdgeInsets.all(0),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchDelay: Duration.zero,
                          searchFieldProps: TextFieldProps(
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary,
                                      width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary,
                                      width: 1.0),
                                ),
                              )),
                          menuProps: MenuProps(
                            backgroundColor: Theme.of(context).primaryColor,
                            shadowColor: Colors.grey[400],
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ),itemBuilder: (context, item, isSelected) {
                          return Container(
                            color: isSelected
                                ? Colors.orange
                                .withOpacity(0.2) // Optional: highlight selected item
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
                          baseStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Line',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary),
                            floatingLabelStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 2.0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.5),
                                  width: 1.0),
                            ),
                            // ... other decoration properties
                          ),
                        ),
                        items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(),
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            selectedValue3 = newValue;
                            selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                          });
                          if (_selectedUnit != null && selectedLineID != null) {
                            final unitCodeVg = _unitMapVg[_selectedUnit];
                            final unitCode = _unitMap[_selectedUnit];

                            fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode!,unitCodeVg!, selectedLineID!);
                          }
                        },
                        selectedItem: selectedValue3,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isStyleWise,
                  child: Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedStyleNo,
                        dropdownButtonProps: DropdownButtonProps(
                          padding: EdgeInsets.all(0),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchDelay: Duration.zero,
                          searchFieldProps: TextFieldProps(
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              cursorColor: Theme.of(context).colorScheme.secondary,
                              decoration: InputDecoration(
                                labelText: 'Search',
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.5)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary,
                                      width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).colorScheme.secondary,
                                      width: 1.0),
                                ),
                              )),
                          menuProps: MenuProps(
                            backgroundColor: Theme.of(context).primaryColor,
                            shadowColor: Colors.grey[400],
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ),itemBuilder: (context, item, isSelected) {
                          return Container(
                            color: isSelected
                                ? Colors.orange
                                .withOpacity(0.2) // Optional: highlight selected item
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
                          baseStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Style',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary),
                            floatingLabelStyle: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary),
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.secondary, width: 2.0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.5),
                                  width: 1.0),
                            ),
                            // ... other decoration properties
                          ),
                        ),
                        items: styleOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedStyleNo = newValue;
                          });
                          if (_selectedUnit != null && selectedStyleNo != null) {
                            final unitCodeVg = _unitMapVg[_selectedUnit];
                            final unitCode = _unitMap[_selectedUnit];

                            fetchData(isStyleWise ? 'stylewise' : 'all', selectedDate, unitCode!,unitCodeVg!,'');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4,bottom: 8.0,left: 8,right: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 5, // Adjust flex value for proportionate spacing
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

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          isLoading = true;
                          isStyleWise = false;
                        });

                        final unitCode = _unitMap[_selectedUnit];
                        final unitCodeVg = _unitMapVg[_selectedUnit];

                        if (_selectedUnit != null && unitCode != null) {
                          await fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode,unitCodeVg!, selectedLineID ?? '0');
                        }
                      }
                    },
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate.toLocal().toString().split(' ')[0],
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                            Icon(Icons.calendar_today,size: 20,color: Theme.of(context).colorScheme.secondary,),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7, // Adjust flex value for spacing
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        activeColor: Colors.orange,
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.orange;
                            }
                            return Colors.white;
                          },
                        ),
                        side: BorderSide(color: Colors.grey[600]!, width: 1.0),
                        value: isLineWise,
                        onChanged: (bool? value) {
                          setState(() {
                            isLineWise = value ?? false;
                            if (isLineWise) isStyleWise = false; // Unselect stylewise
                            print('isLineWise: $isLineWise');
                          });

                          final unitCode = _unitMap[_selectedUnit];
                          final unitCodeVg = _unitMapVg[_selectedUnit];

                          if (_selectedUnit != null) {
                            fetchData(
                                isLineWise ? 'linewise' : 'all',
                                selectedDate,
                                unitCode!,
                                unitCodeVg!,
                                selectedLineID ?? '0'
                            );
                          }
                        },
                      ),
                      Text(
                        'Linewise',
                        style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                      ),
                      Checkbox(
                        activeColor: Colors.orange,
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.orange;
                            }
                            return Colors.white;
                          },
                        ),
                        side: BorderSide(color: Colors.grey[600]!, width: 1.0),
                        value: isStyleWise,
                        onChanged: (bool? value) async {
                          setState(() {
                            isStyleWise = value ?? false;
                            if (isStyleWise) isLineWise = false; // Unselect linewise
                            print('isStyleWise: $isStyleWise');
                          });

                          final unitCode = _unitMap[_selectedUnit];
                          final unitCodeVg = _unitMapVg[_selectedUnit];

                          if (_selectedUnit != null) {
                            await _fetchStyleOptions();
                            await fetchData(
                                isStyleWise ? 'stylewise' : 'all', // update if you have a stylewise API
                                selectedDate,
                                unitCode!,
                                unitCodeVg!,
                                selectedLineID ?? '0'
                            );
                          }
                        },
                      ),
                      Text(
                        'StyleWise',
                        style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Audit No', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Hour', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Style', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                        ),
                        Visibility(
                          visible : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text('Buyer', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Line', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Pcs\nReceived',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Sample\nSize',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Psc\nChecked',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Final\nResult',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Audit\nType',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...sewingData.asMap().entries.map((entry) {
                      var item = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['AuditNo'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['Hrs'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['StyleNo'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Visibility(
                            visible : false,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                              child: Text(item['StyleNo'].toString(),style: TextStyle(
                                  fontSize: 13,color: Theme.of(context).colorScheme.secondary
                              ),),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['Color'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['LineName'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['ReceivedQty'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['SampleSize'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['PcsChecked'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['FinalResult'].toString(),style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['ReAuditNo'].toString() == '' ? 'Fresh' : 'ReAudit\n(${item['ReAuditNo'].toString()})',style: TextStyle(
                                fontSize: 13,color: Theme.of(context).colorScheme.secondary
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: TooltipIcon(
                              tooltipText: "Supervisor: ${item['SupervisorName']}\nQA: ${item['QaName']}\nChecker: ${item['CheckerName']}",
                            ),
                          ),
                        ],
                      );
                    }),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.black),
                          ),
                        ),
                        const SizedBox.shrink(), // Hour
                        const SizedBox.shrink(), // Style
                        const Visibility(
                          visible: false,
                          child: SizedBox.shrink(), // Buyer
                        ),
                        const SizedBox.shrink(), // Color
                        const SizedBox.shrink(), // Line
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalReceivedQty.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalSampleSize.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalPcsChecked.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.black),
                          ),
                        ),
                        const SizedBox.shrink(), // FinalResult
                        const SizedBox.shrink(), // AuditType
                        const SizedBox.shrink(), // Detail
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}