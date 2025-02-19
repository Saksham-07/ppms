import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

Future<List<SalesData>> fetchSalesData(String fy,int check) async {
  print('test');
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/sales?unit=$check&year=$fy'),
  );

  print('http://14.142.248.34:10008/sales?unit=$check&year=$fy');

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
      child: Container(
        child: Row(
          children: [
            Column(
              children: [
                IntrinsicWidth(
                  child: Table(
                    border: TableBorder.all(color: Colors.black45),
                    defaultColumnWidth: IntrinsicColumnWidth(),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFF5FE3D3)),
                        children: [
                          TableCell(
                            child: Center(
                              child: Text(
                                "Buyer",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Total",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                border: TableBorder.all(color: Colors.black45),
                                defaultColumnWidth: IntrinsicColumnWidth(),
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Color(0xFF5FE3D3)),
                                    children: [
                                      for (var month in visibleMonths)
                                        TableCell(
                                          child: Center(
                                            child: Text(
                                              month,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            "Total",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white),
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
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    _getMonthValue(item, month),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        TableCell(
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6, right: 2),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  _calculateRowTotal(item)
                                                      .toString(),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 6, right: 2),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  columnSums[month]?.toString() ??
                                                      '0',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      TableCell(
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 6, right: 2),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                columnSums.values.fold(
                                                    0, (a, b) => a + b).toString(),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold),
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

class _SalesTurnOverPageState extends State<SalesTurnOverPage> {
  String _selectedTurn = "1";
  String? _selectedFyShortName;
  List<dynamic> _fyData = [];
  Future<List<SalesData>>? _salesData;
  bool _isChecked = true;
  int _checkboxValue = 1;
  double _scale = 1.0; // Default scale value
  double _previousScale = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchFyData();
  }

  Future<void> _fetchFyData() async {
    final response =
    await http.get(Uri.parse('http://14.142.248.34:10008/year?year='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fyData = data;
        if (_fyData.isNotEmpty) {
          _selectedFyShortName = _fyData[0]['FyShortName'];
          _fetchData(_selectedFyShortName!,_checkboxValue);
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _fetchData(String fy,int check) {
    setState(() {
      _salesData = fetchSalesData(fy,check);
    });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Sales Turnover',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
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
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child:Transform.scale(
            scale: _scale,
            child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 56,
                      child: TextFormField(
                        initialValue: "Turnover Summary - Month Wise",
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Turn",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 56,
                      child: DropdownButtonFormField<String>(
                        value: _selectedFyShortName,
                        items: _fyData
                            .map<DropdownMenuItem<String>>((dynamic item) {
                          return DropdownMenuItem<String>(
                            value: item['FyShortName'],
                            child: Text(
                              item['FyName'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
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
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],),
              SizedBox(width: double.infinity,height: 10,),
              Row(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Color(0xFF33C4B2),
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                            _checkboxValue = _isChecked ? 1 : 0;
                          });
                        },
                      ),
                      Text("Exclude Today's Sale"),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 12,right: 15),
                    child: Container(
                      width: 50,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedFyShortName != null) {
                            _fetchData(_selectedFyShortName!,_checkboxValue);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16DE48),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                        , child: Text('GO',style: TextStyle(
                        color: Colors.white
                      ),)
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<List<SalesData>>(
                    future: _salesData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No data available');
                      } else {
                        return SalesTable(data: snapshot.data!); // Display the table if data is available
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
            )
            ),
      )
    );
  }
}
