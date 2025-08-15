import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ppms/PoApproval/po_approvals.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ExtraFunction/uuid.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class ProductionPoApprovalsDtl extends StatefulWidget {
  final String ? poNo;
  final String ? approvalFor;
  final String ? pageName;
  final String ? Amount;
  final String ? poYr;
  final String ? poType;
  final String ? type;
  const ProductionPoApprovalsDtl({super.key, required this.poNo, required this.approvalFor, required this.pageName, required this.Amount, this.poYr, this.poType, this.type});

  @override
  State<ProductionPoApprovalsDtl> createState() => _ProductionPoApprovalsDtlState();
}

class _ProductionPoApprovalsDtlState extends State<ProductionPoApprovalsDtl> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _spclPermission = [];
  List<Map<String, dynamic>> _userData = [];
  List<String> special_rigths = [];

  bool isQtyApproval = false;
  bool isVGApproval = false;
  bool isPriceApproval = true;
  bool isBothApproval = false;
  String? uuid = '';
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
  late final AnimationController _lottieController;

  @override
  void initState() {
    if(widget.type == 'VG'){
      isVGApproval = true;
      _getVGDtlData(widget.poNo);
    }
    else{
      _getDtlData(widget.poNo);
    }
    // TODO: implement initState
    super.initState();
    getUid();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _typingController.removeListener(_updateText);
    _typingController.dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    _scaleController.dispose();
    super.dispose();
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
        : shortText!.substring(0, _typingAnimation.value.clamp(0, shortText.length));

    if (_displayText != newText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _displayText = newText;
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

  void getUid() async {
    WidgetsFlutterBinding.ensureInitialized();

    String id = await PersistentUUID.getOrCreateUUID();
    setState(() {
      uuid = id;
    });

    print('Persistent UUID: $uuid');
  }

  Future<void> _showSuccessAnimation() async {
    final completer = Completer<void>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.4),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                  )
                ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animation/approve.json',
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController.duration = Duration(seconds: 2); // Very fast
                    _lottieController.forward().whenComplete(() { Navigator.of(context).pop();
                    completer.complete();
                    });
                  },
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  'PO Approved',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return completer.future;
  }

  Future<void> test() async {
    await _showSuccessAnimation();

    if (mounted) Navigator.of(context).pop(true);

    debugPrint('Test completed successfully');
  }

  Future<void> _getVGDtlData(String ? poNo) async{
    var pageName = widget.pageName.toString();
    var poYr = widget.poYr.toString();
    var poType = widget.poType.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url = '${TBaseURL.baseUrl}/vg_po_approval?data_type=Dtl&po_no=$poNo&pageName=$pageName&user_id=$loginId&po_type=$poType&po_yr=$poYr';
    if (kDebugMode) {
      print(url);
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);

      {setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
        if(data[0]['CanAppr'] == 0 && data[0]['CanAuth'] == 0){
          isQtyApproval = false;
          isPriceApproval = false;
          isBothApproval = false;
        }
        else if(data[0]['CanAppr'] == 0 && data[0]['CanAuth'] == 1){
          isQtyApproval = false;
        }
        else if(data[0]['CanAppr'] == 1 && data[0]['CanAuth'] == 0){
          isPriceApproval = false;
          isQtyApproval = true;
        }
        else{
          isBothApproval = true;
          isQtyApproval = true;
          isPriceApproval = false;
        }
      });
      }
    }else{
      throw Exception('Unable to get data.');
    }
  }

  Future<void> _getDtlData(String ? poNo) async {
    var pageName = widget.pageName.toString();

    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    final String url1 = '${TBaseURL
        .baseUrl}/special?user=$loginId&module=MobileApplication&page=$pageName';
    print(url1);
    final response1 = await http.get(Uri.parse(url1));
    if (response1.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response1.body);
      _spclPermission = List<Map<String, dynamic>>.from(data);
      setState(() {
        special_rigths =
            _spclPermission.map((item) => item['name'] as String).toList();
      });
    } else {
      throw Exception('Unable to get Permissions.');
    }
    final String url = '${TBaseURL.baseUrl}/po_approval_new?type=dtlProd&po_no=$poNo&user=$loginId&pageName=$pageName';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data[0]['MsgType'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SubGroups Not Available'),
            duration: Duration(seconds: 3),
            showCloseIcon: true,
          ),
        );
      } else
      {setState(() {
        _tableData = List<Map<String, dynamic>>.from(data);
      });}
    } else {
      throw Exception('Unable to get data.');
    }
    if (special_rigths.contains('QtyApproval') && _tableData[0]['VERIFY'] == 'N' ){
      isQtyApproval = true;
    }
    final String url2 = '${TBaseURL.baseUrl}/po_approval_new?type=userDtl&pageName=$pageName&user=$loginId&Amount=${widget.Amount}';
    print(url2);
    final response2 = await http.get(Uri.parse(url2));
    if (response2.statusCode == 200){
      final List<dynamic> data = jsonDecode(response2.body);

      setState(() {
        _userData = List<Map<String, dynamic>>.from(data);
      });
    }else{
      throw Exception('Unable to get data.');
    }

}
  //  function for submit data
  Future<void> _saveData(String pageName) async {
    var poNo = widget.poNo;
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');
    int isFinal = 0;
    if (_userData[0]['IsFinal'] == 1){
      isFinal = 1;
    }
    // final String url = '${TBaseURL.baseUrl}po_approval?type=submit&po_no=$poNo&approvalType=prodDtl&user=$loginId';
    final String url = '${TBaseURL.baseUrl}po_approval_new?type=submit&po_no=$poNo&approvalType=prodDtl&user=$loginId&pageName=$pageName&isFinal=$isFinal&device_id=$uuid';
    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      final List<dynamic> data = jsonDecode(response.body);
      if(data[0]['Results'] == 'Done'){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data is saved successfully.'),
            duration: Duration(seconds: 3),
          ),
        );

        await _showSuccessAnimation(); // Show animation before navigating
        if (mounted) Navigator.pop(context, true);
      }else if(data[0]['Results'] == 'No ErpName'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erp Name is not updated. Kindly contact to IT Support.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else{
        // Show error message in SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save data.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }else{
      throw Exception('Unable to save data.');
    }
  }

  Future<void> _saveVGData(String pageName) async {
    var poNo = widget.poNo;
    final prefs = await SharedPreferences.getInstance();
    var loginId = prefs.getString('login_id');

    List<String> urls = [];
    if (_tableData[0]['CanAuth'] == 1) {
      urls.add('${TBaseURL.baseUrl}vg_po_approval?user_id=$loginId&data_type=Submit&pageName=$pageName&po_no=$poNo&po_type=${widget.poType}&po_yr=${widget.poYr}&approval_type=authorise');
    }
    if (_tableData[0]['CanAppr'] == 1) {
      urls.add('${TBaseURL.baseUrl}vg_po_approval?user_id=$loginId&data_type=Submit&pageName=$pageName&po_no=$poNo&po_type=${widget.poType}&po_yr=${widget.poYr}&approval_type=approve');
    }
    if (kDebugMode) {
      for (var url in urls) {
        print(url);
      }
    }

    // Execute all API calls concurrently
    try {
      final responses = await Future.wait(
        urls.map((url) => http.get(Uri.parse(url))),
      );

      // Process responses
      for (final response in responses) {
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          if (data[0]['Msg'] == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PO Approved.'),
                duration: Duration(seconds: 3),
              ),
            );

            await _showSuccessAnimation(); // Show animation before navigating
            if (mounted) Navigator.pop(context, true);
          } else if (data[0]['Results'] == 'No ErpName') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erp Name is not updated. Kindly contact to IT Support.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            // Show error message in SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to save data.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          throw Exception('Unable to save data.');
        }
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
      ),

      body:
    InteractiveViewer(
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isVGApproval && isQtyApproval)
                    _buildApprovalButton(
                      onPressed: () {
                        if(widget.type != 'VG') {
                          _saveData( widget.pageName.toString());
                        }
                        else{
                          _saveVGData(widget.pageName.toString());
                        }
                      },
                      label: 'Qty Verify',
                      color: Colors.green,
                      icon: Icons.local_shipping_outlined,
                    ),
                  if (isVGApproval && isPriceApproval)
                    _buildApprovalButton(
                      onPressed: () {
                        if(widget.type != 'VG') {
                          _saveData(widget.pageName.toString());
                        }
                        else{
                          _saveVGData(widget.pageName.toString());
                        }
                      },
                      label: 'Price Verify',
                      color: Colors.orange,
                      icon: Icons.attach_money_outlined,
                    ),
                  if (isQtyApproval || isBothApproval)
                    _buildApprovalButton(
                      onPressed: () {
                        if(widget.type != 'VG') {
                          _saveData(widget.pageName.toString());
                        }
                        else{
                          _saveVGData(widget.pageName.toString());
                        }
                      },
                      label: 'PO Verify',
                      color: Colors.blue,
                      icon: Icons.verified_outlined,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0 : IntrinsicColumnWidth(),
                        1 : IntrinsicColumnWidth(),
                        2 : IntrinsicColumnWidth(),
                        3 : IntrinsicColumnWidth(),
                        4 : IntrinsicColumnWidth(),
                        5 : IntrinsicColumnWidth(),
                      },
                      children: [
                        TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey[400]
                            ),
                            children: const [
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Po No', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Style No', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Order No', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Color', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                              Padding(padding: EdgeInsets.all(8.0), child: Text('Po Rate', softWrap: false, overflow: TextOverflow.clip, style: TextStyle(color: Colors.black)),),
                            ]
                        ),
                        ..._tableData.asMap().entries.map((entry){
                          var item = entry.value;
                          return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(8.0), child: Text(item['PO_NO'].toString(), softWrap: false, overflow: TextOverflow.clip, style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary),),),
                                Padding(padding:  const EdgeInsets.all(8.0), child: Text(item['STYLE_NO'].toString(), style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['ORDER_NO'].toString(), style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text((item['COLOR'] ?? '').toString(), softWrap: false, overflow: TextOverflow.clip, style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['PO_QTY'].toString(),textAlign: TextAlign.right, style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary)),),
                                Padding(padding: EdgeInsets.all(8.0), child: Text(item['PO_RATE'].toString(),textAlign: TextAlign.right, style: TextStyle(fontSize: 12,color: Theme.of(context).colorScheme.secondary)),),
                              ]
                          );
                        })
                      ]
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
  Widget _buildApprovalButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      iconAlignment: IconAlignment.end,
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }
}