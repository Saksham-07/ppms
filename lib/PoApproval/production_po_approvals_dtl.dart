import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppms/PoApproval/po_approvals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ExtraFunction/uuid.dart';
import '../common/utils/constants/baseurl.dart';

class ProductionPoApprovalsDtl extends StatefulWidget {
  final String ? poNo;
  final String ? approvalFor;
  final String ? pageName;
  final String ? Amount;
  const ProductionPoApprovalsDtl({super.key, required this.poNo, required this.approvalFor, required this.pageName, required this.Amount});

  @override
  State<ProductionPoApprovalsDtl> createState() => _ProductionPoApprovalsDtlState();
}

class _ProductionPoApprovalsDtlState extends State<ProductionPoApprovalsDtl> {
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _spclPermission = [];
  List<Map<String, dynamic>> _userData = [];
  List<String> special_rigths = [];

  bool isQtyApproval = false;
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

  // function for getting dtl data............
  Future<void> _getDtlData(String ? poNo) async {
    var pageName = widget.pageName.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url1 = '${TBaseURL
        .baseUrl}/special?user=$loginId&module=MobileApplication&page=$pageName';
    print(url1);
    final response1 = await http.get(Uri.parse(url1));
    if (response1.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response1.body);
      _spclPermission = List<Map<String, dynamic>>.from(data);
      setState(() {
        special_rigths =
            _spclPermission.map((item) => item['name'] as String).toList();
      });
    } else {
      throw Exception('Unable to get Permissions.');
    }
    final String url = '${TBaseURL.baseUrl}/po_approval_new?type=dtlProd&po_no=$poNo&user=$loginId&pageName=$pageName';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data[0]['MsgType'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SubGroups Not Available'),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
          ),
        );
      } else
      {setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
      });}
    } else {
      throw Exception('Unable to get data.');
    }
    if (special_rigths.contains('QtyApproval') && _tableData[0]['VERIFY'] == 'N' ){
      isQtyApproval = true;
    }
    final String url2 = '${TBaseURL.baseUrl}/po_approval_new?type=userDtl&pageName=$pageName&user=$loginId&Amount=${widget.Amount}';
    print(url2);
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
  //  function for submit data
  Future<void> _saveData(String pageName) async {
    var poNo = widget.poNo;
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    int isFinal = 0;
    if (_userData[0]['IsFinal'] == 1){
      isFinal = 1;
    }
    // final String url = '${TBaseURL.baseUrl}po_approval?type=submit&po_no=$poNo&approvalType=prodDtl&user=$loginId';
    final String url = '${TBaseURL.baseUrl}po_approval_new?type=submit&po_no=$poNo&approvalType=prodDtl&user=$loginId&pageName=$pageName&isFinal=$isFinal&device_id=$uuid';
    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);
      if(data[0]['Results'] == 'Done'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data is saved successfully.'),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isQtyApproval)
                    ElevatedButton(
                      onPressed: () { _saveData(widget.pageName.toString()); },
                      child: Text('Po Verify',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green,),
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
                        1 : IntrinsicColumnWidth(),
                        2 : IntrinsicColumnWidth(),
                        3 : IntrinsicColumnWidth(),
                        4 : IntrinsicColumnWidth(),
                        5 : IntrinsicColumnWidth(),
                      },
                      children: [
                        TableRow(
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[200],
                            ),
                            children: const [
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Po No', softWrap: false, overflow: TextOverflow.clip),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Style No', softWrap: false, overflow: TextOverflow.clip),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Order No', softWrap: false, overflow: TextOverflow.clip),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Color', softWrap: false, overflow: TextOverflow.clip),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', softWrap: false, overflow: TextOverflow.clip),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Po Rate', softWrap: false, overflow: TextOverflow.clip),),
                            ]
                        ),
                        ..._tableData.asMap().entries.map((entry){
                          var item = entry.value;
                          return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(8.0), child: Text(item['PO_NO'].toString(), softWrap: false, overflow: TextOverflow.clip, style: TextStyle(fontSize: 12),),),
                                Padding(padding:  const EdgeInsets.all(8.0), child: Text(item['STYLE_NO'].toString(), style: TextStyle(fontSize: 12)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['ORDER_NO'].toString(), style: TextStyle(fontSize: 12)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text((item['COLOR'] ?? '').toString(), softWrap: false, overflow: TextOverflow.clip, style: TextStyle(fontSize: 12)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['PO_QTY'].toString(),textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['PO_RATE'].toString(),textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),),
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