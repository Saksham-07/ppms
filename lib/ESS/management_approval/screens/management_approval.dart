import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval_form.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../ExtraFunction/uuid.dart';
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
  String uuid = '';
  Future<List<Managementapprovalmodel>>? _futureAppData;

  @override
  void initState() {
    super.initState();
    getUid();
    _futureAppData = getManagementApproval();
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });
    print('Persistent UUID: $uuid');

  }

  void approveApp(String appId, String appCatg, String updateByType) async {
    await approveRejectApplication(
        appId, "Approved", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  void rejectApp(String appId, String appCatg, String updateByType) async {
    await approveRejectApplication(
        appId, "Rejected", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  void holdApp(String appId, String appCatg, String updateByType) async {
    await approveRejectApplication(
        appId, "Hold", appCatg, updateByType, "APPROVE_APP_APPROVAL");
  }

  Future<void> approveRejectApplication(String appId, String appStatus,
      String appType, String updateByType, String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstapprovalData = [];
      var url = '';
      if (appType == "1") {
        url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApproval';
      } else if (appType == "2") {
        url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApprovalHO';
      } else if (appType == "3") {
        url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectManagementApprovalSRV';
      }
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
        "appStatus": appStatus,
        "updateByType": updateByType,
        "mode": mode,
        "employeeId": prefs.getString('employeeId').toString(),
        "deviceId" : uuid
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
      rethrow;
    }
  }

  Future<List<Managementapprovalmodel>> getManagementApproval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstapprovalData = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetManagementApprovalList';
      if (kDebugMode) {
        print('Fetching data management Approval : $url');
      }

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
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          lstapprovalData.add(Managementapprovalmodel.fromJson(i));
        }
        if (kDebugMode) {
          print('Response body: $lstapprovalData');
        }
        return lstapprovalData;
      } else {
        return lstapprovalData;
      }
    } catch (e) {
      rethrow;
    }
  }

  ShowDialog(String message,int msgType) {

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

  showConfirmDialog(String message,String appId, String appCatg, String updateByType,int appType) async {
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
                        approveApp(appId, appCatg, updateByType);
                        Navigator.of(context).pop();
                      }
                      else if(appType==2)
                        {
                          rejectApp(appId, appCatg, updateByType);
                          Navigator.of(context).pop();
                        }
                      else if(appType==3)
                        {
                          holdApp(appId, appCatg, updateByType);
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
          content: Text(message),
        ));
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
            'Management Approval',
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: FutureBuilder(
                      future: _futureAppData,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Text("Loading", style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            verticalDirection: VerticalDirection.down,
                            children: [
                              GridView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                                shrinkWrap: true,
                                itemCount: lstapprovalData.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.7,
                                ),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Emp. Name: ",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      lstapprovalData[index].name.toString(),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Emp. Type: ",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      "${lstapprovalData[index].appType}, (${lstapprovalData[index].unit})",
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Department: ",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      lstapprovalData[index].department.toString(),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Monthly Salary: ",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(lstapprovalData[index].monthlySalary.toString()),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Increment Amount: ",
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(lstapprovalData[index].incAmount.toString()),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog(
                                                  "Are you sure want to Approve?",
                                                  lstapprovalData[index].appId.toString(),
                                                  lstapprovalData[index].appCatg.toString(),
                                                  lstapprovalData[index].updateByType.toString(),
                                                  1,
                                                );
                                              },
                                              icon: const Icon(Iconsax.tick_square, color: Colors.green),
                                              tooltip: "Approve",
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog(
                                                  "Are you sure want to Reject?",
                                                  lstapprovalData[index].appId.toString(),
                                                  lstapprovalData[index].appCatg.toString(),
                                                  lstapprovalData[index].updateByType.toString(),
                                                  2,
                                                );
                                              },
                                              icon: const Icon(Icons.disabled_by_default_rounded, color: Colors.red),
                                              tooltip: "Reject",
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                showConfirmDialog(
                                                  "Are you sure want to Hold?",
                                                  lstapprovalData[index].appId.toString(),
                                                  lstapprovalData[index].appCatg.toString(),
                                                  lstapprovalData[index].updateByType.toString(),
                                                  3,
                                                );
                                              },
                                              icon: const Icon(Icons.back_hand, color: Color(0xFFEEE258)),
                                              tooltip: "Hold",
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Get.to(() => ManagementApprovalForm(
                                                  appId: lstapprovalData[index].appId.toString(),
                                                  appCatg: lstapprovalData[index].appCatg.toString(),
                                                  updateByType: lstapprovalData[index].updateByType.toString(),
                                                ));
                                              },
                                              icon: const Icon(Iconsax.eye3),
                                              tooltip: "View",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          )

        ),);
  }
}
