import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
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

  void ApproveApp(String appId,String appCatg) async
  {
    //await ApproveRejectApplication(appId,"Approved");
  }
  void RejectApp(String appId,String appCatg) async
  {
    //await ApproveRejectApplication(appId,"Rejected");
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
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 1,
                                        crossAxisSpacing: 1),
                                itemBuilder: (context, index) {
                                  return Column(children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        lstapprovalData[index]
                                            .name
                                            .toString()
                                            .text
                                            .make(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ("${lstapprovalData[index].appType} , ${lstapprovalData[index].unit}")
                                            .text
                                            .make(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        "Dept: ${lstapprovalData[index].department.toString()}"
                                            .text
                                            .make(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        "M. Salary: ${lstapprovalData[index].monthlySalary.toString()}"
                                            .text
                                            .make(),
                                        const SizedBox(
                                          height: 10,
                                        ),

                                        "Inc. Amnt: ${lstapprovalData[index].incAmount.toString()}".text.make(),
                                        Row(
                                          children: [
                                            TextButton(onPressed: (){
                                              ApproveApp(lstapprovalData[index]
                                                  .appId
                                                  .toString(),lstapprovalData[index]
                                                  .appCatg
                                                  .toString());
                                            }, child: "Approve".text.makeCentered()),
                                            const SizedBox(width:10 ,),
                                            TextButton(onPressed: (){
                                              RejectApp(lstapprovalData[index]
                                                  .appId
                                                  .toString(),lstapprovalData[index]
                                                  .appCatg
                                                  .toString());
                                            }, child: "Reject".text.makeCentered()),
                                          ],
                                        ).centered()
                                      ],
                                    )
                                        .box
                                        .width(190)
                                        .rounded
                                        .border(color: Colors.blue)
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
