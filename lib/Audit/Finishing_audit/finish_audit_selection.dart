import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Audit/Finishing_audit/finish_audit.dart';
import 'package:ppms/Audit/Sewing_Audit/sewing_audit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import '../../ExtraFunction/uuid.dart';
import '../../common/utils/constants/baseurl.dart';

class FinishAuditSelection extends StatefulWidget {
  const FinishAuditSelection({super.key});

  @override
  FinishAuditSelectionState createState() => FinishAuditSelectionState();
}

class FinishAuditSelectionState extends State<FinishAuditSelection> {
  String? _loginId;
  TextEditingController orderQty = TextEditingController();
  TextEditingController issueQty = TextEditingController();
  TextEditingController receivedQty = TextEditingController();
  TextEditingController pcsChkd = TextEditingController();

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

  List<String> lineOption = [];
  Map<String, String> lineMap = {};
  String? selectedLine;
  int? lineId;

  List<String> floorOptions = [];
  Map<String, String> floorMap = {};
  String? selectedFloor;
  int? floorId;
  Map<String, String> lineIDMap = {};

  List<String> vendorOptions = [];
  Map<String, String> vendorMap = {};
  String? selectedVendor;

  List<String> hrsOption = [];
  Map<String, String> hrsMap = {};
  String? selectedHrs;

  List<String> productOptions = [];
  Map<String, String> productMap = {};
  String? selectedProduct;
  int? productId;

  List<String> supervisorOptions = [];
  Map<String, String> supervisorMap = {};
  String? selectedSupervisor;

  List<String> qaOptions = [];
  Map<String, String> qaMap = {};
  String? selectedQa;

  List<String> checkerOptions = [];
  Map<String, String> checkerMap = {};
  String? selectedChecker;

  List<String> auditOptions = [];
  Map<String, String> auditMap = {};
  String? selectedAudit;

  Map<String, dynamic> tableData = {};
  Map<String, dynamic> textData = {};
  Map<String, dynamic> allData = {};

  bool isSelected = false,isReAudit = true;
  String version = '',uuid = '',reAuditNo = '';
  String startTime = '';
  String? selectedTime;
  late List<String> timeSlots;
  List<String> hourIntervals = [];
  String? selectedInterval;


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

    print('Persistent UUID: $uuid');
  }

  List<String> generateHourlyIntervals(String startTime, String currentTime) {
    String date = DateTime.now().toIso8601String().split('T')[0];
    String nextDate = DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
    DateTime startDateTime = DateTime.parse("$date $startTime");
    DateTime now = DateTime.parse("$date $currentTime");

    List<String> intervals = [];
    int count = 1;

    while (startDateTime.isBefore(DateTime.parse("$nextDate 00:30:00"))) {
      if (startDateTime.isAfter(now.subtract(const Duration(hours: 1))) &&
          startDateTime.isBefore(now.add(const Duration(hours: 1)))) {
        intervals.add(count.toString());
      }

      count++;
      startDateTime = startDateTime.add(Duration(hours: 1));
    }

    return intervals;
  }

  Future<void> _fetchUnitOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _unitOptions = data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};
        _selectedUnit = _unitOptions.isNotEmpty ? _unitOptions[0] : null;
      });

      String? unit = _unitMap[_selectedUnit];

      await _fetchStyleOptions(_selectedUnit!);
      await _fetchStartTime(unit!);
      await _fetchProductOptions();
      await _fetchSupervisorOptions(_selectedUnit!);
      await _fetchQAOptions(_selectedUnit!);
      await _fetchCheckerOptions(_selectedUnit!);
      await _fetchAuditOptions(unit);


    } else {
      if (kDebugMode) {
        print('Failed to load Unit options');
      }
    }
  }

  Future<void> _fetchStyleOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Style&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        styleNoOptions =  ['----'] + data.map((e) => e['STYLE_NO'].toString()).toList();
        styleMap = {for (var item in data) item['STYLE_NO'].toString(): item['STYLE_NO'].toString()};
        selectedStyleNo = styleNoOptions.isNotEmpty ? styleNoOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchAuditOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=AuditNo&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        auditOptions =  ['----'] + data.map((e) => e['AuditNo'].toString()).toList();
        auditMap = {for (var item in data) item['AuditNo'].toString(): item['AuditNo'].toString()};
        selectedAudit = auditOptions.isNotEmpty ? auditOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchReAuditDataOptions(String unit,String audit) async {
    String url = '${TBaseURL.auditUrl}sewing_audit?type=ReAudit&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=&AuditNo=$audit';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        reAuditNo = selectedAudit!;
        selectedStyleNo = data[0]['StyleNo'];
        selectedOrderNo = data[0]['OrderNo'];
        selectedBuyer = data[0]['BuyerName'];
        buyerCode = data[0]['BuyerCode'];
        selectedColor = data[0]['Color'];
        selectedLine = data[0]['LineName'];
        lineId = data[0]['LineId'];
        selectedFloor = data[0]['FloorName'];
        floorId = data[0]['FloorId'];
        // selectedVendor = data[0]['VendorType'];
        selectedVendor = '';
        selectedInterval = (data[0]['Hrs']).toString();
        selectedProduct = data[0]['ComponentName'];
        productId = data[0]['ComponentId'];
        selectedSupervisor = supervisorMap.keys.firstWhere((key) => supervisorMap[key] == data[0]['Supervisor']);
        selectedQa = qaMap.keys.firstWhere((key) => qaMap[key] == data[0]['QA']);
        selectedChecker = checkerMap.keys.firstWhere((key) => checkerMap[key] == data[0]['Checker']);
        orderQty.text = (data[0]['OrderQty']).toString();
        issueQty.text = (data[0]['IssueQty']).toString();
        pcsChkd.text = (data[0]['PCs_Chked']).toString();
        receivedQty.text = (data[0]['ReceivedQty']).toString();
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchStartTime(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=StartTime&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(data);
      setState(() {
        startTime = data[0]['UnitStartTime'];
        print(startTime);
      });
      Future.delayed(const Duration(milliseconds: 300),(){
        String currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
        hourIntervals = generateHourlyIntervals("08:30:00", currentTime);

        // Set the selected value to the most recent interval
        if (hourIntervals.isNotEmpty) {
          selectedInterval = hourIntervals.last;
        }
        print(hourIntervals);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchBuyerOptions(String unit, String style) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Buyer&unit=$unit&style=$style&color=&lineId=&line_Id=&orderNo=';
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
        buyerOptions =  data.map((e) => e['BUYER_NAME'].toString()).toList();
        buyerMap = {for (var item in data) item['BUYER_NAME'].toString(): item['BUYER_CODE'].toString()};
        selectedBuyer = buyerOptions.isNotEmpty ? buyerOptions[0] : null;
      });

    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchOrderOptions(String unit, String style) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Order&unit=$unit&style=$style&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        orderNoOptions =  data.map((e) => e['ORDER_NO'].toString()).toList();
        orderMap = {for (var item in data) item['ORDER_NO'].toString(): item['ORDER_NO'].toString()};
        selectedOrderNo = orderNoOptions.isNotEmpty ? orderNoOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Order options');
      }
    }
  }

  Future<void> _fetchColorOptions(String unit, String style) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Color&unit=$unit&style=$style&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        colorOptions =  data.map((e) => e['COLOR_COMBO'].toString()).toList();
        colorMap = {for (var item in data) item['COLOR_COMBO'].toString(): item['COLOR_COMBO'].toString()};
        selectedColor = colorOptions.isNotEmpty ? colorOptions[0] : null;
      });
      _fetchLineOptions(_selectedUnit!, selectedStyleNo!,selectedColor!);
    } else {
      if (kDebugMode) {
        print('Failed to load Color options');
      }
    }
  }

  Future<void> _fetchLineOptions(String unit, String style,String color) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Line&unit=$unit&style=$style&color=$color&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        lineOption =  data.map((e) => e['LINENAME'].toString()).toList();
        lineMap = {for (var item in data) item['LINENAME'].toString(): item['LINEID'].toString()};
        selectedLine = lineOption.isNotEmpty ? lineOption[0] : null;
      });

      await _fetchFloorOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineMap[selectedLine]!);
      await _fetchVendorOptions(lineMap[selectedLine]!);

    } else {
      if (kDebugMode) {
        print('Failed to load Line options');
      }
    }
  }

  Future<void> _fetchFloorOptions(String unit, String style,String color,String line) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Floor&unit=$unit&style=$style&color=$color&lineId=$line&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    String? lineId;

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        floorOptions =  data.map((e) => e['FloorName'].toString()).toList();
        floorMap = {for (var item in data) item['FloorName'].toString(): item['FloorId'].toString()};
        selectedFloor = floorOptions.isNotEmpty ? floorOptions[0] : null;
        lineIDMap = {for (var item in data) item['FloorName'].toString(): item['LineId'].toString()};
        lineId = lineIDMap[selectedFloor];
      });

      await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineMap[selectedLine]!,selectedOrderNo!);
      if (kDebugMode) {
        print(lineIDMap);
      }
    } else {
      if (kDebugMode) {
        print('Failed to load Floor options');
      }
    }
  }

  Future<void> _fetchVendorOptions(String line) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Vendor&unit=&style=&color=&lineId=$line&line_Id=&orderNo=';
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
        vendorOptions =  data.map((e) => e['VENDOR_GROUP'].toString()).toList();
        vendorMap = {for (var item in data) item['VENDOR_GROUP'].toString(): item['VENDOR_GROUP'].toString()};
        selectedVendor = vendorOptions.isNotEmpty ? vendorOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Vendor options');
      }
    }
  }

  Future<void> _fetchQtyOptions(String unit, String style,String color,String line,String lineId,String order) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Qty&unit=$unit&style=$style&color=$color&line_Id=$line&lineId=$lineId&orderNo=$order';
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
        orderQty.text = data[0]['ORDER_QTY'].toString();
        issueQty.text = data[0]['ISSUE_QTY'].toString();
        pcsChkd.text = data[0]['PCS_CHKED'].toString();
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Qty');
      }
    }
  }

  Future<void> _fetchSupervisorOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Supervisor&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        supervisorOptions = ['----'] + data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
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
    String url = '${TBaseURL.auditUrl}finishing_audit?type=QA&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        qaOptions = ['----'] + data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
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
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Checker&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        checkerOptions = ['----'] + data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
        checkerMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedChecker = checkerOptions.isNotEmpty ? checkerOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Checker options');
      }
    }
  }

  Future<void> _fetchProductOptions() async {
    String url = '${TBaseURL.auditUrl}finishing_audit?type=Product&unit=&style=&color=&lineId=&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        productOptions =  ['----'] + data.map((e) => e['Category'].toString()).toList();
        productMap = {for (var item in data) item['Category'].toString(): item['CategoryId'].toString()};
        selectedProduct = productOptions.isNotEmpty ? productOptions[0] : null;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Product options');
      }
    }
  }


  void _clearList() {
    setState(() {
      selectedBuyer = null;
      selectedStyleNo = null;
      selectedOrderNo = null;
      selectedColor = null;
      selectedLine = null;
      selectedFloor = null;
      selectedProduct = null;
      selectedInterval = null;
      selectedVendor = null;
      selectedSupervisor = null;
      selectedQa = null;
      selectedChecker = null;
      orderQty.text = '';
      issueQty.text = '';
      pcsChkd.text = '';
      receivedQty.text = '';
      selectedAudit = null;
    });
  }

  void _saveSelectedUnitToSharedPreferences(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_unit', unit);
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
          'Finish Audit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          SizedBox(
            width: 120,
            height: 30,
            child: DropdownSearch<String>(
              selectedItem: _selectedUnit,
              enabled: isReAudit,
              dropdownButtonProps: const DropdownButtonProps(
                isVisible: false,

              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                baseStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                dropdownSearchDecoration: InputDecoration(
                  labelStyle: TextStyle(fontSize: 12),
                  floatingLabelStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFF14CEB8), width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFF14CEB8), width: 2.0),
                  ),
                ),
              ),
              popupProps: const PopupProps.menu(
                showSelectedItems: true,
                fit: FlexFit.loose,
              ),
              items: _unitOptions,
              itemAsString: (item) => item,
              onChanged: (newValue) async {
                _clearList();
                styleNoOptions.clear();
                setState(() {

                  _selectedUnit = newValue;
                  _saveSelectedUnitToSharedPreferences(newValue!);
                });
                String? unit = _unitMap[_selectedUnit];
                if (newValue != null && newValue != '----') {
                  await _fetchStyleOptions(newValue);
                  await _fetchSupervisorOptions(newValue);
                  await _fetchStartTime(unit!);
                  await _fetchQAOptions(newValue);
                  await _fetchCheckerOptions(newValue);
                  await _fetchAuditOptions(unit);
                  await _fetchProductOptions();
                }
              },
            ),

          ),
        ],
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
                        enabled: isReAudit,
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
                        items: styleNoOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedStyleNo = newValue;
                          });
                          await _fetchOrderOptions(_selectedUnit!, newValue!);
                          await _fetchBuyerOptions(_selectedUnit!, newValue);
                          await _fetchColorOptions(_selectedUnit!, newValue);
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
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              enabled: isReAudit,
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
                                setState(() {
                                  selectedColor = newValue;
                                  _fetchLineOptions(_selectedUnit!, selectedStyleNo!,newValue!);
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
                  // Unit Dropdown
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        enabled: isReAudit,
                        selectedItem: selectedLine,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
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
                        items: lineOption,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(()  {
                            selectedLine = newValue;

                          });
                          String? lineId = lineIDMap[newValue];

                          await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineMap[newValue]!,selectedOrderNo!);
                          await _fetchFloorOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineMap[newValue]!);
                          await _fetchVendorOptions(lineMap[selectedLine]!);
                        },
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        const SizedBox(width: 8,),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              selectedItem: selectedFloor,
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                              enabled: false, // Disabled dropdown
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Floor',
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
                              items: floorOptions,
                              itemAsString: (item) => item,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        enabled: isReAudit,
                        selectedItem: selectedVendor,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Vendor Type',
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
                        items: vendorOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) {
                          setState(() {
                            selectedVendor = newValue;
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
                              enabled: isReAudit,
                              selectedItem: selectedInterval,
                              popupProps: const PopupProps.menu(showSearchBox: false),
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0),),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Hours',
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
                              items: hourIntervals,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedHrs = newValue;
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
                        enabled: isReAudit,
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
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownSearch<String>(
                              enabled: isReAudit,
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
                        enabled: isReAudit,
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
                              enabled: isReAudit,
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
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        readOnly: !isReAudit,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus(); // Unfocus when tapped outside
                        },
                        keyboardType: TextInputType.number,
                        controller: receivedQty,
                        decoration: const InputDecoration(
                          labelText: 'Received Qty',
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First Radio Button
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "Fresh",
                          groupValue: isFresh,
                          onChanged: (value) {
                            setState(() {
                              isFresh = value!;
                              _clearList();
                              isReAudit = true;
                            });
                          },
                        ),
                        const Text("Fresh"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Radio<String>(
                          value: "ReAudit",
                          groupValue: isFresh,
                          onChanged: (value) {
                            setState(() {
                              isFresh = value!;
                              _clearList();
                              isReAudit = false;
                            });
                          },
                        ),
                        const Text("ReAudit"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 0),
                  if (isFresh == "ReAudit")
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch<String>(
                          selectedItem: selectedAudit,
                          dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Audit No',
                              labelStyle: TextStyle(fontSize: 12),
                              floatingLabelStyle: TextStyle(fontSize: 14),
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
                          items: auditOptions,
                          itemAsString: (item) => item,
                          onChanged: (newValue) {
                            setState(() {
                              selectedAudit = newValue;
                              _fetchReAuditDataOptions(_selectedUnit!,newValue!);
                            });
                          },
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
                    int issueQtyValue = int.tryParse(issueQty.text) ?? 0;
                    int pcsChkdValue = int.tryParse(pcsChkd.text) ?? 0;
                    int recValue = int.tryParse(receivedQty.text) ?? 0;
                    print(issueQtyValue);
                    print(pcsChkdValue);
                    print(recValue);
                    if(issueQtyValue - pcsChkdValue < recValue){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Received Qty is Exceeding Issue/Balance Qty."))
                      );
                      return;
                    }
                    else if(issueQtyValue < recValue){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Received Qty is Exceeding Issue Qty."))
                      );
                    }
                    else if (selectedStyleNo == null || selectedStyleNo == "----" ||
                        selectedColor == null || selectedColor == "----" ||
                        selectedLine == null || selectedLine == "----" ||
                        selectedBuyer == null || selectedBuyer == "----" ||
                        selectedChecker == null || selectedChecker == "----" ||
                        selectedQa == null || selectedQa == "----" ||
                        selectedSupervisor == null || selectedSupervisor == "----" ||
                        pcsChkd.text.isEmpty || receivedQty.text.isEmpty) {

                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ Please fill all fields correctly. ❌"))
                      );
                      return;
                    }

                    tableData = {
                      'Style': selectedStyleNo,
                      'Color': selectedColor,
                      'Line': selectedLine,
                    };

                    String? buyerCodeLocal = buyerMap[selectedBuyer];
                    String? checker = checkerMap[selectedChecker];
                    String? qa = qaMap[selectedQa];
                    String? supervisor = supervisorMap[selectedSupervisor];
                    String? line = lineMap[selectedLine];
                    String? floor = floorMap[selectedFloor];
                    String? lineIdLocal = lineIDMap[selectedFloor];
                    String?  unit = _unitMap[_selectedUnit];
                    String? product = productMap[selectedProduct];
                    int isReAudit = 0;
                    setState(() {
                      if (isFresh == "ReAudit") {
                        isReAudit = 1;
                      }
                      else {
                        isReAudit = 0;
                      }
                    });

                    textData = {
                      'Pcs Checked': pcsChkd.text,
                      'Received Qty': receivedQty.text,
                      'Buyer': isReAudit == 0 ? buyerCodeLocal : buyerCode,
                    };

                    allData = {
                      'Unit' : unit,
                      'Style': selectedStyleNo!,
                      'Order' : selectedOrderNo!,
                      'Buyer': isReAudit == 0 ? buyerCodeLocal! : buyerCode!,
                      'Color': selectedColor!,
                      'Product' : product!,
                      'Line': line!,
                      'Floor' : isReAudit == 0 ? floor! : floorId!,
                      'LineId' : isReAudit == 0 ? lineIdLocal! : lineId!,
                      'Hrs' : selectedInterval!,
                      'PcsChecked': pcsChkd.text,
                      'OrderQty': orderQty.text,
                      'IssueQty': issueQty.text,
                      'Checker' : checker!,
                      'CheckerName' : selectedChecker?.split('(')[0].trim(),
                      'QA' : qa!,
                      'QAName' : selectedQa?.split('(')[0].trim(),
                      'Supervisor' : supervisor!,
                      'SupervisorName' : selectedSupervisor?.split('(')[0].trim(),
                      'Vendor': selectedVendor!,
                      'AuditType' : 'F',
                      'ReAuditNo' : reAuditNo,
                      'IsReAudit' : isReAudit,
                      'Version' : version,
                      'DeviceId' : uuid,
                      'Login' : _loginId,
                    };

                    if (kDebugMode) {
                      print(allData);
                    }

                    Set<String> excludeFields = {'ReAuditNo', 'DeviceId'};
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
    String?  unit = _unitMap[_selectedUnit];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinishingAuditPage(
          tableData: tableData,
          textFieldData: textData,
          allData: allData,
        ),
      ),
    );
    await _fetchStartTime(unit!);
    await _fetchAuditOptions(unit);
  }
}