import 'package:intl/intl.dart';

class Attendancemodel {
  Attendancemodel({
    String? paycode,
    String? unitcode,
    String? date,
    String? shift,
    String? intm,
    String? outtm,
    String? totalwhrs,
    String? latehrs,
    String? earlyhrs,
    String? othrs,
    String? status,
  }) {
    _paycode = paycode;
    _unitcode = unitcode;
    _date = formatDateString(date);
    _shift = shift;
    _intm = intm;
    _outtm = outtm;
    _totalwhrs = formatTotalWHrs(totalwhrs);
    _latehrs = latehrs;
    _earlyhrs = earlyhrs;
    _othrs = othrs;
    _status = status;
  }

  Attendancemodel.fromJson(dynamic json) {
    _paycode = json['PAY_CODE'];
    _unitcode = json['UNIT_CODE'];
    _date = json['DATE'];
    _shift = json['SHIFT'];
    _intm = json['IN_TM'];
    _outtm = json['OUT_TM'];
    _totalwhrs = formatTotalWHrs(json['TOTAL_W_HRS']);
    _latehrs = formatTotalWHrs(json['LATE_HRS']);
    _earlyhrs = json['EARLY_HRS'];
    _othrs = json['OT_HRS'];
    _status = json['STATUS'];
  }

  String? _paycode;
  String? _unitcode;
  String? _date;
  String? _shift;
  String? _intm;
  String? _outtm;
  String? _totalwhrs;
  String? _latehrs;
  String? _earlyhrs;
  String? _othrs;
  String? _status;

  static String formatDateString(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final DateTime dateTime = DateFormat('dd-MMM-yyyy').parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return dateStr; // In case of parsing error, return the original string
    }
  }

  static String formatTotalWHrs(String? totalWHrsStr) {
    if (totalWHrsStr == null) return '';
    try {
      final parts = totalWHrsStr.split(' ');
      if (parts.length >= 4) {
        final hours = int.parse(parts[0]).toString().padLeft(2, '0');
        final mins = int.parse(parts[2]).toString().padLeft(2, '0');
        return '$hours:$mins';
      }
      return totalWHrsStr;
    } catch (e) {
      return totalWHrsStr; // In case of parsing error, return the original string
    }
  }

  // Getters
  String? get paycode => _paycode;
  String? get unitcode => _unitcode;
  String? get date => _date;
  String? get shift => _shift;
  String? get intm => _intm;
  String? get outtm => _outtm;
  String? get totalwhrs => _totalwhrs;
  String? get latehrs => _latehrs;
  String? get earlyhrs => _earlyhrs;
  String? get othrs => _othrs;
  String? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PAY_CODE'] = _paycode;
    map['UNIT_CODE'] = _unitcode;
    map['DATE'] = _date;
    map['SHIFT'] = _shift;
    map['IN_TM'] = _intm;
    map['OUT_TM'] = _outtm;
    map['TOTAL_W_HRS'] = _totalwhrs;
    map['LATE_HRS'] = _latehrs;
    map['EARLY_HRS'] = _earlyhrs;
    map['OT_HRS'] = _othrs;
    map['STATUS'] = _status;
    return map;
  }
}
