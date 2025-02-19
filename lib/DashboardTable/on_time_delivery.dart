import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:http/http.dart' as http;

class OnTimeDetail {
  final int buyerPo;
  final int delayBuyerPo;
  final double delayPoPerc;
  final double delayQty;
  final double delayQtyPerc;
  final int? onTimeBuyerPo;
  final double? onTimePoPerc;
  final double onTimeQty;
  final double? onTimeQtyPerc;
  final double qty;
  final String unitShortCode;

  OnTimeDetail({
    required this.buyerPo,
    required this.delayBuyerPo,
    required this.delayPoPerc,
    required this.delayQty,
    required this.delayQtyPerc,
    this.onTimeBuyerPo,
    this.onTimePoPerc,
    required this.onTimeQty,
    this.onTimeQtyPerc,
    required this.qty,
    required this.unitShortCode,
  });

  factory OnTimeDetail.fromJson(Map<String, dynamic> json) {
    return OnTimeDetail(
      buyerPo: json['BuyerPo'],
      delayBuyerPo: json['DelayBuyerPo'],
      delayPoPerc: json['DelayPoPerc'].toDouble() ?? 0,
      delayQty: json['DelayQty'],
      delayQtyPerc: json['DelayQtyPerc'].toDouble() ?? 0,
      onTimeBuyerPo: json['OnTimeBuyerPo'],
      onTimePoPerc: json['OntimePoPerc']?.toDouble() ?? 0.0,
      onTimeQty: json['OntimeQty'] ?? 0,
      onTimeQtyPerc: json['OntimeQtyPerc']?.toDouble() ?? 0.0,
      qty: json['Qty'],
      unitShortCode: json['UnitShortCode'],
    );
  }
}

// Fetch data from the API
Future<List<OnTimeDetail>> fetchOnTimeData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse(
        'http://14.142.248.34:10008/management?proce_type=onTime&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => OnTimeDetail.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class OnTimeDataSource extends DataGridSource {
  OnTimeDataSource({required List<OnTimeDetail> onTimeData}) {
    _dataGridRows = onTimeData.map<DataGridRow>((data) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'UnitShortCode', value: data.unitShortCode),
        DataGridCell<dynamic>(columnName: 'Qty', value: (data.qty).toStringAsFixed(0)),
        DataGridCell<int?>(columnName: 'PO Cnt', value: (data.buyerPo)),
        DataGridCell<dynamic>(columnName: 'OnTimeQty', value: (data.onTimeQty).toStringAsFixed(0)),
        DataGridCell<int?>(columnName: 'OnTimeBuyerPo', value: (data.onTimeBuyerPo ?? 0)),
        DataGridCell<double?>(columnName: 'OnTimeQtyPerc', value: double.parse((data.onTimeQtyPerc ?? 0).toStringAsFixed(2))),
        DataGridCell<double?>(columnName: 'OnTimePoPerc', value: double.parse((data.onTimePoPerc ?? 0).toStringAsFixed(2))),
        DataGridCell<dynamic>(columnName: 'DelayQty', value: data.delayQty.toStringAsFixed(0)),
        DataGridCell<int>(columnName: 'DelayBuyerPo', value: data.delayBuyerPo),
        DataGridCell<double>(columnName: 'DelayQtyPerc', value: double.parse(data.delayQtyPerc.toStringAsFixed(2))),
        DataGridCell<double>(columnName: 'DelayPoPerc', value: double.parse(data.delayPoPerc.toStringAsFixed(2))),
      ]);
    }).toList();

    if (onTimeData.isNotEmpty) {
      final totals = _calculateTotals(onTimeData);
      _dataGridRows.add(DataGridRow(cells: [
        const DataGridCell<String>(columnName: 'UnitShortCode', value: 'Total'),
        DataGridCell<dynamic>(columnName: 'Qty', value: totals['Qty']),
        DataGridCell<int>(columnName: 'PO Cnt', value: totals['PO Cnt']),
        DataGridCell<dynamic>(columnName: 'OnTimeQty', value: totals['OnTimeQty']),
        DataGridCell<int>(columnName: 'OnTimeBuyerPo', value: totals['OnTimeBuyerPo']),
        DataGridCell<double>(columnName: 'OnTimeQtyPerc', value: totals['OnTimeQtyPerc']),
        DataGridCell<double>(columnName: 'OnTimePoPerc', value: totals['OnTimePoPerc']),
        DataGridCell<dynamic>(columnName: 'DelayQty', value: totals['DelayQty']),
        DataGridCell<int>(columnName: 'DelayBuyerPo', value: totals['DelayBuyerPo']),
        DataGridCell<double>(columnName: 'DelayQtyPerc', value: totals['DelayQtyPerc']),
        DataGridCell<double>(columnName: 'DelayPoPerc', value: totals['DelayPoPerc']),
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

  Map<String, dynamic> _calculateTotals(List<OnTimeDetail> data) {
    int count = data.length; // Total number of items in the list
    if (count == 0) return {}; // Return an empty map if no data is present\
    double roundToTwo(double value , int i) => double.parse(value.toStringAsFixed(i));

    return {
      'Qty': data.fold(0, (sum, item) => sum + (item.qty.toInt())),
      'PO Cnt': data.fold(0, (sum, item) => sum + item.buyerPo),
      'OnTimeQty': data.fold(0, (sum, item) => sum + (item.onTimeQty.toInt())),
      'OnTimeBuyerPo': data.fold(0, (sum, item) => sum + (item.onTimeBuyerPo ?? 0)),
      'OnTimeQtyPerc': roundToTwo(data.fold(0.0, (sum, item) => sum + (item.onTimeQtyPerc ?? 0)) / count , 2),
      'OnTimePoPerc': roundToTwo(data.fold(0.0, (sum, item) => sum + (item.onTimePoPerc ?? 0)) / count , 2),
      'DelayQty': data.fold(0, (sum, item) => sum + (item.delayQty.toInt())),
      'DelayBuyerPo': data.fold(0, (sum, item) => sum + item.delayBuyerPo),
      'DelayQtyPerc': roundToTwo(data.fold(0.0, (sum, item) => sum + item.delayQtyPerc) / count , 2),
      'DelayPoPerc': roundToTwo(data.fold(0.0, (sum, item) => sum + item.delayPoPerc) / count , 2),
    };
  }
}

// Main widget
class OnTimeTable1 extends StatefulWidget {
  final String from;
  final String to;
  final String units;

  const OnTimeTable1({
    super.key,
    required this.from,
    required this.to,
    required this.units,
  });

  @override
  State<OnTimeTable1> createState() => _OnTimeTable1State();
}

class _OnTimeTable1State extends State<OnTimeTable1> {
  late Future<List<OnTimeDetail>> onTimeDataFuture;

  @override
  void initState() {
    super.initState();
    onTimeDataFuture = fetchOnTimeData(widget.from, widget.to, widget.units);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OnTimeDetail>>(
      future: onTimeDataFuture,
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
                source: OnTimeDataSource(onTimeData: snapshot.data!),
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
                      columnNames: ['Qty', 'PO Cnt'],
                      child: Container(
                          color: const Color(0xFF5FE3D3),
                          child: const Center(
                              child: Text(
                                'Total',
                                style: TextStyle(color: Colors.white),
                              ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'OnTimePoPerc',
                        'OnTimeQty',
                        'OnTimeQtyPerc',
                        'OnTimeBuyerPo'
                      ],
                      child: Container(
                          color: const Color(0xFF5FE3D3),
                          child: const Center(
                              child: Text(
                                'On Time',
                                style: TextStyle(color: Colors.white),
                              ))),
                    ),
                    StackedHeaderCell(
                      columnNames: [
                        'DelayPoPerc',
                        'DelayQty',
                        'DelayBuyerPo',
                        'DelayQtyPerc'
                      ],
                      child: Container(
                          color: const Color(0xFF5FE3D3),
                          child: const Center(
                              child: Text(
                                'Delay Details',
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
                      columnName: 'Qty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Qty',
                              overflow: TextOverflow.clip,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'PO Cnt',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('PO Cnt',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OnTimeQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Qty',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OnTimeBuyerPo',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('PO Cnt',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OnTimeQtyPerc',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Qty(%)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'OnTimePoPerc',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('PO Cnt(%)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'DelayQty',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Qty',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'DelayBuyerPo',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('PO Cnt',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'DelayQtyPerc',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('Qty(%)',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)))),
                  GridColumn(
                      columnName: 'DelayPoPerc',
                      label: Container(
                          color: const Color(0xFF5FE3D3),
                          alignment: Alignment.center,
                          child: const Text('PO Cnt(%)',
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
