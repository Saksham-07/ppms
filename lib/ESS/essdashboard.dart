import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ppms/ESS/attendance/monthly_attendance_view.dart';
import 'package:ppms/ESS/download_payslip/download_payslip.dart';
import 'package:ppms/ESS/leave_approval/screens/leave_approval.dart';
import 'package:ppms/ESS/management_approval/screens/management_approval.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'leave_application/screens/leave_application.dart';
import 'models/pendingapprovalmodel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class EssDashBoard extends StatefulWidget {
  const EssDashBoard({super.key});

  @override
  State<EssDashBoard> createState() => _EssDashBoardState();
}

class _EssDashBoardState extends State<EssDashBoard> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  String pendingLeave = "0", pendingMngtApproval = "0";
  String previousPendingLeave = "0", previousPendingMngtApproval = "0";

  @override
  void initState() {
    super.initState();
    GetePendingForApproval();
  }


  Future<void> GetePendingForApproval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetePendingForApproval';
      String empId = prefs.getString('employeeId').toString();

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      Map<String, dynamic> body = {
        "employeeId": empId
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        var resData = Pendingapprovalmodel.fromJson(data);

        String newPendingLeave = resData.pendingLeaveApproval.toString();
        String newPendingMngtApproval = resData.pendingManagementApp.toString();

        setState(() {
          pendingLeave = newPendingLeave;
          pendingMngtApproval = newPendingMngtApproval;

          // Update previous counts
          previousPendingLeave = newPendingLeave;
          previousPendingMngtApproval = newPendingMngtApproval;
        });
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      rethrow;
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
          'Paramount Products Management System',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildListItem("Management Approval", pendingMngtApproval, () {
            Get.to(() => const ManagementApproval(title: 'ESS-Management Approval'));
          }),
          _buildListItem("Leave Approval", pendingLeave, () {
            Get.to(() => const LeaveApproval(title: 'ESS- Leave Approval'));
          }),
          _buildListItem("Leave Application", null, () {
            Get.to(() => const LeaveApplication(title: "ESS-Leave Application History"));
          }),
          _buildListItem("Monthly Attendance", null, () {
            Get.to(() => const MonthlyAttendance());
          }),
          _buildListItem("Download Payslip", null, () {
            Get.to(() => const DownloadPayslip());
          }),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, String? count, VoidCallback onTap) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16.0), // Reduced margin between items
          padding: const EdgeInsets.all(12.0), // Adjust padding as needed
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0xC212F3B0),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.w400), // Adjust font size as needed
                ),
              ),
            ],
          ).onTap(onTap),
        ),
        if (count != null)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
