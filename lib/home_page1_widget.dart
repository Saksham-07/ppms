import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ppms/MainDashboard.dart';
import 'package:ppms/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ESS/essdashboard.dart';
import 'ESS/leave_approval/models/userprofilemodel.dart';
import 'animation_info.dart'; // Import the animation utility
import 'common/utils/constants/baseurl.dart';
import 'package:http/http.dart' as http;

class HomePage1Widget extends StatefulWidget {
  const HomePage1Widget({super.key});

  @override
  State<HomePage1Widget> createState() => _HomePage1WidgetState();
}

class _HomePage1WidgetState extends State<HomePage1Widget>
    with TickerProviderStateMixin {

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    GetEmployeeProfileByEmployeeCode();

    animationsMap.addAll({
      'gridOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeIn,
            delay: Duration(milliseconds: 0),
            duration: Duration(milliseconds: 1000),
            begin: Offset(2.0, 2.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: Duration(milliseconds: 200),
            duration: Duration(milliseconds: 1000),
            begin: Offset(-200.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeIn,
            delay: Duration(milliseconds: 220),
            duration: Duration(milliseconds: 1020),
            begin: Offset(200.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: Duration(milliseconds: 250),
            duration: Duration(milliseconds: 1050),
            begin: Offset(-200.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

  }


  Future<void> GetEmployeeProfileByEmployeeCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function User Profile");
    try {
      const url = TBaseURL.essBaseUrl+'api/HRISM/GetEmployeeProfileByEmployeeCode';
      print('Fetching data from User Profile: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      print("Login Id is "+prefs.getString('login_id').toString());
      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('login_id').toString()
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Status Code ${response.statusCode}");
        var data = jsonDecode(response.body.toString());
        var newProfiledata=Userprofilemodel.fromJson(data);
        print(newProfiledata);
        print(newProfiledata.employeeid.toString());
        prefs.setString('employeeId', newProfiledata.employeeid.toString());
        prefs.setString('unitId', newProfiledata.unit.toString());
        prefs.setString('unitlocation', newProfiledata.unitlocation.toString());
        prefs.setString('department', newProfiledata.department.toString());
        prefs.setString('designation', newProfiledata.designation.toString());
        prefs.setString('reportingperson', newProfiledata.reportingperson.toString());
        prefs.setString('reportingpersonname', newProfiledata.reportingpersonname.toString());

        print("reportingpersonname${prefs.getString('reportingpersonname').toString()}");

      } else {

        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: BoxDecoration(
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
            children:[ NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, _) => [
                const SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor:Color(0xFF5FE3D3),
                  automaticallyImplyLeading: true,
                  title: Text(
                    'Paramount Product Management System',
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      color: Color(0xFFF8F9FA),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
                  actions: [],
                  centerTitle: true,
                  elevation: 4,
                )
              ],
              body: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32, 8, 28, 16),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 32.0, // Horizontal space between items
                          mainAxisSpacing: 24.0, // Vertical space between items
                          childAspectRatio: 1.2, // Aspect ratio of the grid items
                        ),
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MainDashboardWidget()),);
                            },
                            child: Material(
                              color: Colors.transparent,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/kpi_n.png', // Updated to use asset image
                                    width: double.minPositive,
                                    height: double.minPositive,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const EssDashBoard()),);
                            },
                            child: Material(
                              color: Colors.transparent,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child : Container(
                                    width: 20,
                                    height: 20,
                                    child: Image.asset(
                                      'assets/images/ess_new.png', // Updated to use asset image
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']!),
                          ),
                          Material(
                            color: Colors.transparent,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Color(0x33000000),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/file.png', // Updated to use asset image
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation3']!),
                        ],
                      ).animateOnPageLoad(animationsMap['gridOnPageLoadAnimation']!),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, 1),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                        child: Text(
                          'Version',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
          Positioned(
              bottom: 48,
              right: 32,
              child: FloatingActionButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: 'Flutter',)),
                  );
                },
                backgroundColor: Colors.greenAccent,
                elevation: 10,
                child: Icon(Icons.logout),
              ),
          )
          ]
          ),
        ),
      ),
    );
  }
}
