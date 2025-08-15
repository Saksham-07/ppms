
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ppms/ESS/essdashboard.dart';
import 'package:ppms/PoApproval/po_approvals_dtl.dart';
import 'package:ppms/PoApproval/production_po_approvals_dtl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ExtraFunction/lottie_loading.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class PoApproval extends StatefulWidget {
  final String? approvalFor;
  final String? pageName;

  const PoApproval({super.key, required this.approvalFor, required this.pageName});

  @override
  State<PoApproval> createState() => _PoApprovalState();
}

class _PoApprovalState extends State<PoApproval> with TickerProviderStateMixin {
  String? reportDataType;
  String? subReportDataType;
  String? poNo,loginId,id;
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _filteredTableData = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // Add FocusNode
  bool _isRVisible = false,_showFullTitle = true,_isReversing = false,_showCursor = true,
      _fromDateFocused = false,_toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,_backButtonController,_scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;

  @override
  void initState() {
    super.initState();
    _gettingMainData();
    _searchController.addListener(_filterTableData);

    // Set focus on the search field when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  void backAnimation(){
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Longer duration for two-part animation
    );
  }

  void buttonAnimation(){
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleController.reverse();
      }
    });
  }

  //back button animation
  Future<void> _handleBack() async {
    final animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.2), // Move right (backward) 20%
        weight: 40, // 40% of total duration
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: -1.5), // Then move left (forward) off screen
        weight: 60, // 60% of total duration
      ),
    ]).animate(_backButtonController);

    await _backButtonController.forward(); // Start animation
    if (mounted) Navigator.of(context).pop(); // Pop after animation completes
  }

  //App bar typing animation
  void _setupAnimations() {
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _typingAnimation = IntTween(begin: 0, end: _currentMaxLength).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );

    _typingAnimation.addListener(_updateText);
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  void _updateText() {
    if (!mounted) return;

    const fullText = 'Paramount Product Management System';
    var shortText = widget.approvalFor;

    final newText = _showFullTitle
        ? fullText.substring(0, _typingAnimation.value)
        : shortText?.substring(0, _typingAnimation.value.clamp(0, shortText.length));

    if (_displayText != newText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _displayText = newText!;
          });
        }
      });
    }
  }

// 2. Update the _toggleCursor method
  void _toggleCursor(Timer timer) {
    if (!mounted) {
      _cursorTimer.cancel();
      return;
    }

    final shouldShowCursor = _typingController.value > 0 &&
        _typingController.value < 1.0;

    if (shouldShowCursor != _showCursor) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _showCursor = shouldShowCursor);
        }
      });
    }
  }

  //App bar typing animation
  Future<void> _startTypingSequence() async {
    try {
      // Type out full title
      _currentMaxLength = 'Paramount Product Management System'.length;
      _typingController.duration = const Duration(milliseconds: 3000);
      await _typingController.forward(from: 0);

      // Wait 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Reverse type full title
      if (mounted) {
        setState(() => _isReversing = true);
      }
      await _typingController.reverse(from: 1.0);

      // Switch to short title
      if (mounted) {
        setState(() {
          _showFullTitle = false;
          _isReversing = false;
          _currentMaxLength = widget.approvalFor!.length;
        });
      }

      // Adjust duration for shorter text
      _typingController.duration = const Duration(milliseconds: 3000);
      await _typingController.forward(from: 0);
    } catch (e) {
      if (kDebugMode) {
        print('Animation error: $e');
      }
    }
  }

  void _filterTableData() {
    setState(() {
      String searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        _filteredTableData =
            _tableData; // If search query is empty, show all data
      } else {
        _filteredTableData = _tableData.where((item) {
          return item['PO_NO'].toString().toLowerCase().contains(searchQuery) ||
              item['VENDOR_NAME'].toString().toLowerCase().contains(
                  searchQuery);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose the FocusNode
    _typingController.removeListener(_updateText);
    _typingController.dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Function for getting data
  Future<void> _gettingMainData() async {
    _tableData.clear();
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> specialRigths = [];

    var reportDataType = 'main';
    var pageName = widget.pageName.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginIds = prefs.getString('login_id');
    final String url1 = '${TBaseURL.baseUrl}/special?user=${id ?? loginIds}&module=MobileApplication&page=$pageName';
    if (kDebugMode) {
      print(url1);
    }
    final response1 = await http.get(Uri.parse(url1));
    if (response1.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response1.body);
      setState(() {
        specialRigths = List<Map<String, dynamic>>.from(data);
        loginId = prefs.getString('login_id');
      });
    } else {
      throw Exception('Failed to get permissions.');
    }

    List<String> specialRight = specialRigths.map((item) => item['name'] as String).toList();
    if (specialRight.contains('QtyApproval') && specialRight.contains('PriceApproval')) {
      subReportDataType = 'Both';
    } else if (specialRight.contains('QtyApproval')) {
      subReportDataType = 'Qty';
    } else if (specialRight.contains('PriceApproval')) {
      subReportDataType = 'Price';
    }

    int isAll = 0;
    if (specialRight.contains('AllowAllPO')) {
      isAll = 1;
    }

    final String url2 = '${TBaseURL.baseUrl}po_approval_new?type=$reportDataType&subReportType=$subReportDataType&pageName=${widget.pageName.toString()}&user=${id ?? loginIds}&isAll=$isAll';
    final String url3 = '${TBaseURL.baseUrl}vg_po_approval?data_type=Hdr&pageName=${widget.pageName.toString()}&user_id=${id ?? loginIds}';

    if (kDebugMode) {
      print('URL 1: $url2');
      print('URL 2: $url3');
    }

    try {
      final responses = await Future.wait([
        http.get(Uri.parse(url2)),
        http.get(Uri.parse(url3)),
      ]);

      final response1 = responses[0];
      final response2 = responses[1];

      if (response1.statusCode == 200 || response2.statusCode == 200) {
        final List<dynamic> data1 = response1.statusCode == 200 ? jsonDecode(response1.body) : [];
        final List<dynamic> data2 = response2.statusCode == 200 ? jsonDecode(response2.body) : [];

        if (data1.isEmpty && data2.isEmpty) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Data Found.'),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (data1.isNotEmpty && data1[0]['MsgType'] == 1) {
          // Show only data2 if data1 indicates "no rights"
          if (data2.isNotEmpty) {
            setState(() {
              _tableData = List<Map<String, dynamic>>.from(data2);
              _filteredTableData = _tableData;
              log(_tableData.toString());
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No Data Found.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else if (data2.isNotEmpty && (data1.isEmpty || data1[0]['MsgType'] != 1)) {
          // Merge both data1 and data2 if both are valid
          final combinedData = [...data1, ...data2];
          setState(() {
            _tableData = List<Map<String, dynamic>>.from(combinedData);
            _filteredTableData = _tableData;
            log(_tableData.toString());
            _isLoading = false;
          });
        } else {
          // Default case: Show only data1
          setState(() {
            _tableData = List<Map<String, dynamic>>.from(data1);
            _filteredTableData = _tableData;
            log(_tableData.toString());
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load one or both data sources.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while loading data.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // function for navigate to detail
  Future<void> _navigateToDtl (BuildContext context, String poNo, String approvalFor, String amount,String poYear,String poType,String type) async {
    if (widget.pageName == 'ProductionPo'){
      print(approvalFor);
      print(widget.pageName.toString());
      print(amount.toString());
      print(poYear);
      print(poType);
      final result = await Navigator.push(
        context,
          MaterialPageRoute(builder: (context) =>
              ProductionPoApprovalsDtl(poNo : poNo,
                  approvalFor: approvalFor,
                  pageName: widget.pageName.toString(),
                  Amount : amount.toString(),
                  poYr: poYear,
                  poType: poType,
                  type: type,
              )
          )
      );
      if (result == true) {
        _gettingMainData ();
      }
    }else{
      final result = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => PoApprovalDtl(
              poNo : poNo,
              approvalFor: approvalFor,
              pageName: widget.pageName.toString(),
              Amount : amount.toString(),
              poYr: poYear,
              poType: poType,
              type: type,
          )
          )
      );
      if (result == true) {
        _gettingMainData ();
      }
    }

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
                _gettingMainData(); // Run function with entered text
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var pageType = widget.approvalFor;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        bottom: const PreferredSize(
                        preferredSize: Size(7, 7),
                        child: Divider(
                          color: Colors.white,
                          indent: 16,
                          endIndent: 16,
                        )),
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        leading: AnimatedBuilder(
          animation: _backButtonController,
          builder: (context, child) {
            final value = _backButtonController.value;
            double offset;

            // Custom easing for the two-part motion
            if (value < 0.4) {
              // First part - move right (backward)
              offset = Curves.easeOut.transform(value / 0.4) * 0.2;
            } else {
              // Second part - move left (forward)
              offset = 0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
            }

            return Transform.translate(
              offset: Offset(offset * 30, 0), // Multiply by approximate pixel value
              child: Container(
                margin: const EdgeInsets.only(left: 12, top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: _handleBack,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _displayText,
                key: ValueKey(_showFullTitle),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _showFullTitle ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: _showFullTitle ? 0.0 : 1.5,
                ),
              ),
            ),
            if (_showCursor && _typingController.value < 1.0 && _typingController.value > 0)
              Container(
                width: 6,
                height: 20,
                margin: const EdgeInsets.only(left: 2),
                color: Colors.grey,
              ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          if(loginId == '0552482' || loginId == '0552297')
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: GestureDetector(
                  onTap: () {
                    _showSearchDialog(context);
                  },
                  child: const Icon(Icons.search,color: Colors.transparent,size: 16,)
              ),
            ),
        ],
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    controller: _searchController,
                    focusNode: _searchFocusNode, // Attach FocusNode
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.secondary
                      ),
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Theme.of(context).colorScheme.secondary,
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: LottieLoading(animationPath: 'assets/animation/po.json',size: 300,)
                )
                    : SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                              color: Colors.grey[400]),
                          children: [
                            const Padding(
                                padding: EdgeInsets.all(6.0), child: Text('')),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Po No',style: TextStyle(
                                  color: Colors.black
                                ),)),
                            Visibility(
                              visible: widget.pageName == 'ProductionPo',
                              child: const Padding(padding: EdgeInsets.all(6.0),
                                  child: Text('Process',style: TextStyle(
                                      color: Colors.black
                                  ),)),
                            ),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Date',style: TextStyle(
                                    color: Colors.black
                                ),)),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Qty',style: TextStyle(
                                    color: Colors.black
                                ),)),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Curr',style: TextStyle(
                                    color: Colors.black
                                ),)),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Po Amt',style: TextStyle(
                                    color: Colors.black
                                ),)),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('Supplier',style: TextStyle(
                                    color: Colors.black
                                ),)),
                            const Padding(padding: EdgeInsets.all(6.0),
                                child: Text('First Approver',style: TextStyle(
                                    color: Colors.black
                                ),)),
                          ],
                        ),
                        ..._filteredTableData
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key + 1;
                          var item = entry.value;
                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(index.toString(),
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    item['PO_NO'].toString(),
                                    style: TextStyle(fontSize: 12,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      decorationColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4)
                                    ),
                                  ),
                                ),
                                onTap: () =>
                                    _navigateToDtl(
                                        context, item['PO_NO'].toString(),
                                        pageType.toString(),
                                        item['PO_AMOUNT'].toString(),
                                        item['PoYr'] ?? '',
                                        item['PoType'] ?? '',
                                        item['Approval_Type'] ?? '',
                                    ),
                              ),
                              Visibility(
                                visible: widget.pageName == 'ProductionPo',
                                child: Padding(padding: const EdgeInsets.all(6.0),
                                    child: Text(item['PROCESS'].toString(),
                                        style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              ),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['PO_DATE'].toString(),
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(double.parse(item['PO_QTY'].toString()).truncate().toString(),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text((item['Currency'] != null ? item['Currency'].toString() : ''),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['PO_AMOUNT'].toString(),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(item['VENDOR_NAME'].toString(),
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                              Padding(padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                      (item['APPROVED_BY'] ?? '').toString(),
                                      style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary))),
                            ],
                          );
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
