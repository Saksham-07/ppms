import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/utils/constants/baseurl.dart';

class StyleWiseDetail {
  String buyer;
  String styleNo;
  String orderNo;
  double plannedPerCost;
  int cutQty;
  int totalCutQty;
  int revneue;
  int totalRevenue;

  StyleWiseDetail({
    required this.buyer,
    required this.styleNo,
    required this.orderNo,
    required this.plannedPerCost,
    required this.cutQty,
    required this.totalCutQty,
    required this.revneue,
    required this.totalRevenue,
  });

  factory StyleWiseDetail.fromJson(Map<String, dynamic> json) {
    return StyleWiseDetail(
      buyer: json['buyer'] ?? '',
      styleNo: json['styleNo'] ?? '',
      orderNo: json['orderNo'] ?? '',
      plannedPerCost: (json['plannedPerCost'] as num?)?.toDouble() ?? 0.0,
      cutQty: ((json['cutQty'] as num?)?.toInt() ?? 0),
      totalCutQty: (json['totalCutQty'] as num?)?.toInt() ?? 0,
      revneue: (json['revneue'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0
    );
  }
}

class StylewiseTable extends StatelessWidget {
  final List<StyleWiseDetail> data;

  StylewiseTable({super.key, required this.data});

  late int lent = 0;
  Map<String, int> calculateTotals() {
    int cutQty= 0;
    int totalCutQty= 0;
    int revneue= 0;
    int totalRevenue= 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      cutQty += item.cutQty;
      totalCutQty += item.totalCutQty;
      revneue += item.revneue;
      totalRevenue += item.totalRevenue;
      // Add more sums for other properties
    }

    // Return a map with property names as keys and sums as values
    return {
      'cutQty': cutQty,
      'totalCutQty': totalCutQty,
      'revneue': revneue,
      'totalRevenue': totalRevenue,
      // Add more sums for other properties
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, int> totals = calculateTotals();

    return Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: IntrinsicWidth(
                          child: Table(
                            border: TableBorder.all(color: Colors.black45),
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                                children: [
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        "Buyer\n",
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        "Style No\n",
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        'Order No\n',
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        'Planned\nCost',
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        "Today Cut \nQty",
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        "Total Cut\nQty",
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        'Today \nRevenue',
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Center(
                                      child: Text(
                                        "Total \nRevenue",
                                        textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.white
                                      ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              for (var item in data)
                                TableRow(
                                  children: [
                                    TableCell(child:Padding(
                                      padding: const EdgeInsets.only(left:4,right: 4),
                                      child: Text(item.buyer.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.styleNo.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.orderNo.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.plannedPerCost.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.cutQty.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.totalCutQty.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.revneue.toString(),textAlign: TextAlign.end),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(item.totalRevenue.toString(),textAlign: TextAlign.end),
                                    )),
                                  ],
                                ),
                              TableRow(
                                children: [
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(totals['cutQty'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                        fontWeight: FontWeight.w600
                                    ),),
                                  )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(totals['totalCutQty'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                        fontWeight: FontWeight.w600
                                    ),),
                                  )),

                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(totals['revneue'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                        fontWeight: FontWeight.w600
                                    ),),
                                  )),
                                  TableCell(child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(totals['totalRevenue'].toString(),textAlign: TextAlign.end,style: const TextStyle(
                                        fontWeight: FontWeight.w600
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
              ),
    );
  }
}
class StyleWiseModle {
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
StyleWiseModle createModel(BuildContext context, StyleWiseModle Function() modelBuilder) {
  return modelBuilder();
}
class StyleWisePage extends StatefulWidget {
  const StyleWisePage({super.key});

  @override
  _StyleWisePageState createState() => _StyleWisePageState();
}

class _StyleWisePageState extends State<StyleWisePage> {
  late StyleWiseModle _model;
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


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StyleWiseModle());
    fromDateController = TextEditingController();
    toDateController = TextEditingController();
    _loadLoginIdAndFetchData();
    _calculateDates();
    _setInitialDates();
  }

  void _calculateDates() {
    DateTime now = DateTime.now();
    toDate = now.subtract(const Duration(days: 1));

    if (now.day >= 2) {
      fromDate = DateTime(now.year, now.month, 1);
    } else {
      DateTime previousMonth = DateTime(now.year, now.month - 1, 1);
      fromDate = previousMonth;
    }
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
    if (kDebugMode) {
      print(_loginId);
    }
    if (kDebugMode) {
      print(_unit);
    }

    // Ensure _loginId is not null before proceeding
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    if (kDebugMode) {
      print('Fetching data from: $url');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        if (kDebugMode) {
          print(data);
        }
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
  Future<List<StyleWiseDetail>> fetchProdTnaData(String to, String unit) async {
    final response = await http.get(
      Uri.parse('${TBaseURL.baseUrl}stylewise?type=CUTTING&unit=$unit&to=$to&to=$to'),
      // Uri.parse('http://172.16.10.11:8000/management?proce_type=prodTna&from=$from&to=$to&units=$units'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      return jsonResponse.map((data) => StyleWiseDetail.fromJson(data)).toList();

    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  String? _selectedUnit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Cutting - Style Wise Profit & Loss',
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
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ElevatedButton(
                          onPressed: () async {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16DE48),
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
          )
      ),
    );
  }
}