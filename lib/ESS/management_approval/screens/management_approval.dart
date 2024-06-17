import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import '../models/managementapprovalmodel.dart';

class ManagementApproval extends StatefulWidget {
  const ManagementApproval({super.key, required this.title});
  final String title;
  @override
  State<ManagementApproval> createState() => _ManagementApprovalState();
}

class _ManagementApprovalState extends State<ManagementApproval> {
  final List<String> items = [
    'All',
    'Applied',
    'Approved',
    'Rejected',
  ];
  String? selectedValue = "All";
  List<Managementapprovalmodel> lstapprovalData = [];

  void ApproveApp(String appId, String appCatg, String updateByType) async {
    await ApproveRejectApplication(
        appId, "Approved", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  void RejectApp(String appId, String appCatg, String updateByType) async {
    await ApproveRejectApplication(
        appId, "Rejected", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  void HoldApp(String appId, String appCatg, String updateByType) async {
    await ApproveRejectApplication(
        appId, "Hold", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  Future<void> ApproveRejectApplication(String appId, String appStatus,
      String appType, String updateByType, String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstapprovalData = [];
      var url = '';
      if (appType == "1") {
        url =
            'http://172.16.0.123:12008/api/HRISM/ApproveRejectManagementApproval';
      } else if (appType == "2") {
        url =
            'http://172.16.0.123:12008/api/HRISM/ApproveRejectManagementApprovalHO';
      } else if (appType == "3") {
        url =
            'http://172.16.0.123:12008/api/HRISM/ApproveRejectManagementApprovalSRV';
      }
      print('Approving Application Approval of Subbordinate: $url');
      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "appId": appId,
        "appStatus": appStatus,
        "updateByType": updateByType,
        "mode": mode,
        "employeeId": prefs.getString('employeeId').toString()
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ShowDialog(response.body,1);
        setState(() {
          lstapprovalData = [];
          selectedValue = "Applied";
          selectedValue = "All";
        });
      }
      else
        {
          ShowDialog(response.body,2);
        }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  Future<List<Managementapprovalmodel>> getManagementApproval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function");
    try {
      lstapprovalData = [];
      const url =
          'http://172.16.0.123:12008/api/HRISM/GetManagementApprovalList';
      print('Fetching data management Approval : $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeId": prefs.getString('employeeId').toString(),
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          lstapprovalData.add(Managementapprovalmodel.fromJson(i));
        }
        print('Response body: ${lstapprovalData}');
        return lstapprovalData;
      } else {
        return lstapprovalData;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  ShowDialog(String Message,int msgType) {

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
    /*showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"))
              ],
              title: const Text("Application Approval"),
              contentPadding: const EdgeInsets.all(20),
              content: Text(Message),
            ));*/
  }

  showConfirmDialog(String Message,String appId, String appCatg, String updateByType,int appType) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if(appType==1) {
                        ApproveApp(appId, appCatg, updateByType);
                        Navigator.of(context).pop();
                      }
                      else if(appType==2)
                        {
                          RejectApp(appId, appCatg, updateByType);
                          Navigator.of(context).pop();
                        }
                      else if(appType==3)
                        {
                          HoldApp(appId, appCatg, updateByType);
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
          title: const Text("Confirmation Management Approval"),
          contentPadding: const EdgeInsets.all(20),
          content: Text(Message),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          /*DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Select Status',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              items: items
                  .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ))
                  .toList(),
              value: selectedValue,
              onChanged: (String? value) {
                setState(() {
                  selectedValue = value;
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
          ),*/
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: FutureBuilder(
                    future: getManagementApproval(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return "Loading".text.make();
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            GridView.builder(
                                shrinkWrap: true,
                                itemCount: lstapprovalData.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 1,
                                        mainAxisSpacing: 1,
                                        crossAxisSpacing: 1,
                                        childAspectRatio: 2.1),
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            "Emp. Name : ".text.bold.make(),
                                            const SizedBox(
                                              width: 50,
                                            ),
                                            lstapprovalData[index]
                                                .name
                                                .toString()
                                                .text
                                                .overflow(TextOverflow.ellipsis)
                                                .make(),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4.5,
                                        ),
                                        Row(
                                          children: [
                                            "Emp. Type : ".text.bold.make(),
                                            const SizedBox(
                                              width: 59,
                                            ),
                                            ("${lstapprovalData[index].appType} , (${lstapprovalData[index].unit})")
                                                .text
                                                .overflow(TextOverflow.ellipsis)
                                                .make()
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4.5,
                                        ),
                                        Row(children: [
                                          "Department : ".text.bold.make(),
                                          const SizedBox(
                                            width: 51,
                                          ),
                                          lstapprovalData[index]
                                              .department
                                              .toString()
                                              .text
                                              .overflow(TextOverflow.ellipsis)
                                              .make(),
                                        ]),
                                        const SizedBox(
                                          height: 4.5,
                                        ),
                                        Row(
                                          children: [
                                            "Monthly Salary : "
                                                .text
                                                .bold
                                                .make(),
                                            const SizedBox(
                                              width: 30,
                                            ),
                                            lstapprovalData[index]
                                                .monthlySalary
                                                .toString()
                                                .text
                                                .wrapWords(true)
                                                .make()
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 4.5,
                                        ),
                                        Row(
                                          children: [
                                            "Increment Amount : "
                                                .text
                                                .bold
                                                .make(),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            lstapprovalData[index]
                                                .incAmount
                                                .toString()
                                                .text
                                                .wrapWords(true)
                                                .make()
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog("Are you sure want to Approve?",lstapprovalData[index]
                                                    .appId
                                                    .toString(),
                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString(),1);
                                                /*ApproveApp(
                                                    lstapprovalData[index]
                                                        .appId
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString()
                                                );*/
                                              },
                                              icon: const Image(
                                                image: AssetImage(
                                                    "assets/images/ess_images/ButtonIcons/TickIcon.png"),
                                                height: 40,
                                                width: 40,
                                              ),
                                              tooltip: "Approve",

                                              /*,
                                                child: "Approve"
                                                    .text
                                                    .makeCentered()*/
                                            ),
                                            //const SizedBox(width:1 ,),
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog("Are you sure want to Reject?",lstapprovalData[index]
                                                    .appId
                                                    .toString(),
                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString(),2);
                                               /* RejectApp(
                                                    lstapprovalData[index]
                                                        .appId
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString());*/
                                              },
                                              icon: const Image(
                                                image: AssetImage(
                                                    "assets/images/ess_images/ButtonIcons/CrossIcon.png"),
                                                height: 25,
                                                width: 25,
                                              ),
                                              tooltip: "Reject",
                                              /*child: "Reject"
                                                    .text
                                                    .makeCentered()*/
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog("Are you sure want to Hold?",lstapprovalData[index]
                                                    .appId
                                                    .toString(),

                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString(),3);
                                                /*HoldApp(
                                                    lstapprovalData[index]
                                                        .appId
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .appCatg
                                                        .toString(),
                                                    lstapprovalData[index]
                                                        .updateByType
                                                        .toString());*/
                                              },
                                              icon: const Image(
                                                image: AssetImage(
                                                    "assets/images/ess_images/ButtonIcons/HoldIcon.png"),
                                                height: 22,
                                                width: 22,
                                              ),
                                              tooltip: "Hold",
                                              /*child:
                                                    "Hold".text.makeCentered()*/
                                            ),
                                          ],
                                        ).centered()
                                      ],
                                    )
                                        .paddingAll(5)
                                        .box
                                        .shadow
                                        .color(Vx.gray50)
                                        //.width(190)
                                        .rounded
                                        .border(color: Colors.grey)
                                        .shadow
                                        .make()
                                  ]);
                                })
                          ],
                        );
                      }
                    }),
              ),
            ),
          ),
        ]));
  }
}
