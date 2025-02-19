import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../common/utils/constants/baseurl.dart';

class SamRevisionData {
  int todaycuttingRequested;
  int todaycuttingApproved;
  int monthcuttingRequested;
  int monthcuttingApproved;
  int yearcuttingRequested;
  int yearcuttingApproved;
  int todaystitchingRequested;
  int todaystitchingApproved;
  int monthstitchingRequested;
  int monthstitchingApproved;
  int yearstitchingRequested;
  int yearstitchingApproved;
  int todayfinishingRequested;
  int todayfinishingApproved;
  int monthfinishingRequested;
  int monthfinishingApproved;
  int yearfinishingRequested;
  int yearfinishingApproved;
  String unitShortCode;

  SamRevisionData({
    required this.todaycuttingRequested,
    required this.todaycuttingApproved,
    required this.monthcuttingRequested,
    required this.monthcuttingApproved,
    required this.yearcuttingRequested,
    required this.yearcuttingApproved,
    required this.todaystitchingRequested,
    required this.todaystitchingApproved,
    required this.monthstitchingRequested,
    required this.monthstitchingApproved,
    required this.yearstitchingRequested,
    required this.yearstitchingApproved,
    required this.todayfinishingRequested,
    required this.todayfinishingApproved,
    required this.monthfinishingRequested,
    required this.monthfinishingApproved,
    required this.yearfinishingRequested,
    required this.yearfinishingApproved,
    required this.unitShortCode,
  });

  factory SamRevisionData.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return SamRevisionData(
      todaycuttingRequested: int.tryParse(json['TodaycuttingRequested']?.toString() ?? '') ?? 0,
      todaycuttingApproved: int.tryParse(json['TodaycuttingApproved']?.toString() ?? '') ?? 0,
      monthcuttingRequested: int.tryParse(json['MonthcuttingRequested']?.toString() ?? '') ?? 0,
      monthcuttingApproved: int.tryParse(json['MonthcuttingApproved']?.toString() ?? '') ?? 0,
      yearcuttingRequested: int.tryParse(json['YearcuttingRequested']?.toString() ?? '') ?? 0,
      yearcuttingApproved: int.tryParse(json['YearcuttingApproved']?.toString() ?? '') ?? 0,
      todaystitchingRequested: int.tryParse(json['TodaystitchingRequested']?.toString() ?? '') ?? 0,
      todaystitchingApproved: int.tryParse(json['TodaystitchingApproved']?.toString() ?? '') ?? 0,
      monthstitchingRequested: int.tryParse(json['MonthstitchingRequested']?.toString() ?? '') ?? 0,
      monthstitchingApproved: int.tryParse(json['MonthstitchingApproved']?.toString() ?? '') ?? 0,
      yearstitchingRequested: int.tryParse(json['YearstitchingRequested']?.toString() ?? '') ?? 0,
      yearstitchingApproved: int.tryParse(json['YearstitchingApproved']?.toString() ?? '') ?? 0,
      todayfinishingRequested: int.tryParse(json['TodayfinishingRequested']?.toString() ?? '') ?? 0,
      todayfinishingApproved: int.tryParse(json['TodayfinishingApproved']?.toString() ?? '') ?? 0,
      monthfinishingRequested: int.tryParse(json['MonthfinishingRequested']?.toString() ?? '') ?? 0,
      monthfinishingApproved: int.tryParse(json['MonthfinishingApproved']?.toString() ?? '') ?? 0,
      yearfinishingRequested: int.tryParse(json['YearfinishingRequested']?.toString() ?? '') ?? 0,
      yearfinishingApproved: int.tryParse(json['YearfinishingApproved']?.toString() ?? '') ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<SamRevisionData>> fetchSamRevision(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse(
        '${TBaseURL.baseUrl}management?proce_type=samRevision&from=$from&to=$to&units=$units'),
  );
  if (kDebugMode) {
    print('${TBaseURL.baseUrl}management?proce_type=samRevision&from=$from&to=$to&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => SamRevisionData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class SamRevisionDataSource extends DataGridSource {
  SamRevisionDataSource({required List<SamRevisionData> samRevisionData}) {
    _dataGridRows = samRevisionData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'cuttingTodayReq', value: (data.todaycuttingRequested)),
        DataGridCell<int?>(columnName: 'cuttingTodayDone', value: (data.todaycuttingApproved)),
        DataGridCell<int?>(columnName: 'cuttingMonthReq', value: (data.monthcuttingRequested)),
        DataGridCell<int?>(columnName: 'cuttingMonthDone', value: (data.monthcuttingApproved)),
        DataGridCell<int?>(columnName: 'cuttingYearReq', value: (data.yearcuttingRequested)),
        DataGridCell<int?>(columnName: 'cuttingYearDone', value: (data.yearcuttingApproved)),
        DataGridCell<int?>(columnName: 'stitchTodayReq', value: (data.todaystitchingRequested)),
        DataGridCell<int?>(columnName: 'stitchTodayDone', value: (data.todaystitchingApproved)),
        DataGridCell<int?>(columnName: 'stitchMonthReq', value: (data.monthstitchingRequested)),
        DataGridCell<int?>(columnName: 'stitchMonthDone', value: (data.monthstitchingApproved)),
        DataGridCell<int?>(columnName: 'stitchYearReq', value: (data.yearstitchingRequested)),
        DataGridCell<int?>(columnName: 'stitchYearDone', value: (data.yearstitchingApproved)),
        DataGridCell<int?>(columnName: 'finishTodayReq', value: (data.todayfinishingRequested)),
        DataGridCell<int?>(columnName: 'finishTodayDone', value: (data.todayfinishingApproved)),
        DataGridCell<int?>(columnName: 'finishMonthReq', value: (data.monthfinishingRequested)),
        DataGridCell<int?>(columnName: 'finishMonthDone', value: (data.monthfinishingApproved)),
        DataGridCell<int?>(columnName: 'finishYearReq', value: (data.yearfinishingRequested)),
        DataGridCell<int?>(columnName: 'finishYearDone', value: (data.yearfinishingApproved)),
      ]);
    }).toList();

    if (samRevisionData.isNotEmpty) {
      final totals = _calculateTotals(samRevisionData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'cuttingTodayReq', value: totals['todaycuttingRequested']),
        DataGridCell<int>(columnName: 'cuttingTodayDone', value: totals['todaycuttingApproved']),
        DataGridCell<int>(columnName: 'cuttingMonthReq', value: totals['monthcuttingRequested']),
        DataGridCell<int>(columnName: 'cuttingMonthDone', value: totals['monthcuttingApproved']),
        DataGridCell<int>(columnName: 'cuttingYearReq', value: totals['yearcuttingRequested']),
        DataGridCell<int>(columnName: 'cuttingYearDone', value: totals['yearcuttingApproved']),
        DataGridCell<int>(columnName: 'stitchTodayReq', value: totals['todaystitchingRequested']),
        DataGridCell<int>(columnName: 'stitchTodayDone', value: totals['todaystitchingApproved']),
        DataGridCell<int>(columnName: 'stitchMonthReq', value: totals['monthstitchingRequested']),
        DataGridCell<int>(columnName: 'stitchMonthDone', value: totals['monthstitchingApproved']),
        DataGridCell<int>(columnName: 'stitchYearReq', value: totals['yearstitchingRequested']),
        DataGridCell<int>(columnName: 'stitchYearDone', value: totals['yearstitchingApproved']),
        DataGridCell<int>(columnName: 'finishTodayReq', value: totals['todayfinishingRequested']),
        DataGridCell<int>(columnName: 'finishTodayDone', value: totals['todayfinishingApproved']),
        DataGridCell<int>(columnName: 'finishMonthReq', value: totals['monthfinishingRequested']),
        DataGridCell<int>(columnName: 'finishMonthDone', value: totals['monthfinishingApproved']),
        DataGridCell<int>(columnName: 'finishYearReq', value: totals['yearfinishingRequested']),
        DataGridCell<int>(columnName: 'finishYearDone', value: totals['yearfinishingApproved']),
      ]));
    }
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isTotalRow = row
        .getCells()
        .first
        .value == 'Total';
    return DataGridRowAdapter(
      color: isTotalRow ? Colors.yellowAccent : null,
      cells: row.getCells().map<Widget>((dataGridCell) {
        Alignment alignment = dataGridCell.columnName == 'UnitShortCode'
            ? Alignment.centerLeft
            : Alignment.centerRight;
        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            dataGridCell.value.toString(),
            textAlign: alignment == Alignment.centerLeft
                ? TextAlign.left
                : TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _calculateTotals(List<SamRevisionData> data) {
    if (data.isEmpty) return {}; // Return an empty map if no data is present

    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    // Helper function to calculate average of values > 0
    double calculateAverage(List<double> values) {
      var filteredValues = values.where((value) => value > 0).toList();
      if (filteredValues.isEmpty) return 0.0; // Avoid division by 0
      return roundToTwo(filteredValues.reduce((a, b) => a + b) / filteredValues.length);
    }

    // Map each field to its average
    return {
      'todaycuttingRequested': data.fold(0, (sum, item) => sum + item.todaycuttingRequested),
      'todaycuttingApproved': data.fold(0, (sum, item) => sum + item.todaycuttingApproved),
      'monthcuttingRequested': data.fold(0, (sum, item) => sum + item.monthcuttingRequested),
      'monthcuttingApproved': data.fold(0, (sum, item) => sum + item.monthcuttingApproved),
      'yearcuttingRequested': data.fold(0, (sum, item) => sum + item.yearcuttingRequested),
      'yearcuttingApproved': data.fold(0, (sum, item) => sum + item.yearcuttingApproved),
      'todaystitchingRequested': data.fold(0, (sum, item) => sum + item.todaystitchingRequested),
      'todaystitchingApproved': data.fold(0, (sum, item) => sum + item.todaystitchingApproved),
      'monthstitchingRequested': data.fold(0, (sum, item) => sum + item.monthstitchingRequested),
      'monthstitchingApproved': data.fold(0, (sum, item) => sum + item.monthstitchingApproved),
      'yearstitchingRequested': data.fold(0, (sum, item) => sum + item.yearstitchingRequested),
      'yearstitchingApproved': data.fold(0, (sum, item) => sum + item.yearstitchingApproved),
      'todayfinishingRequested': data.fold(0, (sum, item) => sum + item.todayfinishingRequested),
      'todayfinishingApproved': data.fold(0, (sum, item) => sum + item.todayfinishingApproved),
      'monthfinishingRequested': data.fold(0, (sum, item) => sum + item.monthfinishingRequested),
      'monthfinishingApproved': data.fold(0, (sum, item) => sum + item.monthfinishingApproved),
      'yearfinishingRequested': data.fold(0, (sum, item) => sum + item.yearfinishingRequested),
      'yearfinishingApproved': data.fold(0, (sum, item) => sum + item.yearfinishingApproved),
    };
  }
}

// Main widget
class SamRevisionTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const SamRevisionTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<SamRevisionTable> createState() => _SamRevisionTableState();
}

class _SamRevisionTableState extends State<SamRevisionTable> {
  late Future<List<SamRevisionData>> samRevision;

  @override
  void initState() {
    super.initState();
    samRevision = fetchSamRevision(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SamRevisionData>>(
      future: samRevision,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {const double rowHeight = 25;
        const double headerHeight = 80;
        const double footerHeight = 25;
        final int totalRows = snapshot.data!.length; // Include the total row
        final double totalHeight =
            (totalRows * rowHeight) + headerHeight + footerHeight;

        return Container(
          width: double.infinity,
          color: Colors.white,
          child: SizedBox(
            height: totalHeight < MediaQuery.of(context).size.height
                ? totalHeight
                : MediaQuery.of(context).size.height, // Cap height to screen size
            child: SfDataGrid(
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              allowPullToRefresh: true,
              frozenColumnsCount: 1,
              shrinkWrapRows: true,
              highlightRowOnHover: true,
              allowSwiping: false,
              rowHeight: 25,
              horizontalScrollController: ScrollController(initialScrollOffset: 0),
              headerRowHeight: 40,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              source: SamRevisionDataSource(samRevisionData: snapshot.data!),
              stackedHeaderRows: [
                StackedHeaderRow(cells: [
                  StackedHeaderCell(
                    columnNames: ['UnitShortCode'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: ['cuttingTodayReq', 'cuttingTodayDone', 'cuttingMonthReq', 'cuttingMonthDone', 'cuttingYearReq', 'cuttingYearDone'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Cutting',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'stitchTodayReq',
                      'stitchTodayDone',
                      'stitchMonthReq',
                      'stitchMonthDone',
                      'stitchYearReq',
                      'stitchYearDone',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitching',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'finishTodayReq',
                      'finishTodayDone',
                      'finishMonthReq',
                      'finishMonthDone',
                      'finishYearReq',
                      'finishYearDone',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finishing',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                ]),
              ],
              columns: [
                GridColumn(
                    columnName: 'UnitShortCode',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Unit',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingTodayReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingTodayDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingMonthReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingMonthDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingYearReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'cuttingYearDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchTodayReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchTodayDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchMonthReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchMonthDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchYearReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'stitchYearDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishTodayReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishTodayDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishMonthReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishMonthDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishYearReq',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Entry)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'finishYearDone',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Done)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
              ],
            ),
          ),
        );
        } else {
          return const Center(child: Text('No Data Available'));
        }
      },
    );
  }
}
