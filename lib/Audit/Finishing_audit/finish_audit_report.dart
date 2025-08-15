import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../ExtraFunction/TooltipIcon.dart';
import '../../common/utils/constants/baseurl.dart';


class FinishReportPage extends StatefulWidget {
  const FinishReportPage({super.key});

  @override
  FinishReportPageState createState() => FinishReportPageState();
}

class FinishReportPageState extends State<FinishReportPage> {
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;

  List<String> styleOptions = [];
  Map<String, String> styleMap = {};
  String? selectedStyleNo;

  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {}, _unitMapVg = {},_unitCodeMap = {};
  String? _selectedUnit;
  DateTime selectedDate = DateTime.now();
  bool isLineWise = false,isStyleWise = false;
  bool isLinePresent = false;
  int line = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> sewingData = [];

  @override
  void initState() {
    super.initState();
    runFunction();
  }

  void runFunction() async {
    setState(() {
      isLoading = true; // Show loading spinner
    });

    await _fetchDropDownOptions();
    await _checkLineId();

    // Delay to ensure dependent values are set
    await Future.delayed(const Duration(milliseconds: 400), () async {
      if (_selectedUnit != null && _selectedUnit != '') {
        await fetchLineDataFromApi(_unitMapVg[_selectedUnit]!);
        final unitCode = _unitMap[_selectedUnit];
        final unitCodeVg = _unitMapVg[_selectedUnit];
        await _fetchStyleOptions();
        await fetchData('all', selectedDate, unitCode!, unitCodeVg!, '$line');
      }
    });

    setState(() {
      isLoading = false; // Hide loading spinner
    });
  }

  Future<bool> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic lineId = prefs.getInt('line_ids'); // Fetch the line_id as an int
    line = lineId;
    if (kDebugMode) {
      print(lineId);
    }
    if (lineId != 0) {
      isLinePresent = true;
      return true;
    }
    isLinePresent = false;
    return false;
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    final response = await http.get(Uri.parse(url));
    print(url);

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
        _unitCodeMap = {
          for (var item in data) item['UnitShortCode']
              .toString(): item['UnitShortCode1'].toString()
        };
        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
        } else {
          _selectedUnit =
          _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
      });
    } else {
      debugPrint('Failed to load options');
    }
  }

  Future<void> _fetchStyleOptions() async {
    final unitCode = _unitMap[_selectedUnit];
    final unitCodeVg = _unitMapVg[_selectedUnit];
    String url1 = '${TBaseURL.auditUrl}finishing_audit_new?type=ReportStyle&unit=$unitCode&style=&color=&lineId=&line_Id=&orderNo=&date=$selectedDate';
    // If you want to use a different unit value for the second call, adjust here:

    String url2 = '${TBaseURL.auditUrl}finishing_audit_new?type=ReportStyle&unit=$unitCodeVg&style=&color=&lineId=&line_Id=&orderNo=&date=$selectedDate';


    if (kDebugMode) {
      print(url1);
      print(url2);
    }

    try {
      // Fire both requests in parallel
      final responses = await Future.wait([
        http.get(Uri.parse(url1)),
        http.get(Uri.parse(url2)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> data1 = jsonDecode(responses[0].body);
        final List<dynamic> data2 = jsonDecode(responses[1].body);

        // Combine and deduplicate by STYLE_NO
        print(data1);
        print(data2);
        final allData = [...data1, ...data2];
        final styleSet = <String>{};
        final styleList = <String>[];
        final styleMapTemp = <String, String>{};
        for (var item in allData) {
          final styleNo = item['StyleNo'].toString();
          if (styleSet.add(styleNo)) {
            styleList.add(styleNo);
            styleMapTemp[styleNo] = styleNo;
          }
        }
        setState(() {
          styleOptions = ['----'] + styleList;
          styleMap = styleMapTemp;
          selectedStyleNo = styleOptions.isNotEmpty ? styleOptions[0] : null;
        });
        print(styleOptions);
      } else {
        if (kDebugMode) {
          print('Failed to load Buyer options');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching style options: $e');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(
            Uri.parse('${TBaseURL.baseUrl}line_vg?unit=$unit&ot=F'));

        print('${TBaseURL.baseUrl}line_vg?unit=$unit&ot=F');
        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) {
              return {
                'LineName': item['LineName'].toString(),
                'LineID': item['LineId'].toString(),
              };
            }).toList();
          });
          success = true;
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Error fetching data (Attempt $retryCount): $e');
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<String> fetchSupervisorData(String supervisor) async {
    final String url = "${TBaseURL.auditUrl}sewing_report?type=user&date=&unit=&line=&subtype=$supervisor";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
          return data[0]["Name"] ?? "No Name Found";
        }
        return "Unexpected Data Format";
      } else {
        throw Exception('Failed to fetch supervisor info');
      }
    } catch (e) {
      debugPrint('Error fetching supervisor data: $e');
      return "Error Fetching Data";
    }
  }

  Future<void> updateSewingDataWithSupervisorInfo() async {
    List<Map<String, dynamic>> updatedData = [];

    for (var item in sewingData) {
      String sup = item['Supervisor'].toString();
      String qa = item['QA'].toString();
      String supervisorName = await fetchSupervisorData(sup);
      String qaName = await fetchSupervisorData(qa);

      print(qaName);

      setState(() {
        updatedData.add({
          ...item,
          'SupervisorName': supervisorName,
          'QaName': qaName,
        });
      });
    }

    setState(() {
      sewingData = updatedData;
    });
  }

  Future<void> fetchData(String vise, DateTime date, String unit, String vgUnit, String line) async {
    try {
      String formattedDate = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // URLs for both API calls
      final unitUrl = "${TBaseURL.auditUrl}sewing_report_new?type=$vise&date=$formattedDate&unit=$unit&line=$line&subtype=F&style=$selectedStyleNo";
      final vgUnitUrl = "${TBaseURL.auditUrl}sewing_report_new?type=$vise&date=$formattedDate&unit=$vgUnit&line=$line&subtype=F&style=$selectedStyleNo";

      // Print both URLs in debug mode
      if (kDebugMode) {
        print(unitUrl);
        print(vgUnitUrl);
      }

      // Make both API calls concurrently
      final responses = await Future.wait([
        http.get(Uri.parse(unitUrl)),
        http.get(Uri.parse(vgUnitUrl)),
      ]);

      // Check the status of both responses
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final data1 = json.decode(responses[0].body); // Data from first API
        final data2 = json.decode(responses[1].body); // Data from second API

        // Merge the data from both APIs
        final mergedData = [
          ...List<Map<String, dynamic>>.from(data1),
          ...List<Map<String, dynamic>>.from(data2),
        ];

        setState(() {
          sewingData = mergedData;
          isLoading = false;
        });

        await updateSewingDataWithSupervisorInfo();
      } else {
        throw Exception('Failed to load data from one or both APIs');
      }
    } catch (e) {
      // Handle errors
      if (kDebugMode) {
        print('Error: $e');
      }
      throw Exception('Failed to load sewing data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = sewingData.where((item) =>
    item['ReAuditNo'] == null ||
        item['ReAuditNo'].toString().isEmpty
    ).toList();

    final int totalReceivedQty = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['ReceivedQty'].toString()) ?? 0));
    final int totalSampleSize = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['SampleSize'].toString()) ?? 0));
    final int totalPcsChecked = filteredData.fold(0, (sum, item) => sum + (int.tryParse(item['PcsChecked'].toString()) ?? 0));

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
          'Finishing Audit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(),) : Column(
        children: [
          // Dropdowns and Date Picker
          Padding(
            padding: const EdgeInsets.only(bottom: 4,top: 8.0,left: 8,right: 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: DropdownSearch<String>(
                      selectedItem: _selectedUnit,
                      dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                      popupProps: const PopupProps.menu(showSearchBox: false),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Unit',
                          labelStyle: TextStyle(fontSize: 12),
                          floatingLabelStyle: TextStyle(fontSize: 16),
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                          ),
                        ),
                      ),
                      items: _dropDownOptions,
                      itemAsString: (item) => item,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          selectedValue4 = newValue;
                          selectedValue3 = null;
                          dropdownData3.clear();
                          dropdownData5.clear();
                          fetchLineDataFromApi(_unitMapVg [_selectedUnit]!);
                          selectedLineID = '';
                        });
                        final unitCode = _unitMap[_selectedUnit];
                        final unitCodeVg = _unitMapVg[_selectedUnit];
                        fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode!,unitCodeVg!, selectedLineID!);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Visibility(
                  visible: isLineWise,
                  child: Expanded(
                    child: SizedBox(
                      height: 35,
                      child: DropdownSearch<String>(
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Line',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                          ),
                        ),
                        items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(),
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            selectedValue3 = newValue;
                            selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                          });
                          if (_selectedUnit != null && selectedLineID != null) {
                            final unitCodeVg = _unitMapVg[_selectedUnit];
                            final unitCode = _unitMap[_selectedUnit];

                            fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode!,unitCodeVg!, selectedLineID!);
                          }
                        },
                        selectedItem: selectedValue3,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isStyleWise,
                  child: Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedStyleNo,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Style No',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                            ),
                          ),
                        ),
                        items: styleOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedStyleNo = newValue;
                          });
                          if (_selectedUnit != null && selectedStyleNo != null) {
                            final unitCodeVg = _unitMapVg[_selectedUnit];
                            final unitCode = _unitMap[_selectedUnit];

                            fetchData(isStyleWise ? 'stylewise' : 'all', selectedDate, unitCode!,unitCodeVg!,'');
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4,bottom: 8.0,left: 8,right: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 5, // Adjust flex value for proportionate spacing
                  child: GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                          isLoading = true;
                          isStyleWise = false;
                        });

                        final unitCode = _unitMap[_selectedUnit];
                        final unitCodeVg = _unitMapVg[_selectedUnit];

                        if (_selectedUnit != null && unitCode != null) {
                          await fetchData(isLineWise ? 'linewise' : 'all', selectedDate, unitCode,unitCodeVg!, selectedLineID ?? '0');
                        }
                      }
                    },
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate.toLocal().toString().split(' ')[0],
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7, // Adjust flex value for spacing
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isLineWise,
                        onChanged: (bool? value) {
                          setState(() {
                            isLineWise = value ?? false;
                            if (isLineWise) isStyleWise = false; // Unselect stylewise
                            print('isLineWise: $isLineWise');
                          });

                          final unitCode = _unitMap[_selectedUnit];
                          final unitCodeVg = _unitMapVg[_selectedUnit];

                          if (_selectedUnit != null) {
                            fetchData(
                                isLineWise ? 'linewise' : 'all',
                                selectedDate,
                                unitCode!,
                                unitCodeVg!,
                                selectedLineID ?? '0'
                            );
                          }
                        },
                      ),
                      const Text(
                        'Linewise',
                        style: TextStyle(fontSize: 14),
                      ),
                      Checkbox(
                        value: isStyleWise,
                        onChanged: (bool? value) async {
                          setState(() {
                            isStyleWise = value ?? false;
                            if (isStyleWise) isLineWise = false; // Unselect linewise
                            print('isStyleWise: $isStyleWise');
                          });

                          final unitCode = _unitMap[_selectedUnit];
                          final unitCodeVg = _unitMapVg[_selectedUnit];

                          if (_selectedUnit != null) {
                            await _fetchStyleOptions();
                            await fetchData(
                                isStyleWise ? 'stylewise' : 'all', // update if you have a stylewise API
                                selectedDate,
                                unitCode!,
                                unitCodeVg!,
                                selectedLineID ?? '0'
                            );
                          }
                        },
                      ),
                      const Text(
                        'StyleWise',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[200],
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Audit No', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Hour', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Style', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Visibility(
                          visible : false,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text('Buyer', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Line', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Pcs\nReceived',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Sample\nSize',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Psc\nChecked',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Final\nResult',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Audit\nType',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text('Detail', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...sewingData.asMap().entries.map((entry) {
                      var item = entry.value;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['AuditNo'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['Hrs'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['StyleNo'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Visibility(
                            visible : false,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                              child: Text(item['StyleNo'].toString(),style: const TextStyle(
                                  fontSize: 13
                              ),),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['Color'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['LineName'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['ReceivedQty'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['SampleSize'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['PcsChecked'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['FinalResult'].toString(),style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: Text(item['ReAuditNo'].toString() == '' ? 'Fresh' : 'ReAudit\n(${item['ReAuditNo'].toString()})',style: const TextStyle(
                                fontSize: 13
                            ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                            child: TooltipIcon(
                              tooltipText: "Supervisor: ${item['SupervisorName']}\nQA: ${item['QaName']}",
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox.shrink(), // Hour
                        const SizedBox.shrink(), // Style
                        Visibility(
                          visible: false,
                          child: const SizedBox.shrink(), // Buyer
                        ),
                        const SizedBox.shrink(), // Color
                        const SizedBox.shrink(), // Line
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalReceivedQty.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalSampleSize.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0,left: 8,top: 4,bottom: 4),
                          child: Text(
                            totalPcsChecked.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        const SizedBox.shrink(), // FinalResult
                        const SizedBox.shrink(), // AuditType
                        const SizedBox.shrink(), // Detail
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}