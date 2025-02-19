import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class ManpowerDetail {
  final int bareTailorPresent;
  final int bareTailorPresentToday;
  final int empPayroll;
  final int empPresent;
  final int empPresentToday;
  final int femalePresent;
  final int femalePresentToday;
  final int gradeAPlusToday;
  final int gradeAPlusTotal;
  final int gradeAToday;
  final int gradeATotal;
  final int gradeBToday;
  final int gradeBTotal;
  final double mMR;
  final double mMRToday;
  final int malePresent;
  final int malePresentToday;
  final int mispunch;
  final int mispunchToday;
  final int otherTailorPresent;
  final int otherTailorPresentToday;
  final int pcsTailorPayroll;
  final int pcsTailorPayrollToday;
  final int pcsTailorPresent;
  final int pcsTailorPresentToday;
  final int tailorOnPayroll;
  final int tailorOnPayrollToday;
  final int tailorPresent;
  final int tailorPresentToday;
  final String unitShortCode;

  ManpowerDetail({
    required this.bareTailorPresent,
    required this.bareTailorPresentToday,
    required this.empPayroll,
    required this.empPresent,
    required this.empPresentToday,
    required this.femalePresent,
    required this.femalePresentToday,
    required this.gradeAPlusToday,
    required this.gradeAPlusTotal,
    required this.gradeAToday,
    required this.gradeATotal,
    required this.gradeBToday,
    required this.gradeBTotal,
    required this.mMR,
    required this.mMRToday,
    required this.malePresent,
    required this.malePresentToday,
    required this.mispunch,
    required this.mispunchToday,
    required this.otherTailorPresent,
    required this.otherTailorPresentToday,
    required this.pcsTailorPayroll,
    required this.pcsTailorPayrollToday,
    required this.pcsTailorPresent,
    required this.pcsTailorPresentToday,
    required this.tailorOnPayroll,
    required this.tailorOnPayrollToday,
    required this.tailorPresent,
    required this.tailorPresentToday,
    required this.unitShortCode,
  });

  factory ManpowerDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return ManpowerDetail(
      bareTailorPresent: (json['BareTailorPresent'] as num?)?.toInt() ?? 0,
      bareTailorPresentToday: (json['BareTailorPresentToday'] as num?)?.toInt() ?? 0,
      empPayroll: (json['EmpPayroll'] as num?)?.toInt() ?? 0,
      empPresent: (json['EmpPresent'] as num?)?.toInt() ?? 0,
      empPresentToday: (json['EmpPresentToday'] as num?)?.toInt() ?? 0,
      femalePresent: (json['FemalePresent'] as num?)?.toInt() ?? 0,
      femalePresentToday: (json['FemalePresentToday'] as num?)?.toInt() ?? 0,
      gradeAPlusToday: (json['GradeAPlusToday'] as num?)?.toInt() ?? 0,
      gradeAPlusTotal: (json['GradeAPlusTotal'] as num?)?.toInt() ?? 0,
      gradeAToday: (json['GradeAToday'] as num?)?.toInt() ?? 0,
      gradeATotal: (json['GradeATotal'] as num?)?.toInt() ?? 0,
      gradeBToday: (json['GradeBToday'] as num?)?.toInt() ?? 0,
      gradeBTotal: (json['GradeBTotal'] as num?)?.toInt() ?? 0,
      mMR: toTwoDecimalPlaces((json['MMR'] as num?)?.toDouble() ?? 0.0),
      mMRToday: toTwoDecimalPlaces((json['MMRToday'] as num?)?.toDouble() ?? 0.0),
      malePresent: (json['MalePresent'] as num?)?.toInt() ?? 0,
      malePresentToday: (json['MalePresentToday'] as num?)?.toInt() ?? 0,
      mispunch: (json['Mispunch'] as num?)?.toInt() ?? 0,
      mispunchToday: (json['MispunchToday'] as num?)?.toInt() ?? 0,
      otherTailorPresent: (json['OtherTailorPresent'] as num?)?.toInt() ?? 0,
      otherTailorPresentToday: (json['OtherTailorPresentToday'] as num?)?.toInt() ?? 0,
      pcsTailorPayroll: (json['PcsTailorPayroll'] as num?)?.toInt() ?? 0,
      pcsTailorPayrollToday: (json['PcsTailorPayrollToday'] as num?)?.toInt() ?? 0,
      pcsTailorPresent: (json['PcsTailorPresent'] as num?)?.toInt() ?? 0,
      pcsTailorPresentToday: (json['PcsTailorPresentToday'] as num?)?.toInt() ?? 0,
      tailorOnPayroll: (json['TailorOnPayroll'] as num?)?.toInt() ?? 0,
      tailorOnPayrollToday: (json['TailorOnPayrollToday'] as num?)?.toInt() ?? 0,
      tailorPresent: (json['TailorPresent'] as num?)?.toInt() ?? 0,
      tailorPresentToday: (json['TailorPresentToday'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<ManpowerDetail>> fetchManpowerData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=manpowerTailor&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => ManpowerDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class MapPowerDataSource extends DataGridSource {
  MapPowerDataSource({required List<ManpowerDetail> onTimeData}) {
    _dataGridRows = onTimeData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'EmpOnroll', value: (data.empPayroll)),
        DataGridCell<int?>(columnName: 'EmpPreToDate', value: (data.empPresent)),
        DataGridCell<int?>(columnName: 'EmpPreToday', value: (data.empPresentToday)),
        DataGridCell<int?>(columnName: 'TailorToDate', value: (data.tailorOnPayroll)),
        DataGridCell<int?>(columnName: 'TailorToday', value: (data.tailorOnPayrollToday)),
        DataGridCell<int?>(columnName: 'TailorA+ToDate', value: (data.gradeAPlusTotal)),
        DataGridCell<int?>(columnName: 'TailorA+Today', value: (data.gradeAPlusToday)),
        DataGridCell<int?>(columnName: 'TailorAToDate', value: (data.gradeATotal)),
        DataGridCell<int?>(columnName: 'TailorAToday', value: (data.gradeAToday)),
        DataGridCell<int?>(columnName: 'TailorBToDate', value: (data.gradeBTotal)),
        DataGridCell<int?>(columnName: 'TailorBToday', value: (data.gradeBToday)),
        DataGridCell<int?>(columnName: 'TailorPresToDate', value: (data.tailorPresent)),
        DataGridCell<int?>(columnName: 'TailorPresToday', value: (data.tailorPresentToday)),
        DataGridCell<int?>(columnName: 'TailorPresBareToDate', value: (data.bareTailorPresent)),
        DataGridCell<int?>(columnName: 'TailorPresBareToday', value: (data.bareTailorPresentToday)),
        DataGridCell<int?>(columnName: 'TailorPresOtherToDate', value: (data.otherTailorPresent)),
        DataGridCell<int?>(columnName: 'TailorPresOtherToday', value: (data.otherTailorPresentToday)),
        DataGridCell<int?>(columnName: 'MisPunchToDate', value: (data.mispunch)),
        DataGridCell<int?>(columnName: 'MisPunchToday', value: (data.mispunchToday)),
        DataGridCell<int?>(columnName: 'MaleToDate', value: (data.malePresent)),
        DataGridCell<int?>(columnName: 'MaleToday', value: (data.malePresentToday)),
        DataGridCell<int?>(columnName: 'FemaleToDate', value: (data.femalePresent)),
        DataGridCell<int?>(columnName: 'FemaleToday', value: (data.femalePresentToday)),
        DataGridCell<int?>(columnName: 'PceRateOnrollToDate', value: (data.pcsTailorPayroll)),
        DataGridCell<int?>(columnName: 'PceRateOnrollToday', value: (data.pcsTailorPayrollToday)),
        DataGridCell<int?>(columnName: 'PceRatePresToDate', value: (data.pcsTailorPresent)),
        DataGridCell<int?>(columnName: 'PceRatePresToday', value: (data.pcsTailorPresentToday)),
        DataGridCell<double>(columnName: 'MMRToDate', value: double.parse(data.mMR.toStringAsFixed(2))),
        DataGridCell<double>(columnName: 'MMRToday', value: double.parse(data.mMRToday.toStringAsFixed(2))),
      ]);
    }).toList();

    if (onTimeData.isNotEmpty) {
      final totals = _calculateTotals(onTimeData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'EmpOnroll', value: totals['empPayroll']),
        DataGridCell<int>(columnName: 'EmpPreToDate', value: totals['empPresent']),
        DataGridCell<int>(columnName: 'EmpPreToday', value: totals['empPresentToday']),
        DataGridCell<int>(columnName: 'TailorToDate', value: totals['tailorOnPayroll']),
        DataGridCell<int>(columnName: 'TailorToday', value: totals['tailorOnPayrollToday']),
        DataGridCell<int>(columnName: 'TailorA+ToDate', value: totals['gradeAPlusTotal']),
        DataGridCell<int>(columnName: 'TailorA+Today', value: totals['gradeAPlusToday']),
        DataGridCell<int>(columnName: 'TailorAToDate', value: totals['gradeATotal']),
        DataGridCell<int>(columnName: 'TailorAToday', value: totals['gradeAToday']),
        DataGridCell<int>(columnName: 'TailorBToDate', value: totals['gradeBTotal']),
        DataGridCell<int>(columnName: 'TailorBToday', value: totals['gradeBToday']),
        DataGridCell<int>(columnName: 'TailorPresToDate', value: totals['tailorPresent']),
        DataGridCell<int>(columnName: 'TailorPresToday', value: totals['tailorPresentToday']),
        DataGridCell<int>(columnName: 'TailorPresBareToDate', value: totals['bareTailorPresent']),
        DataGridCell<int>(columnName: 'TailorPresBareToday', value: totals['bareTailorPresentToday']),
        DataGridCell<int>(columnName: 'TailorPresOtherToDate', value: totals['otherTailorPresent']),
        DataGridCell<int>(columnName: 'TailorPresOtherToday', value: totals['otherTailorPresentToday']),
        DataGridCell<int>(columnName: 'MisPunchToDate', value: totals['mispunch']),
        DataGridCell<int>(columnName: 'MisPunchToday', value: totals['mispunchToday']),
        DataGridCell<int>(columnName: 'MaleToDate', value: totals['malePresent']),
        DataGridCell<int>(columnName: 'MaleToday', value: totals['malePresentToday']),
        DataGridCell<int>(columnName: 'FemaleToDate', value: totals['femalePresent']),
        DataGridCell<int>(columnName: 'FemaleToday', value: totals['femalePresentToday']),
        DataGridCell<int>(columnName: 'PceRateOnrollToDate', value: totals['pcsTailorPayroll']),
        DataGridCell<int>(columnName: 'PceRateOnrollToday', value: totals['pcsTailorPayrollToday']),
        DataGridCell<int>(columnName: 'PceRatePresToDate', value: totals['pcsTailorPresent']),
        DataGridCell<int>(columnName: 'PceRatePresToday', value: totals['pcsTailorPresentToday']),
        DataGridCell<double>(
            columnName: 'MMRToDate', value: totals['mMR']),
        DataGridCell<double>(
            columnName: 'MMRToday', value: totals['mMRToday']),
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

  Map<String, dynamic> _calculateTotals(List<ManpowerDetail> data) {
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
      'bareTailorPresent': data.fold(0, (sum, item) => sum + item.bareTailorPresent),
      'bareTailorPresentToday': data.fold(0, (sum, item) => sum + item.bareTailorPresentToday),
      'empPayroll': data.fold(0, (sum, item) => sum + item.empPayroll),
      'empPresent': data.fold(0, (sum, item) => sum + item.empPresent),
      'empPresentToday': data.fold(0, (sum, item) => sum + item.empPresentToday),
      'femalePresent': data.fold(0, (sum, item) => sum + item.femalePresent),
      'femalePresentToday': data.fold(0, (sum, item) => sum + item.femalePresentToday),
      'gradeAPlusToday': data.fold(0, (sum, item) => sum + item.gradeAPlusToday),
      'gradeAPlusTotal': data.fold(0, (sum, item) => sum + item.gradeAPlusTotal),
      'gradeAToday': data.fold(0, (sum, item) => sum + item.gradeAToday),
      'gradeATotal': data.fold(0, (sum, item) => sum + item.gradeATotal),
      'gradeBToday': data.fold(0, (sum, item) => sum + item.gradeBToday),
      'gradeBTotal': data.fold(0, (sum, item) => sum + item.gradeBTotal),
      'mMR': calculateAverage(data.map((item) => item.mMR).toList()),
      'mMRToday': calculateAverage(data.map((item) => item.mMRToday).toList()),
      'malePresent': data.fold(0, (sum, item) => sum + item.malePresent),
      'malePresentToday': data.fold(0, (sum, item) => sum + item.malePresentToday),
      'mispunch': data.fold(0, (sum, item) => sum + item.mispunch),
      'mispunchToday': data.fold(0, (sum, item) => sum + item.mispunchToday),
      'otherTailorPresent': data.fold(0, (sum, item) => sum + item.otherTailorPresent),
      'otherTailorPresentToday': data.fold(0, (sum, item) => sum + item.otherTailorPresentToday),
      'pcsTailorPayroll': data.fold(0, (sum, item) => sum + item.pcsTailorPayroll),
      'pcsTailorPayrollToday': data.fold(0, (sum, item) => sum + item.pcsTailorPayrollToday),
      'pcsTailorPresent': data.fold(0, (sum, item) => sum + item.pcsTailorPresent),
      'pcsTailorPresentToday': data.fold(0, (sum, item) => sum + item.pcsTailorPresentToday),
      'tailorOnPayroll': data.fold(0, (sum, item) => sum + item.tailorOnPayroll),
      'tailorOnPayrollToday': data.fold(0, (sum, item) => sum + item.tailorOnPayrollToday),
      'tailorPresent': data.fold(0, (sum, item) => sum + item.tailorPresent),
      'tailorPresentToday': data.fold(0, (sum, item) => sum + item.tailorPresentToday),
    };
  }
}

// Main widget
class ManPowerDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const ManPowerDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<ManPowerDataTable> createState() => _ManPowerDataTableState();
}

class _ManPowerDataTableState extends State<ManPowerDataTable> {
  late Future<List<ManpowerDetail>> auditData;

  @override
  void initState() {
    super.initState();
    auditData = fetchManpowerData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ManpowerDetail>>(
      future: auditData,
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
              source: MapPowerDataSource(onTimeData: snapshot.data!),
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
                    columnNames: ['EmpOnroll'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Emp\nOnroll',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'EmpPreToDate',
                      'EmpPreToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Emp\nPresent',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorToDate',
                      'TailorToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nOnroll',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorA+ToDate',
                      'TailorA+Today',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nOnroll(A+)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorAToDate',
                      'TailorAToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nOnroll(A)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorBToDate',
                      'TailorBToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nOnroll(B)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorPresToDate',
                      'TailorPresToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nPresent',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorPresBareToDate',
                      'TailorPresBareToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nPresent(Bare)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TailorPresOtherToDate',
                      'TailorPresOtherToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Tailor\nPresent(Other)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'MisPunchToDate',
                      'MisPunchToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'MisPunch',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'MaleToDate',
                      'MaleToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Male\nPresent',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FemaleToDate',
                      'FemaleToday',
                    ],
                    child: Container(
                        color: const Color(0xFAEA8AE2),
                        child: const Center(
                            child: Text(
                              'Female\nPresent',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'PceRateOnrollToDate',
                      'PceRateOnrollToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Piece Rate\nOnroll',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'PceRatePresToDate',
                      'PceRatePresToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Piece Rate\nPresent',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'MMRToDate',
                      'MMRToday',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'MMR',
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
                    columnName: 'EmpOnroll',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'EmpPreToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'EmpPreToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorA+ToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorA+Today',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorAToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorAToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorBToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorBToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresBareToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresBareToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresOtherToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TailorPresOtherToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MisPunchToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MisPunchToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MaleToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MaleToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FemaleToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FemaleToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PceRateOnrollToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PceRateOnrollToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PceRatePresToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PceRatePresToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MMRToDate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('To Date',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MMRToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
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
