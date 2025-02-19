import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RunProcedures extends StatefulWidget {
  const RunProcedures({super.key});

  @override
  State<RunProcedures> createState() => _RunProceduresState();
}

class _RunProceduresState extends State<RunProcedures> {
  String? _loginId;
  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _selectedUnitCode;
  late List<dynamic> globalData = [];
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  DateTime _selectedFromDate = DateTime.now();
  DateTime _selectedToDate = DateTime.now();
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _fromDateController.text = _formatDate(_selectedFromDate);
    _toDateController.text = _formatDate(_selectedToDate);
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate,
      firstDate: DateTime(2023, 9, 16), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
    );
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
        _fromDateController.text = _formatDate(_selectedFromDate);
        print(_fromDateController.text);
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedToDate,
      firstDate: DateTime(2023, 9, 16), // 16-Sep-2024
      lastDate: DateTime.now(), // Current date
    );
    if (picked != null && picked != _selectedToDate) {
      setState(() {
        _selectedToDate = picked;
        _toDateController.text = _formatDate(_selectedToDate);
        print(_toDateController.text);
      });
    }
  }

  Future<void> _runProcedure(String type) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final String apiUrl =
        'http://14.142.248.34:10008/get_procedure?type=$type&from_date=${_fromDateController.text}&to_date=${_toDateController.text}';
    print(apiUrl);

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 600));

      print(response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Access the first element in the list and get 'type'
        if (responseData.isNotEmpty && responseData[0] is Map) {
          final String type = responseData[0]['type']?.toString() ?? '';
          print(type);
          _showSuccessDialog(type);
        } else {
          _showErrorDialog('Unexpected data format');
        }
      } else {
        // Show error dialog if there was an issue
        _showErrorDialog('Failed to run procedure');
      }
    } on TimeoutException catch (_) {
      _showErrorDialog('Request timed out. Please try again later.');
    } catch (e) {
      _showErrorDialog('Some error occurred while running the procedure');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }


  void _showSuccessDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Procedure Status'),
          content: Text('$type Procedure run successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    // return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
          'Procedures',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            controller: _fromDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'From Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              suffixIcon: Icon(Icons.date_range_outlined),
                            ),
                            onTap: () {
                              _selectFromDate(context);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0), // Space between fields
                      Expanded(
                        child: Container(
                          height: 40,
                          child: TextFormField(
                            controller: _toDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'To Date',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              suffixIcon: Icon(Icons.date_range_outlined),
                            ),
                            onTap: () {
                              _selectToDate(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSimpleButton('Employee Cost', Colors.blue, () {
                  _runProcedure('EmployeeCost');
                },),
                _buildSimpleButton('Cutting & Finish', Colors.green,  ()
                {
                  _runProcedure('CutFinishPnL');
                }
                ,),
                _buildSimpleButton('Stitching', Colors.red, () {
                  _runProcedure('StitchPnL');
                },),
                _buildSimpleButton('Auto Allocation', Colors.orange, () {
                  _runProcedure('StitchPnLAuto');
                },),
                _buildSimpleButton('Runday', Colors.indigo, () {
                  _runProcedure('Runday');
                },),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSimpleButton(String label, Color color, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextButton(
          onPressed: () => onTap(),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
