import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../common/utils/constants/baseurl.dart';

class Report extends StatefulWidget {
  final String? selectedUnit;

  Report({Key? key, this.selectedUnit}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<Report> {
  String? _selectedUnit;
  List<Map<String, dynamic>> _pendingAllocData = [];
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};

  @override
  void initState() {
    super.initState();
    _fetchDropDownOptions();
    _selectedUnit = widget.selectedUnit;

    // Fetch data when the unit is selected
    Future.delayed(Duration(milliseconds: 200), () {
      if (_selectedUnit != null) {
        _fetchPendingAllocData(_unitMap[_selectedUnit]!); // Fetch pending allocation data
      }
    });
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions = ['----'] + data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};

        // Automatically select the provided unit if it's valid
        if (_selectedUnit != null && _dropDownOptions.contains(_selectedUnit)) {
          _selectedUnit = _selectedUnit;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> _fetchPendingAllocData(String unitCode) async {
    final response = await http.get(Uri.parse('http://14.142.248.34:10008/pending_alloc?unit=$unitCode'));
    // final response = await http.get(Uri.parse('http://172.16.10.11:8000/pending_alloc?unit=$unitCode'));
    if (kDebugMode) {
      print('http://14.142.248.34:10008/pending_alloc?unit=$unitCode');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _pendingAllocData = List<Map<String, dynamic>>.from(data);
      });
    } else {
      throw Exception('Failed to load pending allocation data');
    }
  }

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
          'Person Unallocated',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body:  InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<String>(
                selectedItem: _selectedUnit,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Unit',
                  ),
                ),
                items: _dropDownOptions,
                itemAsString: (item) => item, // Display unit names
                onChanged: (newValue) {
                  setState(() {
                    _selectedUnit = newValue;
                  });
                  if (newValue != null && newValue != '----') {
                    _fetchPendingAllocData(_unitMap[newValue]!); // Fetch pending allocation data
                  }
                },
              ),

              SizedBox(height: 16,child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black)
                    )
                ),
              ),),
              // Table for pending allocations
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: {
                        0: FlexColumnWidth(1.5),
                        1: FlexColumnWidth(2.7),
                        2: FlexColumnWidth(2.3),
                        3: FlexColumnWidth(4.7),
                        4: FlexColumnWidth(2.5),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[200],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Pay Code', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Emp Code', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Desg', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        ..._pendingAllocData.asMap().entries.map((entry) {
                          int index = entry.key + 1;
                          var item = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(index.toString(),style: TextStyle(
                                    fontSize: 13
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['PAY_CODE'].toString(),style: TextStyle(
                                    fontSize: 13
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['EMP_CODE'].toString(),style: TextStyle(
                                    fontSize: 13
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['NAME'] != null && item['NAME']!.length > 12
                                    ? '${item['NAME']!.substring(0, 12)}..'
                                    : item['NAME'] ?? '',style: TextStyle(
                                    fontSize: 13
                                ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(item['DesignationName'].toString(),style: TextStyle(
                                    fontSize: 13
                                ),),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
