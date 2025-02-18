/// monthNo : "6"
/// monthName : "Jun"

class Monthmodel {
  Monthmodel({
      String? monthNo, 
      String? monthName,}){
    _monthNo = monthNo;
    _monthName = monthName;
}

  Monthmodel.fromJson(dynamic json) {
    _monthNo = json['monthNo'];
    _monthName = json['monthName'];
  }
  String? _monthNo;
  String? _monthName;
Monthmodel copyWith({  String? monthNo,
  String? monthName,
}) => Monthmodel(  monthNo: monthNo ?? _monthNo,
  monthName: monthName ?? _monthName,
);
  String? get monthNo => _monthNo;
  String? get monthName => _monthName;

  SetVal(String monthNumber,String monthName)
  {
    _monthNo=monthNumber;
    _monthName=monthName;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['monthNo'] = _monthNo;
    map['monthName'] = _monthName;
    return map;
  }

}