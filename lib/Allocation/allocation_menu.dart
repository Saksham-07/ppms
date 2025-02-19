import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/Allocation/allocation.dart';
import 'package:ppms/Allocation/manpower_verify.dart';
import 'package:ppms/Allocation/verification_report_all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'ot_vertification.dart';

class AllocationMenu extends StatefulWidget {
  const AllocationMenu({super.key});

  @override
  State<AllocationMenu> createState() => _AllocationMenu();
}
class _AllocationMenu extends State<AllocationMenu>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String appVersion = '';
  bool isLineIdPresent = false; // Track if line_id exists in SharedPreferences
  bool _isAllocation = false; // Track if line_id exists in SharedPreferences
  bool _isVerify = false; // Track if line_id exists in SharedPreferences

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkForAllocate(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = 'http://14.142.248.34:10008/base?user=$loginId&module=kpi&page=$page';
    if (kDebugMode) {
      print('http://14.142.248.34:10008/base?user=$loginId&module=kpi&page=LineAllocation');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isAllocation = data.any((item) => item['shortname'] == 'W' || item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isAllocation);
        }
      });
      if(_isAllocation){
        return true;
      }
      else{
        return false;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> verifyManpower(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = 'http://14.142.248.34:10008/base?user=$loginId&module=MobileApplication&page=$page';
    if (kDebugMode) {
      print('http://14.142.248.34:10008/base?user=$loginId&module=MobileApplication&page=ManpowerVerification');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isVerify = data.any((item) => item['shortname'] == 'W' || item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isVerify);
        }
      });
      if(_isVerify){
        return true;
      }
      else{
        return false;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showNoRightsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: Text('You do not have the rights for $title.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: Stack(
            children: [
              NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
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
                    backgroundColor: const Color(0xFF5FE3D3),
                    automaticallyImplyLeading: false,
                    title: const Text(
                      'Line Allocation',
                      style: TextStyle(
                        fontFamily: 'Readex Pro',
                        color: Color(0xFFF8F9FA),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                      ),
                    ),
                    centerTitle: true,
                    elevation: 4,
                  )
                ],
                body: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 2),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 1.30,
                          ),
                          itemCount: _getVisibleItems().length,
                          itemBuilder: (context, index) {
                            final item = _getVisibleItems()[index];
                            return GestureDetector(
                              onTap: item.onTap,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    width: 80,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 8,
                                          color: Color(0x33000000),
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: Image.asset(
                                              item.imagePath,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xC208C2C2),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Item> _getVisibleItems() {
    final items = <Item>[];
      // Only add the 'End Line Audit' if line_id exists
      items.add(
        Item(
          imagePath: 'assets/images/allocation.png',
          label: 'Allocation',
          onTap: () async {
            if (await checkForAllocate('LineAllocation')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Allocation(),
                ),
              );
            } else {
              _showNoRightsDialog('Line Allocation');
            }
          },
        ),
      );
    items.add(
      Item(
        imagePath: 'assets/images/check-mark.png',
        label: 'Manpower Verification',
        onTap: () async {
          if (await verifyManpower('ManpowerVerification')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManpowerVerify(),
              ),
            );
          } else {
            _showNoRightsDialog('Manpower Verification');
          }
        },
      ),


    );
    items.add(
      Item(
        imagePath: 'assets/images/clipboard.png',
        label: 'Allocation Report',
        onTap: () async {
          if (await verifyManpower('ManpowerVerification')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const VerificationReportAll(),
              ),
            );
          } else {
            _showNoRightsDialog('Manpower Report');
          }
        },
      ),
    );
    items.add(
      Item(
        imagePath: 'assets/images/overtime.png',
        label: 'OT Verification',
        onTap: () async {
          if (await verifyManpower('OTApproval')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LinewiseOTVerification(),
              ),
            );
          } else {
            _showNoRightsDialog('OT Verification');
          }
        },
      ),
    );
    return items;
  }
}

class Item {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  Item({required this.imagePath, required this.label, required this.onTap});
}