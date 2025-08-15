import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Allocation/allocation_menu.dart';
import 'package:ppms/Audit/audit_menu.dart';
import 'package:ppms/Dashboard/MainDashboard.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:ppms/PoApproval/menus.dart';
import 'package:ppms/Procedures/RunProcedures.dart';
import 'package:ppms/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ESS/essdashboard.dart';
import '../ESS/leave_approval/models/userprofilemodel.dart';
import '../ExtraFunction/uuid.dart';
import '../Installation/dio.dart';
import '../Resourse/animation_info.dart';
import '../Theme/app_theme.dart';
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
  String? name;
  String? unit;
  String? id;
  bool isLoading = false;
  bool _showFullTitle = true, _showCursor = true;
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  // In your state class
  late AnimationController _buttonController;
  late AnimationController _drawerController;
  late AnimationController _rotationController;
  final _rotationDuration = const Duration(milliseconds: 1000);
  final double _drawerWidth = 280; // Customize drawer width
  bool _isDrawerOpen = false;
  int _currentMaxLength = 0;
  bool isZooming = false;

  Map<String, dynamic> fetchedCounters = {};
  Uri appStoreUrl =
      Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');
  String uuid = '', androidId = '';

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
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    drawerAnimation();
  }

  @override
  void dispose() {
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _buttonController.dispose();
    _drawerController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> runFunction() async {
    await getDetail();
    await _fetchAppVersion();
    await getUid();
    await _initializeRights();
    await updateCounters();
  }

  void drawerAnimation() {
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slower drawer opening
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: _rotationDuration,
      vsync: this,
    );
  }

  Future<void> _handleMenuPress() async {
    if (_buttonController.isAnimating || _drawerController.isAnimating) return;

    if (_isDrawerOpen) {
      await _drawerController.reverse();
      setState(() => _isDrawerOpen = false);
      return;
    }

    _rotationController.reset();

    if (!_isDrawerOpen) {
      _rotationController.forward(); // Rotate CW on open
    } else {
      _rotationController.reverse(); // Rotate CCW on close
    }

    // Animate button to left
    await _buttonController.forward();

    // Open drawer
    setState(() => _isDrawerOpen = true);
    _drawerController.forward();

    // Animate button back
    _buttonController.reverse();
  }

  void _playZoomAnimationAndNavigate(
      String imagePath, Widget nextPage, String text) async {
    setState(() {
      isZooming = true;
    });
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.white,
          child: _DelayedZoom(
            imagePath: imagePath,
            text: text,
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 500));

    overlayEntry.remove();

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: nextPage,
            ),
          );
        },
      ),
    );

    setState(() => isZooming = false);
  }

  Future<void> getUid() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (kDebugMode) {
        print('android ${androidInfo.id}');
      }
      if (Platform.isAndroid) {
        setState(() {
          uuid = androidInfo.id;
        });
      }
    } else {
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

  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'PPMS';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(
              0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  void _toggleCursor(Timer timer) {
    if (mounted) {
      // Show cursor during both forward and reverse typing
      final shouldShowCursor =
          _typingController.value > 0 && _typingController.value < 1.0;

      if (shouldShowCursor || _showCursor != shouldShowCursor) {
        setState(() => _showCursor = shouldShowCursor);
      }
    }
  }

  void _setupAnimations() {
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _typingAnimation = IntTween(begin: 0, end: _currentMaxLength).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );

    _typingAnimation.addListener(_updateText);
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  Future<void> _startTypingSequence() async {
    // Type out full title
    _currentMaxLength = 'Paramount Product Management System'.length;
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);

    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    await _typingController.reverse(from: 1.0);

    // Switch to short title
    if (mounted) {
      setState(() {
        _showFullTitle = false;
        _currentMaxLength = 'PPMS'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  Future<void> _initializeRights() async {
    _isProc = await checkRights('MobileApplication', 'MobileProcedure');
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
    } catch (e) {
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
        getVersion(appVersion);
      } else if (Platform.isIOS) {
        appVersion = packageInfo.version;
        getIosVersion(appVersion);
      }
      if (kDebugMode) {
        print('version $appVersion');
      }
    });
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http
          .get(Uri.parse('${TBaseURL.baseUrl}version?version=$version'));
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
          print(
              'Failed to check version with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getIosVersion(String version) async {
    try {
      final response = await http
          .get(Uri.parse('${TBaseURL.baseUrl}ios_version?version=$version'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data fetched: $data');
        }

        if (data.isNotEmpty) {
          // Check if the current version exists in the list
          bool versionExists = data.any((item) => item['Version'] == version);

          if (!versionExists) {
            // If the version is not in the list, show the update dialog
            await getFile();
            _showUpdateDialog();
          } else {
            if (kDebugMode) {
              print('Current version is up-to-date.');
            }
          }
        } else {
          if (kDebugMode) {
            print('No version data found.');
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Failed to check version with status code: ${response.statusCode}');
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
      final response =
          await http.get(Uri.parse('${TBaseURL.baseUrl}version_file_path'));
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
          print(
              'Failed to fetch file with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching file: $e');
      }
    }
  }

  void _showUpdateDialog() {
    String apkUrl = 'http://14.96.24.164:10004/assets/media/$fileName';
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
            backgroundColor: Theme.of(context).cardColor,
            title: Text('Update Required',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            content: Text('Please update the app to the latest version.',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
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
                child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getDetail() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    unit = prefs.getString('unit');
    id = prefs.getString('login_id');
  }

  Future<bool> checkRights(String mod, String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}base?user=$loginId&module=$mod&page=$page';
    if (kDebugMode) {
      print(url);
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _isAllocation = data.any(
            (item) => item['shortname'] == 'W' || item['shortname'] == 'R');
        if (kDebugMode) {
          print(_isAllocation);
        }
      });
      if (_isAllocation) {
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> checkForkpi() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=MobileKpi';

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
    final String url =
        '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=MobileEss';
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

  void _showNoRightsDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Access Denied',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        content: Text('You do not have the rights for $title.',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, dynamic>> counter() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url1 =
        '${TBaseURL.baseUrl}po_approval_counter_new?user=$loginId';
    final response1 = await http.get(Uri.parse(url1));

    // Second API call
    final String url2 =
        '${TBaseURL.baseUrl}vg_po_approval?user_id=$loginId&data_type=Count';
    final response2 = await http.get(Uri.parse(url2));

    if (kDebugMode) {
      print(url2);
      print(url1);
    }

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final List<dynamic> poApproval = json.decode(response1.body);
      final List<dynamic> poSummary = json.decode(response2.body);
      if (kDebugMode) {
        print(poApproval);
        print(poSummary);
      }
      return {
        "AccessoryBulk":
            poApproval[0]["ACCESSORY_BULK"] + poSummary[0]["ACCESSORY_BULK"],
        "AccessoryImport": poApproval[0]["ACCESSORY_IMPORT"] +
            poSummary[0]["ACCESSORY_IMPORT"],
        "AccessoryPO":
            poApproval[0]["ACCESSORY_PO"] + poSummary[0]["ACCESSORY_PO"],
        "AccessoryProcess": poApproval[0]["ACCESSORY_PROCESS"] +
            poSummary[0]["ACCESSORY_PROCESS"],
        "ExtraAccessoryPurchase": poApproval[0]["EXTRA_ACCESSORY_PURCHASE"] +
            poSummary[0]["EXTRA_ACCESSORY_PURCHASE"],
        "FabricBulkProcess": poApproval[0]["FABRIC_BULK_PROCESS"] +
            poSummary[0]["FABRIC_BULK_PROCESS"],
        "FabricBulkRaw":
            poApproval[0]["FABRIC_BULK_RAW"] + poSummary[0]["FABRIC_BULK_RAW"],
        "FabricProcessPO":
            poApproval[0]["FABRIC_PRO_PO"] + poSummary[0]["FABRIC_PRO_PO"],
        "FabricRawPurchase":
            poApproval[0]["FABRIC_RAW_PUR"] + poSummary[0]["FABRIC_RAW_PUR"],
        "GeneralPO": poApproval[0]["GENERAL_PO"] + poSummary[0]["GENERAL_PO"],
        "ProductionPo":
            poApproval[0]["PROD_PO_COUNT"] + poSummary[0]["PROD_PO_COUNT"],
        "ExtraPurchasePO": poApproval[0]["EXTRA_PURCHASE_PO"] +
            poSummary[0]["EXTRA_PURCHASE_PO"],
      };
    } else {
      throw Exception('Unable to get counters.');
    }
  }

  Future<bool> _checkUserRights(String page) async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url =
        '${TBaseURL.baseUrl}base?user=$loginId&module=MobileApplication&page=$page';
    if (kDebugMode) {
      print(url);
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .any((item) => item['shortname'] == 'R' || item['shortname'] == 'W');
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
    return isZooming
        ? Center(
            child: Center(
                child: Container(
              color: Theme.of(context).primaryColor,
              height: double.infinity,
              width: double.infinity,
            )),
          )
        : GestureDetector(
            onTap: () => {FocusScope.of(context).unfocus()},
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  appBar: AppBar(
                    bottom: const PreferredSize(
                        preferredSize: Size(7, 7),
                        child: Divider(
                          color: Colors.white,
                          indent: 16,
                          endIndent: 16,
                        )),
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor,
                    automaticallyImplyLeading: false,
                    surfaceTintColor: Colors.transparent,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 100),
                          child: Text(
                            _displayText,
                            key: ValueKey(_showFullTitle),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _showFullTitle ? 14 : 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: _showFullTitle ? 0.0 : 1.5,
                            ),
                          ),
                        ),
                        if (_showCursor &&
                            _typingController.value < 1.0 &&
                            _typingController.value > 0)
                          Container(
                            width: 6,
                            height: 20,
                            margin: const EdgeInsets.only(left: 2),
                            color: Colors.white60,
                          ),
                      ],
                    ),
                    actions: [
                      Builder(
                        builder: (context) {
                          return AnimatedBuilder(
                            animation: _buttonController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  -MediaQuery.of(context).size.width *
                                      0.75 *
                                      _buttonController.value,
                                  0,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: AnimatedBuilder(
                                      animation: _rotationController,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _rotationController.value *
                                              2 *
                                              pi, // 360 degrees (2π radians)
                                          child: const Icon(
                                            Icons.menu_rounded,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                        );
                                      },
                                    ),
                                    onPressed: _handleMenuPress,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    centerTitle: true,
                    elevation: 4,
                  ),
                  drawer: const SizedBox.shrink(),
                  key: scaffoldKey,
                  body: isLoading
                      ? const Center(
                          child: LottieLoading(
                          animationPath: 'assets/animation/po.json',
                          size: 300,
                        ))
                      : Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: Container(
                            color: Theme.of(context).primaryColor,
                            child: Stack(
                              children: [
                                NestedScrollView(
                                  floatHeaderSlivers: true,
                                  headerSliverBuilder: (context, _) => [],
                                  body: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16, 2, 16, 2),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: GridView.builder(
                                            padding: const EdgeInsets.all(16),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 12,
                                            ),
                                            itemCount:
                                                _getVisibleItems().length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  _getVisibleItems()[index];
                                              return GestureDetector(
                                                onTap: item.onTap,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiary,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                          item.imagePath,
                                                          height: 60),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(item.label,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary)),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        width: 40,
                                                        height: 3,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary, // soft orange accent bar
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(0, 1),
                                          child: Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0, 16, 0, 12),
                                            child: Text(
                                              'Version: $appVersion',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Readex Pro',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
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
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setBool('isLoggedIn', false);
                                        String? unique;
                                        unique = prefs.getString('uniqueId');
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyHomePage(
                                                    title: 'Flutter',
                                                    uniqueID: unique,
                                                    appVersion: appVersion,
                                                  )),
                                        );
                                      },
                                      backgroundColor: Colors.black45,
                                      elevation: 10,
                                      child: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                ),
                if (_isDrawerOpen)
                  AnimatedBuilder(
                    animation: _drawerController,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: _handleMenuPress, // Close drawer on tap
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(
                            0.4 *
                                _drawerController
                                    .value, // Adjust opacity (0.3 = 30% dark)
                          ),
                        ),
                      );
                    },
                  ),
                AnimatedBuilder(
                  animation: _drawerController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                          -_drawerWidth +
                              (_drawerWidth * _drawerController.value),
                          0),
                      child: Material(
                        elevation: 40, // Optional shadow
                        child: Container(
                          width: _drawerWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              const DrawerHeader(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/new3.webp'),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                child: null,
                              ),
                              ListTile(
                                trailing: Consumer<ThemeProvider>(
                                  builder: (context, themeProvider, child) {
                                    return CupertinoSwitch(
                                      activeTrackColor: Colors.indigo.shade400,
                                      thumbIcon:
                                          WidgetStateProperty.resolveWith<
                                              Icon?>((Set<WidgetState> states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return const Icon(
                                            Icons.mode_night_rounded,
                                            color: Colors.white,
                                          );
                                        }
                                        return const Icon(Icons
                                            .sunny); // All other states will use the default thumbIcon.
                                      }),
                                      thumbColor: themeProvider.themeMode !=
                                              ThemeMode.dark
                                          ? Colors.white
                                          : Colors.black,
                                      value: themeProvider.themeMode ==
                                          ThemeMode.dark,
                                      onChanged: (value) {
                                        themeProvider.toggleTheme(value);
                                      },
                                    );
                                  },
                                ),
                                title: Consumer<ThemeProvider>(
                                    builder: (context, themeProvider, child) {
                                  return Text(
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? 'Dark Mode'
                                        : 'Light Mode',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  );
                                }),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.person_2,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                title: Text(
                                  '$name',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              ListTile(
                                leading: Icon(Icons.factory,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                title: Text('$unit',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              ListTile(
                                leading: Icon(Icons.password,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                title: Text('$id',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              ListTile(
                                leading: Icon(Iconsax.lock,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                title: Text(uuid,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              if (Platform.isIOS)
                                GestureDetector(
                                  onTap: () async {
                                    if (await canLaunchUrl(appStoreUrl)) {
                                      await launchUrl(appStoreUrl);
                                    }
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.update,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    title: Text('Check for Update',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary)),
                                  ),
                                ),
                              if (Platform.isIOS)
                                Divider(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  indent: 12,
                                  endIndent: 12,
                                ),
                              ListTile(
                                leading: Icon(Icons.logout_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                                title: Text('Logout',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('isLoggedIn', false);
                                  String? unique;
                                  unique = prefs.getString('uniqueId');
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyHomePage(
                                              title: 'Flutter',
                                              uniqueID: unique,
                                              appVersion: appVersion,
                                            )),
                                  );
                                },
                              ),
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 12,
                                endIndent: 12,
                              ),
                              // Add more ListTile widgets for additional menu items
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
  }

  void checkData() {
    if (fetchedCounters.isNotEmpty && fetchedCounters != {}) {
      setState(() {
        isLoading = false;
      });

      _playZoomAnimationAndNavigate(
          'assets/images/po1.png',
          PoApprovalMenus(
            fetchedCounters: fetchedCounters,
          ),
          'Welcome to PO Approval');
    } else {
      // Retry after a short delay if the variable is not true yet
      Future.delayed(const Duration(milliseconds: 200), checkData);
    }
  }

  List<Item> _getVisibleItems() {
    final items = [
      Item(
        height: 80,
        width: 80,
        imagePath: 'assets/images/kpi1.png',
        label: 'KPI Dashboard',
        onTap: () async {
          if (await _checkUserRights('MobileKpi')) {
            _playZoomAnimationAndNavigate('assets/images/kpi1.png',
                const MainDashboardWidget(), 'Welcome to KPI Dashboard');
          } else {
            _showNoRightsDialog('KPI Dashboard');
          }
        },
      ),
      Item(
        height: 80,
        width: 80,
        imagePath: 'assets/images/ess1.png',
        label: 'ESS Dashboard',
        onTap: () async {
          if (await _checkUserRights('MobileEss')) {
            _playZoomAnimationAndNavigate('assets/images/ess1.png',
                const EssDashBoard(), 'Welcome to ESS');
          } else {
            _showNoRightsDialog('ESS Dashboard');
          }
        },
      ),
      Item(
        height: 80,
        width: 80,
        imagePath: 'assets/images/po1.png',
        label: 'PO Approval',
        onTap: () async {
          if (await checkRights('MobileApplication', 'PoApprovals')) {
            setState(() => isLoading = true);
            checkData();
          } else {
            _showNoRightsDialog('PO Approval');
          }
        },
      ),
      Item(
        height: 80,
        width: 120,
        imagePath: 'assets/images/lineAllo1.png',
        label: 'Line Allocation',
        onTap: () async {
          if (await checkRights('kpi', 'LineAllocation')) {
            _playZoomAnimationAndNavigate('assets/images/lineAllo1.png',
                const AllocationMenu(), 'Welcome to Line Allocation');
          } else {
            _showNoRightsDialog('Line Allocation');
          }
        },
      ),
      Item(
        height: 80,
        width: 100,
        imagePath: 'assets/images/test1.png',
        label: 'Audit',
        onTap: () async {
          if (await _checkLineId() ||
              await checkRights('MobileApplication', 'MobileAuditReport')) {
            _playZoomAnimationAndNavigate('assets/images/test1.png',
                const AuditMenu(), 'Welcome to Audit');
          } else {
            _showNoRightsDialog('Audit');
          }
        },
      ),
      if (_isProc)
        Item(
          height: 80,
          width: 80,
          imagePath: 'assets/images/processing.png',
          label: 'Procedures',
          onTap: () async {
            _playZoomAnimationAndNavigate('assets/images/logo.jpeg',
                const RunProcedures(), 'Welcome to Procedure');
          },
        ),
    ];
    return items;
  }
}

class Item {
  final String imagePath;
  final double width;
  final double height;
  final String label; // Added label field
  final VoidCallback onTap;

  Item(
      {required this.width,
      required this.height,
      required this.imagePath,
      required this.label,
      required this.onTap});
}

class _DelayedZoom extends StatefulWidget {
  final String imagePath;
  final String text;

  const _DelayedZoom({required this.imagePath, required this.text});

  @override
  State<_DelayedZoom> createState() => _DelayedZoomState();
}

class _DelayedZoomState extends State<_DelayedZoom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    // Delay the start of the animation by one frame (to let white background paint)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Image.asset(
                widget.imagePath,
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Text(
              widget.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: 'Tahoma',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            )
          ],
        ),
      ),
    );
  }
}
