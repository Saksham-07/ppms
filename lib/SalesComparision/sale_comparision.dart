import 'dart:async';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:d_chart/d_chart.dart';
import '../common/utils/constants/baseurl.dart';

class SaleComparison extends StatefulWidget {
  const SaleComparison({super.key});

  @override
  SaleComparisonState createState() => SaleComparisonState();
}

class SaleComparisonState extends State<SaleComparison> {
  String selectedMonthValue = 'None';
  String selectedWiseValue = 'Unit';
  late String turnoverUnit ;
  String selectedValueOrQty = 'Val';
  String? _selectedOption;
  int? _selectedValue;
  String? _selectedFyShortName;
  late double barWidth = 200.0;
  Map<String, List<Map<String, dynamic>>> result = {};
  List<OrdinalGroup> dataGroups = [];
  List<dynamic> _fyData = [];
  List<dynamic> _dropdownData = [];
  String? _selectedDropdownValue;
  final bool _showBarChart = false;
  List<Map<String, dynamic>> barData = [];
  String? selectedValue4;
  String? _loginId;
  late double maxYValue = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    _selectedOption = '--';
    _selectedValue = 0;
    if (_dropdownData.isNotEmpty) {
      _selectedDropdownValue = _dropdownData[0]['Text'] as String;
    }
    _fetchFyData();
    _fetchDropdownData();
    _fetchData();

  }

  Future<void> _fetchFyData() async {
    final response =
    await http.get(Uri.parse('${TBaseURL.baseUrl}year?year='));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _fyData = data;
        if (_fyData.isNotEmpty) {
          _selectedFyShortName = _fyData[0]['FyName'];
        }
      });
      print(_selectedFyShortName);
      // _fetchBuyerData(_selectedFyShortName!);
    }
    else {
      throw Exception('Failed to load FY data');
    }
  }

  Future<void> _fetchDropdownData() async {
    _dropdownData = [];
    if(selectedWiseValue != 'Dgm') {
      final prefs = await SharedPreferences.getInstance();
      _loginId = prefs.getString('login_id');
      // final response = await http.get(Uri.parse(
      //     'http://172.16.10.11:8001/sales_buyer?type=$selectedWiseValue&fy=23-24&user=$_loginId'));

      final response = await http.get(Uri.parse(
          '${TBaseURL.baseUrl}sales_buyer?type=$selectedWiseValue&fy=23-24&user=$_loginId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dropdownData = [
            {'Text': 'All', 'Value': ''},
            ...data
          ];
          if (_dropdownData.isNotEmpty) {
            _selectedDropdownValue = _dropdownData[0]['Text'] as String;
          }
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    }
    else{
      setState(() {
        _dropdownData = [];
      });
    }
  }

  String formatTurnoverValue(double value) {
    num maxTurnover = 0;
    for (var group in dataGroups) {
      for (var data in group.data) {
        if (data.measure > maxTurnover) {
          maxTurnover = data.measure;
        }
      }
    }
    if (maxTurnover < 10000000000 && maxTurnover > 9999999) {
      return (value / 10000000).toStringAsFixed(2);
    }
    else if(maxTurnover < 10000000 && maxTurnover > 99999){
      return (value / 100000).toStringAsFixed(2);
    }
    else if(maxTurnover < 100000 && maxTurnover > 999){
      return (value / 1000).toStringAsFixed(2);
    }
    else {
      return value.toStringAsFixed(0);
    }
  }

  List<Color> barColors = [
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];


  void determineTurnoverUnit() {
    num maxTurnover = 0;
    for (var group in dataGroups) {
      for (var data in group.data) {
        if (data.measure > maxTurnover) {
          maxTurnover = data.measure;
        }
      }
    }
    Future.delayed(const Duration(milliseconds: 100),(){
      setState(() {
        turnoverUnit = maxTurnover >= 10000000 ? "Crores" : "Lakhs";
      });
    });
  }

  Future<void> _fetchData() async {
    dataGroups = [];
    barWidth = 0;
    result.clear();

    // final response = await http.get(Uri.parse('http://172.16.2.168:8001/sales_test'));
    // final response = await http.get(Uri.parse('${TBaseURL.baseUrl}sales_comp?report_for=monthly&report_type=value'));
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}sales_comp?report_for=monthly&report_type=value&fy=$_selectedFyShortName'));

    if (kDebugMode) {
      print('${TBaseURL.baseUrl}sales_comp?report_for=monthly&report_type=value&fy=$_selectedFyShortName');
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        print(data);
        // Process data into the result map
        for (var item in data) {
          String mainColumnValue = item['MainColumn'].toString();
          var subMap = Map<String, dynamic>.from(item);
          subMap.remove('MainColumn');

          if (result.containsKey(mainColumnValue)) {
            result[mainColumnValue]!.add(subMap);
          } else {
            result[mainColumnValue] = [subMap];
          }
        }

        if (kDebugMode) {
          print('result $result');
        }

        List<OrdinalData> ordinalDataList = [];

        dataGroups = result.entries.map((entry) {
          ordinalDataList = entry.value.map((item) {
            String buyerName = item['LabelName'] ?? '';
            buyerName = buyerName.length > 13 ? '${buyerName.substring(0, 13)}..' : buyerName;

            return OrdinalData(
              domain: buyerName,
              measure: (item['Qty'] ?? 0),
            );
          }).toList();

          return OrdinalGroup(
            id: entry.key,
            data: ordinalDataList,
            color: barColors[result.keys.toList().indexOf(entry.key) % barColors.length],
          );
        }).toList();

        // Set barWidth once based on the total number of items
        int totalItems = dataGroups.fold(0, (sum, group) => sum + group.data.length);
        barWidth = (90.0 * totalItems)/2;

        determineTurnoverUnit(); // Adjust turnover unit if needed

        print('Data Groups: $dataGroups');
        print('Bar Width: $barWidth');
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
          'Comp Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right:4, left: 4),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'None',
                              activeColor: Colors.orange,
                              groupValue: selectedMonthValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedMonthValue = value!;
                                  _fetchDropdownData();
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('None', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Month',
                              activeColor: Colors.orange,
                              groupValue: selectedMonthValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedMonthValue = value!;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('Monthly', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Quarter',
                              activeColor: Colors.orange,
                              groupValue: selectedMonthValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedMonthValue = value!;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('Quarterly', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Year',
                              activeColor: Colors.orange,
                              groupValue: selectedMonthValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedMonthValue = value!;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('Yearly', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 4, left: 4),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Unit',
                              activeColor: Colors.teal,
                              groupValue: selectedWiseValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedWiseValue = value!;
                                  _fetchDropdownData();
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('Unit', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Buyer',
                              activeColor: Colors.teal,
                              groupValue: selectedWiseValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedWiseValue = value!;
                                  _fetchDropdownData();
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('Buyer', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Radio<String>(
                              value: 'Dgm',
                              activeColor: Colors.teal,
                              groupValue: selectedWiseValue,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedWiseValue = value!;
                                  _fetchDropdownData();
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Text('DGM', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Add the new Value and Qty radio buttons
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: Radio<String>(
                                value: 'Val',
                                activeColor: Colors.lightGreen,
                                groupValue: selectedValueOrQty,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedValueOrQty = value!;
                                    Timer(Duration(seconds: 2), () {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                    _fetchData();
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const Text('Value', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 25,
                              height: 25,
                              child: Radio<String>(
                                value: 'Qty',
                                activeColor: Colors.lightGreen,
                                groupValue: selectedValueOrQty,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedValueOrQty = value!;
                                    Timer(Duration(seconds: 2), () {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    });
                                    _fetchData();
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const Text('Qty', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        if (_dropdownData.isNotEmpty)
                          Expanded(
                            child: DropdownSearch<String>(
                              items: _dropdownData.map((item) => item['Text'] as String).toList(), // Cast to String
                              selectedItem: _selectedDropdownValue,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: "Select Item",
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14, // Reduce font size
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[400]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.teal,
                                      width: 2.0,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), // Reduce padding
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Reduce padding
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                                    ),
                                    labelText: "Search",
                                    labelStyle: const TextStyle(fontSize: 14), // Adjust label size
                                  ),
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDropdownValue = newValue!;
                                });
                              },
                              dropdownButtonProps: const DropdownButtonProps(
                                padding: EdgeInsets.all(4),
                                icon: Icon(Icons.arrow_drop_down, color: Colors.teal,),
                              ),
                            ),
                          ),


                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: 800,
              width: double.infinity,
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Buyer',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text('in $turnoverUnit', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          buildLegend(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width + barWidth,
                          height: 300.0,
                          child: DChartBarO(
                            vertical: true,
                            animate: true,
                            animationDuration: const Duration(milliseconds: 900),
                            layoutMargin: LayoutMargin(10, 10, 8, 80),
                            configRenderBar: ConfigRenderBar(
                              showBarLabel: true,
                              maxBarWidthPx: 60,
                              barLabelDecorator: BarLabelDecorator(
                                barLabelPosition: BarLabelPosition.auto,
                                labelAnchor: BarLabelAnchor.end,
                                outsideLabelStyle: const LabelStyle(
                                  fontSize: 9,
                                  color: Colors.black,
                                ),
                                insideLabelStyle: const LabelStyle(
                                  fontSize: 9,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            domainAxis: DomainAxis(
                              showLine: true,
                              lineStyle: LineStyle(
                                  color: Colors.grey.shade200
                              ),
                              tickLength: 8,
                              labelRotation: 45,
                              gapAxisToLabel: 8,
                              labelStyle: const LabelStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                            measureAxis: MeasureAxis(
                              gapAxisToLabel: 4,
                              showLine: false,
                              noRenderSpec: true,
                              numericTickProvider: const NumericTickProvider(
                                desiredMinTickCount: 5,
                                desiredMaxTickCount: 7,
                              ),
                              gridLineStyle: LineStyle(
                                color: Colors.grey.shade300,
                                dashPattern: [4],
                              ),
                              labelStyle: const LabelStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                            barLabelValue: (group, data, index) {
                              return formatTurnoverValue(data.measure.toDouble());
                            },
                            groupList: dataGroups,
                          ),
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
    );

  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: dataGroups.map((group) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: group.color,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: ()=>  print(group.id),
                child: Text(
                  group.id,
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}




