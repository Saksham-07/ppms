import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class FinishingAskingDetail {
  final int askingRate;
  final int balToPack;
  final int balToPackVal;
  final int balToSam;
  final int checker;
  final int finishQty;
  final int pressMan;
  final int prodSamProduced;
  final int stitchQty;
  final int totalMnpwr;
  final int wip;
  final String unitShortCode;

  FinishingAskingDetail({
    required this.askingRate,
    required this.balToPack,
    required this.balToPackVal,
    required this.balToSam,
    required this.checker,
    required this.finishQty,
    required this.pressMan,
    required this.prodSamProduced,
    required this.stitchQty,
    required this.totalMnpwr,
    required this.wip,
    required this.unitShortCode,
  });

  factory FinishingAskingDetail.fromJson(Map<String, dynamic> json) {
    return FinishingAskingDetail(
      askingRate: (json['AskingRate'] as num?)?.toInt() ?? 0,
      balToPack: (json['BalToPack'] as num?)?.toInt() ?? 0,
      balToPackVal: (json['BalToPackValue'] as num?)?.toInt() ?? 0,
      balToSam: (json['BalToSam'] as num?)?.toInt() ?? 0,
      checker: (json['Checker'] as num?)?.toInt() ?? 0,
      finishQty: (json['FinishQty'] as num?)?.toInt() ?? 0,
      pressMan: (json['PressMan'] as num?)?.toInt() ?? 0,
      prodSamProduced: (json['ProdSamProduced'] as num?)?.toInt() ?? 0,
      stitchQty: (json['StitchQty'] as num?)?.toInt() ?? 0,
      totalMnpwr: (json['TotalMnpwr'] as num?)?.toInt() ?? 0,
      wip: (json['WIP'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<FinishingAskingDetail>> fetchFinishData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=finish&from=''&to=$to&units=$units'),
  );
  if (kDebugMode) {
    print('http://14.142.248.34:10008/management?proce_type=finish&from=''&to=$to&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => FinishingAskingDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class FinishingAskingDataSource extends DataGridSource {
  FinishingAskingDataSource({required List<FinishingAskingDetail> finishData}) {
    _dataGridRows = finishData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int>(columnName: 'YDayStitch', value: data.stitchQty),
        DataGridCell<int>(columnName: 'SamProd', value: data.prodSamProduced),
        DataGridCell<int>(columnName: 'BalToSam', value: data.balToSam),
        DataGridCell<int>(columnName: 'YDayPack', value: data.finishQty),
        DataGridCell<int>(columnName: 'WTD', value: data.wip),
        DataGridCell<int>(columnName: 'AskingRate', value: data.askingRate),
        DataGridCell<int>(columnName: 'BalToPack', value: data.balToPack),
        DataGridCell<int>(columnName: 'BalToPackGoods', value: data.balToPackVal),
        DataGridCell<int>(columnName: 'TodayChecker', value: data.checker),
        DataGridCell<int>(columnName: 'TodayPressman', value: data.pressMan),
        DataGridCell<int>(columnName: 'TodayManpower', value: data.totalMnpwr),

      ]);
    }).toList();

    if (finishData.isNotEmpty) {
      final totals = _calculateTotals(finishData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'YDayStitch', value: totals['stitchQty']),
        DataGridCell<int>(columnName: 'SamProd', value: totals['prodSamProduced']),
        DataGridCell<int>(columnName: 'BalToSam', value: totals['balToSam']),
        DataGridCell<int>(columnName: 'YDayPack', value: totals['finishQty']),
        DataGridCell<int>(columnName: 'WTD', value: totals['wip']),
        DataGridCell<int>(columnName: 'AskingRate', value: totals['askingRate']),
        DataGridCell<int>(columnName: 'BalToPack', value: totals['balToPack']),
        DataGridCell<int>(columnName: 'BalToPackGoods', value: totals['balToPackVal']),
        DataGridCell<int>(columnName: 'TodayChecker', value: totals['checker']),
        DataGridCell<int>(columnName: 'TodayPressman', value: totals['pressMan']),
        DataGridCell<int>(columnName: 'TodayManpower', value: totals['totalMnpwr']),
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
              fontWeight: isTotalRow ? FontWeight.bold : FontWeight.w400,
              color: Colors.black
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _calculateTotals(List<FinishingAskingDetail> data) {
    int count = data.length; // Total number of items in the list
    if (count == 0) return {}; // Return an empty map if no data is present\

    return {
      'stitchQty': data.fold(0, (sum, item) => sum + (item.stitchQty.toInt())),
      'prodSamProduced': data.fold(0, (sum, item) => sum + (item.prodSamProduced.toInt())),
      'balToSam': data.fold(0, (sum, item) => sum + (item.balToSam.toInt())),
      'finishQty': data.fold(0, (sum, item) => sum + (item.finishQty.toInt())),
      'wip': data.fold(0, (sum, item) => sum + (item.wip.toInt())),
      'askingRate': data.fold(0, (sum, item) => sum + (item.askingRate.toInt())),
      'balToPack': data.fold(0, (sum, item) => sum + (item.balToPack.toInt())),
      'balToPackVal': data.fold(0, (sum, item) => sum + (item.balToPackVal.toInt())),
      'checker': data.fold(0, (sum, item) => sum + (item.checker.toInt())),
      'pressMan': data.fold(0, (sum, item) => sum + (item.pressMan.toInt())),
      'totalMnpwr': data.fold(0, (sum, item) => sum + (item.totalMnpwr.toInt())),
    };
  }
}

// Main widget
class FinishingDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const FinishingDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<FinishingDataTable> createState() => _FinishingDataTableState();
}

class _FinishingDataTableState extends State<FinishingDataTable> {
  late Future<List<FinishingAskingDetail>> finishingAsking;

  @override
  void initState() {
    super.initState();
    finishingAsking = fetchFinishData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FinishingAskingDetail>>(
      future: finishingAsking,
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
              source: FinishingAskingDataSource(finishData: snapshot.data!),
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
                    columnName: 'YDayStitch',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YDay\nStitch',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'SamProd',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('SAM\nProd',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'BalToSam',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Bal To\n Sam',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'YDayPack',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('YDay\nPack',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'WTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('WTD',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'AskingRate',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Asking\nRate',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'BalToPack',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Bal To\nPack',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'BalToPackGoods',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Bal To Pack\nGoods Value',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TodayChecker',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text("Today's\nChecker",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TodayPressman',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text("Today's\nPressmen",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TodayManpower',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text("Today's\nManpower",
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
