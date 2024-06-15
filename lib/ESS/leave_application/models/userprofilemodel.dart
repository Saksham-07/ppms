/// EMPLOYEE_ID : 26
/// LOGIN_ID : "0550205"
/// EMPLOYEE_NAME : "SUMIT MAHAJAN"
/// UNIT : "1"
/// DEPARTMENT : "DIRECTORATE"
/// DESIGNATION : "EXECUTIVE DIRECTOR"

class Userprofilemodel {
  Userprofilemodel({
      num? employeeid, 
      String? loginid, 
      String? employeename, 
      String? unit, 
      String? department, 
      String? designation,}){
    _employeeid = employeeid;
    _loginid = loginid;
    _employeename = employeename;
    _unit = unit;
    _department = department;
    _designation = designation;
}

  Userprofilemodel.fromJson(dynamic json) {
    _employeeid = json['EMPLOYEE_ID'];
    _loginid = json['LOGIN_ID'];
    _employeename = json['EMPLOYEE_NAME'];
    _unit = json['UNIT'];
    _department = json['DEPARTMENT'];
    _designation = json['DESIGNATION'];
  }
  num? _employeeid;
  String? _loginid;
  String? _employeename;
  String? _unit;
  String? _department;
  String? _designation;
Userprofilemodel copyWith({  num? employeeid,
  String? loginid,
  String? employeename,
  String? unit,
  String? department,
  String? designation,
}) => Userprofilemodel(  employeeid: employeeid ?? _employeeid,
  loginid: loginid ?? _loginid,
  employeename: employeename ?? _employeename,
  unit: unit ?? _unit,
  department: department ?? _department,
  designation: designation ?? _designation,
);
  num? get employeeid => _employeeid;
  String? get loginid => _loginid;
  String? get employeename => _employeename;
  String? get unit => _unit;
  String? get department => _department;
  String? get designation => _designation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EMPLOYEE_ID'] = _employeeid;
    map['LOGIN_ID'] = _loginid;
    map['EMPLOYEE_NAME'] = _employeename;
    map['UNIT'] = _unit;
    map['DEPARTMENT'] = _department;
    map['DESIGNATION'] = _designation;
    return map;
  }

}