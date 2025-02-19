import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class AuditDetail {
  final int exFailFTD;
  final int exFailMTD;
  final int exFailYTD;
  final int exPassFTD;
  final int exPassMTD;
  final int exPassYTD;
  final double inspectionToday;
  final double inspectionTotal;
  final double finishAuditToday;
  final double finishAuditTotal;
  final double stitchAuditToday;
  final double stitchAuditTotal;
  final String unitShortCode;

  AuditDetail({
    required this.exFailFTD,
    required this.exFailMTD,
    required this.exFailYTD,
    required this.exPassFTD,
    required this.exPassMTD,
    required this.exPassYTD,
    required this.finishAuditToday,
    required this.finishAuditTotal,
    required this.inspectionToday,
    required this.inspectionTotal,
    required this.stitchAuditToday,
    required this.stitchAuditTotal,
    required this.unitShortCode,
  });

  factory AuditDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return AuditDetail(
      exFailFTD: (json['ExFailFTD'] as num?)?.toInt() ?? 0,
      exFailMTD: (json['ExFailMTD'] as num?)?.toInt() ?? 0,
      exFailYTD: (json['ExFailYTD'] as num?)?.toInt() ?? 0,
      exPassFTD: (json['ExPassFTD'] as num?)?.toInt() ?? 0,
      exPassMTD: (json['ExPassMTD'] as num?)?.toInt() ?? 0,
      exPassYTD: (json['ExPassYTD'] as num?)?.toInt() ?? 0,
      finishAuditToday: toTwoDecimalPlaces((json['FinishAuditToday'] as num?)?.toDouble() ?? 0.0),
      finishAuditTotal: toTwoDecimalPlaces((json['FinishAuditTotal'] as num?)?.toDouble() ?? 0.0),
      inspectionToday: toTwoDecimalPlaces((json['InspectionToday'] as num?)?.toDouble() ?? 0.0),
      inspectionTotal: toTwoDecimalPlaces((json['InspectionTotal'] as num?)?.toDouble() ?? 0.0),
      stitchAuditToday: toTwoDecimalPlaces((json['StitchAuditToday'] as num?)?.toDouble() ?? 0.0),
      stitchAuditTotal: toTwoDecimalPlaces((json['StitchAuditTotal'] as num?)?.toDouble() ?? 0.0),
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

// Fetch data from the API
Future<List<AuditDetail>> fetchAuditDetail(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse(
        'http://14.142.248.34:10008/management?proce_type=audit&from=$from&to=$to&units=$units'),
  );

  print('http://14.142.248.34:10008/management?proce_type=audit&from=$from&to=$to&units=$units');
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => AuditDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class AuditDataSource extends DataGridSource {
  AuditDataSource({required List<AuditDetail> onTimeData}) {
    _dataGridRows = onTimeData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<double>(columnName: 'StitchToday',
            value: double.parse(data.stitchAuditToday.toStringAsFixed(2))),
        DataGridCell<double>(columnName: 'StitchTotal',
            value: double.parse(data.stitchAuditTotal.toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'FinishToday',
            value: double.parse((data.finishAuditToday).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'FinishTotal',
            value: double.parse((data.finishAuditTotal).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'InspectToday', value: double.parse((data.inspectionToday).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'InspectTotal', value: double.parse((data.inspectionTotal).toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'FTDPass', value: (data.exPassFTD)),
        DataGridCell<int?>(columnName: 'FTDFail', value: (data.exFailFTD)),
        DataGridCell<int?>(columnName: 'MTDPass', value: (data.exPassMTD)),
        DataGridCell<int?>(columnName: 'MTDFail', value: (data.exFailMTD)),
        DataGridCell<int?>(columnName: 'YTDPass', value: (data.exPassYTD)),
        DataGridCell<int?>(columnName: 'YTDFail', value: (data.exFailYTD)),
      ]);
    }).toList();

    if (onTimeData.isNotEmpty) {
      final totals = _calculateTotals(onTimeData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<double>(
            columnName: 'StitchToday', value: totals['stitchAuditToday']),
        DataGridCell<double>(
            columnName: 'StitchTotal', value: totals['stitchAuditTotal']),
        DataGridCell<double>(
            columnName: 'FinishToday', value: totals['finishAuditToday']),
        DataGridCell<double>(
            columnName: 'FinishTotal', value: totals['finishAuditTotal']),
        DataGridCell<double>(
            columnName: 'InspectToday', value: totals['inspectionToday']),
        DataGridCell<double>(
            columnName: 'InspectTotal', value: totals['inspectionTotal']),
        DataGridCell<int>(columnName: 'FTDPass', value: totals['exPassFTD']),
        DataGridCell<int>(columnName: 'FTDFail', value: totals['exFailFTD']),
        DataGridCell<int>(columnName: 'MTDPass', value: totals['exPassMTD']),
        DataGridCell<int>(columnName: 'MTDFail', value: totals['exFailMTD']),
        DataGridCell<int>(columnName: 'YTDPass', value: totals['exPassYTD']),
        DataGridCell<int>(columnName: 'YTDFail', value: totals['exFailYTD']),
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

  Map<String, dynamic> _calculateTotals(List<AuditDetail> data) {
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
      'exFailFTD': data.fold(0, (sum, item) => sum + item.exFailFTD),
      'exFailMTD': data.fold(0, (sum, item) => sum + item.exFailMTD),
      'exFailYTD': data.fold(0, (sum, item) => sum + item.exFailYTD),
      'exPassFTD': data.fold(0, (sum, item) => sum + item.exPassFTD),
      'exPassMTD': data.fold(0, (sum, item) => sum + item.exPassMTD),
      'exPassYTD': data.fold(0, (sum, item) => sum + item.exPassYTD),
      'inspectionToday': calculateAverage(data.map((item) => item.inspectionToday).toList()),
      'inspectionTotal': calculateAverage(data.map((item) => item.inspectionTotal).toList()),
      'finishAuditToday': calculateAverage(data.map((item) => item.finishAuditToday).toList()),
      'finishAuditTotal': calculateAverage(data.map((item) => item.finishAuditTotal).toList()),
      'stitchAuditToday': calculateAverage(data.map((item) => item.stitchAuditToday).toList()),
      'stitchAuditTotal': calculateAverage(data.map((item) => item.stitchAuditTotal).toList()),
    };
  }
}

// Main widget
class AuditDetailTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const AuditDetailTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<AuditDetailTable> createState() => _AuditDetailTableState();
}

class _AuditDetailTableState extends State<AuditDetailTable> {
  late Future<List<AuditDetail>> auditData;

  @override
  void initState() {
    super.initState();
    auditData = fetchAuditDetail(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AuditDetail>>(
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
              source: AuditDataSource(onTimeData: snapshot.data!),
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
                    columnNames: ['StitchToday', 'StitchTotal'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitching\nAudit',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishToday',
                      'FinishTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finishing\nAudit',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'InspectToday',
                      'InspectTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Inspection\nAudit',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FTDPass',
                      'FTDFail',
                      'MTDPass',
                      'MTDFail',
                      'YTDPass',
                      'YTDFail',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'External\nAudit',
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
                    columnName: 'StitchToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'InspectToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'InspectTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FTDPass',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Pass)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FTDFail',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD\n(Fail)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MTDPass',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Pass)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'MTDFail',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD\n(Fail)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'YTDPass',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Pass)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'YTDFail',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YTD\n(Fail)',
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
