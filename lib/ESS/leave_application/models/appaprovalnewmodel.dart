/// APP_ID : 75629
/// PAY_CODE : "0390068"
/// EMPLOYEE_NAME : "KAPILA CHANDRA PADHY"
/// EMP_CODE : "7619"
/// U_CODE : "1"
/// APP_TYPE : "Leave"
/// FROM_DT : "06-Jun-2024"
/// TO_DT : "06-Jun-2024"
/// DAYS_COUNT : 0.5
/// APP_COUNT : "Half Day"
/// INT_IME : ""
/// OUT_TIME : ""
/// APP_REMARKS : "urgent work medical"
/// APP_STATUS : "Sent for Approval"
/// LEAVE_TYPE : "0"
/// APPLIED_ON : "08-Jun-2024"
/// APPROVED_ON : null
/// APPROVED_BY : null
/// APPROVAL_REMARKS : null
/// EMP_ADDRESS : ""
/// MOBILE_NO : ""
/// DAY_PART : "First Half"
/// VISIT_LOCATION : ""
/// VISIT_LOCATION_TYPE : ""

class Appaprovalnewmodel {
  Appaprovalnewmodel({
      num? appid, 
      String? paycode, 
      String? employeename, 
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
      String? visitlocationtype,}){
    _appid = appid;
    _paycode = paycode;
    _employeename = employeename;
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
}

  Appaprovalnewmodel.fromJson(dynamic json) {
    _appid = json['APP_ID'];
    _paycode = json['PAY_CODE'];
    _employeename = json['EMPLOYEE_NAME'];
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
  }
  num? _appid;
  String? _paycode;
  String? _employeename;
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
Appaprovalnewmodel copyWith({  num? appid,
  String? paycode,
  String? employeename,
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
}) => Appaprovalnewmodel(  appid: appid ?? _appid,
  paycode: paycode ?? _paycode,
  employeename: employeename ?? _employeename,
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
);
  num? get appid => _appid;
  String? get paycode => _paycode;
  String? get employeename => _employeename;
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['APP_ID'] = _appid;
    map['PAY_CODE'] = _paycode;
    map['EMPLOYEE_NAME'] = _employeename;
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
    return map;
  }

}