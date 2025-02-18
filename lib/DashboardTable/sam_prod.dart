import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class SamProdDetail {
  final double avgSam;
  final int stitchInHouseSam;
  final int stitchInHouseTotal;
  final int stitchOutSam;
  final int stitchOutTotal;
  final int stitchPcsRateSam;
  final int stitchPcsRateTotal;
  final int stitchSam;
  final int stitchTotal;
  final double todayCost;
  final double totalCost;
  final String unitShortCode;

  SamProdDetail({
    required this.avgSam,
    required this.stitchInHouseSam,
    required this.stitchInHouseTotal,
    required this.stitchOutSam,
    required this.stitchOutTotal,
    required this.stitchPcsRateSam,
    required this.stitchPcsRateTotal,
    required this.stitchSam,
    required this.stitchTotal,
    required this.todayCost,
    required this.totalCost,
    required this.unitShortCode,
  });

  factory SamProdDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }

    return SamProdDetail(
      avgSam: toTwoDecimalPlaces((json['AvgSam'] as num?)?.toDouble() ?? 0.0),
      stitchInHouseSam: (json['StitchInHouseSam'] as num?)?.toInt() ?? 0,
      stitchInHouseTotal: (json['StitchInHouseTotal'] as num?)?.toInt() ?? 0,
      stitchOutSam: (json['StitchOutSam'] as num?)?.toInt() ?? 0,
      stitchOutTotal: (json['StitchOutTotal'] as num?)?.toInt() ?? 0,
      stitchPcsRateSam: (json['StitchPcsrateSam'] as num?)?.toInt() ?? 0,
      stitchPcsRateTotal: (json['StitchPcsrateTotal'] as num?)?.toInt() ?? 0,
      stitchSam: (json['StitchSam'] as num?)?.toInt() ?? 0,
      stitchTotal: (json['StitchTotal'] as num?)?.toInt() ?? 0,
      todayCost: toTwoDecimalPlaces((json['TodayCost'] as num?)?.toDouble() ?? 0.0),
      totalCost: toTwoDecimalPlaces((json['TotalCost'] as num?)?.toDouble() ?? 0.0),
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<SamProdDetail>> fetchSamData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=sam&from=$from&to=$to&units=$units'),
  );
  if (kDebugMode) {
    print('http://14.142.248.34:10008/management?proce_type=sam&from=$from&to=$to&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => SamProdDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class SamProdDataSource extends DataGridSource {
  SamProdDataSource({required List<SamProdDetail> finishData}) {
    _dataGridRows = finishData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int>(columnName: 'InHouseQty', value: data.stitchInHouseTotal),
        DataGridCell<int>(columnName: 'InHouseSam', value: data.stitchInHouseSam),
        DataGridCell<int>(columnName: 'OutHouseQty', value: data.stitchOutTotal),
        DataGridCell<int>(columnName: 'OutHouseSam', value: data.stitchOutSam),
        DataGridCell<int>(columnName: 'PieceRateQty', value: data.stitchPcsRateTotal),
        DataGridCell<int>(columnName: 'PieceRateSam', value: data.stitchPcsRateSam),
        DataGridCell<int>(columnName: 'TotalQty', value: data.stitchTotal),
        DataGridCell<int>(columnName: 'TotalSam', value: data.stitchSam),
        DataGridCell<double>(columnName: 'AvgSam', value: data.avgSam),
        DataGridCell<double>(columnName: 'TodayCost/Sam', value: data.todayCost),
        DataGridCell<double>(columnName: 'TotalCost/Sam', value: data.totalCost),

      ]);
    }).toList();

    if (finishData.isNotEmpty) {
      final totals = _calculateTotals(finishData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'InHouseQty', value: totals['stitchInHouseTotal']),
        DataGridCell<int>(columnName: 'InHouseSam', value: totals['stitchInHouseSam']),
        DataGridCell<int>(columnName: 'OutHouseQty', value: totals['stitchOutTotal']),
        DataGridCell<int>(columnName: 'OutHouseSam', value: totals['stitchOutSam']),
        DataGridCell<int>(columnName: 'PieceRateQty', value: totals['stitchPcsRateTotal']),
        DataGridCell<int>(columnName: 'PieceRateSam', value: totals['stitchPcsRateSam']),
        DataGridCell<int>(columnName: 'TotalQty', value: totals['stitchTotal']),
        DataGridCell<int>(columnName: 'TotalSam', value: totals['stitchSam']),
        DataGridCell<double>(columnName: 'AvgSam', value: totals['avgSam']),
        DataGridCell<double>(columnName: 'TodayCost/Sam', value: totals['todayCost']),
        DataGridCell<double>(columnName: 'TotalCost/Sam', value: totals['totalCost']),
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

  Map<String, dynamic> _calculateTotals(List<SamProdDetail> data) {
    if (data.isEmpty) return {}; // Return an empty map if no data is present

    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    double calculateAverage(List<double> values) {
      var filteredValues = values.where((value) => value > 0).toList();
      if (filteredValues.isEmpty) return 0.0; // Avoid division by 0
      return roundToTwo(filteredValues.reduce((a, b) => a + b) / filteredValues.length);
    }

    return {
      'avgSam': calculateAverage(data.map((item) => item.avgSam).toList()),
      'stitchInHouseSam': data.fold(0, (sum, item) => sum + (item.stitchInHouseSam.toInt())),
      'stitchInHouseTotal': data.fold(0, (sum, item) => sum + (item.stitchInHouseTotal.toInt())),
      'stitchOutSam': data.fold(0, (sum, item) => sum + (item.stitchOutSam.toInt())),
      'stitchOutTotal': data.fold(0, (sum, item) => sum + (item.stitchOutTotal.toInt())),
      'stitchPcsRateSam': data.fold(0, (sum, item) => sum + (item.stitchPcsRateSam.toInt())),
      'stitchPcsRateTotal': data.fold(0, (sum, item) => sum + (item.stitchPcsRateTotal.toInt())),
      'stitchSam': data.fold(0, (sum, item) => sum + (item.stitchSam.toInt())),
      'stitchTotal': data.fold(0, (sum, item) => sum + (item.stitchTotal.toInt())),
      'todayCost': calculateAverage(data.map((item) => item.todayCost).toList()),
      'totalCost': calculateAverage(data.map((item) => item.totalCost).toList()),
    };
  }
}

// Main widget
class SamProdTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const SamProdTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<SamProdTable> createState() => _SamProdTableState();
}

class _SamProdTableState extends State<SamProdTable> {
  late Future<List<SamProdDetail>> samProd;

  @override
  void initState() {
    super.initState();
    samProd = fetchSamData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SamProdDetail>>(
      future: samProd,
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
                source: SamProdDataSource(finishData: snapshot.data!),
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
                      columnName: 'InHouseQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('In House\nQty',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'InHouseSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('In House\nSam',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OutHouseQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Out House\nQty',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OutHouseSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Out House\nSam',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'PieceRateQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Piece Rate\nQty',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'PieceRateSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Piece Rate\nSAm',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TotalQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Total\nQty',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TotalSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Total\nSam',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'AvgSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("AVG\nSam",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TodayCost/Sam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Today's\nCost/Sam",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'TotalCost/Sam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Total\nCost/Sam",
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
