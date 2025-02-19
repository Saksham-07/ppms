import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class Category3Detail {
  final String unitShortCode;
  final String buyerName;
  final String styleNo;
  final String startDate;
  final double cuttingCost;
  final double prodSam;
  final double prepSam;
  final double finishCost;

  Category3Detail({
    required this.unitShortCode,
    required this.buyerName,
    required this.styleNo,
    required this.startDate,
    required this.cuttingCost,
    required this.prodSam,
    required this.prepSam,
    required this.finishCost,
  });

  factory Category3Detail.fromJson(Map<String, dynamic> json) {
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

    return Category3Detail(
      unitShortCode: json['UnitShortCode'] ?? '',
      buyerName: json['BuyerName'] ?? '',
      styleNo: json['StyleNo'] ?? '',
      startDate: formattedDate,
      cuttingCost: (json['CuttingCost'] as num?)?.toDouble() ?? 0.0,
      prodSam: (json['ProdSam'] as num?)?.toDouble() ?? 0.0,
      prepSam: (json['PrepSam'] as num?)?.toDouble() ?? 0.0,
      finishCost: (json['FinishCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

Future<List<Category3Detail>> fetchCat3Data(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=Category3&from=&to=&units=$units'),
    // Uri.parse('http://172.16.10.11:8000/management?proce_type=catagory&from=&to=&units=$units'),
  );

  if (kDebugMode) {
    print('http://14.142.248.34:10008/management?proce_type=Category3&from=&to=&units=$units');
  }

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => Category3Detail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

class Category3DataSource extends DataGridSource {
  Category3DataSource({required List<Category3Detail> category3Data}) {
    _dataGridRows = category3Data.map<DataGridRow>((data) {
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
      color: isTotalRow ? Colors.yellowAccent : null,
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
            ),
          ),
        );
      }).toList(),
    );
  }

}

// Main widget
class Category3DataTable extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const Category3DataTable({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<Category3DataTable> createState() => _Category3DataTableState();
}

class _Category3DataTableState extends State<Category3DataTable> {
  late Future<List<Category3Detail>> category3;

  @override
  void initState() {
    super.initState();
    category3 = fetchCat3Data(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category3Detail>>(
      future: category3,
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
                headerRowHeight: 30,
                columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
                columnWidthMode: ColumnWidthMode.fitByCellValue,
                source: Category3DataSource(category3Data: snapshot.data!),
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
                      columnName: 'Buyer',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Buyer',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'Style',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Style No',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'StartDate',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Stitching Start\nDate',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'CuttingCost',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Cutting\nCost",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'ProdSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Prod\nSam',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'PrepSam',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text("Prep\nSam",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'FinishCost',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Finish\nCost',
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
