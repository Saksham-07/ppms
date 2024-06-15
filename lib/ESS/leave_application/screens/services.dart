import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TServices
{
  static Future<void> getApplicationApproval(DateTime dFrom,DateTime Dto,String EmployeeId,String AppStatus) async {
    try {
      const url = 'http://172.16.0.123:12008/api/HRISM/GetApplicationApprovalSub';
      print('Fetching data from Application Approval of Subbordinate: $url');

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
        print('Data received: $data');
        return data;
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}