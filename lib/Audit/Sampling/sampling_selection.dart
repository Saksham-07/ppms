import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Audit/Sampling/sampling_audit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import '../../ExtraFunction/uuid.dart';
import '../../common/utils/constants/baseurl.dart';

class SamplingAuditSelection extends StatefulWidget {
  const SamplingAuditSelection({super.key});

  @override
  SamplingAuditSelectionState createState() => SamplingAuditSelectionState();
}

class SamplingAuditSelectionState extends State<SamplingAuditSelection> {
  String? _loginId,_unitCode;
  TextEditingController orderQty = TextEditingController();
  TextEditingController issueQty = TextEditingController();
  TextEditingController receivedQty = TextEditingController();
  TextEditingController pcsChkd = TextEditingController();

  int _currentIndex = 0;

  String isFresh = "Fresh";
  List<String> _unitOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;

  List<String> buyerOptions = [];
  Map<String, String> buyerMap = {};
  String? selectedBuyer,buyerCode;

  List<String> styleNoOptions = [];
  Map<String, String> styleMap = {};
  String? selectedStyleNo;

  List<String> orderNoOptions = [];
  Map<String, String> orderMap = {};
  String? selectedOrderNo;

  List<String> colorOptions = [];
  Map<String, String> colorMap = {};
  String? selectedColor;

  List<String> productOptions = [];
  Map<String, String> productMap = {};
  String? selectedProduct;

  List<String> sampleOption = [];
  Map<String, String> sampleMap = {};
  Map<String, String> sampleIdMap = {};
  String? selectedSample;

  List<String> supervisorOptions = [];
  Map<String, String> supervisorMap = {};
  String? selectedSupervisor;

  List<String> qaOptions = [];
  Map<String, String> qaMap = {};
  String? selectedQa;

  List<String> checkerOptions = [];
  Map<String, String> checkerMap = {};
  String? selectedChecker;

  Map<String, dynamic> tableData = {};
  Map<String, dynamic> textData = {};
  Map<String, dynamic> allData = {};

  bool isSelected = false,isReAudit = true;
  String version = '',uuid = '',reAuditNo = '';
  String? selectedInterval;
  DateTime? issueTime;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _fetchUnitOptions();
    getVersionNo();
    getUid();
  }

  @override
  void dispose() {
    orderQty.dispose();
    issueQty.dispose();
    receivedQty.dispose();
    pcsChkd.dispose();
    super.dispose();
  }

  Future<void> getVersionNo() async{
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      if (kDebugMode) {
      }
    });
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });
    if (kDebugMode) {
      print('Persistent UUID: $uuid');
    }
  }

  String formatDateTime(DateTime? dateTime, String fallback) {
    if (dateTime == null) return fallback;
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  // Only pick time, date is always today
  Future<void> _selectTime(BuildContext context, bool isIssueTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      setState(() {
        if (isIssueTime) {
          issueTime = selectedDateTime;
        } else {
          startTime = selectedDateTime;
        }
      });
    }
  }

  Future<void> _fetchUnitOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    _unitCode = prefs.getString('unitCode');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _unitOptions = data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};
        _selectedUnit = _unitOptions.isNotEmpty ? _unitOptions[0] : null;
      });

      String type = _currentIndex == 0 ? 'Stitching' : 'Finishing';

      await _fetchSampleOptions(type);
      await _fetchSupervisorOptions(_selectedUnit!);
      await _fetchQAOptions(_selectedUnit!);
      await _fetchCheckerOptions(_selectedUnit!);
    } else {
      if (kDebugMode) {
        print('Failed to load Unit options');
      }
    }
  }

  Future<void> _fetchSampleOptions(String type) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=DocNo&jobType=$type';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        sampleOption =  ['----'] + data.map((e) => e['DocNo'].toString()).toList();
        sampleMap = {for (var item in data) item['DocNo'].toString(): item['DocNo'].toString()};
        sampleIdMap = {for (var item in data) item['DocNo'].toString(): item['DocId'].toString()};
        selectedSample = sampleOption.isNotEmpty ? sampleOption[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchDropdownData(String docId,String type) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=OdrByrStylClr&docId=$docId&jobType=$type';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print('data $data');
      }
      setState(() {
        orderNoOptions =  data.map((e) => e['OrderNo'].toString()).toList();
        orderMap = {for (var item in data) item['OrderNo'].toString(): item['OrderNo'].toString()};
        selectedOrderNo = orderNoOptions.isNotEmpty ? orderNoOptions[0] : null;
        buyerOptions =  data.map((e) => e['BuyerName'].toString()).toList();
        buyerMap = {for (var item in data) item['BuyerName'].toString(): item['BuyerCode'].toString()};
        selectedBuyer = buyerOptions.isNotEmpty ? buyerOptions[0] : null;
        styleNoOptions =  data.map((e) => e['StyleNo'].toString()).toList();
        styleMap = {for (var item in data) item['StyleNo'].toString(): item['StyleNo'].toString()};
        selectedStyleNo = styleNoOptions.isNotEmpty ? styleNoOptions[0] : null;
        colorOptions =  ['----'] + data.map((e) => e['Color'].toString()).toList();
        colorMap = {for (var item in data) item['Color'].toString(): item['Color'].toString()};
        selectedColor = colorOptions.isNotEmpty ? colorOptions[0] : null;
        productOptions =  data.map((e) => e['ProductType'].toString()).toList();
        productMap = {for (var item in data) item['ProductType'].toString(): item['ProductType'].toString()};
        selectedProduct = productOptions.isNotEmpty ? productOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchSupervisorOptions(String unit) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=Supervisor';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        supervisorOptions = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
        supervisorMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedSupervisor = supervisorOptions.isNotEmpty ? supervisorOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Supervisor options');
      }
    }
  }

  Future<void> _fetchQAOptions(String unit) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=QA';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        qaOptions = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
        qaMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedQa = qaOptions.isNotEmpty ? qaOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load QA options');
      }
    }
  }

  Future<void> _fetchCheckerOptions(String unit) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=Checker';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        checkerOptions = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
        checkerMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedChecker = checkerOptions.isNotEmpty ? checkerOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Checker options');
      }
    }
  }

  Future<void> _fetchQtyOptions(String doc, String color, String job) async {
    String url = '${TBaseURL.auditLocalUrl}sampling_audit_vg?type=Qty&jobType=$job&color=$color&docId=$doc';
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      setState(() {
        orderQty.text = data[0]['OrderQty'].toString();
        issueQty.text = data[0]['IssueQty'].toString();
        pcsChkd.text = '0';
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Qty');
      }
    }
  }


  void _clearList() {
    setState(() {
      selectedSample = null;
      selectedBuyer = null;
      selectedStyleNo = null;
      selectedOrderNo = null;
      selectedColor = null;
      selectedInterval = null;
      selectedProduct = null;
      orderQty.text = '';
      issueQty.text = '';
      pcsChkd.text = '';
      receivedQty.text = '';
    });
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
          'Sampling Audit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        // actions: [
        //   SizedBox(
        //     width: 120,
        //     height: 30,
        //     child: DropdownSearch<String>(
        //       selectedItem: _selectedUnit,
        //       dropdownButtonProps: const DropdownButtonProps(
        //         isVisible: false,
        //       ),
        //       dropdownDecoratorProps: const DropDownDecoratorProps(
        //         baseStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //         dropdownSearchDecoration: InputDecoration(
        //           labelStyle: TextStyle(fontSize: 12),
        //           floatingLabelStyle: TextStyle(fontSize: 14),
        //           contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        //           border: OutlineInputBorder(
        //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //             borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
        //           ),
        //           disabledBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //             borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
        //           ),
        //           enabledBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //             borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
        //           ),
        //           focusedBorder: OutlineInputBorder(
        //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //             borderSide: BorderSide(color: Color(0xFF14CEB8), width: 2.0),
        //           ),
        //         ),
        //       ),
        //       popupProps: const PopupProps.menu(
        //         showSelectedItems: true,
        //         fit: FlexFit.loose,
        //       ),
        //       items: _unitOptions,
        //       itemAsString: (item) => item,
        //       onChanged: (newValue) async {
        //         _clearList();
        //         styleNoOptions.clear();
        //         setState(() {
        //           _selectedUnit = newValue;
        //           _saveSelectedUnitToSharedPreferences(newValue!);
        //         });
        //         String? unit = _unitMap[_selectedUnit];
        //         if (newValue != null && newValue != '----') {
        //           await _fetchStyleOptions(newValue);
        //           await _fetchSupervisorOptions(newValue);
        //           await _fetchStartTime(unit!);
        //           await _fetchQAOptions(newValue);
        //           await _fetchCheckerOptions(newValue);
        //           await _fetchAuditOptions(unit);
        //           await _fetchProductOptions();
        //         }
        //       },
        //     ),
        //
        //   ),
        // ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        
        onTap: (index) {
          _clearList();
          setState(() {
            _currentIndex = index; // Change the selected tab
          });
          String type = _currentIndex == 0 ? 'Stitching' : 'Finishing';
          _fetchSampleOptions(type);
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sticky_note_2_outlined,color: Colors.black54,size: 20,), // Icon for Stitching
            label: "Stitching",
            activeIcon: Icon(Icons.sticky_note_2_outlined,color: Colors.black,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.safe_home,color: Colors.black54,size: 20,), // Icon for Finishing
            label: "Finishing",
            activeIcon: Icon(Iconsax.safe_home,color: Colors.black,size: 25,),
          ),
        ],
        backgroundColor: const Color(0xFF5FE3D3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedSample,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Sample No',
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
                        items: sampleOption,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          String? type;
                          String? sampleId;
                          setState(() {
                            selectedSample = newValue;
                            type = _currentIndex == 0? 'Stitching' : 'Finishing';
                            sampleId = sampleIdMap[selectedSample];
                          });
                          _fetchDropdownData(sampleId!,type!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedOrderNo,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        enabled: false, // Disabled dropdown
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Order No',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelStyle: TextStyle(fontSize: 16),
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                            disabledBorder: OutlineInputBorder(
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
                        items: orderNoOptions,
                        itemAsString: (item) => item,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedStyleNo,
                        enabled: false,
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
                        items: styleNoOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedStyleNo = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedBuyer,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        enabled: false,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Buyer',
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
                        items: buyerOptions,
                        itemAsString: (item) => item,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              selectedItem: selectedColor,
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Color',
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
                              items: colorOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                String? job;
                                String? sampleId;
                                setState(() {
                                  selectedColor = newValue;
                                  job = _currentIndex == 0 ? 'Stitching' : 'Finishing';
                                  sampleId = sampleIdMap[selectedSample];
                                });
                                _fetchQtyOptions(sampleId!,newValue!,job!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              selectedItem: selectedSupervisor,
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Supervisor',
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
                              items: supervisorOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedSupervisor = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedQa,
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'QA',
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
                        items: qaOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            selectedQa = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              selectedItem: selectedChecker,
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Checker',
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
                              items: checkerOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedChecker = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formatDateTime(issueTime,'Audit Date'),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        enabled: false,
                        selectedItem: selectedProduct,
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Product',
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
                        items: productOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            selectedProduct = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        readOnly: true,
                        controller: orderQty,
                        decoration: const InputDecoration(
                          labelText: 'Order Qty',
                          labelStyle: TextStyle(fontSize: 12),
                          floatingLabelStyle: TextStyle(fontSize: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Field 2
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        readOnly: true,
                        controller: issueQty,
                        decoration: const InputDecoration(
                          labelText: 'Issue Qty',
                          labelStyle: TextStyle(fontSize: 12),
                          floatingLabelStyle: TextStyle(fontSize: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        readOnly: true,
                        controller: pcsChkd,
                        decoration: const InputDecoration(
                          labelText: 'PCS Checked',
                          labelStyle: TextStyle(fontSize: 12),
                          floatingLabelStyle: TextStyle(fontSize: 16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              SizedBox(width: 140,child:
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    int issueQtyValue = int.tryParse(issueQty.text.trim()) ?? 0;
                    int pcsChkdValue = int.tryParse(pcsChkd.text.trim()) ?? 0;
                    int recValue = int.tryParse(receivedQty.text.trim()) ?? 0;

                    if (kDebugMode) {
                      print("Issue Qty: $issueQtyValue, Pcs Checked: $pcsChkdValue, Received Qty: $recValue");
                    }

                    if (issueQtyValue - pcsChkdValue < recValue) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Received Qty is Exceeding balance Qty."))
                      );
                      return;
                    }
                    else if (selectedStyleNo == null || selectedStyleNo == "----" ||
                        selectedColor == null || selectedColor == "----" ||
                        selectedBuyer == null || selectedBuyer == "----" ||
                        selectedChecker == null || selectedChecker == "----" ||
                        selectedQa == null || selectedQa == "----" ||
                        selectedSupervisor == null || selectedSupervisor == "----" ||
                        issueTime == null || pcsChkd.text.isEmpty) {

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("❌ Please fill all fields correctly. ❌"))
                      );
                      return;
                    }

                    tableData = {
                      'Style': selectedStyleNo,
                      'Color': selectedColor,
                    };

                    String? checker = checkerMap[selectedChecker];
                    String? qa = qaMap[selectedQa];
                    String? supervisor = supervisorMap[selectedSupervisor];
                    String? id = sampleIdMap[selectedSample];
                    buyerCode = buyerMap[selectedBuyer];

                    textData = {
                      'Pcs Checked': pcsChkd.text,
                      'Received Qty': issueQty.text,
                      'Buyer': buyerCode,
                    };

                    allData = {
                      'Sample': selectedSample,
                      'SampleId' : id,
                      'Style': selectedStyleNo!,
                      'Order' : selectedOrderNo!,
                      'Buyer': buyerCode!,
                      'Color': selectedColor!,
                      'Product': selectedProduct,
                      'PcsChecked': pcsChkd.text,
                      'OrderQty': orderQty.text,
                      'IssueQty': issueQty.text,
                      'IssueTime': issueTime.toString(),
                      'Checker' : checker!,
                      'CheckerName' : selectedChecker?.split('(')[0].trim(),
                      'QA' : qa!,
                      'QAName' : selectedQa?.split('(')[0].trim(),
                      'Supervisor' : supervisor!,
                      'SupervisorName' : selectedSupervisor?.split('(')[0].trim(),
                      'AuditType' : _currentIndex == 0 ? 'S': 'F',
                      'Version' : version,
                      'DeviceId' : uuid,
                      'Login' : _loginId,
                      'Unit' : _unitCode,
                    };

                    if (kDebugMode) {
                      print(allData);
                    }

                    Set<String> excludeFields = {'DeviceId'};
                    List<String> nullFields = allData.entries
                        .where((entry) =>
                    !excludeFields.contains(entry.key) && // Exclude specific fields
                        (entry.value == null || entry.value.toString().trim().isEmpty))
                        .map((entry) => entry.key)
                        .toList();

                    if (nullFields.isNotEmpty) {
                      if (kDebugMode) {
                        print("❌ Navigation prevented: These fields are null or empty: ${nullFields.join(', ')}");
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ Please fill the fields again: ${nullFields.join(', ')} ❌"))
                      );
                    } else {
                      navigate(tableData, textData, allData);
                    }

                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xC27CF378)),
                child: const Text('Start Audit', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
              )
              )
            ],
          ),
        ),
      ),
    );
  }
  Future <void> navigate (Map<String, dynamic> tableData,Map<String, dynamic> textFieldData,Map<String, dynamic> allData)async{
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SamplingAuditPage(
          tableData: tableData,
          textFieldData: textData,
          allData: allData,
        ),
      ),
    );
    String type = _currentIndex == 0? 'Stitching' : 'Finishing';
    _clearList();
    Future.delayed(const Duration(milliseconds: 100),(){
      _fetchSampleOptions(type);
    });
  }
}