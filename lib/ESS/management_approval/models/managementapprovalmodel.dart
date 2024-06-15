/// appId : "6511"
/// appType : "New Joinee"
/// appCatg : 1
/// name : "Balinder Tiwari"
/// unit : "B-30E"
/// dateofSubmission : "09/04/2024"
/// monthlySalary : 27000.0
/// incAmount : 0.0
/// newSalary : 0.0
/// department : "Embroidery"
/// positionCategory : "Staff"
/// positionName : "Supervisor"
/// reportingPerson : "Balram"
/// positionStatus : "Sent for Approval"
/// approver1Status : "Draft"
/// approver2Status : ""
/// approverAVPStatus : ""
/// approver3Status : ""
/// approver4Status : ""
/// approver5Status : ""

class Managementapprovalmodel {
  Managementapprovalmodel({
      String? appId, 
      String? appType, 
      num? appCatg, 
      String? name, 
      String? unit, 
      String? dateofSubmission, 
      num? monthlySalary, 
      num? incAmount, 
      num? newSalary, 
      String? department, 
      String? positionCategory, 
      String? positionName, 
      String? reportingPerson, 
      String? positionStatus, 
      String? approver1Status, 
      String? approver2Status, 
      String? approverAVPStatus, 
      String? approver3Status, 
      String? approver4Status, 
      String? approver5Status,}){
    _appId = appId;
    _appType = appType;
    _appCatg = appCatg;
    _name = name;
    _unit = unit;
    _dateofSubmission = dateofSubmission;
    _monthlySalary = monthlySalary;
    _incAmount = incAmount;
    _newSalary = newSalary;
    _department = department;
    _positionCategory = positionCategory;
    _positionName = positionName;
    _reportingPerson = reportingPerson;
    _positionStatus = positionStatus;
    _approver1Status = approver1Status;
    _approver2Status = approver2Status;
    _approverAVPStatus = approverAVPStatus;
    _approver3Status = approver3Status;
    _approver4Status = approver4Status;
    _approver5Status = approver5Status;
}

  Managementapprovalmodel.fromJson(dynamic json) {
    _appId = json['appId'];
    _appType = json['appType'];
    _appCatg = json['appCatg'];
    _name = json['name'];
    _unit = json['unit'];
    _dateofSubmission = json['dateofSubmission'];
    _monthlySalary = json['monthlySalary'];
    _incAmount = json['incAmount'];
    _newSalary = json['newSalary'];
    _department = json['department'];
    _positionCategory = json['positionCategory'];
    _positionName = json['positionName'];
    _reportingPerson = json['reportingPerson'];
    _positionStatus = json['positionStatus'];
    _approver1Status = json['approver1Status'];
    _approver2Status = json['approver2Status'];
    _approverAVPStatus = json['approverAVPStatus'];
    _approver3Status = json['approver3Status'];
    _approver4Status = json['approver4Status'];
    _approver5Status = json['approver5Status'];
  }
  String? _appId;
  String? _appType;
  num? _appCatg;
  String? _name;
  String? _unit;
  String? _dateofSubmission;
  num? _monthlySalary;
  num? _incAmount;
  num? _newSalary;
  String? _department;
  String? _positionCategory;
  String? _positionName;
  String? _reportingPerson;
  String? _positionStatus;
  String? _approver1Status;
  String? _approver2Status;
  String? _approverAVPStatus;
  String? _approver3Status;
  String? _approver4Status;
  String? _approver5Status;
Managementapprovalmodel copyWith({  String? appId,
  String? appType,
  num? appCatg,
  String? name,
  String? unit,
  String? dateofSubmission,
  num? monthlySalary,
  num? incAmount,
  num? newSalary,
  String? department,
  String? positionCategory,
  String? positionName,
  String? reportingPerson,
  String? positionStatus,
  String? approver1Status,
  String? approver2Status,
  String? approverAVPStatus,
  String? approver3Status,
  String? approver4Status,
  String? approver5Status,
}) => Managementapprovalmodel(  appId: appId ?? _appId,
  appType: appType ?? _appType,
  appCatg: appCatg ?? _appCatg,
  name: name ?? _name,
  unit: unit ?? _unit,
  dateofSubmission: dateofSubmission ?? _dateofSubmission,
  monthlySalary: monthlySalary ?? _monthlySalary,
  incAmount: incAmount ?? _incAmount,
  newSalary: newSalary ?? _newSalary,
  department: department ?? _department,
  positionCategory: positionCategory ?? _positionCategory,
  positionName: positionName ?? _positionName,
  reportingPerson: reportingPerson ?? _reportingPerson,
  positionStatus: positionStatus ?? _positionStatus,
  approver1Status: approver1Status ?? _approver1Status,
  approver2Status: approver2Status ?? _approver2Status,
  approverAVPStatus: approverAVPStatus ?? _approverAVPStatus,
  approver3Status: approver3Status ?? _approver3Status,
  approver4Status: approver4Status ?? _approver4Status,
  approver5Status: approver5Status ?? _approver5Status,
);
  String? get appId => _appId;
  String? get appType => _appType;
  num? get appCatg => _appCatg;
  String? get name => _name;
  String? get unit => _unit;
  String? get dateofSubmission => _dateofSubmission;
  num? get monthlySalary => _monthlySalary;
  num? get incAmount => _incAmount;
  num? get newSalary => _newSalary;
  String? get department => _department;
  String? get positionCategory => _positionCategory;
  String? get positionName => _positionName;
  String? get reportingPerson => _reportingPerson;
  String? get positionStatus => _positionStatus;
  String? get approver1Status => _approver1Status;
  String? get approver2Status => _approver2Status;
  String? get approverAVPStatus => _approverAVPStatus;
  String? get approver3Status => _approver3Status;
  String? get approver4Status => _approver4Status;
  String? get approver5Status => _approver5Status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['appId'] = _appId;
    map['appType'] = _appType;
    map['appCatg'] = _appCatg;
    map['name'] = _name;
    map['unit'] = _unit;
    map['dateofSubmission'] = _dateofSubmission;
    map['monthlySalary'] = _monthlySalary;
    map['incAmount'] = _incAmount;
    map['newSalary'] = _newSalary;
    map['department'] = _department;
    map['positionCategory'] = _positionCategory;
    map['positionName'] = _positionName;
    map['reportingPerson'] = _reportingPerson;
    map['positionStatus'] = _positionStatus;
    map['approver1Status'] = _approver1Status;
    map['approver2Status'] = _approver2Status;
    map['approverAVPStatus'] = _approverAVPStatus;
    map['approver3Status'] = _approver3Status;
    map['approver4Status'] = _approver4Status;
    map['approver5Status'] = _approver5Status;
    return map;
  }

}