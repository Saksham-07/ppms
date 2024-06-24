import 'package:flutter/material.dart';
import 'attendance_report_columns.dart';

class TTableDataHelper
{
  static List<TTableColumns> kTableColumnsList=[
    TTableColumns(title: 'Date',width: 80.0),
    TTableColumns(title: 'In',width: 40.0),
    TTableColumns(title: 'Out',width: 40.0),
    TTableColumns(title: 'Status',width: 40.0),
    TTableColumns(title: 'Hours',width: 80.0),
  ];
}