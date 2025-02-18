import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../../../ExtraFunction/uuid.dart';
import '../models/appaprovalnewmodel.dart';

class LeaveApproval extends StatefulWidget {
  const LeaveApproval({super.key, required this.title});

  final String title;

  @override
  State<LeaveApproval> createState() => _LeaveApproval();
}

class _LeaveApproval extends State<LeaveApproval> {
  DateTimeRange selectedDates = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(const Duration(days: 10)));
  final List<String> items = [
    'All',
    'Applied',
    'Approved',
    'Rejected',
  ];
  String? selectedValue = "All";
  var outputFormat = DateFormat('dd-MM-yyyy');
  List<Appaprovalnewmodel> lstAppData = [];

  String uuid = '';
  Future<List<Appaprovalnewmodel>>? _futureAppData;

  @override
  void initState() {
    super.initState();
    getUid();
    _futureAppData = getApplicationApprovalSub();
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });
      print('Persistent UUID: $uuid');

  }

  void approveLeaveApp(String appId, String remarks) async {
    await approveRejectApplication(appId, "Approved", remarks);
  }

  void rejectLeaveApp(String appId, String remarks) async {
    await approveRejectApplication(appId, "Rejected", remarks);
  }

  Future<void> approveRejectApplication(
      String appId, String appStatus, String approvalRemarks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstAppData = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/ApproveRejectApplication';
      if (kDebugMode) {
        print('Approving Application Approval of Subordinate: $url');
      }

      print(uuid);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "appId": appId,
        "appStatus": appStatus,
        "approvalRemarks": approvalRemarks,
        "deviceId":"$uuid",
      };

      print(body);
      print(jsonEncode(body));

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if(kDebugMode) {
        print(response.body);
      }

      if(response.statusCode == 200) {
        showDialogs(response.body, 1);
        setState(() {
          lstAppData = [];
          selectedValue = "Applied";
          selectedValue = "All";
        });
      } else {
        showDialogs(response.body, 2);
      }
    } catch (e) {
      rethrow;
    }
  }

  showDialogs(String message, int msgType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: BoxDecoration(
            color: msgType == 1 ? Colors.blue : const Color(0xFFC72C41),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white, overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      ),
    ));
  }

  showConfirmDialog(String message, String appId, int appType) async {
    String remarks;
    bool isAccept = false;
    if(appType == 1) {
      remarks = "Approved By Mobile Application"; // Variable to hold remark input
      isAccept = true;
    }
    else{
      remarks = "Rejected By Mobile Application";
    }


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation Leave Approval"),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 10),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: isAccept ? 'Approved By Mobile Application' : 'Rejected By Mobile Application',
                border: const OutlineInputBorder(),
                labelText: "Enter Remarks",
              ),
              onChanged: (value) {
                remarks = value; // Capture the remark input
              },
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (remarks.trim().isEmpty) {
                    // Validate if remarks are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Remarks cannot be empty.")),
                    );
                    return;
                  }
                  if (appType == 1) {
                    approveLeaveApp(appId, remarks);
                  } else if (appType == 2) {
                    rejectLeaveApp(appId, remarks);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("Yes"),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("No"),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<List<Appaprovalnewmodel>> getApplicationApprovalSub() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstAppData = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetApplicationApprovalSub';
      if (kDebugMode) {
        print('Fetching data from Application Approval of Subbordinate: $url');
      }

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "dFrom": "2024-06-11",
        "dTo": "2024-06-22",
        "appStatus": selectedValue
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
          lstAppData.add(Appaprovalnewmodel.fromJson(i));
        }
        return lstAppData;
      } else {
        return lstAppData;
      }
    } catch (e) {
      throw e;
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
          'Leave Approval',
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
                        return const CircularProgressIndicator();
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            GridView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: lstAppData.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.8,
                              ),
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added to align the buttons at the end
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            "Emp. Name : ".text.bold.make(),
                                            const SizedBox(width: 10),
                                            lstAppData[index].employeename.toString()
                                                .text.overflow(TextOverflow.ellipsis)
                                                .make(),
                                          ],
                                        ).paddingSymmetric(vertical: 2, horizontal: 8),
                                        Row(
                                          children: [
                                            "App Type : ".text.bold.make(),
                                            const SizedBox(width: 10),
                                            lstAppData[index].apptype.toString().text.make(),
                                          ],
                                        ).paddingSymmetric(vertical: 2, horizontal: 8),
                                        Row(
                                          children: [
                                            "App. Period : ".text.bold.make(),
                                            const SizedBox(width: 10),
                                            ("${lstAppData[index].fromdt} - ${lstAppData[index].todt}")
                                                .text.make(),
                                          ],
                                        ).paddingSymmetric(vertical: 2, horizontal: 8),
                                        Row(
                                          children: [
                                            "Duration : ".text.bold.make(),
                                            const SizedBox(width: 10),
                                            "${lstAppData[index].dayscount.toString()} Days"
                                                .text.make(),
                                          ],
                                        ).paddingSymmetric(vertical: 2, horizontal: 8),
                                        Row(
                                          children: [
                                            "Remarks : ".text.bold.make(),
                                            const SizedBox(width: 10),
                                            lstAppData[index].appremarks.toString()
                                                .text.overflow(TextOverflow.ellipsis)
                                                .make(),
                                          ],
                                        ).paddingSymmetric(vertical: 2, horizontal: 8),
                                        const SizedBox(height: 4.5),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            showConfirmDialog(
                                              "Are you sure you want to Approve",
                                              lstAppData[index].appid.toString(),
                                              1,
                                            );
                                          },
                                          icon: const Icon(Iconsax.tick_square, color: Colors.green),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          onPressed: () {
                                            showConfirmDialog(
                                              "Are you sure you want to Reject",
                                              lstAppData[index].appid.toString(),
                                              2,
                                            );
                                          },
                                          icon: const Icon(Icons.disabled_by_default_rounded, color: Colors.red),
                                        ),
                                      ],
                                    )
                                  ],
                                ).paddingAll(8)
                                    .box
                                    .shadow
                                    .color(Vx.gray50)
                                    .rounded
                                    .border(color: Colors.grey)
                                    .make();
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
        ),
      ),
    );
  }
}
