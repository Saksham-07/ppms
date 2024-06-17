/// pendingManagementApp : 1
/// pendingLeaveApproval : 6

class Pendingapprovalmodel {
  Pendingapprovalmodel({
      num? pendingManagementApp, 
      num? pendingLeaveApproval,}){
    _pendingManagementApp = pendingManagementApp;
    _pendingLeaveApproval = pendingLeaveApproval;
}

  Pendingapprovalmodel.fromJson(dynamic json) {
    _pendingManagementApp = json['pendingManagementApp'];
    _pendingLeaveApproval = json['pendingLeaveApproval'];
  }
  num? _pendingManagementApp;
  num? _pendingLeaveApproval;
Pendingapprovalmodel copyWith({  num? pendingManagementApp,
  num? pendingLeaveApproval,
}) => Pendingapprovalmodel(  pendingManagementApp: pendingManagementApp ?? _pendingManagementApp,
  pendingLeaveApproval: pendingLeaveApproval ?? _pendingLeaveApproval,
);
  num? get pendingManagementApp => _pendingManagementApp;
  num? get pendingLeaveApproval => _pendingLeaveApproval;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pendingManagementApp'] = _pendingManagementApp;
    map['pendingLeaveApproval'] = _pendingLeaveApproval;
    return map;
  }

}