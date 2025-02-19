import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../StylewiseDropdown/cutting_datewise.dart';

class CuttingDetail {
  final String dated;
  final String date;
  final int cost;
  final int manPower;
  final int oTAmt;
  final double oThrs;
  final int profitLoss;
  final int qty;
  final int revenue;
  final bool isHoliday;
  final bool isWeekOff;

  CuttingDetail({
    required this.dated,
    required this.date,
    required this.cost,
    required this.manPower,
    required this.oTAmt,
    required this.oThrs,
    required this.profitLoss,
    required this.qty,
    required this.revenue,
    required this.isHoliday,
    required this.isWeekOff,
  });

  factory CuttingDetail.fromJson(Map<String, dynamic> json) {
    String? startDateStr = json['Dated'];

    String formattedDate;
    String date;
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        // Parse the date string using DateFormat
        DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
        DateTime startDate = inputFormat.parseUTC(startDateStr);

        // Format the date
        date = DateFormat('yyyy-MM-dd').format(startDate);
        formattedDate = DateFormat('MMM d, yyyy').format(startDate);
      } catch (e) {
        formattedDate = '';
        date = '';
      }
    } else {
      formattedDate = '';
      date = '';
    }

    return CuttingDetail(
      dated: formattedDate,
      date: date,
      cost: (json['Cost'] as num?)?.toInt() ?? 0,
      manPower: (json['Manpower'] as num?)?.toInt() ?? 0,
      oTAmt: (json['OTAmt'] as num?)?.toInt() ?? 0,
      oThrs: (json['OThrs'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['ProfitLoss'] as num?)?.toInt() ?? 0,
      qty: (json['Qty'] as num?)?.toInt() ?? 0,
      revenue: (json['Revenue'] as num?)?.toInt() ?? 0,
      isHoliday: json['IsHoliday'],
      isWeekOff: json['IsWeekOff'],
    );
  }
}

Future<List<CuttingDetail>> fetchCuttingData(String from, String to, String unit) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/opration?type=CUTTING&unit=$unit&from=$from&to=$to'),
    // Uri.parse('http://172.16.10.11:8000/opration?type=CUTTING&unit=$unit&from=$from&to=$to'),
  );

  print('http://14.142.248.34:10008/opration?type=CUTTING&unit=$unit&from=$from&to=$to');

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
    MaterialPageRoute(builder: (context) => CuttingStylePage(fromDate: fromDate, toDate: toDate,unit: unit)),
  );
}

class CuttingTable extends StatelessWidget {
  final List<CuttingDetail> data;
  final String? unit;

  CuttingTable({required this.data, required this.unit});

  late int lent = 0;
  Map<String, dynamic> calculateTotals() {
    int cost = 0;
    int manPower = 0;
    int oTAmt = 0;
    double oThrs = 0;
    int profitLoss = 0;
    int qty = 0;
    int revenue = 0;

    for (var item in data) {
      cost += item.cost;
      manPower += item.manPower;
      oTAmt += item.oTAmt;
      oThrs += item.oThrs;
      profitLoss += item.profitLoss;
      qty += item.qty;
      revenue += item.revenue;
    }
    // Return a map with property names as keys and sums as values
    return {
      'cost': cost,
      'manPower': manPower,
      'oTAmt': oTAmt,
      'oThrs': double.parse(oThrs.toStringAsFixed(2)),
      'profitLoss': profitLoss,
      'qty': qty,
      'revenue': revenue,
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
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "Dated",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            " Qty ",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            '  Revenue  ',
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            '  Manpower  ',
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "  OT Hours  ",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "  OT Amount  ",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            '  Cost  ',
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "  Profit Loss  ",
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
                                      decoration: BoxDecoration(
                                        color: item.isHoliday || item.isWeekOff
                                            ? Color(0xD07BF3E8)
                                            : Colors.transparent,
                                      ),
                                      children: [
                                        TableCell(child:Padding(
                                          padding: const EdgeInsets.only(left: 4,right: 4),
                                          child: GestureDetector(
                                            onTap: ()=>Navigator.push(context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>  CuttingStyleDropPage(fromDate: item.date, toDate: item.date, unit: unit!)
                                                          ),),
                                            child: Text(item.dated.toString(),textAlign: TextAlign.start,style: TextStyle(
                                                color: Colors.lightBlue,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Colors.lightBlue
                                            ),),
                                          ),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.qty.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.revenue.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.manPower.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.oThrs.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.oTAmt.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.cost.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(item.profitLoss),
                                        )),
                                      ],
                                    ),
                                  TableRow(
                                    decoration: BoxDecoration(color: Colors.green[300]),
                                    children: [
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['qty'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['revenue'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['manPower'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['oThrs'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['oTAmt'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['cost'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: buildCell(totals['profitLoss']!,isTotal: true)
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
class CuttingStylePage extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final String unit;

  CuttingStylePage({required this.fromDate, required this.toDate, required this.unit});

  @override
  _CuttingStylePageState createState() => _CuttingStylePageState();
}

class _CuttingStylePageState extends State<CuttingStylePage> {
  late CuttingModel _model;
  late DateTime fromDate;
  late DateTime toDate;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? management;
  String? _selectedUnit;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _loginId;
  String? _unit;
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
    final String url = 'http://14.142.248.34:10008/unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions = data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};

        // Set the selected unit based on the provided widget.unit
        if (_dropDownOptions.contains(widget.unit)) {
          _selectedUnit = widget.unit;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }

        saveUnitMapToSharedPreferences(_unitMap);
        _fetchData();
      });
    } else {
      print('Failed to load options');
    }
  }

  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  void _fetchData() {
    String from = fromDateController.text;
    String to = toDateController.text;
    String selectedUnitCode = _unitMap[_selectedUnit]!;
    if (_selectedUnit != null) {
      setState(() {
        _cuttingDetailsFuture = fetchCuttingData(from, to, selectedUnitCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5FE3D3),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Cutting Profit & Loss', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
          top: true,
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            panAxis: PanAxis.free,
            minScale: 1.0,
            maxScale: 4.0,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            fromDateController.text = DateFormat('yyyy-MM-dd').format(fromDate);
                                          });
                                        }
                                      },
                                      child: const Icon(Icons.date_range_outlined, color: Colors.grey, size: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            toDateController.text = DateFormat('yyyy-MM-dd').format(toDate);
                                          });
                                        }
                                      },
                                      child: const Icon(Icons.date_range_outlined, color: Colors.grey, size: 24),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              items: _dropDownOptions.map<DropdownMenuItem<String>>((String value) {
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
                                  borderSide: const BorderSide(color: Color(0xFF605E5E)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                            ),
                          ),
                        ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ElevatedButton(
                  onPressed: _fetchData,
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
                  child: SingleChildScrollView(
                    child: FutureBuilder<List<CuttingDetail>>(
                      future: _cuttingDetailsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('No data available');
                        } else {
                          return CuttingTable(data: snapshot.data! , unit: _selectedUnit,); // Display the table if data is available
                        }
                      },
                    ),
                  ),
                ),
                  ]
                ),
          )
      ),
    );
  }
}