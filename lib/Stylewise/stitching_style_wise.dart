import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ExtraFunction/datefeild.dart';
import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class StitchingDetail {
  final String dated;
  final String dated2;
  final int actualOutPut;
  final int lineProfitLoss;
  final int netProfitLoss;
  final int plannedTarget;
  final int prepProfitLoss;
  final int targetSam;
  final bool isHoliday;
  final bool isWeekOff;

  StitchingDetail({
    required this.dated,
    required this.dated2,
    required this.actualOutPut,
    required this.lineProfitLoss,
    required this.netProfitLoss,
    required this.plannedTarget,
    required this.prepProfitLoss,
    required this.targetSam,
    required this.isHoliday,
    required this.isWeekOff,
  });

  factory StitchingDetail.fromJson(Map<String, dynamic> json) {
    String? startDateStr = json['Dated'];

    String formattedDate;
    String formatDate;
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        // Parse the date string using DateFormat
        DateFormat inputFormat =
            DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
        DateTime startDate = inputFormat.parseUTC(startDateStr);

        // Format the date
        formattedDate = DateFormat('MMM d, yyyy').format(startDate);
        formatDate = DateFormat('yyyy-mm-d').format(startDate);
      } catch (e) {
        print('Error parsing date: $e');
        formattedDate = '';
        formatDate = '';
      }
    } else {
      formattedDate = '';
      formatDate = '';
    }

    return StitchingDetail(
      dated: formattedDate,
      dated2: formatDate,
      actualOutPut: (json['ActualOutPut'] as num?)?.toInt() ?? 0,
      lineProfitLoss: (json['LineProfitLoss'] as num?)?.toInt() ?? 0,
      netProfitLoss: (json['NetProfitLoss'] as num?)?.toInt() ?? 0,
      plannedTarget: (json['PlannedTarget'] as num?)?.toInt() ?? 0,
      prepProfitLoss: (json['PrepProfitLoss'] as num?)?.toInt() ?? 0,
      targetSam: (json['TargetSam'] as num?)?.toInt() ?? 0,
      isHoliday: json['IsHoliday'],
      isWeekOff: json['IsWeekOff'],
    );
  }
}

Future<List<StitchingDetail>> fetchOnTimeData(
    String from, String to, String unit, String vgUnit) async {
  final response = await http.get(
    Uri.parse(
        '${TBaseURL.baseUrl}operation_wise_vg?type=STITCHING&unit=$unit&from=$from&to=$to&vgUnit=$vgUnit'),
    // Uri.parse('http://172.16.10.11:8000/opration?type=CUTTING&unit=$unit&from=$from&to=$to'),
  );

  if (kDebugMode) {
    print(
        '${TBaseURL.baseUrl}operation_wise_vg?type=STITCHING&unit=$unit&from=$from&to=$to&vgUnit=$vgUnit');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => StitchingDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class StitchingTable extends StatelessWidget {
  final List<StitchingDetail> data;

  StitchingTable({required this.data});

  late int lent = 0;
  Map<String, dynamic> calculateTotals() {
    int actualOutPut = 0;
    int lineProfitLoss = 0;
    int netProfitLoss = 0;
    int plannedTarget = 0;
    int prepProfitLoss = 0;
    int targetSam = 0;

    for (var item in data) {
      actualOutPut += item.actualOutPut;
      lineProfitLoss += item.lineProfitLoss;
      netProfitLoss += item.netProfitLoss;
      plannedTarget += item.plannedTarget;
      prepProfitLoss += item.prepProfitLoss;
      targetSam += item.targetSam;
    }
    // Return a map with property names as keys and sums as values
    return {
      'actualOutPut': actualOutPut,
      'lineProfitLoss': lineProfitLoss,
      'netProfitLoss': netProfitLoss,
      'plannedTarget': plannedTarget,
      'prepProfitLoss': prepProfitLoss,
      'targetSam': targetSam,
      // Add more sums for other properties
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> totals = calculateTotals();
    Widget buildCell(int value, {bool isTotal = false}) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          value.toString(),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: value < 0 ? Colors.red : Colors.green,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      );
    }

    return InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: IntrinsicWidth(
                          child: Table(
                            border: TableBorder.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.6)),
                            defaultColumnWidth: IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.grey[700]),
                                children: const [
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          "Dated",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          "Target\nSam",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          'Plan\nTarget',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          'Actual\nOutput',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          "P&L\n(Line)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          "P&L\n(Prep)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: 4.0, left: 4.0),
                                        child: Text(
                                          'P&L\n(Total)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              for (var item in data)
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: item.isHoliday || item.isWeekOff
                                        ? const Color(0xFFA1D7DE)
                                        : Colors.transparent,
                                  ),
                                  children: [
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4),
                                      child: GestureDetector(
                                          child: Text(
                                        item.dated.toString(),
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.lightBlue,
                                        ),
                                      )),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: Text(
                                        item.targetSam.toString(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color:
                                                item.isHoliday || item.isWeekOff
                                                    ? Colors.black
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: Text(
                                        item.plannedTarget.toString(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color:
                                                item.isHoliday || item.isWeekOff
                                                    ? Colors.black
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: Text(
                                        item.actualOutPut.toString(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                            color:
                                                item.isHoliday || item.isWeekOff
                                                    ? Colors.black
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                      ),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: buildCell(item.lineProfitLoss),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: buildCell(item.prepProfitLoss),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 4, left: 4),
                                      child: buildCell(item.netProfitLoss),
                                    )),
                                  ],
                                ),
                              TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.green[300]),
                                children: [
                                  const TableCell(
                                      child: Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: Text(
                                      '',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 4, left: 4),
                                    child: Text(
                                      totals['targetSam'].toString(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 4, left: 4),
                                    child: Text(
                                      totals['plannedTarget'].toString(),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 4, left: 4),
                                    child: Text(
                                      totals['actualOutPut'].toString(),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                                  TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 4, left: 4),
                                          child: buildCell(
                                              totals['lineProfitLoss']!,
                                              isTotal: true))),
                                  TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 4, left: 4),
                                          child: buildCell(
                                              totals['prepProfitLoss']!,
                                              isTotal: true))),
                                  TableCell(
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 4, left: 4),
                                          child: buildCell(
                                              totals['netProfitLoss']!,
                                              isTotal: true))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]));
  }
}

class StitchingModel {
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

StitchingModel createModel(
    BuildContext context, StitchingModel Function() modelBuilder) {
  return modelBuilder();
}

class StitchingStylePage extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final String unit;

  StitchingStylePage(
      {required this.fromDate, required this.toDate, required this.unit});

  @override
  _StitchingStylePageState createState() => _StitchingStylePageState();
}

class _StitchingStylePageState extends State<StitchingStylePage>
    with TickerProviderStateMixin {
  late StitchingModel _model;
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? management;
  String? _selectedUnit;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {};
  String? _loginId;
  String? _unit;
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
  Future<List<StitchingDetail>>? _cuttingDetailsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StitchingModel());
    fromDateController = TextEditingController();
    toDateController = TextEditingController();

    // Parse the initial dates from the widget
    fromDate = DateTime.parse(widget.fromDate);
    toDate = DateTime.parse(widget.toDate);

    // Set the initial dates in the controllers
    fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate);
    toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);

    _loadLoginIdAndFetchData();
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

  //App bar typing animation
  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'Stitching Profit & Loss';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(
              0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  //App bar typing animation
  void _toggleCursor(Timer timer) {
    if (mounted) {
      // Show cursor during both forward and reverse typing
      final shouldShowCursor =
          _typingController.value > 0 && _typingController.value < 1.0;

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
        _currentMaxLength = 'Stitching Profit & Loss'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
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
    // Ensure _loginId is not null before proceeding
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    print('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
          for (var item in data)
            item['UnitShortCode'].toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data)
            item['UnitShortCode'].toString(): item['UnitCode'].toString()
        };

        // Set the selected unit
        if (_dropDownOptions.contains(widget.unit)) {
          _selectedUnit = widget.unit;
        } else {
          _selectedUnit =
              _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
        saveUnitMapToSharedPreferences(_unitMap);
        _fetchData();
      });
    } else {
      // Handle error
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> saveUnitMapToSharedPreferences(
      Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  void _fetchData() {
    String from = fromDateController.text;
    String to = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String vgUnit = _unitMapVg[_selectedUnit]!;
    if (_selectedUnit != null) {
      setState(() {
        _cuttingDetailsFuture =
            fetchOnTimeData(from, to, selectedUnitCode, vgUnit);
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
        elevation: 0,
        shadowColor: Colors.transparent,
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 8),
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       border: Border.all(
        //         color: Colors.grey[700]!,
        //         width: 0.5,
        //       ),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(
        //         Icons.menu_rounded,
        //         color: Colors.white,
        //         size: 22,
        //       ),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //       style: IconButton.styleFrom(
        //         backgroundColor: Colors.black54,
        //         shape: const CircleBorder(),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SafeArea(
          top: true,
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            panAxis: PanAxis.free,
            minScale: 1.0,
            maxScale: 4.0,
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onTertiary,
                        blurRadius: 8,
                        offset: Offset(6, 7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
                                    firstDate:
                                        fromDate, // Ensure to date can't be before from date
                                    helpText: 'Select To Date',
                                  );
                                  if (date != null) {
                                    setState(() {
                                      toDate = date;
                                      toDateController.text =
                                          DateFormat('yyyy-MM-dd').format(date);
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
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _showRGBBorder
                                          ? _borderColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.5),
                                      width: _showRGBBorder ? 2 : 1,
                                    ),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedUnit,
                                    dropdownColor:
                                        Theme.of(context).colorScheme.primary,
                                    items: _dropDownOptions
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontFamily: 'Tahoma',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
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
                                        borderSide: BorderSide
                                            .none, // Remove default border
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Remove default border
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Remove default border
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide
                                            .none, // Remove default border
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
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
                                      transitionType:
                                          TransitionType.CENTER_ROUNDER,
                                      backgroundColor: Colors.grey[600]!,
                                      borderRadius: 8,
                                      borderColor: Colors.grey[400]!,
                                      borderWidth: 1.5,
                                      animationDuration:
                                          const Duration(seconds: 1),
                                      animatedOn: AnimatedOn.onTap,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tahoma',
                                      ),
                                      onPress: () async {
                                        _scaleController
                                            .forward(); // Start the scale animation
                                        _fetchData();
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(6, 7),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<StitchingDetail>>(
                      future: _cuttingDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                              width: double.infinity,
                              child: LottieLoading(
                                size: 150,
                                animationPath:
                                    'assets/animation/Paperplane.json',
                              ));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              children: [
                                const LottieLoading(
                                  size: 300,
                                  animationPath: 'assets/animation/error.json',
                                ),
                                Text(
                                  'Please Try Reloading Or Try Again After Some Time',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Column(
                            children: [
                              const LottieLoading(
                                size: 300,
                                animationPath: 'assets/animation/noData.json',
                              ),
                              Text(
                                'No Data Available',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ],
                          ));
                        } else {
                          return StitchingTable(data: snapshot.data!);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ]),
          )),
    );
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

  Future<DateTime?> _showEnhancedDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    String helpText = 'Select Date',
  }) async {
    final theme = Theme.of(context);

    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
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
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      helpText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
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
                      borderRadius: const BorderRadius.all(Radius.circular(4))),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blueGrey,
                        onPrimary: Theme.of(context).colorScheme.secondary,
                        surface: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                        onSurface: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
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
}
