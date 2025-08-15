import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ppms/Allocation/allocation.dart';
import 'package:ppms/ExtraFunction/animated_slide_in_card.dart';
import 'package:ppms/ExtraFunction/datefeild.dart';
import 'package:ppms/Stylewise/cutting_style_wise.dart';
import 'package:ppms/Stylewise/finishing_style_wise.dart';
import 'package:ppms/Stylewise/stitching_style_wise.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:ppms/Delivery/delivery_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Audit/El_Audit/AuditHourly/el_hourly_report.dart';
import '../ManagementReview/profit_and_loss.dart';
import '../SalesComparision/sale_comparision.dart';
import '../SalesTurnover/SalesTurnOver.dart';
import '../Theme/app_theme.dart';

class MainDashboardModel {
  final unfocusNode = FocusNode();
  DateTime? datePicked1;
  DateTime? datePicked2;
  String? dropDownValue;
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  List<String> dropDownOptions = [];


  void dispose() {
    unfocusNode.dispose();
    fromDateController.dispose();
    toDateController.dispose();
  }
}

MainDashboardModel createModel(BuildContext context, MainDashboardModel Function() modelBuilder) {
  return modelBuilder();
}

class MainDashboardWidget extends StatefulWidget {
  const MainDashboardWidget({super.key});

  @override
  State<MainDashboardWidget> createState() => _MainDashboardWidgetState();
}

class _MainDashboardWidgetState extends State<MainDashboardWidget> with TickerProviderStateMixin {
  late MainDashboardModel _model;
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? management;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {},_unitMapVg = {};
  String? _loginId,_unitCodesString,_unit,_netTodayProfit,_netTotalProfit,_cutting,_finish,
      _stitching, _finishing, _total, _samToday, _samTotal, _mmrToday,
      _mmrTotal, _energy, _effToday, _effTotal, _todayTailor, _totalTailor;
  bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
      _fromDateFocused = false,_toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,_backButtonController,_scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  String? _selectedUnit;
  int _currentMaxLength = 0;
  UniqueKey _managementReviewKey = UniqueKey(),_samProducedKey = UniqueKey(),_newKey = UniqueKey(),_mmrKey = UniqueKey(),_effKey = UniqueKey()
      ,_finishKey = UniqueKey(),_salesKey = UniqueKey(),_energyKey = UniqueKey(),_tailorKey = UniqueKey();
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDashboardModel());
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    checkForR();
    runFunction();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    _model.dispose();
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

  //App bar typing animation
  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'PPMS';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  //App bar typing animation
  void _toggleCursor(Timer timer) {
    if (mounted) {
      // Show cursor during both forward and reverse typing
      final shouldShowCursor = _typingController.value > 0 &&
          _typingController.value < 1.0;

      if (shouldShowCursor || _showCursor != shouldShowCursor) {
        setState(() => _showCursor = shouldShowCursor);
      }
    }
  }

  //App bar typing animation
  Future<void> _startTypingSequence() async {
    // Type out full title
    _currentMaxLength = 'Paramount Product Management System'.length;
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);

    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Reverse type full title
    setState(() => _isReversing = true);
    await _typingController.reverse(from: 1.0);

    // Switch to short title
    if (mounted) {
      setState(() {
        _showFullTitle = false;
        _isReversing = false;
        _currentMaxLength = 'PPMS'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  Future<void> runFunction() async{
    await _loadLoginIdAndFetchData();
    await fetchRights(_loginId!, 'DashEfficiency');
    await _calculateDates();
    await _setInitialDates();
    await _fetchProfitData();
    await _fetchAsking();
    await _fetchVgData('SamProduced');
    await _fetchVgData('MMR');
    await _fetchVgData('EnergyCost');
    await _fetchVgData('TailorSummary');
    await _fetchVgData('Efficiency');
  }

  Future<void> checkForR() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    final String url = '${TBaseURL.baseUrl}base?user=$_loginId&module=Management&page=Sales_turnover';

    if (kDebugMode) {
      print('Fetching data from URL: $url');
    } // Print the URL

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Check if any of the objects in the list has 'shortname' equal to 'R'
      setState(() {
        _isRVisible = data.any((item) => item['shortname'] == 'R');
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List> fetchRights(String login, String rightPage) async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}base_vg?user=$login&page=$rightPage'));
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}base_vg?user=$_loginId&page=$rightPage');
    }
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> right = [];
      if(data[0]['view_f'] == true){
        right.add('R');
      }
      if(data[0]['Delete_f'] == true){
        right.add('D');
      }
      if(data[0]['edit_f'] == true){
        right.add('M');
      }
      if (kDebugMode) {
        print(data);
        print(right);
      }
      return data;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> _calculateDates() async {
    DateTime now = DateTime.now();
    toDate = now.subtract(const Duration(days: 1));

    if (now.day >= 2) {
      fromDate = DateTime(now.year, now.month, 1);
    } else {
      DateTime previousMonth = DateTime(now.year, now.month - 1, 1);
      fromDate = previousMonth;
    }
  }

  String parseDoubleField(dynamic data, String key, String type) {
    try {
      final value = data?[key];
      if (value == null) return '0';
      final parsed = type == '1' ? double.tryParse(value.toString())?.toStringAsFixed(2) : double.tryParse(value.toString())?.toStringAsFixed(0);
      return parsed?.toString() ?? '0';
    } catch (_) {
      return '0';
    }
  }

  String? formattedDate;

  Future<void> _fetchAsking() async {
    if (_selectedUnit == null) return;

    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url = '${TBaseURL.baseUrl}asking?unit=$selectedUnitCode';


    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        DateFormat originalFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
        DateFormat desiredFormat = DateFormat('yyyy-MM-dd');

        formattedDate = desiredFormat.format(originalFormat.parse(data[0]["AskingDate"]));

        setState(() {
        });

        // Call the next API using the formatted date
        _getFinishing();
      }
    } else {
      setState(() {
        // Handle error here if needed
      });
    }
  }

  Future<void> _fetchProfitData() async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String selectedUnitCodeVg = _unitMapVg[_selectedUnit]!;
    String url2 =
        '${TBaseURL.baseUrl}main_dashboard_vg?type=Pnl&vgUnit=$selectedUnitCodeVg&fromDate=$fromDateStr'
        '&toDate=$toDateStr&allowUnitVg=$_unitCodesString&unit=$selectedUnitCode&allowUnit=${_unitMap.values.join(",")}';

    if (kDebugMode) {
      print('URL2 = $url2');
    }

    try {
      final response2 = await http.get(Uri.parse(url2));

      if (response2.statusCode == 200) {
        final data2 = jsonDecode(response2.body);

        setState(() {
          _netTodayProfit = parseDoubleField(data2[0], 'NetTodayProfit','0');
          _netTotalProfit = parseDoubleField(data2[0], 'NetTotalProfit','0');
          _cutting = parseDoubleField(data2[0], 'CutPnL','0');
          _stitching = parseDoubleField(data2[0], 'StitchPnL','0');
          _finishing = parseDoubleField(data2[0], 'FinishPnL','0');
          _total = parseDoubleField(data2[0], 'TotalPnL','0');
        });
      } else {
        setState(() {
          _netTodayProfit = '0';
          _netTotalProfit = '0';
          _cutting = '0';
          _stitching = '0';
          _finishing = '0';
          _total = '0';
        });
        if (kDebugMode) {
          print('Failed to load data from the second API: ${response2.statusCode}');
        }
      }
    } catch (e) {
      setState(() {
        _netTodayProfit = '0';
        _netTotalProfit = '0';
        _cutting = '0';
        _stitching = '0';
        _finishing = '0';
        _total = '0';
      });
      if (kDebugMode) {
        print('Error fetching profit data: $e');
      }
    }
  }

  Color _borderColor = Colors.black26;
  bool _showRGBBorder = false;
  int _currentRGBIndex = 0;
  final List<Color> _rgbColors = [
    Colors.black,
    Colors.black87,
    Colors.black54,
    Colors.black45,
     Colors.black26
  ];

// Add this method to your state class to handle the RGB animation
  void _startRGBAnimation() {
    setState(() {
      _showRGBBorder = true;
    });

    // Reset the animation after 2 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showRGBBorder = false;
        });
      }
    });

    // Animate through RGB colors
    const frameDuration = Duration(milliseconds: 200);
    _currentRGBIndex = 0;
    Timer.periodic(frameDuration, (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentRGBIndex = (_currentRGBIndex + 1) % _rgbColors.length;
        _borderColor = _rgbColors[_currentRGBIndex];
      });

      // Stop after 2 seconds
      if (timer.tick * frameDuration.inMilliseconds >= 2000) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _borderColor = Colors.black26;
          });
        }
      }
    });
  }

  Future<void> _getFinishing() async {
    if (formattedDate == null) return;

    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url = '${TBaseURL.baseUrl}finish?to=$toDateStr&ask=$formattedDate&unit=$selectedUnitCode';
    if (kDebugMode) {
      print(url);
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _finish = parseDoubleField(data[0], 'AskingRatePcs','0');
        });
      } else {
        setState(() {
          _finish = '0';
        });
      }
    } catch (_) {
      setState(() {
        _finish = '0';
      });
    }
  }

  Future<void> _fetchVgData(String type) async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String selectedUnitCodeVg = _unitMapVg[_selectedUnit]!;

    String url =
        '${TBaseURL.baseUrl}main_dashboard_vg?type=$type&vgUnit=$selectedUnitCodeVg&fromDate=$fromDateStr'
        '&toDate=$toDateStr&allowUnitVg=$_unitCodesString&unit=$selectedUnitCode&allowUnit=${_unitMap.values.join(",")}';

    if (kDebugMode) {
      print(url);
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (type == 'MMR') {
            _mmrToday = parseDoubleField(data[0], 'MMRToday','1');
            _mmrTotal = parseDoubleField(data[0], 'MMRTotal','1');
          } else if (type == 'EnergyCost') {
            _energy = parseDoubleField(data[0], 'TotalValue','1');
          } else if (type == 'Efficiency') {
            _effToday = parseDoubleField(data[0], 'TodayEff','1');
            _effTotal = parseDoubleField(data[0], 'TotalEff','1');
          } else if (type == 'SamProduced') {
            _samToday = parseDoubleField(data[0], 'TodaySam','1');
            _samTotal = parseDoubleField(data[0], 'TotalSam','1');
          } else if (type == 'TailorSummary') {
            _todayTailor = data[0]?['TailorPresentToday']?.toString() ?? '0';
            _totalTailor = data[0]?['TailorPresentTotal']?.toString() ?? '0';
          }
        });
      } else {
        setState(() {
          _samTotal = '0';
          _samToday = '0';
          _mmrTotal = '0';
          _mmrToday = '0';
          _energy = '0';
          _effToday = '0';
          _effTotal = '0';
          _todayTailor = '0';
          _totalTailor = '0';
        });
      }
    } catch (_) {
      setState(() {
        _samTotal = '0';
        _samToday = '0';
        _mmrTotal = '0';
        _mmrToday = '0';
        _energy = '0';
        _effToday = '0';
        _effTotal = '0';
        _todayTailor = '0';
        _totalTailor = '0';
      });
    }
  }

  Color _getProfitColor(String? profit) {
    if (profit == null) return Colors.black;
    double value = double.tryParse(profit) ?? 0;
    return value < 0 ? Colors.red : Colors.green;
  }

  Future<void> _setInitialDates() async {
    fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate);
    toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);
  }

  Future<void> _loadLoginIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
      _unit = prefs.getString('unit');
    });
    if (_loginId != null) {
      await _fetchDropDownOptions();
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final String url = '${TBaseURL.baseUrl}unit_vg?type=lookUpUnitRight&user=$_loginId';
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}unit_vg?type=lookUpUnitRight&user=$_loginId');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode1'].toString()
        };
        _unitCodesString = data.map((e) => e['UnitCode'].toString()).join(',');
        _unitMapVg = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode'].toString()
        };

        // Set the selected unit
        if (_dropDownOptions.contains(_unit)) {
          _selectedUnit = _unit;
        } else {
          _selectedUnit =
          _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
        saveUnitMapToSharedPreferences(_unitMap);
      });
    } else {
      // Handle error
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  void navigateToProfitAndLoss(BuildContext context) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfitAndLossScreen(fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }

  void navigateToSales(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesTurnOverPage(),//fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }
  void navigateToBar2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SaleComparison(),
      ),
    );
  }
  void navigateToAllocation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Allocation(),//fromDate: fromDateStr, toDate: toDateStr),
      ),
    );
  }

  void navigateToCutting(BuildContext context, String selectedUnit) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CuttingStylePage(fromDate: fromDateStr, toDate: toDateStr, unit: selectedUnit),
      ),
    );
  }
  void navigateToBar(BuildContext context,String selectedUnit) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    if (kDebugMode) {
      print(fromDateStr + toDateStr + selectedUnit);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  const HourlyReportPage(),
      ),
    );
  }

  void navigateToStitch(BuildContext context, String selectedUnit) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StitchingStylePage(fromDate: fromDateStr, toDate: toDateStr, unit: selectedUnit),
      ),
    );
  }

  void navigateToFinish(BuildContext context, String selectedUnit) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinishStylePage(fromDate: fromDateStr, toDate: toDateStr, unit: selectedUnit),
      ),
    );
  }

  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    // First select From Date
    final fromDate = await _showEnhancedDatePicker(
      context: context,
      initialDate: this.fromDate,
      helpText: 'Select From Date',
    );

    if (fromDate == null) return; // User cancelled

    setState(() {
      this.fromDate = fromDate;
      fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate);
    });

    // Then automatically open To Date picker
    final toDate = await _showEnhancedDatePicker(
      context: context,
      initialDate: this.toDate.isAfter(fromDate) ? this.toDate : fromDate,
      firstDate: fromDate, // Ensure to date can't be before from date
      helpText: 'Select To Date',
    );

    if (toDate != null) {
      setState(() {
        this.toDate = toDate;
        toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);
      });
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
                  fontSize: _showFullTitle ? 14 : 20,
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
        elevation: 0,
        shadowColor: Colors.transparent,
        // actions: [
        //
        // ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.jpeg'),
                    fit: BoxFit.fitHeight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: null,
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.black),
                title: const Text('Logout', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  // Place your logout logic here
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Date pickers and dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.07),
                    blurRadius: 4,
                    offset: Offset(6, 7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date pickers row
                    Row(
                      children: [
                        Expanded(
                          child: ModernDateInput(
                            controller: fromDateController,
                            hintText: 'From Date',
                            isSelected: _fromDateFocused,
                            onTap: () => _selectDateRange(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ModernDateInput(
                            controller: toDateController,
                            hintText: 'To Date',
                            isSelected: _toDateFocused,
                            onTap: () async {
                              final date = await _showEnhancedDatePicker(
                                context: context,
                                initialDate: toDate,
                                firstDate: fromDate, // Ensure to date can't be before from date
                                helpText: 'Select To Date',
                              );
                              if (date != null) {
                                setState(() {
                                  toDate = date;
                                  toDateController.text = DateFormat('yyyy-MM-dd').format(date);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Unit dropdown and button row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _showRGBBorder ? _borderColor : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                  width: _showRGBBorder ? 2 : 1,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                dropdownColor: Theme.of(context).colorScheme.primary,
                                items: _dropDownOptions.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontFamily: 'Tahoma',
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedUnit = newValue!;
                                  });
                                  _startRGBAnimation(); // Start the animation when value changes
                                },
                                decoration: InputDecoration(
                                  filled: false,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none, // Remove default border
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none, // Remove default border
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none, // Remove default border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none, // Remove default border
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: AnimatedButton(
                                  height: 35,
                                  width: 80,
                                  text: 'Go',
                                  isReverse: true,
                                  selectedTextColor: Colors.black,
                                  transitionType: TransitionType.CENTER_ROUNDER,
                                  backgroundColor: Colors.grey[600]!,
                                  borderRadius: 8,
                                  borderColor: Colors.grey[400]!,
                                  borderWidth: 1.5,
                                  animationDuration: const Duration(seconds: 1),
                                  animatedOn: AnimatedOn.onTap,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tahoma',
                                  ),
                                  onPress: () async {
                                    _scaleController.forward(); // Start the scale animation

                                    setState(() {
                                      _managementReviewKey = UniqueKey();
                                      _samProducedKey = UniqueKey();
                                      _newKey = UniqueKey();
                                      _effKey = UniqueKey();
                                      _mmrKey = UniqueKey();
                                      _finishKey = UniqueKey();
                                      _salesKey = UniqueKey();
                                      _energyKey = UniqueKey();
                                      _tailorKey = UniqueKey();
                                    });

                                    await _fetchProfitData();
                                    await _fetchVgData('SamProduced');
                                    await _fetchVgData('MMR');
                                    await _fetchVgData('EnergyCost');
                                    await _fetchVgData('TailorSummary');
                                    await _fetchVgData('Efficiency');
                                    await _fetchAsking();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dashboard cards section (all scrollable together)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: ListView(
                children: [
                  // Management Review (full width)
                  AnimatedSlideInCard(
                    key: _managementReviewKey,
                    direction: SlideDirection.top,
                    delayMilliseconds: 800,
                    duration: const Duration(milliseconds: 1200),
                    child: GestureDetector(
                      onTap: ()=> navigateToProfitAndLoss(context),
                      child: dashboardCard(
                        bgColor: Colors.white,
                        borderColor: Colors.black26,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Management Review',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Tahoma',
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.secondary,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: _netTodayProfit,
                                      style: TextStyle(
                                        color: _getProfitColor(_netTodayProfit),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tahoma',
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _netTodayProfit == null ? '' : ' / ',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tahoma',
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _netTotalProfit,
                                      style: TextStyle(
                                        color: _getProfitColor(_netTotalProfit),
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tahoma',
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Sam Produced (full width)
                  AnimatedSlideInCard(
                    key: _samProducedKey,
                    direction: SlideDirection.top,
                    delayMilliseconds: 400,
                    duration: const Duration(milliseconds: 1600),
                    child: dashboardCard(
                      bgColor: Colors.white,
                      borderColor: Colors.black26,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'Sam Produced',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Tahoma',
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.secondary,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _samToday ?? '0',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tahoma',
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tahoma',
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _samTotal ?? '0',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tahoma',
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedSlideInCard(
                    key: _newKey,
                    direction: SlideDirection.top,
                    duration: const Duration(milliseconds: 2000),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryChartPage(),
                        ),
                      ),
                      child: dashboardCard(
                        bgColor: Colors.white,
                        borderColor: Colors.black26,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Delivery Chart',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Tahoma',
                                  fontSize: 18,
                                  color: Theme.of(context).colorScheme.secondary,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Grid for the rest
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: List.generate(12, (index) {
                      // Define all possible cards in order
                      final cards = [
                        GestureDetector(
                          onTap: () => navigateToCutting(context, _selectedUnit!),
                          child: AnimatedSlideInCard(
                            key: _managementReviewKey,
                            direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                            delayMilliseconds: 1000 + index * 150,
                            duration: const Duration(milliseconds: 800),
                            child: dashboardCard(
                              bgColor: Colors.white,
                              borderColor: Colors.black26,
                              child: buildPLCard('Cutting P&L', _cutting, _getProfitColor(_cutting), titleColor: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => navigateToStitch(context, _selectedUnit!),
                          child: AnimatedSlideInCard(
                            key: _managementReviewKey,
                            direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                            delayMilliseconds: 1000 + index * 150,
                            duration: const Duration(milliseconds: 800),
                            child: dashboardCard(
                              bgColor: Colors.white,
                              borderColor: Colors.black26,
                              child: buildPLCard('Stitching P&L', _stitching, _getProfitColor(_stitching), titleColor: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => navigateToFinish(context, _selectedUnit!),
                          child: AnimatedSlideInCard(
                            key: _managementReviewKey,
                            direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                            delayMilliseconds: 1000 + index * 150,
                            duration: const Duration(milliseconds: 800),
                            child: dashboardCard(
                              bgColor: Colors.white,
                              borderColor: Colors.black26,
                              child: buildPLCard('Finishing P&L', _finishing, _getProfitColor(_finishing), titleColor: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _managementReviewKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildPLCard('Total P&L', _total, _getProfitColor(_total), titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _mmrKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildSummaryCard('MMR', _mmrToday, _mmrTotal, titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _energyKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildPLCard('Energy Cost', _energy, Colors.blueAccent, titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _tailorKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildSummaryCard('Tailor Smry', _todayTailor, _totalTailor, titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _effKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildSummaryCard('Efficiency(%)', _effToday, _effTotal, titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        AnimatedSlideInCard(
                          key: _finishKey,
                          direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                          delayMilliseconds: 1000 + index * 150,
                          duration: const Duration(milliseconds: 800),
                          child: dashboardCard(
                            bgColor: Colors.white,
                            borderColor: Colors.black26,
                            child: buildPLCard('Finish Asking', _finish, Colors.blueAccent, titleColor: Theme.of(context).colorScheme.secondary),
                          ),
                        ),
                        if (_isRVisible)
                          GestureDetector(
                            onTap: () => navigateToSales(context),
                            child: AnimatedSlideInCard(
                              key: _salesKey,
                              direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                              delayMilliseconds: 1000 + index * 150,
                              duration: const Duration(seconds: 1),
                              child: dashboardCard(
                                bgColor: Colors.white,
                                borderColor: Colors.black26,
                                child: Center(
                                  child: Text(
                                    'Sales Turnover',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Tahoma',
                                      fontSize: 20,
                                      shadows: const [
                                      Shadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                      )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_loginId == '0552482')
                          GestureDetector(
                          onTap: () => navigateToBar(context, _selectedUnit!),
                          child: AnimatedSlideInCard(
                            direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                            delayMilliseconds: 1000 + index * 150,
                            duration: const Duration(milliseconds: 800),
                            child: dashboardCard(
                              bgColor: Colors.white,
                              borderColor: Colors.black26,
                              child: const Center(
                                child: Text(
                                  'Line Allocation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Tahoma',
                                    fontSize: 20,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_loginId == '0552482')
                          GestureDetector(
                          onTap: () => navigateToBar2(context),
                          child: AnimatedSlideInCard(
                            direction: index.isEven ? SlideDirection.left : SlideDirection.right,
                            delayMilliseconds: 1000 + index * 150,
                            duration: const Duration(milliseconds: 800),
                            child: dashboardCard(
                              bgColor: Colors.white,
                              borderColor: Colors.black26,
                              child: const Center(
                                child: Text(
                                  'Sales Turnover',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Tahoma',
                                    fontSize: 20,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ];

                      // Return the card at the current index (if it exists)
                      return index < cards.length ? cards[index] : const SizedBox.shrink();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard({
    required Widget child,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: .5,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget buildPLCard(String title, String? value, Color color, {Color titleColor = Colors.black}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Tahoma',
              fontSize: 18,
              color: titleColor,
              shadows: const [
                Shadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value ?? '0',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Tahoma',
              fontSize: 15,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSummaryCard(String title, String? today, String? total, {Color titleColor = Colors.black}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Tahoma',
              fontSize: 18,
              color: titleColor,
              shadows: const [
                Shadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: today ?? '0',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                    fontSize: 15,
                  ),
                ),
                TextSpan(
                  text: ' / ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: total ?? '0',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tahoma',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<DateTime?> _showEnhancedDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    String helpText = 'Select Date',
  }) async {
    final theme = Theme.of(context).datePickerTheme;

    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      helpText,
                      style: theme.dayStyle
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Date picker
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: const BorderRadius.all(Radius.circular(4))
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blueGrey,
                        onPrimary: Theme.of(context).colorScheme.secondary,
                        surface: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        onSurface: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                      ),
                    ),
                    child: DatePickerDialog(
                      initialDate: initialDate,
                      firstDate: firstDate ?? DateTime(2000),
                      lastDate: DateTime(2100),
                      helpText: '',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}