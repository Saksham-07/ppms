import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
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
    if (kDebugMode) {
      print("Back to List Leave Application ");
    }
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    getYearList();
    getMonthList();
    getLeaveBalance();
    getLeaveAppList();
    if (kDebugMode) {
      print("Month Number ${DateTime.now().month.toString()}");
    }
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reportingPersonaName = prefs.getString("reportingpersonname").toString();
    setState(() {
    });
  }

  Future<List<YearDto>> getYearList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstYear = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetyearList';
      if (kDebugMode) {
        print('Fetching data Year List: $url');
      }

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
        if (kDebugMode) {
          print('Response body Year List: ${response.body.toString()}');
        }
        return lstYear;
      } else {
        return lstYear;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Monthmodel>> getMonthList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstMonth = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetmonthList';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

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
        if (kDebugMode) {
          print('Response body Month List: ${response.body.toString()}');
        }
        return lstMonth;
      } else {
        return lstMonth;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Selfleaveapp>> getLeaveAppList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstLeaveApp = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GeteLeaveApplicationHistory';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

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
        if (kDebugMode) {
          print('Response body Self Leave List: ${response.body.toString()}');
        }
        return lstLeaveApp;
      } else {
        return lstLeaveApp;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLeaveBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function Leave Balance");
    }
    try {
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GeteLeaveBalance';
      if (kDebugMode) {
        print('Fetching data Leave Balance: $url');
      }

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

        if (kDebugMode) {
          print('Response body Self Leave List: ${response.body.toString()}');
        }
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

  showConfirmDialog(String message,String appId,int appType) async {
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
                        cancelLeaveApp(appId);
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
          content: Text(message),
        ));
  }

  void cancelLeaveApp(String appId) async {
    await cancelApplication(appId, "Cancelled");
  }

  Future<void> cancelApplication(String appId, String appStatus) async {
    try {
      lstLeaveApp = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/CancelLeaveApplication';
      if (kDebugMode) {
        print('Approving Application Approval of Subbordinate: $url');
      }

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

      if (kDebugMode) {
        print(response.body);
      }

      if (response.statusCode == 200) {
        showAlert(response.body,1);
        setState(() {
            selectedYear=DateTime.now().year.toString();
            getLeaveAppList();
        });
      }
      else
      {
        showAlert(response.body,2);
      }
    } catch (e) {
      rethrow;
    }
  }

  showAlert(String message,int msgType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Container(
      padding: const EdgeInsets.all(16),
      height: 90,
      decoration: BoxDecoration(
          color:msgType==1?Colors.blue:const Color(0xFFC72C41),
          borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message,style: const TextStyle(fontSize:12,color:Colors.white,overflow: TextOverflow.ellipsis ),)
        ],
      ),
    )));
  }

  Future<void> _navigateToPage (String title , String req) async {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              LeaveForm(title: title ,reqType: req,
              )
          )
      );
      if (result == true) {
        getLeaveAppList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5FE3D3),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Application',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
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
            ),
            const SizedBox(
              height: 10,
            ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Balances Column
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "CL $leaveCL".text.make(),
                  "SL $leaveSL".text.make(),
                  "EL $leaveEL".text.make(),
                ],
              ),
            ),
            // Buttons Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Visibility(
                    visible: (reportingPersonaName.isNotEmptyAndNotNull),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double buttonWidth = (constraints.maxWidth - 90) / 2;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: buttonWidth,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _navigateToPage('Leave Request', "Leave");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: const Color(0xFFFFFFFF),
                                      ),
                                      child: const Text("Leave"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // MisPunch Button
                                  SizedBox(
                                    width: buttonWidth,
                                    height: 30, // Fixed height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _navigateToPage('MisPunch Request', "Mispunch");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: const Color(0xFFFFFFFF),
                                      ),
                                      child: const Text("MisPunch"),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // OD Button
                                  SizedBox(
                                    width: buttonWidth,
                                    height: 30, // Fixed height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _navigateToPage('OD Request', "OD");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlue,
                                        foregroundColor: const Color(0xFFFFFFFF),
                                      ),
                                      child: const Text("OD"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // WFH Button
                                  SizedBox(
                                    width: buttonWidth,
                                    height: 30, // Fixed height
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _navigateToPage('WFH Request', "WFH");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: const Color(0xFFFFFFFF),
                                      ),
                                      child: const Text("WFH"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        /// Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        top: BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        top: BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                    ),
                  child: DropdownButtonHideUnderline(
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Application Type Row
                                  Flexible(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "App Type    : ".text.bold.make(),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: lstLeaveApp[index]
                                              .apptype
                                              .toString()
                                              .text
                                              .make(),
                                        ),
                                        const Spacer(),
                                        Visibility(
                                          visible: (lstLeaveApp[index].appstatus.toString() ==
                                              "Sent for Approval"),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              onPressed: () {
                                                showConfirmDialog(
                                                  "Are you sure want to Cancel",
                                                  lstLeaveApp[index].appid.toString(),
                                                  2,
                                                );
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
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Application Period Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "App. Period : ".text.bold.make(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ("${lstLeaveApp[index].fromdt} - ${lstLeaveApp[index].todt}")
                                        .text
                                        .make(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Remarks Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "Remarks     : ".text.bold.make(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      lstLeaveApp[index].apptype.toString() == "Mispunch"
                                          ? lstLeaveApp[index].misPunchReason.toString()
                                          :  lstLeaveApp[index].appremarks!.length >= 15 ? lstLeaveApp[index].appremarks.toString().substring(0,15): lstLeaveApp[index].appremarks.toString() ,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Application Status Row
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "App. Status : ".text.bold.make(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: lstLeaveApp[index].appstatus!.text.make(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            if(lstLeaveApp[index].appstatus! == 'Accepted' || lstLeaveApp[index].appstatus! == 'Rejected')
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  "App. Cmnts : ".text.bold.make(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: (lstLeaveApp[index].approvalremarks ?? '').text.make(),
                                  ),
                                ],
                              ),
                            ),

                            Visibility(
                              visible: (lstLeaveApp[index].apptype.toString() == "Mispunch"),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    (lstLeaveApp[index].intime == null ||
                                        lstLeaveApp[index].intime!.isEmpty
                                        ? "Out Time    : "
                                        : "In Time    : ")
                                        .text
                                        .bold
                                        .make(),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: (lstLeaveApp[index].intime == null ||
                                          lstLeaveApp[index].intime!.isEmpty
                                          ? lstLeaveApp[index].outtime
                                          : lstLeaveApp[index].intime)
                                          .toString()
                                          .text
                                          .make(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                            .paddingAll(5)
                            .box
                            .shadow
                            .color(Vx.gray50)
                            .rounded
                            .border(color: Colors.grey)
                            .make(),
                      );
                    },
                  ),
                ],
              )),
            )),
          ],
        ),
      ),
    );
  }
}
