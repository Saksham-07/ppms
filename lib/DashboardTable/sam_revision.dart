import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../common/utils/constants/baseurl.dart';

class SamRevisionDetail {
  final String bLocatShortCode;
  final String stitchStartDate;
  final String orderNo;
  final String styleNo;
  final double costSam;
  final double firstProd;
  final double lastSam;
  final double costingVariation;
  final double variation;

  SamRevisionDetail({
    required this.bLocatShortCode,
    required this.stitchStartDate,
    required this.orderNo,
    required this.styleNo,
    required this.costSam,
    required this.firstProd,
    required this.lastSam,
    required this.costingVariation,
    required this.variation,
  });

  factory SamRevisionDetail.fromJson(Map<String, dynamic> json) {
    String? startDateStr = json['StitchStartDate'];

    String formattedDate;
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        // Parse the date string using DateFormat
        DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
        DateTime startDate = inputFormat.parseUTC(startDateStr);

        // Format the date
        formattedDate = DateFormat('d/MM/yy').format(startDate);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing date: $e');
        }
        formattedDate = '';
      }
    } else {
      formattedDate = '';
    }
    double roundTo2Decimal(double value) => double.parse(value.toStringAsFixed(2));

    return SamRevisionDetail(
      bLocatShortCode: json['Blocatshortcode'] ?? '',
      stitchStartDate: formattedDate,
      orderNo: json['OrderNo'] ?? '',
      styleNo: json['StyleNo'] ?? '',
      costSam: roundTo2Decimal((json['StyleSMV'] as num?)?.toDouble() ?? 0.0),
      firstProd: roundTo2Decimal((json['ProdSamFresh'] as num?)?.toDouble() ?? 0.0),
      lastSam: roundTo2Decimal((json['ProdSam'] as num?)?.toDouble() ?? 0.0),
      costingVariation: roundTo2Decimal((json['CostingVariation'] as num?)?.toDouble() ?? 0.0),
      variation: roundTo2Decimal((json['Variation'] as num?)?.toDouble() ?? 0.0),
    );
  }
}

Future<List<SamRevisionDetail>> fetchSamData(String from, String to, String units,String vgUnit) async {
  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}mngmnt_review_vg?proc_type=StyleCostRevision&type=StyleCostRevision&fromDate=&toDate=&unit=&unitVg='),
    // Uri.parse('http://172.16.10.11:8000/management?proce_type=catagory&from=&to=&units=$units'),
  );

  if (kDebugMode) {
    print('${TBaseURL.baseUrl}mngmnt_review_vg?proc_type=StyleCostRevision&type=StyleCostRevision&fromDate=&toDate=&unit=&unitVg=');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => SamRevisionDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class SamRevDataSource extends DataGridSource {
  SamRevDataSource({required List<SamRevisionDetail> samRevData}) {
    _dataGridRows = samRevData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.bLocatShortCode),
        DataGridCell<String>(columnName: 'StartDate', value: data.stitchStartDate),
        DataGridCell<String>(columnName: 'Style', value: data.styleNo),
        DataGridCell<double>(columnName: 'CostSam', value: data.costSam),
        DataGridCell<double>(columnName: 'FirstSam', value: data.firstProd),
        DataGridCell<double>(columnName: 'LastSam', value: data.lastSam),
        DataGridCell<double>(columnName: 'CostVariation', value: data.costingVariation),
        DataGridCell<double>(columnName: 'Variation', value: data.variation),

      ]);
    }).toList();
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
        Alignment alignment = dataGridCell.columnName == 'UnitShortCode' || dataGridCell.columnName == 'Order' ||
            dataGridCell.columnName == 'Style' || dataGridCell.columnName == 'StartDate'
            ? Alignment.centerLeft
            : Alignment.centerRight;

        TextStyle textStyle = TextStyle(
          fontSize: 14,
          fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
          color: Colors.black
        );

        // Check if this is a variation column and apply color based on value
        if ((dataGridCell.columnName == 'CostVariation' ||
            dataGridCell.columnName == 'Variation') &&
            dataGridCell.value is double) {
          double value = dataGridCell.value as double;
          textStyle = textStyle.copyWith(
            color: value > 0 ? Colors.red : Colors.green,
          );
        }
        return Container(
          alignment: alignment,
          padding: const EdgeInsets.only(left: 4, right: 2,top: 2,bottom: 2),
          child: Text(
            dataGridCell.value.toString(),
            textAlign: alignment == Alignment.centerLeft ? TextAlign.left : TextAlign.right,
            style: textStyle
          ),
        );
      }).toList(),
    );
  }

}

// Main widget
class SamRevDataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;
  final String vgUnit;

  const SamRevDataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
    required this.vgUnit,
  });

  @override
  State<SamRevDataTable> createState() => _SamRevDataTableState();
}

class _SamRevDataTableState extends State<SamRevDataTable> {
  late Future<List<SamRevisionDetail>> samRev;

  @override
  void initState() {
    super.initState();
    samRev = fetchSamData(widget.from, widget.to, widget.units,widget.vgUnit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SamRevisionDetail>>(
      future: samRev,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Calculate total height based on data rows, header, and footer
          const double rowHeight = 25;
          const double headerHeight = 30;
          final int totalRows = snapshot.data!.length; // Include the total row
          final double totalHeight =
              (totalRows * rowHeight) + headerHeight;

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
                rowHeight: 25,
                headerRowHeight: 40,
                columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                source: SamRevDataSource(samRevData: snapshot.data!),
                columns: [
                  GridColumn(
                      columnName: 'UnitShortCode',
                      width: 40,
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Unit',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'StartDate',
                      width: 74,
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Stitching\nStart Date',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'Style',
                      width: 180,
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Style',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'CostSam',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text("Costing\nSAM(A)",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'FirstSam',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('First Prod\nSam(B)',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'LastSam',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text("Last Prod\nSam(C)",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'CostVariation',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Variation\n(C-A)',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'Variation',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Variation\n(C-B)',
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
