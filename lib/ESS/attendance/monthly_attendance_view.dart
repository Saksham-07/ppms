import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/models/monthmodel.dart';
import '../../common/utils/constants/baseurl.dart';
import '../essdashboard.dart';
import '../leave_application/models/yeardto.dart';
import 'package:http/http.dart' as http;

import 'models/TTableHelper.dart';
import 'models/attendancemodel.dart';

class MonthlyAttendance extends StatefulWidget {
  const MonthlyAttendance({super.key});

  @override
  State<MonthlyAttendance> createState() => _MonthlyAttendanceState();
}

class _MonthlyAttendanceState extends State<MonthlyAttendance> {
  List<YearDto> lstYear = [];
  String? selectedYear = DateTime.now().year.toString();
  List<Monthmodel> lstMonth = [];
  String? selectedMonth = DateTime.now().month.toString();
  List<Attendancemodel> lstAttendanceDetails = [];

  LinkedScrollControllerGroup controllerGroup = LinkedScrollControllerGroup();

  ScrollController? headerScrollControler;
  ScrollController? dataScrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///Initialyze individual Controller to Group
    headerScrollControler = controllerGroup.addAndGet();
    dataScrollController = controllerGroup.addAndGet();

    getYearList();
    getMonthList();
    getAttendanceDetails();
  }

  Future<List<YearDto>> getYearList() async {
    print("Here on Function");
    try {
      lstYear = [];
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetyearList';
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
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetmonthList';
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

  Future<List<Attendancemodel>> getAttendanceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Here on Function");
    try {
      lstAttendanceDetails = [];
      const url = TBaseURL.essBaseUrl + 'api/HRISM/GetMonthlyAttendance';
      print('Fetching data Month List: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      Map<String, dynamic> body = {
        "employeeCode": prefs.getString('login_id').toString(),
        "yearNo": selectedYear.toString(),
        "monthNo": selectedMonth.toString(),
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
            lstAttendanceDetails.add(Attendancemodel.fromJson(i));
          });
        }
        print('Response body Self Leave List: ${response.body.toString()}');
        return lstAttendanceDetails;
      } else {
        return lstAttendanceDetails;
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
            onPressed: () => (Get.to(() => const EssDashBoard())),
            icon: const Icon(Iconsax.arrow_left),
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "ESS-Monthly Attendance",
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            height: 10,
          ),

          /// Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Year',
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
                      getAttendanceDetails();
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
                    'Select Month',
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
                      getAttendanceDetails();
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
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Row(
                          children: [
                            DataTable(
                                columns: TTableDataHelper.kTableColumnsList
                                    .getRange(0, 1)
                                    .map((e) {
                                  return DataColumn(
                                    label: SizedBox(
                                      width: e.width,
                                      child: Text(e.title ?? ''),
                                    ),
                                  );
                                }).toList(),
                                headingRowColor: WidgetStateProperty.all(Colors.green),
                                dataRowColor:
                                WidgetStateProperty.all(Colors.green.shade100),
                                rows: List.generate(lstAttendanceDetails.length, (index) {
                                  return DataRow(
                                      cells: [DataCell(SizedBox(
                                        width: TTableDataHelper.kTableColumnsList.first.width,
                                        child: Text(lstAttendanceDetails[index].date.toString()),
                                      ))]);
                                })),
                            Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: dataScrollController,
                                  child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                                      dataRowColor:
                                      WidgetStateProperty.all(Colors.blue.shade50),
                                      columns: TTableDataHelper.kTableColumnsList
                                          .getRange(1,
                                          TTableDataHelper.kTableColumnsList.length)
                                          .map((e) {
                                        return DataColumn(
                                          label: SizedBox(
                                            width: e.width,
                                            child: Text(e.title ?? ''),
                                          ),
                                        );
                                      }).toList(),
                                      rows: List.generate(lstAttendanceDetails.length, (index) {
                                        return DataRow(cells: [
                                          DataCell(SizedBox(child: Text(lstAttendanceDetails[index].intm.toString()),width: TTableDataHelper.kTableColumnsList[1].width,)),
                                          DataCell(SizedBox(child: Text(lstAttendanceDetails[index].outtm.toString()), width: TTableDataHelper.kTableColumnsList[2].width,)),
                                          DataCell(SizedBox(child: Text(lstAttendanceDetails[index].status.toString()), width: TTableDataHelper.kTableColumnsList[3].width,)),
                                          DataCell(SizedBox(child: Text(lstAttendanceDetails[index].totalwhrs.toString()), width: TTableDataHelper.kTableColumnsList[4].width,)),
                                        ]);
                                      })),
                                )),

                          ],
                        ),
                      ),
                      TableHeader()
                    ],
                  )))
        ]));
  }

  Widget TableHeader() {
    return Row(
      children: [
        DataTable(
            columns: TTableDataHelper.kTableColumnsList.getRange(0, 1).map((e) {
              return DataColumn(
                label: SizedBox(
                  width: e.width,
                  child: Text(e.title ?? ''),
                ),
              );
            }).toList(),
            headingRowColor: WidgetStateProperty.all(Colors.green),
            dataRowColor: WidgetStateProperty.all(Colors.green.shade100),
            rows: []),
        Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: headerScrollControler,
              child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                  dataRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                  columns: TTableDataHelper.kTableColumnsList
                      .getRange(1, TTableDataHelper.kTableColumnsList.length)
                      .map((e) {
                    return DataColumn(
                      label: SizedBox(
                        width: e.width,
                        child: Text(e.title ?? ''),
                      ),
                    );
                  }).toList(),
                  rows: []),
            )),

      ],
    );
  }

}
