import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class ProdTnaDetail {
  final int fileHandoverCount;
  final int fileHandoverDiff;
  final int styleCount;
  final int tnaApproveCount;
  final int tnaApproveDiff;
  final int tnaCount;
  final int tnaDiff;
  final int tnaReviewCount;
  final int tnaReviewDiff;
  final String unitShortCode;


  ProdTnaDetail({
    required this.fileHandoverCount,
    required this.fileHandoverDiff,
    required this.styleCount,
    required this.tnaApproveCount,
    required this.tnaApproveDiff,
    required this.tnaCount,
    required this.tnaDiff,
    required this.tnaReviewCount,
    required this.tnaReviewDiff,
    required this.unitShortCode,
  });

  factory ProdTnaDetail.fromJson(Map<String, dynamic> json) {
    return ProdTnaDetail(
      fileHandoverCount: (json['FileHandoverCount'] as num?)?.toInt() ?? 0,
      fileHandoverDiff: (json['FileHandoverDiff'] as num?)?.toInt() ?? 0,
      styleCount: (json['StyleCount'] as num?)?.toInt() ?? 0,
      tnaApproveCount: (json['TnaApproveCount'] as num?)?.toInt() ?? 0,
      tnaApproveDiff: (json['TnaApproveDiff'] as num?)?.toInt() ?? 0,
      tnaCount: (json['TnaCount'] as num?)?.toInt() ?? 0,
      tnaDiff: (json['TnaDiff'] as num?)?.toInt() ?? 0,
      tnaReviewCount: (json['TnaReviewCount'] as num?)?.toInt() ?? 0,
      tnaReviewDiff: (json['TnaReviewDiff'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

// Fetch data from the API
Future<List<ProdTnaDetail>> fetchProdTnaData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=prodTna&from=$from&to=$to&units=$units'),
    // Uri.parse('http://172.16.10.11:8000/management?proce_type=prodTna&from=$from&to=$to&units=$units'),
  );

  print('http://14.142.248.34:10008/management?proce_type=prodTna&from=$from&to=$to&units=$units');

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => ProdTnaDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class ProdTnaDataSource extends DataGridSource {
  ProdTnaDataSource({required List<ProdTnaDetail> prodTnaData}) {
    _dataGridRows = prodTnaData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<int?>(columnName: 'FileHandover', value: (data.styleCount)),
        DataGridCell<int?>(columnName: 'FileHandoverPending', value: (data.fileHandoverDiff)),
        DataGridCell<int?>(columnName: 'TNAMade', value: (data.tnaCount)),
        DataGridCell<int?>(columnName: 'TNAPending', value: (data.tnaDiff)),
        DataGridCell<int?>(columnName: 'Reviewed', value: (data.tnaReviewCount)),
        DataGridCell<int?>(columnName: 'ReviewedPending', value: (data.tnaReviewDiff)),
        DataGridCell<int?>(columnName: 'Approved', value: (data.tnaApproveCount)),
        DataGridCell<int?>(columnName: 'ApprovedPending', value: (data.tnaApproveDiff)),
      ]);
    }).toList();

    if (prodTnaData.isNotEmpty) {
      final totals = _calculateTotals(prodTnaData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<int>(columnName: 'FileHandover', value: totals['styleCount']),
        DataGridCell<int>(columnName: 'FileHandoverPending', value: totals['fileHandoverDiff']),
        DataGridCell<int>(columnName: 'TNAMade', value: totals['tnaCount']),
        DataGridCell<int>(columnName: 'TNAPending', value: totals['tnaDiff']),
        DataGridCell<int>(columnName: 'Reviewed', value: totals['tnaReviewCount']),
        DataGridCell<int>(columnName: 'ReviewedPending', value: totals['tnaReviewDiff']),
        DataGridCell<int>(columnName: 'Approved', value: totals['tnaApproveCount']),
        DataGridCell<int>(columnName: 'ApprovedPending', value: totals['tnaApproveDiff']),
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

  Map<String, dynamic> _calculateTotals(List<ProdTnaDetail> data) {
    int count = data.length; // Total number of items in the list
    if (count == 0) return {}; // Return an empty map if no data is present\
    double roundToTwo(double value , int i) => double.parse(value.toStringAsFixed(i));

    return {
      'styleCount': data.fold(0, (sum, item) => sum + (item.styleCount.toInt())),
      'fileHandoverDiff': data.fold(0, (sum, item) => sum + (item.fileHandoverDiff.toInt())),
      'tnaCount': data.fold(0, (sum, item) => sum + (item.tnaCount.toInt())),
      'tnaDiff': data.fold(0, (sum, item) => sum + (item.tnaDiff.toInt())),
      'tnaReviewCount': data.fold(0, (sum, item) => sum + (item.tnaReviewCount.toInt())),
      'tnaReviewDiff': data.fold(0, (sum, item) => sum + (item.tnaReviewDiff.toInt())),
      'tnaApproveCount': data.fold(0, (sum, item) => sum + (item.tnaApproveCount.toInt())),
      'tnaApproveDiff': data.fold(0, (sum, item) => sum + (item.tnaApproveDiff.toInt())),
    };
  }
}

// Main widget
class ProdTnaDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const ProdTnaDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<ProdTnaDataTable> createState() => _ProdTnaDataTableState();
}

class _ProdTnaDataTableState extends State<ProdTnaDataTable> {
  late Future<List<ProdTnaDetail>> prodTna;

  @override
  void initState() {
    super.initState();
    prodTna = fetchProdTnaData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProdTnaDetail>>(
      future: prodTna,
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
              headerRowHeight: 40,
              columnWidthMode: ColumnWidthMode.fitByCellValue,
              source: ProdTnaDataSource(prodTnaData: snapshot.data!),
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
                      'FileHandover',
                      'FileHandoverPending',
                      'TNAMade',
                      'TNAPending'
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              'File HandOver &\nTNA Made',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ))),
                  ),
                  StackedHeaderCell(
                    columnNames: [
                      'Reviewed',
                      'ReviewedPending',
                      'Approved',
                      'ApprovedPending'
                    ],
                    child: Container(
                        color: const Color(0xFF5FE3D3),
                        child: const Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              'TNA Review\n& Approval',
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
                            overflow: TextOverflow.clip,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FileHandover',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('File\nHndovr',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'FileHandoverPending',
                    minimumWidth: 80,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('File Hndovr\nPending',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TNAMade',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('TNA\nMade',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'TNAPending',
                    minimumWidth: 60,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('TNA\nPending',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'Reviewed',
                    minimumWidth: 70,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Reviewed',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ReviewedPending',
                    minimumWidth: 70,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Reviewed\nPending',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'Approved',
                    minimumWidth: 70,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Approved',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)))),
                GridColumn(
                    columnName: 'ApprovedPending',
                    minimumWidth: 70,
                    label: Container(
                        color: const Color(0xFF5FE3D3),
                        alignment: Alignment.center,
                        child: const Text('Approved\nPending',
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
