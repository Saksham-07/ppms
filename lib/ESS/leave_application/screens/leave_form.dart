import 'dart:convert';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ppms/ESS/leave_application/screens/leave_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/services.dart';

import '../../../common/utils/constants/baseurl.dart';

class LeaveForm extends StatefulWidget {
  const LeaveForm({super.key, required this.title, required this.reqType});
  final String title;
  final String reqType;
  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  TimeOfDay selectedIntTime = TimeOfDay.now();
  TimeOfDay selectedOuttTime = TimeOfDay.now();
  DateTimeRange selectedDates =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  var outputFormat = DateFormat('dd-MM-yyyy');
  var outputFormatymd = DateFormat('yyyy-MM-dd');
  final List<String> lstReqType = [
    'OD',
    'Leave',
    'Mispunch',
    'WFH',
  ];
  String? selectedReqType;
  List<bool> isHalfOrFullDay = [true, false];
  List<bool> isFirstOrSecondHalf = [true, false];
  final List<String> lstVisitLocation = ['Outside Unit'];
  String? selectedVisitLocation;

  final List<String> lstmispunchReason = ['Forgot to punch','Finger punching issue due to Mehndi / cut','Other'];
  String? selectedmisPunchReason;

  var daysCount = 0.0;
  bool isHalfDay = false;

  ////Text Input Controller
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final reasonController = TextEditingController();
  final visitLocationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedReqType = widget.reqType.toString();
    calculateTotalDays(selectedDates.start, selectedDates.end);
    isHalfDay = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _disposeFormInput();
  }

  _disposeFormInput() {
    addressController.dispose();
    mobileController.dispose();
    reasonController.dispose();
    visitLocationController.dispose();
  }

  calculateTotalDays(DateTime start, DateTime end) {
    setState(() {
      daysCount = end.difference(start).inDays + 1.0;
      print("Total Days ${daysCount}");
    });
  }

  submitApplication() {
    if ((selectedReqType == "Leave" ||
            selectedReqType == "OD" ||
            selectedReqType == "WFH") &&
        (reasonController.text == null ||
            reasonController.text.trim().isEmpty)) {
      ShowDialog("Please enter purpose", "Warning");
      return;
    }
    if (selectedReqType == "OD" &&
        (selectedVisitLocation == null || selectedVisitLocation!.isEmpty)) {
      ShowDialog("Please select visit location Type", "Warning");
      return;
    }
    if (selectedReqType == "OD" &&
        (visitLocationController.text == null ||
            visitLocationController.text.isEmpty)) {
      ShowDialog("Please enter visit location details", "Warning");
      return;
    }
    if (selectedReqType == "Mispunch" && (selectedmisPunchReason == null ||
        selectedmisPunchReason!.isEmpty))
      {
        ShowDialog("Please select mispunch reason", "Warning");
        return;
      }
    SaveApplication();
    //ShowDialog("Application Submitted successfully", "Success");
  }

  Future<void> SaveApplication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url =
          TBaseURL.essBaseUrl + 'api/HRISM/SendLeaveApplicationApproval';
      print('Approving Application Approval of Subbordinate: $url');

      // Define the headers and body
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      String hulfOrFullDay = "";
      String firstOrSecondHalf = "0";
      double finalDaysCount = daysCount;
      if ((selectedReqType == "Leave" || selectedReqType == "OD")) {
        if (isHalfOrFullDay[1] == true) {
          finalDaysCount = 0.5;
          hulfOrFullDay = "Half Day";
          if (isFirstOrSecondHalf[0] == true) {
            firstOrSecondHalf = "First Half";
          } else {
            firstOrSecondHalf = "Second Half";
          }
        } else {
          hulfOrFullDay = "Full Day";
        }
      }
      String inTime="";
      String outTime="";
      if (selectedReqType == "Mispunch")
      {
          if(isFirstOrSecondHalf[0]==true)
            {
              firstOrSecondHalf = "First Half";
              inTime=("${selectedIntTime.hour} : ${selectedIntTime.minute}");
            }
          else
            {
              firstOrSecondHalf = "Second Half";
              outTime=("${selectedOuttTime.hour} : ${selectedOuttTime.minute}");
            }
      }


      Map<String, dynamic> body = {
        "employeeId": prefs.getString('employeeId').toString(),
        "employeeCode": prefs.getString('login_id').toString(),
        "unitId": prefs.getString('unitId').toString(),
        "appType": selectedReqType.toString(),
        "fromDt": outputFormatymd.format(selectedDates.start).toString(),
        "toDt": outputFormatymd.format(selectedDates.end).toString(),
        "daysCount": finalDaysCount,
        "fullOrHalf": hulfOrFullDay,
        "dayPart": firstOrSecondHalf,
        "inTime": inTime,
        "outTime": outTime,
        "appRemarks": reasonController.text.toString(),
        "address": addressController.text.toString(),
        "mobileNo": mobileController.text.toString(),
        "appStatus": "Sent for Approval",
        "visitLocation": visitLocationController.text.toString(),
        "visitLocationType": selectedVisitLocation.isNotEmptyAndNotNull?selectedVisitLocation.toString():"",
        "misPunchRemarks": selectedmisPunchReason.isNotEmptyAndNotNull?selectedmisPunchReason.toString():"",
      };
      print("Req Body ${jsonEncode(body)}");
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print(response.body);

      if (response.statusCode == 200) {
        ShowDialog(response.body, "Success");
        //Get.to(()=>LeaveApplication(title: "ESS-Leave Application"));
      } else {
        ShowDialog(response.body, "Error");
      }
    } catch (e) {
      throw e;
      print('Error fetching data: $e');
    }
  }

  ShowDialog(String Message, String Title) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      if (Title == "Success") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LeaveApplication(
                                  title: "ESS-Leave Application History")),
                        ).then((value) => setState(() {}));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Close"))
              ],
              title: Text(Title),
              contentPadding: const EdgeInsets.all(20),
              content: Text(Message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => (Get.to(
                () => const LeaveApplication(title: "ESS-Leave Application"))),
            icon: const Icon(Iconsax.arrow_left),
          ),
          automaticallyImplyLeading: false,
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
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 50,
                      ),
                      Flexible(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(
                                'Select Type',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              items: lstReqType
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedReqType,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedReqType = value;
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
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                  ////Date Range
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: TextField(
                          enabled: true,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
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
                                      calculateTotalDays(selectedDates.start,
                                          selectedDates.end);
                                    });
                                  }
                                },
                                icon: const Icon(Iconsax.calendar)),
                            labelText: outputFormat
                                .format(selectedDates.start)
                                .toString(),
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Flexible(
                        child: TextField(
                          enabled: true,
                          decoration: InputDecoration(
                              prefixIcon: IconButton(
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
                                        calculateTotalDays(selectedDates.start,
                                            selectedDates.end);
                                      });
                                    }
                                  },
                                  icon: const Icon(Iconsax.calendar)),
                              labelText: outputFormat
                                  .format(selectedDates.end)
                                  .toString(),
                              labelStyle:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ////Toggle Button for Half Day and full day
                  Visibility(
                    visible: ((selectedReqType == "Leave" ||
                            selectedReqType == "OD" ||
                            selectedReqType == "WFH") &&
                        daysCount == 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          fillColor: Colors.lightBlue,
                          color: Colors.black,
                          selectedColor: Colors.white,
                          renderBorder: true,
                          borderRadius: BorderRadius.circular(15.0),
                          borderColor: Colors.blue,

                          // ToggleButtons uses a List<bool> to track its selection state.
                          isSelected: isHalfOrFullDay,
                          // ToggleButtons uses a List<Widget> to build its children.
                          children: const <Widget>[
                            Text(
                              "        Full Day      ",
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              "       Half Day      ",
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                          onPressed: (int newIndex) {
                            setState(() {
                              for (int index = 0;
                                  index < isHalfOrFullDay.length;
                                  index++) {
                                if (index == newIndex) {
                                  isHalfOrFullDay[index] = true;
                                } else {
                                  isHalfOrFullDay[index] = false;
                                }
                              }
                              if (isHalfOrFullDay[1] == true) {
                                isHalfDay = true;
                              } else {
                                isHalfDay = false;
                              }
                              print("Full or Half Day ${isHalfOrFullDay}");
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ////Toggle Button for First Half or Second Half
                  Visibility(
                    visible:
                        (isHalfDay == true || selectedReqType == "Mispunch"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          fillColor: Colors.lightBlue,
                          color: Colors.black,
                          selectedColor: Colors.white,
                          renderBorder: true,
                          borderRadius: BorderRadius.circular(15.0),
                          borderColor: Colors.blue,

                          // ToggleButtons uses a List<bool> to track its selection state.
                          isSelected: isFirstOrSecondHalf,
                          // ToggleButtons uses a List<Widget> to build its children.
                          children: const <Widget>[
                            Text(
                              "        First Half      ",
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              "       Second Half      ",
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                          onPressed: (int newIndex) {
                            setState(() {
                              for (int index = 0;
                                  index < isFirstOrSecondHalf.length;
                                  index++) {
                                if (index == newIndex) {
                                  isFirstOrSecondHalf[index] = true;
                                } else {
                                  isFirstOrSecondHalf[index] = false;
                                }
                              }
                              print("First/Second Half ${isFirstOrSecondHalf}");
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  ///Address During Leave
                  Visibility(
                    visible: (selectedReqType == "Leave"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: Card(
                            color: Vx.gray100,
                            child: TextField(
                              controller: addressController,
                              maxLines: 3, //or null
                              decoration: const InputDecoration.collapsed(
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                                hintText: "Address During leave period",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: (selectedReqType == "Leave"),
                    child: const SizedBox(
                      height: 10,
                    ),
                  ),

                  ///Mobile Number
                  Visibility(
                    visible: (selectedReqType == "Leave"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: Card(
                            color: Vx.gray100,
                            child: TextField(
                              controller: mobileController,
                              maxLines: 2, //or null
                              decoration: const InputDecoration.collapsed(
                                hintText: "Mobile Number",
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),

                              keyboardType: TextInputType.number,
                              inputFormatters: [], // Only numbers can be entered
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: (selectedReqType == "Leave"),
                    child: const SizedBox(
                      height: 10,
                    ),
                  ),

                  /////Visit Location Type
                  Visibility(
                    visible:
                        (selectedReqType == "OD" || selectedReqType == "WFH"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Select Location Type',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: lstVisitLocation
                                    .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedVisitLocation,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedVisitLocation = value;
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
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible:
                        (selectedReqType == "OD" || selectedReqType == "WFH"),
                    child: const SizedBox(
                      height: 20,
                    ),
                  ),

                  /// Visit Location Details
                  Visibility(
                    visible:
                        (selectedReqType == "OD" || selectedReqType == "WFH"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: Card(
                            color: Vx.gray100,
                            child: TextField(
                              controller: visitLocationController,
                              maxLines: 2, //or null
                              decoration: const InputDecoration.collapsed(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.start,
                                hintText: "Visit Location (To be specified)",
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible:
                        (selectedReqType == "OD" || selectedReqType == "WFH"),
                    child: const SizedBox(
                      height: 20,
                    ),
                  ),

                  ///Reason
                  Visibility(
                    visible: (selectedReqType == "Leave" ||
                        selectedReqType == "OD" ||
                        selectedReqType == "WFH"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: Card(
                            color: Vx.gray100,
                            child: TextField(
                              controller: reasonController,
                              maxLines: 3, //or null
                              decoration: const InputDecoration.collapsed(
                                hintText: "Purpose",
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: (selectedReqType == "Mispunch"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Visibility(
                          visible: (isFirstOrSecondHalf[0]==true),
                          child: Text(
                            "In Time ${selectedIntTime.hour} : ${selectedIntTime.minute}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (isFirstOrSecondHalf[0]==true),
                          child: IconButton(
                              onPressed: () async {
                                final TimeOfDay? timeOfDay = await showTimePicker(
                                  context: context,
                                  initialTime: selectedIntTime,
                                  initialEntryMode: TimePickerEntryMode.dial,
                                );
                                if (timeOfDay != null) {
                                  setState(() {
                                    selectedIntTime = timeOfDay;
                                  });
                                }
                              },
                              icon: const Icon(
                                Iconsax.clock,
                                color: Colors.blue,
                              )),
                        ),
                        Visibility(
                          visible: (isFirstOrSecondHalf[1]==true),
                          child: Text(
                            "Out Time ${selectedOuttTime.hour} : ${selectedOuttTime.minute}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (isFirstOrSecondHalf[1]==true),
                          child: IconButton(
                              onPressed: () async {
                                final TimeOfDay? timeOfDay = await showTimePicker(
                                  context: context,
                                  initialTime: selectedOuttTime,
                                  initialEntryMode: TimePickerEntryMode.dial,
                                );
                                if (timeOfDay != null) {
                                  setState(() {
                                    selectedOuttTime = timeOfDay;
                                  });
                                }
                              },
                              icon: const Icon(
                                Iconsax.clock,
                                color: Colors.blue,
                              )),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  /////MIS Punch Reason
                  Visibility(
                    visible:
                    (selectedReqType == "Mispunch"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Reason for Mispunch',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: lstmispunchReason
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                    .toList(),
                                value: selectedmisPunchReason,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedmisPunchReason = value;
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
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),

                  ///Submit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          submitApplication();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: const Color(0xFFFFFFFF)),
                        child: const Text("Send for Approval"),
                      )
                    ],
                  )
                ],
              ),
            ),
          ))
        ]));
  }
}
