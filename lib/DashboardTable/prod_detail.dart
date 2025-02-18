import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class ProductionData {
  final int cuttingToday;
  final int cuttingTotal;
  final int finishInouseToday;
  final int finishInouseTotal;
  final int finishOutToday;
  final int finishOutTotal;
  final int finishPcsRateToday;
  final int finishPcsRateTotal;
  final int finishToday;
  final int finishTotal;
  final int shipMonthPcs;
  final int shipMonthRate;
  final int shipTodayPcs;
  final int shipTodayRate;
  final int shipYearPcs;
  final int shipYearRate;
  final int stitchInouseToday;
  final int stitchInouseTotal;
  final int stitchOutToday;
  final int stitchOutTotal;
  final int stitchPcsRateToday;
  final int stitchPcsRateTotal;
  final int stitchToday;
  final int stitchTotal;
  final String unitShortCode;

  ProductionData({
    required this.cuttingToday,
    required this.cuttingTotal,
    required this.finishInouseToday,
    required this.finishInouseTotal,
    required this.finishOutToday,
    required this.finishOutTotal,
    required this.finishPcsRateToday,
    required this.finishPcsRateTotal,
    required this.finishToday,
    required this.finishTotal,
    required this.shipMonthPcs,
    required this.shipMonthRate,
    required this.shipTodayPcs,
    required this.shipTodayRate,
    required this.shipYearPcs,
    required this.shipYearRate,
    required this.stitchInouseToday,
    required this.stitchInouseTotal,
    required this.stitchOutToday,
    required this.stitchOutTotal,
    required this.stitchPcsRateToday,
    required this.stitchPcsRateTotal,
    required this.stitchToday,
    required this.stitchTotal,
    required this.unitShortCode,
  });

  factory ProductionData.fromJson(Map<String, dynamic> json) {
    return ProductionData(
      cuttingToday: (json['CuttingToday'] as num?)?.toInt() ?? 0,
      cuttingTotal: (json['CuttingTotal'] as num?)?.toInt() ?? 0,
      finishInouseToday: (json['FinishInouseToday'] as num?)?.toInt() ?? 0,
      finishInouseTotal: (json['FinishInouseTotal'] as num?)?.toInt() ?? 0,
      finishOutToday: (json['FinishOutToday'] as num?)?.toInt() ?? 0,
      finishOutTotal: (json['FinishOutTotal'] as num?)?.toInt() ?? 0,
      finishPcsRateToday: (json['FinishPcsRateToday'] as num?)?.toInt() ?? 0,
      finishPcsRateTotal: (json['FinishPcsRateTotal'] as num?)?.toInt() ?? 0,
      finishToday: (json['FinishToday'] as num?)?.toInt() ?? 0,
      finishTotal: (json['FinishTotal'] as num?)?.toInt() ?? 0,
      shipMonthPcs: (json['ShipMonthPcs'] as num?)?.toInt() ?? 0,
      shipMonthRate: (json['ShipMonthRate'] as num?)?.toInt() ?? 0,
      shipTodayPcs: (json['ShipTodayPcs'] as num?)?.toInt() ?? 0,
      shipTodayRate: (json['ShipTodayRate'] as num?)?.toInt() ?? 0,
      shipYearPcs: (json['ShipYearPcs'] as num?)?.toInt() ?? 0,
      shipYearRate: (json['ShipYearRate'] as num?)?.toInt() ?? 0,
      stitchInouseToday: (json['StitchInouseToday'] as num?)?.toInt() ?? 0,
      stitchInouseTotal: (json['StitchInouseTotal'] as num?)?.toInt() ?? 0,
      stitchOutToday: (json['StitchOutToday'] as num?)?.toInt() ?? 0,
      stitchOutTotal: (json['StitchOutTotal'] as num?)?.toInt() ?? 0,
      stitchPcsRateToday: (json['StitchPcsRateToday'] as num?)?.toInt() ?? 0,
      stitchPcsRateTotal: (json['StitchPcsRateTotal'] as num?)?.toInt() ?? 0,
      stitchToday: (json['StitchToday'] as num?)?.toInt() ?? 0,
      stitchTotal: (json['StitchTotal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<ProductionData>> fetchProdData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=prod&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => ProductionData.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class ProdDataSource extends DataGridSource {
  ProdDataSource({required List<ProductionData> prodData}) {
    _dataGridRows = prodData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'ActualToday', value: (data.cuttingToday)),
        DataGridCell<int?>(columnName: 'ActualTotal', value: (data.cuttingTotal)),
        DataGridCell<int?>(columnName: 'StitchInToday', value: (data.stitchInouseToday)),
        DataGridCell<int?>(columnName: 'StitchInTotal', value: (data.stitchInouseTotal)),
        DataGridCell<int?>(columnName: 'StitchOutToday', value: (data.stitchOutToday)),
        DataGridCell<int?>(columnName: 'StitchOutTotal', value: (data.stitchOutTotal)),
        DataGridCell<int?>(columnName: 'StitchPcsToday', value: (data.stitchPcsRateToday)),
        DataGridCell<int?>(columnName: 'StitchPcsTotal', value: (data.stitchPcsRateTotal)),
        DataGridCell<int?>(columnName: 'StitchNetToday', value: (data.stitchToday)),
        DataGridCell<int?>(columnName: 'StitchNetTotal', value: (data.stitchTotal)),
        DataGridCell<int?>(columnName: 'FinishInToday', value: (data.finishInouseToday)),
        DataGridCell<int?>(columnName: 'FinishInTotal', value: (data.finishInouseTotal)),
        DataGridCell<int?>(columnName: 'FinishOutToday', value: (data.finishOutToday)),
        DataGridCell<int?>(columnName: 'FinishOutTotal+ToDate', value: (data.finishOutTotal)),
        DataGridCell<int?>(columnName: 'FinishPcsToday+Today', value: (data.finishPcsRateToday)),
        DataGridCell<int?>(columnName: 'FinishPcsTotal', value: (data.finishPcsRateTotal)),
        DataGridCell<int?>(columnName: 'FinishNetToday', value: (data.finishToday)),
        DataGridCell<int?>(columnName: 'FinishNetTotal', value: (data.finishTotal)),
        DataGridCell<int?>(columnName: 'ShipTodayQty', value: (data.shipTodayPcs)),
        DataGridCell<int?>(columnName: 'ShipTodayAmt', value: (data.shipTodayRate)),
        DataGridCell<int?>(columnName: 'ShipMtdQty', value: (data.shipMonthPcs)),
        DataGridCell<int?>(columnName: 'ShipMtdAmt', value: (data.shipMonthRate)),
        DataGridCell<int?>(columnName: 'ShipYtdQty', value: (data.shipYearPcs)),
        DataGridCell<int?>(columnName: 'ShipYtdAmt', value: (data.shipYearRate)),
      ]);
    }).toList();

    if (prodData.isNotEmpty) {
      final totals = _calculateTotals(prodData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'ActualToday', value: totals['cuttingToday']),
        DataGridCell<int>(columnName: 'ActualTotal', value: totals['cuttingTotal']),
        DataGridCell<int>(columnName: 'StitchInToday', value: totals['stitchInouseToday']),
        DataGridCell<int>(columnName: 'StitchInTotal', value: totals['stitchInouseTotal']),
        DataGridCell<int>(columnName: 'StitchOutToday', value: totals['stitchOutToday']),
        DataGridCell<int>(columnName: 'StitchOutTotal', value: totals['stitchOutTotal']),
        DataGridCell<int>(columnName: 'StitchPcsToday', value: totals['stitchPcsRateToday']),
        DataGridCell<int>(columnName: 'StitchPcsTotal', value: totals['stitchPcsRateTotal']),
        DataGridCell<int>(columnName: 'StitchNetToday', value: totals['stitchToday']),
        DataGridCell<int>(columnName: 'StitchNetTotal', value: totals['stitchTotal']),
        DataGridCell<int>(columnName: 'FinishInToday', value: totals['finishInouseToday']),
        DataGridCell<int>(columnName: 'FinishInTotal', value: totals['finishInouseTotal']),
        DataGridCell<int>(columnName: 'FinishOutToday', value: totals['finishOutToday']),
        DataGridCell<int>(columnName: 'FinishOutTotal', value: totals['finishOutTotal']),
        DataGridCell<int>(columnName: 'FinishPcsToday', value: totals['finishPcsRateToday']),
        DataGridCell<int>(columnName: 'FinishPcsTotal', value: totals['finishPcsRateTotal']),
        DataGridCell<int>(columnName: 'FinishNetToday', value: totals['finishToday']),
        DataGridCell<int>(columnName: 'FinishNetTotal', value: totals['finishTotal']),
        DataGridCell<int>(columnName: 'ShipTodayQty', value: totals['shipTodayPcs']),
        DataGridCell<int>(columnName: 'ShipTodayAmt', value: totals['shipTodayRate']),
        DataGridCell<int>(columnName: 'ShipMtdQty', value: totals['shipMonthPcs']),
        DataGridCell<int>(columnName: 'ShipMtdAmt', value: totals['shipMonthRate']),
        DataGridCell<int>(columnName: 'ShipYtdQty', value: totals['shipYearPcs']),
        DataGridCell<int>(columnName: 'ShipYtdAmt', value: totals['shipYearRate']),
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

  Map<String, dynamic> _calculateTotals(List<ProductionData> data) {
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
      'cuttingToday': data.fold(0, (sum, item) => sum + item.cuttingToday),
      'cuttingTotal': data.fold(0, (sum, item) => sum + item.cuttingTotal),
      'stitchInouseToday': data.fold(0, (sum, item) => sum + item.stitchInouseToday),
      'stitchInouseTotal': data.fold(0, (sum, item) => sum + item.stitchInouseTotal),
      'stitchOutToday': data.fold(0, (sum, item) => sum + item.stitchOutToday),
      'stitchOutTotal': data.fold(0, (sum, item) => sum + item.stitchOutTotal),
      'stitchPcsRateToday': data.fold(0, (sum, item) => sum + item.stitchPcsRateToday),
      'stitchPcsRateTotal': data.fold(0, (sum, item) => sum + item.stitchPcsRateTotal),
      'stitchToday': data.fold(0, (sum, item) => sum + item.stitchToday),
      'stitchTotal': data.fold(0, (sum, item) => sum + item.stitchTotal),
      'finishInouseToday': data.fold(0, (sum, item) => sum + item.finishInouseToday),
      'finishInouseTotal': data.fold(0, (sum, item) => sum + item.finishInouseTotal),
      'finishOutToday': data.fold(0, (sum, item) => sum + item.finishOutToday),
      'finishOutTotal': data.fold(0, (sum, item) => sum + item.finishOutTotal),
      'finishPcsRateToday': data.fold(0, (sum, item) => sum + item.finishPcsRateToday),
      'finishPcsRateTotal': data.fold(0, (sum, item) => sum + item.finishPcsRateTotal),
      'finishToday': data.fold(0, (sum, item) => sum + item.finishToday),
      'finishTotal': data.fold(0, (sum, item) => sum + item.finishTotal),
      'shipTodayPcs': data.fold(0, (sum, item) => sum + item.shipTodayPcs),
      'shipTodayRate': data.fold(0, (sum, item) => sum + item.shipTodayRate),
      'shipMonthPcs': data.fold(0, (sum, item) => sum + item.shipMonthPcs),
      'shipMonthRate': data.fold(0, (sum, item) => sum + item.shipMonthRate),
      'shipYearPcs': data.fold(0, (sum, item) => sum + item.shipYearPcs),
      'shipYearRate': data.fold(0, (sum, item) => sum + item.shipYearRate),
    };
  }
}

// Main widget
class ProductionDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const ProductionDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<ProductionDataTable> createState() => _ProductionDataTableState();
}

class _ProductionDataTableState extends State<ProductionDataTable> {
  late Future<List<ProductionData>> prodData;

  @override
  void initState() {
    super.initState();
    prodData = fetchProdData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductionData>>(
      future: prodData,
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
              source: ProdDataSource(prodData: snapshot.data!),
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
                    columnNames: ['ActualToday','ActualTotal'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Actual Cutting',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchInToday',
                      'StitchInTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch\nIn House',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchOutToday',
                      'StitchOutTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch\nOut House',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchPcsToday',
                      'StitchPcsTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch\nPiece Rate',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchNetToday',
                      'StitchNetTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Stitch\nNet',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishInToday',
                      'FinishInTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish\nIn House',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishOutToday',
                      'FinishOutTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish\nOut House',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishPcsToday',
                      'FinishPcsTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish\nPiece Rate',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishNetToday',
                      'FinishNetTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finish\nNet',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'ShipTodayQty',
                      'ShipTodayAmt',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Ship\nToday',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'ShipMtdQty',
                      'ShipMtdAmt',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Ship\nMTD',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'ShipYtdQty',
                      'ShipYtdAmt',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Ship\nYTD',
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
                    columnName: 'ActualToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ActualTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchInToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchInTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchOutToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchOutTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchPcsToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchPcsTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchNetToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchNetTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishInToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishInTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishOutToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishOutTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishPcsToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishPcsTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishNetToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishNetTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipTodayQty',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Qty',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipTodayAmt',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Amount',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipMtdQty',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Qty',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipMtdAmt',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Amount',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipYtdQty',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Qty',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ShipYtdAmt',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Amount',
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
