import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../../common/utils/constants/baseurl.dart';

class DownloadPayslipView extends StatefulWidget {
  final String? month;
  final int? year;

  const DownloadPayslipView({super.key, this.month, this.year});

  @override
  State<DownloadPayslipView> createState() => _DownloadPayslipViewState();
}

class _DownloadPayslipViewState extends State<DownloadPayslipView> {
  final GlobalKey _globalKey = GlobalKey();
  List<Map<String, dynamic>> datas = [];
  String? loginId,id;

  @override
  void initState() {
    super.initState();
    _fetchPayslip();

  }

  void _showSearchDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter"),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Type Here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without action
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  id = searchController.text.trim();
                });
                Navigator.pop(context); // Close dialog
                _fetchPayslip(); // Run function with entered text
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAndPrintScreen() async {
    try {
      // Capture the screen as an image
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); // High resolution
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Create a PDF document with the captured image
      final pdf = pw.Document();
      final imageMemory = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imageMemory),
            ); // Center the image in the PDF
          },
        ),
      );

      // Save the PDF to a file
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/payslip.pdf");
      await file.writeAsBytes(await pdf.save());

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved and ready to print: ${file.path}")),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error capturing the screen: $e");
      }
    }
  }


  Future<void> _fetchPayslip() async {
    final prefs = await SharedPreferences.getInstance();
    loginId = prefs.getString('login_id');
    print(id);
    if(id == '' || id == null) {
      setState(() {
        id = loginId;
      });
    }

    final url1 = Uri.parse(
      '${TBaseURL.baseUrl}payslip?user_id=$id&month=${widget.month}&year=${widget.year}',
    );
    final url2 = Uri.parse(
      '${TBaseURL.baseUrl}payslip_earn?user_id=$id&month=${widget.month}&year=${widget.year}',
    );

    print(url1);
    print(url2);

    try {
      // Fetch both API responses in parallel
      final response1 = await http.get(url1);
      final response2 = await http.get(url2);

      // Check for successful responses
      if (response1.statusCode == 200 && response2.statusCode == 200) {
        // Parse JSON responses
        setState(() {
          List<Map<String, dynamic>> data1 = List<Map<String, dynamic>>.from(json.decode(response1.body));
          List<Map<String, dynamic>> data2 = List<Map<String, dynamic>>.from(json.decode(response2.body));

          for (int i = 0; i < data1.length; i++) {
            final combinedData = {...data1[i], ...data2[i]};
            datas.add(combinedData);
          }
        });

        if (kDebugMode) {
          print('Combined Data: $datas');
          log('Combined Data: $datas');
        }

        // You can now use the `datas` list for further processing
      } else {
        if (kDebugMode) {
          print("Failed to fetch data from one or both APIs.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching payslip data: $e");
      }
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
        actions: [
          if(loginId == '0552482' || loginId == '0552297')
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: GestureDetector(
                  onTap: () {
                    _showSearchDialog(context);
                  },
                  child: SizedBox(width: 50,height: 50,child: Text('',style: TextStyle(color: Color(0xFF5FE3D3)),),)
              ),
            ),
        ],
        title: const Text(
          'Payslip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: RepaintBoundary(
      key: _globalKey, // Wrap the entire body to capture
      child: ListView.builder(
        itemCount: datas.length,
        itemBuilder: (context, index) {
          final data = datas[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicWidth(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Text(
                            data['COMPANY_NAME'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${data['COMPANY_ADDRESS']}\nPAYSLIP FOR THE MONTH OF ${data['MONTH_NAME']}, ${data['YEAR_NO']}\nForm-X (See Rule-26)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // Leave Details and Employee Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Leave Details Table
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: const Border(
                                            left: BorderSide(
                                                color: Colors.black,
                                                width: 1.3),
                                            right: BorderSide(
                                                color: Colors.black,
                                                width: 1.3),
                                            top: BorderSide(
                                                color: Colors.black,
                                                width: 1.3),
                                          ),
                                          color: Colors.grey.shade300,
                                        ),
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Text(
                                              'Leave Detail',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      _buildLeaveTable(data),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              // Employee Information Table
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildEmployeeInfoTable(data),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Salary Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Work Details Table
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildWorkDetailsTable(data),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildEarningsTable(data),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Center(
                                              child: Text(
                                                  '${data['AMOUNT_IN_RUP']} : ${data['NET_PAY']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 16))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('This is a sample screen to print'),
                          ElevatedButton(
                            onPressed: _captureAndPrintScreen, // Print the screen
                            child: const Text('Capture & Print Screen'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
    );
  }

  Widget _buildLeaveTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black,width: 1.3),
      children: [
        TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            children: const [
          Center(child: Padding(padding: EdgeInsets.all(0),
            child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
          Padding(
            padding: EdgeInsets.only(top: 8.0,bottom: 8 ,left: 8,right: 8),
            child: Center(child: Text('Total',textAlign: TextAlign.center,style: TextStyle(
                fontWeight: FontWeight.bold
            ),),),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0,bottom: 8,left: 8,right: 8),
            child: Center(child: Text('Used',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0,bottom: 8,left: 8,right: 8),
            child: Center(child: Text('Earn',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0,bottom: 8,left: 8,right: 8),
            child: Center(child: Text('Bal',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
        ]),
        _buildLeaveRow(
          'CL',
          data['CL_OPEN'] ?? '0',
          data['CL_TAKE'] ?? '0',
          '0',
          data['CL_BAL'] ?? '0',
        ),
        _buildLeaveRow(
          'EL',
          data['EL_OPEN'] ?? '0',
          data['EL_TAKE'] ?? '0',
          '0',
          data['EL_BAL'] ?? '0',
        ),
        _buildLeaveRow(
          'SL',
          data['SL_OPEN'] ?? '0',
          data['SL_TAKE'] ?? '0',
          '0',
          data['SL_BAL'] ?? '0',
        ),
      ],
    );
  }

  TableRow _buildLeaveRow(String type, String open, String used, String earned, String balance) {
    return TableRow(children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Center(child: Text(type,style: const TextStyle(
              fontWeight: FontWeight.bold
          ),)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Center(child: Text(open)),
      ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Center(child: Text(used)),
      ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Center(child: Text(earned)),
      ),
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: Center(child: Text(balance)),
      ),
    ]);
  }

  Widget _buildEmployeeInfoTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        _buildInfoRow('CODE', data['PAY_CODE'], 'BANK NAME', data['BANK_NAME']),
        _buildInfoRow('NAME', data['EMP_NAME'], 'A/C No', data['AC_NO']),
        _buildInfoRow('FATHER\'S/HUSB', data['FH_NAME'], 'PF No', data['EPF_NO']),
        _buildInfoRow('DESIGNATION', data['DESIGNATION'], 'UAN', data['UAN_NO']),
        _buildInfoRow('DEPT', data['DEPARTMENT'], 'PAY MODE', data['PAY_MODE']),
        _buildInfoRow('DOJ', data['DOJ'], 'ESI NO', data['ESIC_NO']),
        _buildInfoRow('PAN', data['PAN_NO'], 'AADHAR NO', data['AADHAR_NO']),
      ],
    );
  }

  TableRow _buildInfoRow(String leftTitle, String leftValue, String rightTitle, String rightValue) {
    return TableRow(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(leftTitle,style: const TextStyle(
              fontWeight: FontWeight.bold
          ),),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(leftValue),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(rightTitle,style: const TextStyle(
            fontWeight: FontWeight.bold
        ),),
      ),
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(rightValue),
      ),
    ]);
  }

  Widget _buildWorkDetailsTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black,width: 1.3),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        _buildWorkDetailRow('WD', data['WD']),
        _buildWorkDetailRow('WO', data['WO']),
        _buildWorkDetailRow('HD', data['HD']),
        _buildWorkDetailRow('CL', data['CL']),
        _buildWorkDetailRow('EL', data['EL']),
        _buildWorkDetailRow('SL', data['SL']),
        _buildWorkDetailRow('ML', data['ML']),
        _buildWorkDetailRow('CO', data['CO']),
        _buildWorkDetailRow('ESI', data['ESI_D']),
        _buildWorkDetailRow('Pay Days', data['ESI_D']),
      ],
    );
  }

  TableRow _buildWorkDetailRow(String title, String value) {
    return TableRow(children: [
      Container(
        color: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.only(top: 8,bottom: 8,left: 15,right: 15),
          child: Text(title,textAlign: TextAlign.center,style: const TextStyle(
              fontWeight: FontWeight.bold
          ),),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8,bottom: 8,left: 15,right: 15),
        child: Text(value,textAlign: TextAlign.right,),
      ),
    ]);
  }

  Widget _buildEarningsTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black,width: 1.3),
      // defaultColumnWidth: IntrinsicColumnWidth(),
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(90),
        2: FixedColumnWidth(90),
        3: FixedColumnWidth(90),
        4: FixedColumnWidth(90),
        5: FixedColumnWidth(130),
      },
      children: [
        TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('-',style: TextStyle(
              fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Salary',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Earnign',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Arrear',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Total',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Deduction',style: TextStyle(
                fontWeight: FontWeight.bold
            ),)),
          ),
        ]),
        _salaryRow(data['ALL1'], data['RATE1'], data['EARN1'], data['ARR1'], data['TotalEarn1'], data['DALT1'], data['DED1']),
        _salaryRow(data['ALL2'], data['RATE2'], data['EARN2'], data['ARR2'], data['TotalEarn2'], data['DALT2'], data['DED2']),
        _salaryRow(data['ALL3'], data['RATE3'], data['EARN3'], data['ARR3'], data['TotalEarn3'], data['DALT3'], data['DED3']),
        _salaryRow(data['ALL4'], data['RATE4'], data['EARN4'], data['ARR4'], data['TotalEarn4'], data['DALT4'], data['DED4']),
        _salaryRow(data['ALL5'], data['RATE5'], data['EARN5'], data['ARR5'], data['TotalEarn5'], data['DALT5'], data['DED5']),
        _salaryRow(data['ALL6'], data['RATE6'], data['EARN6'], data['ARR6'], data['TotalEarn6'], data['DALT6'], data['DED6']),
        _salaryRow('Total', data['GROSS_RATE'], data['GROSS_EARN'], data['ArrTotal'], data['TotalEarnSum'], '', data['TOTAL_DEDUCTIONS']),
      ],
    );
  }

  TableRow _salaryRow(String allowance, String rate, String earn, String arrear, String totalEarn, String deductionAlt, String deduction) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(allowance,style: const TextStyle(
          fontWeight: FontWeight.bold
        ),)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(rate)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(earn)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(arrear)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(totalEarn)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text('$deductionAlt      $deduction')),
      ),
    ]);
  }
}