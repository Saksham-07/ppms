import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../models/appaprovalnewmodel.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key, required this.title});

  final String title;

  @override
  State<LeaveApplication> createState() => _LeaveApplication();
}

class _LeaveApplication extends State<LeaveApplication> {
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

  void ApproveLeaveApp(String appId) async
  {
    await ApproveRejectApplication(appId,"Approved");
  }
  void RejectLeaveApp(String appId) async
  {
    await ApproveRejectApplication(appId,"Rejected");
  }
  Future<void> ApproveRejectApplication(String appId,String appStatus) async {
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
      ShowDialog(response.body);
      if (response.statusCode == 200) {

          setState(() {
            lstAppData=[];
            selectedValue="Applied";
            selectedValue="All";
          });
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }
  ShowDialog(String Message)
  {
    showDialog(context: context, builder: (context)=>AlertDialog(
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: const Text("Close"))
      ],
      title: const Text("Application Approval"),
      contentPadding: const EdgeInsets.all(20),
      content: Text(Message) ,
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
          Row(
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
          ),
          Expanded(
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
                                crossAxisCount: 2,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1),
                        itemBuilder: (context, index) {
                          return Column(children:
                          [
                            Column(
                              children: [
                                lstAppData[index]
                                    .employeename
                                    .toString()
                                    .text
                                    .make(),
                                const SizedBox(height:10 ,),
                                lstAppData[index]
                                    .apptype
                                    .toString()
                                    .text
                                    .make(),
                                const SizedBox(height:10 ,),
                                ("${lstAppData[index]
                                    .fromdt} -- ${lstAppData[index]
                                    .todt}")
                                    .text
                                    .make(),
                                const SizedBox(height:10 ,),
                                Row(
                                  children: [
                                    TextButton(onPressed: (){
                                          ApproveLeaveApp(lstAppData[index]
                                              .appid
                                              .toString());
                                    }, child: "Approve".text.makeCentered()),
                                    const SizedBox(width:10 ,),
                                    TextButton(onPressed: (){
                                      RejectLeaveApp(lstAppData[index]
                                          .appid
                                          .toString());
                                    }, child: "Reject".text.makeCentered()),
                                  ],
                                ).centered()
                              ],
                            ).box.rounded.border(color: Colors.blue).make()


                          ]);
                        })
                  ],
                );
              }
            },
         )
          )
        ],
      ),
    );
  }
}
