import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class AttManpowerData {
  int femaleStaffJoinedToday;
  int femaleStaffLeftToday;
  int femaleStaffOnrollToday;
  double femaleStaffTotalAttr;
  int femaleTailorJoinedToday;
  int femaleTailorLeftToday;
  int femaleTailorOnrollToday;
  double femaleTailorTotalAttr;
  int maleStaffJoinedToday;
  int maleStaffLeftToday;
  int maleStaffOnrollToday;
  double maleStaffTotalAttr;
  int maleTailorJoinedToday;
  int maleTailorLeftToday;
  int maleTailorOnrollToday;
  double maleTailorTotalAttr;
  int staffJoinedToday;
  int staffLeftToday;
  int staffOnrollToday;
  double staffTotalAttr;
  int tailorJoinedToday;
  int tailorLeftToday;
  int tailorOnrollToday;
  double tailorTotalAttr;
  String unitShortCode;

  AttManpowerData({
    required this.femaleStaffJoinedToday,
    required this.femaleStaffLeftToday,
    required this.femaleStaffOnrollToday,
    required this.femaleStaffTotalAttr,
    required this.femaleTailorJoinedToday,
    required this.femaleTailorLeftToday,
    required this.femaleTailorOnrollToday,
    required this.femaleTailorTotalAttr,
    required this.maleStaffJoinedToday,
    required this.maleStaffLeftToday,
    required this.maleStaffOnrollToday,
    required this.maleStaffTotalAttr,
    required this.maleTailorJoinedToday,
    required this.maleTailorLeftToday,
    required this.maleTailorOnrollToday,
    required this.maleTailorTotalAttr,
    required this.staffJoinedToday,
    required this.staffLeftToday,
    required this.staffOnrollToday,
    required this.staffTotalAttr,
    required this.tailorJoinedToday,
    required this.tailorLeftToday,
    required this.tailorOnrollToday,
    required this.tailorTotalAttr,
    required this.unitShortCode,
  });

  factory AttManpowerData.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }
    return AttManpowerData(
      femaleStaffJoinedToday: json['FemaleStaffJoinedToday'] ?? 0,
      femaleStaffLeftToday: json['FemaleStaffLeftToday'] ?? 0,
      femaleStaffOnrollToday: json['FemaleStaffOnrollToday'] ?? 0,
      femaleStaffTotalAttr: toTwoDecimalPlaces((json['FemaleStaffTotalAttr'] as num?)?.toDouble() ?? 0.0),
      femaleTailorJoinedToday: json['FemaleTailorJoinedToday'] ?? 0,
      femaleTailorLeftToday: json['FemaleTailorLeftToday'] ?? 0,
      femaleTailorOnrollToday: json['FemaleTailorOnrollToday'] ?? 0,
      femaleTailorTotalAttr: toTwoDecimalPlaces((json['FemaleTailorTotalAttr'] as num?)?.toDouble() ?? 0.0),
      maleStaffJoinedToday: json['MaleStaffJoinedToday'] ?? 0,
      maleStaffLeftToday: json['MaleStaffLeftToday'] ?? 0,
      maleStaffOnrollToday: json['MaleStaffOnrollToday'] ?? 0,
      maleStaffTotalAttr: toTwoDecimalPlaces((json['MaleStaffTotalAttr'] as num?)?.toDouble() ?? 0.0),
      maleTailorJoinedToday: json['MaleTailorJoinedToday'] ?? 0,
      maleTailorLeftToday: json['MaleTailorLeftToday'] ?? 0,
      maleTailorOnrollToday: json['MaleTailorOnrollToday'] ?? 0,
      maleTailorTotalAttr: toTwoDecimalPlaces((json['MaleTailorTotalAttr'] as num?)?.toDouble() ?? 0.0),
      staffJoinedToday: json['StaffJoinedToday'] ?? 0,
      staffLeftToday: json['StaffLeftToday'] ?? 0,
      staffOnrollToday: json['StaffOnrollToday'] ?? 0,
      staffTotalAttr: toTwoDecimalPlaces((json['StaffTotalAttr'] as num?)?.toDouble() ?? 0.0),
      tailorJoinedToday: json['TailorJoinedToday'] ?? 0,
      tailorLeftToday: json['TailorLeftToday'] ?? 0,
      tailorOnrollToday: json['TailorOnrollToday'] ?? 0,
      tailorTotalAttr: toTwoDecimalPlaces((json['TailorTotalAttr'] as num?)?.toDouble() ?? 0.0),
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}
// Fetch data from the API
Future<List<AttManpowerData>> fetchAttManpower(String from, String to, String units,String vgUnit) async {
  final response = await http.get(
    Uri.parse(
        '${TBaseURL.baseUrl}mngmnt_review_vg?type=MnpwrTailorATTDtl&unitVg=$vgUnit&fromDate=$from&toDate=$to&unit=$units&proc_type=attManpower'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => AttManpowerData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class AttManpowerDataSource extends DataGridSource {
  AttManpowerDataSource({required List<AttManpowerData> attManpoerData}) {
    _dataGridRows = attManpoerData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'MaleOnRoll', value: (data.maleTailorOnrollToday)),
        DataGridCell<int?>(columnName: 'MaleJoined', value: (data.maleTailorJoinedToday)),
        DataGridCell<int?>(columnName: 'MaleLeft', value: (data.maleTailorLeftToday)),
        DataGridCell<double?>(columnName: 'MaleAttrition', value: double.parse((data.maleTailorTotalAttr).toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'FemaleOnRoll', value: (data.femaleTailorOnrollToday)),
        DataGridCell<int?>(columnName: 'FemaleJoined', value: (data.femaleTailorJoinedToday)),
        DataGridCell<int?>(columnName: 'FemaleLeft', value: (data.femaleTailorLeftToday)),
        DataGridCell<double>(columnName: 'FemaleAttrition', value: double.parse(data.femaleTailorTotalAttr.toStringAsFixed(2))),
        DataGridCell<int?>(columnName: 'TotalOnRoll', value: (data.tailorOnrollToday)),
        DataGridCell<int?>(columnName: 'TotalJoined', value: (data.tailorJoinedToday)),
        DataGridCell<int?>(columnName: 'TotalLeft', value: (data.tailorLeftToday)),
        DataGridCell<double?>(columnName: 'TotalAttrition', value: double.parse((data.tailorTotalAttr).toStringAsFixed(2))),
      ]);
    }).toList();

    if (attManpoerData.isNotEmpty) {
      final totals = _calculateTotals(attManpoerData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'MaleOnRoll', value: totals['maleTailorOnrollToday']),
        DataGridCell<int>(columnName: 'MaleJoined', value: totals['maleTailorJoinedToday']),
        DataGridCell<int>(columnName: 'MaleLeft', value: totals['maleTailorLeftToday']),
        DataGridCell<double>(columnName: 'MaleAttrition', value: totals['maleTailorTotalAttr']),
        DataGridCell<int>(columnName: 'FemaleOnRoll', value: totals['femaleTailorOnrollToday']),
        DataGridCell<int>(columnName: 'FemaleJoined', value: totals['femaleTailorJoinedToday']),
        DataGridCell<int>(columnName: 'FemaleLeft', value: totals['femaleTailorLeftToday']),
        DataGridCell<double>(columnName: 'FemaleAttrition', value: totals['femaleTailorTotalAttr']),
        DataGridCell<int>(columnName: 'TotalOnRoll', value: totals['tailorOnrollToday']),
        DataGridCell<int>(columnName: 'TotalJoined', value: totals['tailorJoinedToday']),
        DataGridCell<int>(columnName: 'TotalLeft', value: totals['tailorLeftToday']),
        DataGridCell<double>(columnName: 'TotalAttrition', value: totals['tailorTotalAttr']),
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

  Map<String, dynamic> _calculateTotals(List<AttManpowerData> data) {
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
      'maleTailorOnrollToday': data.fold(0, (sum, item) => sum + item.maleTailorOnrollToday),
      'maleTailorJoinedToday': data.fold(0, (sum, item) => sum + item.maleTailorJoinedToday),
      'maleTailorLeftToday': data.fold(0, (sum, item) => sum + item.maleTailorLeftToday),
      'maleTailorTotalAttr': calculateAverage(data.map((item) => item.maleTailorTotalAttr).toList()),
      'femaleTailorOnrollToday': data.fold(0, (sum, item) => sum + item.femaleTailorOnrollToday),
      'femaleTailorJoinedToday': data.fold(0, (sum, item) => sum + item.femaleTailorJoinedToday),
      'femaleTailorLeftToday': data.fold(0, (sum, item) => sum + item.femaleTailorLeftToday),
      'femaleTailorTotalAttr': calculateAverage(data.map((item) => item.femaleTailorTotalAttr).toList()),
      'tailorOnrollToday': data.fold(0, (sum, item) => sum + item.tailorOnrollToday),
      'tailorJoinedToday': data.fold(0, (sum, item) => sum + item.tailorJoinedToday),
      'tailorLeftToday': data.fold(0, (sum, item) => sum + item.tailorLeftToday),
      'tailorTotalAttr': calculateAverage(data.map((item) => item.tailorTotalAttr).toList()),
    };
  }
}

// Main widget
class AttManpowerTailorTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;
  final String vgUnit;

  const AttManpowerTailorTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
    required this.vgUnit,
  });

  @override
  State<AttManpowerTailorTable> createState() => _AttManpowerTailorTableState();
}

class _AttManpowerTailorTableState extends State<AttManpowerTailorTable> {
  late Future<List<AttManpowerData>> attManpower;

  @override
  void initState() {
    super.initState();
    attManpower = fetchAttManpower(widget.from, widget.to, widget.units, widget.vgUnit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AttManpowerData>>(
      future: attManpower,
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
              headerRowHeight: 40,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              source: AttManpowerDataSource(attManpoerData: snapshot.data!),
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
                    columnNames: ['MaleOnRoll', 'MaleJoined', 'MaleLeft', 'MaleAttrition'],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Male',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'FemaleOnRoll',
                      'FemaleJoined',
                      'FemaleLeft',
                      'FemaleAttrition',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Female',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'TotalOnRoll',
                      'TotalJoined',
                      'TotalLeft',
                      'TotalAttrition',
                    ],
                    child: Container(
                        color: Colors.grey[400],
                        child: const Center(
                            child: Text(
                              'Total',
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
                    columnName: 'MaleOnRoll',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('On Roll\n(on 1st)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'MaleJoined',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Joined\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'MaleLeft',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Left\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'MaleAttrition',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Attrition\nRate(%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),

                GridColumn(
                    columnName: 'FemaleOnRoll',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('On Roll\n(on 1st)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FemaleJoined',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Joined\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FemaleLeft',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Left\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'FemaleAttrition',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Attrition\nRate(%)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TotalOnRoll',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('On Roll\n(on 1st)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TotalJoined',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Joined\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TotalLeft',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Left\n(In a Prd)',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black87)))),
                GridColumn(
                    columnName: 'TotalAttrition',
                    minimumWidth: 60,
                    label: Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Attrition\nRate(%)',
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
