import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class AuditVsDetail {
  final int auditFinishToday;
  final int auditFinishTotal;
  final int auditStitchToday;
  final int auditStitchTotal;
  final int finishToday;
  final int finishTotal;
  final int finishTodayVariance;
  final int finishTotalVariance;
  final int stitchTodayVariance;
  final int stitchTotalVariance;
  final int stitchToday;
  final int stitchTotal;
  final String unitShortCode;

  AuditVsDetail({
    required this.auditFinishToday,
    required this.auditFinishTotal,
    required this.auditStitchToday,
    required this.auditStitchTotal,
    required this.finishToday,
    required this.finishTotal,
    required this.finishTodayVariance,
    required this.finishTotalVariance,
    required this.stitchTodayVariance,
    required this.stitchTotalVariance,
    required this.stitchToday,
    required this.stitchTotal,
    required this.unitShortCode,
  });

  factory AuditVsDetail.fromJson(Map<String, dynamic> json) {
    return AuditVsDetail(
      auditFinishToday: (json['AuditFinishToday'] as num?)?.toInt() ?? 0,
      auditFinishTotal: (json['AuditFinishTotal'] as num?)?.toInt() ?? 0,
      auditStitchToday: (json['AuditStitchToday'] as num?)?.toInt() ?? 0,
      auditStitchTotal: (json['AuditStitchTotal'] as num?)?.toInt() ?? 0,
      finishToday: (json['FinishToday'] as num?)?.toInt() ?? 0,
      finishTotal: (json['FinishTotal'] as num?)?.toInt() ?? 0,
      finishTodayVariance: (json['FinishTodayVariance'] as num?)?.toInt() ?? 0,
      finishTotalVariance: (json['FinishTotalVariance'] as num?)?.toInt() ?? 0,
      stitchTodayVariance: (json['StitchTodayVariance'] as num?)?.toInt() ?? 0,
      stitchTotalVariance: (json['StitchTotalVariance'] as num?)?.toInt() ?? 0,
      stitchToday: (json['StitchToday'] as num?)?.toInt() ?? 0,
      stitchTotal: (json['StitchTotal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<AuditVsDetail>> fetchAuditVsActual(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=auditVs&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => AuditVsDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class AuditVsActualSource extends DataGridSource {
  AuditVsActualSource({required List<AuditVsDetail> auditActualData}) {
    _dataGridRows = auditActualData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'AuditStitchToday', value: (data.auditStitchToday)),
        DataGridCell<int?>(columnName: 'AuditStitchTotal', value: (data.auditStitchTotal)),
        DataGridCell<int?>(columnName: 'StitchQtyToday', value: (data.stitchToday)),
        DataGridCell<int?>(columnName: 'StitchQtyTotal', value: (data.stitchTotal)),
        DataGridCell<int?>(columnName: 'StitchVerToday', value: (data.stitchTodayVariance)),
        DataGridCell<int?>(columnName: 'StitchVerTotal', value: (data.stitchTotalVariance)),
        DataGridCell<int?>(columnName: 'AuditFinishToday', value: (data.auditFinishToday)),
        DataGridCell<int?>(columnName: 'AuditFinishTotal', value: (data.auditFinishTotal)),
        DataGridCell<int?>(columnName: 'FinishQtyToday', value: (data.finishToday)),
        DataGridCell<int?>(columnName: 'FinishQtyTotal', value: (data.finishTotal)),
        DataGridCell<int?>(columnName: 'FinishVerToday', value: (data.finishTodayVariance)),
        DataGridCell<int?>(columnName: 'FinishVerTotal', value: (data.finishTotalVariance)),
      ]);
    }).toList();

    if (auditActualData.isNotEmpty) {
      final totals = _calculateTotals(auditActualData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'AuditStitchToday', value: totals['auditStitchToday']),
        DataGridCell<int>(columnName: 'AuditStitchTotal', value: totals['auditStitchTotal']),
        DataGridCell<int>(columnName: 'StitchQtyToday', value: totals['stitchToday']),
        DataGridCell<int>(columnName: 'StitchQtyTotal', value: totals['stitchTotal']),
        DataGridCell<int>(columnName: 'StitchVerToday', value: totals['stitchTodayVariance']),
        DataGridCell<int>(columnName: 'StitchVerTotal', value: totals['stitchTotalVariance']),
        DataGridCell<int>(columnName: 'AuditFinishToday', value: totals['auditFinishToday']),
        DataGridCell<int>(columnName: 'AuditFinishTotal', value: totals['auditFinishTotal']),
        DataGridCell<int>(columnName: 'FinishQtyToday', value: totals['finishToday']),
        DataGridCell<int>(columnName: 'FinishQtyTotal', value: totals['finishTotal']),
        DataGridCell<int>(columnName: 'FinishVerToday', value: totals['finishTodayVariance']),
        DataGridCell<int>(columnName: 'FinishVerTotal', value: totals['finishTotalVariance']),
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

  Map<String, dynamic> _calculateTotals(List<AuditVsDetail> data) {
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
      'auditFinishToday': data.fold(0, (sum, item) => sum + item.auditFinishToday),
      'auditFinishTotal': data.fold(0, (sum, item) => sum + item.auditFinishTotal),
      'auditStitchToday': data.fold(0, (sum, item) => sum + item.auditStitchToday),
      'auditStitchTotal': data.fold(0, (sum, item) => sum + item.auditStitchTotal),
      'finishToday': data.fold(0, (sum, item) => sum + item.finishToday),
      'finishTotal': data.fold(0, (sum, item) => sum + item.finishTotal),
      'finishTodayVariance': data.fold(0, (sum, item) => sum + item.finishTodayVariance),
      'finishTotalVariance': data.fold(0, (sum, item) => sum + item.finishTotalVariance),
      'stitchTodayVariance': data.fold(0, (sum, item) => sum + item.stitchTodayVariance),
      'stitchTotalVariance': data.fold(0, (sum, item) => sum + item.stitchTotalVariance),
      'stitchToday': data.fold(0, (sum, item) => sum + item.stitchToday),
      'stitchTotal': data.fold(0, (sum, item) => sum + item.stitchTotal),
    };
  }
}

// Main widget
class AuditVsActualTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const AuditVsActualTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<AuditVsActualTable> createState() => _AuditVsActualTableState();
}

class _AuditVsActualTableState extends State<AuditVsActualTable> {
  late Future<List<AuditVsDetail>> auditData;

  @override
  void initState() {
    super.initState();
    auditData = fetchAuditVsActual(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuditVsDetail>>(
      future: auditData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {const double rowHeight = 25;
        const double headerHeight = 50;
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
              headerRowHeight: 25,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              source: AuditVsActualSource(auditActualData: snapshot.data!),
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
                    columnNames: [
                      'AuditStitchToday',
                      'AuditStitchTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Audit Stitch',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchQtyToday',
                      'StitchQtyTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchVerToday',
                      'StitchVerTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch Ver',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'AuditFinishToday',
                      'AuditFinishTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Audit Finish',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishQtyToday',
                      'FinishQtyTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishVerToday',
                      'FinishVerTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish Ver',
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
                    columnName: 'AuditStitchToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'AuditStitchTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchQtyToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchQtyTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchVerToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchVerTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'AuditFinishToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'AuditFinishTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishQtyToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishQtyTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishVerToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishVerTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
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
