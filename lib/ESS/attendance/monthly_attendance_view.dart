import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/models/monthmodel.dart';
import '../../common/utils/constants/baseurl.dart';
import '../leave_application/models/yeardto.dart';
import 'package:http/http.dart' as http;
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
  late Future<List<Attendancemodel>> _attendanceFuture;

  LinkedScrollControllerGroup controllerGroup = LinkedScrollControllerGroup();

  ScrollController? headerScrollControler;
  ScrollController? dataScrollController;
  String? unit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///Initialyze individual Controller to Group
    headerScrollControler = controllerGroup.addAndGet();
    dataScrollController = controllerGroup.addAndGet();

    getYearList();
    getMonthList();
    _attendanceFuture = getAttendanceDetails();
  }

  Future<List<YearDto>> getYearList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstYear = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetyearList';
      if (kDebugMode) {
        print('Fetching data Year List: $url');
      }

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
        if (kDebugMode) {
          print('Response body Year List: ${response.body.toString()}');
        }
        return lstYear;
      } else {
        return lstYear;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Monthmodel>> getMonthList() async {
    if (kDebugMode) {
      print("Here on Function");
    }
    try {
      lstMonth = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetmonthList';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

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
        if (kDebugMode) {
          print('Response body MOnth List: ${response.body.toString()}');
        }
        return lstMonth;
      } else {
        return lstMonth;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Attendancemodel>> getAttendanceDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unit = prefs.getString('unit');
    try {
      lstAttendanceDetails = [];
      const url = '${TBaseURL.essBaseUrl}api/HRISM/GetMonthlyAttendance';
      if (kDebugMode) {
        print('Fetching data Month List: $url');
      }

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
        log('Data : ${response.body.toString()}');
        for (Map i in data) {
          setState(() {
            lstAttendanceDetails.add(Attendancemodel.fromJson(i));
          });
        }
        return lstAttendanceDetails;
      } else {
        return lstAttendanceDetails;
      }
    } catch (e) {
      rethrow;
    }
  }

  int calculateTotalLateMinutes() {

    int totalLateMinutes = 0;
    for (var detail in lstAttendanceDetails) {
      if (detail.status == 'cl1' || detail.status == 'sl1') continue;

      if (detail.latehrs != null) {
        final parts = detail.latehrs!.split(':');
        int hours = 00;
        int minutes = 00;

        if (parts.length >= 2) {
          hours = int.tryParse(parts[0]) ?? 0;
          minutes = int.tryParse(parts[1]) ?? 0;
        } else if (parts.length == 2) {
          if (parts[1] == 'HRS') {
            hours = int.tryParse(parts[0]) ?? 0;
          } else if (parts[1] == 'MINS') {
            minutes = int.tryParse(parts[0]) ?? 0;
          }
        }

        totalLateMinutes += hours * 60 + minutes;
      }
    }
    return totalLateMinutes;
  }

  int calculateTotalEarlyOutMinutes() {
    int totalEarlyOutMinutes = 0;
    for (var detail in lstAttendanceDetails) {
      if (detail.status == 'cl2'||detail.status == 'sl2') continue;

      if (detail.earlyhrs != null) {
        totalEarlyOutMinutes += int.tryParse(detail.earlyhrs!) ?? 0;
      }
    }
    return totalEarlyOutMinutes;
  }

  void _updateAttendanceDetails() {
    setState(() {
      lstAttendanceDetails.clear();
      _attendanceFuture = getAttendanceDetails();
    });
  }
  @override
  Widget build(BuildContext context) {
    final totalLateMinutes = calculateTotalLateMinutes();
    final totalEarlyMinutes = calculateTotalEarlyOutMinutes();

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
            'Monthly Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
    body: SafeArea(
      bottom: false,
      maintainBottomViewPadding: false,
      child: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 2,
                          ),
                          left: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          right: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          top: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
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
                              _updateAttendanceDetails();
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 100,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                            left: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            right: BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            top: BorderSide(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                        ),
                      child: DropdownButtonHideUnderline(
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
                              _updateAttendanceDetails();
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 100,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    if(unit == 'A-55')
                      Padding(
                        padding: const EdgeInsets.only(top : 10.0),
                        child: Column(
                          children: [
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                border: const Border(
                                    bottom: BorderSide(color: Colors.black),
                                ),
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                                color: Colors.white,
                                boxShadow:[
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text('Total Min : 420'),
                              ),
                            ),
                            Container(
                              width: 150,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                              color: Colors.white,
                              boxShadow:[
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 2, // How much the shadow spreads
                                  blurRadius: 3, // How much the shadow blurs
                                  offset: const Offset(0, 3),
                                  // Position of the shadow (x, y)
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text('Total Min Used : ${-totalEarlyMinutes + totalLateMinutes}'),
                            ),
                          ),
                          ],
                        ),
                      )
                  ],
                ),
              Expanded(
              child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
          child: FutureBuilder<List<Attendancemodel>>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
          lstAttendanceDetails = snapshot.data!;
          final totalLateMinutes = calculateTotalLateMinutes();
          final totalEarlyMinutes = calculateTotalEarlyOutMinutes();

          return InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            panAxis: PanAxis.free,
            minScale: 1.0,
            maxScale: 4.0,
            child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.only(top : 12.0, left: 4, right: 4, bottom: 8),
                            child: Table(
                              border: TableBorder.all(color: Colors.black),
                              columnWidths: const {
                                0: FixedColumnWidth(100),
                                1: FixedColumnWidth(60),
                                2: FixedColumnWidth(60),
                                3: FixedColumnWidth(55),
                                4: FixedColumnWidth(55),
                                5: FixedColumnWidth(55),
                                6: FixedColumnWidth(50),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                  ),

                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Date',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'In',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Out',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Status',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Total Hr',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Late In',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Early Out',textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                ...lstAttendanceDetails.map((detail) {
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.date.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.intm.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.outtm.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.status.toString(),textAlign: TextAlign.center,style: TextStyle(
                                          color: detail.status == 'A' || detail.status == 'MS'
                                              ? Colors.red
                                              : detail.status == 'P' || detail.status == 'WO'
                                              ? Colors.green
                                              : Colors.black,
                                        ),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.totalwhrs == '0' ? '' : detail.totalwhrs.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.latehrs == '0' ? '' : detail.latehrs.toString()),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(detail.earlyhrs == '0' ? '' : detail.earlyhrs.toString()),
                                      ),
                                    ],
                                  );
                                }),
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                  ),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Total',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox.shrink(),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox.shrink(),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox.shrink(),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox.shrink(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        totalLateMinutes.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        totalEarlyMinutes.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ),
                    ),
          );
          } else {
            return const Center(child: Text('No data available'));
          }
          },
          ),
              ),
              ),
          ],
          ),
        ),
      ),
    ),
    );
  }
}

