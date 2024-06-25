import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/essdashboard.dart';
import 'package:ppms/ESS/leave_application/screens/leave_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../common/models/monthmodel.dart';
import '../../../common/utils/constants/baseurl.dart';
import '../models/leavebalancedto.dart';
import '../models/selfleaveapp.dart';
import '../models/yeardto.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key,
    required this.title,
    this.isRefresh=false});
  final String title;
  final bool isRefresh;
  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late TextEditingController _controller;
  String reportingPerson = "", reportingPersonaName = "";

  List<YearDto> lstYear = [];
  String? selectedYear = DateTime.now().year.toString();
  List<Monthmodel> lstMonth = [];
  String? selectedMonth = DateTime.now().month.toString();
  List<Selfleaveapp> lstLeaveApp = [];
  String? leaveCL = "0";
  String? leaveSL = "0";
  String? leaveEL = "0";

  @override
  void initState() {
    print("Back to List Leave Application ");
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    getYearList();
    getMonthList();
    getLeaveBalance();
    getLeaveAppList();
    print("Month Number ${DateTime.now().month.toString()}");
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reportingPersonaName = prefs.getString("reportingpersonname").toString();
    setState(() {
      _controller = new TextEditingController(text: reportingPersonaName);
    });
  }

  Future<List<YearDto>> getYearList() async {
    print("Here on Function");
    try {
      lstYear = [];
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetyearList';
      print('Fetching data Year List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstYear.add(YearDto.fromJson(i));
          });
        }
        print('Response body Year List: ${response.body.toString()}');
        return lstYear;
      } else {
        return lstYear;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  Future<List<Monthmodel>> getMonthList() async {
    print("Here on Function");
    try {
      lstMonth = [];
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetmonthList';
      print('Fetching data Month List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstMonth.add(Monthmodel.fromJson(i));
          });
        }
        print('Response body MOnth List: ${response.body.toString()}');
        return lstMonth;
      } else {
        return lstMonth;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  Future<List<Selfleaveapp>> getLeaveAppList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function");
    try {
      lstLeaveApp = [];
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GeteLeaveApplicationHistory';
      print('Fetching data Month List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "yearNo": selectedYear.toString(),
        "monthNo": selectedMonth.toString(),
        "appStatus": "All"
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstLeaveApp.add(Selfleaveapp.fromJson(i));
          });
        }
        print('Response body Self Leave List: ${response.body.toString()}');
        return lstLeaveApp;
      } else {
        return lstLeaveApp;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  Future<void> getLeaveBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function Leave Balance");
    try {
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GeteLeaveBalance';
      print('Fetching data Leave Balance: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "unitCode": prefs.getString('unitId').toString(),
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var leaveBal = Leavebalancedto.fromJson(data);
        setState(() {
          leaveCL = leaveBal.clbal.toString();
          leaveSL = leaveBal.slbal.toString();
          leaveEL = leaveBal.elbal.toString();
        });

        print('Response body Self Leave List: ${response.body.toString()}');
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  showConfirmDialog(String Message,String appId,int appType) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if(appType==2)
                      {
                        CancelLeaveApp(appId);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Yes")),
                const SizedBox(width: 5,),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("No")),
              ],
            )

          ],
          title: const Text("Confirmation Leave Cancellation"),
          contentPadding: const EdgeInsets.all(20),
          content: Text(Message),
        ));
  }

  void CancelLeaveApp(String appId) async {
    await CancelApplication(appId, "Cancelled");
  }

  Future<void> CancelApplication(String appId, String appStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstLeaveApp = [];
      const url = TBaseURL.essBaseUrl+'api/HRISM/CancelLeaveApplication';
      print('Approving Application Approval of Subbordinate: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "appId": appId,
        "appStatus": appStatus
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ShowAlert(response.body,1);
        setState(() {
            selectedYear=DateTime.now().year.toString();
            getLeaveAppList();
        });
      }
      else
      {
        ShowAlert(response.body,2);
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  ShowAlert(String Message,int msgType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Container(
      padding: const EdgeInsets.all(16),
      height: 90,
      decoration: BoxDecoration(
          color:msgType==1?Colors.blue:Color(0xFFC72C41),
          borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Message,style: const TextStyle(fontSize:12,color:Colors.white,overflow: TextOverflow.ellipsis ),)
        ],
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>(Get.to(()=>const EssDashBoard())), icon: const Icon(Iconsax.arrow_left),),
        automaticallyImplyLeading: false,
        title: Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .apply(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),

          ///Reporting Manager Details
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              "Reporting Manager : ".text.size(16).bold.makeCentered(),
              const SizedBox(
                width: 10,
              ),
              reportingPersonaName.text
                  .size(16)
                  .overflow(TextOverflow.ellipsis)
                  .makeCentered().flexible()
            ],
          ).box.color(Vx.gray100).rounded.make(),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  " CL ${leaveCL}".text.make(),
                  " SL ${leaveSL}".text.make(),
                  "   EL ${leaveEL}".text.make()
                ],
              ).box.color(Vx.gray100).make(),
              const SizedBox(
                width: 200,
              ),
              Visibility(
                visible: (reportingPersonaName.isNotEmptyAndNotNull),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(()=>const LeaveForm(title: 'ESS - Leave Request',reqType: "Leave",));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: const Color(0xFFFFFFFF)),
                  child: const Text("New Request"),
                ),
              ),
            ],
          ),


          /// Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Year',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: lstYear
                      .map((YearDto item) => DropdownMenuItem<String>(
                            value: item.yearNo,
                            child: Text(
                              item.yearNo.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  value: selectedYear,
                  onChanged: (String? value) {
                    setState(() {
                      selectedYear = value;
                      getLeaveAppList();
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    width: 140,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: lstMonth
                      .map((Monthmodel item) => DropdownMenuItem<String>(
                            value: item.monthNo,
                            child: Text(
                              item.monthName.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  value: selectedMonth,
                  onChanged: (String? value) {
                    setState(() {
                      selectedMonth = value;
                      getLeaveAppList();
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    width: 140,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            ],
          ),

          ////Application List
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,

              children: [
                GridView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lstLeaveApp.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.3),
                    itemBuilder: (context, index) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    "App Type    : ".text.bold.make(),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    lstLeaveApp[index]
                                        .apptype
                                        .toString()
                                        .text
                                        .make(),
                                    SizedBox(
                                      width: 150.0+(
                                          lstLeaveApp[index].apptype.toString()=="OD"?45.0:
                                          (lstLeaveApp[index].apptype.toString()=="Leave"?30.0:
                                          (lstLeaveApp[index].apptype.toString()=="WFH"?30.0:0.0))),
                                    ),

                                    Visibility(
                                      visible:(lstLeaveApp[index].appstatus.toString()=="Sent for Approval"),
                                      child: Container(
                                        decoration:const BoxDecoration(
                                          borderRadius: BorderRadius.only(topRight:Radius.circular(12) ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            showConfirmDialog("Are you sure want to Cancel",lstLeaveApp[index]
                                                .appid
                                                .toString(),2);
                                          },
                                          icon: const Image(
                                            image: AssetImage(
                                                "assets/images/ess_images/ButtonIcons/CrossIcon.png"),
                                            height: 25,
                                            width: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                ),
                                const SizedBox(
                                  height: 4.5,
                                ),
                                Row(
                                  children: [
                                    "App. Period : ".text.bold.make(),
                                    const SizedBox(
                                      width: 19,
                                    ),
                                    ("${lstLeaveApp[index].fromdt} - ${lstLeaveApp[index].todt}")
                                        .text
                                        .make(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4.5,
                                ),
                                Row(
                                  children: [
                                    "Remarks     : ".text.bold.make(),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    "${ (lstLeaveApp[index].apptype.toString()=="Mispunch"?lstLeaveApp[index].misPunchReason.toString():lstLeaveApp[index].appremarks.toString())}"
                                        .text.overflow(TextOverflow.ellipsis).maxLines(2)
                                        .make().flexible(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4.5,
                                ),
                                Row(
                                  children: [
                                    "App. Status : ".text.bold.make(),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    ("${lstLeaveApp[index].appstatus}")
                                        .text
                                        .make(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5.5,
                                ),
                                Visibility(
                                  visible: (lstLeaveApp[index].apptype.toString()=="Mispunch"),
                                  child: Row(
                                    children: [
                                      (lstLeaveApp[index].intime==null || lstLeaveApp[index].intime!.isEmpty?"Out Time    : ":"In Time    : ").text.bold.make(),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      ("${lstLeaveApp[index].intime==null || lstLeaveApp[index].intime!.isEmpty?lstLeaveApp[index].outtime:lstLeaveApp[index].intime}")
                                          .text
                                          .make(),
                                    ],
                                  ),
                                ),

                              ],
                            )
                          ]).paddingAll(5)
                          .box
                          .shadow
                          .color(Vx.gray50)
                      //.width(190)
                          .rounded
                          .border(color: Colors.grey)
                          .shadow
                          .make();
                    })
              ],
            )),
          )),
        ],
      ),
    );
  }
}
