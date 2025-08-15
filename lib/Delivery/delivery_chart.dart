import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ppms/ExtraFunction/lottie_loading.dart';
import 'package:provider/provider.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class DeliveryChartPage extends StatefulWidget {
  const DeliveryChartPage({Key? key}) : super(key: key);

  @override
  DeliveryChart createState() => DeliveryChart();
}

class DeliveryChart extends State<DeliveryChartPage>
    with TickerProviderStateMixin {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedYear;
  final Map<String, bool> _expandedMonths = {};
  final Map<String, bool> _editingMonths = {};
  List<dynamic> _apiData = [];
  List<dynamic> _editableData = [];
  bool _isLoading = true;
  bool _showFilteredData = false;
  bool _filtersExpanded = false;
  bool _isButtonPressed = false;
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _isRVisible = false,
      _showFullTitle = true,
      _isReversing = false,
      _showCursor = true,
      _fromDateFocused = false,
      _toDateFocused = false;
  bool isDarkMode = false;
  late AnimationController _typingController,
      _backButtonController,
      _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _backButtonAnimation;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month);
    _toDate = DateTime(now.year, now.month);
    _selectedYear = now.year;
    _fetchReportData();
    buttonAnimation();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();
  }

  @override
  void dispose() {
    _textControllers.forEach((key, controller) => controller.dispose());
    _focusNodes.forEach((key, node) => node.dispose());
    _scaleController.dispose();
    _typingController
      ..removeListener(_updateText)
      ..dispose();
    _cursorTimer.cancel();
    _backButtonController.dispose();
    super.dispose();
  }

  void backAnimation() {
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds: 500), // Longer duration for two-part animation
    );
  }

  void buttonAnimation() {
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
        tween:
            Tween(begin: 0.2, end: -1.5), // Then move left (forward) off screen
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
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  //App bar typing animation
  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'Delivery Chart';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(
              0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  //App bar typing animation
  void _toggleCursor(Timer timer) {
    if (mounted) {
      // Show cursor during both forward and reverse typing
      final shouldShowCursor =
          _typingController.value > 0 && _typingController.value < 1.0;

      if (shouldShowCursor || _showCursor != shouldShowCursor) {
        setState(() => _showCursor = shouldShowCursor);
      }
    }
  }

  //App bar typing animation
  Future<void> _startTypingSequence() async {
    // Type out full title
    _currentMaxLength = 'Paramount Product Management System'.length;
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);

    // Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Reverse type full title
    setState(() => _isReversing = true);
    await _typingController.reverse(from: 1.0);

    // Switch to short title
    if (mounted) {
      setState(() {
        _showFullTitle = false;
        _isReversing = false;
        _currentMaxLength = 'Delivery Chart'.length;
      });
    }

    // Adjust duration for shorter text
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  Future<void> _fetchReportData() async {
    setState(() => _isLoading = true);

    try {
      String url =
          '${TBaseURL.baseUrl}factory_report?year=${_selectedYear ?? DateTime.now().year}';
      if (kDebugMode) print('Fetching data from: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log(data.toString());
        setState(() {
          _apiData = data;
          _editableData = List.from(data);
          _initializeControllers();
          _isLoading = false;
        });
      } else {
        if (kDebugMode)
          print('Failed to load report data: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching report data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _textControllers.forEach((key, controller) => controller.dispose());
    _focusNodes.forEach((key, node) => node.dispose());
    _textControllers.clear();
    _focusNodes.clear();

    for (var item in _editableData) {
      final id =
          '${item['monYr']}-${item['monMonth']}-${item['BLocatShortCode']}-${item['TeamName']}';

      _textControllers['$id-workdays'] =
          TextEditingController(text: item['workdays']?.toString() ?? '0');

      _textControllers['$id-capPerDay'] =
          TextEditingController(text: item['UnitCap']?.toString() ?? '0');

      _textControllers['$id-capacity'] =
          TextEditingController(text: item['Capacity']?.toString() ?? '0');

      _focusNodes['$id-workdays'] = FocusNode();
      _focusNodes['$id-capPerDay'] = FocusNode();
      _focusNodes['$id-capacity'] = FocusNode();
    }
  }

  List<DateTime> _getMonthsFromApiData() {
    if (_apiData.isEmpty) return [];

    final months = _apiData
        .map((item) => DateTime(item['monYr'], item['monMonth']))
        .toSet()
        .toList();

    months.sort((a, b) => a.compareTo(b));
    return months;
  }

  List<DateTime> _getFilteredMonths() {
    if (_fromDate == null || _toDate == null) return [];

    List<DateTime> months = [];
    DateTime current = DateTime(_fromDate!.year, _fromDate!.month);
    DateTime end = DateTime(_toDate!.year, _toDate!.month);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }

    return months;
  }

  List<dynamic> _getDataForMonth(DateTime month) {
    return _editableData.where((item) {
      return item['monYr'] == month.year && item['monMonth'] == month.month;
    }).toList();
  }

  String _getMonthName(int monthNumber) {
    return DateFormat('MMM').format(DateTime(2020, monthNumber));
  }

  Future<void> _saveChangesForMonth(DateTime month) async {
    final monthKey = DateFormat('MMM yyyy').format(month);
    final monthData = _getDataForMonth(month);

    setState(() {
      _editingMonths[monthKey] = false;
    });

    try {
      for (var item in monthData) {
        final id =
            '${item['monYr']}-${item['monMonth']}-${item['BLocatShortCode']}-${item['TeamName']}';

        final workdaysText = _textControllers['$id-workdays']?.text ?? '0';
        final capPerDayText = _textControllers['$id-capPerDay']?.text ?? '0';
        final capacityText = _textControllers['$id-capacity']?.text ?? '0';

        final workdays = int.tryParse(workdaysText) ?? 0;
        final capPerDay = int.tryParse(capPerDayText) ?? 0.0;
        final capacity = int.tryParse(capacityText) ?? 0;
        final monthlyCap = (workdays * capPerDay).toInt();

        final apiUrl = Uri.parse('${TBaseURL.baseUrl}insert_delivery?' +
            'team=${Uri.encodeComponent(item['TeamName'])}' +
            '&month=${item['monMonth']}' +
            '&year=${item['monYr']}' +
            '&capacity=$capacity' +
            '&unit=${Uri.encodeComponent(item['BLocatShortCode'])}' +
            '&capDay=$capPerDay' +
            '&workdays=$workdays');

        if (kDebugMode) print('Calling API: $apiUrl');

        final response = await http.get(apiUrl);

        if (response.statusCode == 200) {
          if (kDebugMode)
            print('API response for ${item['TeamName']}: ${response.body}');
        } else {
          if (kDebugMode)
            print(
                'API call failed for ${item['TeamName']}: ${response.statusCode}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        content: Text('Data saved successfully for $monthKey',style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      if (kDebugMode) print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save data: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleEditingForMonth(DateTime month) {
    final monthKey = DateFormat('MMM yyyy').format(month);
    setState(() {
      _editingMonths[monthKey] = !(_editingMonths[monthKey] ?? false);
    });
  }

  Widget _buildMonthCard(DateTime month) {
    final monthKey = DateFormat('MMM yyyy').format(month);
    final isExpanded = _expandedMonths[monthKey] ?? false;
    final isEditing = _editingMonths[monthKey] ?? false;
    final monthData = _getDataForMonth(month);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: isExpanded
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                setState(() => _expandedMonths[monthKey] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthKey,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Row(
                    children: [
                      if (isExpanded) ...[
                        if (isEditing)
                          IconButton(
                            icon: Icon(Icons.save, color: Colors.blue),
                            onPressed: () => _saveChangesForMonth(month),
                            tooltip: 'Save changes',
                          ),
                        IconButton(
                          icon: Icon(
                            isEditing ? Icons.close : Icons.edit,
                            color: isEditing ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                          ),
                          onPressed: () => _toggleEditingForMonth(month),
                          tooltip: isEditing ? 'Cancel editing' : 'Edit data',
                        ),
                      ],
                      if (!isExpanded) ...[
                        Text(
                          '${monthData.length} entries',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        )
                      ],
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0 : 0.5,
                        child: Icon(Icons.expand_more, color: Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: Container(),
            secondChild: _buildMonthTable(monthData, isEditing),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTable(List<dynamic> monthData, bool isEditing) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 4.0, bottom: 16, right: 10, left: 10),
          child: Material(
            elevation: 2,
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey[300]!,
                    width: 1,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[200]!, Colors.grey[100]!],
                        ),
                      ),
                      children: [
                        _buildTableCell('Team', isHeader: true),
                        _buildTableCell('Capacity',
                            isHeader: true, isNumeric: true, isEditable: true),
                        _buildTableCell('Qty', isHeader: true, isNumeric: true),
                        _buildTableCell('Balance',
                            isHeader: true, isNumeric: true),
                        _buildTableCell('Unit', isHeader: true),
                        _buildTableCell('Work\nDays',
                            isHeader: true, isNumeric: true, isEditable: true),
                        _buildTableCell('Cap/\nDay',
                            isHeader: true, isNumeric: true, isEditable: true),
                        _buildTableCell('Cap \nMonthly',
                            isHeader: true, isNumeric: true),
                      ],
                    ),
                    ...monthData.map((data) {
                      final id =
                          '${data['monYr']}-${data['monMonth']}-${data['BLocatShortCode']}-${data['TeamName']}';
                      return _buildTableRow(
                        data['BLocatShortCode']?.toString() ?? '-',
                        '$id-workdays',
                        '$id-capPerDay',
                        data['TeamName']?.toString() ?? '-',
                        data['Capacity']?.toString() ?? '-',
                        data,
                        isEditing,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String c1, String workdaysKey, String capPerDayKey,
      String c5, String c6, Map<String, dynamic> item, bool isEditing) {
    final workdaysText = _textControllers[workdaysKey]?.text ?? '0';
    final capPerDayText = _textControllers[capPerDayKey]?.text ?? '0';
    final capacityKey = workdaysKey.replaceFirst('-workdays', '-capacity');
    final capacityText = _textControllers[capacityKey]?.text ?? '0';

    final workdays = int.tryParse(workdaysText) ?? 0;
    final capPerDay = double.tryParse(capPerDayText) ?? 0.0;
    final capacity = int.tryParse(capacityText) ?? 0;
    final qty = item['Qty']?.toInt() ?? 0;
    final balance = capacity - qty;
    final monthlyCap = (workdays * capPerDay).toStringAsFixed(0);
    final firstName = c5.split(' ').first;
    final hasWorkDaysData = workdaysText != '0' && workdaysText.isNotEmpty;
    final hasCapPerDayData = capPerDayText != '0' && capPerDayText.isNotEmpty;
    final hasCapacityData = capacityText != '0' && capacityText.isNotEmpty;

    return TableRow(
      decoration: BoxDecoration(color: Colors.white),
      children: [
        _buildTableCell(firstName),
        (isEditing && hasCapacityData)
            ? _buildEditableCell(capacityKey)
            : _buildTableCell(capacityText, isNumeric: true),
        _buildTableCell(qty.toString(), isNumeric: true),
        _buildTableCell(balance.toString(), isNumeric: true),
        _buildTableCell(c1),
        (isEditing && hasWorkDaysData)
            ? _buildEditableCell(workdaysKey)
            : _buildTableCell(workdaysText, isNumeric: true),
        (isEditing && hasCapPerDayData)
            ? _buildEditableCell(capPerDayKey)
            : _buildTableCell(capPerDayText, isNumeric: true),
        _buildTableCell(monthlyCap, isNumeric: true),
      ],
    );
  }

  Widget _buildEditableCell(String key) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 25,
          child: TextField(
            controller: _textControllers[key],
            focusNode: _focusNodes[key],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            ),
            style: TextStyle(color: Colors.grey[700]),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false,
      bool isNumeric = false,
      bool isEditable = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              color: isHeader ? Colors.grey[800] : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _applyFilters() => setState(() {
        _showFilteredData = true;
        _expandedMonths.clear();
      });

  void _resetFilters() {
    setState(() {
      _showFilteredData = false;
      _expandedMonths.clear();
      final now = DateTime.now();
      _fromDate = DateTime(now.year, now.month);
      _toDate = DateTime(now.year, now.month);
      _selectedYear = now.year;
    });
    _fetchReportData();
  }

  @override
  Widget build(BuildContext context) {
    final monthsToDisplay =
        _showFilteredData ? _getFilteredMonths() : _getMonthsFromApiData();

    return Scaffold(
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
              offset =
                  0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
            }

            return Transform.translate(
              offset:
                  Offset(offset * 30, 0), // Multiply by approximate pixel value
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
            if (_showCursor &&
                _typingController.value < 1.0 &&
                _typingController.value > 0)
              Container(
                width: 6,
                height: 20,
                margin: const EdgeInsets.only(left: 2),
                color: Colors.grey,
              ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        shadowColor: Colors.transparent,
        // actions: [
          //   Container(
          //     margin: const EdgeInsets.only(right: 8),
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.grey[700]!,
          //         width: 0.5,
          //       ),
          //     ),
          //     child: IconButton(
          //       icon: const Icon(
          //         Icons.menu_rounded,
          //         color: Colors.white,
          //         size: 22,
          //       ),
          //       onPressed: () => Scaffold.of(context).openDrawer(),
          //       style: IconButton.styleFrom(
          //         backgroundColor: Colors.black54,
          //         shape: const CircleBorder(),
          //       ),
          //     ),
          //   ),
        // ],
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Theme.of(context).colorScheme.onTertiary,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Customize',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.7),
                          ),
                        ),
                        trailing: IconButton(
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 300),
                            turns: _filtersExpanded ? 0.5 : 0,
                            child: Icon(Icons.expand_more,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.7)),
                          ),
                          onPressed: () => setState(
                              () => _filtersExpanded = !_filtersExpanded),
                        ),
                        onTap: () => setState(
                            () => _filtersExpanded = !_filtersExpanded),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: Container(height: 0),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectDate(context, true),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _fromDate != null
                                                  ? _getMonthName(
                                                      _fromDate!.month)
                                                  : 'From Month',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                                              ),
                                            ),
                                            Icon(Icons.calendar_today,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectDate(context, false),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.4),),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _toDate != null
                                                  ? _getMonthName(
                                                      _toDate!.month)
                                                  : 'To Month',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                                              ),
                                            ),
                                            Icon(Icons.calendar_today,
                                                size: 20,
                                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      height: 35,
                                      child: DropdownButtonFormField<int>(
                                        value: _selectedYear,
                                        decoration: InputDecoration(
                                          labelText: 'Year',
                                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.9)),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),width: 1)
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),width: 1)
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),width: 1)
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 0),
                                        ),
                                        items: List.generate(10, (index) {
                                          final year =
                                              DateTime.now().year - 5 + index;
                                          return DropdownMenuItem<int>(
                                            value: year,
                                            child: Text(year.toString(),style: TextStyle(color : Theme.of(context).colorScheme.secondary),),
                                          );
                                        }),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedYear = value;
                                          });
                                          _fetchReportData(); // Add this line to refresh data when year changes
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTapDown: (_) => setState(
                                          () => _isButtonPressed = true),
                                      onTapUp: (_) => setState(
                                          () => _isButtonPressed = false),
                                      onTapCancel: () => setState(
                                          () => _isButtonPressed = false),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 100),
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius:
                                                  _isButtonPressed ? 1 : 3,
                                              offset: _isButtonPressed
                                                  ? const Offset(1, 1)
                                                  : const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            onTap: _applyFilters,
                                            child: const Center(
                                              child: Text(
                                                'GO',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        crossFadeState: _filtersExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Expanded(
                  child: Center(
                      child: LottieLoading(
                size: 300,
                animationPath: 'assets/animation/Paperplane.json',
              )))
            else if (_apiData.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const LottieLoading(
                        size: 300,
                        animationPath: 'assets/animation/noData.json',
                      ),
                      Text(
                        'No data available',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  )
                ),
              )
            else if (monthsToDisplay.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const LottieLoading(
                        size: 300,
                        animationPath: 'assets/animation/noData.json',
                      ),
                      Text(
                        'No months match the selected filters',
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  )
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: monthsToDisplay.length,
                  itemBuilder: (context, index) =>
                      _buildMonthCard(monthsToDisplay[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate! : _toDate!,
      firstDate: DateTime(_selectedYear ?? 2000, 1),
      lastDate: DateTime(_selectedYear ?? 2100, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueGrey,
              onPrimary: Theme.of(context).colorScheme.secondary,
              surface: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              onSurface: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = DateTime(_selectedYear!, picked.month);
          if (_fromDate!.isAfter(_toDate!)) _toDate = _fromDate;
        } else {
          _toDate = DateTime(_selectedYear!, picked.month);
          if (_toDate!.isBefore(_fromDate!)) _fromDate = _toDate;
        }
      });
    }
  }
}
