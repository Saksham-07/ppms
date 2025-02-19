import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:ppms/ESS/download_payslip/test.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;

class DownloadPayslip extends StatefulWidget {
  const DownloadPayslip({super.key});

  @override
  State<DownloadPayslip> createState() => _DownloadPayslipState();
}

class _DownloadPayslipState extends State<DownloadPayslip> {
  int? _selectedMonth;
  int? _selectedYear;

  final List<Map<String, dynamic>> _months = [
    {'name': 'January', 'value': 01},
    {'name': 'February', 'value': 02},
    {'name': 'March', 'value': 03},
    {'name': 'April', 'value': 04},
    {'name': 'May', 'value': 05},
    {'name': 'June', 'value': 06},
    {'name': 'July', 'value': 07},
    {'name': 'August', 'value': 08},
    {'name': 'September', 'value': 09},
    {'name': 'October', 'value': 10},
    {'name': 'November', 'value': 11},
    {'name': 'December', 'value': 12},
  ];

  final List<Map<String, dynamic>> datas = [
    {
      "COMPANY_NAME": "ABC Corp",
      "COMPANY_ADDRESS": "123, Corporate Avenue, City",
      "MONTH_NAME": "September",
      "YEAR_NO": "2024",
      "CL_OPEN": "10",
      "CL_TAKE": "2",
      "CL_BAL": "8",
      "EL_OPEN": "15",
      "EL_TAKE": "3",
      "EL_BAL": "12",
      "SL_OPEN": "7",
      "SL_TAKE": "1",
      "SL_BAL": "6",
      "PAY_CODE": "EMP123",
      "BANK_NAME": "Bank XYZ",
      "EMP_NAME": "John Doe",
      "AC_NO": "1234567890",
      "FH_NAME": "John's Father",
      "EPF_NO": "EPF12345",
      "DESIGNATION": "Software Engineer",
      "UAN_NO": "UAN987654",
      "DEPARTMENT": "IT",
      "PAY_MODE": "Bank Transfer",
      "DOJ": "01-Jan-2020",
      "ESIC_NO": "ESI12345",
      "PAN_NO": "PAN12345",
      "AADHAR_NO": "123456789012",
      "WD": "20",
      "WO": "4",
      "HD": "1",
      "CL": "2",
      "EL": "3",
      "SL": "1",
      "ML": "0",
      "CO": "1",
      "ESI_D": "200",
      "PAY_DAYS": "25",
      "ALL1": "Basic + DA",
      "RATE1": "10000",
      "EARN1": "10000",
      "ARR1": "0",
      "TotalEarn1": "1000000",
      "DALT1": "PF",
      "DED1": "1000000",
      "ALL2": "HRA",
      "ALL3": "Tran Allow",
      "ALL4": "Other",
      "ALL5": "C.E.A",
      "ALL6": "SPI Allow",
      "ALL7": "Total",
      "RATE2": "5000000",
      "EARN2": "5000000",
      "ARR2": "0",
      "TotalEarn2": "5000000",
      "DALT2": "ESI",
      "DED2": "500",
      "GROSS_RATE": "1500000",
      "GROSS_EARN": "1500000",
      "ArrTotal": "0",
      "TotalEarnSum": "1500000",
      "TOTAL_DEDUCTIONS": "1500000",
      "AMOUNT_IN_RUP": "Twenty Lack Twenty Seven Thousand Twenty Eight",
      "NET_PAY": "1350000",
    },
  ];

  void navigateToReport(BuildContext context) {
    if (kDebugMode) {
      print('Navigating to report');
    }
    String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadPayslipView(
          month: formattedMonth,
          year: _selectedYear,
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    for (final data in datas) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.ListView.builder(
              itemCount: datas.length,
              itemBuilder: (context, index) {
                final data = datas[index];
                return pw.Container(
                  padding: const pw.EdgeInsets.all(10.0),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  child: pw.Column(
                    children: [
                      // Header
                      pw.Text(
                        data['COMPANY_NAME'],
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        '${data['COMPANY_ADDRESS']}\nPAYSLIP FOR THE MONTH OF ${data['MONTH_NAME']}, ${data['YEAR_NO']}\nForm-X (See Rule-26)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 20),

                      // Leave Details and Employee Info
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Leave Details Table
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(10.0),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black, width: 1.5),
                              ),
                              child: pw.Column(
                                children: [
                                  pw.Container(
                                    width: double.infinity,
                                    decoration: const pw.BoxDecoration(
                                      color: PdfColors.grey300,
                                      border: pw.Border(
                                        left: pw.BorderSide(color: PdfColors.black, width: 1.3),
                                        right: pw.BorderSide(color: PdfColors.black, width: 1.3),
                                        top: pw.BorderSide(color: PdfColors.black, width: 1.3),
                                      ),
                                    ),
                                    child: pw.Center(
                                      child: pw.Padding(
                                        padding: const pw.EdgeInsets.all(6.0),
                                        child: pw.Text(
                                          'Leave Detail',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
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
                          pw.SizedBox(width: 20),
                          // Employee Information Table
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(8.0),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black, width: 1.5),
                              ),
                              child: pw.Column(
                                children: [
                                  _buildEmployeeInfoTable(data),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 20),

                      // Salary Details
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Work Details Table
                          pw.Expanded(
                            flex: 1,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(8.0),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black, width: 1.5),
                              ),
                              child: pw.Column(
                                children: [
                                  _buildWorkDetailsTable(data),
                                ],
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          // Earnings Table
                          pw.Expanded(
                            flex: 4,
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(8.0),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.black, width: 1.5),
                              ),
                              child: pw.Column(
                                children: [
                                  _buildEarningsTable(data),
                                  pw.Container(
                                    width: double.infinity,
                                    child: pw.Padding(
                                      padding: const pw.EdgeInsets.all(24.0),
                                      child: pw.Center(
                                        child: pw.Text(
                                          '${data['AMOUNT_IN_RUP']} : ${data['NET_PAY']}',
                                          style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
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
                );
              },
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/payslip.pdf");
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    await OpenFile.open(file.path);

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildLeaveTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.3),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Type'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Total'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Used'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Earn'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Bal'),
            ),
          ],
        ),
        _buildLeaveRow('CL', data['CL_OPEN'], data['CL_TAKE'], '0', data['CL_BAL']),
        _buildLeaveRow('EL', data['EL_OPEN'], data['EL_TAKE'], '0', data['EL_BAL']),
        _buildLeaveRow('SL', data['SL_OPEN'], data['SL_TAKE'], '0', data['SL_BAL']),
      ],
    );
  }

  pw.TableRow _buildLeaveRow(String type, String open, String used, String earned, String balance) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(type)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(open)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(used)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(earned)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(balance)),
      ],
    );
  }

  pw.Widget _buildEmployeeInfoTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.3),
      children: [
        _buildInfoRow('Bank Name', data['BANK_NAME']),
        _buildInfoRow('Account No', data['AC_NO']),
        _buildInfoRow('Employee Name', data['EMP_NAME']),
        _buildInfoRow('Father\'s/Husband\'s Name', data['FH_NAME']),
        _buildInfoRow('Designation', data['DESIGNATION']),
        _buildInfoRow('Department', data['DEPARTMENT']),
        _buildInfoRow('DOJ', data['DOJ']),
        _buildInfoRow('ESIC No', data['ESIC_NO']),
        _buildInfoRow('PAN No', data['PAN_NO']),
        _buildInfoRow('Aadhar No', data['AADHAR_NO']),
      ],
    );
  }

  pw.TableRow _buildInfoRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(value)),
      ],
    );
  }

  pw.Widget _buildWorkDetailsTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.3),
      children: [
        _buildWorkRow('WD', data['WD']),
        _buildWorkRow('WO', data['WO']),
        _buildWorkRow('HD', data['HD']),
        _buildWorkRow('CL', data['CL']),
        _buildWorkRow('EL', data['EL']),
        _buildWorkRow('SL', data['SL']),
        _buildWorkRow('ML', data['ML']),
        _buildWorkRow('CO', data['CO']),
      ],
    );
  }

  pw.TableRow _buildWorkRow(String type, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(type)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(value)),
      ],
    );
  }

  pw.Widget _buildEarningsTable(Map<String, dynamic> data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 1.3),
      children: [
        _buildEarningsRow('Earnings', 'Rate', 'Earn', 'Arrears', 'Total Earn', 'DALT', 'Ded'),
        _buildEarningsRow(data['ALL1'], data['RATE1'], data['EARN1'], data['ARR1'], data['TotalEarn1'], data['DALT1'], data['DED1']),
      ],
    );
  }


  pw.TableRow _buildEarningsRow(String earnings, String rate, String earn, String arrears, String totalEarn, String dalt, String ded) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(earnings)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(rate)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(earn)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(arrears)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(totalEarn)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(dalt)),
        pw.Padding(padding: const pw.EdgeInsets.all(6.0), child: pw.Text(ded)),
      ],
    );
  }



  // await OpenFile.open(file.path);final output = await getTemporaryDirectory();
    // final file = File("${output.path}/payslip.pdf");
    // await file.writeAsBytes(await pdf.save());
    //
    // // Open the PDF file
    // await OpenFile.open(file.path);

  final List<int> _years = List.generate(
      DateTime.now().year - 2020, (index) => 2021 + index);

  Future<void> _fetchPayslip() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString('login_id');
    if (_selectedMonth != null && _selectedYear != null) {
      setState(() {
      });

      String formattedMonth = _selectedMonth!.toString().padLeft(2, '0');
      final url = Uri.parse('http://172.16.2.171:8000/tools/pay_slip_new/');
      if (kDebugMode) {
        print(formattedMonth);
        print(_selectedYear);
        print(url);
      }

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // Get the directory to save the file
          Directory? directory;
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory();
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          }

          if (directory != null) {
            String filePath = '${directory.path}/payslip_${_selectedYear}_$formattedMonth.pdf';

            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            await OpenFile.open(filePath);

            if (kDebugMode) {
              print('Payslip downloaded and opened successfully');
            }
          }
        } else {
          if (kDebugMode) {
            print('Failed to fetch payslip: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      } finally {
        setState(() {
        });
      }
    } else {
      if (kDebugMode) {
        print('Please select both month and year');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    ),
                    value: _selectedMonth,
                    items: _months.map((month) {
                      return DropdownMenuItem<int>(
                        value: month['value'],
                        child: Text(month['name']),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    ),
                    value: _selectedYear,
                    items: _years.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green
                    ),
                    onPressed: _fetchPayslip,
                    onLongPress: ()=> _generatePdf(context),
                    child: const Text('Download',style: TextStyle(color: Colors.white),),
                  ),
                ),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent
                    ),
                    onPressed: ()=> navigateToReport(context),
                    child: const Text('View',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}