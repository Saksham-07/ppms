import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ppms/PoApproval/po_approvals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../common/utils/constants/baseurl.dart';

class PoApprovalMenus extends StatefulWidget {
  final Map<String, dynamic> fetchedCounters;
  const PoApprovalMenus({super.key, required this.fetchedCounters});

  @override
  State<PoApprovalMenus> createState() => _PoApprovalMenusState();
}

class _PoApprovalMenusState extends State<PoApprovalMenus> {
  List<Map<String, dynamic>> _poApprovalList = [];
  Map<String, List<Map<String, dynamic>>> groupedMenuItems = {
    // "Accessory": [],
    // "Fabric": [],
    // "General": [],
    // "Production": []
  };

  Map<String, int> submenuCounters = {};
  int _expandedTileIndex = -1; // Track the currently expanded tile index

  @override
  void initState() {
    _permData();
    Future.delayed(const Duration(milliseconds: 200), () {
      updateCounters();
    });
    super.initState();
  }

  Future<void> updateCounters() async {
    try {
      // Fetch the counters using the _counter function
      // Map<String, dynamic> fetchedCounters = await counter();

      // Update submenuCounters by mapping the fetched values to integers
      submenuCounters = widget.fetchedCounters.map((key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0));
      print(submenuCounters);

      print('Updated submenuCounters: $submenuCounters');
    } catch (e) {
      print('Error updating counters: $e');
    }
  }

  // Navigate to PO approval page
  void _navigatePoApproval(BuildContext context, String approvalFor, String pageName) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PoApproval(approvalFor: approvalFor, pageName: pageName)));
  }

  // Fetch menu data
  Future<void> _permData() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}menu_rights?user=$loginId&page=PoApprovals';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> poApprovalList = json.decode(response.body);

      setState(() {
        _poApprovalList = List<Map<String, dynamic>>.from(poApprovalList);
          int i = 0;
        for (var item in _poApprovalList) {
          String menuType = item['MenuType'];
          if (!groupedMenuItems.containsKey(menuType)) {
            groupedMenuItems[menuType] = [];
            i++;
          }
          item['index'] = i;
          groupedMenuItems[menuType]?.add(item);
        }
        log('$groupedMenuItems');
      });
    } else {
      throw Exception('Unable to get permissions.');
    }
  }


  static Future<Map<String, dynamic>> counter() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}po_approval_counter_new?user=$loginId';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> poApproval = json.decode(response.body);
      print(poApproval);
      return {
        "AccessoryBulk": poApproval[0]["ACCESSORY_BULK"],
        "AccessoryImport": poApproval[0]["ACCESSORY_IMPORT"],
        "AccessoryPO": poApproval[0]["ACCESSORY_PO"],
        "AccessoryProcess": poApproval[0]["ACCESSORY_PROCESS"],
        "ExtraAccessoryPurchase": poApproval[0]["EXTRA_ACCESSORY_PURCHASE"],
        "FabricBulkProcess": poApproval[0]["FABRIC_BULK_PROCESS"],
        "FabricBulkRaw": poApproval[0]["FABRIC_BULK_RAW"],
        "FabricProcessPO": poApproval[0]["FABRIC_PRO_PO"],
        "FabricRawPurchase": poApproval[0]["FABRIC_RAW_PUR"],
        "GeneralPO": poApproval[0]["GENERAL_PO"],
        "ProductionPo": poApproval[0]["PROD_PO_COUNT"],
        "ExtraPurchasePO": poApproval[0]["EXTRA_PURCHASE_PO"],
      };
    } else {
      throw Exception('Unable to get counters.');
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
          'PO Approvals',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: groupedMenuItems.entries.map((entry) {
              return _buildExpandableSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection(String title, List<Map<String, dynamic>> subMenus) {
    bool isExpanded = _expandedTileIndex == subMenus[0]['index'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: const Border(
          left: BorderSide(color: Color(0xC212F3B0), width: 2),
          bottom: BorderSide(color: Color(0xC212F3B0), width: 2),
          right: BorderSide(color: Color(0xC212F3B0), width: 2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                // Toggle expansion state
                _expandedTileIndex = isExpanded ? -1 : subMenus[0]['index'];
              });
            },
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? subMenus.length * 60.0 : 0,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemCount: subMenus.length,
              itemBuilder: (context, index) {
                String menuCode = subMenus[index]['MenuCode'];
                int counter = submenuCounters[menuCode] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xC212F3B0),
                              spreadRadius: 0.2,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            _navigatePoApproval(
                              context,
                              subMenus[index]['Name'].toString(),
                              subMenus[index]['MenuCode'].toString(),
                            );
                          },
                          title: Text(
                            subMenus[index]['Name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            counter.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
