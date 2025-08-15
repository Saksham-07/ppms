import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:ppms/MainMenu/home_page1_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ExtraFunction/splash_screen.dart';
import 'ExtraFunction/uuid.dart';
import 'Theme/app_theme.dart';
import 'common/utils/constants/baseurl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start initialization with login check
  final initializationFuture = _initializeApp();

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: MyApp(initializationFuture: initializationFuture),
  ));
}

Future<Map<String, dynamic>> _initializeApp() async {
  // Perform all initialization tasks
  final prefs = await SharedPreferences.getInstance();

  // Generate device ID
  String? uuid;
  if (Platform.isAndroid) {
    uuid = prefs.getString('uniqueId');
    uuid ??= (Random().nextInt(900000) + 100000).toString();
  } else if (Platform.isIOS) {
    uuid = await PersistentUUID.getOrCreateUUID();
  }

  // Check login status
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Get app version
  final packageInfo = await PackageInfo.fromPlatform();
  final appVersion = packageInfo.version;

  // Ensure splash screen shows for minimum 3 seconds
  await Future.wait([
    Future.delayed(const Duration(seconds: 3)),
  ]);

  return {
    'uniqueID': uuid,
    'isLoggedIn': isLoggedIn,
    'appVersion': appVersion,
  };
}

class MyApp extends StatelessWidget {
  final Future<Map<String, dynamic>> initializationFuture;

  const MyApp({super.key, required this.initializationFuture});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return GetMaterialApp(
      title: 'Flutter',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme, // Use light theme from provider
      darkTheme: themeProvider.darkTheme, // Use dark theme from provider
      themeMode: themeProvider.themeMode,
      home: FutureBuilder<Map<String, dynamic>>(
        future: initializationFuture,
        builder: (context, snapshot) {
          // Show splash screen while initializing
          if (snapshot.connectionState != ConnectionState.done) {
            return SplashScreen();
          }

          // Initialization complete - check login status
          final data = snapshot.data!;

          if (data['isLoggedIn'] == true) {
            // User is logged in, go directly to home page
            return const HomePage1Widget();
          } else {
            // User not logged in, show login page
            return MyHomePage(
              title: 'Main Page',
              uniqueID: data['uniqueID'],
              appVersion: data['appVersion'],
            );
          }
        },
      ),
    );
  }
}

// Rest of your existing MyHomePage implementation remains exactly the same
class MyHomePage extends StatefulWidget {
  final String title;
  final String? uniqueID;

  const MyHomePage(
      {super.key,
      required this.title,
      required this.uniqueID,
      required appVersion});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final unFocusNode = FocusNode();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  FocusNode? textFieldFocusNode2;
  String appVersion = '';
  TextEditingController? textController2;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    passwordVisibility = false;
    _checkLoginStatus();
    _fetchAppVersion();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    prefs.setString('uniqueId', widget.uniqueID!);
    final packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.version);
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage1Widget()),
      );
    }
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
    });
  }

  Future<void> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (kDebugMode) {
      print("Stored SharedPreferences data:");
    }
    prefs.getKeys().forEach((key) {
      if (kDebugMode) {
        print("$key: ${prefs.get(key)}");
      }
    });
    // Remove specific keys
    await prefs.remove('login_id');
    await prefs.remove('unit');
    await prefs.remove('unitCode');
    await prefs.remove('name');
    await prefs.remove('line_id');
    await prefs.remove('line_name');
    await prefs.remove('line_ids');
    await prefs.remove('unit_code');
  }

  bool isPresent = false;
  Future<void> fetchData(String user, String password, String id) async {
    try {
      final url =
          '${TBaseURL.baseUrl}new_login?user_id=$user&password=$password&id=$id';
      final response = await http.get(Uri.parse(url));
      if (kDebugMode) {
        print(url);
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        clearLoginData();
        setState(() {});
        if (data != null && data.isNotEmpty) {
          String? loginId;
          String? unit;
          String? unitCode;
          String? name;
          int? lineId;
          String? lineCode;
          String? lineName;
          setState(() {
            loginId = data[0]['Login_id'];
            unit = data[0]['Unit'];
            unitCode = data[0]['UnitCode'] ?? '';
            name = data[0]['Employee_Name'];
            lineId = data[0]['LineId'] ?? 0;
            lineCode = data[0]['LineCode'] ?? '';
            lineName = data[0]['LineName'] ?? '';

            if (kDebugMode) {
              print(data);
              print(unitCode);
            }
          });

          Future.delayed(const Duration(milliseconds: 100), () {
            saveSharedPref(loginId!, unit!, name!, lineCode!, lineName!,
                lineId!, unitCode!);
          });

          setState(() {
            isPresent = true;
          });
        } else {
          setState(() {
            isPresent = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> saveSharedPref(String loginId, String unit, String name,
      String lineCode, String lineName, int lineId, String unitCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_id', loginId);
    await prefs.setString('unit', unit);
    await prefs.setString('unitCode', unitCode);
    await prefs.setString('name', name);
    await prefs.setString('line_id', lineCode);
    await prefs.setString('line_name', lineName);
    await prefs.setInt('line_ids', lineId);
    await prefs.setString('unit_code', unitCode);
  }

  void getB() async {
    try {
      const url =
          'http://14.96.24.164:12008/api/HRISM/GeteLeaveApplicationHistory';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": "9970",
        "yearNo": "2024",
        "monthNo": "6",
        "appStatus": "All",
        "appType": "Leave",
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data received: $data');
        }
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  void _login() async {
    String? userId = textController1?.text.trim();
    String? password = textController2?.text.trim();
    String? id = widget.uniqueID;
    if (kDebugMode) {
      print(id);
    }

    if (kDebugMode) {
      print('Logging In');
    }
    fetchData(userId!, password!, id!);

    final response = await http.get(Uri.parse(
        '${TBaseURL.baseUrl}new_login?user_id=$userId&password=$password&id=$id'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage1Widget()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid user ID or password',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),backgroundColor: Theme.of(context).cardColor,),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to login. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Title
              Column(
                children: [
                  Container(
                    width: 220,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: OverflowBox(
                      maxWidth: 300, // Same as your Lottie size
                      maxHeight: 140,
                      child: const LottieLoading(
                        animationPath: 'assets/animation/logo_grey.json',
                        size: 150,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'PPMS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Paramount Product Management System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Device ID
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                  boxShadow: [
                    BoxShadow(color: Colors.grey[500]!,blurRadius: 1,offset: const Offset(0,2))
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Device ID: ${widget.uniqueID}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Login Form
              Card(
                elevation: 4,
                shadowColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Username Field
                      TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: textController1,
                        decoration: InputDecoration(
                          labelText: 'User ID',
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          prefixIcon: Icon(Icons.person_outline,
                              color: Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[500]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[500]!),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.9)),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        controller: textController2,
                        obscureText: !passwordVisibility,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(() =>
                                passwordVisibility = !passwordVisibility),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[500]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[500]!),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Version Info
              Text(
                'Version: $appVersion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
