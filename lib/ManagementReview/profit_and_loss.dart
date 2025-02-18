import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ppms/DashboardTable/additional_loss_table.dart';
import 'package:ppms/DashboardTable/att_manpower_staff.dart';
import 'package:ppms/DashboardTable/att_manpower_tailor.dart';
import 'package:ppms/DashboardTable/audit_data.dart';
import 'package:ppms/DashboardTable/audit_vs_actual.dart';
import 'package:ppms/DashboardTable/category_2_style.dart';
import 'package:ppms/DashboardTable/cut_to_ship.dart';
import 'package:ppms/DashboardTable/embroidery_table.dart';
import 'package:ppms/DashboardTable/energy_cost.dart';
import 'package:ppms/DashboardTable/factory_finish.dart';
import 'package:ppms/DashboardTable/finishing_asking_detail.dart';
import 'package:ppms/DashboardTable/ot_detail.dart';
import 'package:ppms/DashboardTable/prod_detail.dart';
import 'package:ppms/DashboardTable/prod_tna.dart';
import 'package:ppms/DashboardTable/profit_n_loss.dart';
import 'package:ppms/DashboardTable/sam_prod.dart';
import 'package:ppms/DashboardTable/sam_revision_table.dart';
import 'package:ppms/DashboardTable/on_time_delivery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DashboardTable/category_3_style.dart';
import '../DashboardTable/man_power.dart';

class ProfitAndLossScreen extends StatefulWidget {
  final String fromDate;
  final String toDate;

  ProfitAndLossScreen({required this.fromDate, required this.toDate});

  @override
  _ProfitAndLossScreenState createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> {
  String? _loginId;
  bool _isProfitAndLossExpanded = false;
  bool _isProductionExpanded = false;
  bool _isEmbroideryExpanded = false;
  bool _isOtExpanded = false;
  bool _isFinishExpanded = false;
  bool _isAuditExpanded = false;
  bool _isCutExpanded = false;
  bool _isSamExpanded = false;
  bool _isRevisionExpanded = false;
  bool _isManpowerExpanded = false;
  bool _isManpowerTailorExpanded = false;
  bool _isManpowerStaffExpanded = false;
  bool _isAuditVsExpanded = false;
  bool _isEnergyExpanded = false;
  bool _isFinishTurnExpanded = false;
  bool _isOnTimeExpanded = false;
  bool _isCatExpanded = false;
  bool _isCat3Expanded = false;
  bool _isProdTnaExpanded = false;
  bool _isAdditionalLossExpanded = false;
  late Future<List<String>> futureUnits;
  List<String> visibleSections = [];
  String unit = '';


  void _loadVisibleSections() async {
    final response = await http.get(Uri.parse('http://14.142.248.34:10008/special?user=$_loginId&module=dashboard&page=managementreview'));
    if (kDebugMode) {
      print('http://14.142.248.34:10008/special?user=$_loginId&module=dashboard&page=managementreview');
    }
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        visibleSections = data.map((item) => item['name'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLoginIdAndFetchData();
    Future.delayed(const Duration(milliseconds: 200), () {
      _loadVisibleSections();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
          futureUnits = fetchUnits();
          futureUnits.then((units) {
            unit = units.join(',');
            if (kDebugMode) {
              print('Units: $units');
              print('Units: $unit');
            }

          }).catchError((error) {
            if (kDebugMode) {
              print('Error fetching units: $error');
            }
          });
    });

  }

  Future<void> _loadLoginIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    if (_loginId != null) {
      await fetchUnits();
    }
  }
  Future<List<String>> fetchUnits() async {
    final response = await http.get(Uri.parse('http://14.142.248.34:10008/unit?type=pnl2&user=$_loginId'));
    if (kDebugMode) {
      print('http://14.142.248.34:10008/unit?type=pnl2&user=$_loginId');
    }
    // final response = await http.get(Uri.parse('http://172.16.10.11:8000/unit?type=pnl2&user=$_loginId'));
    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> units = unitsJson.map((unit) => unit['UnitCode'].toString()).toList();
      if (kDebugMode) {
        print(units);
      }
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }


  // Future<List<String>> fetchSpecial() async {
  //   // final response = await http.get(Uri.parse('http://14.142.248.34:10008/unit?type=pnl2&user=$_loginId'));
  //   final response = await http.get(Uri.parse('http://172.16.10.11:8000/special?user=$_loginId&module=dashboard&page=managementreview'));
  //   if (response.statusCode == 200) {
  //   } else {
  //     throw Exception('Failed to load units from API');
  //   }
  // }


  void _resetAllExcept(String section) {
    if (section != 'profitAndLoss') _isProfitAndLossExpanded = false;
    if (section != 'production') _isProductionExpanded = false;
    if (section != 'embroidery') _isEmbroideryExpanded = false;
    if (section != 'ot') _isOtExpanded = false;
    if (section != 'finish') _isFinishExpanded = false;
    if (section != 'audit') _isAuditExpanded = false;
    if (section != 'cutToShip') _isCutExpanded = false;
    if (section != 'sam') _isSamExpanded = false;
    if (section != 'samR') _isRevisionExpanded = false;
    if (section != 'manpower') _isManpowerExpanded = false;
    if (section != 'manpowerTailor') _isManpowerTailorExpanded = false;
    if (section != 'manpowerStaff') _isManpowerStaffExpanded = false;
    if (section != 'auditVs') _isAuditVsExpanded = false;
    if (section != 'energy') _isEnergyExpanded = false;
    if (section != 'finishTurn') _isFinishTurnExpanded = false;
    if (section != 'onTime') _isOnTimeExpanded = false;
    if (section != 'Cat') _isCatExpanded = false;
    if (section != 'Cat3') _isCat3Expanded = false;
    if (section != 'prodTna') _isProdTnaExpanded = false;
    if (section != 'additional') _isAdditionalLossExpanded = false;
  }


  Widget _buildSection1({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget pageContent,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              color: color,
              border: const Border(bottom: BorderSide(color: Colors.black45)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(title, style: const TextStyle(color: Colors.black)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 16.0, top: 2.0, bottom: 2.0),
                  child: Icon(
                    isExpanded ? Icons.arrow_drop_down_circle_outlined : Icons.play_arrow_rounded,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        isExpanded ? pageContent : const SizedBox(), // Show the page content if expanded
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5FE3D3),
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
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        panAxis: PanAxis.free,
        minScale: 1.0,
        maxScale: 4.0,
        child: SizedBox(height: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                if (visibleSections.contains('ProfitNLosss'))
                  _buildSection1(
                    title: 'Profit & Loss',
                    isExpanded: _isProfitAndLossExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('profitAndLoss');
                        _isProfitAndLossExpanded = !_isProfitAndLossExpanded;
                      });
                    },
                    pageContent: PnLDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('ProductionDtl'))
                  _buildSection1(
                    title: 'Production Detail',
                    isExpanded: _isProductionExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('production');
                        _isProductionExpanded = !_isProductionExpanded;
                      });
                    },
                    pageContent: ProductionDataTable(from: widget.fromDate, to: widget.toDate, units: unit)
                  ),
                if(visibleSections.contains('Embroidery'))
                  _buildSection1(title: 'Embroidery', 
                      isExpanded: _isEmbroideryExpanded,
                      onTap: (){
                        setState(() {
                          _resetAllExcept('embroidery');
                          _isEmbroideryExpanded = !_isEmbroideryExpanded;
                        });
                      }, 
                      pageContent: EmbroideryDetailTable(from: widget.fromDate, to: widget.toDate, units: unit),
                      color: Colors.black12
                  ),
                if (visibleSections.contains('OtDetails'))
                  _buildSection1(
                    title: 'OT Detail',
                    isExpanded: _isOtExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('ot');
                        _isOtExpanded = !_isOtExpanded;
                      });
                    },
                    pageContent: OTDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('FinishAskingDtl'))
                  _buildSection1(
                    title: 'Finishing Asking Detail',
                    isExpanded: _isFinishExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('finish');
                        _isFinishExpanded = !_isFinishExpanded;
                      });
                    },
                    pageContent: FinishingDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('AuditData'))
                  _buildSection1(
                    title: 'Audit Data(Fail %)',
                    isExpanded: _isAuditExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('audit');
                        _isAuditExpanded = !_isAuditExpanded;
                      });
                    },
                    pageContent: AuditDetailTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('CutToShip'))
                  _buildSection1(
                    title: 'Cut To Ship(%)',
                    isExpanded: _isCutExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('cutToShip');
                        _isCutExpanded = !_isCutExpanded;
                      });
                    }, pageContent: CutShipTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('SamProduced'))
                  _buildSection1(
                    title: 'Sam Produced',
                    isExpanded: _isSamExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('sam');
                        _isSamExpanded = !_isSamExpanded;
                      });
                    }, pageContent: SamProdTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if(visibleSections.contains('SamRevisionDtl'))
                  _buildSection1(title: 'Sam Revision Detail',
                      isExpanded: _isRevisionExpanded,
                      onTap: (){
                        setState(() {
                          _resetAllExcept('samR');
                          _isRevisionExpanded = !_isRevisionExpanded;
                        });
                      },
                      pageContent: SamRevisionTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('ManpowerTailors'))
                  _buildSection1(
                    title: 'Manpower Table',
                    isExpanded: _isManpowerExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('manpower');
                        _isManpowerExpanded = !_isManpowerExpanded;
                      });
                    },
                    pageContent: ManPowerDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('ATTManpowerTailors'))
                  _buildSection1(
                    title: 'ATT Manpower Today - Tailor',
                    isExpanded: _isManpowerTailorExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('manpowerTailor');
                        _isManpowerTailorExpanded = !_isManpowerTailorExpanded;
                      });
                    },
                    pageContent: AttManpowerTailorTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('ATTManpowerStaff'))
                  _buildSection1(
                    title: 'ATT Manpower Today - Staff',
                    isExpanded: _isManpowerStaffExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('manpowerStaff');
                        _isManpowerStaffExpanded = !_isManpowerStaffExpanded;
                      });
                    },
                    pageContent: AttManpowerStaffTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if(visibleSections.contains('AdditionalSummaryDashRpt'))
                  _buildSection1(
                      title: 'Additional Loss',
                      isExpanded: _isAdditionalLossExpanded,
                      onTap: () {
                        setState(() {
                          _resetAllExcept('additional');
                          _isAdditionalLossExpanded = !_isAdditionalLossExpanded;
                        });
                      },
                      pageContent: AdditionalLossTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('AuditVsActual'))
                  _buildSection1(
                    title: 'Audit VS Actual',
                    isExpanded: _isAuditVsExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('auditVs');
                        _isAuditVsExpanded = !_isAuditVsExpanded;
                      });
                    },
                    pageContent: AuditVsActualTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('EnergyCost'))
                  _buildSection1(
                    title: 'Energy Cost',
                    isExpanded: _isEnergyExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('energy');
                        _isEnergyExpanded = !_isEnergyExpanded;
                      });
                    },
                    pageContent: EnergyDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('FinishingTurnover'))
                  _buildSection1(
                    title: 'Factory Finishing Turnover',
                    isExpanded: _isFinishTurnExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('finishTurn');
                        _isFinishTurnExpanded = !_isFinishTurnExpanded;
                      });
                    },
                    pageContent: FinishTurnDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('OntimeDelivery'))
                  _buildSection1(
                    title: 'Ontime Delivery',
                    isExpanded: _isOnTimeExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('onTime');
                        _isOnTimeExpanded = !_isOnTimeExpanded;
                      });
                    },
                    pageContent: OnTimeTable1(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('CostCategory2StyleDtl'))
                  _buildSection1(
                    title: 'Category2 Styles',
                    isExpanded: _isCatExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('Cat');
                        _isCatExpanded = !_isCatExpanded;
                      });
                    },
                    pageContent: Category2DataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
                if (visibleSections.contains('CostCategory2StyleDtl'))
                  _buildSection1(
                    title: 'Category3 Styles',
                    isExpanded: _isCat3Expanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('Cat3');
                        _isCat3Expanded = !_isCat3Expanded;
                      });
                    },
                    pageContent: Category3DataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                    color: Colors.black12,
                  ),
                if (visibleSections.contains('MgmntReviewProductionTNA'))
                  _buildSection1(
                    title: 'Production TNA',
                    isExpanded: _isProdTnaExpanded,
                    onTap: () {
                      setState(() {
                        _resetAllExcept('prodTna');
                        _isProdTnaExpanded = !_isProdTnaExpanded;
                      });
                    },pageContent: ProdTnaDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}