import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfitAndLoss.dart';

// Define the MainDashboardModel class and createModel function
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

class _MainDashboardWidgetState extends State<MainDashboardWidget> {
  late MainDashboardModel _model;
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? management;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _loginId;
  String? _unit;
  String? _netTodayProfit;
  String? _netTotalProfit;
  String? _cutting;
  String? _stitching, _finishing, _total, _samToday, _samTotal, _mmrToday,
      _mmrTotal, _energy, _effToday, _effTotal, _todayTailor, _totalTailor;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDashboardModel());
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    _loadLoginIdAndFetchData();
    _calculateDates();
    _setInitialDates();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _fetchProfitData();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _fetchSam('SamProduced');
      _fetchSam('MMR');
      _fetchSam('EnergyCost');
      _fetchSam('TailorSummary');
      _fetchSam('Efficiency');
    });
  }

  void _calculateDates() {
    DateTime now = DateTime.now();
    toDate = now.subtract(Duration(days: 1));

    if (now.day >= 2) {
      fromDate = DateTime(now.year, now.month, 1);
    } else {
      DateTime previousMonth = DateTime(now.year, now.month - 1, 1);
      fromDate = previousMonth;
    }
  }

  Future<void> _fetchProfitData() async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url =
        'http://172.16.0.5:10008/procedure_pnl?type=Pnl&unit=$selectedUnitCode&from=$fromDateStr&to=$toDateStr&unit_list=${_unitMap
        .values.join(",")}';

    print('Fetching profit data from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _netTodayProfit = data[0]['NetTodayProfit'].toString();
        _netTotalProfit = data[0]['NetTotalProfit'].toString();
        _cutting = data[0]['CutPnL'].toString();
        _stitching = data[0]['StitchPnL'].toString();
        _finishing = data[0]['FinishPnL'].toString();
        _total = data[0]['TotalPnL'].toString();
      });
    } else {
      setState(() {
        _netTodayProfit = 'Error';
        _netTotalProfit = 'Error';
      });
    }
  }


  Future<void> _fetchSam(String type) async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url =
        'http://172.16.0.5:10008/procedure?proce_type=common&type=$type&unit=$selectedUnitCode&from=$fromDateStr&to=$toDateStr';

    print('Fetching profit data from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        if (type == 'SamProduced') {
          _samToday = data[0]['TodaySam'].toString();
          _samTotal = data[0]['TotalSam'].toString();
        }
        else if (type == 'MMR') {
          _mmrToday = data[0]['MMRToday'].toString();
          _mmrTotal = data[0]['MMRTotal'].toString();
        }
        else if (type == 'EnergyCost') {
          _energy = data[0]['TotalValue'].toString();
        }
        else if (type == 'Efficiency') {
          _effToday = data[0]['TodayEff'].toString();
          _effTotal = data[0]['TotalEff'].toString();
        }
        else if (type == 'TailorSummary') {
          _todayTailor = data[0]['TailorPresentToday'].toString();
          _totalTailor = data[0]['TailorPresentTotal'].toString();
        }
      });
    } else {
      setState(() {
        _samTotal = 'Error';
        _samToday = 'Error';
        _mmrTotal = 'Error';
        _mmrToday = 'Error';
        _energy = 'Error';
        _effToday = 'Error';
        _effTotal = 'Error';
        _todayTailor = 'Error';
        _totalTailor = 'Error';
      });
    }
  }


  Color _getProfitColor(String? profit) {
    if (profit == null) return Colors.black;
    double value = double.tryParse(profit) ?? 0;
    return value < 0 ? Colors.red : Colors.green;
  }


  void _setInitialDates() {
    fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate);
    toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
    print(_loginId);
    print(_unit);

    // Ensure _loginId is not null before proceeding
    final String url = 'http://172.16.0.5:10008/unit?type=permissions&user=$_loginId';
    print('Fetching data from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        print(data);
        _dropDownOptions =
            data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {
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
      print('Failed to load options');
    }
  }

  void navigateToProfitAndLoss(BuildContext context) {
    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfitAndLossScreen(fromDate: fromDateStr, toDate: toDateStr,))
    );
  }

  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  String? _selectedUnit;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
      _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF5FE3D3),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Paramount Product Management System',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: fromDateController,
                                      decoration: const InputDecoration(
                                        hintText: 'From Date',
                                        border: InputBorder.none,
                                      ),
                                      readOnly: true,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? datePicked1 = await showDatePicker(
                                        context: context,
                                        initialDate: fromDate,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                      );
                                      if (datePicked1 != null) {
                                        setState(() {
                                          fromDate = datePicked1;
                                          fromDateController.text =
                                              DateFormat('yyyy-MM-dd').format(
                                                  fromDate);
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.date_range_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
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
                                      );
                                      if (datePicked2 != null) {
                                        setState(() {
                                          toDate = datePicked2;
                                          toDateController.text =
                                              DateFormat('yyyy-MM-dd').format(
                                                  toDate);
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.date_range_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            items: _dropDownOptions.map<
                                DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontFamily: 'Readex Pro',
                                    color: Color(0xFF13171A),
                                    fontSize: 16,
                                    letterSpacing: 0,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue!;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF5EFEF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFF605E5E)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ElevatedButton(
                          onPressed: () async {
                            String? selectedUnitCode = _unitMap[_selectedUnit];
                            print('From Date: ${fromDateController.text}');
                            print('To Date: ${toDateController.text}');
                            print('Selected Unit Code: $selectedUnitCode');
                            await _fetchProfitData();
                            await _fetchSam('SamProduced');
                            await _fetchSam('MMR');
                            await _fetchSam('EnergyCost');
                            await _fetchSam('TailorSummary');
                            await _fetchSam('Efficiency');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16DE48),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Go',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Readex Pro',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SingleChildScrollView(
                            child: InkWell(
                              child: Padding(
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    16, 10, 16, 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(
                                            12, 0, 12, 0),
                                        child: Material(
                                          color: Colors.transparent,
                                          elevation: 2,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Container(
                                            width: 300,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 1,
                                                  color: Color(0xC212F3B0),
                                                  offset: Offset(
                                                    0,
                                                    2,
                                                  ),
                                                  spreadRadius: 0.2,
                                                )
                                              ],
                                              borderRadius: const BorderRadius
                                                  .only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFF07F8C9),
                                                width: 0.2,
                                              ),
                                            ),
                                            alignment: const AlignmentDirectional(
                                                0, 0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 6, 0, 0),
                                                  child: Text(
                                                    'Management Review',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 16,
                                                      vertical: 8),
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: _netTodayProfit ??
                                                              '0',
                                                          style: TextStyle(
                                                            color: _getProfitColor(
                                                                _netTodayProfit),
                                                            fontWeight: FontWeight
                                                                .w500,
                                                            fontFamily: 'Readex Pro',
                                                            fontSize: 16,
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                        const TextSpan(
                                                          text: ' / ',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight: FontWeight
                                                                .w500,
                                                            fontFamily: 'Readex Pro',
                                                            fontSize: 16,
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: _netTotalProfit ??
                                                              '0',
                                                          style: TextStyle(
                                                            color: _getProfitColor(
                                                                _netTotalProfit),
                                                            fontWeight: FontWeight
                                                                .w500,
                                                            fontFamily: 'Readex Pro',
                                                            fontSize: 16,
                                                            letterSpacing: 0,
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
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => navigateToProfitAndLoss(context),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional
                                        .fromSTEB(
                                        12, 0, 12, 0),
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: 2,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Container(
                                        width: 319,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 1,
                                              color: Color(0xC212F3B0),
                                              offset: Offset(
                                                0,
                                                2,
                                              ),
                                              spreadRadius: 0.2,
                                            )
                                          ],
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF07F8C9),
                                            width: 0.2,
                                          ),
                                        ),
                                        alignment: const AlignmentDirectional(
                                            0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0, 6, 0, 0),
                                              child: Text(
                                                  'Sam Produced',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Readex Pro',
                                                    fontSize: 20,
                                                    letterSpacing: 0,
                                                  )
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 16, vertical: 8),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: _samToday ?? '0',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        fontFamily: 'Readex Pro',
                                                        fontSize: 16,
                                                        letterSpacing: 0,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' / ',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        fontFamily: 'Readex Pro',
                                                        fontSize: 16,
                                                        letterSpacing: 0,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: _samTotal ?? '0',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight: FontWeight
                                                            .w500,
                                                        fontFamily: 'Readex Pro',
                                                        fontSize: 16,
                                                        letterSpacing: 0,
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
                                ),
                              ],
                            ),
                          ),

                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  16, 10, 16, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Cutting P&L',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: Text(
                                                    _cutting ?? '0',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 16,
                                                      letterSpacing: 0,
                                                      color: _getProfitColor(
                                                          _cutting),
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Stitching P&L',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: Text(
                                                    _stitching ?? '0',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      color: _getProfitColor(
                                                          _stitching),
                                                      fontSize: 16,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  16, 10, 16, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Finishing P&L',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: Text(
                                                    _finishing ?? '0',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 16,
                                                      color: _getProfitColor(
                                                          _finishing),
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Total P&L',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: Text(
                                                    _total ?? '0',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      color: _getProfitColor(
                                                          _total),
                                                      fontSize: 16,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  16, 10, 16, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'MMR',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: _mmrToday ?? '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' / ',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: _mmrTotal ?? '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
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
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Energy Cost',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: Text(
                                                    _energy ?? '0',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      color: Colors.blue,
                                                      fontSize: 16,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  16, 10, 16, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Tailor Summary',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: _todayTailor ??
                                                            '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' / ',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: _totalTailor ??
                                                            '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
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
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          12, 0, 12, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Container(
                                          width: 319,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 1,
                                                color: Color(0xC212F3B0),
                                                offset: Offset(
                                                  0,
                                                  2,
                                                ),
                                                spreadRadius: 0.2,
                                              )
                                            ],
                                            borderRadius: const BorderRadius
                                                .only(
                                              bottomLeft: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF07F8C9),
                                              width: 0.2,
                                            ),
                                          ),
                                          alignment: const AlignmentDirectional(
                                              0, 0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 6, 0, 0),
                                                child: Text(
                                                    'Efficiency (%)',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight
                                                          .w500,
                                                      fontFamily: 'Readex Pro',
                                                      fontSize: 20,
                                                      letterSpacing: 0,
                                                    )
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(0, 8, 0, 0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: _effToday ?? '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text: ' / ',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: _effTotal ?? '0',
                                                        style: const TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight: FontWeight
                                                              .w500,
                                                          fontFamily: 'Readex Pro',
                                                          fontSize: 16,
                                                          letterSpacing: 0,
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
              ]
          ),
        ),
      ),
    );
  }


}