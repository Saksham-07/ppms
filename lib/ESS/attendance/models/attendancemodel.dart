/// PAY_CODE : "0550687"
/// UNIT_CODE : "1"
/// DATE : "01-Jun-2024"
/// SHIFT : "G2   "
/// IN_TM : "09:51"
/// OUT_TM : "18:50"
/// TOTAL_W_HRS : "8 HRS 29 MINS"
/// LATE_HRS : "0 HRS 21 MINS"
/// EARLY_HRS : "0"
/// OT_HRS : "0 HRS 50 MINS"
/// STATUS : "P"

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
      String? status,}){
    _paycode = paycode;
    _unitcode = unitcode;
    _date = date;
    _shift = shift;
    _intm = intm;
    _outtm = outtm;
    _totalwhrs = totalwhrs;
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
    _totalwhrs = json['TOTAL_W_HRS'];
    _latehrs = json['LATE_HRS'];
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
Attendancemodel copyWith({  String? paycode,
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
}) => Attendancemodel(  paycode: paycode ?? _paycode,
  unitcode: unitcode ?? _unitcode,
  date: date ?? _date,
  shift: shift ?? _shift,
  intm: intm ?? _intm,
  outtm: outtm ?? _outtm,
  totalwhrs: totalwhrs ?? _totalwhrs,
  latehrs: latehrs ?? _latehrs,
  earlyhrs: earlyhrs ?? _earlyhrs,
  othrs: othrs ?? _othrs,
  status: status ?? _status,
);
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