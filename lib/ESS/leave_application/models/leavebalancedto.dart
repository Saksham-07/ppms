/// PAYCODE : "0550205"
/// EMP_CODE : "153"
/// EL_OPEN : 0.0
/// CL_OPEN : 0.0
/// SL_OPEN : 0.0
/// EL_EARN : 0.0
/// EL_EARN_P : 0.0
/// EL_TK : 0.0
/// CL_TK : 0.0
/// SL_TK : 0.0
/// EL_BAL : 30.0
/// CL_BAL : 7.0
/// SL_BAL : 21.0

class Leavebalancedto {
  Leavebalancedto({
      String? paycode, 
      String? empcode, 
      num? elopen, 
      num? clopen, 
      num? slopen, 
      num? elearn, 
      num? elearnp, 
      num? eltk, 
      num? cltk, 
      num? sltk, 
      num? elbal, 
      num? clbal, 
      num? slbal,}){
    _paycode = paycode;
    _empcode = empcode;
    _elopen = elopen;
    _clopen = clopen;
    _slopen = slopen;
    _elearn = elearn;
    _elearnp = elearnp;
    _eltk = eltk;
    _cltk = cltk;
    _sltk = sltk;
    _elbal = elbal;
    _clbal = clbal;
    _slbal = slbal;
}

  Leavebalancedto.fromJson(dynamic json) {
    _paycode = json['PAYCODE'];
    _empcode = json['EMP_CODE'];
    _elopen = json['EL_OPEN'];
    _clopen = json['CL_OPEN'];
    _slopen = json['SL_OPEN'];
    _elearn = json['EL_EARN'];
    _elearnp = json['EL_EARN_P'];
    _eltk = json['EL_TK'];
    _cltk = json['CL_TK'];
    _sltk = json['SL_TK'];
    _elbal = json['EL_BAL'];
    _clbal = json['CL_BAL'];
    _slbal = json['SL_BAL'];
  }
  String? _paycode;
  String? _empcode;
  num? _elopen;
  num? _clopen;
  num? _slopen;
  num? _elearn;
  num? _elearnp;
  num? _eltk;
  num? _cltk;
  num? _sltk;
  num? _elbal;
  num? _clbal;
  num? _slbal;
Leavebalancedto copyWith({  String? paycode,
  String? empcode,
  num? elopen,
  num? clopen,
  num? slopen,
  num? elearn,
  num? elearnp,
  num? eltk,
  num? cltk,
  num? sltk,
  num? elbal,
  num? clbal,
  num? slbal,
}) => Leavebalancedto(  paycode: paycode ?? _paycode,
  empcode: empcode ?? _empcode,
  elopen: elopen ?? _elopen,
  clopen: clopen ?? _clopen,
  slopen: slopen ?? _slopen,
  elearn: elearn ?? _elearn,
  elearnp: elearnp ?? _elearnp,
  eltk: eltk ?? _eltk,
  cltk: cltk ?? _cltk,
  sltk: sltk ?? _sltk,
  elbal: elbal ?? _elbal,
  clbal: clbal ?? _clbal,
  slbal: slbal ?? _slbal,
);
  String? get paycode => _paycode;
  String? get empcode => _empcode;
  num? get elopen => _elopen;
  num? get clopen => _clopen;
  num? get slopen => _slopen;
  num? get elearn => _elearn;
  num? get elearnp => _elearnp;
  num? get eltk => _eltk;
  num? get cltk => _cltk;
  num? get sltk => _sltk;
  num? get elbal => _elbal;
  num? get clbal => _clbal;
  num? get slbal => _slbal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PAYCODE'] = _paycode;
    map['EMP_CODE'] = _empcode;
    map['EL_OPEN'] = _elopen;
    map['CL_OPEN'] = _clopen;
    map['SL_OPEN'] = _slopen;
    map['EL_EARN'] = _elearn;
    map['EL_EARN_P'] = _elearnp;
    map['EL_TK'] = _eltk;
    map['CL_TK'] = _cltk;
    map['SL_TK'] = _sltk;
    map['EL_BAL'] = _elbal;
    map['CL_BAL'] = _clbal;
    map['SL_BAL'] = _slbal;
    return map;
  }

}