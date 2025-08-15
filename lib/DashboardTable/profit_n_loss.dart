import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../ExtraFunction/lottie_loading.dart';
import '../Stylewise/cutting_style_wise.dart';
import '../Stylewise/finishing_style_wise.dart';
import '../Stylewise/stitching_style_wise.dart';

class ProfitAndLossData {
  String unitShortCode;
  String unitShortCode1;
  String operationHead;
  int todayCutOutput;
  int todayCutProfit;
  int totalCutPtofit;
  double todayCutCost;
  int todayStitchOutput;
  int todayStitchProfit;
  int totalStitchProfit;
  double planTodayEff;
  double planAvgEff;
  double stitchTodayEff;
  double stitchAvgEff;
  int todayFinishOutput;
  int todayFinishProfit;
  int totalFinishProfit;
  double todayFinishCost;
  int todayActualPackingOutput;
  int variance;
  int todayProfit;
  int totalProfit;
  String unitCode;

  ProfitAndLossData({
    required this.stitchAvgEff,
    required this.planAvgEff,
    required this.planTodayEff,
    required this.stitchTodayEff,
    required this.todayActualPackingOutput,
    required this.todayCutCost,
    required this.todayCutOutput,
    required this.todayCutProfit,
    required this.todayFinishCost,
    required this.todayFinishOutput,
    required this.todayFinishProfit,
    required this.todayProfit,
    required this.todayStitchOutput,
    required this.todayStitchProfit,
    required this.totalCutPtofit,
    required this.totalFinishProfit,
    required this.totalProfit,
    required this.totalStitchProfit,
    required this.unitCode,
    required this.unitShortCode,
    required this.unitShortCode1,
    required this.operationHead,
    required this.variance,
  });

  factory ProfitAndLossData.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return ProfitAndLossData(
      stitchAvgEff: toTwoDecimalPlaces((json['StitchAvgEff'] as num?)?.toDouble() ?? 0.0),
      planAvgEff: toTwoDecimalPlaces((json['PlanAvgEff'] as num?)?.toDouble() ?? 0.0),
      planTodayEff: toTwoDecimalPlaces((json['PlanTodayEff'] as num?)?.toDouble() ?? 0.0),
      stitchTodayEff: toTwoDecimalPlaces((json['StitchTodayEff'] as num?)?.toDouble() ?? 0.0),
      todayCutCost: toTwoDecimalPlaces((json['TodayCutCost'] as num?)?.toDouble() ?? 0.0),
      todayFinishCost: (json['TodayFinishCost'] as num?)?.toDouble() ?? 0.0,
      todayCutOutput: (json['TodayCutOutput'] as num?)?.toInt() ?? 0,
      todayCutProfit: (json['TodayCutProfit'] as num?)?.toInt() ?? 0,
      totalCutPtofit: (json['TotalCutPtofit'] as num?)?.toInt() ?? 0,
      todayStitchOutput: (json['TodayStitchOutput'] as num?)?.toInt() ?? 0,
      todayStitchProfit: (json['TodayStitchProfit'] as num?)?.toInt() ?? 0,
      totalStitchProfit: (json['TotalStitchProfit'] as num?)?.toInt() ?? 0,
      todayFinishOutput: (json['TodayFinishOutput'] as num?)?.toInt() ?? 0,
      todayFinishProfit: (json['TodayFinishProfit'] as num?)?.toInt() ?? 0,
      totalFinishProfit: (json['TotalFinishProfit'] as num?)?.toInt() ?? 0,
      todayActualPackingOutput: (json['TodayActualPackingOutput'] as num?)?.toInt() ?? 0,
      variance: (json['Variance'] as num?)?.toInt() ?? 0,
      todayProfit: (json['TodayProfit'] as num?)?.toInt() ?? 0,
      totalProfit: (json['TotalProfit'] as num?)?.toInt() ?? 0,
      unitCode: json['UnitCode'] ?? '',
      unitShortCode: json['UnitShortCode'] ?? '',
      unitShortCode1: json['UnitShortCode1'] ?? '',
      operationHead: json['OperationHead'] ?? '',
    );
  }
}
  // print('${TBaseURL.baseUrl}mngmnt_review_vg?type=Pnl&unit=$vgUnit&fromDate=$from&toDate=$to');

Future<List<ProfitAndLossData>> fetchProfitAndLossData(String from, String to, String units, String vgUnit)
async {
  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}mngmnt_review_vg?type=Pnl&unitVg=$vgUnit&fromDate=$from&toDate=$to&unit=$units&proc_type=MngmntReviewPnL'),
  );
  if (kDebugMode) {
    print('${TBaseURL.baseUrl}mngmnt_review_vg?type=Pnl&unitVg=$vgUnit&fromDate=$from&toDate=$to&unit=$units&proc_type=MngmntReviewPnL');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ProfitAndLossData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}


class PnLDataSource extends DataGridSource {
  final String from;
  final String to;
  final BuildContext context;

  PnLDataSource({required List<ProfitAndLossData> pnlData , required this.from, required this.to , required this.context}) {
    _dataGridRows = pnlData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<String>(
            columnName: 'UnitShortCode1', value: data.unitShortCode1),
        DataGridCell<String>(
            columnName: 'Team', value: data.operationHead),
        DataGridCell<int?>(columnName: 'CutTodayOutput', value: (data.todayCutOutput)),
        DataGridCell<int?>(columnName: 'CutTodayPnL', value: (data.todayCutProfit)),
        DataGridCell<int?>(columnName: 'CutTotalPnL', value: (data.totalCutPtofit)),
        DataGridCell<double?>(columnName: 'CutCostPerQty', value: double.parse((data.todayCutCost).toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'StitchTodayOutput', value: (data.todayStitchOutput)),
        DataGridCell<int?>(columnName: 'StitchTodayPnL', value: (data.todayStitchProfit)),
        DataGridCell<int?>(columnName: 'StitchTotalPnL', value: (data.totalStitchProfit)),
        DataGridCell<double?>(columnName: 'TodayPlanEff', value: double.parse((data.planTodayEff).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'AvgPlanEff', value: double.parse((data.planAvgEff).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'TodayActEff', value: double.parse((data.stitchTodayEff).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'AvgActEff', value: double.parse((data.stitchAvgEff).toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'FinishTodayOutput', value: (data.todayFinishOutput)),
        DataGridCell<int?>(columnName: 'FinishTodayPnL', value: (data.todayFinishProfit)),
        DataGridCell<int?>(columnName: 'FinishTotalPnL', value: (data.totalFinishProfit)),
        DataGridCell<double?>(columnName: 'FinishCotPerQty', value: double.parse((data.todayFinishCost).toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'TodayPack', value: (data.todayActualPackingOutput)),
        DataGridCell<int?>(columnName: 'Variance', value: (data.variance)),
        DataGridCell<int?>(columnName: 'TodayPnL', value: (data.todayProfit)),
        DataGridCell<int?>(columnName: 'TotalPnL', value: (data.totalProfit)),
      ]);
    }).toList();

    if (pnlData.isNotEmpty) {
      final totals = _calculateTotals(pnlData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        const DataGridCell<String>(columnName: 'UnitShortCode1', value: ''),
        const DataGridCell<String>(columnName: 'Team', value: ''),
        DataGridCell<int>(columnName: 'CutTodayOutput', value: totals['todayCutOutput']),
        DataGridCell<int>(columnName: 'CutTodayPnL', value: totals['todayCutProfit']),
        DataGridCell<int>(columnName: 'CutTotalPnL', value: totals['totalCutPtofit']),
        DataGridCell<double>(columnName: 'CutCostPerQty', value: totals['todayCutCost']),
        DataGridCell<int>(columnName: 'StitchTodayOutput', value: totals['todayStitchOutput']),
        DataGridCell<int>(columnName: 'StitchTodayPnL', value: totals['todayStitchProfit']),
        DataGridCell<int>(columnName: 'StitchTotalPnL', value: totals['totalStitchProfit']),
        DataGridCell<double>(columnName: 'TodayPlanEff', value: totals['planTodayEff']),
        DataGridCell<double>(columnName: 'AvgPlanEff', value: totals['planAvgEff']),
        DataGridCell<double>(columnName: 'TodayActEff', value: totals['stitchTodayEff']),
        DataGridCell<double>(columnName: 'AvgActEff', value: totals['stitchAvgEff']),
        DataGridCell<int>(columnName: 'FinishTodayOutput', value: totals['todayFinishOutput']),
        DataGridCell<int>(columnName: 'FinishTodayPnL', value: totals['todayFinishProfit']),
        DataGridCell<int>(columnName: 'FinishTotalPnL', value: totals['totalFinishProfit']),
        DataGridCell<double>(columnName: 'FinishCotPerQty', value: totals['todayFinishCost']),
        DataGridCell<int>(columnName: 'TodayPack', value: totals['todayActualPackingOutput']),
        DataGridCell<int>(columnName: 'Variance', value: totals['variance']),
        DataGridCell<int>(columnName: 'TodayPnL', value: totals['todayProfit']),
        DataGridCell<int>(columnName: 'TotalPnL', value: totals['totalProfit']),
      ]));
    }
  }

  void navigateToCutting(BuildContext context, String fromDate, String toDate,String unit) {
    print(unit);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CuttingStylePage(fromDate: fromDate, toDate: toDate,unit: unit)),
    );

  }
  void navigateToFinish(BuildContext context, String fromDate, String toDate,String unit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinishStylePage(fromDate: fromDate, toDate: toDate,unit:unit)),
    );
  }
  void navigateToStitch(BuildContext context, String fromDate, String toDate,String unit) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StitchingStylePage(fromDate: fromDate, toDate: toDate,unit:unit)),
    );
  }
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isTotalRow = row.getCells().first.value == 'Total';
    final isSubTotalRow = row.getCells().first.value == 'SubTotal';

    return DataGridRowAdapter(
        color: isTotalRow
            ? const Color(0xFF8DEAA3)
            : isSubTotalRow
            ? const Color(0xFFA1D7DE)
            : null,
      cells: row.getCells().map<Widget>((dataGridCell) {
        Alignment alignment = dataGridCell.columnName == 'UnitShortCode' || dataGridCell.columnName == 'Team'
            ? Alignment.centerLeft
            : Alignment.centerRight;

        // Check if the column should have color applied
        bool shouldColor = ['CutTodayPnL', 'CutTotalPnL', 'StitchTodayPnL', 'StitchTotalPnL', 'FinishTodayPnL', 'FinishTotalPnL', 'TodayPnL', 'TotalPnL']
            .contains(dataGridCell.columnName);

        // Determine color based on value
        Color? textColor;
        if (shouldColor && dataGridCell.value is num) {
          num value = dataGridCell.value;
          textColor = value < 0 ? Colors.red : Colors.green;
        }
        bool isClickableColumn = ['CutTotalPnL', 'StitchTotalPnL', 'FinishTotalPnL']
            .contains(dataGridCell.columnName);

        return Container(
            alignment: alignment,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: GestureDetector(
        onTap: isClickableColumn && !isTotalRow && !isSubTotalRow
        ? () {
        String unitShortCode = row.getCells().firstWhere((cell) => cell.columnName == 'UnitShortCode1').value.toString();
        String columnName = dataGridCell.columnName;

        if (columnName == 'CutTotalPnL') {
        navigateToCutting(context, from, to, unitShortCode);
        } else if (columnName == 'StitchTotalPnL') {
        navigateToStitch(context, from, to, unitShortCode);
        } else if (columnName == 'FinishTotalPnL') {
        navigateToFinish(context, from, to, unitShortCode);
        }
        }
            : null,
          child: Text(
            dataGridCell.value.toString(),
            textAlign: alignment == Alignment.centerLeft
                ? TextAlign.left
                : TextAlign.right,
            style: TextStyle(
              fontSize: isTotalRow ? 16 : 14,
              fontWeight: isTotalRow || isSubTotalRow
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: textColor ?? Colors.black, // Apply color conditionally
              decoration: isClickableColumn && !isTotalRow && !isSubTotalRow ? TextDecoration.underline : null,
            ),
          ),
        )
        );
      }).toList(),
    );
  }



  Map<String, dynamic> _calculateTotals(List<ProfitAndLossData> data) {
    if (data.isEmpty) return {}; // Return an empty map if no data is present

    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    // Helper function to calculate average of values > 0
    double calculateAverage(List<double> values) {
      var filteredValues = values.where((value) => value > 0).toList();
      if (filteredValues.isEmpty) return 0.0; // Avoid division by 0
      return roundToTwo(filteredValues.reduce((a, b) => a + b) / filteredValues.length);
    }

    // Filter out rows where UnitShortCode == "SubTotal"
    var filteredData = data.where((item) => item.unitShortCode != "SubTotal").toList();

    // Map each field to its calculated value
    return {
      'todayCutOutput': filteredData.fold(0, (sum, item) => sum + item.todayCutOutput),
      'todayCutProfit': filteredData.fold(0, (sum, item) => sum + item.todayCutProfit),
      'totalCutPtofit': filteredData.fold(0, (sum, item) => sum + item.totalCutPtofit),
      'todayCutCost': calculateAverage(filteredData.map((item) => item.todayCutCost).toList()),
      'todayStitchOutput': filteredData.fold(0, (sum, item) => sum + item.todayStitchOutput),
      'todayStitchProfit': filteredData.fold(0, (sum, item) => sum + item.todayStitchProfit),
      'totalStitchProfit': filteredData.fold(0, (sum, item) => sum + item.totalStitchProfit),
      'planTodayEff': calculateAverage(filteredData.map((item) => item.planTodayEff).toList()),
      'planAvgEff': calculateAverage(filteredData.map((item) => item.planAvgEff).toList()),
      'stitchTodayEff': calculateAverage(filteredData.map((item) => item.stitchTodayEff).toList()),
      'stitchAvgEff': calculateAverage(filteredData.map((item) => item.stitchAvgEff).toList()),
      'todayFinishOutput': filteredData.fold(0, (sum, item) => sum + item.todayFinishOutput),
      'todayFinishProfit': filteredData.fold(0, (sum, item) => sum + item.todayFinishProfit),
      'totalFinishProfit': filteredData.fold(0, (sum, item) => sum + item.totalFinishProfit),
      'todayFinishCost': calculateAverage(filteredData.map((item) => item.todayFinishCost).toList()),
      'todayActualPackingOutput': filteredData.fold(0, (sum, item) => sum + item.todayActualPackingOutput),
      'variance': filteredData.fold(0, (sum, item) => sum + item.variance),
      'todayProfit': filteredData.fold(0, (sum, item) => sum + item.todayProfit),
      'totalProfit': filteredData.fold(0, (sum, item) => sum + item.totalProfit),
    };
  }}

// Main widget
class PnLDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;
  final String unitsVg;

  const PnLDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
    required this.unitsVg,
  });

  @override
  State<PnLDataTable> createState() => _PnLDataTableState();
}

class _PnLDataTableState extends State<PnLDataTable> {
  late Future<List<ProfitAndLossData>> pnlData;


  @override
  void initState() {
    super.initState();
    pnlData = fetchProfitAndLossData(widget.from, widget.to, widget.units,widget.unitsVg);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProfitAndLossData>>(
      future: pnlData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: double.infinity,
              child: LottieLoading(size: 150,animationPath: 'assets/animation/profit.json',));
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
              headerRowHeight: 35,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              source: PnLDataSource(pnlData: snapshot.data!,from: widget.from , to: widget.to,context: context),
              stackedHeaderRows: [
                StackedHeaderRow(cells: [
                  StackedHeaderCell(
                    columnNames: ['UnitShortCode','UnitShortCode1'],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              '',
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: ['Team'],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              '',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'CutTodayOutput',
                      'CutTodayPnL',
                      'CutTotalPnL',
                      'CutCostPerQty',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Cutting',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'StitchTodayOutput',
                      'StitchTodayPnL',
                      'StitchTotalPnL',
                      'TodayPlanEff',
                      'AvgPlanEff',
                      'TodayActEff',
                      'AvgActEff',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Stitching',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FinishTodayOutput',
                      'FinishTodayPnL',
                      'FinishTotalPnL',
                      'FinishCotPerQty',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Finishing',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TodayPack',
                      'Variance',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Finish Vs Packing',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TodayPnL',
                      'TotalPnL',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Overall',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                ]),
              ],
              columns: [
                GridColumn(
                    columnName: 'UnitShortCode',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Unit',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                  visible: false,

                    columnName: 'UnitShortCode1',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Unit',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'Team',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Team',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'CutTodayOutput',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nOutput',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'CutTodayPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'CutTotalPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Total\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'CutCostPerQty',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Cost/\nQty',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'StitchTodayOutput',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nOutput',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'StitchTodayPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'StitchTotalPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Total\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TodayPlanEff',
                    minimumWidth: 75,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today Plan\nEff (%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'AvgPlanEff',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Avg Plan\nEff (%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TodayActEff',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today Act\nEff (%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'AvgActEff',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Avg Act\nEff (%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FinishTodayOutput',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nOutput',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FinishTodayPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FinishTotalPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Total\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FinishCotPerQty',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Cost/\nQty',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TodayPack',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nPacking',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'Variance',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Variance',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TodayPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Today\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TotalPnL',
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Total\nP&L',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
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
