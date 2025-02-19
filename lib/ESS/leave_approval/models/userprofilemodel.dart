/// EMPLOYEE_ID : 9970
/// LOGIN_ID : "0552445"
/// EMPLOYEE_NAME : "SATENDRA KUMAR CHANGWAL"
/// UNIT : "1"
/// UNIT_LOCATION : "A-55"
/// DEPARTMENT : "IT"
/// DESIGNATION : "IT HEAD"
/// REPORTING_PERSON : "26"
/// REPORTING_PERSON_NAME : "SUMIT MAHAJAN"

class Userprofilemodel {
  Userprofilemodel({
      num? employeeid, 
      String? loginid, 
      String? employeename, 
      String? unit, 
      String? unitlocation, 
      String? department, 
      String? designation, 
      String? reportingperson, 
      String? reportingpersonname,}){
    _employeeid = employeeid;
    _loginid = loginid;
    _employeename = employeename;
    _unit = unit;
    _unitlocation = unitlocation;
    _department = department;
    _designation = designation;
    _reportingperson = reportingperson;
    _reportingpersonname = reportingpersonname;
}

  Userprofilemodel.fromJson(dynamic json) {
    _employeeid = json['EMPLOYEE_ID'];
    _loginid = json['LOGIN_ID'];
    _employeename = json['EMPLOYEE_NAME'];
    _unit = json['UNIT'];
    _unitlocation = json['UNIT_LOCATION'];
    _department = json['DEPARTMENT'];
    _designation = json['DESIGNATION'];
    _reportingperson = json['REPORTING_PERSON'];
    _reportingpersonname = json['REPORTING_PERSON_NAME'];
  }
  num? _employeeid;
  String? _loginid;
  String? _employeename;
  String? _unit;
  String? _unitlocation;
  String? _department;
  String? _designation;
  String? _reportingperson;
  String? _reportingpersonname;
Userprofilemodel copyWith({  num? employeeid,
  String? loginid,
  String? employeename,
  String? unit,
  String? unitlocation,
  String? department,
  String? designation,
  String? reportingperson,
  String? reportingpersonname,
}) => Userprofilemodel(  employeeid: employeeid ?? _employeeid,
  loginid: loginid ?? _loginid,
  employeename: employeename ?? _employeename,
  unit: unit ?? _unit,
  unitlocation: unitlocation ?? _unitlocation,
  department: department ?? _department,
  designation: designation ?? _designation,
  reportingperson: reportingperson ?? _reportingperson,
  reportingpersonname: reportingpersonname ?? _reportingpersonname,
);
  num? get employeeid => _employeeid;
  String? get loginid => _loginid;
  String? get employeename => _employeename;
  String? get unit => _unit;
  String? get unitlocation => _unitlocation;
  String? get department => _department;
  String? get designation => _designation;
  String? get reportingperson => _reportingperson;
  String? get reportingpersonname => _reportingpersonname;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EMPLOYEE_ID'] = _employeeid;
    map['LOGIN_ID'] = _loginid;
    map['EMPLOYEE_NAME'] = _employeename;
    map['UNIT'] = _unit;
    map['UNIT_LOCATION'] = _unitlocation;
    map['DEPARTMENT'] = _department;
    map['DESIGNATION'] = _designation;
    map['REPORTING_PERSON'] = _reportingperson;
    map['REPORTING_PERSON_NAME'] = _reportingpersonname;
    return map;
  }

}