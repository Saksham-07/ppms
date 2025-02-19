import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ppms/ESS/leave_application/screens/leave_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

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
  TextEditingController  addressController = TextEditingController();
  TextEditingController  mobileController = TextEditingController();
  TextEditingController  reasonController = TextEditingController();
  TextEditingController  visitLocationController = TextEditingController();
  String appBarTitle = '';

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
      if (kDebugMode) {
        print("Total Days $daysCount");
      }
    });
  }

  submitApplication() {
    if ((selectedReqType == "Leave" ||
            selectedReqType == "OD" ||
            selectedReqType == "WFH") &&
        (reasonController.text.trim().isEmpty)) {
      ShowDialog("Please enter purpose", "Warning");
      return;
    }
    if (selectedReqType == "OD" &&
        (selectedVisitLocation == null || selectedVisitLocation!.isEmpty)) {
      ShowDialog("Please select visit location Type", "Warning");
      return;
    }
    if (selectedReqType == "OD" &&
        (visitLocationController.text.isEmpty)) {
      ShowDialog("Please enter visit location details", "Warning");
      return;
    }
    if (selectedReqType == "Mispunch" && (selectedmisPunchReason == null ||
        selectedmisPunchReason!.isEmpty))
      {
        ShowDialog("Please select mispunch reason", "Warning");
        return;
      }
    saveApplication();
    //ShowDialog("Application Submitted successfully", "Success");
  }

  Future<void> saveApplication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      const url =
          '${TBaseURL.essBaseUrl}api/HRISM/SendLeaveApplicationApproval';
      if (kDebugMode) {
        print('Approving Application Approval of Subbordinate: $url');
      }

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
      if (kDebugMode) {
        print("Req Body ${jsonEncode(body)}");
      }
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print(response.body);
      }

      if (response.statusCode == 200) {
        ShowDialog(response.body, "Success");
        //Get.to(()=>LeaveApplication(title: "ESS-Leave Application"));
      } else {
        ShowDialog(response.body, "Error");
      }
    } catch (e) {
      rethrow;
    }
  }

  ShowDialog(String message, String title) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      if (title == "Success") {
                        Navigator.of(context).pop(true);
                        Navigator.of(context).pop(true);
                      } else {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text("Close"))
              ],
              title: Text(title),
              contentPadding: const EdgeInsets.all(20),
              content: Text(message),
            )
    );
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
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 2,
        ),
        body: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          panAxis: PanAxis.free,
          minScale: 1.0,
          maxScale: 4.0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        Flexible(
                          child:Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                            child: Container(
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
                              child: Visibility(
                                visible: false,
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
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),

                      ],
                    ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        enabled: true,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () async {
                              final DateTimeRange? dateTimeRange = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(3000),
                              );
                              if (dateTimeRange != null) {
                                setState(() {
                                  selectedDates = dateTimeRange;
                                  calculateTotalDays(selectedDates.start, selectedDates.end);
                                });
                              }
                            },
                            icon: const Icon(Iconsax.calendar),
                          ),
                          labelText: 'From Date',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: outputFormat.format(selectedDates.start).toString(),
                          hintStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        enabled: true,
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () async {
                              final DateTimeRange? dateTimeRange = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(3000),
                              );
                              if (dateTimeRange != null) {
                                setState(() {
                                  selectedDates = dateTimeRange;
                                  calculateTotalDays(selectedDates.start, selectedDates.end);
                                });
                              }
                            },
                            icon: const Icon(Iconsax.calendar),
                          ),
                          label: const Text('To Date'),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          hintText: outputFormat.format(selectedDates.end).toString(),
                          hintStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: ((selectedReqType == "Leave" ||
                                  selectedReqType == "OD" ||
                                  selectedReqType == "WFH") &&
                              daysCount == 1.0),
                          child: SizedBox(height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ToggleButtons(
                                  fillColor: Colors.greenAccent,
                                  color: Colors.black,
                                  selectedColor: Colors.white,
                                  renderBorder: true,
                                  borderRadius: BorderRadius.circular(9.0),
                                  borderColor: Colors.black26,

                                  // ToggleButtons uses a List<bool> to track its selection state.
                                  isSelected: isHalfOrFullDay,
                                  // ToggleButtons uses a List<Widget> to build its children.
                                  children: const <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                                      child: Text(
                                        "Full Day",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                                      child: Text(
                                        "Half Day",
                                        style: TextStyle(fontSize: 15),
                                      ),
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
                                      if (kDebugMode) {
                                        print("Full or Half Day $isHalfOrFullDay");
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        ////Toggle Button for First Half or Second Half
                        Visibility(
                          visible:
                              (isHalfDay == true || selectedReqType == "Mispunch"),
                          child: SizedBox(height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 10,
                                  width: 20,
                                ),
                                ToggleButtons(
                                  fillColor: Colors.greenAccent,
                                  color: Colors.black,
                                  selectedColor: Colors.white,
                                  renderBorder: true,
                                  borderRadius: BorderRadius.circular(9.0),
                                  borderColor: Colors.black26,

                                  // ToggleButtons uses a List<bool> to track its selection state.
                                  isSelected: isFirstOrSecondHalf,
                                  // ToggleButtons uses a List<Widget> to build its children.
                                  children: const <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                                      child: Text(
                                        "First Half",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                                      child: Text(
                                        "Second Half",
                                        style: TextStyle(fontSize: 15),
                                      ),
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
                                      if (kDebugMode) {
                                        print("First/Second Half $isFirstOrSecondHalf");
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                              color: const Color(0xFFF2F8F7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: addressController,
                                  maxLines: 2, //or null
                                  decoration: const InputDecoration.collapsed(
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    hintText: "Address During leave period",
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
                              color: const Color(0xFFF2F8F7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: mobileController,
                                  maxLines: 1, //or null
                                  decoration: const InputDecoration.collapsed(
                                    hintText: "Mobile Number",
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                  keyboardType: TextInputType.number,
                                  inputFormatters: const [], // Only numbers can be entered
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

                    /////Visit Location Type
                    Visibility(
                      visible:
                          (selectedReqType == "OD" || selectedReqType == "WFH"),
                      child: Padding(
                        padding: const EdgeInsets.only(left : 18.0 , right: 18),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add some padding
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true, // Makes dropdown expand within container
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
                                  width: double.infinity, // Set width to match container
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                              color: const Color(0xFFF2F8F7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: visitLocationController,
                                  maxLines: 1, //or null
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
                              color: const Color(0xFFF2F8F7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: TextField(
                                  controller: reasonController,
                                  maxLines: 2, //or null
                                  decoration: const InputDecoration.collapsed(
                                    hintText: "Purpose",
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Visibility(
                      visible: (selectedReqType == "Mispunch"),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 25,
                          ),
                          Visibility(
                            visible: (isFirstOrSecondHalf[0]==true),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: Colors.grey),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 2,
                                    color: Colors.greenAccent,
                                    offset: Offset(
                                      0,
                                      2,
                                    ),
                                    spreadRadius: 0.2,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0,right: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "In Time ${selectedIntTime.hour} : ${selectedIntTime.minute}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30,
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
                                            color: Colors.black,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (isFirstOrSecondHalf[1]==true),
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: Colors.grey),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 2,
                                      color: Colors.greenAccent,
                                      offset: Offset(
                                        0,
                                        2,
                                      ),
                                      spreadRadius: 0.2,
                                    )
                                  ],
                                ),
                              child: Padding(
                                padding: const EdgeInsets.only(left : 6.0, right: 6),
                                child: Row(
                                  children: [
                                    Text(
                                      "Out Time ${selectedOuttTime.hour} : ${selectedOuttTime.minute}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 30,
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
                                            color: Colors.black,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                          Container (
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: const BorderRadius.all(Radius.circular(8))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14.0,left: 14.0),
                              child: SizedBox(
                                width: 300,
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
                              backgroundColor: const Color(0xC23EEF39),
                              foregroundColor: const Color(0xFFFFFFFF)),
                          child: const Text("Send for Approval"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ))
          ]),
        ));
  }
}
