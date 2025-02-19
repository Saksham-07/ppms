import 'dart:async';
import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ppms/Allocation/report.dart';
import 'package:ppms/Allocation/scan_qr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/utils/constants/baseurl.dart';
import '../ExtraFunction/uuid.dart';
import '../Installation/dio.dart';

class Allocation extends StatefulWidget {
  const Allocation({super.key});

  @override
  _AllocationState createState() => _AllocationState();
}

class _AllocationState extends State<Allocation> {
  List<Map<String, dynamic>> scannedDataList = [];
  List<Map<String, String>> dropdownData3 = [];
  List<String> dropdownData5 = [];
  String? selectedValue3;
  String? selectedLineID;
  String? selectedValue4;
  String? selectedValue5;
  String? userId;
  String? fetchedTailorName;
  int? fetchedTailorDept;
  int? fetchedTailorSDept;
  int? fetchedTailorDesg;
  String? fetchedTailorUnit;
  String? fetchedTailorCode;
  String? paycodes;
  String? prevLine;
  bool _isAllocation = false;
  bool _isR = false;
  String appVersion = '';
  String fileName = '';
  Timer? _versionTimer;

  TextEditingController textController = TextEditingController();

  List<String> _dropDownOptions = [];
  Map<String, String> _unitMap = {};
  String? _selectedUnit;
  String? _loginId;
  String? previousValue;
  bool isOTSelected = false;
  String _allocMnpwr = '';
  String _totalMnpwr = '';
  bool isData = false;
  String uuid = '';

  @override
  void initState() {
    super.initState();
    getUid();
    _versionTimer = Timer.periodic(const Duration(minutes: 30), (timer)
    {
      _fetchAppVersion();
    });
    previousValue = selectedValue3;
    _fetchDropDownOptions();
    _getUserIdFromSharedPreferences();
    _getSelectedUnitFromSharedPreferences();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_selectedUnit != null) {
        _fetchTableData(_unitMap[_selectedUnit]!);
        // Fetch pending allocation data
        if(selectedLineID != null){
          if (kDebugMode) {
            print(selectedLineID);
          }
          _isData(selectedLineID);
        }
      }
    });
    checkForAllocate();
  }

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  @override
  void dispose() {
    _versionTimer?.cancel();
    super.dispose();
  }

  //*-*-*-*-*-*-*-*-*-*-*-*-Update code Start-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      print(appVersion);
      getVersion(appVersion);
    });
  }

  Future<void> getVersion(String version) async {
    try {
      final response = await http.get(Uri.parse('http://14.142.248.34:10008/version?version=$version'));
      print('http://14.142.248.34:10008/version?version=$version');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          bool isVersionValid = data[0]['IsActive'];
          if (!isVersionValid) {
            await getFile();
            _showUpdateDialog();  // Only show dialog if fileName is available
          }
        } else {
          if (kDebugMode) {
            print('No data found');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to check version with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getFile() async {
    try {
      final response = await http.get(Uri.parse('http://14.142.248.34:10008/version_file_path'));
      if (kDebugMode) {
        print(response);
      }
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data[0]['VersionFile']);
        }
        fileName = data[0]['VersionFile'] ?? ''; // Set fileName if available
      } else {
        if (kDebugMode) {
          print('Failed to fetch file with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching file: $e');
      }
    }
  }

  void _showUpdateDialog() {
    String apkUrl = 'http://14.142.248.34:10004/assets/media/$fileName';
    print(apkUrl);
    if (kDebugMode) {
      print(apkUrl);
    }
    if (kDebugMode) {
      print("Apk: $apkUrl");
    }
    Uri appStoreUrl = Uri.parse('https://apps.apple.com/app/ppms-ios/id6504535323');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text('Please update the app to the latest version.'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (Platform.isAndroid) {
                    downloadApk(context, apkUrl);
                  } else if (Platform.isIOS) {
                    if (await canLaunchUrl(appStoreUrl)) {
                      await launchUrl(appStoreUrl);
                    } else {
                      if (kDebugMode) {
                        print('Could not launch $appStoreUrl');
                      }
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  //*-*-*-*-*-*-*-*-*-*-*-*-Update Code End-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

  Future<void> _isData(String ?line) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    int ot = isOTSelected ? 1 : 0;
    String? unit = _unitMap[_selectedUnit]!;

    if(ot == 0)
    {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/chk_line_verification?line_id=$line&ot=$ot&unit=$unit'));
        if (kDebugMode) {
          print('http://14.142.248.34:10008/chk_line_verification?line_id=$line&ot=$ot&unit=$unit');
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.isNotEmpty) {
            setState(() {
            isData = true;
            if (kDebugMode) {
              print('isData $isData');
            }
            });
          }
          else{
            isData = false;
          }
        } else {
          setState(() {
            isData = false;
            if (kDebugMode) {
              print('$isData iieir');
            }
          });
          throw Exception('Failed to load table data');
        }
      }
      catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    else{
      isData = false;
      if (kDebugMode) {
        print('isData $isData');
      }
    }
  }

  Future<void> _fetchTableData(String unitCode) async {
    const int maxRetries = 5;
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/total_alloc?unit=$unitCode&dated='));

        if (kDebugMode) {
          print('http://14.142.248.34:10008/total_alloc?unit=$unitCode&dated=');
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.isNotEmpty) {
            setState(() {
              _allocMnpwr = data[0]['AllocMnpwr'].toString();
              _totalMnpwr = data[0]['TotalMnpwr'].toString();

              if (kDebugMode) {
                print('AllocMnpwr: $_allocMnpwr, TotalMnpwr: $_totalMnpwr');
              }
            });
          }
          success = true;
        } else {
          throw Exception('Failed to load table data');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }
      await Future.delayed(const Duration(seconds: 1)); // Optional delay between retries
    }
  }

  Future<void> _fetchDropDownOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}unit?type=permissions&user=$_loginId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _dropDownOptions = ['----'] + data.map((e) => e['UnitShortCode'].toString()).toList();
        _unitMap = {for (var item in data) item['UnitShortCode'].toString(): item['UnitCode'].toString()};

        if (_dropDownOptions.contains(selectedValue4)) {
          _selectedUnit = selectedValue4;
        } else {
          _selectedUnit = _dropDownOptions.isNotEmpty ? _dropDownOptions[0] : null;
        }
        saveUnitMapToSharedPreferences(_unitMap);
      });
      if (_selectedUnit != null) {
        _fetchTableData(_unitMap[_selectedUnit]!); // Fetch pending allocation data
      }
    } else {
      if (kDebugMode) {
        print('Failed to load options');
      }
    }
  }

  Future<void> fetchLineDataFromApi(String unit) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;
    int ot = isOTSelected ? 1 : 0;

    while (retryCount < maxRetries && !success) {
      try {
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/line?unit=$unit&ot=$ot'));
        // final response = await http.get(Uri.parse('http://172.16.10.11:8001/line?unit=$unit&ot=$ot'));
        if (kDebugMode) {
          print('http://14.142.248.34:10008/line?unit=$unit&ot=$ot');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData3 = jsonResponse.map((item) => {
              'LineName': item['LineName'].toString(),
              'LineID': item['LineId'].toString(),
            }).toList();
          });
          success = true; // Data successfully fetched, exit loop
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('Error fetching data (Attempt $retryCount): $e');
        }
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }

      await Future.delayed(const Duration(seconds: 2)); // Optional delay between retries
    }
  }

  Future<void> fetchTailorDataFromApi(String unit) async {
    const int maxRetries = 5; // Number of retry attempts
    int retryCount = 0;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        String yesterday = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
        final response = await http.get(Uri.parse('http://14.142.248.34:10008/tailor?unit=$unit&date=$yesterday'));
        if (kDebugMode) {
          print('http://14.142.248.34:10008/tailor?unit=$unit&date=$yesterday');
        }

        if (response.statusCode == 200) {
          List<dynamic> jsonResponse = json.decode(response.body);
          setState(() {
            dropdownData5 = jsonResponse.map((item) {
              String paycode = item['PAY_CODE'].toString();
              String name = item['NAME'].toString();
              return '$paycode[$name]';
            }).toList();
          });
          success = true; // Data successfully fetched, exit loop
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        retryCount++;
        if (kDebugMode) {
          print('Error fetching data (Attempt $retryCount): $e');
        }
        if (retryCount >= maxRetries) {
          throw Exception('Unable to fetch data after $retryCount attempts');
        }
      }

      await Future.delayed(const Duration(seconds: 2)); // Optional delay between retries
    }
  }


  Future<void> _getUserIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullUserId = prefs.getString('name');
    setState(() {
      userId = (fullUserId != null && fullUserId.length > 15)
          ? fullUserId.substring(0, 15)
          : fullUserId;
    });
  }

  Future<void> _getSelectedUnitFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedUnit = prefs.getString('selectedUnit');
    setState(() {
      selectedValue4 = selectedUnit ?? '-';
      if (selectedUnit != null) {
        dropdownData3.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          fetchLineDataFromApi(selectedUnit);
        });
        fetchLineDataFromApi(selectedUnit);
        Future.delayed(const Duration(milliseconds: 500), () {
          fetchTailorDataFromApi(selectedUnit);
        });
      }
    });
  }

  Future<void> fetchTailorDataByCode(String code) async {
    try {
      final response = await http.get(Uri.parse('http://14.142.248.34:10008/tailor_data?code=$code'));
      // final response = await http.get(Uri.parse('http://172.16.10.11:8000/tailor_data?code=$code'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          var data = jsonResponse[0];
          setState(() {
            paycodes = data['PAY_CODE'];
            if (kDebugMode) {
              print(paycodes);
            }
            fetchedTailorCode = data['NAME'];
            if (kDebugMode) {
              print(fetchedTailorCode);
            }
            fetchedTailorName = data['EMP_CODE'];
            if (kDebugMode) {
              print(fetchedTailorName);
            }
            fetchedTailorDept = data['DEPT'];
            if (kDebugMode) {
              print(fetchedTailorDept);
            }
            fetchedTailorSDept = data['SDEPT'];
            fetchedTailorDesg = data['DESG'];
            fetchedTailorUnit = data['UnitShortCode'];
          });
        } else {
          if (kDebugMode) {
            print('No data found');
          }
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }


  void _addSelectedData() {
    if (selectedValue5 == null) {
      _showTailorSelectionAlert();
      return;
    }
    bool ot = isOTSelected;

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (selectedValue5 != null && selectedValue3 != null && selectedValue4 != null) {
      fetchTailorDataByCode(selectedValue5!).then((_) {
        if (fetchedTailorName != null && !_isNameDuplicate(fetchedTailorName!)) {
          if (fetchedTailorUnit == selectedValue4) {
            checkDataInApi(todayDate,paycodes!).then((alreadyExists) {
              if (alreadyExists) {
                if(ot){
                  _showDataExistsAlert(() {
                    _addDataToList();
                  });
                }
                else {
                  if (_isAllocation) {
                    _showDataExistsAlert(() {
                      _addDataToList();
                    });
                  }
                  else {
                    _showRights();
                  }
                }
              } else {
                _addDataToList();
              }
            });
          } else {
            _showUnitMismatchAlert();
          }
        }
      });
    } else if (selectedValue3 == null) {
      _showLineSelectionAlert();
    }
  }

  void _navigateToScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QR()),
    );
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool ot = isOTSelected;

    if (result != null) {
      await fetchTailorDataByCode(result);

      if(selectedValue3 != null) {
        if (fetchedTailorUnit == selectedValue4) {
          fetchTailorDataByCode(selectedValue3!).then((_) {
            if (fetchedTailorName != null &&
                !_isNameDuplicate(fetchedTailorName!)) {
              checkDataInApi(todayDate, paycodes!).then((alreadyExists) {
                if (alreadyExists) {
                  if(ot){
                    _showDataExistsAlert(() {
                      _addDataToList();
                    });
                  }
                  else {
                    if (_isAllocation) {
                      _showDataExistsAlert(() {
                        _addDataToList();
                      });
                    }
                    else {
                      _showRights();
                    }
                  }
                } else {
                  _addDataToList();
                }
              });
            }
          });
        } else {
          _showUnitMismatchAlert();
        }
      }
    }
  }

  void navigateToReport(BuildContext context) {
    if (kDebugMode) {
      print('Navigating to report');
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Report(selectedUnit: _selectedUnit),
      ),
    );
  }

  void _showDataExistsAlert(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Already Present'),
          content: const Text('The data you are trying to add already exists. Do you want to update it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the onConfirm callback to add the data
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showRights() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('You do not have rights to modify data'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _addDataToList() {

    bool ot = isOTSelected;
    if (kDebugMode) {
      print(ot);
    }
    setState(() {
      scannedDataList.add({
        'tailor': fetchedTailorCode!,
        'line': selectedValue3!,
        'LineID': selectedLineID!,
        'unit': fetchedTailorUnit!,
        'UnitCode': _unitMap[fetchedTailorUnit] ?? '',
        'EMP_CODE': fetchedTailorName!,
        'DEPT': fetchedTailorDept!,
        'SDEPT': fetchedTailorSDept!,
        'DESG': fetchedTailorDesg!,
        'PayCode': paycodes!,
      });
    });
  }

  void _showLineSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Line Not Selected'),
          content: const Text('Please select a line before adding.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTailorSelectionAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tailor Not Selected'),
          content: const Text('Please select a tailor before adding.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showUnitMismatchAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unit Mismatch'),
          content: const Text('User unit does not match the Selected unit. Please select the appropriate unit.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _isNameDuplicate(String name) {
    bool isDuplicate = scannedDataList.any((element) => element['EMP_CODE'] == name);

    if (isDuplicate) {
      _showDuplicateAlert();
    }

    return isDuplicate;
  }

  void _showDuplicateAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Duplicate Data"),
          content: const Text("This data is already present."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearList() {
    setState(() {
      scannedDataList.clear();
    });
  }
  Future<void> _sendDataToApi(String tailor, String fy, String pay, String lineID, String unitCode, int dept, int sDept, int desg, String emp) async {

    final response = await http.get(Uri.parse(
        'http://14.142.248.34:10008/allocate?line=$lineID&fy=$fy&empC=$emp&payC=$pay'
            '&empN=$tailor&dept=$dept&sDept=$sDept&desg=$desg&unit=$unitCode&created=$_loginId&device_id=$uuid'));

    if (kDebugMode) {
      print('Request URL: http://14.142.248.34:10008/allocate?line=$lineID&fy=$fy'
          '&empC=$emp&payC=$pay&empN=$tailor&dept=$dept&sDept=$sDept'
          '&desg=$desg&unit=$unitCode&created=$_loginId&device_id=$uuid');
    }

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Data sent successfully: Tailor: $tailor, LineID: $lineID, Unit: $unitCode');
      }
    } else {
      if (kDebugMode) {
        print('Failed to send data: ${response.body}');
      }
    }
  }

  Future<void> checkForAllocate() async {
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = 'http://14.142.248.34:10008/base?user=$loginId&module=kpi&page=LineAllocation';

    if (kDebugMode) {
      print('http://14.142.248.34:10008/base?user=$loginId&module=kpi&page=LineAllocation');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // If all items are 'R', hide the buttons
        bool allR = data.every((item) => item['shortname'] == 'R');
        _isR = !allR; // _isAllocation will be true if there is any 'M' or other than 'R'
        _isAllocation = data.any((item) => item['shortname'] == 'M');
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _sendDataToUpdateApi(String lineID, String pay, String date, bool isOt, String otLine) async {
    final url = isOt
        ? 'http://14.142.248.34:10008/update_line_alloc?type=2&line=&otLine=$lineID&paycode=$pay&date=$date&modified=$_loginId'
        : 'http://14.142.248.34:10008/update_line_alloc?type=1&line=$lineID&otLine=&paycode=$pay&date=$date&modified=$_loginId';

    if (kDebugMode) {
      print('Request URL: $url');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Data updated successfully: LineID: $lineID, Paycode: $pay');
      }
    } else {
      if (kDebugMode) {
        print('Failed to update data: ${response.body}');
      }
    }
  }

  String getFinancialYear(DateTime date) {
    int year = date.year;
    if (date.isBefore(DateTime(year, 4, 1))) {
      return '${(year - 1)}-$year';
    } else {
      return '$year-${(year + 1)}';
    }
  }

  Future<bool> checkDataInApi(String date, String paycode) async {
    final response = await http.get(Uri.parse('http://14.142.248.34:10008/check_line_alloc?date=$date&paycode=$paycode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (data is List && data.isNotEmpty) {
        prevLine = data[0]['LineId'].toString();
        if (kDebugMode) {
          print(prevLine);
        }
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('Failed to check data');
    }
  }
  bool isLoading = false;

  Future<void> _allocate() async {
    setState(() {
      isLoading = true;
    });

    String fy = getFinancialYear(DateTime.now());
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool ot = isOTSelected;

    int successCount = 0; // Track successful allocations
    int failureCount = 0; // Track failed allocations

    for (var data in scannedDataList) {
      try {
        // Check if the data is present in the first API
        bool isDataPresent = await checkDataInApi(todayDate, data['PayCode']);

        if (kDebugMode) {
          print('Is data present: $isDataPresent');
        }

        if (isDataPresent) {
          await _sendDataToUpdateApi(
            data['LineID'],
            data['PayCode']!,
            todayDate,
            ot,
            data['LineID'],
          );
          successCount++; // Increment success for update
        } else {
          if (kDebugMode) {
            print('Allocating');
          }
          await _sendDataToApi(
            data['tailor']!,
            fy,
            data['PayCode'],
            data['LineID']!,
            data['UnitCode']!,
            data['DEPT']!,
            data['SDEPT']!,
            data['DESG']!,
            data['EMP_CODE'],
          );
          successCount++; // Increment success for new allocation
        }

      } catch (e) {
        if (kDebugMode) {
          print('Error in _allocate: $e');
        }
        failureCount++;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: successCount == scannedDataList.length
              ? const Text('Allocation Successful')
              : const Text('Allocation Partially Successful'),
          content: Text(successCount == scannedDataList.length
              ? 'All data allocations were successful.'
              : '$successCount allocations succeeded, $failureCount failed.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Clear the list regardless of success or failure
    _clearList();
    _fetchTableData(_unitMap[_selectedUnit]!);

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Data already exists"),
          content: const Text("Do you want to update the existing data?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Reject"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  String _getTailorName(String payCode) {
    // Find the name corresponding to the PAY_CODE in your dropdownData5
    final item = dropdownData5.firstWhere(
          (element) => element.startsWith(payCode),
      orElse: () => '',
    );
    return item.split('[').last.replaceAll(']', '');
  }


  Future<void> saveUnitMapToSharedPreferences(Map<String, String> unitMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unitMap', jsonEncode(unitMap));
  }

  Future<void> _saveSelectedUnitToSharedPreferences(String selectedUnit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedUnit', selectedUnit);
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
          'Allocation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
          Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<String>(
                      selectedItem: _selectedUnit,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Unit',
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                        ),
                      ),
                      items: _dropDownOptions,
                      itemAsString: (item) => item, // Display unit names
                      onChanged: (newValue) {
                        _clearList();
                        setState(() {
                          selectedValue4 = newValue;
                          _selectedUnit = newValue;
                          selectedValue3 = null; // Clear line value
                          selectedValue5 = null; // Clear tailor value
                          dropdownData3.clear(); // Clear line data
                          dropdownData5.clear(); // Clear tailor data
                          _saveSelectedUnitToSharedPreferences(newValue!);
                        });
                        fetchLineDataFromApi(newValue!);
                        _fetchTableData(_unitMap[newValue]!);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          fetchTailorDataFromApi(newValue);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        constraints: BoxConstraints(
                          maxHeight: 350.0,
                        ),
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding for the search box
                            border: OutlineInputBorder(), // Border around the search box
                            hintText: 'Search...',
                          ),
                          style: TextStyle(fontSize: 14.0), // Adjust font size if needed
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Line',
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                        ),
                      ),
                      items: dropdownData3.map((Map<String, String> value) => value['LineName']!).toList(),
                      itemAsString: (item) => item,
                      onBeforePopupOpening: (popupProps) async {
                        bool? shouldOpen = true;
                        if(scannedDataList.isNotEmpty) {
                          // Show a dialog to confirm whether the popup should open
                          shouldOpen = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Confirm Change"),
                                content: const Text(
                                    "Changing the line will clear all your data. Are you sure?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    // Prevent opening
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      _clearList();
                                    },
                                    // Allow opening
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );
                        }

                        return shouldOpen == true; // Open only if user confirms
                      },
                      onChanged: (newValue) {
                        previousValue = selectedValue3;
                        {
                          // If no data, just change the line directly
                          setState(() {
                            previousValue = newValue; // Update the previous value
                            selectedValue3 = newValue;
                            selectedLineID = dropdownData3.firstWhere((element) => element['LineName'] == newValue)['LineID'];
                            _isData(selectedLineID);
                          });
                          print('faervgrfgv');
                        }
                        print('$selectedValue3 $previousValue');
                      },
                      selectedItem: selectedValue3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        constraints: BoxConstraints(
                          maxHeight: 350.0,
                        ),
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding for the search box
                            border: OutlineInputBorder(), // Border around the search box
                            hintText: 'Search...',
                          ),
                          style: TextStyle(fontSize: 14.0), // Adjust font size if needed
                        ),
                      ),
                      selectedItem: selectedValue5 != null ? '$selectedValue5[${_getTailorName(selectedValue5!)}]' : null,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: Text('Tailor'),
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          isDense: true,
                        ),
                      ),
                      items: dropdownData5,
                      itemAsString: (item) => item,
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedValue5 = newValue.split('[').first;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    children: [

                      Row(
                        children: [
                          Checkbox(
                            value: isOTSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                isOTSelected = value ?? false;
                              });
                              if (kDebugMode) {
                                print(isOTSelected);
                              }
                              setState(() {
                                if (_selectedUnit != null) {
                                  dropdownData3.clear();
                                  fetchLineDataFromApi(_selectedUnit!);
                                }
                                if(selectedLineID != null){
                                  _isData(selectedLineID);
                                }
                              });
                            },
                          ),
                          const Text(
                            'OT',
                          ),
                        ],
                      ),
                      const SizedBox(width: 20,)
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(_isR)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xC27CF378),),
                    onPressed: _addSelectedData,
                    child: const Text('Add',style: TextStyle(
                        color: Colors.black
                    ),),
                  ),
                  const SizedBox(width: 10),
                  if(_isR)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xC2F63F54),),
                    onPressed: () {
                      if (selectedValue3 == null || selectedValue3!.isEmpty) {
                        _showLineSelectionAlert();
                      } else {
                        _navigateToScanner(context);
                      }
                    },
                    child: const Text('Scan',style: TextStyle(
                        color: Colors.black
                    ),),
                  ),
                  const SizedBox(width: 8,),
                  // Add a table here
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.lightBlue[200],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0 , bottom: 8, right: 2, left: 2),
                          child: Text('Present/Allocated : $_totalMnpwr/$_allocMnpwr',style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 14
                          ),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FixedColumnWidth(25),
                        1: FlexColumnWidth(2.3),
                        2: FlexColumnWidth(2.5),
                        3: FlexColumnWidth(4.2),
                        4: FixedColumnWidth(40),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[200],
                          ),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Pay Code',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Emp Code',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox.shrink(), // Empty cell for the delete icon
                              ),
                            ),
                          ],
                        ),
                        ...scannedDataList.asMap().entries.map((entry) {
                          int index = entry.key;
                          var data = entry.value;
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.only(top:8.0),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      textAlign: TextAlign.center,// Serial number
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      data['PayCode'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      data['EMP_CODE'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      data['tailor'] != null && data['tailor']!.length > 13
                                          ? '${data['tailor']!.substring(0, 14)}..'
                                          : data['tailor'] ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: SizedBox(
                                  height: 20,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        scannedDataList.remove(data);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(_isR)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xC27CF378),),
                      onPressed: () {
                        if(!isLoading) {
                          if (!isData) {
                            if (scannedDataList.isEmpty) {
                              showEmptyListAlert(context);
                            } else {
                              _allocate();
                            }
                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  "Can't Allocate, Line Manpower Already Verified")),
                            );
                          }
                        }
                      },
                      child: const Text('Allocate',style: TextStyle(
                          color: Colors.black
                      ),),),
                  const SizedBox(width: 16),
                  if(_isR)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(
                          0xC2F63F54),),
                      onPressed: _clearList,
                      child: const Text('Clear All',style: TextStyle(
                          color: Colors.black
                      ),),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(
                        0xC2F6AD3F),),
                    onPressed: () => navigateToReport(context),
                    child: const Text('Report',style: TextStyle(
                        color: Colors.black
                    ),),
                  ),
                ],
              ),
            ],
          ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5), // Overlay background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ]
        ),
      ),
    );
  }

  void showEmptyListAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Data Available'),
          content: const Text('Add Some Data before Allocating.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }void showChangeLineAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are You Sure'),
          content: const Text('This will Clear All Data.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}