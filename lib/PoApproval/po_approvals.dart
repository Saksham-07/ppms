
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/ESS/essdashboard.dart';
import 'package:ppms/PoApproval/po_approvals_dtl.dart';
import 'package:ppms/PoApproval/production_po_approvals_dtl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/utils/constants/baseurl.dart';

class PoApproval extends StatefulWidget {
  final String? approvalFor;
  final String? pageName;

  const PoApproval({super.key, required this.approvalFor, required this.pageName});

  @override
  State<PoApproval> createState() => _PoApprovalState();
}

class _PoApprovalState extends State<PoApproval> {
  String? reportDataType;
  String? subReportDataType;
  String? poNo,loginId,id;
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _filteredTableData = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Add FocusNode

  @override
  void initState() {
    super.initState();
    _gettingMainData();
    _searchController.addListener(_filterTableData);

    // Set focus on the search field when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _filterTableData() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        _filteredTableData =
            _tableData; // If search query is empty, show all data
      } else {
        _filteredTableData = _tableData.where((item) {
          return item['PO_NO'].toString().toLowerCase().contains(searchQuery) ||
              item['VENDOR_NAME'].toString().toLowerCase().contains(
                  searchQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  // Function for getting data
  Future<void> _gettingMainData () async {
    _tableData.clear();
    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> specialRigths = [];

    var reportDataType = 'main';
    var pageName = widget.pageName.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginIds = prefs.getString('login_id');
    final String url1 = '${TBaseURL.baseUrl}/special?user=${id ?? loginIds}&module=MobileApplication&page=$pageName';
    if (kDebugMode) {
      print(url1);
    }
    final response1 = await http.get(Uri.parse(url1));
    if (response1.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response1.body);
      setState(() {
        specialRigths = List<Map<String, dynamic>>.from(data);
        loginId = prefs.getString('login_id');
      });
    }else{
      throw Exception('Failed to get permissions.');
    }
    List<String> special_rigths = specialRigths.map((item) => item['name'] as String).toList();
    if (special_rigths.contains('QtyApproval') && special_rigths.contains('PriceApproval')) {
      subReportDataType = 'Both';
    }else if (special_rigths.contains('QtyApproval')){
      subReportDataType = 'Qty';
    }else if (special_rigths.contains('PriceApproval')){
      subReportDataType = 'Price';
    }
    int isAll = 0;
    if (special_rigths.contains('AllowAllPO')){
      isAll = 1;
    }
    final String url = '${TBaseURL.baseUrl}po_approval_new?type=$reportDataType&subReportType=$subReportDataType&pageName=${widget.pageName.toString()}&user=${id ?? loginIds}&isAll=$isAll';
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Data Found.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (data[0]['MsgType'] == 1) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SubGroups Not Available'),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
          ),
        );
      } else {
        setState(() {
          _tableData = List<Map<String, dynamic>>.from(data);
          _filteredTableData = _tableData; // Initialize _filteredTableData here
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      throw Exception('Failed to load data.');
    }
  }

  // function for navigate to detail
  Future<void> _navigateToDtl (BuildContext context, String poNo, String approvalFor, String amount) async {
    if (widget.pageName == 'ProductionPo'){
      final result = await Navigator.push(
        context,
          MaterialPageRoute(builder: (context) =>
              ProductionPoApprovalsDtl(poNo : poNo,
                  approvalFor: approvalFor,
                  pageName: widget.pageName.toString(),
                  Amount : amount.toString()
              )
          )
      );
      if (result == true) {
        _gettingMainData ();
      }
    }else{
      final result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => PoApprovalDtl(poNo : poNo, approvalFor: approvalFor, pageName: widget.pageName.toString(), Amount : amount.toString()))
      );
      if (result == true) {
        _gettingMainData ();
      }
    }

  }

  void _showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter"),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Type Here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without action
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  id = searchController.text.trim();
                });
                Navigator.pop(context); // Close dialog
                _gettingMainData(); // Run function with entered text
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
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
        actions: [
          if(loginId == '0552482' || loginId == '0552297')
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: GestureDetector(
                  onTap: () {
                    _showSearchDialog(context);
                  },
                  child: const Icon(Icons.search,color: Color(0xFF5FE3D3),size: 16,)
              ),
            ),
        ],
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
      ),
      body: InteractiveViewer(
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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode, // Attach FocusNode
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5.0,
                  ),
                )
                    : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                              color: Colors.lightBlue[200]),
                          children: [
                            const Padding(
                                padding: EdgeInsets.all(6.0), child: Text('')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Po No')),
                            Visibility(
                              visible: widget.pageName == 'ProductionPo',
                              child: const Padding(padding: EdgeInsets.all(6.0),
                                  child: Text('Process')),
                            ),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Date')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Qty')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Po Amt')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Supplier')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('First Approver')),
                          ],
                        ),
                        ..._filteredTableData
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key + 1;
                          var item = entry.value;
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(index.toString(),
                                      style: const TextStyle(fontSize: 12))),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    item['PO_NO'].toString(),
                                    style: const TextStyle(fontSize: 12,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                                onTap: () =>
                                    _navigateToDtl(
                                        context, item['PO_NO'].toString(),
                                        pageType.toString(),
                                        item['PO_AMOUNT'].toString()),
                              ),
                              Visibility(
                                visible: widget.pageName == 'ProductionPo',
                                child: Padding(padding: const EdgeInsets.all(6.0),
                                    child: Text(item['PROCESS'].toString(),
                                        style: const TextStyle(fontSize: 12))),
                              ),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['PO_DATE'].toString(),
                                      style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['PO_QTY'].toString(),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['PO_AMOUNT'].toString(),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['VENDOR_NAME'].toString(),
                                      style: const TextStyle(fontSize: 12))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                      (item['APPROVED_BY'] ?? '').toString(),
                                      style: const TextStyle(fontSize: 12))),
                            ],
                          );
                        })
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
