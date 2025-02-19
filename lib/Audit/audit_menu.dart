import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/Audit/El_Audit/end_line_new.dart';
import 'package:ppms/Audit/Sewing_Audit/sewing_audit_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'El_Audit/AuditHourly/el_hourly_report.dart';
import 'El_Audit/el_audit_report.dart';
import 'El_Audit/end_line.dart';
import 'El_Audit/end_line_test.dart';

import 'package:http/http.dart' as http;

import 'Finishing_audit/finish_audit_selection.dart';

class AuditMenu extends StatefulWidget {
  const AuditMenu({super.key});

  @override
  State<AuditMenu> createState() => _AuditMenuState();
}

class _AuditMenuState extends State<AuditMenu>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String appVersion = '';
  String? id;
  bool isLineIdPresent = false;
  bool _isAllocation = false;

  @override
  void initState() {
    super.initState();
    _checkLineId(); // Check for line_id when the widget is initialized
  }

  Future<bool> checkRights(String mod, String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = 'http://14.142.248.34:10008/base?user=$loginId&module=$mod&page=$page';
    if (kDebugMode) {
      print(url);
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isAllocation = data.any((item) => item['shortname'] == 'R');
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

  void _showNoRightsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You do not have the rights to access this feature.'),
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

  // Function to check if line_id exists in SharedPreferences
  Future<void> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lineId = prefs.getString('line_id');
    setState(() {

    id = prefs.getString('login_id');
    });
    // Fetch the line_id as an int
    if (lineId != '') {
      setState(() {
        isLineIdPresent = true; // Set to true if line_id exists
      });
    }
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
                      'Audit',
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

    if (isLineIdPresent) {
      // Only add the 'End Line Audit' if line_id exists
      items.add(
        Item(
          imagePath: 'assets/images/clean.png',
          label: 'End Line Audit',
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditPage(),
              ),
            );
          },
        ),
      );
    }

    if (id == '0552482' || id == '0552445' || id == '0552297' ||
        id == '0551723') {
      items.add(
        Item(
          imagePath: 'assets/images/clean.png',
          label: 'End Line Audit Test',
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditTestPage(),
              ),
            );
          },
        ),
      );
    }

    items.add(
      Item(
        imagePath: 'assets/images/sale-report.png',
        label: 'EL Audit Report',
        onTap: () async {
          if (await checkRights('MobileApplication', 'MobileAuditReport')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AuditELReport(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

    items.add(
      Item(
        imagePath: 'assets/images/sale-report.png',
        label: 'EL Hourly Report',
        onTap: () async {
          if (await checkRights('MobileApplication', 'MobileAuditReport')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HourlyReportPage(),
              ),
            );
          }
          else {
            _showNoRightsDialog();
          }
        },
      ),
    );

    if(id == '0552482' || id == '0552445' || id == '0552297' || id == '0551723') {
      items.add(
        Item(
          imagePath: 'assets/images/fashion.png',
          label: 'Sewing Audit',
          onTap: () async {
            if (await checkRights('MobileApplication', 'MobileSewingAudit')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SewingAuditSelection(),
                ),
              );
            }
            else {
              _showNoRightsDialog();
            }
          },
        ),
      );

      items.add(
        Item(
          imagePath: 'assets/images/fashion.png',
          label: 'Finish Audit',
          onTap: () async {
            if (await checkRights('MobileApplication', 'MobileFinishingAudit')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinishAuditSelection(),
                ),
              );
            }
            else {
              _showNoRightsDialog();
            }
          },
        ),
      );
    }

    return items;
  }
}
class Item {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  Item({required this.imagePath, required this.label, required this.onTap});
}
