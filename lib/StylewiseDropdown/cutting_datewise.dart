import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class CuttingDetail {
  final String buyer;
  final String order;
  final String style;
  final int cutQty;
  final double plannedPerCost;
  final int revenue;
  final int totalCutQty;
  final int totalRevenue;

  CuttingDetail({
    required this.buyer,
    required this.order,
    required this.style,
    required this.cutQty,
    required this.plannedPerCost,
    required this.revenue,
    required this.totalCutQty,
    required this.totalRevenue,
  });

  factory CuttingDetail.fromJson(Map<String, dynamic> json) {

    return CuttingDetail(
      buyer: json['Buyer']?.toString() ?? '', // Use empty string if null
      order: json['OrderNo']?.toString() ?? '', // Use empty string if null
      style: json['StyleNo']?.toString() ?? '', // Use empty string if null
      cutQty: (json['CutQty'] as num?)?.toInt() ?? 0, // Default to 0 if null
      plannedPerCost: (json['PlannedPerCost'] as num?)?.toDouble() ?? 0.00, // Default to 0.00 if null
      revenue: (json['Revneue'] as num?)?.toInt() ?? 0, // Default to 0 if null
      totalCutQty: (json['TotalCutQty'] as num?)?.toInt() ?? 0, // Default to 0 if null
      totalRevenue: (json['TotalRevenue'] as num?)?.toInt() ?? 0, // Default to 0 if null
    );
  }
}

Future<List<CuttingDetail>> fetchCuttingData(String to, String unit, String vgUnit) async {
  DateTime toDate = DateTime.parse(to);

  // Calculate the 'from' date as the first day of the same month as 'to'
  String from = DateTime(toDate.year, toDate.month, 1).toIso8601String().split('T')[0];

  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}stylewise_vg?type=CUTTING&vgUnit=$vgUnit&from=$from&to=$to&unit=$unit'),
  );
  print('${TBaseURL.baseUrl}stylewise_vg?type=CUTTING&vgUnit=$vgUnit&from=$from&to=$to&unit=$unit');

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => CuttingDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

void navigateToCutting(BuildContext context, String fromDate, String toDate,String unit) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CuttingStyleDropPage(fromDate: fromDate, toDate: toDate,unit: unit)),
  );
}

class CuttingTable extends StatelessWidget {
  final List<CuttingDetail> data;

  CuttingTable({required this.data});

  late int lent = 0;
  Map<String, dynamic> calculateTotals() {
    int cost = 0;
    int totalCutQty = 0;
    int revenue = 0;
    int totalRevenue = 0;

    for (var item in data) {
      cost += item.cutQty;
      totalCutQty += item.totalCutQty;
      totalRevenue += item.totalRevenue;
      revenue += item.revenue;
    }
    // Return a map with property names as keys and sums as values
    return {
      'cost': cost,
      'totalCutQty': totalCutQty,
      'revenue': revenue,
      'totalRevenue': totalRevenue,
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
        child: Row(
            children:[
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
                                border: TableBorder.all(color: Colors.black45),
                                defaultColumnWidth: const IntrinsicColumnWidth(),
                                children: [
                                   TableRow(
                                    decoration: BoxDecoration(color: Colors.grey[700]),
                                    children: const [
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              "Buyer",
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              "Style",
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              'Order',
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              'Planned\nCost',
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              "Today Cutting\nCost",
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              "Total Cutting\nCost",
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              'Today\nRevenue',
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0, right : 8),
                                          child: Center(
                                            child: Text(
                                              "Total\nRevenue",
                                              textAlign: TextAlign.center,style: TextStyle(
                                                color: Colors.white
                                            ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                  for (var item in data)
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color : Colors.transparent,
                                      ),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                                            child: Text(
                                              item.buyer.length > 15 ? '${item.buyer.substring(0, 15)}..' : item.buyer,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                            ),
                                          ),
                                        ),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8),
                                          child: Text(item.style.toString(),textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 8.0,right: 8),
                                          child: Text(item.order.toString(),textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(item.plannedPerCost.toStringAsFixed(2),textAlign: TextAlign.end,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(item.cutQty.toString(),textAlign: TextAlign.end,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(item.totalCutQty.toString(),textAlign: TextAlign.end,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(item.revenue.toString(),textAlign: TextAlign.end,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Text(item.totalRevenue.toString(),textAlign: TextAlign.end,
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                        )),
                                      ],
                                    ),
                                  TableRow(
                                    decoration: const BoxDecoration(color: Color(0xFF8DEAA3)),
                                    children: [
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                        ),),
                                      )),
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['cost'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          color: Colors.black
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['totalCutQty'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['revenue'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          color: Colors.black
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['totalRevenue'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black
                                        ),),
                                      )),
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
            ]
        )
    );
  }
}

class CuttingModel {
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
CuttingModel createModel(BuildContext context, CuttingModel Function() modelBuilder) {
  return modelBuilder();
}
class CuttingStyleDropPage extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final String unit;

  CuttingStyleDropPage({super.key, required this.fromDate, required this.toDate, required this.unit});

  @override
  _CuttingStyleDropPageState createState() => _CuttingStyleDropPageState();
}

class _CuttingStyleDropPageState extends State<CuttingStyleDropPage> with TickerProviderStateMixin {
  late CuttingModel _model;
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? management;
  String? _selectedUnit;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {},_unitMapVg = {};
  String? _loginId;
  String? _unit;
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
  Future<List<CuttingDetail>>? _cuttingDetailsFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CuttingModel());
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
    const shortText = 'Cutting Profit & Loss';

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
        _currentMaxLength = 'Cutting Profit & Loss'.length;
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
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitCode'].toString()
        };

        // Set the selected unit
        if (_dropDownOptions.contains(widget.unit)) {
          _selectedUnit = widget.unit;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
        _fetchData();
        saveUnitMapToSharedPreferences(_unitMap);
      });
    } else {
      // Handle error
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  void _fetchData() {
    String to = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String selectedUnitCodeVg = _unitMapVg[_selectedUnit]!;

    if (_selectedUnit != null) {
      setState(() {
        _cuttingDetailsFuture = fetchCuttingData(to, selectedUnitCode,selectedUnitCodeVg);
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
                  fontSize: _showFullTitle ? 17 : 18,
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
            child: Container(
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 35,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _showRGBBorder ? _borderColor : Colors.black26,
                                    width: _showRGBBorder ? 2 : 1,
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedUnit,
                                  dropdownColor: Theme.of(context).cardColor.withValues(alpha: 0.8),
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
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1), // Remove default border
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
                                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1), // Remove default border
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                          controller: toDateController,
                                          decoration: const InputDecoration(
                                            hintText: 'To Date',
                                            border: InputBorder.none,
                                          ),
                                          readOnly: true,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final DateTime? datePicked2 = await showDatePicker(
                                            context: context,
                                            initialDate: toDate,
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2050),
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
                                          if (datePicked2 != null) {
                                            setState(() {
                                              toDate = datePicked2;
                                              toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);
                                            });
                                          }
                                        },
                                        child: Icon(Icons.date_range_outlined, color:
                                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7), size: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
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
                                        _fetchData();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [

                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: FutureBuilder<List<CuttingDetail>>(
                          future: _cuttingDetailsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                  width: double.infinity,
                                  child: LottieLoading(size: 250,animationPath: 'assets/animation/Paperplane.json',));
                            } else if (snapshot.hasError) {
                              return const LottieLoading(size: 250,animationPath: 'assets/animation/error.json',);
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const LottieLoading(size: 250,animationPath: 'assets/animation/noData.json',);
                            } else {
                              return CuttingTable(data: snapshot.data!); // Display the table if data is available
                            }
                          },
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          )
      ),
    );
  }
  Color _borderColor = Colors.black26;
  bool _showRGBBorder = false;
  int _currentRGBIndex = 0;
  final List<Color> _rgbColors = [
    Colors.grey[100]!,
    Colors.grey[200]!,
    Colors.grey[300]!,
    Colors.grey[400]!,
    Colors.grey[500]!,
    Colors.grey[600]!,
    Colors.grey[700]!,
    Colors.grey[800]!,
    Colors.grey[900]!,
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