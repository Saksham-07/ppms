import 'dart:convert';
import 'package:d_chart/commons/data_model/data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ppms/Allocation/allocation.dart';
import 'package:ppms/Bars/d_chart_bar.dart';
import 'package:ppms/Stylewise/cutting_style_wise.dart';
import 'package:ppms/Stylewise/finishing_style_wise.dart';
import 'package:ppms/Stylewise/stitching_style_wise.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Audit/El_Audit/AuditHourly/el_hourly_report.dart';
import '../ManagementReview/profit_and_loss.dart';
import '../SalesComparision/sale_comparision.dart';
import '../SalesTurnover/SalesTurnOver.dart';
import '../main.dart';

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
  String? _finish;
  String? _stitching, _finishing, _total, _samToday, _samTotal, _mmrToday,
      _mmrTotal, _energy, _effToday, _effTotal, _todayTailor, _totalTailor;

  bool _isRVisible = false;
  bool isDarkMode = false;
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
      _fetchAsking();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _fetchSam('SamProduced');
      _fetchSam('MMR');
      _fetchSam('EnergyCost');
      _fetchSam('TailorSummary');
      _fetchSam('Efficiency');
    });
    checkForR();
  }

  Future<void> runFunction() async{
    await _loadLoginIdAndFetchData();
    await _calculateDates();
    await _setInitialDates();
    await _fetchProfitData();
    await _fetchAsking();
    await _fetchSam('SamProduced');
    await _fetchSam('MMR');
    await _fetchSam('EnergyCost');
    await _fetchSam('TailorSummary');
    await _fetchSam('Efficiency');
    await checkForR();
  }

  Future<void> checkForR() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    final String url = 'http://14.142.248.34:10008/base?user=$_loginId&module=Management&page=Sales_turnover';

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

  Future<void> _fetchProfitData() async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url =
        'http://14.142.248.34:10008/procedure_pnl?type=Pnl&unit=$selectedUnitCode&from=$fromDateStr&to=$toDateStr&unit_list=${_unitMap
        .values.join(",")}';


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
    }  else {
  setState(() {
  _netTodayProfit = '0';
  _netTotalProfit = '0';
  _cutting = '0';
  _stitching = '0';
  _finishing = '0';
  _total = '0';
  });
  }
}

  String? formattedDate;

  Future<void> _fetchAsking() async {
    if (_selectedUnit == null) return;

    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url = 'http://14.142.248.34:10008/asking?unit=$selectedUnitCode';


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

  Future<void> _getFinishing() async {
    if (formattedDate == null) return;

    // String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    // Example URL for the second API call
    String url = 'http://14.142.248.34:10008/finish?to=$toDateStr&ask=$formattedDate&unit=$selectedUnitCode';
    if (kDebugMode) {
      print(url);
    }


    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _finish = data[0]['AskingRatePcs'].toString();
      });
    } else {
      setState(() {
        _finish = '0';
      });
    }
  }

Future<void> _fetchSam(String type) async {
    if (_selectedUnit == null) return;

    String fromDateStr = fromDateController.text;
    String toDateStr = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    String url =
        'http://14.142.248.34:10008/procedure?proce_type=common&type=$type&unit=$selectedUnitCode&from=$fromDateStr&to=$toDateStr';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        if (type == 'SamProduced') {
          _samToday = data[0]['TodaySam'].toString();
          _samTotal = data[0]['TotalSam'].toString();
        }
        else if (type == 'MMR') {
          _mmrToday = double.parse(data[0]['MMRToday'].toString()).toStringAsFixed(2);
          _mmrTotal = double.parse(data[0]['MMRTotal'].toString()).toStringAsFixed(2);
        }
        else if (type == 'EnergyCost') {
          _energy = double.parse(data[0]['TotalValue'].toString()).toStringAsFixed(2);
        }
        else if (type == 'Efficiency') {
          _effToday = double.parse(data[0]['TodayEff'].toString()).toStringAsFixed(2);
          _effTotal = double.parse(data[0]['TotalEff'].toString()).toStringAsFixed(2);
        }
        else if (type == 'TailorSummary') {
          _todayTailor = data[0]['TailorPresentToday'].toString();
          _totalTailor = data[0]['TailorPresentTotal'].toString();
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

    // Ensure _loginId is not null before proceeding
    final String url = 'http://14.142.248.34:10008/unit?type=permissions&user=$_loginId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
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
        builder: (context) => SaleComparison(),
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

  String? _selectedUnit;


  @override
  Widget build(BuildContext context) {
    List<OrdinalGroup> chartData = [
      OrdinalGroup(
        id: '1',
        data: [
          OrdinalData(domain: '20', measure: 470000),
          OrdinalData(domain: '30', measure: 600000),
          OrdinalData(domain: '40', measure: 420000),
          OrdinalData(domain: '50', measure: 550000),
          OrdinalData(domain: '60', measure: 650000),
        ],
        color: Colors.orangeAccent,
      ),


      OrdinalGroup(
        id: '2',
        data: [
          OrdinalData(domain: '20', measure: 330000),
          OrdinalData(domain: '30', measure: 400000),
          OrdinalData(domain: '40', measure: 500000),
          OrdinalData(domain: '50', measure: 460000),
          OrdinalData(domain: '60', measure: 560000),
        ],
        color: Colors.redAccent,
      ),

      OrdinalGroup(
        id: '3',
        data: [
          OrdinalData(domain: '20', measure: 210000),
          OrdinalData(domain: '30', measure: 300000),
          OrdinalData(domain: '40', measure: 700000),
          OrdinalData(domain: '50', measure: 520000),
          OrdinalData(domain: '60', measure: 420000),
        ],
        color: Colors.greenAccent,
      ),
    ];
    return GestureDetector(
      onTap: () =>
      _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF5FE3D3),
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
          actions: [
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.blueGrey[100],
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image:  DecorationImage(
                      image: AssetImage('assets/images/logo.jpeg'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: null,
                ),
                // ListTile(
                //   leading: Icon(Icons.assignment_late_outlined),
                //   title: Text('Line Allocation'),
                //   onTap: () => navigateToAllocation(context),
                // ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Logout'),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn', false);
                    String? unique;
                    unique = prefs.getString('uniqueID');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter', uniqueID: unique,)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 5),
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
                      horizontal: 16, vertical: 5),
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
                            await _fetchProfitData();
                            await _fetchSam('SamProduced');
                            await _fetchSam('MMR');
                            await _fetchSam('EnergyCost');
                            await _fetchSam('TailorSummary');
                            await _fetchSam('Efficiency');
                            await _fetchAsking();
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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 5),
                                  child: InkWell(
                                    // onTap: () => isDarkMode ? print('erwe') : navigateToProfitAndLoss(context), // Original onTap function
                                    onTap: () =>navigateToProfitAndLoss(context), // Original onTap function
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: 2,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                                              offset: Offset(0, 2),
                                              spreadRadius: 0.2,
                                            ),
                                          ],
                                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                                          border: Border.all(
                                            color: const Color(0xFF07F8C9),
                                            width: 0.2,
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: isDarkMode
                                                  ? const AspectRatio(
                                                aspectRatio: 6,
                                                child: Padding(
                                                  padding: EdgeInsets.all(.0),
                                                  child: DChartBar(dataGroups: [],barWidth: 200,unit: '',),
                                                ),
                                              )
                                                  : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(top: 6),
                                                    child: Text(
                                                      'Management Review',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: 'Readex Pro',
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: _netTodayProfit ?? '0',
                                                            style: TextStyle(
                                                              color: _getProfitColor(_netTodayProfit),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: 'Readex Pro',
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const TextSpan(
                                                            text: ' / ',
                                                            style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: 'Readex Pro',
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: _netTotalProfit ?? '0',
                                                            style: TextStyle(
                                                              color: _getProfitColor(_netTotalProfit),
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: 'Readex Pro',
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Switch in the Top-Right Corner
                                            // Positioned(
                                            //   top: -8,
                                            //   right: -8,
                                            //   child: Transform.scale(
                                            //     scale: 0.55, // Adjusted the scale for a smaller switch
                                            //     child: Switch(
                                            //       value: isDarkMode,
                                            //       onChanged: (value) {
                                            //         setState(() {
                                            //           isDarkMode = value;
                                            //         });
                                            //       },
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(6, 10, 6, 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional
                                        .fromSTEB(
                                        6, 0, 6, 0),
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
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          6, 0, 4, 0),
                                      child: GestureDetector(
                                        onTap: ()=> navigateToCutting(context,_selectedUnit!),
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
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
                                      child: GestureDetector(
                                        onTap: ()=>navigateToStitch(context,_selectedUnit!),
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
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          6, 0, 4, 0),
                                      child: GestureDetector(
                                        onTap: ()=> navigateToFinish(context,_selectedUnit!),
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
                                  ),
                                  Expanded(
                                      flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
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
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          6, 0, 4, 0),
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
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
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
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          6, 0, 4, 0),
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
                                                    'Tailor Smry',
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
                                    flex:2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
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
                                                    'Efficiency(%)',
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
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          6, 0, 4, 0),
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
                                                    'Finish Asking',
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
                                                    _finish ?? '0',
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
                                  Expanded(
                                    flex: 2,
                                    child: Visibility(
                                      visible: _isRVisible,
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(
                                            4, 0, 6, 0),
                                        child: GestureDetector(
                                          onTap: ()=> navigateToSales(context),
                                          // onTap: () => navigateToSales(context),
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
                                              child: const Text(
                                                  'Sales Turnover',textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .w500,
                                                    fontFamily: 'Readex Pro',
                                                    fontSize: 20,
                                                    letterSpacing: 0,
                                                  )
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if(_loginId == '0552482')
                          Align(
                            alignment: const AlignmentDirectional(-1, -1),
                            child: Padding(
                              padding:
                              const EdgeInsetsDirectional.fromSTEB(
                                  6, 10, 6, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
                                      child: GestureDetector(
                                        onTap: ()=>navigateToBar(context,_selectedUnit!),
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
                                            child: const Text(
                                                'Line Allocation',textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .w500,
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 20,
                                                  letterSpacing: 0,
                                                )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional
                                          .fromSTEB(
                                          4, 0, 6, 0),
                                      child: GestureDetector(
                                        onTap: ()=> navigateToBar2(context),
                                        // onTap: () => navigateToSales(context),
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
                                            child: const Text(
                                                'Sales Turnover',textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight
                                                      .w500,
                                                  fontFamily: 'Readex Pro',
                                                  fontSize: 20,
                                                  letterSpacing: 0,
                                                )
                                            ),
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