import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysql1/mysql1.dart';
import 'package:ppms/home_page1_widget.dart';
import 'package:ppms/sql.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: isLoggedIn ? HomePage1Widget() : MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final unfocusNode = FocusNode();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
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
    _checkLoginStatus(); // Check if the user is already logged in
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // If user is already logged in, navigate to HomePage1Widget
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage1Widget()),
      );
    }
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();
    super.dispose();
  }

  bool isPresent = false;
  Future<void> fetchData(String user, String password) async {
    try {
      final url = 'http://172.16.0.5:10008/login?user_id=$user&password=$password';
      // final url = 'http://172.16.10.11:8000/login?user_id=$user&password=$password';
      print('Fetching data from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Data received: $data');

        if (data != null && data.isNotEmpty) {
          String loginId = data[0]['Login_id'];
          String unit = data[0]['Unit'];
          print(unit);

          // Save login_id to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('login_id', loginId);
          await prefs.setString('unit', unit);

          print('Login_id saved: $loginId');

          setState(() {
            isPresent = true;
          });
        } else {
          setState(() {
            isPresent = false;
          });
        }
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void getB() async {
    try {
      const url = 'http://172.16.0.123:12008/api/HRISM/GeteLeaveApplicationHistory';
      print('Fetching data from: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode":"9970",
        "yearNo":"2024",
        "monthNo":"6",
        "appStatus":"All",
        "appType":"Leave"
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Data received: $data');
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// Assuming this function is part of a StatefulWidget
  void setState(VoidCallback fn) {
    // Implement this function to update the state in your widget
  }

  void _login() async {
    String? userId = textController1?.text.trim();
    String? password = textController2?.text.trim();

    fetchData(userId!, password!);

    final response = await http.get(Uri.parse('http://172.16.0.5:10008/login?user_id=$userId&password=$password'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        print(data);
        // If login is successful, set isLoggedIn to true and navigate to HomePage1Widget
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage1Widget()),
        );
      } else {
        // Show error message if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid user ID or password')),
        );
      }
    } else {
      // Show error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Color(0xB2B9F6F3),Color(0xFFFFFFFF)],
    begin: Alignment(0.1,1.0),
    end: Alignment(-0.1,0.0),
    ),
    ),
      child: SafeArea(
        child: // Generated code for this Column Widget...
        Align(
          alignment: AlignmentDirectional(0, 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome To PPMS',style: TextStyle(
    fontSize: 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w800,
    ),),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
                  child: Text(
                    'ID: ',
                    style: TextStyle(
    letterSpacing: 0
    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(38, 10, 38, 10),
                  child: TextFormField(
                    controller: textController1,
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF101518),
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF06D5CD),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF199A7B),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF101518),
                      fontSize: 18,
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(38, 10, 38, 10),
                  child: TextFormField(
                    controller: textController2,
                    focusNode: textFieldFocusNode2,
                    autofocus: false,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF101518),
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF06D5CD),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF199A7B),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                      prefixIcon: Icon(
                        Icons.password_sharp,
                      ),

                    ),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF101518),
                      fontSize: 18,
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 10),
                  child: ElevatedButton(
                    onPressed: _login,
                    // onLongPress: getB,
                    child : Text('Login' ,style: TextStyle(
                      fontFamily: 'Tahoma'
                    ),),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Color(0xFF06D5CD); // Color when button is pressed
                          }
                          return Color(0xFF06D5CD); // Default color
                        },
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
                      ),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 20),
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Color(0xD02CE0CA),width: 2.0), // Border color and width
                        ),
                      ),
                      elevation: MaterialStateProperty.resolveWith<double>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return 15.0; // Elevation when pressed
                          } else if (states.contains(MaterialState.hovered)) {
                            return 10.0; // Elevation when hovered
                          }
                          return 5.0;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      )
      ),
    );
  }
}
