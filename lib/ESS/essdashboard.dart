import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/leave_approval/screens/leave_approval.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../common/widgets/appbar/appbar.dart';
import 'package:http/http.dart' as http;

import 'leave_application/screens/leave_application.dart';
import 'leave_approval/models/userprofilemodel.dart';

class EssDashBoard extends StatefulWidget {
  const EssDashBoard({super.key});

  @override
  State<EssDashBoard> createState() => _EssDashBoardState();
}

class _EssDashBoardState extends State<EssDashBoard> {

  @override
  void initState()  {
    // TODO: implement initState
     GetEmployeeProfileByEmployeeCode();
   /* SharedPreferences prefs = await SharedPreferences.getInstance();
    print("From shared preference${prefs.getString('login_id')}");*/
    super.initState();
  }

  Future<void> GetEmployeeProfileByEmployeeCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function User Profile");
    try {
      const url =
          'http://172.16.0.123:12008/api/HRISM/GetEmployeeProfileByEmployeeCode';
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
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    ////App Bar
                    const TAppBar(title: "Welcome to ESS",),
                    const SizedBox(height: 32,),

                    ///// Icons List
                     Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("Leave Approval",style: Theme.of(context).textTheme.headlineSmall,),
                                  const SizedBox(width: 20,),
                                  const Icon(Iconsax.arrow_right)
                                ],
                              ).onTap((){
                                Get.to(()=>const LeaveApproval(title: 'ESS- Leave Approval',));
                              }),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("Management Approval",style: Theme.of(context).textTheme.headlineSmall,),
                                  const SizedBox(width: 20,),
                                  const Icon(Iconsax.arrow_right)
                                ],
                              ).onTap(()=>Get.to(()=>ManagementApproval(title: 'ESS-Management Approval',))),
                            ],
                          ),
                          const SizedBox(height: 20,),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text("Leave Application",style: Theme.of(context).textTheme.headlineSmall,),
                                  const SizedBox(width: 20,),
                                  const Icon(Iconsax.arrow_right)
                                ],
                              ),
                            ],
                          ).onTap(()=>Get.to(()=>const LeaveApplication(title: "ESS-Leave Application",))),

                        ],
                      ),
                    ),


                  ],
                ),
              )

            ],
          ),
        ),
    );
  }
}

