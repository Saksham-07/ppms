import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ppms/common/utils/constants/baseurl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../ExtraFunction/lottie_loading.dart';

class AdditionalLossDetail {
  final int ftmIntimation;
  final int utmIntimation;
  final int ftmClaim;
  final int utmClaim;
  final int ftmDebit;
  final int utmDebit;
  final int ftmExtraFreight;
  final int utmExtraFreight;
  final String unitShortCode;

  AdditionalLossDetail({
    required this.ftmIntimation,
    required this.utmIntimation,
    required this.ftmClaim,
    required this.utmClaim,
    required this.ftmDebit,
    required this.utmDebit,
    required this.ftmExtraFreight,
    required this.utmExtraFreight,
    required this.unitShortCode,
  });

  factory AdditionalLossDetail.fromJson(Map<String, dynamic> json) {
    return AdditionalLossDetail(
      ftmIntimation: (json['FtmIntimation'] as num?)?.toInt() ?? 0,
      utmIntimation: (json['UtmIntimation'] as num?)?.toInt() ?? 0,
      ftmClaim:
          (json['ClaimTypeAmountINR_SpecificPeriod'] as num?)?.toInt() ?? 0,
      utmClaim:
          (json['ClaimTypeAmountINR_FinancialYear'] as num?)?.toInt() ?? 0,
      ftmDebit: (json['FtmDebit'] as num?)?.toInt() ?? 0,
      utmDebit: (json['UtmDebit'] as num?)?.toInt() ?? 0,
      ftmExtraFreight: (json['FtmExtraFreight'] as num?)?.toInt() ?? 0,
      utmExtraFreight: (json['UtmExtraFreight'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

Future<List<AdditionalLossDetail>> fetchAdditionalLoss(
    String from, String to, String units, String vgUnit) async {
  final response = await http.get(
    Uri.parse(
        '${TBaseURL.baseUrl}mngmnt_review_vg?type=AdditionalLossSummary&unitVg=$vgUnit&fromDate=$from&toDate=$to&unit=$units&proc_type=MngmntReviewOther'),
  );
  if (kDebugMode) {
    print(
        '${TBaseURL.localUrl}mngmnt_review_vg?type=AdditionalLossSummary&unitVg=$vgUnit&fromDate=$from&toDate=$to&unit=$units&proc_type=MngmntReviewOther');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse
        .map((data) => AdditionalLossDetail.fromJson(data))
        .toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class AuditVsActualSource extends DataGridSource {
  AuditVsActualSource({required List<AdditionalLossDetail> auditActualData}) {
    _dataGridRows = auditActualData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(
            columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(
            columnName: 'IntimationFtm', value: (data.ftmIntimation)),
        DataGridCell<int?>(
            columnName: 'IntimationUtm', value: (data.utmIntimation)),
        DataGridCell<int?>(columnName: 'ClaimFtm', value: (data.ftmClaim)),
        DataGridCell<int?>(columnName: 'ClaimUtm', value: (data.utmClaim)),
        DataGridCell<int?>(columnName: 'DebitFtm', value: (data.ftmDebit)),
        DataGridCell<int?>(columnName: 'DebitUtm', value: (data.utmDebit)),
        DataGridCell<int?>(
            columnName: 'ExtraFreightFtd', value: (data.ftmExtraFreight)),
        DataGridCell<int?>(
            columnName: 'ExtraFreightUtd', value: (data.utmExtraFreight)),
      ]);
    }).toList();

    if (auditActualData.isNotEmpty) {
      final totals = _calculateTotals(auditActualData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(
            columnName: 'IntimationFtm', value: totals['ftmIntimation']),
        DataGridCell<int>(
            columnName: 'IntimationUtm', value: totals['utmIntimation']),
        DataGridCell<int>(columnName: 'ClaimFtm', value: totals['ftmClaim']),
        DataGridCell<int>(columnName: 'ClaimUtm', value: totals['utmClaim']),
        DataGridCell<int>(columnName: 'DebitFtm', value: totals['ftmDebit']),
        DataGridCell<int>(columnName: 'DebitUtm', value: totals['utmDebit']),
        DataGridCell<int>(
            columnName: 'ExtraFreightFtd', value: totals['ftmExtraFreight']),
        DataGridCell<int>(
            columnName: 'ExtraFreightUtd', value: totals['utmExtraFreight']),
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
            textAlign: alignment == Alignment.centerLeft
                ? TextAlign.left
                : TextAlign.right,
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

  Map<String, dynamic> _calculateTotals(List<AdditionalLossDetail> data) {
    if (data.isEmpty) return {}; // Return an empty map if no data is present

    double roundToTwo(double value) => double.parse(value.toStringAsFixed(2));

    // Helper function to calculate average of values > 0
    double calculateAverage(List<double> values) {
      var filteredValues = values.where((value) => value > 0).toList();
      if (filteredValues.isEmpty) return 0.0; // Avoid division by 0
      return roundToTwo(
          filteredValues.reduce((a, b) => a + b) / filteredValues.length);
    }

    // Map each field to its average
    return {
      'ftmIntimation': data.fold(0, (sum, item) => sum + item.ftmIntimation),
      'utmIntimation': data.fold(0, (sum, item) => sum + item.utmIntimation),
      'ftmClaim': data.fold(0, (sum, item) => sum + item.ftmClaim),
      'utmClaim': data.fold(0, (sum, item) => sum + item.utmClaim),
      'ftmDebit': data.fold(0, (sum, item) => sum + item.ftmDebit),
      'utmDebit': data.fold(0, (sum, item) => sum + item.utmDebit),
      'ftmExtraFreight':
          data.fold(0, (sum, item) => sum + item.ftmExtraFreight),
      'utmExtraFreight':
          data.fold(0, (sum, item) => sum + item.utmExtraFreight),
    };
  }
}

// Main widget
class AdditionalLossTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;
  final String vgUnit;

  const AdditionalLossTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
    required this.vgUnit,
  });

  @override
  State<AdditionalLossTable> createState() => _AdditionalLossTableState();
}

class _AdditionalLossTableState extends State<AdditionalLossTable> {
  late Future<List<AdditionalLossDetail>> additionalLossData;

  @override
  void initState() {
    super.initState();
    additionalLossData = fetchAdditionalLoss(
        widget.from, widget.to, widget.units, widget.vgUnit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdditionalLossDetail>>(
      future: additionalLossData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              width: double.infinity,
              child: LottieLoading(
                size: 150,
                animationPath: 'assets/animation/profit.json',
              ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          const double rowHeight = 25;
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
                  : MediaQuery.of(context)
                      .size
                      .height, // Cap height to screen size
              child: SfDataGrid(
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                allowPullToRefresh: false,
                frozenColumnsCount: 1,
                shrinkWrapRows: true,
                highlightRowOnHover: true,
                allowSwiping: false,
                rowHeight: 25,
                horizontalScrollController:
                    ScrollController(initialScrollOffset: 0),
                headerRowHeight: 25,
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                source: AuditVsActualSource(auditActualData: snapshot.data!),
                stackedHeaderRows: [
                  StackedHeaderRow(cells: [
                    StackedHeaderCell(
                      columnNames: ['UnitShortCode'],
                      child: Container(
                          color: Colors.grey[400],
                          child: const Center(
                              child: Text(
                            '',
                            style: TextStyle(color: Colors.black87),
                          ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'IntimationFtm',
                        'IntimationUtm',
                      ],
                      child: Container(
                          color: Colors.grey[400],
                          child: const Center(
                              child: Text(
                            'Intimation',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'ClaimFtm',
                        'ClaimUtm',
                      ],
                      child: Container(
                          color: Colors.grey[400],
                          child: const Center(
                              child: Text(
                            'Claim',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'DebitFtm',
                        'DebitUtm',
                      ],
                      child: Container(
                          color: Colors.grey[400],
                          child: const Center(
                              child: Text(
                            'Debit',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87),
                          ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'ExtraFreightFtd',
                        'ExtraFreightUtd',
                      ],
                      child: Container(
                          color: Colors.grey[400],
                          child: const Center(
                              child: Text(
                            'Extra Freight',
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
                      columnName: 'IntimationFtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('FTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'IntimationUtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('UTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ClaimFtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('FTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ClaimUtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('UTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'DebitFtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('FTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'DebitUtm',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('UTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ExtraFreightFtd',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('FTM',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ExtraFreightUtd',
                      label: Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text('UTM',
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
