import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Audit/Finishing_audit/finish_audit.dart';
import 'package:ppms/Audit/Sewing_Audit/sewing_audit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

import '../../ExtraFunction/uuid.dart';
import '../../common/utils/constants/baseurl.dart';

class FinishingAuditSelection extends StatefulWidget {
  const FinishingAuditSelection({super.key});

  @override
  FinishingAuditSelectionState createState() => FinishingAuditSelectionState();
}

class FinishingAuditSelectionState extends State<FinishingAuditSelection> {
  String? _loginId;
  int _currentIndex = 0;
  TextEditingController orderQty = TextEditingController();
  TextEditingController issueQty = TextEditingController();
  TextEditingController receivedQty = TextEditingController();
  TextEditingController pcsChkd = TextEditingController();

  String isFresh = "Fresh";
  List<String> _unitOptions = [];
  Map<String, String> _unitMap = {},_unitMapVg = {};
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
  String? lineId;

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
  String? selectedProduct = '';

  List<String> supervisorOptions = [];
  Map<String, String> supervisorMap = {};
  String? selectedSupervisor;

  List<String> qaOptions = [];
  Map<String, String> qaMap = {};
  String? selectedQa;

  List<String> checkerOptions = [];
  Map<String, String> checkerMap = {};
  String? selectedChecker;

  List<String> aqmOptions = [];
  Map<String, String> aqmMap = {};
  String? selectedAqm;

  List<String> inChargeOptions = [];
  Map<String, String> inChargeMap = {};
  String? selectedInCharge;

  List<String> auditOptions = [];
  Map<String, String> auditMap = {};
  String? selectedAudit;

  Map<String, dynamic> tableData = {};
  Map<String, dynamic> textData = {};
  Map<String, dynamic> allData = {};

  bool isSelected = false,isReAudit = true,isOutHouse = false;
  String version = '',uuid = '',reAuditNo = '';
  String startTime = '';
  String? selectedTime;
  late List<String> timeSlots;
  List<String> hourIntervals = [];
  String? selectedInterval;


  @override
  void initState() {
    super.initState();
    _fetchUnitOptions('Apps');
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
    DateTime startDateTime = DateTime.parse("$date $startTime");
    DateTime now = DateTime.parse("$date $currentTime");

    List<String> intervals = [];
    int count = 0;

    while (startDateTime.isBefore(DateTime.parse("$date 23:59:59"))) {
      // Add the interval if it matches the previous hour or the current hour
      if (startDateTime.isAfter(now.subtract(const Duration(hours: 1))) &&
          startDateTime.isBefore(now.add(const Duration(hours: 1)))) {
        intervals.add(count.toString());
      }

      count++;
      startDateTime = startDateTime.add(const Duration(hours: 1));
    }

    return intervals;
  }

  Future<void> _fetchUnitOptions(String type) async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId';
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId');
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _unitOptions = data.map((e) => e['UnitShortCode1'].toString()).toList();
        _unitMap = {
          for (var item in data) item['UnitShortCode1']
              .toString(): item['UnitCode1'].toString()
        };
        _unitMapVg = {
          for (var item in data) item['UnitShortCode1']
              .toString(): item['UnitCode'].toString()
        };
        _selectedUnit = _unitOptions.isNotEmpty ? _unitOptions[0] : null;
      });


      String? unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];

      await _fetchVendorOptions();
      await _fetchSupervisorOptions(_selectedUnit!);
      await _fetchStartTime(unit!);
      await _fetchQAOptions(_selectedUnit!);
      await _fetchCheckerOptions(_selectedUnit!);
      await _fetchAqmOptions(_selectedUnit!);
      await _fetchInChargeOptions(_selectedUnit!);
      await _fetchAuditOptions(unit);


    } else {
      if (kDebugMode) {
        print('Failed to load Unit options');
      }
    }
  }

  Future<void> _fetchStyleOptions(String unit,String line) async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps'){
      url = '${TBaseURL.auditUrl}finishing_audit_new?type=Style&unit=$unit&style=&color=&lineId=$line&line_Id=&orderNo=';
    }
    else if(type == 'VG'){
      String? vgUnit = _unitMapVg[unit];
      print(selectedVendor);
      if(selectedVendor == 'InHouse') {
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Style&Unit=$vgUnit&Line=$line&Party=&Vendor=$selectedVendor';
      }
      else{
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Style&Unit=$vgUnit&Line=&Party=$line&Vendor=$selectedVendor';
      }
    }
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => e['STYLE_NO'].toString()).toList();
      String lineKey = selectedLine ?? '';
      String? style = await loadLineMappedPref('styleSewingByLine', lineKey);
      setState(() {
        styleNoOptions =  options;
        styleMap = {for (var item in data) item['STYLE_NO'].toString(): item['STYLE_NO'].toString()};
        selectedStyleNo = (style != null && options.contains(style))
            ? style
            : (options.isNotEmpty ? options[0] : null);
      });

      String? lineApps = lineMap[selectedLine];
      String? lineId = lineIDMap[selectedFloor];
      String type = _currentIndex == 0 ? 'Apps' : 'VG';
      selectedOrderNo = null;
      selectedBuyer = null;
      selectedColor = null;
      orderQty.text = '';
      issueQty.text = '';
      pcsChkd.text = '';
      receivedQty.text = '';
      if(type == 'Apps') {
        await _fetchOrderOptions(_selectedUnit!, selectedStyleNo!);
        await _fetchBuyerOptions(_selectedUnit!, selectedStyleNo!);
        await _fetchColorOptions(_selectedUnit!, selectedStyleNo!);
        await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineApps!,selectedOrderNo!);
      }
      else if(type == 'VG'){
        String? lineId = lineMap[selectedLine];
        await _fetchOdrByrClr(_selectedUnit!,selectedStyleNo!,lineId!);
      }
      String? unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];
      await _fetchStartTime(unit!);
      await _fetchProductOptions();

    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchAuditOptions(String unit) async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps') {
      url = '${TBaseURL
          .auditUrl}finishing_audit_new?type=AuditNo&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=';
    }
    else if(type == 'VG'){
      String? vgUnit = _unitMapVg[_selectedUnit];
      url = '${TBaseURL
          .auditUrl}finishing_audit_new?type=AuditNo&unit=$vgUnit&style=&color=&lineId=&line_Id=&orderNo=';
    }
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
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps') {
      url = '${TBaseURL
          .auditUrl}finishing_audit?type=ReAudit&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=&AuditNo=$audit';
    }
    else if(type == 'VG'){
      url = '${TBaseURL.auditUrl}finish_audit_vg?type=ReAudit&Unit=&AuditNo=$audit';
    }
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
        selectedVendor = data[0]['VendorType'];
        if(selectedVendor == 'INH-FINISHING' || selectedVendor == 'InHouse'){
          isOutHouse = false;
        }
        else{
          isOutHouse = true;
        }
        if(!isOutHouse) {
          selectedLine = data[0]['LineName'];
          lineId = data[0]['LineId'];
        }
        else{
          selectedLine = data[0]['LineName1'];
          lineId = data[0]['VendorId'];
        }
        selectedFloor = data[0]['FloorName'];
        floorId = data[0]['FloorId'];

        selectedInterval = (data[0]['Hrs']).toString();
        selectedProduct = data[0]['Component'];
        selectedSupervisor = supervisorMap.keys.firstWhere((key) => supervisorMap[key] == data[0]['Supervisor']);
        selectedQa = qaMap.keys.firstWhere((key) => qaMap[key] == data[0]['QA']);
        selectedAqm = aqmMap.keys.firstWhere((key) => aqmMap[key] == data[0]['AQM']);
        selectedInCharge = inChargeMap.keys.firstWhere((key) => inChargeMap[key] == data[0]['Incharge']);
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
    String url = '${TBaseURL.auditUrl}finishing_audit_vg_new?type=StartTime&Unit=$unit';
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
        startTime = data[0]['UnitStartTime'];
        if (kDebugMode) {
          print(startTime);
        }
      });
      Future.delayed(const Duration(milliseconds: 300),(){
        String currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
        hourIntervals = generateHourlyIntervals(startTime, currentTime);

        // Set the selected value to the most recent interval
        setState(() {
          if (hourIntervals.isNotEmpty) {
            selectedInterval = hourIntervals.last;
          }
        });

        print(hourIntervals);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchOdrByrClr(String unit, String style,String line) async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String? vgUnit = _unitMapVg[unit];
    String url = '';
    if(!isOutHouse) {
      url = '${TBaseURL
          .auditUrl}finishing_audit_vg_new?type=OdrByrClr&Unit=$vgUnit&style=$style&Line=$line&Party=&Vendor=$selectedVendor';
    }
    else{
      url = '${TBaseURL
          .auditUrl}finishing_audit_vg_new?type=OdrByrClr&Unit=$vgUnit&style=$style&Line=&Party=$line&Vendor=$selectedVendor';
    }
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print('data $data');
      }
      String? lineId;
      List<String> options = data.map((e) => e['COLOR_COMBO'].toString()).toList();
      String lineKey = selectedLine ?? '';
      String? savedColor = await loadLineMappedPref('colorSewingByLine', lineKey);
      setState(() {
        buyerOptions =  data.map((e) => e['BUYER_NAME'].toString()).toList();
        buyerMap = {for (var item in data) item['BUYER_NAME'].toString(): item['BUYER_CODE'].toString()};
        selectedBuyer = buyerOptions.isNotEmpty ? buyerOptions[0] : null;
        orderNoOptions =  data.map((e) => e['ORDER_NO'].toString()).toList();
        orderMap = {for (var item in data) item['ORDER_NO'].toString(): item['ORDER_NO'].toString()};
        selectedOrderNo = orderNoOptions.isNotEmpty ? orderNoOptions[0] : null;
        colorOptions =  options;
        colorMap = {for (var item in data) item['COLOR_COMBO'].toString(): item['COLOR_COMBO'].toString()};
        selectedColor = (savedColor != null && options.contains(savedColor))
            ? savedColor
            : (options.isNotEmpty ? options[0] : null);
        lineId = lineMap[selectedLine];
      });

      String? unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];

      await _fetchStartTime(unit!);
      await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineMap[selectedLine]!,selectedOrderNo!);
      await _fetchProductOptions();

    } else {
      if (kDebugMode) {
        print('Failed to load Buyer options');
      }
    }
  }

  Future<void> _fetchBuyerOptions(String unit, String style) async {
    String url = '${TBaseURL.auditUrl}finishing_audit_new?type=Buyer&unit=$unit&style=$style&color=&lineId=&line_Id=&orderNo=';
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
    String url = '${TBaseURL.auditUrl}finishing_audit_new?type=Order&unit=$unit&style=$style&color=&lineId=&line_Id=&orderNo=';
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
    String url = '${TBaseURL.auditUrl}finishing_audit_new?type=Color&unit=$unit&style=$style&color=&lineId=${lineMap[selectedLine]}&line_Id=&orderNo=';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => e['COLOR_COMBO'].toString()).toList();
      String lineKey = selectedLine ?? '';
      String? savedColor = await loadLineMappedPref('colorSewingByLine', lineKey);
      String? lineId;
      setState(() {
        colorOptions =  options;
        colorMap = {for (var item in data) item['COLOR_COMBO'].toString(): item['COLOR_COMBO'].toString()};
        selectedColor = (savedColor != null && options.contains(savedColor))
            ? savedColor
            : (options.isNotEmpty ? options[0] : null);
      });
      String type = _currentIndex == 0 ? 'Apps' : 'VG';
      if(isOutHouse){
        lineId = lineMap[selectedLine];
      }
      else {
        lineId = lineIDMap[selectedFloor];
      }
      await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineMap[selectedLine]!,selectedOrderNo!);
      await _fetchProductOptions();
    } else {
      if (kDebugMode) {
        print('Failed to load Color options');
      }
    }
  }

  Future<void> _fetchLineOptions(String unit, String vendor) async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps') {
      url = '${TBaseURL
          .auditUrl}finishing_audit_new?type=Line&unit=$unit&style=&color=&lineId=&line_Id=&orderNo=&vendor=$vendor';
    }
    else if(type == 'VG'){
      String? vgUnit = _unitMapVg[unit];
      if(vendor == 'InHouse') {
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Line&Unit=$vgUnit&Vendor=$vendor';
      }
      else{
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=VendorName&Unit=$vgUnit&Vendor=$vendor';
      }
    }
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        lineOption =  ['----'] + data.map((e) => e['LINENAME'].toString()).toList();
        lineMap = {for (var item in data) item['LINENAME'].toString(): item['LINEID'].toString()};
        selectedLine = lineOption.isNotEmpty ? lineOption[0] : null;
      });
      // await _fetchStyleOptions(unit, type,lineMap[selectedLine]!);

    } else {
      if (kDebugMode) {
        print('Failed to load Line options');
      }
    }
  }

  Future<void> _fetchFloorOptions(String unit,String line) async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps'){
      url = '${TBaseURL.auditUrl}finishing_audit_new?type=Floor&unit=$unit&style=&color=&lineId=$line&line_Id=&orderNo=';
    }
    else if (type == 'VG'){
      String? vgUnit = _unitMapVg[unit];
      url = '${TBaseURL
          .auditUrl}finishing_audit_vg_new?type=Floor&Unit=$vgUnit&line=$line';
    }
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

      if (kDebugMode) {
        print(lineIDMap);
      }
    } else {
      if (kDebugMode) {
        print('Failed to load Floor options');
      }
    }
  }

  Future<void> _fetchVendorOptions() async {
    String type = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps') {
      url = '${TBaseURL
          .auditUrl}finishing_audit_new?type=Vendor&unit=&style=&color=&lineId=&line_Id=&orderNo=';
    }
    else if(type == 'VG'){
      url = '${TBaseURL
          .auditUrl}finishing_audit_vg_new?type=Vendor&Unit=&style=&color=&line=';
    }
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));


    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }

      setState(() {
        vendorOptions =  data.map((e) => e['VENDOR_GROUP'].toString()).toList();
        vendorMap = {for (var item in data) item['VENDOR_GROUP'].toString(): item['VENDOR_GROUP'].toString()};
        selectedVendor = vendorOptions.isNotEmpty ? vendorOptions[0] : null;
        if(selectedVendor == 'OH-FINISHING' || selectedVendor == 'OutHouse' || selectedVendor == 'PR-WORK' || selectedVendor == 'PcsRate'){
          isOutHouse = true;
        }
        else{
          isOutHouse = false;
        }
        if(selectedVendor != null || selectedVendor != '') {
          _fetchLineOptions(_selectedUnit!, selectedVendor!);
        }
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Vendor options');
      }
    }
  }

  Future<void> _fetchQtyOptions(String unit, String style,String color,String line,String lineId,String order) async {
    String type  = _currentIndex == 0 ? 'Apps' : 'VG';
    String url = '';
    if(type == 'Apps') {
      if(!isOutHouse) {
        url = '${TBaseURL
            .auditUrl}finishing_audit_new?type=Qty&unit=$unit&style=$style&color=$color&line_Id=$line&lineId=$lineId&orderNo=$order&vendor=';
      }
      else{
        url = '${TBaseURL
            .auditUrl}finishing_audit_new?type=Qty&unit=$unit&style=$style&color=$color&line_Id=&lineId=$lineId&orderNo=$order&vendor=$line';
      }
    }
    else if(type == 'VG'){
      String? vgUnit = _unitMapVg[unit];
      if(!isOutHouse) {
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Qty&Unit=$vgUnit&style=$style&color=$color&line=$lineId&order=$order&Party=&Vendor=$selectedVendor';
      }
      else{
        url = '${TBaseURL
            .auditUrl}finishing_audit_vg_new?type=Qty&Unit=$vgUnit&style=$style&color=$color&line=&order=$order&Party=$lineId&Vendor=$selectedVendor';
      }
    }
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

  Future<void> saveLineMappedPref(String prefKey, String line, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> map = {};
    String? jsonString = prefs.getString(prefKey);
    if (jsonString != null) {
      map = Map<String, String>.from(json.decode(jsonString));
    }
    map[line] = value;
    await prefs.setString(prefKey, json.encode(map));
  }

  Future<String?> loadLineMappedPref(String prefKey, String line) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(prefKey);
    if (jsonString == null) return null;
    Map<String, dynamic> map = json.decode(jsonString);
    return map[line] as String?;
  }

  Future<void> _fetchSupervisorOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit_vg_new?type=Supervisor&Unit=$unit';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
      String lineKey = selectedLine ?? '';
      String? sup = await loadLineMappedPref('supSewingByLine', lineKey);
      setState(() {
        supervisorOptions = options;
        supervisorMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedSupervisor = (sup != null && options.contains(sup))
            ? sup
            : (options.isNotEmpty ? options[0] : null);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Supervisor options');
      }
    }
  }

  Future<void> _fetchQAOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit_vg_new?type=QA&Unit=$unit';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
      String lineKey = selectedLine ?? '';
      String? savedQa = await loadLineMappedPref('qaSewingByLine', lineKey);
      setState(() {
        qaOptions = options;
        qaMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedQa = (savedQa != null && options.contains(savedQa))
            ? savedQa
            : (options.isNotEmpty ? options[0] : null);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load QA options');
      }
    }
  }

  Future<void> _fetchCheckerOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}finishing_audit_vg_new?type=Checker&Unit=$unit';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
      String lineKey = selectedLine ?? '';
      String? savedCheck = await loadLineMappedPref('checkerSewingByLine', lineKey);
      setState(() {
        checkerOptions = options;
        checkerMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedChecker = (savedCheck != null && options.contains(savedCheck))
            ? savedCheck
            : (options.isNotEmpty ? options[0] : null);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Checker options');
      }
    }
  }

  Future<void> _fetchAqmOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}sewing_audit_vg_new?type=AQM&Unit=$unit';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
      String lineKey = selectedLine ?? '';
      String? savedCheck = await loadLineMappedPref('aqmSewingByLine', lineKey);
      setState(() {
        aqmOptions = options;
        aqmMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedAqm = (savedCheck != null && options.contains(savedCheck))
            ? savedCheck
            : (options.isNotEmpty ? options[0] : null);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Checker options');
      }
    }
  }

  Future<void> _fetchInChargeOptions(String unit) async {
    String url = '${TBaseURL.auditUrl}sewing_audit_vg_new?type=InCharge&Unit=$unit';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => '${e['NAME']}(${e['PAY_CODE']})').toList();
      String lineKey = selectedLine ?? '';
      String? savedCheck = await loadLineMappedPref('inChargeSewingByLine', lineKey);
      setState(() {
        inChargeOptions = options;
        inChargeMap = {for (var item in data) '${item['NAME']}(${item['PAY_CODE']})': item['PAY_CODE'].toString()};
        selectedInCharge = (savedCheck != null && options.contains(savedCheck))
            ? savedCheck
            : (options.isNotEmpty ? options[0] : null);
      });
    } else {
      if (kDebugMode) {
        print('Failed to load Checker options');
      }
    }
  }

  Future<void> _fetchProductOptions() async {
    String url = '${TBaseURL.auditUrl}finishing_audit_vg_new?type=Product&Unit=&order=$selectedOrderNo&color=$selectedColor&Vendor=$selectedVendor';
    final response = await http.get(Uri.parse(url));

    if (kDebugMode) {
      print(url);
    }

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<String> options = data.map((e) => e['Component'].toString()).toList();
      // Use an empty string if selectedLine is null
      String lineKey = selectedLine ?? '';
      String? savedProd = await loadLineMappedPref('prodSewingByLine', lineKey);
      setState(() {
        productOptions = options;
        productMap = {for (var item in data) item['Component'].toString(): item['Component'].toString()};
        selectedProduct = (savedProd != null && options.contains(savedProd))
            ? savedProd
            : (options.isNotEmpty ? options[0] : '');
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
      styleMap.clear();
      styleNoOptions.clear();
      productOptions.clear();
      selectedOrderNo = null;
      lineMap.clear();
      lineOption.clear();
      colorMap.clear();
      colorOptions.clear();
      selectedColor = null;
      selectedLine = null;
      selectedFloor = null;
      selectedProduct = '';
      selectedInterval = null;
      selectedVendor = null;
      selectedSupervisor = null;
      selectedQa = null;
      selectedChecker = null;
      selectedAqm = null;
      selectedInCharge = null;
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
          'Finishing Audit',
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
                lineOption.clear();
                vendorOptions.clear();
                supervisorOptions.clear();
                qaOptions.clear();
                checkerOptions.clear();
                aqmOptions.clear();
                inChargeOptions.clear();
                setState(() {

                  _selectedUnit = newValue;
                  _saveSelectedUnitToSharedPreferences(newValue!);
                });
                String? unit = _unitMap[_selectedUnit];
                String type = _currentIndex == 0 ? 'Apps' : 'VG';
                if (newValue != null && newValue != '----') {
                  await _fetchVendorOptions();
                  await _fetchSupervisorOptions(newValue);
                  await _fetchStartTime(unit!);
                  await _fetchQAOptions(newValue);
                  await _fetchCheckerOptions(newValue);
                  await _fetchAqmOptions(_selectedUnit!);
                  await _fetchInChargeOptions(_selectedUnit!);
                  await _fetchAuditOptions(unit);
                }
              },
            ),

          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          _clearList();
          setState(() {
            _currentIndex = index; // Change the selected tab
          });
          String type = _currentIndex == 0 ? 'Apps' : 'VG';
          String? unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];

          await _fetchVendorOptions();
          await _fetchStartTime(unit!);
          await _fetchSupervisorOptions(_selectedUnit!);
          await _fetchQAOptions(_selectedUnit!);
          await _fetchCheckerOptions(_selectedUnit!);
          await _fetchAuditOptions(unit);
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.app_shortcut,color: Colors.black54,size: 20,), // Icon for Stitching
            label: "Apps",
            activeIcon: Icon(Icons.app_shortcut,color: Colors.black,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond,color: Colors.black54,size: 20,), // Icon for Finishing
            label: "VG",
            activeIcon: Icon(Icons.diamond,color: Colors.black,size: 25,),
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
                  // Unit Dropdown
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40,
                      child: DropdownSearch<String>(
                        enabled: isReAudit,
                        selectedItem: selectedLine,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration(!isOutHouse ? 'Line' : 'Vendor'),
                        ),
                        items: lineOption,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(()  {
                            selectedLine = newValue;
                          });
                          String? lineId = lineIDMap[newValue];

                          await _fetchSupervisorOptions(_selectedUnit!);
                          await _fetchQAOptions(_selectedUnit!);
                          await _fetchCheckerOptions(_selectedUnit!);
                          await _fetchFloorOptions(_selectedUnit!,lineMap[newValue]!);
                          await _fetchStyleOptions(_selectedUnit!,lineMap[newValue]!);
                          await saveLineMappedPref('prodSewingByLine', selectedLine ?? '', selectedProduct ?? '');
                          await saveLineMappedPref('supSewingByLine', selectedLine ?? '', selectedSupervisor ?? '');
                          await saveLineMappedPref('qaSewingByLine', selectedLine ?? '', selectedQa ?? '');
                          await saveLineMappedPref('checkerSewingByLine', selectedLine ?? '', selectedChecker ?? '');
                          await saveLineMappedPref('aqmSewingByLine', selectedLine ?? '', selectedColor ?? '');
                          await saveLineMappedPref('inChargeSewingByLine', selectedLine ?? '', selectedColor ?? '');
                        },
                      ),
                    ),
                  ),
                  if(!isOutHouse)
                    const SizedBox(width: 8,),
                  if(!isOutHouse)
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch<String>(
                          selectedItem: selectedFloor,
                          dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                          enabled: false, // Disabled dropdown
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: dropdownDecoration('Floor'),
                          ),
                          items: floorOptions,
                          itemAsString: (item) => item,
                        ),
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
                        selectedItem: selectedStyleNo,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('Style No'),
                        ),
                        items: styleNoOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedStyleNo = newValue;
                          });
                          await saveLineMappedPref('styleSewingByLine', selectedLine ?? '', newValue ?? '');
                          String? line = lineMap[selectedLine];
                          String? lineId = lineIDMap[selectedFloor];
                          String type = _currentIndex == 0 ? 'Apps' : 'VG';
                          selectedOrderNo = null;
                          selectedBuyer = null;
                          selectedColor = null;
                          orderQty.text = '';
                          issueQty.text = '';
                          pcsChkd.text = '';
                          receivedQty.text = '';
                          if(type == 'Apps') {
                            await _fetchOrderOptions(_selectedUnit!, newValue!);
                            await _fetchBuyerOptions(_selectedUnit!, newValue);
                            await _fetchColorOptions(_selectedUnit!, newValue);
                            await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,line!,selectedOrderNo!);
                          }
                          else if(type == 'VG'){
                            String? vgUnit = _unitMapVg[_selectedUnit];
                            String? lineId = lineMap[selectedLine];
                            await _fetchOdrByrClr(_selectedUnit!,newValue!,lineId!);
                            await _fetchProductOptions();
                          }
                          String? unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];
                          await _fetchStartTime(unit!);
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
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('Order No'),
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
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('Buyer'),
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
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: dropdownDecoration('Color'),
                              ),
                              items: colorOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) async {
                                setState(() {
                                  selectedColor = newValue;
                                });
                                await saveLineMappedPref('colorSewingByLine', selectedLine ?? '', newValue ?? '');
                                String? lineId;
                                String? line = lineMap[selectedLine];
                                if(isOutHouse){
                                  lineId = lineMap[selectedLine];
                                }
                                else {
                                  lineId = lineIDMap[selectedFloor];
                                }
                                orderQty.text = '';
                                issueQty.text = '';
                                pcsChkd.text = '';
                                receivedQty.text = '';

                                await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,newValue!,lineId!,line!,selectedOrderNo!);
                                await _fetchProductOptions();
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
                        selectedItem: selectedVendor,
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('Vendor Type'),
                        ),
                        items: vendorOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          _clearList();
                          setState(() {
                            selectedVendor = newValue;
                          });
                          setState(() {
                            if(selectedVendor == 'OH-FINISHING' || selectedVendor == 'OutHouse'|| selectedVendor == 'PR-WORK' || selectedVendor == 'PcsRate'){
                              isOutHouse = true;
                            }
                            else{
                              isOutHouse = false;
                            }
                          });
                          String? unit = _unitMap[_selectedUnit];

                          await _fetchLineOptions(_selectedUnit!,newValue!);
                          await _fetchSupervisorOptions(_selectedUnit!);
                          await _fetchStartTime(unit!);
                          await _fetchQAOptions(_selectedUnit!);
                          await _fetchCheckerOptions(_selectedUnit!);
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
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: dropdownDecoration('Hours'),
                              ),
                              items: hourIntervals,
                              itemAsString: (item) => item,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedInterval = newValue;
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
                        enabled: isReAudit && productOptions.isNotEmpty,
                        selectedItem: selectedProduct,
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('Component'),
                        ),
                        items: productOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedProduct = newValue;
                          });
                          await saveLineMappedPref('prodSewingByLine', selectedLine ?? '', selectedProduct ?? '');
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
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: dropdownDecoration('Supervisor'),
                              ),
                              items: supervisorOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) async {
                                setState(() {
                                  selectedSupervisor = newValue;
                                });
                                await saveLineMappedPref('supSewingByLine', selectedLine ?? '', newValue ?? '');
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
                        selectedItem: selectedInCharge,
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Floor InCharge',
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
                        items: inChargeOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedInCharge = newValue;
                          });
                          await saveLineMappedPref('inChargeSewingByLine', selectedLine ?? '', newValue ?? '');
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
                              selectedItem: selectedAqm,
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'AQM',
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
                              items: aqmOptions,
                              itemAsString: (item) => item,
                              onChanged: (newValue) async {
                                setState(() {
                                  selectedAqm = newValue;
                                });
                                await saveLineMappedPref('aqmSewingByLine', selectedLine ?? '', newValue ?? '');
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
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: dropdownDecoration('QA'),
                        ),
                        items: qaOptions,
                        itemAsString: (item) => item,
                        onChanged: (newValue) async {
                          setState(() {
                            selectedQa = newValue;
                          });
                          await saveLineMappedPref('qaSewingByLine', selectedLine ?? '', newValue ?? '');
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
                        decoration: textDecoration('Order Qty'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        readOnly: true,
                        controller: issueQty,
                        decoration: textDecoration('Issue Qty'),
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
                        decoration: textDecoration('PCS Checked'),
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
                        decoration: textDecoration('Received Qty'),
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
                  // const SizedBox(width: 16),
                  // Expanded(
                  //   flex: 1,
                  //   child: Row(
                  //     children: [
                  //       Radio<String>(
                  //         value: "Sampling",
                  //         groupValue: isFresh,
                  //         onChanged: (value) {
                  //           setState(() {
                  //             isFresh = value!;
                  //             _clearList();
                  //           });
                  //         },
                  //       ),
                  //       const Text("Sampling"),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(width: 0),
                  if (isFresh == "ReAudit")
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch<String>(
                          selectedItem: selectedAudit,
                          dropdownButtonProps: const DropdownButtonProps(padding: EdgeInsets.all(0)),
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: dropdownDecoration('Audit No'),
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
                onPressed: () async {
                  setState(() {
                    int issueQtyValue = int.tryParse(issueQty.text.trim()) ?? 0;
                    int pcsChkdValue = int.tryParse(pcsChkd.text.trim()) ?? 0;
                    int recValue = int.tryParse(receivedQty.text.trim()) ?? 0;

                    print("Issue Qty: $issueQtyValue, Pcs Checked: $pcsChkdValue, Received Qty: $recValue");

                    int isReAudit = 0;
                    setState(() {
                      if (isFresh == "ReAudit") {
                        isReAudit = 1;
                      }
                      else {
                        isReAudit = 0;
                      }
                    });
                    if(isReAudit == 0){
                      if (issueQtyValue - pcsChkdValue < recValue) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Received Qty is Exceeding balance Qty."))
                        );
                        return;
                      }
                    }

                    if(isReAudit == 0) {
                      if (!isOutHouse) {
                        if (selectedStyleNo == null ||
                            selectedStyleNo == "----" ||
                            selectedColor == null || selectedColor == "----" ||
                            selectedLine == null || selectedLine == "----" ||
                            selectedBuyer == null || selectedBuyer == "----" ||
                            selectedQa == null || selectedQa == "----" ||
                            selectedSupervisor == null ||
                            selectedSupervisor == "----" ||
                            selectedAqm == null ||
                            selectedAqm == "----" ||
                            selectedInCharge == null ||
                            selectedInCharge == "----" ||
                            pcsChkd.text.isEmpty || receivedQty.text.isEmpty) {
                          // Show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  "❌ Please fill all fields correctly. ❌"))
                          );
                          return;
                        }
                      }
                      else {
                        if (selectedStyleNo == null ||
                            selectedStyleNo == "----" ||
                            selectedColor == null || selectedColor == "----" ||
                            selectedBuyer == null || selectedBuyer == "----" ||
                            selectedQa == null || selectedQa == "----" ||
                            selectedSupervisor == null ||
                            selectedSupervisor == "----" ||
                            selectedAqm == null ||
                            selectedAqm == "----" ||
                            selectedInCharge == null ||
                            selectedInCharge == "----" ||
                            pcsChkd.text.isEmpty || receivedQty.text.isEmpty) {
                          // Show an error message
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  "❌ Please fill all fields correctly. ❌"))
                          );
                          return;
                        }
                      }
                    }
                    else{
                      if (selectedStyleNo == null ||
                          selectedStyleNo == "----" ||
                          selectedColor == null || selectedColor == "----" ||
                          selectedBuyer == null || selectedBuyer == "----" ||
                          selectedQa == null || selectedQa == "----" ||
                          selectedSupervisor == null ||
                          selectedSupervisor == "----" ||
                          selectedAudit == null || selectedAudit == '----' ||
                          pcsChkd.text.isEmpty || receivedQty.text.isEmpty) {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "❌ Please fill all fields correctly. ❌"))
                        );
                        return;
                      }
                    }

                    String type = _currentIndex == 0 ? 'Apps' : 'VG';

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
                    String? aqm = aqmMap[selectedAqm];
                    String? inCharge = inChargeMap[selectedInCharge];
                    String? lineIdLocal = lineIDMap[selectedFloor];
                    String?  unit = type == 'Apps' ? _unitMap[_selectedUnit] : _unitMapVg[_selectedUnit];


                    textData = {
                      'Pcs Checked': pcsChkd.text,
                      'Received Qty': receivedQty.text,
                      'Buyer': isReAudit == 0 ? buyerCodeLocal : buyerCode,
                    };



                    allData = {
                      'Unit' : unit,
                      'UnitShCode' : _selectedUnit,
                      'Style': selectedStyleNo!,
                      'Order' : selectedOrderNo!,
                      'Buyer': isReAudit == 0 ? buyerCodeLocal! : buyerCode!,
                      'Color': selectedColor!,
                      'Product' : selectedProduct,
                      'Line': !isOutHouse ? isReAudit == 0 ? line! : lineId : '',
                      'Floor' : !isOutHouse ?isReAudit == 0 ? floor! : floorId! : '',
                      'LineId': !isOutHouse ? isReAudit == 0 ? (lineIdLocal ?? 0) : (lineId ?? 0) : '',
                      'VendorId' : isOutHouse ? isReAudit == 0 ? line! : lineId : '',
                      'Hrs' : selectedInterval!,
                      'PcsChecked': pcsChkd.text,
                      'OrderQty': orderQty.text,
                      'IssueQty': issueQty.text,
                      'QA' : qa!,
                      'QAName' : selectedQa?.split('(')[0].trim(),
                      'Supervisor' : supervisor!,
                      'SupervisorName' : selectedSupervisor?.split('(')[0].trim(),
                      'InCharge' : inCharge!,
                      'InChargeName' : selectedInCharge?.split('(')[0].trim(),
                      'AQM' : aqm!,
                      'AQMName' : selectedAqm?.split('(')[0].trim(),
                      'Vendor': selectedVendor!,
                      'AuditType' : 'F',
                      'ReAuditNo' : isReAudit == 1 ? reAuditNo : '',
                      'IsReAudit' : isReAudit,
                      'Version' : version,
                      'DeviceId' : uuid,
                      'Login' : _loginId,
                      'Type' : type,
                    };

                    if (kDebugMode) {
                      print(allData);
                    }

                    Set<String> excludeFields = {'ReAuditNo', 'DeviceId','Vendor'};
                    if (isOutHouse) {
                      excludeFields.add('Line');
                      excludeFields.add('Floor');
                      excludeFields.add('LineId');
                    } else {
                      excludeFields.add('VendorId');
                    }
                    if(productOptions.isEmpty || productOptions == []){
                      excludeFields.add('Product');
                    }
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
                  await saveLineMappedPref('prodSewingByLine', selectedLine ?? '', selectedProduct ?? '');
                  await saveLineMappedPref('supSewingByLine', selectedLine ?? '', selectedSupervisor ?? '');
                  await saveLineMappedPref('qaSewingByLine', selectedLine ?? '', selectedQa ?? '');
                  await saveLineMappedPref('checkerSewingByLine', selectedLine ?? '', selectedChecker ?? '');
                  await saveLineMappedPref('styleSewingByLine', selectedLine ?? '', selectedStyleNo ?? '');
                  await saveLineMappedPref('colorSewingByLine', selectedLine ?? '', selectedColor ?? '');
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
    String? lineId = lineIDMap[selectedFloor];
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
    setState(() {
      selectedStyleNo = null;
    });
    // await _fetchQtyOptions(_selectedUnit!, selectedStyleNo!,selectedColor!,lineId!,lineMap[selectedLine]!,selectedOrderNo!);
    if(isFresh == 'ReAudit'){
      _clearList();
    }
  }

  InputDecoration dropdownDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 12),
      floatingLabelStyle: const TextStyle(fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      disabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
      ),
    );
  }

  InputDecoration textDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(fontSize: 12),
      floatingLabelStyle: const TextStyle(fontSize: 16),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Color(0xFF5FE3D3), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
    );
  }
}