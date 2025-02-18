import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/uuid.dart';
import '../common/utils/constants/baseurl.dart';

class PoApprovalDtl extends StatefulWidget {
  final String ? poNo;
  final String ? approvalFor;
  final String ? pageName;
  final String ? Amount;
  const PoApprovalDtl({super.key, required this.poNo, required this.approvalFor, required this.pageName, required this.Amount});

  @override
  State<PoApprovalDtl> createState() => _PoApprovalDtlState();
}

class _PoApprovalDtlState extends State<PoApprovalDtl> {
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _userData = [];
  List<Map<String, dynamic>> _spclPermission = [];
  List<String> special_rigths = [];
  Set<dynamic> userTypes = {};

  bool isQtyApproval = true;
  bool isPriceApproval = true;
  bool isSubGroup = true;
  bool isAmount = true;
  bool isBothApproval = false;
  bool isUserTypeSame = false;

  int qtyCount = 0;
  int priceCount = 0;
  String? uuid = '';


  @override
  void initState() {
    _getDtlData(widget.poNo);
    // TODO: implement initState
    super.initState();
    getUid();
  }
  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  Future<bool> _showSubGroupDialog(BuildContext context,String msg,String title) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$title Alert"),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);  // Confirm action
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ) ?? false;  // Return false if the dialog is dismissed
  }

  Future<void> _getDtlData(String ? poNo) async{
    var pageName = widget.pageName.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url1 = '${TBaseURL.baseUrl}/special?user=$loginId&module=MobileApplication&page=$pageName';
    if (kDebugMode) {
      print(url1);
    }
    final response1 = await http.get(Uri.parse(url1));
    if (response1.statusCode == 200){
      final List<dynamic> data = jsonDecode(response1.body);
      _spclPermission = List<Map<String, dynamic>>.from(data);
      setState(() {
        special_rigths = _spclPermission.map((item) => item['name'] as String).toList();
      });
    }else{
      throw Exception('Unable to get Permissions.');
    }
    final String url = '${TBaseURL.baseUrl}/po_approval_new?type=dtl&po_no=$poNo&pageName=$pageName&user=$loginId';
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);
      if (data[0]['MsgType'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SubGroups Not Available'),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
          ),
        );
      } else

      {setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
        // final Map<String, dynamic> subgroupSums = {};
        // for (var item in _tableData) {
        //   final subgroup = item['ITEM_SUBGROUP'];
        //   final amount = item['AMOUNT'];
        //   final allowAmount = item['ALLOW_AMOUNT'];
        //
        //   if (!subgroupSums.containsKey(subgroup)) {
        //     subgroupSums[subgroup] = {'sum': 0, 'allowAmount': allowAmount};
        //   }
        //   subgroupSums[subgroup]['sum'] += amount;
        // }
        //
        // // Check if any sum exceeds the ALLOW_AMOUNT and display an alert
        // subgroupSums.forEach((subgroup, values) {
        //   final sum = values['sum'];
        //   final allowAmount = values['allowAmount'];
        //
        //   if (sum > allowAmount) {
        //     // Show an alert for this subgroup
        //     _showSubGroupDialog(context,"Subgroup: $subgroup exceeds allowed amount.\nSum: $sum, Allow: $allowAmount",'Amount');
        //   }
        // });
        final maxAllowAmount = _tableData.fold<double>(
          0,
              (currentMax, item) => item['ALLOW_AMOUNT'] > currentMax ? item['ALLOW_AMOUNT'] : currentMax,
        );

        // Compare AMOUNT with the max ALLOW_AMOUNT for each item
        for (var item in _tableData) {
          final amount = item['AMOUNT'];
          if (amount > maxAllowAmount) {
            // Show an alert if the AMOUNT exceeds the max ALLOW_AMOUNT
            isAmount = false;
          }
        }
      });}
    }else{
      throw Exception('Unable to get data.');
    }

    // if (special_rigths.contains('QtyApproval') && _tableData[0]['VERIFY'] == 'N' ){
    //   isQtyApproval = true;
    // }
    // if (special_rigths.contains('PriceApproval') && _tableData[0]['VERIFY'] == 'Y'  && _tableData[0]['PRICE_VERIFY'] == 'N' ){
    //   isPriceApproval = true;
    // }
    // if (special_rigths.contains('PriceApproval') && special_rigths.contains('QtyApproval') && _tableData[0]['VERIFY'] == 'N'  && _tableData[0]['PRICE_VERIFY'] == 'N' ){
    //   isBothApproval = true;
    // }

    String itemGroup = '';
    
      for (var data in _tableData) {
        if (!data['IGNORE_SUBGROUP']) {
          if (data['ALLOW_SUBGROUP'] == 0) {
            itemGroup = data['ITEM_SUBGROUP'];
            isSubGroup = false;
            if (kDebugMode) {
              print(isSubGroup);
            }
          }
        }
        qtyCount += data['IS_QTY'] ? 1 : 0;
        priceCount += data['IS_PRICE'] ? 1 : 0;
        if(!data['IS_PRICE'] || data['VERIFY'] == 'N') {
          isPriceApproval = false;
        }
        if(!data['IS_QTY'] || data['VERIFY'] == 'Y') {
          isQtyApproval = false;
        }
        if(data['IS_PRICE'] && data['VERIFY'] == 'N') {
          isBothApproval = true;
        }
        if (data['UserType'] != null) {
          userTypes.add(data['UserType']);
        }
      }
    if (userTypes.length > 1) {
      isUserTypeSame = true;
    }

      if((priceCount > 0 && qtyCount > 0 && priceCount != qtyCount) || isUserTypeSame){
        isQtyApproval = false;
        isPriceApproval = false;
        isBothApproval = false;
        _showSubGroupDialog(context, "You don't have access permission for item group", 'No Access');
      }

      if(!isSubGroup){
        _showSubGroupDialog(context,"You don't have access permission for item group : $itemGroup",'Permission');
      }

    final String url2 = '${TBaseURL.baseUrl}/po_approval_new?type=userDtl&pageName=$pageName&user=$loginId&Amount=${widget.Amount}';
    if (kDebugMode) {
      print(url2);
    }
    final response2 = await http.get(Uri.parse(url2));
    if (response2.statusCode == 200){
      final List<dynamic> data = jsonDecode(response2.body);

      setState(() {
        _userData = List<Map<String, dynamic>>.from(data);
      });
    }else{
      throw Exception('Unable to get data.');
    }
  }

  Future<void> _saveData(String approvalType, String pageName) async {
      var poNo = widget.poNo;
      final prefs = await SharedPreferences.getInstance();
      var loginId = prefs.getString('login_id');
      int isFinal = 0;
      if (_userData[0]['IsFinal'] == 1){
        isFinal = 1;
      }

      String url = '';
      if(!isAmount && pageName == 'GeneralPO') {
        url = '${TBaseURL
            .baseUrl}po_approval_new?type=submit&po_no=$poNo&approvalType=$approvalType&user=$loginId&pageName=$pageName&isFinal=0&device_id=$uuid';
        if (kDebugMode) {
          print('not $isFinal');
        }
      }
      else {
        url = '${TBaseURL
            .baseUrl}po_approval_new?type=submit&po_no=$poNo&approvalType=$approvalType&user=$loginId&pageName=$pageName &isFinal=$isFinal&device_id=$uuid';
        if (kDebugMode) {
          print('dddf $isFinal');
        }
      }
      if (kDebugMode) {
        print(url);
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200){
        final List<dynamic> data = jsonDecode(response.body);
        if(data[0]['Results'] == 'Done'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PO Approved.'),
              duration: Duration(seconds: 3),
            ),
          );

          // Navigate to another page if needed
          Navigator.pop(context, true);

        }else if(data[0]['Results'] == 'No ErpName'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erp Name is not updated. Kindly contact to IT Support.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else{
            // Show error message in SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to save data.'),
                duration: Duration(seconds: 3),
              ),
            );
        }
      }else{
        throw Exception('Unable to save data.');
      }
  }

  @override
  Widget build(BuildContext context) {
    var pageType = widget.approvalFor;

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
          title: Text(
            '$pageType Approval',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),body:
    InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      panAxis: PanAxis.free,
      minScale: 1.0,
      maxScale: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if(isSubGroup)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isQtyApproval)
                          ElevatedButton(
                            onPressed: () { _saveData('Qty', widget.pageName.toString()); },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
                            child: const Text('Qty Verify',style: TextStyle(color: Colors.white),),
                          ),
                        if (isPriceApproval)
                          ElevatedButton(
                            onPressed: () { _saveData('Price', widget.pageName.toString()); },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange,),
                            child: const Text('Price Verify',style: TextStyle(color: Colors.white),),
                          ),
                        if (isBothApproval)
                          ElevatedButton(
                            onPressed: () { _saveData('Both', widget.pageName.toString()); },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),
                            child: const Text('Po Verify',style: TextStyle(color: Colors.white),),
                          ),
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
                            columnWidths: const {
                              0 : IntrinsicColumnWidth(),
                              1 : FixedColumnWidth(250),
                              2 : IntrinsicColumnWidth(),
                              3 : IntrinsicColumnWidth(),
                              4 : IntrinsicColumnWidth(),
                              5 : IntrinsicColumnWidth(),
                              6 : IntrinsicColumnWidth(),
                              7 : IntrinsicColumnWidth(),
                            },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[200],
                              ),
                              children: const [
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Po No', softWrap: false, overflow: TextOverflow.clip),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Item Code'),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('UOM'),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Color', softWrap: false, overflow: TextOverflow.clip),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Width',textAlign: TextAlign.right, softWrap: false, overflow: TextOverflow.clip),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Qty',textAlign: TextAlign.right, softWrap: false, overflow: TextOverflow.clip),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Po Rate',textAlign: TextAlign.right, softWrap: false, overflow: TextOverflow.clip),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Last Po Rate',textAlign: TextAlign.right, softWrap: false, overflow: TextOverflow.clip),),
                              ]
                            ),
                            ..._tableData.asMap().entries.map((entry) {
                              var item = entry.value;

                              // Check if PO_RATE and LAST_PO_RATE are different
                              bool isDifferent = false;
                              print('${item["PO_RATE"]} & ${item["LAST_PO_RATE"]}');
                              if(item['LAST_PO_RATE'] != 0 && item['LAST_PO_RATE'] != null) {
                                isDifferent = item['PO_RATE'] >
                                    item['LAST_PO_RATE'];
                              }

                              return TableRow(
                                  decoration: BoxDecoration(
                                    color: isDifferent ? Colors.red[300] : Colors.transparent,
                                  ),
                                  children: [
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['PO_NO'].toString(), softWrap: false, overflow: TextOverflow.clip, style: const TextStyle(fontSize: 12),),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['ITEM_CODE'].toString(), style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['UOM'].toString(), style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text((item['COLOR'] ?? '').toString(), softWrap: false, overflow: TextOverflow.clip, style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text((item['WIDTH'] ?? '').toString(), style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['PO_QTY'].toString(), style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(item['PO_RATE'].toString(), style: const TextStyle(fontSize: 12)),),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text((item['LAST_PO_RATE'] ?? '').toString(), style: const TextStyle(fontSize: 12)),),
                                ]
                              );
                            })
                          ]
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
