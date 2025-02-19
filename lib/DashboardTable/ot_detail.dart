import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class OtDetail {
  final int cuttingOtAmtFTD;
  final int cuttingOtAmtMTD;
  final int cuttingOthrsFTD;
  final int cuttingOthrsMTD;
  final int cuttingPerHrFTD;
  final int cuttingPerHrMTD;
  final int finishOtAmtFTD;
  final int finishOtAmtMTD;
  final int finishOthrsFTD;
  final int finishOthrsMTD;
  final int finishPerHrFTD;
  final int finishPerHrMTD;
  final int stitchOtAmtFTD;
  final int stitchOtAmtMTD;
  final int stitchOthrsFTD;
  final int stitchOthrsMTD;
  final int stitchPerHrFTD;
  final int stitchPerHrMTD;
  final int todayOtAmtFTD;
  final int todayOtAmtMTD;
  final int todayOthrsFTD;
  final int todayOthrsMTD;
  final int todayPerHrFTD;
  final int todayPerHrMTD;
  final String unitShortCode;

  OtDetail({
    required this.cuttingOtAmtFTD,
    required this.cuttingOtAmtMTD,
    required this.cuttingOthrsFTD,
    required this.cuttingOthrsMTD,
    required this.cuttingPerHrFTD,
    required this.cuttingPerHrMTD,
    required this.finishOtAmtFTD,
    required this.finishOtAmtMTD,
    required this.finishOthrsFTD,
    required this.finishOthrsMTD,
    required this.finishPerHrFTD,
    required this.finishPerHrMTD,
    required this.stitchOtAmtFTD,
    required this.stitchOtAmtMTD,
    required this.stitchOthrsFTD,
    required this.stitchOthrsMTD,
    required this.stitchPerHrFTD,
    required this.stitchPerHrMTD,
    required this.todayOtAmtFTD,
    required this.todayOtAmtMTD,
    required this.todayOthrsFTD,
    required this.todayOthrsMTD,
    required this.todayPerHrFTD,
    required this.todayPerHrMTD,
    required this.unitShortCode,
  });

  factory OtDetail.fromJson(Map<String, dynamic> json) {
    return OtDetail(
      cuttingOtAmtFTD: (json['CuttingOtAmtFTD'] as num?)?.toInt() ?? 0,
      cuttingOtAmtMTD: (json['CuttingOtAmtMTD'] as num?)?.toInt() ?? 0,
      cuttingOthrsFTD: (json['CuttingOthrsFTD'] as num?)?.toInt() ?? 0,
      cuttingOthrsMTD: (json['CuttingOthrsMTD'] as num?)?.toInt() ?? 0,
      cuttingPerHrFTD: (json['CuttingPerHrFTD'] as num?)?.toInt() ?? 0,
      cuttingPerHrMTD: (json['CuttingPerHrMTD'] as num?)?.toInt() ?? 0,
      finishOtAmtFTD: (json['FinishOtAmtFTD'] as num?)?.toInt() ?? 0,
      finishOtAmtMTD: (json['FinishOtAmtMTD'] as num?)?.toInt() ?? 0,
      finishOthrsFTD: (json['FinishOthrsFTD'] as num?)?.toInt() ?? 0,
      finishOthrsMTD: (json['FinishOthrsMTD'] as num?)?.toInt() ?? 0,
      finishPerHrFTD: (json['FinishPerHrFTD'] as num?)?.toInt() ?? 0,
      finishPerHrMTD: (json['FinishPerHrMTD'] as num?)?.toInt() ?? 0,
      stitchOtAmtFTD: (json['StitchOtAmtFTD'] as num?)?.toInt() ?? 0,
      stitchOtAmtMTD: (json['StitchOtAmtMTD'] as num?)?.toInt() ?? 0,
      stitchOthrsFTD: (json['StitchOthrsFTD'] as num?)?.toInt() ?? 0,
      stitchOthrsMTD: (json['StitchOthrsMTD'] as num?)?.toInt() ?? 0,
      stitchPerHrFTD: (json['StitchPerHrFTD'] as num?)?.toInt() ?? 0,
      stitchPerHrMTD: (json['StitchPerHrMTD'] as num?)?.toInt() ?? 0,
      todayOtAmtFTD: (json['TotalOtAmtFTD'] as num?)?.toInt() ?? 0,
      todayOtAmtMTD: (json['TotalOtAmtMTD'] as num?)?.toInt() ?? 0,
      todayOthrsFTD: (json['TotalOthrsFTD'] as num?)?.toInt() ?? 0,
      todayOthrsMTD: (json['TotalOthrsMTD'] as num?)?.toInt() ?? 0,
      todayPerHrFTD: (json['TotalPerHrFTD'] as num?)?.toInt() ?? 0,
      todayPerHrMTD: (json['TotalPerHrMTD'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitCode'] ?? '',
    );
  }
}

Future<List<OtDetail>> fetchOtData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=ot&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => OtDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class OTDataSource extends DataGridSource {
  OTDataSource({required List<OtDetail> oTData}) {
    _dataGridRows = oTData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'CutHrsFTD', value: (data.cuttingOthrsFTD)),
        DataGridCell<int?>(columnName: 'CutHrsMTD', value: (data.cuttingOthrsMTD)),
        DataGridCell<int?>(columnName: 'CutValFTD', value: (data.cuttingOtAmtFTD)),
        DataGridCell<int?>(columnName: 'CutValMTD', value: (data.cuttingOtAmtMTD)),
        DataGridCell<int?>(columnName: 'CutPerFTD', value: (data.cuttingPerHrFTD)),
        DataGridCell<int?>(columnName: 'CutPerMTD', value: (data.cuttingPerHrMTD)),
        DataGridCell<int?>(columnName: 'StitchHrsFTD+Today', value: (data.stitchOthrsFTD)),
        DataGridCell<int?>(columnName: 'StitchHrsMTD', value: (data.stitchOthrsMTD)),
        DataGridCell<int?>(columnName: 'StitchValFTD', value: (data.stitchOtAmtFTD)),
        DataGridCell<int?>(columnName: 'StitchValMTD+ToDate', value: (data.stitchOtAmtMTD)),
        DataGridCell<int?>(columnName: 'StitchPerFTD', value: (data.stitchPerHrFTD)),
        DataGridCell<int?>(columnName: 'StitchPerMTD', value: (data.stitchPerHrMTD)),
        DataGridCell<int?>(columnName: 'FinishHrsFTD', value: (data.finishOthrsFTD)),
        DataGridCell<int?>(columnName: 'FinishHrsMTD', value: (data.finishOthrsMTD)),
        DataGridCell<int?>(columnName: 'FinishValFTD', value: (data.finishOtAmtFTD)),
        DataGridCell<int?>(columnName: 'FinishValMTD', value: (data.finishOtAmtMTD)),
        DataGridCell<int?>(columnName: 'FinishPerFTD', value: (data.finishPerHrFTD)),
        DataGridCell<int?>(columnName: 'FinishPerMTD', value: (data.finishPerHrMTD)),
        DataGridCell<int?>(columnName: 'FactoryHrsFTD', value: (data.todayOthrsFTD)),
        DataGridCell<int?>(columnName: 'FactoryHrsMTD', value: (data.todayOthrsMTD)),
        DataGridCell<int?>(columnName: 'FactoryValFTD', value: (data.todayOtAmtFTD)),
        DataGridCell<int?>(columnName: 'FactoryValMTD', value: (data.todayOtAmtMTD)),
        DataGridCell<int?>(columnName: 'FactoryPerFTD', value: (data.todayPerHrFTD)),
        DataGridCell<int?>(columnName: 'FactoryPerMTD', value: (data.todayPerHrMTD)),
      ]);
    }).toList();

    if (oTData.isNotEmpty) {
      final totals = _calculateTotals(oTData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'CutHrsFTD', value: totals['cuttingOthrsFTD']),
        DataGridCell<int>(columnName: 'CutHrsMTD', value: totals['cuttingOthrsMTD']),
        DataGridCell<int>(columnName: 'CutValFTD', value: totals['cuttingOtAmtFTD']),
        DataGridCell<int>(columnName: 'CutValMTD', value: totals['cuttingOtAmtMTD']),
        DataGridCell<int>(columnName: 'CutPerFTD', value: totals['cuttingPerHrFTD']),
        DataGridCell<int>(columnName: 'CutPerMTD', value: totals['cuttingPerHrMTD']),
        DataGridCell<int>(columnName: 'StitchHrsFTD', value: totals['stitchOthrsFTD']),
        DataGridCell<int>(columnName: 'StitchHrsMTD', value: totals['stitchOthrsMTD']),
        DataGridCell<int>(columnName: 'StitchValFTD', value: totals['stitchOtAmtFTD']),
        DataGridCell<int>(columnName: 'StitchValMTD', value: totals['stitchOtAmtMTD']),
        DataGridCell<int>(columnName: 'StitchPerFTD', value: totals['stitchPerHrFTD']),
        DataGridCell<int>(columnName: 'StitchPerMTD', value: totals['stitchPerHrMTD']),
        DataGridCell<int>(columnName: 'FinishHrsFTD', value: totals['finishOthrsFTD']),
        DataGridCell<int>(columnName: 'FinishHrsMTD', value: totals['finishOthrsMTD']),
        DataGridCell<int>(columnName: 'FinishValFTD', value: totals['finishOtAmtFTD']),
        DataGridCell<int>(columnName: 'FinishValMTD', value: totals['finishOtAmtMTD']),
        DataGridCell<int>(columnName: 'FinishPerFTD', value: totals['finishPerHrFTD']),
        DataGridCell<int>(columnName: 'FinishPerMTD', value: totals['finishPerHrMTD']),
        DataGridCell<int>(columnName: 'FactoryHrsFTD', value: totals['todayOthrsFTD']),
        DataGridCell<int>(columnName: 'FactoryHrsMTD', value: totals['todayOthrsMTD']),
        DataGridCell<int>(columnName: 'FactoryValFTD', value: totals['todayOtAmtFTD']),
        DataGridCell<int>(columnName: 'FactoryValMTD', value: totals['todayOtAmtMTD']),
        DataGridCell<int>(columnName: 'FactoryPerFTD', value: totals['todayPerHrFTD']),
        DataGridCell<int>(columnName: 'FactoryPerMTD', value: totals['todayPerHrMTD']),
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

        // Check if this is the column you want to make clickable
        bool isClickableColumn = dataGridCell.columnName == 'UnitShortCode';

        return Container(
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: GestureDetector(
            onTap: isClickableColumn && !isTotalRow
                ? () {
              // Retrieve and print values from the entire row
              String unitShortCode = row.getCells().firstWhere((cell) => cell.columnName == 'UnitShortCode').value.toString();
              String anotherValue = row.getCells().firstWhere((cell) => cell.columnName == 'CutHrsFTD').value.toString();
              String another1Value = row.getCells().firstWhere((cell) => cell.columnName == 'CutHrsMTD').value.toString();

              print('Clicked on UnitShortCode: $unitShortCode');
              print('Another value from the same row: $anotherValue');
              print('Another value from the same row: $another1Value');

              // You can use these values to trigger actions, navigate, or update UI
            }
                : null,
            child: Text(
              dataGridCell.value.toString(),
              textAlign: alignment == Alignment.centerLeft ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                fontSize: isTotalRow ? 16 : 14, // Adjust font size dynamically
                fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
                color: isClickableColumn && !isTotalRow ? Colors.black : Colors.black, // Optional for clickable styling
                //decoration: isClickableColumn && !isTotalRow ? TextDecoration.underline : null, // Optional for clickable styling
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Map<String, dynamic> _calculateTotals(List<OtDetail> data) {
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
      'cuttingOthrsFTD': data.fold(0, (sum, item) => sum + item.cuttingOthrsFTD),
      'cuttingOthrsMTD': data.fold(0, (sum, item) => sum + item.cuttingOthrsMTD),
      'cuttingOtAmtFTD': data.fold(0, (sum, item) => sum + item.cuttingOtAmtFTD),
      'cuttingOtAmtMTD': data.fold(0, (sum, item) => sum + item.cuttingOtAmtMTD),
      'cuttingPerHrFTD': data.fold(0, (sum, item) => sum + item.cuttingPerHrFTD),
      'cuttingPerHrMTD': data.fold(0, (sum, item) => sum + item.cuttingPerHrMTD),
      'stitchOthrsFTD': data.fold(0, (sum, item) => sum + item.stitchOthrsFTD),
      'stitchOthrsMTD': data.fold(0, (sum, item) => sum + item.stitchOthrsMTD),
      'stitchOtAmtFTD': data.fold(0, (sum, item) => sum + item.stitchOtAmtFTD),
      'stitchOtAmtMTD': data.fold(0, (sum, item) => sum + item.stitchOtAmtMTD),
      'stitchPerHrFTD': data.fold(0, (sum, item) => sum + item.stitchPerHrFTD),
      'stitchPerHrMTD': data.fold(0, (sum, item) => sum + item.stitchPerHrMTD),
      'finishOthrsFTD': data.fold(0, (sum, item) => sum + item.finishOthrsFTD),
      'finishOthrsMTD': data.fold(0, (sum, item) => sum + item.finishOthrsMTD),
      'finishOtAmtFTD': data.fold(0, (sum, item) => sum + item.finishOtAmtFTD),
      'finishOtAmtMTD': data.fold(0, (sum, item) => sum + item.finishOtAmtMTD),
      'finishPerHrFTD': data.fold(0, (sum, item) => sum + item.finishPerHrFTD),
      'finishPerHrMTD': data.fold(0, (sum, item) => sum + item.finishPerHrMTD),
      'todayOthrsFTD': data.fold(0, (sum, item) => sum + item.todayOthrsFTD),
      'todayOthrsMTD': data.fold(0, (sum, item) => sum + item.todayOthrsMTD),
      'todayOtAmtFTD': data.fold(0, (sum, item) => sum + item.todayOtAmtFTD),
      'todayOtAmtMTD': data.fold(0, (sum, item) => sum + item.todayOtAmtMTD),
      'todayPerHrFTD': data.fold(0, (sum, item) => sum + item.todayPerHrFTD),
      'todayPerHrMTD': data.fold(0, (sum, item) => sum + item.todayPerHrMTD),
    };
  }
}

// Main widget
class OTDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const OTDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<OTDataTable> createState() => _OTDataTableState();
}

class _OTDataTableState extends State<OTDataTable> {
  late Future<List<OtDetail>> oTData;

  @override
  void initState() {
    super.initState();
    oTData = fetchOtData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OtDetail>>(
      future: oTData,
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
              source: OTDataSource(oTData: snapshot.data!),
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
                    columnNames: ['CutHrsFTD','CutHrsMTD'],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Cutting\nOT Hrs',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'CutValFTD',
                      'CutValMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Cutting\nOT Val',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'CutPerFTD',
                      'CutPerMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Cutting\nPer/HR OT',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchHrsFTD',
                      'StitchHrsMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Bare Stitch\nOT Hrs',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchValFTD',
                      'StitchValMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Bare Stitch\nOT Val',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchPerFTD',
                      'StitchPerMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Bare Stitch\nPer/HR OT',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishHrsFTD',
                      'FinishHrsMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finishing\nOT Hrs',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishValFTD',
                      'FinishValMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finishing\nOT Val',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishPerFTD',
                      'FinishPerMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Finishing\nPer/HR OT',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FactoryHrsFTD',
                      'FactoryHrsMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Factory\nOT Hrs',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FactoryValFTD',
                      'FactoryValMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Factory\nOT Val',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FactoryPerFTD',
                      'FactoryPerMTD',
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'Factory\nPer/HR OT',
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
                    columnName: 'CutHrsFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CutHrsMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CutValFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CutValMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CutPerFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'CutPerMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchHrsFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchHrsMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchValFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchValMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchPerFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'StitchPerMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishHrsFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishHrsMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishValFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishValMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishPerFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FinishPerMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryHrsFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryHrsMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryValFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryValMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryPerFTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('FTD',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FactoryPerMTD',
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('MTD',
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
