import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Allocation/allocation_menu.dart';
import 'package:ppms/Audit/audit_menu.dart';
import 'package:ppms/Dashboard/MainDashboard.dart';
import 'package:ppms/PoApproval/menus.dart';
import 'package:ppms/Procedures/RunProcedures.dart';
import 'package:ppms/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ESS/essdashboard.dart';
import '../ESS/leave_approval/models/userprofilemodel.dart';
import '../ExtraFunction/uuid.dart';
import '../Installation/dio.dart';
import '../Resourse/animation_info.dart';
import '../common/utils/constants/baseurl.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class HomePage1Widget extends StatefulWidget {
  const HomePage1Widget({super.key});

  @override
  State<HomePage1Widget> createState() => _HomePage1WidgetState();
}

class _HomePage1WidgetState extends State<HomePage1Widget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  String appVersion = '';
  String appVersionIphone = '';
  String fileName = '';
  bool _isAllocation = false;
  bool _isKpi = false;
  bool _isEss = false;
  bool _isProc = false;
  bool _isPO = false;
  String? name;
  String? unit;
  String? id;
  bool isLoading = false;
  Map<String, dynamic> fetchedCounters = {};
  Uri appStoreUrl = Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');
  String uuid = '',androidId='';


  @override
  void initState() {
    super.initState();
    runFunction();
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        updateCounters();
      } else {
        timer.cancel();
      }
    });

    animationsMap.addAll({
      'gridOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeIn,
            delay: const Duration(milliseconds: 0),
            duration: const Duration(milliseconds: 1000),
            begin: const Offset(2.0, 2.0),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
    });
  }

  Future<void> runFunction ()async{
    await getDetail();
    await _fetchAppVersion();
    await getUid();
    await getEmployeeProfileByEmployeeCode();
    await _initializeRights();
    await updateCounters();
  }

  Future<void> getUid() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      print('android ${androidInfo.id}');
      if (Platform.isAndroid) {
        setState(() {
          uuid = androidInfo.id;
        });
      }
    }
    else{
      String id = await PersistentUUID.getOrCreateUUID();
      setState(() {
        uuid = id;
      });
    }
    if (kDebugMode) {
      print('Persistent UUID: $uuid');
    }
  }

  Future<void> updateCounters() async {
    try {
      // Fetch the counters using the _counter function
      fetchedCounters = await counter();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating counters: $e');
      }
    }
  }

  Future<void> _initializeRights() async {
    _isProc = await checkRights('MobileApplication','MobileProcedure');
    _isPO = await checkRights('MobileApplication','PoApprovals');
    setState(() {}); // Update the UI if necessary
  }

  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // return '${androidInfo.manufacturer} ${androidInfo.brand} ${androidInfo.model} ';
        return '$androidInfo';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return '$iosInfo';
      }
    }
    catch (e) {
      if (kDebugMode) {
        print("Failed to get device ID: $e");
      }
      return null;
    }
    return null;
  }

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      if (Platform.isAndroid) {
        appVersion = packageInfo.version;
      } else if (Platform.isIOS) {
        appVersion = packageInfo.version;
      }
      if (kDebugMode) {
        print('version $appVersion');
      }
      getVersion(appVersion);
    });
  }


  Future<void> getVersion(String version) async {
    try {
      final response = await http.get(Uri.parse('${TBaseURL.baseUrl}version?version=$version'));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        if (data.isNotEmpty) {
          bool isVersionValid = data[0]['IsActive'];
          if (!isVersionValid) {
            await getFile();
            _showUpdateDialog();
          }
        } else {
          if (kDebugMode) {
            print('No data found');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to check version with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getFile() async {
    try {
      final response = await http.get(Uri.parse('${TBaseURL.baseUrl}version_file_path'));
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data[0]['VersionFile']);
        }
        fileName = data[0]['VersionFile'] ?? ''; // Set fileName if available
      } else {
        if (kDebugMode) {
          print('Failed to fetch file with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching file: $e');
      }
    }
  }
  void _showUpdateDialog() {
    String apkUrl = 'http://14.142.248.34:10004/assets/media/$fileName';
    print(apkUrl);
    if (kDebugMode) {
      print(apkUrl);
    }
    if (kDebugMode) {
      print("Apk: $apkUrl");
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text('Please update the app to the latest version.'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    // If on Android, download the APK
                    downloadApk(context, apkUrl);
                  } else if (Platform.isIOS) {
                    // If on iOS, launch the App Store URL
                    if (await canLaunchUrl(appStoreUrl)) {
                      await launchUrl(appStoreUrl);
                    } else {
                      if (kDebugMode) {
                        print('Could not launch $appStoreUrl');
                      }
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getDetail() async{
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    unit = prefs.getString('unit');
    id = prefs.getString('login_id');
  }

  Future<bool> checkRights(String mod, String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=$mod&page=$page';
    if (kDebugMode) {
      print(url);
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

  Future<void> checkForkpi() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=MobileKpi';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isKpi = data.any((item) => item['shortname'] == 'R');

        if (kDebugMode) {
          print(_isKpi);
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> checkForEss() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=MobileEss';
    if (kDebugMode) {
      print(url);
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isEss = data.any((item) => item['shortname'] == 'R');

        if (kDebugMode) {
          print(_isEss);
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> getEmployeeProfileByEmployeeCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetEmployeeProfileByEmployeeCode';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('login_id').toString()
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var newProfiledata = Userprofilemodel.fromJson(data);
        prefs.setString('employeeId', newProfiledata.employeeid.toString());
        prefs.setString('unitId', newProfiledata.unit.toString());
        prefs.setString('unitlocation', newProfiledata.unitlocation.toString());
        prefs.setString('department', newProfiledata.department.toString());
        prefs.setString('designation', newProfiledata.designation.toString());
        prefs.setString('reportingperson', newProfiledata.reportingperson.toString());
        prefs.setString('reportingpersonname', newProfiledata.reportingpersonname.toString());
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      rethrow;
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

  Future<bool> _checkUserRights(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=$page';
    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.any((item) => item['shortname'] == 'R' || item['shortname'] == 'W');
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> _checkLineId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic lineId = prefs.getString('line_id'); // Fetch the line_id as an int
    if (kDebugMode) {
      print(lineId);
    }
    if (lineId != '') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar :AppBar(
          backgroundColor: const Color(0xFF5FE3D3),
          automaticallyImplyLeading: false,
          title: const Text(
            'Paramount Product Management System',
            style: TextStyle(
              fontFamily: 'Readex Pro',
              color: Color(0xFFF8F9FA),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0,
            ),
          ),
          actions: [
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu, // Icon to open the drawer
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    if (kDebugMode) {
                      print('erte');
                    }
                    Scaffold.of(context).openDrawer(); // Open the drawer
                  },
                );
              },
            ),
          ],
          centerTitle: true,
          elevation: 4,
        ),
        drawer: Drawer(
          child: Container(
            color: const Color(0xFF5FE3D3), // Set the background color for the options part
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpeg'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child: null,
                ),
                ListTile(
                  leading: const Icon(Icons.person_2),
                  title: Text('$name'),
                ),ListTile(
                  leading: const Icon(Icons.factory),
                  title: Text('$unit'),
                ),ListTile(
                  leading: const Icon(Icons.password),
                  title: Text('$id'),
                ),ListTile(
                  leading: const Icon(Iconsax.lock),
                  title: Text(uuid),
                ),
                if(Platform.isIOS)
                GestureDetector(
                  onTap:() async {if (await canLaunchUrl(appStoreUrl)) {
                                await launchUrl(appStoreUrl);
                              }},
                  child: const ListTile(
                    leading: Icon(Icons.update),
                    title: Text('Check for Update'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Logout'),
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn', false);
                    String? unique;
                    unique = prefs.getString('uniqueId');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter', uniqueID: unique,)),
                    );
                  },
                ),
                // Add more ListTile widgets for additional menu items
              ],
            ),
          ),
        ),
        key: scaffoldKey,
        body: isLoading ? Center(child: CircularProgressIndicator(),):Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top : 18.0),
            child: Container(
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
                                              blurRadius: 2,
                                              color: Color(0xC212F3B0),
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
                          Align(
                            alignment: const AlignmentDirectional(0, 1),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 12),
                              child: Text(
                                'Version: $appVersion',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: id == '0552482' || id == '0552297',
                    child: Positioned(
                      bottom: 48,
                      right: 32,
                      child: FloatingActionButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isLoggedIn', false);
                          String? unique;
                          unique = prefs.getString('uniqueId');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter', uniqueID: unique,)),
                          );
                        },
                        backgroundColor: Colors.greenAccent,
                        elevation: 10,
                        child: const Icon(Icons.logout),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  List _getVisibleItems() {
    final items = [
        Item(
          imagePath: 'assets/images/kpi_n.png',
          label: 'KPI Dashboard',
          onTap: () async {
            if (await _checkUserRights('MobileKpi')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainDashboardWidget(),
                ),
              );
            } else {
              _showNoRightsDialog('KPI Dashboard');
            }
          },
        ),
        Item(
          imagePath: 'assets/images/ess_new.png',
          label: 'ESS Dashboard',
          onTap: () async {
            if (await _checkUserRights('MobileEss')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EssDashBoard(),
                ),
              );
            } else {
              _showNoRightsDialog('ESS Dashboard');
            }
          },
        ),
      Item(
        imagePath: 'assets/images/file.png',
        label: 'PO Approval',
        onTap: () async {
          if (await checkRights('MobileApplication','PoApprovals')) {
            isLoading = true;
            checkData();
          } else {
            _showNoRightsDialog('PO Approval');
          }
        },
      ),
        Item(
          imagePath: 'assets/images/allocation.png',
          label: 'Line Allocation',
          onTap: () async {
            if (await checkRights('kpi','LineAllocation')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllocationMenu(),
                ),
              );
            } else {
              _showNoRightsDialog('Line Allocation');
            }
          },
        ),

        Item(
          imagePath: 'assets/images/audit.png',
          label: 'Audit',
          onTap: () async {
            if (await _checkLineId()|| await checkRights('MobileApplication','MobileAuditReport')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AuditMenu(),
                ),
              );
            } else {
              _showNoRightsDialog('Audit');
            }
          },
        ),

      if(_isProc)
      Item(
        imagePath: 'assets/images/logo.jpeg',
        label: 'Procedures',
        onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RunProcedures(),
              ),
            );
        },
      ),
    ];
    return items;
  }

  void checkData(){
    if(fetchedCounters.isNotEmpty && fetchedCounters != {}) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoApprovalMenus(fetchedCounters: fetchedCounters,),
        ),
      );
      }
      else {
        // Retry after a short delay if the variable is not true yet
        Future.delayed(const Duration(milliseconds: 200), checkData);
      }
    }
}

class Item {
  final String imagePath;
  final String label; // Added label field
  final VoidCallback onTap;

  Item({required this.imagePath, required this.label, required this.onTap});
}
