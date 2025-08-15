import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class CutToShipDetail {
  final double cutPlanPerc;
  final double orderToShipPerc;
  final double budgetRejPerc;
  final int budgetRejVal;
  final double actualRejPerc;
  final int actualRejVal;
  final double validationRejPerc;
  final int varianceVal;
  final String unitShortCode;

  CutToShipDetail({
    required this.actualRejPerc,
    required this.budgetRejPerc,
    required this.cutPlanPerc,
    required this.actualRejVal,
    required this.budgetRejVal,
    required this.varianceVal,
    required this.orderToShipPerc,
    required this.validationRejPerc,
    required this.unitShortCode,
  });

  factory CutToShipDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }

    return CutToShipDetail(
      cutPlanPerc: toTwoDecimalPlaces((json['CutPlanPerc'] as num?)?.toDouble() ?? 0.0),
      orderToShipPerc: toTwoDecimalPlaces((json['OrderToShipPerc'] as num?)?.toDouble() ?? 0.0),
      budgetRejPerc: toTwoDecimalPlaces((json['BudgetRejPerc'] as num?)?.toDouble() ?? 0.0),
      budgetRejVal: (json['BudgetRejVal'] as num?)?.toInt() ?? 0,
      actualRejPerc: toTwoDecimalPlaces((json['ActualRejPerc'] as num?)?.toDouble() ?? 0.0),
      actualRejVal: (json['ActualRejVal'] as num?)?.toInt() ?? 0,
      validationRejPerc: toTwoDecimalPlaces((json['ValidationRejPerc'] as num?)?.toDouble() ?? 0.0),
      varianceVal: (json['VarianceVal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitId'] ?? '',
    );
  }
}

Future<List<CutToShipDetail>> fetchCutToShipData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}management?proce_type=cutToShip&from=$from&to=$to&units=$units'),
  );
  if (kDebugMode) {
    print('${TBaseURL.baseUrl}management?proce_type=cutToShip&from=$from&to=$to&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => CutToShipDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class CutToShipDataSource extends DataGridSource {
  CutToShipDataSource({required List<CutToShipDetail> cutShipData}) {
    _dataGridRows = cutShipData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<double>(columnName: 'CutToShipPerc', value: data.cutPlanPerc),
        DataGridCell<double>(columnName: 'OrderToShipPerc', value: data.orderToShipPerc),
        DataGridCell<double>(columnName: 'BudgetRejPerc', value: data.budgetRejPerc),
        DataGridCell<int>(columnName: 'BudgetRejVal', value: data.budgetRejVal),
        DataGridCell<double>(columnName: 'ActualRejPerc', value: data.actualRejPerc),
        DataGridCell<int>(columnName: 'ActualRejVal', value: data.actualRejVal),
        DataGridCell<double>(columnName: 'VariancePerc', value: data.validationRejPerc),
        DataGridCell<int>(columnName: 'VarianceVal', value: data.varianceVal),

      ]);
    }).toList();

    if (cutShipData.isNotEmpty) {
      final totals = _calculateTotals(cutShipData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<double>(columnName: 'CutToShipPerc', value: totals['cutPlanPerc']),
        DataGridCell<double>(columnName: 'OrderToShipPerc', value: totals['orderToShipPerc']),
        DataGridCell<double>(columnName: 'BudgetRejPerc', value: totals['budgetRejPerc']),
        DataGridCell<int>(columnName: 'BudgetRejVal', value: totals['budgetRejVal']),
        DataGridCell<double>(columnName: 'ActualRejPerc', value: totals['actualRejPerc']),
        DataGridCell<int>(columnName: 'ActualRejVal', value: totals['actualRejVal']),
        DataGridCell<double>(columnName: 'VariancePerc', value: totals['validationRejPerc']),
        DataGridCell<int>(columnName: 'VarianceVal', value: totals['varianceVal'])
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
      color: isTotalRow ? const Color(0xFF8DEAA3) : null,
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
              color: Colors.black
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _calculateTotals(List<CutToShipDetail> data) {
    if (data.isEmpty) return {};

    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    double calculateAverage(List<double> values) {
      var filteredValues = values.where((value) => value > 0).toList();
      if (filteredValues.isEmpty) return 0.0;
      return roundToTwo(filteredValues.reduce((a, b) => a + b) / filteredValues.length);
    }

    return {
      'cutPlanPerc': calculateAverage(data.map((item) => item.cutPlanPerc).toList()),
      'orderToShipPerc': calculateAverage(data.map((item) => item.orderToShipPerc).toList()),
      'budgetRejPerc': calculateAverage(data.map((item) => item.budgetRejPerc).toList()),
      'budgetRejVal': data.fold(0, (sum, item) => sum + (item.budgetRejVal.toInt())),
      'actualRejPerc': calculateAverage(data.map((item) => item.actualRejPerc).toList()),
      'actualRejVal': data.fold(0, (sum, item) => sum + (item.actualRejVal.toInt())),
      'validationRejPerc': calculateAverage(data.map((item) => item.validationRejPerc).toList()),
      'varianceVal': data.fold(0, (sum, item) => sum + (item.varianceVal.toInt())),
    };
  }
}

// Main widget
class CutShipTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const CutShipTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<CutShipTable> createState() => _CutShipTableState();
}

class _CutShipTableState extends State<CutShipTable> {
  late Future<List<CutToShipDetail>> cutShip;

  @override
  void initState() {
    super.initState();
    cutShip = fetchCutToShipData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CutToShipDetail>>(
      future: cutShip,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: double.infinity,
              child: LottieLoading(size: 150,animationPath: 'assets/animation/profit.json',));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          const double rowHeight = 25;
          const double headerHeight = 40;
          const double footerHeight = 25;
          final int totalRows = snapshot.data!.length;
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
                source: CutToShipDataSource(cutShipData: snapshot.data!),
                columns: [
                  GridColumn(
                      columnName: 'UnitShortCode',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Unit',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'CutToShipPerc',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Cut Plan\nTo Ship %',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'OrderToShipPerc',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Order To\n Ship%',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'BudgetRejPerc',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Budget\nRej%',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'BudgetRejVal',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Budget\nRej Val',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ActualRejPerc',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Actual\nRej%',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ActualRejVal',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Actual\nRej Val',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'VariancePerc',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Variance\nRej%',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'VarianceVal',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Variance\nRej Val',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
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
