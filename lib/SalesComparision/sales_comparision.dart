import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Bars/bar3.dart';
import '../common/utils/constants/baseurl.dart';

class SalesComparision extends StatefulWidget {
  @override
  _SalesComparisionState createState() => _SalesComparisionState();
}

class _SalesComparisionState extends State<SalesComparision> {
  String selectedRadioValue = '1';
  String? _selectedOption;
  int? _selectedValue;
  String? _selectedFyShortName;
  String? _selectedBuyerOption;
  List<dynamic> _fyData = [];
  List<dynamic> _buyerData = [];
  bool _showBarChart = false;
  List<Map<String, dynamic>> barData = [];

  @override
  void initState() {
    super.initState();
    _selectedOption = '--';
    _selectedValue = 0;
    _fetchFyData();
  }

  Future<void> _fetchFyData() async {
    final response =
    await http.get(Uri.parse('${TBaseURL.baseUrl}year?year='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fyData = data;
        if (_fyData.isNotEmpty) {
          _selectedFyShortName = _fyData[0]['FyShortName'];
        }
      });
      _fetchBuyerData(_selectedFyShortName!);
    } else {
      throw Exception('Failed to load FY data');
    }
  }

  Future<void> _fetchBuyerData(String fy) async {
    // final String fy = _selectedFyShortName ?? '';
    print('rgr');
    final response =
    await http.get(Uri.parse('http://172.16.10.11:8001/sales_buyer?fy=$fy'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _buyerData = data;
      });
    } else {
      throw Exception('Failed to load buyer data');
    }
  }

  Future<void> _fetchSalesData() async {
    final String fy = _selectedFyShortName ?? '';
    final String buyer = _selectedBuyerOption ?? '';
    final int type = _selectedValue ?? 0;
    int vise = int.parse(selectedRadioValue);

    if (type == 2) {
      vise = 0;
    }

    const String url =
        'http://172.16.10.11:8001/sales_comp?report_for=monthWise&report_type=value';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        barData = data.map<Map<String, dynamic>>((item) {
          String label;
          double maxY = 0;
          switch (vise) {
            case 1:
              String truncatedName = item['MonthName'].length > 4
                  ? item['MonthName'].substring(0, 3)
                  : item['MonthName'];
              label = truncatedName;
              maxY = 100.0;
              break;
            case 2:
              int q = item['QuarterNo'];
              if(q == 1){
                label = 'Apr-June';
              }else if(q == 2){
                label = 'July-Sep';
              }else if(q == 3){
                label = 'Oct-Dec';
              }else if(q == 4) {
                label = 'Jan-Mar';
              }else{
                label = '';
              }
              maxY = 300.0;
              break;
            case 3:
              label = item['FYear'];
              maxY = 800.0;
              break;
            default:
              label = '';
          }

          if (type == 2) {
            label = item['Merchandiser'].length > 7
                ? item['Merchandiser'].substring(0, 7)
                : item['Merchandiser'];
          }

          return {
            'index': data.indexOf(item),
            'turnoverValue': item['TurnoverValue'],
            'qty': item['Qty'],
            'turnoverBar': item['TurnoverBar'], // New value
            'qtyBar': item['QtyBar'], // New value
            'maxY': maxY, // New value for maxY
            'label': label,
          };
        }).toList();
        _showBarChart = true;
      });
    } else {
      throw Exception('Failed to load sales data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sending Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedOption,
                    items: [
                      '--',
                      'Buyer wise',
                      'DGM wise'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                        if (newValue == 'Buyer wise') {
                          _selectedValue = 1;
                        } else if (newValue == 'DGM wise') {
                          _selectedValue = 2;
                        } else {
                          _selectedValue = 0;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Option",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFyShortName,
                    items: _fyData.isNotEmpty
                        ? _fyData.map<DropdownMenuItem<String>>((dynamic item) {
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
                    }).toList()
                        : [],
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
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedOption == 'Buyer wise') ...[
              DropdownButtonFormField<String>(
                value: _selectedBuyerOption,
                items: _buyerData.isNotEmpty
                    ? _buyerData.map<DropdownMenuItem<String>>((dynamic item) {
                  String truncatedName = item['BuyerName'].length > 15
                      ? item['BuyerName'].substring(0, 15)
                      : item['BuyerName'];
                  return DropdownMenuItem<String>(
                    value: item['BuyerCode'],
                    child: Text(
                      truncatedName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBuyerOption = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Select Buyer Option",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(right: 12, left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: '1',
                        groupValue: selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRadioValue = value!;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('Monthly', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: '2',
                        groupValue: selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRadioValue = value!;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('Quarterly', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: '3',
                        groupValue: selectedRadioValue,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRadioValue = value!;
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('Yearly', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _fetchSalesData(); // Fetch and display bar chart data
                },
                child: const Text('Show Bar'),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            if (_showBarChart)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: BarChartSample3(barData: barData),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
