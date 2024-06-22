/// APP_ID : 76353
/// PAY_CODE : "0550687"
/// EMP_CODE : "53"
/// U_CODE : "1"
/// APP_TYPE : "Mispunch"
/// FROM_DT : "22-Jun-2024"
/// TO_DT : "22-Jun-2024"
/// DAYS_COUNT : 1.0
/// APP_COUNT : ""
/// INT_IME : ""
/// OUT_TIME : "22 : 15"
/// APP_REMARKS : ""
/// APP_STATUS : "Sent for Approval"
/// LEAVE_TYPE : ""
/// APPLIED_ON : "22-Jun-2024"
/// APPROVED_ON : null
/// APPROVED_BY : null
/// APPROVAL_REMARKS : null
/// EMP_ADDRESS : ""
/// MOBILE_NO : ""
/// DAY_PART : "Second Half"
/// VISIT_LOCATION : ""
/// VISIT_LOCATION_TYPE : "null"
/// Mis_Punch_Reason : "Finger punching issue due to Mehndi / cut"

class Selfleaveapp {
  Selfleaveapp({
      num? appid, 
      String? paycode, 
      String? empcode, 
      String? ucode, 
      String? apptype, 
      String? fromdt, 
      String? todt, 
      num? dayscount, 
      String? appcount, 
      String? intime, 
      String? outtime, 
      String? appremarks, 
      String? appstatus, 
      String? leavetype, 
      String? appliedon, 
      dynamic approvedon, 
      dynamic approvedby, 
      dynamic approvalremarks, 
      String? empaddress, 
      String? mobileno, 
      String? daypart, 
      String? visitlocation, 
      String? visitlocationtype, 
      String? misPunchReason,}){
    _appid = appid;
    _paycode = paycode;
    _empcode = empcode;
    _ucode = ucode;
    _apptype = apptype;
    _fromdt = fromdt;
    _todt = todt;
    _dayscount = dayscount;
    _appcount = appcount;
    _intime = intime;
    _outtime = outtime;
    _appremarks = appremarks;
    _appstatus = appstatus;
    _leavetype = leavetype;
    _appliedon = appliedon;
    _approvedon = approvedon;
    _approvedby = approvedby;
    _approvalremarks = approvalremarks;
    _empaddress = empaddress;
    _mobileno = mobileno;
    _daypart = daypart;
    _visitlocation = visitlocation;
    _visitlocationtype = visitlocationtype;
    _misPunchReason = misPunchReason;
}

  Selfleaveapp.fromJson(dynamic json) {
    _appid = json['APP_ID'];
    _paycode = json['PAY_CODE'];
    _empcode = json['EMP_CODE'];
    _ucode = json['U_CODE'];
    _apptype = json['APP_TYPE'];
    _fromdt = json['FROM_DT'];
    _todt = json['TO_DT'];
    _dayscount = json['DAYS_COUNT'];
    _appcount = json['APP_COUNT'];
    _intime = json['INT_IME'];
    _outtime = json['OUT_TIME'];
    _appremarks = json['APP_REMARKS'];
    _appstatus = json['APP_STATUS'];
    _leavetype = json['LEAVE_TYPE'];
    _appliedon = json['APPLIED_ON'];
    _approvedon = json['APPROVED_ON'];
    _approvedby = json['APPROVED_BY'];
    _approvalremarks = json['APPROVAL_REMARKS'];
    _empaddress = json['EMP_ADDRESS'];
    _mobileno = json['MOBILE_NO'];
    _daypart = json['DAY_PART'];
    _visitlocation = json['VISIT_LOCATION'];
    _visitlocationtype = json['VISIT_LOCATION_TYPE'];
    _misPunchReason = json['Mis_Punch_Reason'];
  }
  num? _appid;
  String? _paycode;
  String? _empcode;
  String? _ucode;
  String? _apptype;
  String? _fromdt;
  String? _todt;
  num? _dayscount;
  String? _appcount;
  String? _intime;
  String? _outtime;
  String? _appremarks;
  String? _appstatus;
  String? _leavetype;
  String? _appliedon;
  dynamic _approvedon;
  dynamic _approvedby;
  dynamic _approvalremarks;
  String? _empaddress;
  String? _mobileno;
  String? _daypart;
  String? _visitlocation;
  String? _visitlocationtype;
  String? _misPunchReason;
Selfleaveapp copyWith({  num? appid,
  String? paycode,
  String? empcode,
  String? ucode,
  String? apptype,
  String? fromdt,
  String? todt,
  num? dayscount,
  String? appcount,
  String? intime,
  String? outtime,
  String? appremarks,
  String? appstatus,
  String? leavetype,
  String? appliedon,
  dynamic approvedon,
  dynamic approvedby,
  dynamic approvalremarks,
  String? empaddress,
  String? mobileno,
  String? daypart,
  String? visitlocation,
  String? visitlocationtype,
  String? misPunchReason,
}) => Selfleaveapp(  appid: appid ?? _appid,
  paycode: paycode ?? _paycode,
  empcode: empcode ?? _empcode,
  ucode: ucode ?? _ucode,
  apptype: apptype ?? _apptype,
  fromdt: fromdt ?? _fromdt,
  todt: todt ?? _todt,
  dayscount: dayscount ?? _dayscount,
  appcount: appcount ?? _appcount,
  intime: intime ?? _intime,
  outtime: outtime ?? _outtime,
  appremarks: appremarks ?? _appremarks,
  appstatus: appstatus ?? _appstatus,
  leavetype: leavetype ?? _leavetype,
  appliedon: appliedon ?? _appliedon,
  approvedon: approvedon ?? _approvedon,
  approvedby: approvedby ?? _approvedby,
  approvalremarks: approvalremarks ?? _approvalremarks,
  empaddress: empaddress ?? _empaddress,
  mobileno: mobileno ?? _mobileno,
  daypart: daypart ?? _daypart,
  visitlocation: visitlocation ?? _visitlocation,
  visitlocationtype: visitlocationtype ?? _visitlocationtype,
  misPunchReason: misPunchReason ?? _misPunchReason,
);
  num? get appid => _appid;
  String? get paycode => _paycode;
  String? get empcode => _empcode;
  String? get ucode => _ucode;
  String? get apptype => _apptype;
  String? get fromdt => _fromdt;
  String? get todt => _todt;
  num? get dayscount => _dayscount;
  String? get appcount => _appcount;
  String? get intime => _intime;
  String? get outtime => _outtime;
  String? get appremarks => _appremarks;
  String? get appstatus => _appstatus;
  String? get leavetype => _leavetype;
  String? get appliedon => _appliedon;
  dynamic get approvedon => _approvedon;
  dynamic get approvedby => _approvedby;
  dynamic get approvalremarks => _approvalremarks;
  String? get empaddress => _empaddress;
  String? get mobileno => _mobileno;
  String? get daypart => _daypart;
  String? get visitlocation => _visitlocation;
  String? get visitlocationtype => _visitlocationtype;
  String? get misPunchReason => _misPunchReason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['APP_ID'] = _appid;
    map['PAY_CODE'] = _paycode;
    map['EMP_CODE'] = _empcode;
    map['U_CODE'] = _ucode;
    map['APP_TYPE'] = _apptype;
    map['FROM_DT'] = _fromdt;
    map['TO_DT'] = _todt;
    map['DAYS_COUNT'] = _dayscount;
    map['APP_COUNT'] = _appcount;
    map['INT_IME'] = _intime;
    map['OUT_TIME'] = _outtime;
    map['APP_REMARKS'] = _appremarks;
    map['APP_STATUS'] = _appstatus;
    map['LEAVE_TYPE'] = _leavetype;
    map['APPLIED_ON'] = _appliedon;
    map['APPROVED_ON'] = _approvedon;
    map['APPROVED_BY'] = _approvedby;
    map['APPROVAL_REMARKS'] = _approvalremarks;
    map['EMP_ADDRESS'] = _empaddress;
    map['MOBILE_NO'] = _mobileno;
    map['DAY_PART'] = _daypart;
    map['VISIT_LOCATION'] = _visitlocation;
    map['VISIT_LOCATION_TYPE'] = _visitlocationtype;
    map['Mis_Punch_Reason'] = _misPunchReason;
    return map;
  }

}