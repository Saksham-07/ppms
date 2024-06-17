import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FinishDetail {
  final int askingRate;
  final int balToPack;
  final int balToPackVal;
  final int balToSam;
  final int checker;
  final int finishQty;
  final int pressMan;
  final int prodSamProduced;
  final int stitchQty;
  final int totalMnpwr;
  final int wip;
  final String unitShortCode;

  FinishDetail({
    required this.askingRate,
    required this.balToPack,
    required this.balToPackVal,
    required this.balToSam,
    required this.checker,
    required this.finishQty,
    required this.pressMan,
    required this.prodSamProduced,
    required this.stitchQty,
    required this.totalMnpwr,
    required this.wip,
    required this.unitShortCode,
  });

  factory FinishDetail.fromJson(Map<String, dynamic> json) {
    return FinishDetail(
      askingRate: (json['AskingRate'] as num?)?.toInt() ?? 0,
      balToPack: (json['BalToPack'] as num?)?.toInt() ?? 0,
      balToPackVal: (json['BalToPackValue'] as num?)?.toInt() ?? 0,
      balToSam: (json['BalToSam'] as num?)?.toInt() ?? 0,
      checker: (json['Checker'] as num?)?.toInt() ?? 0,
      finishQty: (json['FinishQty'] as num?)?.toInt() ?? 0,
      pressMan: (json['PressMan'] as num?)?.toInt() ?? 0,
      prodSamProduced: (json['ProdSamProduced'] as num?)?.toInt() ?? 0,
      stitchQty: (json['StitchQty'] as num?)?.toInt() ?? 0,
      totalMnpwr: (json['TotalMnpwr'] as num?)?.toInt() ?? 0,
      wip: (json['WIP'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

class SamProdDetail {
  final double avgSam;
  final int stitchInHouseSam;
  final int stitchInHouseTotal;
  final int stitchOutSam;
  final int stitchOutTotal;
  final int stitchPcsrateSam;
  final int stitchPcsrateTotal;
  final int stitchSam;
  final int stitchTotal;
  final double todayCost;
  final double totalCost;
  final String unitShortCode;

  SamProdDetail({
    required this.avgSam,
    required this.stitchInHouseSam,
    required this.stitchInHouseTotal,
    required this.stitchOutSam,
    required this.stitchOutTotal,
    required this.stitchPcsrateSam,
    required this.stitchPcsrateTotal,
    required this.stitchSam,
    required this.stitchTotal,
    required this.todayCost,
    required this.totalCost,
    required this.unitShortCode,
  });

  factory SamProdDetail.fromJson(Map<String, dynamic> json) {
    double toTwoDecimalPlaces(double value) {
      return double.parse(value.toStringAsFixed(2));
    }

    return SamProdDetail(
      avgSam: toTwoDecimalPlaces((json['AvgSam'] as num?)?.toDouble() ?? 0.0),
      stitchInHouseSam: (json['StitchInHouseSam'] as num?)?.toInt() ?? 0,
      stitchInHouseTotal: (json['StitchInHouseTotal'] as num?)?.toInt() ?? 0,
      stitchOutSam: (json['StitchOutSam'] as num?)?.toInt() ?? 0,
      stitchOutTotal: (json['StitchOutTotal'] as num?)?.toInt() ?? 0,
      stitchPcsrateSam: (json['StitchPcsrateSam'] as num?)?.toInt() ?? 0,
      stitchPcsrateTotal: (json['StitchPcsrateTotal'] as num?)?.toInt() ?? 0,
      stitchSam: (json['StitchSam'] as num?)?.toInt() ?? 0,
      stitchTotal: (json['StitchTotal'] as num?)?.toInt() ?? 0,
      todayCost: toTwoDecimalPlaces((json['TodayCost'] as num?)?.toDouble() ?? 0.0),
      totalCost: toTwoDecimalPlaces((json['TotalCost'] as num?)?.toDouble() ?? 0.0),
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

class AuditDetail {
  final int exFailFTD;
  final int exFailMTD;
  final int exFailYTD;
  final int exPassFTD;
  final int exPassMTD;
  final int exPassYTD;
  final int finishAuditToday;
  final int finishAuditTotal;
  final int inspectionToday;
  final int inspectionTotal;
  final int stitchAuditToday;
  final int stitchAuditTotal;
  final String unitShortCode;

  AuditDetail({
    required this.exFailFTD,
    required this.exFailMTD,
    required this.exFailYTD,
    required this.exPassFTD,
    required this.exPassMTD,
    required this.exPassYTD,
    required this.finishAuditToday,
    required this.finishAuditTotal,
    required this.inspectionToday,
    required this.inspectionTotal,
    required this.stitchAuditToday,
    required this.stitchAuditTotal,
    required this.unitShortCode,
  });

  factory AuditDetail.fromJson(Map<String, dynamic> json) {
    return AuditDetail(
      exFailFTD: (json['ExFailFTD'] as num?)?.toInt() ?? 0,
      exFailMTD: (json['ExFailMTD'] as num?)?.toInt() ?? 0,
      exFailYTD: (json['ExFailYTD'] as num?)?.toInt() ?? 0,
      exPassFTD: (json['ExPassFTD'] as num?)?.toInt() ?? 0,
      exPassMTD: (json['ExPassMTD'] as num?)?.toInt() ?? 0,
      exPassYTD: (json['ExPassYTD'] as num?)?.toInt() ?? 0,
      finishAuditToday: (json['FinishAuditToday'] as num?)?.toInt() ?? 0,
      finishAuditTotal: (json['FinishAuditTotal'] as num?)?.toInt() ?? 0,
      inspectionToday: (json['InspectionToday'] as num?)?.toInt() ?? 0,
      inspectionTotal: (json['InspectionTotal'] as num?)?.toInt() ?? 0,
      stitchAuditToday: (json['StitchAuditToday'] as num?)?.toInt() ?? 0,
      stitchAuditTotal: (json['StitchAuditTotal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

class OtDetail {
  final int cuttingOtAmtFTD;
  final int cuttingOtAmtMTD;
  final int cuttingOthrsFTD;
  final int cuttingOthrsMTD;
  final int cuttingPerHrFTD;
  final int cuttingPerHrMTD;
  final int finishOtAmtFTD;
  final int finishOtAmtMTD;
  final int finishOthrsFTD;
  final int finishOthrsMTD;
  final int finishPerHrFTD;
  final int finishPerHrMTD;
  final int stitchOtAmtFTD;
  final int stitchOtAmtMTD;
  final int stitchOthrsFTD;
  final int stitchOthrsMTD;
  final int stitchPerHrFTD;
  final int stitchPerHrMTD;
  final int todayOtAmtFTD;
  final int todayOtAmtMTD;
  final int todayOthrsFTD;
  final int todayOthrsMTD;
  final int todayPerHrFTD;
  final int todayPerHrMTD;
  final String unitCode;

  OtDetail({
    required this.cuttingOtAmtFTD,
    required this.cuttingOtAmtMTD,
    required this.cuttingOthrsFTD,
    required this.cuttingOthrsMTD,
    required this.cuttingPerHrFTD,
    required this.cuttingPerHrMTD,
    required this.finishOtAmtFTD,
    required this.finishOtAmtMTD,
    required this.finishOthrsFTD,
    required this.finishOthrsMTD,
    required this.finishPerHrFTD,
    required this.finishPerHrMTD,
    required this.stitchOtAmtFTD,
    required this.stitchOtAmtMTD,
    required this.stitchOthrsFTD,
    required this.stitchOthrsMTD,
    required this.stitchPerHrFTD,
    required this.stitchPerHrMTD,
    required this.todayOtAmtFTD,
    required this.todayOtAmtMTD,
    required this.todayOthrsFTD,
    required this.todayOthrsMTD,
    required this.todayPerHrFTD,
    required this.todayPerHrMTD,
    required this.unitCode,
  });

  factory OtDetail.fromJson(Map<String, dynamic> json) {
    return OtDetail(
      cuttingOtAmtFTD: (json['CuttingOtAmtFTD'] as num?)?.toInt() ?? 0,
      cuttingOtAmtMTD: (json['CuttingOtAmtMTD'] as num?)?.toInt() ?? 0,
      cuttingOthrsFTD: (json['CuttingOthrsFTD'] as num?)?.toInt() ?? 0,
      cuttingOthrsMTD: (json['CuttingOthrsMTD'] as num?)?.toInt() ?? 0,
      cuttingPerHrFTD: (json['CuttingPerHrFTD'] as num?)?.toInt() ?? 0,
      cuttingPerHrMTD: (json['CuttingPerHrMTD'] as num?)?.toInt() ?? 0,
      finishOtAmtFTD: (json['FinishOtAmtFTD'] as num?)?.toInt() ?? 0,
      finishOtAmtMTD: (json['FinishOtAmtMTD'] as num?)?.toInt() ?? 0,
      finishOthrsFTD: (json['FinishOthrsFTD'] as num?)?.toInt() ?? 0,
      finishOthrsMTD: (json['FinishOthrsMTD'] as num?)?.toInt() ?? 0,
      finishPerHrFTD: (json['FinishPerHrFTD'] as num?)?.toInt() ?? 0,
      finishPerHrMTD: (json['FinishPerHrMTD'] as num?)?.toInt() ?? 0,
      stitchOtAmtFTD: (json['StitchOtAmtFTD'] as num?)?.toInt() ?? 0,
      stitchOtAmtMTD: (json['StitchOtAmtMTD'] as num?)?.toInt() ?? 0,
      stitchOthrsFTD: (json['StitchOthrsFTD'] as num?)?.toInt() ?? 0,
      stitchOthrsMTD: (json['StitchOthrsMTD'] as num?)?.toInt() ?? 0,
      stitchPerHrFTD: (json['StitchPerHrFTD'] as num?)?.toInt() ?? 0,
      stitchPerHrMTD: (json['StitchPerHrMTD'] as num?)?.toInt() ?? 0,
      todayOtAmtFTD: (json['TotalOtAmtFTD'] as num?)?.toInt() ?? 0,
      todayOtAmtMTD: (json['TotalOtAmtMTD'] as num?)?.toInt() ?? 0,
      todayOthrsFTD: (json['TotalOthrsFTD'] as num?)?.toInt() ?? 0,
      todayOthrsMTD: (json['TotalOthrsMTD'] as num?)?.toInt() ?? 0,
      todayPerHrFTD: (json['TotalPerHrFTD'] as num?)?.toInt() ?? 0,
      todayPerHrMTD: (json['TotalPerHrMTD'] as num?)?.toInt() ?? 0,
      unitCode: json['UnitCode'] ?? '',
    );
  }
}

class ProductionData {
  final int cuttingToday;
  final int cuttingTotal;
  final int finishInouseToday;
  final int finishInouseTotal;
  final int finishOutToday;
  final int finishOutTotal;
  final int finishPcsRateToday;
  final int finishPcsRateTotal;
  final int finishToday;
  final int finishTotal;
  final int shipMonthPcs;
  final int shipMonthRate;
  final int shipTodayPcs;
  final int shipTodayRate;
  final int shipYearPcs;
  final int shipYearRate;
  final int stitchInouseToday;
  final int stitchInouseTotal;
  final int stitchOutToday;
  final int stitchOutTotal;
  final int stitchPcsRateToday;
  final int stitchPcsRateTotal;
  final int stitchToday;
  final int stitchTotal;
  final String unitShortCode;

  ProductionData({
    required this.cuttingToday,
    required this.cuttingTotal,
    required this.finishInouseToday,
    required this.finishInouseTotal,
    required this.finishOutToday,
    required this.finishOutTotal,
    required this.finishPcsRateToday,
    required this.finishPcsRateTotal,
    required this.finishToday,
    required this.finishTotal,
    required this.shipMonthPcs,
    required this.shipMonthRate,
    required this.shipTodayPcs,
    required this.shipTodayRate,
    required this.shipYearPcs,
    required this.shipYearRate,
    required this.stitchInouseToday,
    required this.stitchInouseTotal,
    required this.stitchOutToday,
    required this.stitchOutTotal,
    required this.stitchPcsRateToday,
    required this.stitchPcsRateTotal,
    required this.stitchToday,
    required this.stitchTotal,
    required this.unitShortCode,
  });

  factory ProductionData.fromJson(Map<String, dynamic> json) {
    return ProductionData(
      cuttingToday: (json['CuttingToday'] as num?)?.toInt() ?? 0,
      cuttingTotal: (json['CuttingTotal'] as num?)?.toInt() ?? 0,
      finishInouseToday: (json['FinishInouseToday'] as num?)?.toInt() ?? 0,
      finishInouseTotal: (json['FinishInouseTotal'] as num?)?.toInt() ?? 0,
      finishOutToday: (json['FinishOutToday'] as num?)?.toInt() ?? 0,
      finishOutTotal: (json['FinishOutTotal'] as num?)?.toInt() ?? 0,
      finishPcsRateToday: (json['FinishPcsRateToday'] as num?)?.toInt() ?? 0,
      finishPcsRateTotal: (json['FinishPcsRateTotal'] as num?)?.toInt() ?? 0,
      finishToday: (json['FinishToday'] as num?)?.toInt() ?? 0,
      finishTotal: (json['FinishTotal'] as num?)?.toInt() ?? 0,
      shipMonthPcs: (json['ShipMonthPcs'] as num?)?.toInt() ?? 0,
      shipMonthRate: (json['ShipMonthRate'] as num?)?.toInt() ?? 0,
      shipTodayPcs: (json['ShipTodayPcs'] as num?)?.toInt() ?? 0,
      shipTodayRate: (json['ShipTodayRate'] as num?)?.toInt() ?? 0,
      shipYearPcs: (json['ShipYearPcs'] as num?)?.toInt() ?? 0,
      shipYearRate: (json['ShipYearRate'] as num?)?.toInt() ?? 0,
      stitchInouseToday: (json['StitchInouseToday'] as num?)?.toInt() ?? 0,
      stitchInouseTotal: (json['StitchInouseTotal'] as num?)?.toInt() ?? 0,
      stitchOutToday: (json['StitchOutToday'] as num?)?.toInt() ?? 0,
      stitchOutTotal: (json['StitchOutTotal'] as num?)?.toInt() ?? 0,
      stitchPcsRateToday: (json['StitchPcsRateToday'] as num?)?.toInt() ?? 0,
      stitchPcsRateTotal: (json['StitchPcsRateTotal'] as num?)?.toInt() ?? 0,
      stitchToday: (json['StitchToday'] as num?)?.toInt() ?? 0,
      stitchTotal: (json['StitchTotal'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

class ManpowerDetail {
  final int bareTailorPresent;
  final int bareTailorPresentToday;
  final int empPayroll;
  final int empPresent;
  final int empPresentToday;
  final int femalePresent;
  final int femalePresentToday;
  final int gradeAPlusToday;
  final int gradeAPlusTotal;
  final int gradeAToday;
  final int gradeATotal;
  final int gradeBToday;
  final int gradeBTotal;
  final double mMR;
  final double mMRToday;
  final int malePresent;
  final int malePresentToday;
  final int mispunch;
  final int mispunchToday;
  final int otherTailorPresent;
  final int otherTailorPresentToday;
  final int pcsTailorPayroll;
  final int pcsTailorPayrollToday;
  final int pcsTailorPresent;
  final int pcsTailorPresentToday;
  final int tailorOnPayroll;
  final int tailorOnPayrollToday;
  final int tailorPresent;
  final int tailorPresentToday;
  final String unitShortCode;

  ManpowerDetail({
    required this.bareTailorPresent,
    required this.bareTailorPresentToday,
    required this.empPayroll,
    required this.empPresent,
    required this.empPresentToday,
    required this.femalePresent,
    required this.femalePresentToday,
    required this.gradeAPlusToday,
    required this.gradeAPlusTotal,
    required this.gradeAToday,
    required this.gradeATotal,
    required this.gradeBToday,
    required this.gradeBTotal,
    required this.mMR,
    required this.mMRToday,
    required this.malePresent,
    required this.malePresentToday,
    required this.mispunch,
    required this.mispunchToday,
    required this.otherTailorPresent,
    required this.otherTailorPresentToday,
    required this.pcsTailorPayroll,
    required this.pcsTailorPayrollToday,
    required this.pcsTailorPresent,
    required this.pcsTailorPresentToday,
    required this.tailorOnPayroll,
    required this.tailorOnPayrollToday,
    required this.tailorPresent,
    required this.tailorPresentToday,
    required this.unitShortCode,
  });

  factory ManpowerDetail.fromJson(Map<String, dynamic> json) {
      double toTwoDecimalPlaces(double value) {
        return double.parse(value.toStringAsFixed(2));
      }
    return ManpowerDetail(
      bareTailorPresent: (json['BareTailorPresent'] as num?)?.toInt() ?? 0,
      bareTailorPresentToday: (json['BareTailorPresentToday'] as num?)?.toInt() ?? 0,
      empPayroll: (json['EmpPayroll'] as num?)?.toInt() ?? 0,
      empPresent: (json['EmpPresent'] as num?)?.toInt() ?? 0,
      empPresentToday: (json['EmpPresentToday'] as num?)?.toInt() ?? 0,
      femalePresent: (json['FemalePresent'] as num?)?.toInt() ?? 0,
      femalePresentToday: (json['FemalePresentToday'] as num?)?.toInt() ?? 0,
      gradeAPlusToday: (json['GradeAPlusToday'] as num?)?.toInt() ?? 0,
      gradeAPlusTotal: (json['GradeAPlusTotal'] as num?)?.toInt() ?? 0,
      gradeAToday: (json['GradeAToday'] as num?)?.toInt() ?? 0,
      gradeATotal: (json['GradeATotal'] as num?)?.toInt() ?? 0,
      gradeBToday: (json['GradeBToday'] as num?)?.toInt() ?? 0,
      gradeBTotal: (json['GradeBTotal'] as num?)?.toInt() ?? 0,
      mMR: toTwoDecimalPlaces((json['MMR'] as num?)?.toDouble() ?? 0.0),
      mMRToday: toTwoDecimalPlaces((json['MMRToday'] as num?)?.toDouble() ?? 0.0),
      malePresent: (json['MalePresent'] as num?)?.toInt() ?? 0,
      malePresentToday: (json['MalePresentToday'] as num?)?.toInt() ?? 0,
      mispunch: (json['Mispunch'] as num?)?.toInt() ?? 0,
      mispunchToday: (json['MispunchToday'] as num?)?.toInt() ?? 0,
      otherTailorPresent: (json['OtherTailorPresent'] as num?)?.toInt() ?? 0,
      otherTailorPresentToday: (json['OtherTailorPresentToday'] as num?)?.toInt() ?? 0,
      pcsTailorPayroll: (json['PcsTailorPayroll'] as num?)?.toInt() ?? 0,
      pcsTailorPayrollToday: (json['PcsTailorPayrollToday'] as num?)?.toInt() ?? 0,
      pcsTailorPresent: (json['PcsTailorPresent'] as num?)?.toInt() ?? 0,
      pcsTailorPresentToday: (json['PcsTailorPresentToday'] as num?)?.toInt() ?? 0,
      tailorOnPayroll: (json['TailorOnPayroll'] as num?)?.toInt() ?? 0,
      tailorOnPayrollToday: (json['TailorOnPayrollToday'] as num?)?.toInt() ?? 0,
      tailorPresent: (json['TailorPresent'] as num?)?.toInt() ?? 0,
      tailorPresentToday: (json['TailorPresentToday'] as num?)?.toInt() ?? 0,
      unitShortCode: json['UnitShortCode'] ?? '',
    );
  }
}

class ProfitAndLossData {
  bool isReqdPNL;
  double stitchAvgEff;
  double stitchTodayEff;
  double todayActualPackingOutput;
  double todayCutCost;
  double todayCutOutput;
  double todayCutProfit;
  double todayFinishCost;
  double todayFinishOutput;
  double todayFinishProfit;
  double todayProfit;
  int todayStitchOutput;
  double todayStitchProfit;
  double totalCutPtofit;
  double totalFinishProfit;
  double totalProfit;
  double totalStitchProfit;
  String unitCode;
  String unitShortCode;
  double variance;

  ProfitAndLossData({
    required this.isReqdPNL,
    required this.stitchAvgEff,
    required this.stitchTodayEff,
    required this.todayActualPackingOutput,
    required this.todayCutCost,
    required this.todayCutOutput,
    required this.todayCutProfit,
    required this.todayFinishCost,
    required this.todayFinishOutput,
    required this.todayFinishProfit,
    required this.todayProfit,
    required this.todayStitchOutput,
    required this.todayStitchProfit,
    required this.totalCutPtofit,
    required this.totalFinishProfit,
    required this.totalProfit,
    required this.totalStitchProfit,
    required this.unitCode,
    required this.unitShortCode,
    required this.variance,
  });

  factory ProfitAndLossData.fromJson(Map<String, dynamic> json) {
    return ProfitAndLossData(
      isReqdPNL: json['IsReqdPNL'] ?? false,
      stitchAvgEff: (json['StitchAvgEff'] as num?)?.toDouble() ?? 0.0,
      stitchTodayEff: (json['StitchTodayEff'] as num?)?.toDouble() ?? 0.0,
      todayActualPackingOutput: (json['TodayActualPackingOutput'] as num?)?.toDouble() ?? 0.0,
      todayCutCost: (json['TodayCutCost'] as num?)?.toDouble() ?? 0.0,
      todayCutOutput: (json['TodayCutOutput'] as num?)?.toDouble() ?? 0.0,
      todayCutProfit: (json['TodayCutProfit'] as num?)?.toDouble() ?? 0.0,
      todayFinishCost: (json['TodayFinishCost'] as num?)?.toDouble() ?? 0.0,
      todayFinishOutput: (json['TodayFinishOutput'] as num?)?.toDouble() ?? 0.0,
      todayFinishProfit: (json['TodayFinishProfit'] as num?)?.toDouble() ?? 0.0,
      todayProfit: (json['TodayProfit'] as num?)?.toDouble() ?? 0.0,
      todayStitchOutput: json['TodayStitchOutput'] ?? 0,
      todayStitchProfit: (json['TodayStitchProfit'] as num?)?.toDouble() ?? 0.0,
      totalCutPtofit: (json['TotalCutPtofit'] as num?)?.toDouble() ?? 0.0,
      totalFinishProfit: (json['TotalFinishProfit'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (json['TotalProfit'] as num?)?.toDouble() ?? 0.0,
      totalStitchProfit: (json['TotalStitchProfit'] as num?)?.toDouble() ?? 0.0,
      unitCode: json['UnitCode'] ?? '',
      unitShortCode: json['UnitShortCode'] ?? '',
      variance: (json['Variance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

Future<List<ProductionData>> fetchProdData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=prod&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => ProductionData.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}
Future<List<FinishDetail>> fetchFinishData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=finish&from=''&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => FinishDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}
Future<List<SamProdDetail>> fetchSamData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://172.16.10.11:8000/management?proce_type=sam&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => SamProdDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<OtDetail>> fetchOtData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=ot&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => OtDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}
Future<List<ManpowerDetail>> fetchManpowerData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://172.16.10.11:8000/management?proce_type=manpowerTailor&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => ManpowerDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<AuditDetail>> fetchAuditData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=audit&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);

    return jsonResponse.map((data) => AuditDetail.fromJson(data)).toList();

  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<ProfitAndLossData>> fetchProfitAndLossData(String from, String to, String units) async {
  final response = await http.get(
    Uri.parse('http://14.142.248.34:10008/management?proce_type=pnl&from=$from&to=$to&units=$units'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ProfitAndLossData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}
Future<List<String>> fetchUnits() async {
  final response = await http.get(Uri.parse('http://14.142.248.34:10008/unit?type=pnl&user'));
  if (response.statusCode == 200) {
    final List<dynamic> unitsJson = json.decode(response.body);
    final List<String> units = unitsJson.map((unit) => unit['UnitCode'].toString()).toList();
    print(units);
    return units;
  } else {
    throw Exception('Failed to load units from API');
  }
}

class ProfitAndLossTable extends StatelessWidget {
  final List<ProfitAndLossData> data;

  ProfitAndLossTable({required this.data});

  late int lent = 0;
  Map<String, double> calculateTotals() {
    double stitchAvgEffTotal = 0.0;
    double stitchTodayEffTotal = 0.0;
    double todayCutCostTotal = 0.0;
    double todayCutOutputTotal = 0.0;
    double todayCutProfitTotal = 0.0;
    double todayFinishCostTotal = 0.0;
    double todayFinishOutputTotal = 0.0;
    double todayFinishProfitTotal = 0.0;
    double todayProfitTotal = 0.0;
    double todayStitchOutputTotal = 0.0;
    double todayStitchProfitTotal = 0.0;
    double totalCutProfitTotal = 0.0;
    double totalFinishProfitTotal = 0.0;
    double totalProfitTotal = 0.0;
    double totalStitchProfitTotal = 0.0;
    double variance = 0.0;
    double todaysPack = 0.0;
    double avrTodsam = 0.0;
    double avreff = 0.0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      stitchAvgEffTotal += item.stitchAvgEff;
      stitchTodayEffTotal += item.stitchTodayEff;
      todayCutCostTotal += item.todayCutCost;
      todayCutOutputTotal += item.todayCutOutput;
      todayCutProfitTotal += item.todayCutProfit;
      todayFinishCostTotal += item.todayFinishCost;
      todayFinishOutputTotal += item.todayFinishOutput;
      todayFinishProfitTotal += item.todayFinishProfit;
      todayProfitTotal += item.todayProfit;
      todayStitchOutputTotal += item.todayStitchOutput;
      todayStitchProfitTotal += item.todayStitchProfit;
      totalCutProfitTotal += item.totalCutPtofit;
      totalFinishProfitTotal += item.totalFinishProfit;
      totalProfitTotal += item.totalProfit;
      totalStitchProfitTotal += item.totalStitchProfit;
      variance += item.variance;
      todaysPack += item.todayActualPackingOutput;
      if(item.stitchAvgEff != 0){
        lent = lent +1;
        print(lent);
      }
      // Add more sums for other properties
    }
    avrTodsam = stitchTodayEffTotal/lent;
    avreff = stitchAvgEffTotal/lent;

    // Return a map with property names as keys and sums as values
    return {
      'todayCutOutput': double.parse(todayCutOutputTotal.toStringAsFixed(2)),
      'todayCutProfit': double.parse(todayCutProfitTotal.toStringAsFixed(2)),
      'totalCutProfit': double.parse(totalCutProfitTotal.toStringAsFixed(2)),
      'todayCutCost': double.parse(todayCutCostTotal.toStringAsFixed(2)),
      'todayStitchOutput': double.parse(todayStitchOutputTotal.toStringAsFixed(2)),
      'todayStitchProfit': double.parse(todayStitchProfitTotal.toStringAsFixed(2)),
      'totalStitchProfit': double.parse(totalStitchProfitTotal.toStringAsFixed(2)),
      'stitchAvgEff': double.parse(avrTodsam.toStringAsFixed(2)),
      'stitchTodayEff': double.parse(avreff.toStringAsFixed(2)),
      'todayFinishOutput': double.parse(todayFinishOutputTotal.toStringAsFixed(2)),
      'todayFinishProfit': double.parse(todayFinishProfitTotal.toStringAsFixed(2)),
      'totalFinishProfit': double.parse(totalFinishProfitTotal.toStringAsFixed(2)),
      'todayFinishCost': double.parse(todayFinishCostTotal.toStringAsFixed(2)),
      'todayProfit': double.parse(todayProfitTotal.toStringAsFixed(2)),
      'totalProfit': double.parse(totalProfitTotal.toStringAsFixed(2)),
      'variance' : double.parse(variance.toStringAsFixed(2)),
      'todayPack' : double.parse(todaysPack.toStringAsFixed(2)),
      // Add more sums for other properties
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, double> totals = calculateTotals();
    Widget buildCell(double value, {bool isTotal = false}) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          value.toString(),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: value < 0 ? Colors.red : Colors.green,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    return SingleChildScrollView(


      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('')),
              ),
              Container(
                width: 359.5,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Cutting' , style: TextStyle(
                  fontWeight: FontWeight.bold,

                  color: Colors.white
                ),)),
              ),
              Container(
                width: 480,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('Stitching',style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 360,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Finishing',style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 180,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Finishing vs Packing',style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 200,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                    right: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Overlall',style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 40.5,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('\nUnit',style: TextStyle(
                      color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitShortCode)),
                    );
                  }).toList(),
                  Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                  border: Border(
                  left: BorderSide(color: Colors.black45),
                  bottom: BorderSide(color: Colors.black45),
                  ),
                  ),
                  child: Center(child: Text('Total',style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder.all(color: Colors.black45),
                    columnWidths: const{
                      0: FixedColumnWidth(100.0),
                      1: FixedColumnWidth(100.0),
                      2: FixedColumnWidth(100.0),
                      3: FixedColumnWidth(60.0),
                      4: FixedColumnWidth(100.0),
                      5: FixedColumnWidth(100.0),
                      6: FixedColumnWidth(100.0),
                      7: FixedColumnWidth(100.0),
                      8: FixedColumnWidth(80.0),
                      9: FixedColumnWidth(100.0),
                      10: FixedColumnWidth(100.0),
                      11: FixedColumnWidth(100.0),
                      12: FixedColumnWidth(60.0),
                      13: FixedColumnWidth(90.0),
                      14: FixedColumnWidth(90.0),
                      15: FixedColumnWidth(100.0),
                      16: FixedColumnWidth(100.0),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                        children: [
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's \nOutput",
                                textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's\nP&L",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Total \nP&L',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Cost/Qty',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's \nOutput",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's\nP&L",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Total \nP&L',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's \nEff(%)",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Avg \nEff(%)',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's \nOutput",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's\nP&L",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Total \nP&L',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Cost/Qty',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's Pack\nOutput",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Variance",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                "Today's\nP&L",
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Total \nP&L',
                                textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var item in data)
                        TableRow(
                          children: [
                            TableCell(child:Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayCutOutput.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.todayCutProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.totalCutPtofit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayCutCost.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayStitchOutput.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.todayStitchProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.totalStitchProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchTodayEff.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchAvgEff.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayFinishOutput.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.todayFinishProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.totalFinishProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayFinishCost.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.todayActualPackingOutput.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.variance.toString(),textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.todayProfit),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: buildCell(item.totalProfit),
                            )),
                          ],
                        ),
                      TableRow(
                        children: [
                          TableCell(child:Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['todayCutOutput'].toString(),textAlign: TextAlign.end,style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['todayCutProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['totalCutProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text('',textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['todayStitchOutput'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['todayStitchProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['totalStitchProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchAvgEff'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchTodayEff'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['todayFinishOutput'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['todayFinishProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['totalFinishProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text('',textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['todayPack'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['variance'].toString(),textAlign: TextAlign.end,style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['todayProfit']!,isTotal: true),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: buildCell(totals['totalProfit']!,isTotal: true),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuditTable extends StatelessWidget {
  final List<AuditDetail> data;

  AuditTable({required this.data});

  late int lent = 0;
  Map<String, int> calculateTotals() {
    int exFailFTD = 0;
    int exFailMTD = 0;
    int exFailYTD = 0;
    int exPassFTD = 0;
    int exPassMTD = 0;
    int exPassYTD = 0;
    int finishAuditToday = 0;
    int finishAuditTotal = 0;
    int inspectionToday = 0;
    int inspectionTotal = 0;
    int stitchAuditToday = 0;
    int stitchAuditTotal = 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      exFailFTD += item.exFailFTD;
      exFailMTD += item.exFailMTD;
      exFailYTD += item.exFailYTD;
      exPassFTD += item.exPassFTD;
      exPassMTD += item.exPassMTD;
      exPassYTD += item.exPassYTD;
      finishAuditToday += item.finishAuditToday;
      finishAuditTotal += item.finishAuditTotal;
      inspectionToday += item.inspectionToday;
      inspectionTotal += item.inspectionTotal;
      stitchAuditToday += item.stitchAuditToday;
      stitchAuditTotal += item.stitchAuditTotal;
    }

    // Return a map with property names as keys and sums as values
    return {
      'exFailFTD': exFailFTD,
      'exFailMTD': exFailMTD,
      'exFailYTD': exFailYTD,
      'exPassFTD': exPassFTD,
      'exPassMTD': exPassMTD,
      'exPassYTD': exPassYTD,
      'finishAuditToday': finishAuditToday,
      'finishAuditTotal': finishAuditTotal,
      'inspectionToday': inspectionToday,
      'inspectionTotal': inspectionTotal,
      'stitchAuditToday': stitchAuditToday,
      'stitchAuditTotal': stitchAuditTotal,
      // Add more sums for other properties
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, int> totals = calculateTotals();
    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('')),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Stitching\nAudit' ,textAlign: TextAlign.center, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('Finishing\nAudit',textAlign: TextAlign.center,style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Inspection\nAudit',textAlign: TextAlign.center,style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 360,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('External Audit',textAlign: TextAlign.center,style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 40.5,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('\nUnit',style: TextStyle(
                        color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitShortCode)),
                    );
                  }).toList(),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Total',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45),
                  columnWidths: const{
                    0: FixedColumnWidth(60.0),
                    1: FixedColumnWidth(60.0),
                    2: FixedColumnWidth(60.0),
                    3: FixedColumnWidth(60.0),
                    4: FixedColumnWidth(60.0),
                    5: FixedColumnWidth(60.0),
                    6: FixedColumnWidth(60.0),
                    7: FixedColumnWidth(60.0),
                    8: FixedColumnWidth(60.0),
                    9: FixedColumnWidth(60.0),
                    10: FixedColumnWidth(60.0),
                    11: FixedColumnWidth(60.0),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                      children: [
                        TableCell(
                          child: Center(
                            child: Text(
                              "Today",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Total",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Total',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Today",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Total",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'FTD (Pass)',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "FTD (Fail)",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'MTD (Pass)',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "MTD (Fail)",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "FTD (Pass)",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'FTD (Fail)',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(child:Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchAuditToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchAuditTotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishAuditToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishAuditTotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.inspectionToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.inspectionTotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exPassFTD.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exFailFTD.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exPassMTD.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exFailMTD.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exPassYTD.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.exFailYTD.toString(),textAlign: TextAlign.end),
                          )),
                        ],
                      ),
                    TableRow(
                      children: [
                        TableCell(child:Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchAuditToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchAuditTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishAuditToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishAuditTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['inspectionToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['inspectionTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exPassFTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exFailFTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exPassMTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exFailMTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exPassYTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['exFailYTD'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ManpowerTable extends StatelessWidget {
  final List<ManpowerDetail> data;

  ManpowerTable({required this.data});

  late int mmr = 0;
  late int mmrToday = 0;
  Map<String, dynamic> calculateTotals() {
    int bareTailorPresent = 0;
    int bareTailorPresentToday = 0;
    int empPayroll = 0;
    int empPresent = 0;
    int empPresentToday = 0;
    int femalePresent = 0;
    int femalePresentToday = 0;
    int gradeAPlusToday = 0;
    int gradeAPlusTotal = 0;
    int gradeAToday = 0;
    int gradeATotal = 0;
    int gradeBToday = 0;
    int gradeBTotal = 0;
    double mMR = 0;
    double mMRToday = 0;
    double mMRAvg = 0;
    double mMRTodayAvg = 0;
    int malePresent = 0;
    int malePresentToday = 0;
    int mispunch = 0;
    int mispunchToday = 0;
    int otherTailorPresent = 0;
    int otherTailorPresentToday = 0;
    int pcsTailorPayroll = 0;
    int pcsTailorPayrollToday = 0;
    int pcsTailorPresent = 0;
    int pcsTailorPresentToday = 0;
    int tailorOnPayroll = 0;
    int tailorOnPayrollToday = 0;
    int tailorPresent = 0;
    int tailorPresentToday = 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      bareTailorPresent += item.bareTailorPresent;
      bareTailorPresentToday += item.bareTailorPresentToday;
      empPayroll += item.empPayroll;
      empPresent += item.empPresent;
      empPresentToday += item.empPresentToday;
      femalePresent += item.femalePresent;
      femalePresentToday += item.femalePresentToday;
      gradeAPlusToday += item.gradeAPlusToday;
      gradeAPlusTotal += item.gradeAPlusTotal;
      gradeAToday += item.gradeAToday;
      gradeATotal += item.gradeATotal;
      gradeBToday += item.gradeBToday;
      gradeBTotal += item.gradeBTotal;
      mMR += item.mMR;
      mMRToday += item.mMRToday;
      malePresent += item.malePresent;
      malePresentToday += item.malePresentToday;
      mispunch += item.mispunch;
      mispunchToday += item.mispunchToday;
      otherTailorPresent += item.otherTailorPresent;
      otherTailorPresentToday += item.otherTailorPresentToday;
      pcsTailorPayroll += item.pcsTailorPayroll;
      pcsTailorPayrollToday += item.pcsTailorPayrollToday;
      pcsTailorPresent += item.pcsTailorPresent;
      pcsTailorPresentToday += item.pcsTailorPresentToday;
      tailorOnPayroll += item.tailorOnPayroll;
      tailorOnPayrollToday += item.tailorOnPayrollToday;
      tailorPresent += item.tailorPresent;
      tailorPresentToday += item.tailorPresentToday;
      if(mMR != 0){
        mmr = mmr +1;
      }
      if(mMRToday != 0){
        mmrToday = mmr +1;
      }
    }

    mMRAvg = mMR/mmr;
    mMRTodayAvg = mMRToday/mmrToday;

    // Return a map with property names as keys and sums as values
    return {
      'bareTailorPresent': bareTailorPresent,
      'bareTailorPresentToday': bareTailorPresentToday,
      'empPayroll': empPayroll,
      'empPresent': empPresent,
      'empPresentToday': empPresentToday,
      'femalePresent': femalePresent,
      'femalePresentToday': femalePresentToday,
      'gradeAPlusToday': gradeAPlusToday,
      'gradeAPlusTotal': gradeAPlusTotal,
      'gradeAToday': gradeAToday,
      'gradeATotal': gradeATotal,
      'gradeBToday': gradeBToday,
      'gradeBTotal': gradeBTotal,
      'mMR': double.parse(mMRAvg.toStringAsFixed(2)),
      'mMRToday': double.parse(mMRTodayAvg.toStringAsFixed(2)),
      'malePresent': malePresent,
      'malePresentToday': malePresentToday,
      'mispunch': mispunch,
      'mispunchToday': mispunchToday,
      'otherTailorPresent': otherTailorPresent,
      'otherTailorPresentToday': otherTailorPresentToday,
      'pcsTailorPayroll': pcsTailorPayroll,
      'pcsTailorPayrollToday': pcsTailorPayrollToday,
      'pcsTailorPresent': pcsTailorPresent,
      'pcsTailorPresentToday': pcsTailorPresentToday,
      'tailorOnPayroll': tailorOnPayroll,
      'tailorOnPayrollToday': tailorOnPayrollToday,
      'tailorPresent': tailorPresent,
      'tailorPresentToday': tailorPresentToday,
      // Add more sums for other properties
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> totals = calculateTotals();
    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('')),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Emo\nOnroll' ,textAlign: TextAlign.center, style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Emp\nPresent' ,textAlign: TextAlign.center, style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('Tailor\nOnroll',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor \nOnroll(A+)',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor\nOnroll(A)',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor\nOnroll(B)',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor\nPresent',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor\nPresent(Bare)',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Tailor\nPresent(Other)',textAlign: TextAlign.center,style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('MisPunch',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Male\nPresent',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFAEA8AE2),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Female\nPresent',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Piece Rate\nOnroll',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Piece Rate\nPresent',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('MMR',textAlign: TextAlign.center,style: TextStyle(

                    color: Colors.white
                ),)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20.5,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Unit',style: TextStyle(
                        color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitShortCode)),
                    );
                  }).toList(),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Total',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45),
                  columnWidths: const{
                    0: FixedColumnWidth(60.0),
                    1: FixedColumnWidth(60.0),
                    2: FixedColumnWidth(60.0),
                    3: FixedColumnWidth(60.0),
                    4: FixedColumnWidth(60.0),
                    5: FixedColumnWidth(60.0),
                    6: FixedColumnWidth(60.0),
                    7: FixedColumnWidth(60.0),
                    8: FixedColumnWidth(60.0),
                    9: FixedColumnWidth(60.0),
                    10: FixedColumnWidth(60.0),
                    11: FixedColumnWidth(60.0),
                    12: FixedColumnWidth(60.0),
                    13: FixedColumnWidth(60.0),
                    14: FixedColumnWidth(60.0),
                    15: FixedColumnWidth(60.0),
                    16: FixedColumnWidth(60.0),
                    17: FixedColumnWidth(60.0),
                    18: FixedColumnWidth(60.0),
                    19: FixedColumnWidth(60.0),
                    20: FixedColumnWidth(60.0),
                    21: FixedColumnWidth(60.0),
                    22: FixedColumnWidth(60.0),
                    23: FixedColumnWidth(60.0),
                    24: FixedColumnWidth(60.0),
                    25: FixedColumnWidth(60.0),
                    26: FixedColumnWidth(60.0),
                    27: FixedColumnWidth(60.0),
                    28: FixedColumnWidth(60.0),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                      children: [
                        TableCell(
                          child: Center(
                            child: Text(
                              "",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "To Date",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Today',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(child:Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.bareTailorPresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.bareTailorPresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.empPayroll.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.empPresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.empPresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.femalePresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.femalePresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeAPlusToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeAPlusTotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeAToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeATotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeBToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.gradeBTotal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.mMR.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.mMRToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.malePresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.malePresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.mispunch.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.mispunchToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.otherTailorPresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.otherTailorPresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.pcsTailorPayroll.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.pcsTailorPayrollToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.pcsTailorPresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.pcsTailorPresentToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.tailorOnPayroll.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.tailorOnPayrollToday.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.tailorPresent.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.tailorPresentToday.toString(),textAlign: TextAlign.end),
                          )),
                        ],
                      ),
                    TableRow(
                      children: [
                        TableCell(child:Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['bareTailorPresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['bareTailorPresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['empPayroll'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['empPresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['empPresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['femalePresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['femalePresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeAPlusToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeAPlusTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeAToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeATotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeBToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['gradeBTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['mMR'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['mMRToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['malePresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['malePresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['mispunch'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['mispunchToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['otherTailorPresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['otherTailorPresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['pcsTailorPayroll'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['pcsTailorPayrollToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['pcsTailorPresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['pcsTailorPresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['tailorOnPayroll'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['tailorOnPayrollToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['tailorPresent'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['tailorPresentToday'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProdDataTable extends StatelessWidget {
  final List<ProductionData> data;

  ProdDataTable({required this.data});

  late int lent = 0;

  Map<String, int> calculateTotals() {
    int cuttingToday = 0;
    int cuttingTotal = 0;
    int finishInouseToday = 0;
    int finishInouseTotal = 0;
    int finishOutToday = 0;
    int finishOutTotal = 0;
    int finishPcsRateToday = 0;
    int finishPcsRateTotal = 0;
    int finishToday = 0;
    int finishTotal = 0;
    int shipMonthPcs = 0;
    int shipMonthRate = 0;
    int shipTodayPcs = 0;
    int shipTodayRate = 0;
    int shipYearPcs = 0;
    int shipYearRate = 0;
    int stitchInouseToday = 0;
    int stitchInouseTotal = 0;
    int stitchOutToday = 0;
    int stitchOutTotal = 0;
    int stitchPcsRateToday = 0;
    int stitchPcsRateTotal = 0;
    int stitchToday = 0;
    int stitchTotal = 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      cuttingToday += item.cuttingToday;
      cuttingTotal += item.cuttingTotal;
      finishInouseToday += item.finishInouseToday;
      finishInouseTotal += item.finishInouseTotal;
      finishOutToday += item.finishOutToday;
      finishOutTotal += item.finishOutTotal;
      finishPcsRateToday += item.finishPcsRateToday;
      finishPcsRateTotal += item.finishPcsRateTotal;
      finishToday += item.finishToday;
      finishTotal += item.finishTotal;
      shipMonthPcs += item.shipMonthPcs;
      shipMonthRate += item.shipMonthRate;
      shipTodayPcs += item.shipTodayPcs;
      shipTodayRate += item.shipTodayRate;
      shipYearPcs += item.shipYearPcs;
      shipYearRate += item.shipYearRate;
      stitchInouseToday += item.stitchInouseToday;
      stitchInouseTotal += item.stitchInouseTotal;
      stitchOutToday += item.stitchOutToday;
      stitchOutTotal += item.stitchOutTotal;
      stitchPcsRateToday += item.stitchPcsRateToday;
      stitchPcsRateTotal += item.stitchPcsRateTotal;
      stitchToday += item.stitchToday;
      stitchTotal += item.stitchTotal;
    }


      // Return a map with property names as keys and sums as values
      return {
        'cuttingToday': cuttingToday,
        'cuttingTotal': cuttingTotal,
        'finishInouseToday': finishInouseToday,
        'finishInouseTotal': finishInouseTotal,
        'finishOutToday': finishOutToday,
        'finishOutTotal': finishOutTotal,
        'finishPcsRateToday': finishPcsRateToday,
        'finishPcsRateTotal': finishPcsRateTotal,
        'finishToday': finishToday,
        'finishTotal': finishTotal,
        'shipMonthPcs': shipMonthPcs,
        'shipMonthRate': shipMonthRate,
        'shipTodayPcs': shipTodayPcs,
        'shipTodayRate': shipTodayRate,
        'shipYearPcs': shipYearPcs,
        'shipYearRate': shipYearRate,
        'stitchInouseToday': stitchInouseToday,
        'stitchInouseTotal': stitchInouseTotal,
        'stitchOutToday': stitchOutToday,
        'stitchOutTotal': stitchOutTotal,
        'stitchPcsRateToday': stitchPcsRateToday,
        'stitchPcsRateTotal': stitchPcsRateTotal,
        'stitchToday': stitchToday,
        'stitchTotal': stitchTotal,
        // Add more sums for other properties
      };
    }


    @override
    Widget build(BuildContext context) {
      Map<String, int> totals = calculateTotals();
      return SingleChildScrollView(

        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black54),
                    ),
                  ),
                  child: Center(child: Text('')),
                ),
                Container(
                  width: 160,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('', style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: Colors.white
                  ),)),
                ),
                Container(
                  width: 640,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black54),
                    ),
                  ),
                  child: Center(child: Text('Stitching', style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: Colors.white
                  ),)),
                ),
                Container(
                  width: 640,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Finishing', style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: Colors.white
                  ),)),
                ),
                Container(
                  width: 620,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black54),
                    ),
                  ),
                  child: Center(child: Text('Shipping', style: TextStyle(
                      fontWeight: FontWeight.bold,

                      color: Colors.white
                  ),)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      left: BorderSide(color: Colors.black54),
                    ),
                  ),
                  child: Center(child: Text('')),
                ),
                Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Actual Cutting', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),
                Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Inhouse', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Out House', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Piece Rate', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Net', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Inhouse', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Out House', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Piece Rate', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Net', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 180,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('Today', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 210,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('MTD', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),Container(
                  width: 230,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF08B9AA),
                    border: Border(
                      top: BorderSide(color: Colors.black54),
                      left: BorderSide(color: Colors.black45),
                    ),
                  ),
                  child: Center(child: Text('YTD', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),)),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(0xFF08B9AA),
                        border: Border(
                          top: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                          left: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text('Unit', style: TextStyle(
                          color: Colors.white
                      ),)),
                    ),
                    ...data.map((item) {
                      return Container(
                        width: 100,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black45),
                            bottom: BorderSide(color: Colors.black45),
                          ),
                        ),
                        child: Center(child: Text(item.unitShortCode)),
                      );
                    }).toList(),
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text('Total', style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),)),
                    )
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder.all(color: Colors.black45),
                    columnWidths: const{
                      0: FixedColumnWidth(80.0),
                      1: FixedColumnWidth(80.0),
                      2: FixedColumnWidth(80.0),
                      3: FixedColumnWidth(80.0),
                      4: FixedColumnWidth(80.0),
                      5: FixedColumnWidth(80.0),
                      6: FixedColumnWidth(80.0),
                      7: FixedColumnWidth(80.0),
                      8: FixedColumnWidth(80.0),
                      9: FixedColumnWidth(80.0),
                      10: FixedColumnWidth(80.0),
                      11: FixedColumnWidth(80.0),
                      12: FixedColumnWidth(80.0),
                      13: FixedColumnWidth(80.0),
                      14: FixedColumnWidth(80.0),
                      15: FixedColumnWidth(80.0),
                      16: FixedColumnWidth(80.0),
                      17: FixedColumnWidth(80.0),
                      18: FixedColumnWidth(80.0),
                      19: FixedColumnWidth(100.0),
                      20: FixedColumnWidth(100.0),
                      21: FixedColumnWidth(110.0),
                      22: FixedColumnWidth(110.0),
                      23: FixedColumnWidth(120.0),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                        children: [
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Today", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text("Total", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Amount', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Amount', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                          TableCell(
                            child: Center(
                              child: Text('Amount', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        ],
                      ),
                      for (var item in data)
                        TableRow(
                          children: [
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.cuttingToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.cuttingTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchInouseToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchInouseTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchOutToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchOutTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchPcsRateToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchPcsRateTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.stitchTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishInouseToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishInouseTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishOutToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                  item.finishOutTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishPcsRateToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishPcsRateTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishToday.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.finishTotal.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipTodayPcs.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipTodayRate.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipMonthPcs.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipMonthRate.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipYearPcs.toString(),
                                  textAlign: TextAlign.end),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(item.shipYearRate.toString(),
                                  textAlign: TextAlign.end),
                            )),
                          ],
                        ),
                      TableRow(
                        children: [
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['cuttingToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['cuttingTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchInouseToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchInouseTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchOutToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchOutTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchPcsRateToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchPcsRateTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['stitchTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishInouseToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishInouseTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishOutToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishOutTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishPcsRateToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishPcsRateTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishToday'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['finishTotal'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipTodayPcs'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipTodayRate'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipMonthPcs'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipMonthRate'].toString(),
                              textAlign: TextAlign.end, style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipYearPcs'].toString(), textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(totals['shipYearRate'].toString(), textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

class OtTable extends StatelessWidget {
  final List<OtDetail> data;

  OtTable({required this.data});

  late int lent = 0;

  Map<String, int> calculateTotals() {
    int cuttingOtAmtFTDTotal = 0;
    int cuttingOtAmtMTDTotal = 0;
    int cuttingOthrsFTDTotal = 0;
    int cuttingOthrsMTDTotal = 0;
    int cuttingPerHrFTDTotal = 0;
    int cuttingPerHrMTDTotal = 0;
    int finishOtAmtFTDTotal = 0;
    int finishOtAmtMTDTotal = 0;
    int finishOthrsFTDTotal = 0;
    int finishOthrsMTDTotal = 0;
    int finishPerHrFTDTotal = 0;
    int finishPerHrMTDTotal = 0;
    int stitchOtAmtFTDTotal = 0;
    int stitchOtAmtMTDTotal = 0;
    int stitchOthrsFTDTotal = 0;
    int stitchOthrsMTDTotal = 0;
    int stitchPerHrFTDTotal = 0;
    int stitchPerHrMTDTotal = 0;
    int todayOtAmtFTDTotal = 0;
    int todayOtAmnMTDTotal = 0;
    int todayOthrsFTDTotal = 0;
    int todayOthrsMTDTotal = 0;
    int todayPerHrFTDTotal = 0;
    int todayPerHrMTDTotal = 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      cuttingOtAmtFTDTotal += item.cuttingOtAmtFTD;
      cuttingOtAmtMTDTotal += item.cuttingOtAmtMTD;
      cuttingOthrsFTDTotal += item.cuttingOthrsFTD;
      cuttingOthrsMTDTotal += item.cuttingOthrsMTD;
      cuttingPerHrFTDTotal += item.cuttingPerHrFTD;
      cuttingPerHrMTDTotal += item.cuttingPerHrMTD;
      finishOtAmtFTDTotal += item.finishOtAmtFTD;
      finishOtAmtMTDTotal += item.finishOtAmtMTD;
      finishOthrsFTDTotal += item.finishOthrsFTD;
      finishOthrsMTDTotal += item.finishOthrsMTD;
      finishPerHrFTDTotal += item.finishPerHrFTD;
      finishPerHrMTDTotal += item.finishPerHrMTD;
      stitchOtAmtFTDTotal += item.stitchOtAmtFTD;
      stitchOtAmtMTDTotal += item.stitchOtAmtMTD;
      stitchOthrsFTDTotal += item.stitchOthrsFTD;
      stitchOthrsMTDTotal += item.stitchOthrsMTD;
      stitchPerHrFTDTotal += item.stitchPerHrFTD;
      stitchPerHrMTDTotal += item.stitchPerHrMTD;
      todayOtAmtFTDTotal += item.todayOtAmtFTD;
      todayOtAmnMTDTotal += item.todayOtAmtMTD;
      todayOthrsFTDTotal += item.todayOthrsFTD;
      todayOthrsMTDTotal += item.todayOthrsMTD;
      todayPerHrFTDTotal += item.todayPerHrFTD;
      todayPerHrMTDTotal += item.todayPerHrMTD;
    }


    // Return a map with property names as keys and sums as values
    return {
      'cuttingOtAmtFTDTotal': cuttingOtAmtFTDTotal,
      'cuttingOtAmtMTDTotal': cuttingOtAmtMTDTotal,
      'cuttingOthrsFTDTotal': cuttingOthrsFTDTotal,
      'cuttingOthrsMTDTotal': cuttingOthrsMTDTotal,
      'cuttingPerHrFTDTotal': cuttingPerHrFTDTotal,
      'cuttingPerHrMTDTotal': cuttingPerHrMTDTotal,
      'finishOtAmtFTDTotal': finishOtAmtFTDTotal,
      'finishOtAmtMTDTotal': finishOtAmtMTDTotal,
      'finishOthrsFTDTotal': finishOthrsFTDTotal,
      'finishOthrsMTDTotal': finishOthrsMTDTotal,
      'finishPerHrFTDTotal': finishPerHrFTDTotal,
      'finishPerHrMTDTotal': finishPerHrMTDTotal,
      'stitchOtAmtFTDTotal': stitchOtAmtFTDTotal,
      'stitchOtAmtMTDTotal': stitchOtAmtMTDTotal,
      'stitchOthrsFTDTotal': stitchOthrsFTDTotal,
      'stitchOthrsMTDTotal': stitchOthrsMTDTotal,
      'stitchPerHrFTDTotal': stitchPerHrFTDTotal,
      'stitchPerHrMTDTotal': stitchPerHrMTDTotal,
      'todayOtAmtFTDTotal': todayOtAmtFTDTotal,
      'todayOtAmnMTDTotal': todayOtAmnMTDTotal,
      'todayOthrsFTDTotal': todayOthrsFTDTotal,
      'todayOthrsMTDTotal': todayOthrsMTDTotal,
      'todayPerHrFTDTotal': todayPerHrFTDTotal,
      'todayPerHrMTDTotal': todayPerHrMTDTotal,
      // Add more sums for other properties
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, int> totals = calculateTotals();
    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('')),
              ),
              Container(
                width: 520,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Cutting', style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 520,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('Bare Stitching', style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 520,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Finishing', style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
              Container(
                width: 520,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('Factory', style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Colors.white
                ),)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    left: BorderSide(color: Colors.black54),
                  ),
                ),
                child: Center(child: Text('')),
              ),
              Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black45),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Hours', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),
              Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Value', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Per/HR OT', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Hours', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Value', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Per/HR OT', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Hours', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Value', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Per/HR OT', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Hours', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('OT Value', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(0xFF08B9AA),
                  border: Border(
                    top: BorderSide(color: Colors.black54),
                    left: BorderSide(color: Colors.black45),
                  ),
                ),
                child: Center(child: Text('Per/HR OT', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white
                ),)),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Unit', style: TextStyle(
                        color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitCode)),
                    );
                  }).toList(),
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Total', style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45),
                  columnWidths: const{
                    0: FixedColumnWidth(80.0),
                    1: FixedColumnWidth(80.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                    4: FixedColumnWidth(80.0),
                    5: FixedColumnWidth(80.0),
                    6: FixedColumnWidth(80.0),
                    7: FixedColumnWidth(80.0),
                    8: FixedColumnWidth(100.0),
                    9: FixedColumnWidth(100.0),
                    10: FixedColumnWidth(80.0),
                    11: FixedColumnWidth(80.0),
                    12: FixedColumnWidth(80.0),
                    13: FixedColumnWidth(80.0),
                    14: FixedColumnWidth(100.0),
                    15: FixedColumnWidth(100.0),
                    16: FixedColumnWidth(80.0),
                    17: FixedColumnWidth(80.0),
                    18: FixedColumnWidth(80.0),
                    19: FixedColumnWidth(80.0),
                    20: FixedColumnWidth(100.0),
                    21: FixedColumnWidth(100.0),
                    22: FixedColumnWidth(80.0),
                    23: FixedColumnWidth(80.0),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                      children: [
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("FTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text("MTD", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('FTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('MTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('FTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('MTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('FTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                        TableCell(
                          child: Center(
                            child: Text('MTD', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),),),
                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingOthrsFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingOthrsMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingOtAmtFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingOtAmtMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingPerHrFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.cuttingPerHrMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchOthrsFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                                item.stitchOthrsMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchOtAmtFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchOtAmtMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchPerHrFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchPerHrMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishOthrsFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishOthrsMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishOtAmtFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishOtAmtMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishPerHrFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishPerHrMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayOthrsFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayOthrsMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayOtAmtFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayOtAmtMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayPerHrFTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.todayPerHrMTD.toString(),
                                textAlign: TextAlign.end),
                          )),
                        ],
                      ),
                    TableRow(
                      children: [
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingOthrsFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingOthrsMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingOtAmtFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingOtAmtMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingPerHrFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['cuttingPerHrMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOthrsFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOthrsMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOtAmtFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOtAmtMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchPerHrFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchPerHrMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishOthrsFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishOthrsMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishOtAmtFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishOtAmtMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishPerHrFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishPerHrMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayOthrsFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayOthrsMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayOtAmtFTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayOtAmnMTDTotal'].toString(),
                            textAlign: TextAlign.end, style: TextStyle(
                                fontWeight: FontWeight.bold
                            ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayPerHrFTDTotal'].toString(), textAlign: TextAlign.end, style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayPerHrMTDTotal'].toString(), textAlign: TextAlign.end, style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinishTable extends StatelessWidget {
  final List<FinishDetail> data;

  FinishTable({required this.data});

  late int lent = 0;
  Map<String, int> calculateTotals() {
    int askingRate = 0;
    int balToPack = 0;
    int balToPackVal = 0;
    int balToSam = 0;
    int checker = 0;
    int finishQty = 0;
    int pressMan = 0;
    int prodSamProduced = 0;
    int stitchQty = 0;
    int totalMnpwr = 0;
    int wip = 0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      askingRate += item.askingRate;
      balToPack += item.balToPack;
      balToPackVal += item.balToPackVal;
      balToSam += item.balToSam;
      checker += item.checker;
      finishQty += item.finishQty;
      pressMan += item.pressMan;
      prodSamProduced += item.prodSamProduced;
      stitchQty += item.stitchQty;
      totalMnpwr += item.totalMnpwr;
      wip += item.wip;
    }
    // Return a map with property names as keys and sums as values
    return {
      'askingRate': askingRate,
      'balToPack': balToPack,
      'balToPackVal': balToPackVal,
      'balToSam': balToSam,
      'checker': checker,
      'finishQty': finishQty,
      'pressMan': pressMan,
      'prodSamProduced': prodSamProduced,
      'stitchQty': stitchQty,
      'totalMnpwr': totalMnpwr,
      'wip': wip,
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, int> totals = calculateTotals();
    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 40.5,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('\nUnit',style: TextStyle(
                        color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitShortCode)),
                    );
                  }).toList(),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Total',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45),
                  columnWidths: const{
                    0: FixedColumnWidth(100.0),
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                    4: FixedColumnWidth(100.0),
                    5: FixedColumnWidth(100.0),
                    6: FixedColumnWidth(100.0),
                    7: FixedColumnWidth(120.0),
                    8: FixedColumnWidth(100.0),
                    9: FixedColumnWidth(100.0),
                    10: FixedColumnWidth(100.0),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                      children: [
                        TableCell(
                          child: Center(
                            child: Text(
                              "Yesterday \nStitching",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "SAM's\nProduced",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Balance \nTo SAM',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Yeasterday\nPacking',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "\nWTD",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Asking\nRate",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Balance \nTo Pack',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Balance To Pack \nGoods Value",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Today's \nChecker",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Today's \nPressman",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),TableCell(
                          child: Center(
                            child: Text(
                              "Today's \nManpower",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(child:Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.stitchQty.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.prodSamProduced.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.balToSam.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.finishQty.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.wip.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.askingRate.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.balToPack.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.balToPackVal.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.checker.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.pressMan.toString(),textAlign: TextAlign.end),
                          )),
                          TableCell(child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(item.totalMnpwr.toString(),textAlign: TextAlign.end),
                          )),
                        ],
                      ),
                    TableRow(
                      children: [
                        TableCell(child:Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchQty'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['prodSamProduced'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['balToSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['finishQty'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['wip'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['askingRate'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['balToPack'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['balToPackVal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['checker'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['pressMan'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['totalMnpwr'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SamTable extends StatelessWidget {
  final List<SamProdDetail> data;

  SamTable({required this.data});

  late int avgNum = 0;
  late int todayNum = 0;
  late int totalNum = 0;
  Map<String, dynamic> calculateTotals() {
    double avgSam = 0.0;
    double avgAvgSam = 0.0;
    int stitchInHouseSam = 0;
    int stitchInHouseTotal = 0;
    int stitchOutSam = 0;
    int stitchOutTotal = 0;
    int stitchPcsrateSam = 0;
    int stitchPcsrateTotal = 0;
    int stitchSam = 0;
    int stitchTotal = 0;
    double todayCost = 0;
    double avrTodayCost = 0.0;
    double avrTotalCost = 0.0;
    double totalCost = 0.0;

    // Add more variables for other properties

    // Iterate over the list of data and sum up the values
    for (var item in data) {
      avgSam += item.avgSam;
      stitchInHouseSam += item.stitchInHouseSam;
      stitchInHouseTotal += item.stitchInHouseTotal;
      stitchOutSam += item.stitchOutSam;
      stitchOutTotal += item.stitchOutTotal;
      stitchPcsrateSam += item.stitchPcsrateSam;
      stitchPcsrateTotal += item.stitchPcsrateTotal;
      stitchSam += item.stitchSam;
      stitchTotal += item.stitchTotal;
      todayCost += item.todayCost;
      totalCost += item.totalCost;
      if(item.avgSam != 0){
        avgNum = avgNum +1;
        print(avgNum);
      }
      if(item.todayCost != 0){
        todayNum = todayNum + 1;
      }
      if(item.totalCost != 0){
        totalNum = totalNum + 1;
      }
    }
    avgAvgSam = avgSam/avgNum;
    avrTodayCost = todayCost/todayNum;
    avrTotalCost = totalCost/totalNum;
    // Return a map with property names as keys and sums as values
    return {
      'avgSam': double.parse(avgAvgSam.toStringAsFixed(2)),
      'stitchInHouseSam': stitchInHouseSam,
      'stitchInHouseTotal': stitchInHouseTotal,
      'stitchOutSam': stitchOutSam,
      'stitchOutTotal': stitchOutTotal,
      'stitchPcsrateSam': stitchPcsrateSam,
      'stitchPcsrateTotal': stitchPcsrateTotal,
      'stitchSam': stitchSam,
      'stitchTotal': stitchTotal,
      'todayCost': double.parse(avrTodayCost.toStringAsFixed(2)),
      'totalCost': double.parse(avrTotalCost.toStringAsFixed(2)),
    };
  }


  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> totals = calculateTotals();
    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 40.5,
                    decoration: BoxDecoration(
                      color: Color(0xFF08B9AA),
                      border: Border(
                        top: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                        left: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('\nUnit',style: TextStyle(
                        color: Colors.white
                    ),)),
                  ),
                  ...data.map((item) {
                    return Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black45),
                          bottom: BorderSide(color: Colors.black45),
                        ),
                      ),
                      child: Center(child: Text(item.unitShortCode)),
                    );
                  }).toList(),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black45),
                        bottom: BorderSide(color: Colors.black45),
                      ),
                    ),
                    child: Center(child: Text('Total',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)),
                  )
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder.all(color: Colors.black45),
                  columnWidths: const{
                    0: FixedColumnWidth(100.0),
                    1: FixedColumnWidth(100.0),
                    2: FixedColumnWidth(100.0),
                    3: FixedColumnWidth(100.0),
                    4: FixedColumnWidth(100.0),
                    5: FixedColumnWidth(100.0),
                    6: FixedColumnWidth(100.0),
                    7: FixedColumnWidth(120.0),
                    8: FixedColumnWidth(100.0),
                    9: FixedColumnWidth(100.0),
                    10: FixedColumnWidth(100.0),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF08B9AA)),
                      children: [
                        TableCell(
                          child: Center(
                            child: Text(
                              "In House \nQty",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "In House\nSam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Out House \nQty',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Out House\nSam',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Piece Rate\nQty",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Piece Rate\nSam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              'Total \nQty',
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Total \nSam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "AVG \nSam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Center(
                            child: Text(
                              "Today's \nCost/Sam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),TableCell(
                          child: Center(
                            child: Text(
                              "Total \nCost/Sam",
                              textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var item in data)
                      TableRow(
                        children: [
                          TableCell(child: Padding(
                            child: Text(item.stitchInHouseTotal.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchInHouseSam.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchOutTotal.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchOutSam.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchPcsrateTotal.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchPcsrateSam.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchTotal.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.stitchSam.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child:Padding(
                            child: Text(item.avgSam.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.todayCost.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                          TableCell(child: Padding(
                            child: Text(item.totalCost.toString(),textAlign: TextAlign.end),
                            padding: const EdgeInsets.only(right: 4),
                          )),
                        ],
                      ),
                    TableRow(
                      children: [
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchInHouseTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchInHouseSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOutTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchOutSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchPcsrateTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchPcsrateSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchTotal'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['stitchSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child:Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['avgSam'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                        TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['todayCost'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),TableCell(child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(totals['totalCost'].toString(),textAlign: TextAlign.end,style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfitAndLossScreen extends StatefulWidget {
  final String fromDate;
  final String toDate;

  ProfitAndLossScreen({required this.fromDate, required this.toDate});

  @override
  _ProfitAndLossScreenState createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  bool _isProfitAndLossExpanded = false;
  bool _isProductionExpanded = false;
  bool _isOtExpanded = false;
  bool _isFinishExpanded = false;
  bool _isAuditExpanded = false;
  bool _isSamExpanded = false;
  bool _isManpowerExpanded = false;
  Future<List<ProfitAndLossData>>? futureData;
  Future<List<ProductionData>>? prodData;
  Future<List<OtDetail>>? otData;
  Future<List<FinishDetail>>? finishData;
  Future<List<AuditDetail>>? auditData;
  Future<List<SamProdDetail>>? samData;
  Future<List<ManpowerDetail>>? manpowerData;
  late Future<List<String>> futureUnits;

  @override
  void initState() {
    super.initState();
    futureUnits = fetchUnits();
    futureUnits.then((units) {
      print('Units: $units');
    }).catchError((error) {
      print('Error fetching units: $error');
    });
  }

  void _loadProfitAndLossData() {
    if (futureData == null) {
      futureUnits.then((units) {
        final unitsString = units.join(',');
        final fromDate = widget.fromDate;
        final toDate = widget.toDate;
        setState(() {
          futureData = fetchProfitAndLossData(fromDate, toDate, unitsString);
        });
      }).catchError((error) {
        print('Error fetching units: $error');
      });
    }
  }

  void _loadProductionData() {
    if (prodData == null) {
      futureUnits.then((units) {
        final unitsString = units.join(',');
        final fromDate = widget.fromDate;
        final toDate = widget.toDate;
        setState(() {
          prodData = fetchProdData(fromDate, toDate, unitsString);
        });
      }).catchError((error) {
        print('Error fetching units: $error');
      });
    }
  }

  void _loadOtData() {
      if (otData == null) {
        futureUnits.then((units) {
          final unitsString = units.join(',');
          final fromDate = widget.fromDate;
          final toDate = widget.toDate;
          setState(() {
            otData = fetchOtData(fromDate, toDate, unitsString);
          });
        }).catchError((error) {
          print('Error fetching units: $error');
        });
      }
    }

  void _loadFinishData() {
      if (finishData == null) {
        futureUnits.then((units) {
          final unitsString = units.join(',');
          final fromDate = widget.fromDate;
          final toDate = widget.toDate;
          setState(() {
            finishData = fetchFinishData(fromDate, toDate, unitsString);
          });
        }).catchError((error) {
          print('Error fetching units: $error');
        });
      }
    }

  void _loadSamData() {
      if (samData == null) {
        futureUnits.then((units) {
          final unitsString = units.join(',');
          final fromDate = widget.fromDate;
          final toDate = widget.toDate;
          setState(() {
            samData = fetchSamData(fromDate, toDate, unitsString);
          });
        }).catchError((error) {
          print('Error fetching units: $error');
        });
      }
    }

  void _loadAuditData() {
      if (auditData == null) {
        futureUnits.then((units) {
          final unitsString = units.join(',');
          final fromDate = widget.fromDate;
          final toDate = widget.toDate;
          setState(() {
            auditData = fetchAuditData(fromDate, toDate, unitsString);
          });
        }).catchError((error) {
          print('Error fetching units: $error');
        });
      }
    }
    void _loadManpowerData() {
      if (auditData == null) {
        futureUnits.then((units) {
          final unitsString = units.join(',');
          final fromDate = widget.fromDate;
          final toDate = widget.toDate;
          setState(() {
            manpowerData = fetchManpowerData(fromDate, toDate, unitsString);
          });
        }).catchError((error) {
          print('Error fetching units: $error');
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5FE3D3),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Management Review',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isProfitAndLossExpanded = !_isProfitAndLossExpanded;
                _isProductionExpanded = false;
                _isOtExpanded = false;
                _isFinishExpanded = false;
                _isAuditExpanded = false;
                _isSamExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isProfitAndLossExpanded) {
                _loadProfitAndLossData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Profit & Loss',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isProfitAndLossExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isProfitAndLossExpanded
              ? FutureBuilder<List<ProfitAndLossData>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return ProfitAndLossTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isProductionExpanded = !_isProductionExpanded;
                _isProfitAndLossExpanded = false;
                _isOtExpanded = false;
                _isFinishExpanded = false;
                _isAuditExpanded = false;
                _isSamExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isProductionExpanded) {
                _loadProductionData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child:  Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Production Detail',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isProductionExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isProductionExpanded
              ? FutureBuilder<List<ProductionData>>(
            future: prodData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return ProdDataTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isOtExpanded = !_isOtExpanded;
                _isProfitAndLossExpanded = false;
                _isProductionExpanded = false;
                _isFinishExpanded = false;
                _isAuditExpanded = false;
                _isSamExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isOtExpanded) {
                _loadOtData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('OT Detail',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isOtExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isOtExpanded
              ? FutureBuilder<List<OtDetail>>(
            future: otData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return OtTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFinishExpanded = !_isFinishExpanded;
                _isProfitAndLossExpanded = false;
                _isProductionExpanded = false;
                _isOtExpanded = false;
                _isAuditExpanded = false;
                _isSamExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isFinishExpanded) {
                _loadFinishData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Finishing Asking Detail',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isFinishExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isFinishExpanded
              ? FutureBuilder<List<FinishDetail>>(
            future: finishData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return FinishTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isAuditExpanded = !_isAuditExpanded;
                _isProfitAndLossExpanded = false;
                _isProductionExpanded = false;
                _isOtExpanded = false;
                _isFinishExpanded = false;
                _isSamExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isAuditExpanded) {
                _loadAuditData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Audit (Fail %)',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isAuditExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isAuditExpanded
              ? FutureBuilder<List<AuditDetail>>(
            future: auditData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return AuditTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSamExpanded = !_isSamExpanded;
                _isProfitAndLossExpanded = false;
                _isProductionExpanded = false;
                _isOtExpanded = false;
                _isFinishExpanded = false;
                _isAuditExpanded = false;
                _isManpowerExpanded = false;
              });
              if (_isSamExpanded) {
                _loadSamData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text('Sam Produced',
                              style: TextStyle(color: Colors.black)))),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isSamExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isSamExpanded
              ? FutureBuilder<List<SamProdDetail>>(
            future: samData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return SamTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
          GestureDetector(
            onTap: () {
              setState(() {
                _isManpowerExpanded = !_isManpowerExpanded;
                _isProfitAndLossExpanded = false;
                _isProductionExpanded = false;
                _isOtExpanded = false;
                _isFinishExpanded = false;
                _isAuditExpanded = false;
                _isSamExpanded = false;
              });
              if (_isManpowerExpanded) {
                _loadManpowerData();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border(bottom: BorderSide(color: Colors.black45))),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Manpower Table',
                                style: TextStyle(color: Colors.black)),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, top: 2.0, bottom: 2.0),
                    child: Icon(
                        _isManpowerExpanded
                            ? Icons.arrow_drop_down_circle_outlined
                            : Icons.play_arrow_rounded,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          _isManpowerExpanded
              ? FutureBuilder<List<ManpowerDetail>>(
            future: manpowerData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              } else {
                return ManpowerTable(data: snapshot.data!);
              }
            },
          )
              : SizedBox(),
        ],
      ),
    );
  }
}
