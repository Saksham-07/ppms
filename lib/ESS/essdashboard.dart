import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/leave_approval/screens/leave_approval.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../common/widgets/appbar/appbar.dart';
import 'package:http/http.dart' as http;
import 'leave_application/screens/leave_application.dart';
import 'models/pendingapprovalmodel.dart';

class EssDashBoard extends StatefulWidget {
  const EssDashBoard({super.key});

  @override
  State<EssDashBoard> createState() => _EssDashBoardState();
}

class _EssDashBoardState extends State<EssDashBoard> {
  String pendingLeave="0",pendingMngtApproval="0";
  @override
  void initState()  {
    // TODO: implement initState
     GetePendingForApproval();
    super.initState();
  }


  Future<void> GetePendingForApproval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function Approval");
    try {
      const url = TBaseURL.essBaseUrl+'api/HRISM/GetePendingForApproval';
      print('Fetching data from User Profile: $url');
      String empId=prefs.getString('employeeId').toString();

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      print('Employee Id from preffered shared: $empId');
      Map<String, dynamic> body = {
        "employeeId": prefs.getString('employeeId').toString()
      };
      print('Request body before call: ${body}');
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print('Response body after call: ${response.body}');
      if (response.statusCode == 200) {
        print("Status Code ${response.statusCode}");
        var data = jsonDecode(response.body.toString());
        var resData=Pendingapprovalmodel.fromJson(data);
        setState(()
        {
          pendingLeave = resData.pendingLeaveApproval.toString();
          pendingMngtApproval = resData.pendingManagementApp.toString();
        });
        print('Pending Leave Approval: ${pendingLeave}');
        print('Pending Mngmt Approval: ${pendingMngtApproval}');

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
                                  Text("Leave Approval ",style: Theme.of(context).textTheme.headlineSmall,),
                                  Text("(${pendingLeave=="0"?"0":pendingLeave})",style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.red,),),
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
                                  Text("Management Approval ",style: Theme.of(context).textTheme.headlineSmall,),
                                  Text("(${pendingMngtApproval=="0"?"0":pendingMngtApproval})",style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.red),),
                                  const SizedBox(width: 20,),
                                  const Icon(Iconsax.arrow_right)
                                ],
                              ).onTap(()=>Get.to(()=>const ManagementApproval(title: 'ESS-Management Approval',))),
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
                          ).onTap(()=>Get.to(()=>const LeaveApplication(title: "ESS-Leave Application History",))),

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

