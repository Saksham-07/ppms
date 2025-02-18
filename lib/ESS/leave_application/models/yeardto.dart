/// yearNo : "2024"

class YearDto {
  YearDto({
      String? yearNo,}){
    _yearNo = yearNo;
}

  YearDto.fromJson(dynamic json) {
    _yearNo = json['yearNo'];
  }
  String? _yearNo;
  YearDto copyWith({  String? yearNo,
}) => YearDto(  yearNo: yearNo ?? _yearNo,
);
  String? get yearNo => _yearNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['yearNo'] = _yearNo;
    return map;
  }

}