import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class CustomDataGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tableData;
  final bool isChecked;
  final bool isLineWise;

  final int totalPassQty;
  final int totalRejectQty;
  final int totalDefectQty;
  final int totalRectQty;
  final int totalAuditQty;
  final int totalBalQty;

  const CustomDataGrid({
    Key? key,
    required this.tableData,
    required this.isChecked,
    required this.isLineWise,
    required this.totalPassQty,
    required this.totalRejectQty,
    required this.totalDefectQty,
    required this.totalRectQty,
    required this.totalAuditQty,
    required this.totalBalQty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      gridLinesVisibility: GridLinesVisibility.both,
      frozenColumnsCount: 1,
      columnWidthMode: ColumnWidthMode.fitByCellValue,
      rowHeight: 30,
      headerRowHeight: 40,
      source: _TableDataSource(
        tableData: tableData,
        isChecked: isChecked,
        isLineWise: isLineWise,
        totalPassQty: totalPassQty,
        totalRejectQty: totalRejectQty,
        totalDefectQty: totalDefectQty,
        totalRectQty: totalRectQty,
        totalAuditQty: totalAuditQty,
        totalBalQty: totalBalQty,
      ),
      columns: [
        GridColumn(
          columnName: 'StyleNo',
          maximumWidth: 150,
          label: Container(
              color: Colors.grey[400],
              child: const Center(child: Text('Style No',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        GridColumn(
          columnName: 'Color',
          maximumWidth: 140,
          label: Container(
              color: Colors.grey[400],child: const Center(child: Text('Color',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        if (isChecked || isLineWise)
          GridColumn(
            columnName: 'LineName',
            label: Container(
                color: Colors.grey[400],child: const Center(child: Text('Line',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
          ),
        if (isChecked)
          GridColumn(
            columnName: 'AuditDate',
            label: Container(
                color: Colors.grey,child: const Center(child: Text('Date',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
          ),
        GridColumn(
          columnName: 'PassQty',
          label: Container(
              color: Colors.grey[400],child: const Center(child: Text('Pass Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        GridColumn(
          columnName: 'RejectQty',
          label: Container(
              color: Colors.grey[400],child: const Center(child: Text('Reject Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        GridColumn(
          columnName: 'DefectQty',
          label: Container(
              color: Colors.grey[400],child: const Center(child: Text('Defect Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        GridColumn(
          minimumWidth: 50,
          columnName: 'RectifiedQty',
          label: Container(
              color: Colors.grey[400],child: const Center(child: Text('Rectify Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
        ),
        if (!isChecked)
          GridColumn(
            columnName: 'AuditQty',
            label: Container(
                color: Colors.grey[400],child: const Center(child: Text('Audit Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
          ),
        if (!isChecked)
          GridColumn(
            columnName: 'BalanceQty',
            label: Container(
                color: Colors.grey[400],child: const Center(child: Text('Balance Qty',textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)))),
          ),
      ],
    );
  }
}

class _TableDataSource extends DataGridSource {
  final List<Map<String, dynamic>> tableData;
  final bool isChecked;
  final bool isLineWise;
  final int totalPassQty;
  final int totalRejectQty;
  final int totalDefectQty;
  final int totalRectQty;
  final int totalAuditQty;
  final int totalBalQty;

  _TableDataSource({
    required this.tableData,
    required this.isChecked,
    required this.isLineWise,
    required this.totalPassQty,
    required this.totalRejectQty,
    required this.totalDefectQty,
    required this.totalRectQty,
    required this.totalAuditQty,
    required this.totalBalQty,
  }) {
    _dataGridRows = tableData
        .map<DataGridRow>(
          (data) => DataGridRow(
        cells: [
          DataGridCell(columnName: 'StyleNo', value: data['StyleNo']),
          DataGridCell(columnName: 'Color', value: data['Color']),
          if (isChecked || isLineWise)
            DataGridCell(columnName: 'LineName', value: data['LineName']),
          if (isChecked)
            DataGridCell(columnName: 'AuditDate', value: data['AuditDate']),
          DataGridCell(columnName: 'PassQty', value: data['PassQty'] ?? 0),
          DataGridCell(columnName: 'RejectQty', value: data['RejectQty'] ?? 0),
          DataGridCell(columnName: 'DefectQty', value: data['DefectQty'] ?? 0),
          DataGridCell(columnName: 'RectifiedQty', value: data['RectifiedQty'] ?? 0),
          if (!isChecked)
            DataGridCell(columnName: 'AuditQty', value: data['AuditQty'] ?? 0),
          if (!isChecked)
            DataGridCell(columnName: 'BalanceQty', value: data['BalanceQty'] ?? 0),
        ],
      ),
    )
        .toList();
    if (tableData.isNotEmpty) {
      _dataGridRows.add(DataGridRow(cells: [
        DataGridCell(columnName: 'StyleNo', value: 'Total'),
        DataGridCell(columnName: 'Color', value: ''),
        if (isChecked || isLineWise)
          DataGridCell(columnName: 'LineName', value: ''),
        if (isChecked)
          DataGridCell(columnName: 'AuditDate', value: ''),
        DataGridCell(columnName: 'PassQty', value: totalPassQty),
        DataGridCell(columnName: 'RejectQty', value: totalRejectQty),
        DataGridCell(columnName: 'DefectQty', value: totalDefectQty),
        DataGridCell(columnName: 'RectifiedQty', value: totalRectQty),
        if (!isChecked)
          DataGridCell(columnName: 'AuditQty', value: totalAuditQty),
        if (!isChecked)
          DataGridCell(columnName: 'BalanceQty', value: totalBalQty),
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
        color: isTotalRow ? Colors.green[300] : null,cells: row.getCells().map<Widget>((dataCell) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          dataCell.value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }).toList());
  }
}
