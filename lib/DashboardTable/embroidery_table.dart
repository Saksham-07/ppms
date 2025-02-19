import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../common/utils/constants/baseurl.dart';

class EmbroideryDetail {
  final double todayDispatch;
  final double totalDispatch;
  final double todayCapacity;
  final double totalCapacity;
  final double todayEfficiency;
  final double totalEfficiency;
  final double todayPnL;
  final double totalPnL;
  final String unitShortCode;

  EmbroideryDetail({
    required this.todayCapacity,
    required this.todayDispatch,
    required this.todayEfficiency,
    required this.todayPnL,
    required this.totalCapacity,
    required this.totalDispatch,
    required this.totalEfficiency,
    required this.totalPnL,
    required this.unitShortCode,
  });

  factory EmbroideryDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return EmbroideryDetail(
      todayCapacity: toTwoDecimalPlaces((json['TodayCapacity'] as num?)?.toDouble() ?? 0.0),
      todayDispatch: toTwoDecimalPlaces((json['TodayDispatch'] as num?)?.toDouble() ?? 0.0),
      todayEfficiency: toTwoDecimalPlaces((json['TodayEfficiency'] as num?)?.toDouble() ?? 0.0),
      todayPnL: toTwoDecimalPlaces((json['TodayPnL'] as num?)?.toDouble() ?? 0.0),
      totalCapacity: toTwoDecimalPlaces((json['TotalCapacity'] as num?)?.toDouble() ?? 0.0),
      totalDispatch: toTwoDecimalPlaces((json['TotalDispatch'] as num?)?.toDouble() ?? 0.0),
      totalEfficiency: toTwoDecimalPlaces((json['TotalEfficiency'] as num?)?.toDouble() ?? 0.0),
      totalPnL: toTwoDecimalPlaces((json['TotalPnL'] as num?)?.toDouble() ?? 0.0),
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

// Fetch data from the API
Future<List<EmbroideryDetail>> fetchEmbroideryDetail(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse(
        '${TBaseURL.baseUrl}management?proce_type=embroidery&from=$from&to=$to&units='),);

  if (kDebugMode) {
    print('${TBaseURL.baseUrl}management?proce_type=embroidery&from=$from&to=$to&units=');
  }
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => EmbroideryDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class EmbroideryDataSource extends DataGridSource {
  EmbroideryDataSource({required List<EmbroideryDetail> onTimeData}) {
    _dataGridRows = onTimeData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<double>(columnName: 'DispatchToday',
            value: double.parse(data.todayDispatch.toStringAsFixed(2))),
        DataGridCell<double>(columnName: 'DispatchTotal',
            value: double.parse(data.totalDispatch.toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'CapacityToday',
            value: double.parse((data.todayCapacity).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'CapacityTotal',
            value: double.parse((data.totalCapacity).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'EffToday', value: double.parse((data.todayEfficiency).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'EffTotal', value: double.parse((data.totalEfficiency).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'PnLToday', value: double.parse((data.todayPnL).toStringAsFixed(2))),
        DataGridCell<double?>(
            columnName: 'PnLTotal', value: double.parse((data.totalPnL).toStringAsFixed(2))),
      ]);
    }).toList();

    // if (onTimeData.isNotEmpty) {
    //   // final totals = _calculateTotals(onTimeData);
    //   _dataGridRows.add(DataGridRow(cells: [
    //     const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
    //     DataGridCell<double>(
    //         columnName: 'StitchToday', value: totals['todayCapacity']),
    //     DataGridCell<double>(
    //         columnName: 'StitchTotal', value: totals['todayDispatch']),
    //     DataGridCell<double>(
    //         columnName: 'FinishToday', value: totals['todayEfficiency']),
    //     DataGridCell<double>(
    //         columnName: 'FinishTotal', value: totals['todayPnL']),
    //     DataGridCell<double>(
    //         columnName: 'InspectToday', value: totals['totalCapacity']),
    //     DataGridCell<double>(
    //         columnName: 'InspectTotal', value: totals['totalDispatch']),
    //     DataGridCell<double>(
    //         columnName: 'InspectToday', value: totals['totalEfficiency']),
    //     DataGridCell<double>(
    //         columnName: 'InspectTotal', value: totals['totalPnL']),
    //   ]));
    // }
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

  // Map<String, dynamic> _calculateTotals(List<EmbroideryDetail> data) {
  //   if (data.isEmpty) return {}; // Return an empty map if no data is present
  //
  //   double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));
  //
  //   // Helper function to calculate average of values > 0
  //   double calculateAverage(List<double> values) {
  //     var filteredValues = values.where((value) => value > 0).toList();
  //     if (filteredValues.isEmpty) return 0.0; // Avoid division by 0
  //     return roundToTwo(filteredValues.reduce((a, b) => a + b) / filteredValues.length);
  //   }
  //
  //   // Map each field to its average
  //   return {
  //     'exFailFTD': data.fold(0, (sum, item) => sum + item.exFailFTD),
  //     'exFailMTD': data.fold(0, (sum, item) => sum + item.exFailMTD),
  //     'exFailYTD': data.fold(0, (sum, item) => sum + item.exFailYTD),
  //     'exPassFTD': data.fold(0, (sum, item) => sum + item.exPassFTD),
  //     'exPassMTD': data.fold(0, (sum, item) => sum + item.exPassMTD),
  //     'exPassYTD': data.fold(0, (sum, item) => sum + item.exPassYTD),
  //     'inspectionToday': calculateAverage(data.map((item) => item.inspectionToday).toList()),
  //     'inspectionTotal': calculateAverage(data.map((item) => item.inspectionTotal).toList()),
  //     'finishAuditToday': calculateAverage(data.map((item) => item.finishAuditToday).toList()),
  //     'finishAuditTotal': calculateAverage(data.map((item) => item.finishAuditTotal).toList()),
  //     'stitchAuditToday': calculateAverage(data.map((item) => item.stitchAuditToday).toList()),
  //     'stitchAuditTotal': calculateAverage(data.map((item) => item.stitchAuditTotal).toList()),
  //   };
  // }
}

// Main widget
class EmbroideryDetailTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const EmbroideryDetailTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<EmbroideryDetailTable> createState() => _EmbroideryDetailTableState();
}

class _EmbroideryDetailTableState extends State<EmbroideryDetailTable> {
  late Future<List<EmbroideryDetail>> embroideryData;

  @override
  void initState() {
    super.initState();
    embroideryData = fetchEmbroideryDetail(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmbroideryDetail>>(
      future: embroideryData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {const double rowHeight = 25;
        const double headerHeight = 80;
        final int totalRows = snapshot.data!.length; // Include the total row
        final double totalHeight =
            (totalRows * rowHeight) + headerHeight;

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
              source: EmbroideryDataSource(onTimeData: snapshot.data!),
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
                    columnNames: ['DispatchToday', 'DispatchTotal'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Dispatch',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'CapacityToday',
                      'CapacityTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Capacity %',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'EffToday',
                      'EffTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Eff %',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'PnLToday',
                      'PnLTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Profit/Loss',
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
                    columnName: 'DispatchToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'DispatchTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CapacityToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CapacityTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'EffToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'EffTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PnLToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PnLTotal',
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
