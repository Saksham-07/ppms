import 'dart:ffi';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../common/models/monthmodel.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({super.key, required this.title});
  final String title;
  @override
  State<LeaveApplication> createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late TextEditingController _controller;
  String reportingPerson = "", reportingPersonaName = "";

  final List<String> lstYear = [
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
  ];
  String? selectedYear = "2024";
  List<Monthmodel> lstMonth=[];
  
  void addMonthList()
  {
    print("On Function in Month List");
    Monthmodel mnth=new Monthmodel();
    mnth.SetVal("1","January");

    lstMonth.add(mnth);
    print("Month LIst$lstMonth}");
    /*lstMonth.add({"monthNo":"2","monthName":"Feb"} as Monthmodel);
    lstMonth.add({"monthNo":"3","monthName":"Mar"} as Monthmodel);
    lstMonth.add({"monthNo":"4","monthName":"Apr"} as Monthmodel);
    lstMonth.add({"monthNo":"5","monthName":"May"} as Monthmodel);
    lstMonth.add({"monthNo":"6","monthName":"Jun"} as Monthmodel);
    lstMonth.add({"monthNo":"7","monthName":"Jul"} as Monthmodel);
    lstMonth.add({"monthNo":"8","monthName":"Aug"} as Monthmodel);
    lstMonth.add({"monthNo":"9","monthName":"Sep"} as Monthmodel);
    lstMonth.add({"monthNo":"10","monthName":"Oct"} as Monthmodel);
    lstMonth.add({"monthNo":"11","monthName":"Nov"} as Monthmodel);
    lstMonth.add({"monthNo":"12","monthName":"Dec"} as Monthmodel);*/
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPrefs();
    addMonthList();
  }

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    reportingPersonaName = prefs.getString("reportingpersonname").toString();
    setState(() {
      _controller = new TextEditingController(text: reportingPersonaName);
    });
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

          /// Application List
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
            ],
          )
        ],
      ),
    );
  }
}
