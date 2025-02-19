import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class EnergyDetail {
  final int dieselValueToday;
  final int dieselValueTotal;
  final int eelectricValueToday;
  final int eelectricValueTotal;
  final int pngValueToday;
  final int pngValueTotal;
  final int solorValueToday;
  final int solorValueTotal;
  final int valueToday;
  final int valueTotal;
  final String unitShortCode;

  EnergyDetail({
    required this.dieselValueToday,
    required this.dieselValueTotal,
    required this.eelectricValueToday,
    required this.eelectricValueTotal,
    required this.pngValueToday,
    required this.pngValueTotal,
    required this.solorValueToday,
    required this.solorValueTotal,
    required this.valueToday,
    required this.valueTotal,
    required this.unitShortCode,
  });

  factory EnergyDetail.fromJson(Map<String, dynamic> json) {
    return EnergyDetail(
      dieselValueToday: (json['DieselValueToday'] as num?)?.toInt() ?? 0,
      dieselValueTotal: (json['DieselValueTotal'] as num?)?.toInt() ?? 0,
      eelectricValueToday: (json['EelectricValueToday'] as num?)?.toInt() ?? 0,
      eelectricValueTotal: (json['EelectricValueTotal'] as num?)?.toInt() ?? 0,
      pngValueToday: (json['PngValueToday'] as num?)?.toInt() ?? 0,
      pngValueTotal: (json['PngValueTotal'] as num?)?.toInt() ?? 0,
      solorValueToday: (json['SolorValueToday'] as num?)?.toInt() ?? 0,
      solorValueTotal: (json['SolorValueTotal'] as num?)?.toInt() ?? 0,
      valueToday: (json['ValueToday'] as num?)?.toInt() ?? 0,
      valueTotal: (json['ValueTotal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<EnergyDetail>> fetchEnergyCost(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=energy&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => EnergyDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class EnergySource extends DataGridSource {
  EnergySource({required List<EnergyDetail> energyData}) {
    _dataGridRows = energyData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'DieselToday', value: (data.dieselValueToday)),
        DataGridCell<int?>(columnName: 'DieselTotal', value: (data.dieselValueTotal)),
        DataGridCell<int?>(columnName: 'ElectricityToday', value: (data.eelectricValueToday)),
        DataGridCell<int?>(columnName: 'ElectricityTotal', value: (data.eelectricValueTotal)),
        DataGridCell<int?>(columnName: 'PNGToday', value: (data.pngValueToday)),
        DataGridCell<int?>(columnName: 'PNGTotal', value: (data.pngValueTotal)),
        DataGridCell<int?>(columnName: 'SolarToday', value: (data.solorValueToday)),
        DataGridCell<int?>(columnName: 'SolarTotal', value: (data.solorValueTotal)),
        DataGridCell<int?>(columnName: 'NetToday', value: (data.valueToday)),
        DataGridCell<int?>(columnName: 'NetTotal', value: (data.valueTotal)),
      ]);
    }).toList();

    if (energyData.isNotEmpty) {
      final totals = _calculateTotals(energyData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'DieselToday', value: totals['dieselValueToday']),
        DataGridCell<int>(columnName: 'DieselTotal', value: totals['dieselValueTotal']),
        DataGridCell<int>(columnName: 'ElectricityToday', value: totals['eelectricValueToday']),
        DataGridCell<int>(columnName: 'ElectricityTotal', value: totals['eelectricValueTotal']),
        DataGridCell<int>(columnName: 'PNGToday', value: totals['pngValueToday']),
        DataGridCell<int>(columnName: 'PNGTotal', value: totals['pngValueTotal']),
        DataGridCell<int>(columnName: 'SolarToday', value: totals['solorValueToday']),
        DataGridCell<int>(columnName: 'SolarTotal', value: totals['solorValueTotal']),
        DataGridCell<int>(columnName: 'NetToday', value: totals['valueToday']),
        DataGridCell<int>(columnName: 'NetTotal', value: totals['valueTotal']),
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

  Map<String, dynamic> _calculateTotals(List<EnergyDetail> data) {
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
      'dieselValueToday': data.fold(0, (sum, item) => sum + item.dieselValueToday),
      'dieselValueTotal': data.fold(0, (sum, item) => sum + item.dieselValueTotal),
      'eelectricValueToday': data.fold(0, (sum, item) => sum + item.eelectricValueToday),
      'eelectricValueTotal': data.fold(0, (sum, item) => sum + item.eelectricValueTotal),
      'pngValueToday': data.fold(0, (sum, item) => sum + item.pngValueToday),
      'pngValueTotal': data.fold(0, (sum, item) => sum + item.pngValueTotal),
      'solorValueToday': data.fold(0, (sum, item) => sum + item.solorValueToday),
      'solorValueTotal': data.fold(0, (sum, item) => sum + item.solorValueTotal),
      'valueToday': data.fold(0, (sum, item) => sum + item.valueToday),
      'valueTotal': data.fold(0, (sum, item) => sum + item.valueTotal),
    };
  }
}

// Main widget
class EnergyDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const EnergyDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<EnergyDataTable> createState() => _EnergyDataTableState();
}

class _EnergyDataTableState extends State<EnergyDataTable> {
  late Future<List<EnergyDetail>> energyData;

  @override
  void initState() {
    super.initState();
    energyData = fetchEnergyCost(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EnergyDetail>>(
      future: energyData,
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
              source: EnergySource(energyData: snapshot.data!),
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
                      'DieselToday',
                      'DieselTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Diesel',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'ElectricityToday',
                      'ElectricityTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Electricity',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'PNGToday',
                      'PNGTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'PNG',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'SolarToday',
                      'SolarTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Solar',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'NetToday',
                      'NetTotal',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Total',
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
                    columnName: 'DieselToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'DieselTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ElectricityToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ElectricityTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PNGToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'PNGTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'SolarToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'SolarTotal',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Total',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'NetToday',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Today',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'NetTotal',
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
