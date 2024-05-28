import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:ppms/menuScreen.dart';
import 'package:ppms/sql.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  var id = '';

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

  Future<bool> verifyUser(String userId, String password) async {
    var sql = mySql();

    try {
      MySqlConnection conn = await sql.getConnection();
      print("Connected");
      var results = await conn.query(
        'SELECT COUNT(*) FROM HR_USER_MSTR WHERE LOGIN_ID = ? AND PASSWORD = ?',
        [userId, password],
      );
      await conn.close();
      print("jbjhb");
      var count = results.first.values?.first as int;

      return count > 0;
    } catch (e) {
      print('Error connecting to MySQL: $e');
      return false;
    }
  }

  void _login() async {
    String userId = textController1?.text ?? '';
    String password = textController2?.text ?? '';

    bool isValidUser = await verifyUser(userId, password);
    if (isValidUser) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen()));
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid user ID or password')),
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
