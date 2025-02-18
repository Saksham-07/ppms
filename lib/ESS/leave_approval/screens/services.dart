import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TServices
{
  static Future<void> getApplicationApproval(DateTime dFrom,DateTime dto,String employeeId,String appStatus) async {
    try {
      const url = 'http://172.16.0.123:12008/api/HRISM/GetApplicationApprovalSub';
      if (kDebugMode) {
        print('Fetching data from Application Approval of Subbordinate: $url');
      }

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode":"9970",
        "dFrom":"2024-06-11",
        "dTo":"2024-06-22",
        "appStatus":"All"
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Data received: $data');
        }
        return data;
      } else {
        if (kDebugMode) {
          print('Failed to load data with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }
}