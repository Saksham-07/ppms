import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ppms/ESS/management_approval/models/managementapprovalformdto.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:http/http.dart' as http;

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
  State<ManagementApprovalForm> createState() => _ManagementApprovalFormState(appId: this.appId,appCatg: this.appCatg,updateByType: this.updateByType);
}

class _ManagementApprovalFormState extends State<ManagementApprovalForm> {

  String? appId;
  String? appCatg;
  String? updateByType;

  _ManagementApprovalFormState({this.appId,this.appCatg,this.updateByType});

  var FormData;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getManagementApproval();
  }

  Future<Managementapprovalformdto> getManagementApproval() async {

    print("Here on Function");
    try {

      const url = TBaseURL.essBaseUrl+'api/HRISM/GetManagementApprovalAppById';
      print('Fetching data management Approval : $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "appId": appId,
        "appType":appCatg
      };

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

        var approvalData=Managementapprovalformdto.fromJson(data);
        setState(() {
          FormData=approvalData;
        });
        print('Response body: ${approvalData}');
        return FormData;
      } else {
        return FormData;
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
        body:  const Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child:
                    Column(
                      children: [
                        Row(
                          children: [

                          ],
                        )
                      ],
                    )
                  )))
        ]));
  }
}
