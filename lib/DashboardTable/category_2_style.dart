import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

import '../ExtraFunction/lottie_loading.dart';
import '../common/utils/constants/baseurl.dart';

class CategoryDetail {
  final String unitShortCode;
  final String buyerName;
  final String styleNo;
  final String startDate;
  final double cuttingCost;
  final double prodSam;
  final double prepSam;
  final double finishCost;

  CategoryDetail({
    required this.unitShortCode,
    required this.buyerName,
    required this.styleNo,
    required this.startDate,
    required this.cuttingCost,
    required this.prodSam,
    required this.prepSam,
    required this.finishCost,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    String? startDateStr = json['StartDate'];

    String formattedDate;
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        // Parse the date string using DateFormat
        DateFormat inputFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US');
        DateTime startDate = inputFormat.parseUTC(startDateStr);

        // Format the date
        formattedDate = DateFormat('MMM d, yyyy').format(startDate);
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

    return CategoryDetail(
      unitShortCode: json['UnitShortCode'] ?? '',
      buyerName: json['BuyerName'] ?? '',
      styleNo: json['StyleNo'] ?? '',
      startDate: formattedDate,
      cuttingCost: roundTo2Decimal((json['CuttingCost'] as num?)?.toDouble() ?? 0.0),
      prodSam: roundTo2Decimal((json['ProdSam'] as num?)?.toDouble() ?? 0.0),
      prepSam: roundTo2Decimal((json['PrepSam'] as num?)?.toDouble() ?? 0.0),
      finishCost: roundTo2Decimal((json['FinishCost'] as num?)?.toDouble() ?? 0.0),
    );
  }
}

Future<List<CategoryDetail>> fetchCatData(String from, String to, String units,String vgUnit) async {
  final response = await http.get(
    Uri.parse('${TBaseURL.baseUrl}mngmnt_review_vg?proc_type=Category2&type=Category2&fromDate=&toDate=&unit=$units&unitVg=$vgUnit'),
    // Uri.parse('http://172.16.10.11:8000/management?proce_type=catagory&from=&to=&units=$units'),
  );

  if (kDebugMode) {
    print('${TBaseURL.baseUrl}mngmnt_review_vg?proc_type=Category2&type=Category2&from=&to=&units=$units&unitVg=$vgUnit');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => CategoryDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class Category2DataSource extends DataGridSource {
  Category2DataSource({required List<CategoryDetail> category2Data}) {
    _dataGridRows = category2Data.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<String>(columnName: 'Buyer', value: data.buyerName),
        DataGridCell<String>(columnName: 'Style', value: data.styleNo),
        DataGridCell<String>(columnName: 'StartDate', value: data.startDate),
        DataGridCell<double>(columnName: 'CuttingCost', value: data.cuttingCost),
        DataGridCell<double>(columnName: 'ProdSam', value: data.prodSam),
        DataGridCell<double>(columnName: 'PrepSam', value: data.prepSam),
        DataGridCell<double>(columnName: 'FinishCost', value: data.finishCost),

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
      color: isTotalRow ? const Color(0xFF8DEAA3) : null,
      cells: row.getCells().map<Widget>((dataGridCell) {
        Alignment alignment = dataGridCell.columnName == 'UnitShortCode' || dataGridCell.columnName == 'Buyer' ||
            dataGridCell.columnName == 'Style' || dataGridCell.columnName == 'StartDate'
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

}

// Main widget
class Category2DataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;
  final String vgUnit;

  const Category2DataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
    required this.vgUnit,
  });

  @override
  State<Category2DataTable> createState() => _Category2DataTableState();
}

class _Category2DataTableState extends State<Category2DataTable> {
  late Future<List<CategoryDetail>> category2;

  @override
  void initState() {
    super.initState();
    category2 = fetchCatData(widget.from, widget.to, widget.units,widget.vgUnit);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryDetail>>(
      future: category2,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: double.infinity,
              child: LottieLoading(size: 150,animationPath: 'assets/animation/profit.json',));
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
                headerRowHeight: 30,
                columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                source: Category2DataSource(category2Data: snapshot.data!),
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
                      columnName: 'Buyer',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Buyer',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'Style',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Style No',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'StartDate',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Stitching Start\nDate',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'CuttingCost',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text("Cutting\nCost",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'ProdSam',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Prod\nSam',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'PrepSam',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text("Prep\nSam",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87)))),
                  GridColumn(
                      columnName: 'FinishCost',
                      label: Container(
                          color: Colors.grey[400],
                          alignment: Alignment.center,
                          child: const Text('Finish\nCost',
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
