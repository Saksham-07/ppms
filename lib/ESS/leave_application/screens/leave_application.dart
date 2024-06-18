import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../common/models/monthmodel.dart';
import '../../../common/utils/constants/baseurl.dart';
import '../models/selfleaveapp.dart';
import '../models/yeardto.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key, required this.title});
  final String title;
  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late TextEditingController _controller;
  String reportingPerson = "", reportingPersonaName = "";

  List<YearDto> lstYear = [];
  String? selectedYear = DateTime.now().year.toString();
  List<Monthmodel> lstMonth = [];
  String? selectedMonth="6" /*DateTime.now().month.toString()*/;
  List<Selfleaveapp> lstLeaveApp=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    getYearList();
    getMonthList();
    getLeaveAppList();
    print("Month Number ${DateTime.now().month.toString()}");
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reportingPersonaName = prefs.getString("reportingpersonname").toString();
    setState(() {
      _controller = new TextEditingController(text: reportingPersonaName);
    });
  }

  Future<List<YearDto>> getYearList() async {
    print("Here on Function");
    try {
      lstYear = [];
      const url = TBaseURL.essBaseUrl+'api/HRISM/GetyearList';
      print('Fetching data Year List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };


      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstYear.add(YearDto.fromJson(i));
          });

        }
        print('Response body Year List: ${response.body.toString()}');
        return lstYear;
      } else {
        return lstYear;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  Future<List<Monthmodel>> getMonthList() async {
    print("Here on Function");
    try {
      lstMonth = [];
      const url = TBaseURL.essBaseUrl+'api/HRISM/GetmonthList';
      print('Fetching data Month List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };


      // Send the POST request
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map i in data) {
          setState(() {
            lstMonth.add(Monthmodel.fromJson(i));
          });
        }
        print('Response body MOnth List: ${response.body.toString()}');
        return lstMonth;
      } else {
        return lstMonth;
        print('Failed to load data with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }
  Future<List<Selfleaveapp>> getLeaveAppList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function");
    try {
      lstLeaveApp = [];
      const url = TBaseURL.essBaseUrl+'api/HRISM/GeteLeaveApplicationHistory';
      print('Fetching data Month List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('employeeId').toString(),
        "yearNo": selectedYear.toString(),
        "monthNo": selectedMonth.toString(),
        "appStatus":"All"
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
          setState(() {
            lstLeaveApp.add(Selfleaveapp.fromJson(i));
          });
        }
        print('Response body Self Leave List: ${response.body.toString()}');
        return lstLeaveApp;
      } else {
        return lstLeaveApp;
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
          const SizedBox(
            height: 10,
          ),
          ///Reporting Manager Details
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              "Reporting Manager : ".text.size(14).bold.makeCentered(),
              const CircleAvatar(
                radius: 18,
                child: ClipOval(
                  child: Image(
                    image: AssetImage(
                      "assets/images/image.png",
                    ),
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              reportingPersonaName.text
                  .size(12)
                  .overflow(TextOverflow.ellipsis)
                  .makeCentered()
            ],
          ).box.color(Vx.gray200).rounded.make(),

          /// Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                  items: lstYear
                      .map((YearDto item) => DropdownMenuItem<String>(
                    value: item.yearNo,
                    child: Text(
                      item.yearNo.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
                      .toList(),
                  value: selectedYear,
                  onChanged: (String? value) {
                    setState(() {
                      selectedYear = value;
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
                  items: lstMonth
                      .map((Monthmodel item) => DropdownMenuItem<String>(
                    value: item.monthNo,
                    child: Text(
                      item.monthName.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
                      .toList(),
                  value: selectedMonth,
                  onChanged: (String? value) {
                    setState(() {
                      selectedMonth = value;
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
            ],
          ),
          ////Application List
           Expanded(child:
          Padding(padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [

              ],
            )
          ),
          )
          )

        ],
      ),
    );
  }
}
