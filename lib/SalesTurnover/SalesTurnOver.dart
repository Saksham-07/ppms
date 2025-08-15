import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class SalesData {
  String mainColumn;
  String january;
  String february;
  String march;
  String april;
  String may;
  String june;
  String july;
  String august;
  String september;
  String october;
  String november;
  String december;

  SalesData({
    required this.mainColumn,
    required this.january,
    required this.february,
    required this.march,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    String intOrBlank(num? value) {
      return value != null ? value.toInt().toString() : '';
    }

    return SalesData(
      mainColumn: json['MainColumn']?.toString() ?? '',
      january: intOrBlank(json['January'] as num?),
      february: intOrBlank(json['February'] as num?),
      march: intOrBlank(json['March'] as num?),
      april: intOrBlank(json['April'] as num?),
      may: intOrBlank(json['May'] as num?),
      june: intOrBlank(json['June'] as num?),
      july: intOrBlank(json['July'] as num?),
      august: intOrBlank(json['August'] as num?),
      september: intOrBlank(json['September'] as num?),
      october: intOrBlank(json['October'] as num?),
      november: intOrBlank(json['November'] as num?),
      december: intOrBlank(json['December'] as num?),
    );
  }
}

Future<List<SalesData>> fetchSalesData(String fy, int check) async {
  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}sales?unit=$check&year=$fy'),
  );

  if (kDebugMode) {
    print('${TBaseURL.baseUrl}sales?unit=$check&year=$fy');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return jsonResponse.map((data) => SalesData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

String trimToFirst15Characters(String text) {
  if (text.length > 11) {
    return '${text.substring(0, 11)}.';
  } else {
    return text;
  }
}

class SalesTable extends StatelessWidget {
  final List<SalesData> data;

  SalesTable({required this.data});

  List<String> _getVisibleMonths() {
    // Check which months have data available
    List<String> visibleMonths = [];
    if (data.isNotEmpty) {
      SalesData firstData = data.first;
      if (firstData.april.isNotEmpty) visibleMonths.add('April');
      if (firstData.may.isNotEmpty) visibleMonths.add('May');
      if (firstData.june.isNotEmpty) visibleMonths.add('June');
      if (firstData.july.isNotEmpty) visibleMonths.add('July');
      if (firstData.august.isNotEmpty) visibleMonths.add('August');
      if (firstData.september.isNotEmpty) visibleMonths.add('September');
      if (firstData.october.isNotEmpty) visibleMonths.add('October');
      if (firstData.november.isNotEmpty) visibleMonths.add('November');
      if (firstData.december.isNotEmpty) visibleMonths.add('December');
      if (firstData.january.isNotEmpty) visibleMonths.add('January');
      if (firstData.february.isNotEmpty) visibleMonths.add('February');
      if (firstData.march.isNotEmpty) visibleMonths.add('March');
    }
    return visibleMonths;
  }

  int _calculateRowTotal(SalesData item) {
    int total = 0;
    total += int.tryParse(item.april) ?? 0;
    total += int.tryParse(item.may) ?? 0;
    total += int.tryParse(item.june) ?? 0;
    total += int.tryParse(item.july) ?? 0;
    total += int.tryParse(item.august) ?? 0;
    total += int.tryParse(item.september) ?? 0;
    total += int.tryParse(item.october) ?? 0;
    total += int.tryParse(item.november) ?? 0;
    total += int.tryParse(item.december) ?? 0;
    total += int.tryParse(item.january) ?? 0;
    total += int.tryParse(item.february) ?? 0;
    total += int.tryParse(item.march) ?? 0;
    return total;
  }

  Map<String, int> _calculateColumnSums() {
    Map<String, int> sums = {
      'April': 0,
      'May': 0,
      'June': 0,
      'July': 0,
      'August': 0,
      'September': 0,
      'October': 0,
      'November': 0,
      'December': 0,
      'January': 0,
      'February': 0,
      'March': 0,
    };

    for (var item in data) {
      sums['April'] = (sums['April'] ?? 0) + (int.tryParse(item.april) ?? 0);
      sums['May'] = (sums['May'] ?? 0) + (int.tryParse(item.may) ?? 0);
      sums['June'] = (sums['June'] ?? 0) + (int.tryParse(item.june) ?? 0);
      sums['July'] = (sums['July'] ?? 0) + (int.tryParse(item.july) ?? 0);
      sums['August'] = (sums['August'] ?? 0) + (int.tryParse(item.august) ?? 0);
      sums['September'] =
          (sums['September'] ?? 0) + (int.tryParse(item.september) ?? 0);
      sums['October'] =
          (sums['October'] ?? 0) + (int.tryParse(item.october) ?? 0);
      sums['November'] =
          (sums['November'] ?? 0) + (int.tryParse(item.november) ?? 0);
      sums['December'] =
          (sums['December'] ?? 0) + (int.tryParse(item.december) ?? 0);
      sums['January'] =
          (sums['January'] ?? 0) + (int.tryParse(item.january) ?? 0);
      sums['February'] =
          (sums['February'] ?? 0) + (int.tryParse(item.february) ?? 0);
      sums['March'] = (sums['March'] ?? 0) + (int.tryParse(item.march) ?? 0);
    }

    return sums;
  }

  @override
  Widget build(BuildContext context) {
    List<String> visibleMonths = _getVisibleMonths();
    Map<String, int> columnSums = _calculateColumnSums();

    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      minScale: 0.8,
      maxScale: 2.5,
      child: Row(
        children: [
          Column(
            children: [
              IntrinsicWidth(
                child: Table(
                  border: TableBorder.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[400]),
                      children: const [
                        TableCell(
                          child: Center(
                            child: Text(
                              "Buyer",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  trimToFirst15Characters(
                                      item.mainColumn.toString()),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF8DEAA3)),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Total",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
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
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              defaultColumnWidth: const IntrinsicColumnWidth(),
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[400]),
                                  children: [
                                    for (var month in visibleMonths)
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            month,
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    TableCell(
                                      child: Container(
                                        color: Colors.grey[400],
                                        child: const Center(
                                          child: Text(
                                            "Total",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var item in data)
                                  TableRow(
                                    children: [
                                      for (var month in visibleMonths)
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 2),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  _getMonthValue(item, month),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      TableCell(
                                        child: Container(
                                          color: const Color(0xffbeedf5),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 2),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  _calculateRowTotal(item)
                                                      .toString(),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                TableRow(
                                  children: [
                                    for (var month in visibleMonths)
                                      TableCell(
                                        child: Container(
                                          color: const Color(0xFF8DEAA3),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 2),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  columnSums[month]
                                                          ?.toString() ??
                                                      '0',
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    TableCell(
                                      child: Container(
                                        color: const Color(0xFFC4B2F1),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 6, right: 2),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                columnSums.values
                                                    .fold(0, (a, b) => a + b)
                                                    .toString(),
                                                textAlign: TextAlign.end,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
          )
        ],
      ),
    );
  }

  String _getMonthValue(SalesData item, String month) {
    switch (month) {
      case 'April':
        return item.april;
      case 'May':
        return item.may;
      case 'June':
        return item.june;
      case 'July':
        return item.july;
      case 'August':
        return item.august;
      case 'September':
        return item.september;
      case 'October':
        return item.october;
      case 'November':
        return item.november;
      case 'December':
        return item.december;
      case 'January':
        return item.january;
      case 'February':
        return item.february;
      case 'March':
        return item.march;
      default:
        return '';
    }
  }

  String trimToFirst15Characters(String text) {
    if (text.length > 11) {
      return '${text.substring(0, 11)}.';
    } else {
      return text;
    }
  }
}

class SalesTurnOverPage extends StatefulWidget {
  @override
  _SalesTurnOverPageState createState() => _SalesTurnOverPageState();
}

class _SalesTurnOverPageState extends State<SalesTurnOverPage>
    with TickerProviderStateMixin {
  String _selectedTurn = "1";
  String? _selectedFyShortName;
  List<dynamic> _fyData = [];
  Future<List<SalesData>>? _salesData;
  bool _isChecked = false;
  double _scale = 1.0; // Default scale value
  double _previousScale = 1.0;
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
  late AnimationController _checkboxController;
  late Animation<double> _checkboxScaleAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;

  @override
  void initState() {
    super.initState();
    _fetchFyData();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    _checkboxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _checkboxScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _checkboxController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _checkboxController.dispose();
    super.dispose();
  }

  void _startCheckboxAnimation() {
    _checkboxController.reset();
    _checkboxController.forward();
  }

  Future<void> _fetchFyData() async {
    int todaySale = _isChecked ? 1 : 0;
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}year?year='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fyData = data;
        if (_fyData.isNotEmpty) {
          _selectedFyShortName = _fyData[0]['FyShortName'];
          _fetchData(_selectedFyShortName!, todaySale);
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
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
    const shortText = 'Sales Turnover';

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
        _currentMaxLength = 'PPMS'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  void _fetchData(String fy, int check) {
    setState(() {
      _salesData = fetchSalesData(fy, check);
    });
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
                offset: Offset(
                    offset * 30, 0), // Multiply by approximate pixel value
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
        body: InteractiveViewer(
          panEnabled: true, // Allows panning with a single finger
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = _previousScale * details.scale;
                });
              },
              onScaleEnd: (details) {
                _previousScale = _scale;
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Transform.scale(
                  scale: _scale,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 35,
                              child: TextFormField(
                                initialValue: "Turnover Summary - Month Wise",
                                readOnly: true,
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 8),
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  )),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    width: 1,
                                  )),
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 35,
                              child: DropdownButtonFormField<String>(
                                value: _selectedFyShortName,
                                items: _fyData.map<DropdownMenuItem<String>>(
                                    (dynamic item) {
                                  return DropdownMenuItem<String>(
                                    value: item['FyShortName'],
                                    child: Text(
                                      item['FyName'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFyShortName = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: "FY Year",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                                  labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: double.infinity,
                        height: 10,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isChecked = !_isChecked;
                                    _startCheckboxAnimation();
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _isChecked
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[700]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: _isChecked
                                        ? const Icon(
                                            Icons.check,
                                            key: ValueKey<bool>(true),
                                            size: 18,
                                            color: Colors.white,
                                          )
                                        : const SizedBox.shrink(
                                            key: ValueKey<bool>(false)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Exclude Today's Sale",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
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
                                      if (_selectedFyShortName != null) {
                                        int todaySale = _isChecked ? 1 : 0;
                                        _fetchData(
                                            _selectedFyShortName!, todaySale);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: FutureBuilder<List<SalesData>>(
                          future: _salesData,
                          builder: (context, snapshot) {
                            // Loading state
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: LottieLoading(
                                  size: 280,
                                  animationPath:
                                      'assets/animation/Paperplane.json',
                                ),
                              );
                            }

                            // Error state
                            if (snapshot.hasError) {
                              return const Center(
                                child: Column(
                                  children: [
                                    LottieLoading(
                                      size: 280,
                                      animationPath:
                                          'assets/animation/error.json',
                                    ),
                                    Text('Please Try Again After Some Time')
                                  ],
                                ),
                              );
                            }

                            // Data loaded but empty
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Column(
                                  children: [
                                    LottieLoading(
                                      size: 280,
                                      animationPath:
                                          'assets/animation/noData.json',
                                    ),
                                    Text('Please Try Again After Some Time')
                                  ],
                                ),
                              );
                            }

                            // Data loaded successfully
                            return SingleChildScrollView(
                              child: SalesTable(data: snapshot.data!),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ));
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
}
