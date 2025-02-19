import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
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

Future<List<StitchingDetail>> fetchOnTimeData(String from, String to, String unit) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/opration?type=STITCHING&unit=$unit&from=$from&to=$to'),
    // Uri.parse('http://172.16.10.11:8000/opration?type=FINISHING&unit=$unit&from=$from&to=$to'),
  );

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
                                            "Target Sam",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Plan Target',
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'Actual Output',
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "P&L (Line)",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "P&L (Prep)",
                                            textAlign: TextAlign.center,style: TextStyle(
                                              color: Colors.white
                                          ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            'P&L (Total)',
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
                                          padding: const EdgeInsets.only(left:4,right: 4),
                                          child: GestureDetector
                                            (onTap: ()=>print(item.dated),
                                              child: Text(item.dated.toString(),textAlign: TextAlign.start,style: TextStyle(
                                                  color: Colors.lightBlue,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: Colors.lightBlue
                                              ),)),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.targetSam.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.plannedTarget.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(item.actualOutPut.toString(),textAlign: TextAlign.end),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(item.lineProfitLoss),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(item.prepProfitLoss),
                                        )),
                                        TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(item.netProfitLoss),
                                        )),
                                      ],
                                    ),
                                  TableRow(
                                    children: [
                                      const TableCell(child:Padding(
                                        padding: EdgeInsets.only(right: 4),
                                        child: Text('',textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child:Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['targetSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['plannedTarget'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(totals['actualOutPut'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      )),
                                      TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(totals['lineProfitLoss']!,isTotal: true)
                                      )),
                                      TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(totals['prepProfitLoss']!,isTotal: true)
                                      )),
                                      TableCell(child: Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: buildCell(totals['netProfitLoss']!,isTotal: true)
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
StitchingModel createModel(BuildContext context, StitchingModel Function() modelBuilder) {
  return modelBuilder();
}
class StitchingStylePage extends StatefulWidget {
  final String fromDate;
  final String toDate;
  final String unit;

  StitchingStylePage({required this.fromDate, required this.toDate, required this.unit});

  @override
  _StitchingStylePageState createState() => _StitchingStylePageState();
}

class _StitchingStylePageState extends State<StitchingStylePage> {
  late StitchingModel _model;
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
        _cuttingDetailsFuture = fetchOnTimeData(from, to, selectedUnitCode);
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
        title: const Text('Stitchinging Profit & Loss', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                padding: const EdgeInsets.only(left:7, right:7),
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
                      child: FutureBuilder<List<StitchingDetail>>(
                        future: _cuttingDetailsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No data available');
                          } else {
                            return StitchingTable(data: snapshot.data!); // Display the table if data is available
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