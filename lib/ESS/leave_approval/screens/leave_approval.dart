import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
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

  /*@override
  void initState() {
    super.initState();
    print("Called Init State");
    Future.delayed(const Duration(milliseconds: 10), () {
      getApplicationApprovalSub();
      print('Data Initialyzed: $lstAppData');

    });


  }*/

  void ApproveLeaveApp(String appId) async {
    await ApproveRejectApplication(appId, "Approved");
  }

  void RejectLeaveApp(String appId) async {
    await ApproveRejectApplication(appId, "Rejected");
  }

  Future<void> ApproveRejectApplication(String appId, String appStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      lstAppData = [];
      const url =
          'http://172.16.0.123:12008/api/HRISM/ApproveRejectApplication';
      print('Approving Application Approval of Subbordinate: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
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
        ShowDialog(response.body,1);
        setState(() {
          lstAppData = [];
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
                      if(appType==1) {
                        ApproveLeaveApp(appId);
                        Navigator.of(context).pop();
                      }
                      else if(appType==2)
                      {
                        RejectLeaveApp(appId);
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
          title: const Text("Confirmation Leave Approval"),
          contentPadding: const EdgeInsets.all(20),
          content: Text(Message),
        ));
  }

  Future<List<Appaprovalnewmodel>> getApplicationApprovalSub() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function");
    try {
      lstAppData = [];
      const url =
          'http://172.16.0.123:12008/api/HRISM/GetApplicationApprovalSub';
      print('Fetching data from Application Approval of Subbordinate: $url');

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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        final DateTimeRange? dateTimeRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                        );
                        if (dateTimeRange != null) {
                          setState(() {
                            selectedDates = dateTimeRange;
                          });
                        }
                      },
                      child: const Text("Select Date")),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      "${outputFormat.format(selectedDates.start)} - ${outputFormat.format(selectedDates.end)}"),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              DropdownButtonHideUnderline(
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
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),*/
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: FutureBuilder(
                future: getApplicationApprovalSub(),
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
                            itemCount: lstAppData.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: 1,
                                    crossAxisSpacing: 8,
                                    childAspectRatio:1.94),
                            itemBuilder: (context, index) {
                              return Column(children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        "Emp. Name : ".text.bold.make(),
                                        const SizedBox(
                                          width: 35,
                                        ),
                                        lstAppData[index]
                                            .employeename
                                            .toString()
                                            .text.overflow(TextOverflow.ellipsis)
                                            .make(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4.5,
                                    ),
                                    Row(
                                      children: [
                                        "App Type : ".text.bold.make(),
                                        const SizedBox(
                                          width: 50,
                                        ),
                                        lstAppData[index]
                                            .apptype
                                            .toString()
                                            .text
                                            .make()
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4.5,
                                    ),
                                    Row(
                                      children: [
                                        "App. Period : ".text.bold.make(),
                                        const SizedBox(
                                          width: 33,
                                        ),
                                        ("${lstAppData[index].fromdt} - ${lstAppData[index].todt}")
                                            .text
                                            .make(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4.5,
                                    ),
                                    Row(
                                      children: [
                                        "Duration : ".text.bold.make(),
                                        const SizedBox(
                                          width: 55,
                                        ),
                                        "${lstAppData[index].dayscount.toString()} Days"
                                            .text
                                            .make(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 4.5,
                                    ),
                                    Row(
                                      children: [
                                        "Remarks : ".text.bold.make(),
                                        const SizedBox(
                                          width: 53,
                                        ),
                                        lstAppData[index].appremarks.toString()
                                            .text.overflow(TextOverflow.ellipsis)
                                            .make(),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            showConfirmDialog("Are you sure want to Approve",lstAppData[index]
                                                .appid
                                                .toString(),1);
                                            /*ApproveLeaveApp(lstAppData[index]
                                                .appid
                                                .toString());*/
                                          },
                                          icon: const Image(
                                            image: AssetImage(
                                                "assets/images/ess_images/ButtonIcons/TickIcon.png"),
                                            height: 40,
                                            width: 40,
                                          ),
                                          /*child:
                                                "Approve".text.makeCentered()*/
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showConfirmDialog("Are you sure want to Reject",lstAppData[index]
                                                .appid
                                                .toString(),2);
                                           /* RejectLeaveApp(lstAppData[index]
                                                .appid
                                                .toString());*/
                                          },
                                          icon: const Image(
                                            image: AssetImage(
                                                "assets/images/ess_images/ButtonIcons/CrossIcon.png"),
                                            height: 25,
                                            width: 25,
                                          ),
                                          /*child:
                                                "Reject".text.makeCentered()*/
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
                },
              ),
            ),
          ))
        ],
      ),
    );
  }
}
