import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;


class FinishTurnDetail {
  final int finishToday;
  final int finishTotal;
  final int finishYTD;
  final int turnoverToday;
  final int turnoverTotal;
  final int turnoverYTD;
  final String unitShortCode;

  FinishTurnDetail({
    required this.finishToday,
    required this.finishTotal,
    required this.finishYTD,
    required this.turnoverToday,
    required this.turnoverTotal,
    required this.turnoverYTD,
    required this.unitShortCode,
  });

  factory FinishTurnDetail.fromJson(Map<String, dynamic> json) {
    return FinishTurnDetail(
      finishToday: (json['FinishToday'] as num?)?.toInt() ?? 0,
      finishTotal: (json['FinishTotal'] as num?)?.toInt() ?? 0,
      finishYTD: (json['FinishYTD'] as num?)?.toInt() ?? 0,
      turnoverToday: (json['TurnoverToday'] as num?)?.toInt() ?? 0,
      turnoverTotal: (json['TurnoverTotal'] as num?)?.toInt() ?? 0,
      turnoverYTD: (json['TurnoverYTD'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<FinishTurnDetail>> fetchFinishData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=finishTurn&from=$from&to=$to&units=$units'),
  );
  if (kDebugMode) {
    print('http://14.142.248.34:10008/management?proce_type=finishTurn&from=$from&to=$to&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => FinishTurnDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class FinishTurnDataSource extends DataGridSource {
  FinishTurnDataSource({required List<FinishTurnDetail> finishData}) {
    _dataGridRows = finishData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int>(columnName: 'TodayQty', value: data.finishToday),
        DataGridCell<int>(columnName: 'TotalQty', value: data.finishTotal),
        DataGridCell<int>(columnName: 'YtdQty', value: data.finishYTD),
        DataGridCell<int>(columnName: 'TodayTurn', value: data.turnoverToday),
        DataGridCell<int>(columnName: 'TotalTurn', value: data.turnoverTotal),
        DataGridCell<int>(columnName: 'YtdTurn', value: data.turnoverYTD),

      ]);
    }).toList();

    if (finishData.isNotEmpty) {
      final totals = _calculateTotals(finishData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'TodayQty', value: totals['finishToday']),
        DataGridCell<int>(columnName: 'TotalQty', value: totals['finishTotal']),
        DataGridCell<int>(columnName: 'YtdQty', value: totals['finishYtd']),
        DataGridCell<int>(columnName: 'TodayTurn', value: totals['turnoverToday']),
        DataGridCell<int>(columnName: 'TotalTurn', value: totals['turnoverTotal']),
        DataGridCell<int>(columnName: 'YtdTurn', value: totals['turnoverYtd']),
      ]));
    }
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isTotalRow = row.getCells().first.value == 'Total';
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
            textAlign: alignment == Alignment.centerLeft ? TextAlign.left : TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _calculateTotals(List<FinishTurnDetail> data) {
    int count = data.length; // Total number of items in the list
    if (count == 0) return {}; // Return an empty map if no data is present\

    return {
      'finishToday': data.fold(0, (sum, item) => sum + (item.finishToday.toInt())),
      'finishTotal': data.fold(0, (sum, item) => sum + (item.finishTotal.toInt())),
      'finishYtd': data.fold(0, (sum, item) => sum + (item.finishYTD.toInt())),
      'turnoverToday': data.fold(0, (sum, item) => sum + (item.turnoverToday.toInt())),
      'turnoverTotal': data.fold(0, (sum, item) => sum + (item.turnoverTotal.toInt())),
      'turnoverYtd': data.fold(0, (sum, item) => sum + (item.turnoverYTD.toInt())),
    };
  }
}

// Main widget
class FinishTurnDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const FinishTurnDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<FinishTurnDataTable> createState() => _FinishTurnDataTableState();
}

class _FinishTurnDataTableState extends State<FinishTurnDataTable> {
  late Future<List<FinishTurnDetail>> finishingTurn;

  @override
  void initState() {
    super.initState();
    finishingTurn = fetchFinishData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FinishTurnDetail>>(
      future: finishingTurn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Calculate total height based on data rows, header, and footer
          const double rowHeight = 25;
          const double headerHeight = 40;
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
                frozenColumnsCount: 1,
                footerFrozenRowsCount: 1,
                rowHeight: 25,
                headerRowHeight: 40,
                columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                source: FinishTurnDataSource(finishData: snapshot.data!),
                columns: [
                  GridColumn(
                      columnName: 'UnitShortCode',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Unit',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TodayQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Today's\nQTY",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TotalQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('MTD\nQTY',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'YtdQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('YTD\nQTY',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TodayTurn',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Today's\n Turnover",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TotalTurn',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('MTD\nTurnover',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'YtdTurn',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('YTD\nTurnover',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
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
