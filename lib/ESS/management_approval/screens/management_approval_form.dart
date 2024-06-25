import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/management_approval/models/managementapprovalformdto.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/common/utils/constants/image_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../common/utils/constants/baseurl.dart';

class ManagementApprovalForm extends StatefulWidget {
  const ManagementApprovalForm(
      {super.key,
      required this.appId,
      required this.appCatg,
      required this.updateByType});

  final String appId;
  final String appCatg;
  final String updateByType;

  @override
  State<ManagementApprovalForm> createState() => _ManagementApprovalFormState(
      appId: this.appId,
      appCatg: this.appCatg,
      updateByType: this.updateByType);
}

class _ManagementApprovalFormState extends State<ManagementApprovalForm> {
  String? appId;
  String? appCatg;
  String? updateByType;



  _ManagementApprovalFormState({this.appId, this.appCatg, this.updateByType});

  Managementapprovalformdto formData = Managementapprovalformdto();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getManagementApproval();
  }

  Future<Managementapprovalformdto> getManagementApproval() async {
    print("Here on Function");
    try {
      const url =
          TBaseURL.essBaseUrl + 'api/HRISM/GetManagementApprovalAppById';
      print('Fetching data management Approval : $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {"appId": appId, "appType": appCatg};

      print("Req Body ${body}");

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        var approvalData = Managementapprovalformdto.fromJson(data);
        setState(() {
          formData = approvalData;
        });
        print('Response body: ${approvalData}');
        return formData;
      } else {
        return formData;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  showConfirmDialog(String Message, String appId, String appCatg,
      String updateByType, int appType) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (appType == 1) {
                            ApproveApp(appId, appCatg, updateByType);
                            Navigator.of(context).pop();
                          } else if (appType == 2) {
                            RejectApp(appId, appCatg, updateByType);
                            Navigator.of(context).pop();
                          } else if (appType == 3) {
                            HoldApp(appId, appCatg, updateByType);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Yes")),
                    const SizedBox(
                      width: 5,
                    ),
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
      var url = '';
      if (appType == "1") {
        url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApproval';
      } else if (appType == "2") {
        url =
            '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApprovalHO';
      } else if (appType == "3") {
        url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApprovalSRV';
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
        ShowDialog(response.body, 1);
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const ManagementApproval(title: "ESS-Management Approval")),
          ).then((value) => setState(() {}));
        });
      } else {
        ShowDialog(response.body, 2);
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  ShowDialog(String Message, int msgType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
      padding: const EdgeInsets.all(16),
      height: 90,
      decoration: BoxDecoration(
          color: msgType == 1 ? Colors.blue : Color(0xFFC72C41),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Message,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                overflow: TextOverflow.ellipsis),
          )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => (Get.to(() =>
                const ManagementApproval(title: 'ESS-Managemrnt Approval'))),
            icon: const Icon(Iconsax.arrow_left),
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "Management Approval Form",
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Row(
                      children: [
                        DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(Colors.blue.shade50),
                          headingTextStyle:
                              TextStyle(color: Colors.blue.shade50),
                          dataRowColor:
                              WidgetStateProperty.all(Colors.blue.shade50.withOpacity(0.7)),
                          columns: const [
                            DataColumn(
                              label: SizedBox(
                                width: 100.0,
                                height: 1.0,
                                child: Text("First Head"),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 200.0,
                                height: 1.0,
                                child: Text("Second Head"),
                              ),
                            ),
                            /*DataColumn(
                                  label: SizedBox(
                                    width: 80.0,
                                    child: Text("Third Head"),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 80.0,
                                    child: Text("Fourth Head"),
                                  ),
                                )*/
                          ],
                          rows: [
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "App. Type",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(
                                    formData.typeofappointedname.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Left Emp. Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.leftempname.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Approval HOD",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.hodname.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Unit",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.unitname.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Category",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.category.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Level",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.level.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "New Emp. Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.newempname.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Grade",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.grade.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Department",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.department.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Sub. Department",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.subdepartment.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Designation",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.desigtion.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Date of Join",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.doj.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Monthly Salary",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.monthlysalary.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Increase Amount",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.incamount.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "New Monthly Salary",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child:
                                    Text(formData.newmonthlysalary.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Increase %",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(formData.incper.toString()),
                              )),
                            ]),
                            DataRow(cells: [
                              const DataCell(SizedBox(
                                width: 100.0,
                                child: Text(
                                  "Reporting Officer",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                              DataCell(SizedBox(
                                width: 200.0,
                                child: Text(
                                    formData.reportingPersonName.toString()),
                              )),
                            ])
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          )),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ScrollPhysics(),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                     Column(
                      children: [
                        const Text(
                          "Proposer",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.propstatus=="Sent for Approval" || formData.propstatus=="Approved"?TImages.approveStatus:(formData.propstatus=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.propstatus=="Sent for Approval" || formData.propstatus=="Approved"?Iconsax.verify:(formData.propstatus=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        const Text(
                          "Unit HR Head",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apr1status=="Sent for Approval" || formData.apr1status=="Approved"?TImages.approveStatus:(formData.apr1status=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apr1status=="Sent for Approval" || formData.apr1status=="Approved"?Iconsax.verify:(formData.apr1status=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                     Column(
                      children: [
                        const Text(
                          "Unit GM",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apr2status=="Sent for Approval" || formData.apr2status=="Approved"?TImages.approveStatus:(formData.apr2status=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apr2status=="Sent for Approval" || formData.apr2status=="Approved"?Iconsax.verify:(formData.apr2status=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                     Column(
                      children: [
                        const Text(
                          "AVP APPROVAL",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apravpstatus=="Sent for Approval" || formData.apravpstatus=="Approved"?TImages.approveStatus:(formData.apravpstatus=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apravpstatus=="Sent for Approval" || formData.apravpstatus=="Approved"?Iconsax.verify:(formData.apravpstatus=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                      Column(
                      children: [
                        const Text(
                          "HO",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apr3status=="Sent for Approval" || formData.apr3status=="Approved"?TImages.approveStatus:(formData.apr3status=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apr3status=="Sent for Approval" || formData.apr3status=="Approved"?Iconsax.verify:(formData.apr3status=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                     Column(
                      children: [
                        const Text(
                          "Senior Management Approval",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apr4status=="Sent for Approval" || formData.apr4status=="Approved"?TImages.approveStatus:(formData.apr4status=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apr4status=="Sent for Approval" || formData.apr4status=="Approved"?Iconsax.verify:(formData.apr4status=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                        .make(),
                    const SizedBox(
                      width: 10,
                    ),
                     Column(
                      children: [
                        const Text(
                          "Mr.Sumit/Mr. Narinder/Mr. Surinder",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image(width: 30,height: 30,image: AssetImage(formData.apr5status=="Sent for Approval" || formData.apr5status=="Approved"?TImages.approveStatus:(formData.apr5status=="Hold"?TImages.holdStatus:TImages.pendingStatus)))
                        //Icon(formData.apr5status=="Sent for Approval" || formData.apr5status=="Approved"?Iconsax.verify:(formData.apr5status=="Hold"?Icons.thumb_down:Iconsax.timer))
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  showConfirmDialog(
                      "Are you sure want to Approve?",
                      appId.toString(),
                      appCatg.toString(),
                      updateByType.toString(),
                      1);
                },
                icon: const Image(
                  image: AssetImage(
                      "assets/images/ess_images/ButtonIcons/TickIcon.png"),
                  height: 40,
                  width: 40,
                ),
                tooltip: "Approve",
              ),
              IconButton(
                onPressed: () {
                  showConfirmDialog(
                      "Are you sure want to Reject?",
                      appId.toString(),
                      appCatg.toString(),
                      updateByType.toString(),
                      2);
                },
                icon: const Image(
                  image: AssetImage(
                      "assets/images/ess_images/ButtonIcons/CrossIcon.png"),
                  height: 25,
                  width: 25,
                ),
                tooltip: "Reject",
              ),
              IconButton(
                onPressed: () {
                  showConfirmDialog(
                      "Are you sure want to Hold?",
                      appId.toString(),
                      appCatg.toString(),
                      updateByType.toString(),
                      3);
                },
                icon: const Image(
                  image: AssetImage(
                      "assets/images/ess_images/ButtonIcons/HoldIcon.png"),
                  height: 22,
                  width: 22,
                ),
                tooltip: "Hold",
              ),
            ],
          ).centered().paddingAll(5)
              .box
              .shadow
              .color(Vx.gray50)
          //.width(190)
              .rounded
              .border(color: Colors.grey)
              .shadow
              .make(),
        ]));
  }
}
