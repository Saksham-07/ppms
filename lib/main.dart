import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ppms/MainMenu/home_page1_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'ExtraFunction/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get current date
  DateFormat('yyyy-MM-dd').format(DateTime.now());
  prefs.remove('uniqueID');
  // Get stored last login date
  prefs.getString('lastLoginDate');

  String uuid = await PersistentUUID.getOrCreateUUID();
  print('Persistent UUID: $uuid');


  runApp(MyApp( uniqueID: uuid));
}

class MyApp extends StatelessWidget {
  final String? uniqueID;

  const MyApp({super.key, required this.uniqueID});


  @override
  Widget build(BuildContext context) {
    print(uniqueID);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return GetMaterialApp(
      title: 'Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
        fontFamily: 'tahoma',
      ),
      home: MyHomePage(title: 'Main Page', uniqueID: uniqueID),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String? uniqueID;

  const MyHomePage({super.key, required this.title, required this.uniqueID});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final unfocusNode = FocusNode();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  FocusNode? textFieldFocusNode2;
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
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    prefs.setString('uniqueID', widget.uniqueID!);
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage1Widget()),
      );
    }
  }

  Future<void> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("Stored SharedPreferences data:");
    prefs.getKeys().forEach((key) {
      print("$key: ${prefs.get(key)}");
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
      final url = 'http://14.142.248.34:10008/new_login?user_id=$user&password=$password&id=$id';
      final response = await http.get(Uri.parse(url));
      if (kDebugMode) {
        print(url);
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        clearLoginData();
        setState(() {

        });
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
              print(data);print(unitCode);
            }
          });

          Future.delayed(const Duration(milliseconds: 100),(){
            saveSharedPref(loginId!,unit!,name!,lineCode!,lineName!,lineId!,unitCode!);
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

  Future<void> saveSharedPref(String loginId,String unit,String name,String lineCode,String lineName,int lineId,String unitCode) async {
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
      const url = 'http://14.142.248.34:12008/api/HRISM/GeteLeaveApplicationHistory';

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
    print(id);

    if (kDebugMode) {
      print('Logging In');
    }
    fetchData(userId!, password!, id!);

    final response = await http.get(Uri.parse('http://14.142.248.34:10008/new_login?user_id=$userId&password=$password&id=$id'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Future.delayed(const Duration(milliseconds: 200),()
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage1Widget()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID or password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xB2B9F6F3), Color(0xFFFFFFFF)],
            begin: Alignment(0.1, 1.0),
            end: Alignment(-0.1, 0.0),
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome To PPMS',
                    style: TextStyle(
                      fontSize: 28,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
                    child: Text(
                      'ID: ${widget.uniqueID}',
                      style: const TextStyle(letterSpacing: 0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(38, 10, 38, 10),
                    child: TextFormField(
                      controller: textController1,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF101518),
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF06D5CD),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF199A7B),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                        prefixIcon: const Icon(
                          Icons.person,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF101518),
                        fontSize: 18,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(38, 10, 38, 10),
                    child: TextFormField(
                      controller: textController2,
                      autofocus: false,
                      obscureText: !passwordVisibility,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF101518),
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF06D5CD),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF199A7B),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: InkWell(
                          onTap: () => setState(
                                () => passwordVisibility = !passwordVisibility,
                          ),
                          focusNode: FocusNode(skipTraversal: true),
                          child: Icon(
                            passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF757575),
                            size: 22,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF101518),
                        fontSize: 18,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 10),
                child: ElevatedButton(
                  onPressed: _login,
                  // onLongPress: getB,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFF06D5CD);
                        }
                        return const Color(0xFF06D5CD);
                      },
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
                    ),
                    textStyle: WidgetStateProperty.all<TextStyle>(
                      const TextStyle(fontSize: 20),
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color(0xD02CE0CA), width: 2.0),
                      ),
                    ),
                    elevation: WidgetStateProperty.resolveWith<double>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return 15.0;
                        } else if (states.contains(WidgetState.hovered)) {
                          return 10.0;
                        }
                        return 5.0;
                      },
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontFamily: 'Tahoma'),
                  ),
                ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

