import 'dart:async';
import 'package:flutter/cupertino.dart';
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
import 'package:ppms/DashboardTable/prod_detail_with_rights.dart';
import 'package:ppms/DashboardTable/prod_tna.dart';
import 'package:ppms/DashboardTable/profit_n_loss.dart';
import 'package:ppms/DashboardTable/sam_prod.dart';
import 'package:ppms/DashboardTable/sam_revision_table.dart';
import 'package:ppms/DashboardTable/on_time_delivery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DashboardTable/category_3_style.dart';
import '../DashboardTable/man_power.dart';
import '../DashboardTable/sam_revision.dart';
import '../Theme/app_theme.dart';
import '../common/utils/constants/baseurl.dart';

class ProfitAndLossScreen extends StatefulWidget {
  final String fromDate;
  final String toDate;

  ProfitAndLossScreen({required this.fromDate, required this.toDate});

  @override
  _ProfitAndLossScreenState createState() => _ProfitAndLossScreenState();
}

class _ProfitAndLossScreenState extends State<ProfitAndLossScreen> with TickerProviderStateMixin {
  String? _loginId;
  bool _isProdQty = false;
  late Future<List<String>> futureUnits, unitsVg;
  List<String> visibleSections = [];
  String unit = '', vgUnit = '';
  bool _showFullTitle = true, _showCursor = true, _isReversing = false;
  bool isDarkMode = false;
  late AnimationController _backButtonController;
  late Animation<Offset> _backButtonAnimation;
  late AnimationController _typingController;
  late Animation<int> _typingAnimation;
  late Timer _cursorTimer;
  String _displayText = '';
  int _currentMaxLength = 0;
  bool _showSearchIcon = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  // For section animations
  late AnimationController _sectionAnimationController;
  late Animation<double> _sectionFadeAnimation;
  late Animation<double> _sectionSlideAnimation;
  late AnimationController _expansionController;
  late Animation<double> _heightFactor;

  // Map to store which sections should be expanded
  final Map<String, bool> _sectionExpansionState = {
    'Profit & Loss': false,
    'Production Detail': false,
    'Embroidery': false,
    'OT Detail': false,
    'Finishing Asking Detail': false,
    'Audit Data(Fail %)': false,
    'Cut To Ship(%)': false,
    'Sam Produced': false,
    'Sam Revision Detail': false,
    'Manpower Table': false,
    'ATT Manpower Today - Tailor': false,
    'ATT Manpower Today - Staff': false,
    'Additional Loss': false,
    'Audit VS Actual': false,
    'Energy Cost': false,
    'Factory Finishing Turnover': false,
    'Ontime Delivery': false,
    'Category2 Styles': false,
    'Category3 Styles': false,
    'Production TNA': false,
    'Sam Revision': false,
  };

  // Map to associate section titles with their visibility keys
  final Map<String, String> _sectionVisibilityKeys = {
    'Profit & Loss': 'ProfitNLosss',
    'Production Detail': 'ProductionDtl',
    'Embroidery': 'Embroidery',
    'OT Detail': 'OtDetails',
    'Finishing Asking Detail': 'FinishAskingDtl',
    'Audit Data(Fail %)': 'AuditData',
    'Cut To Ship(%)': 'CutToShip',
    'Sam Produced': 'SamProduced',
    'Sam Revision Detail': 'SamRevisionDtl',
    'Manpower Table': 'ManpowerTailors',
    'ATT Manpower Today - Tailor': 'ATTManpowerTailors',
    'ATT Manpower Today - Staff': 'ATTManpowerStaff',
    'Additional Loss': 'AdditionalSummaryDashRpt',
    'Audit VS Actual': 'AuditVsActual',
    'Energy Cost': 'EnergyCost',
    'Factory Finishing Turnover': 'FinishingTurnover',
    'Ontime Delivery': 'OntimeDelivery',
    'Category2 Styles': 'CostCategory2StyleDtl',
    'Category3 Styles': 'CostCategory2StyleDtl',
    'Production TNA': 'MgmntReviewProductionTNA',
    'Sam Revision': 'CostRevisionMgmtRw',
  };

  @override
  void initState() {
    super.initState();

    // Initialize section animations
    _sectionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _sectionFadeAnimation = CurvedAnimation(
      parent: _sectionAnimationController,
      curve: Curves.easeInOut,
    );

    _sectionSlideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _sectionAnimationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _expansionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightFactor = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOut,
    );

    _loadLoginIdAndFetchData();
    _currentMaxLength = 'Paramount Product Management System'.length;
    _setupAnimations();
    _startTypingSequence();
    backAnimation();

    Future.delayed(const Duration(milliseconds: 200), () {
      _loadVisibleSections();
      fetchProdQtyRights(_loginId!);
      _sectionAnimationController.forward();
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

      unitsVg = fetchUnitsVg();
      unitsVg.then((units) {
        vgUnit = units.join(',');
        if (kDebugMode) {
          print('Units: $vgUnit');
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('Error fetching units: $error');
        }
      });
    });
  }

  @override
  void dispose() {
    _typingController
      ..removeListener(_updateText)
      ..stop()
      ..dispose();

    _cursorTimer.cancel();
    _backButtonController.dispose();
    _sectionAnimationController.dispose();
    _expansionController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _loadVisibleSections() async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}special?user=$_loginId&module=dashboard&page=managementreview'));
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}special?user=$_loginId&module=dashboard&page=managementreview');
    }
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        visibleSections.addAll(data.map((item) => item['name'].toString()).toList());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void backAnimation() {
    _backButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _handleBack() async {
    _typingController.stop();
    _cursorTimer.cancel();

    try {
      final animation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.2), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 0.2, end: -1.5), weight: 60),
      ]).animate(_backButtonController);

      await _backButtonController.forward();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _setupAnimations() {
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _typingAnimation = IntTween(begin: 0, end: _currentMaxLength).animate(
      CurvedAnimation(
        parent: _typingController,
        curve: Curves.easeInOut,
      ),
    );

    _typingAnimation.addListener(_updateText);
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), _toggleCursor);
  }

  void _updateText() {
    const fullText = 'Paramount Product Management System';
    const shortText = 'Management Review';

    setState(() {
      _displayText = _showFullTitle
          ? fullText.substring(0, _typingAnimation.value)
          : shortText.substring(0, _typingAnimation.value.clamp(0, shortText.length));
    });
  }

  void _toggleCursor(Timer timer) {
    if (mounted) {
      final shouldShowCursor = _typingController.value > 0 &&
          _typingController.value < 1.0;

      if (shouldShowCursor || _showCursor != shouldShowCursor) {
        setState(() => _showCursor = shouldShowCursor);
      }
    }
  }

  Future<void> _startTypingSequence() async {
    _currentMaxLength = 'Paramount Product Management System'.length;
    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isReversing = true);
    await _typingController.reverse(from: 1.0);

    if (mounted) {
      setState(() {
        _showFullTitle = false;
        _isReversing = false;
        _currentMaxLength = 'PPMS'.length;
        _showSearchIcon = true;
      });
    }

    _typingController.duration = const Duration(milliseconds: 3000);
    await _typingController.forward(from: 0);
  }

  Future<void> _loadLoginIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loginId = prefs.getString('login_id');
    });
    if (_loginId != null) {
      await fetchUnits();
      await fetchProdQtyRights(_loginId!);
    }
  }

  Future<List<String>> fetchUnits() async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId'));
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId');
    }

    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> units = unitsJson.map((unit) => unit['UnitCode1'].toString()).toList();
      if (kDebugMode) {
        print(units);
      }
      return units;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<List<String>> fetchUnitsVg() async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId'));
    if (kDebugMode) {
      print('${TBaseURL.baseUrl}unit_vg?type=VG&user=$_loginId');
    }

    if (response.statusCode == 200) {
      final List<dynamic> unitsJson = json.decode(response.body);
      final List<String> unitsVg = unitsJson.map((unit) => unit['UnitCode'].toString()).toList();
      if (kDebugMode) {
        print(unitsVg);
      }
      return unitsVg;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  Future<void> fetchProdQtyRights(String login) async {
    final response = await http.get(Uri.parse('${TBaseURL.baseUrl}special_vg?user=$login&page=DashMngmntReview'));
    print('${TBaseURL.baseUrl}special_vg?user=$_loginId&page=DashMngmntReview');
    if (response.statusCode == 200) {
      final List<dynamic> modules = jsonDecode(response.body);
      setState(() {
        _isProdQty = modules.any((module) => module['MODULE_NAME'] == 'AllowShowSalesValue');
        visibleSections.addAll(modules.map((item) => item['MODULE_NAME'].toString()).toList());
        print(visibleSections);
      });
      return;
    } else {
      throw Exception('Failed to load units from API');
    }
  }

  void _toggleSectionExpansion(String sectionTitle) {
    setState(() {
      // Collapse all other sections
      _sectionExpansionState.forEach((key, value) {
        if (key != sectionTitle) {
          _sectionExpansionState[key] = false;
        }
      });

      // Toggle the selected section
      _sectionExpansionState[sectionTitle] = !_sectionExpansionState[sectionTitle]!;

      // Animate the expansion
      if (_sectionExpansionState[sectionTitle]!) {
        _expansionController.forward();
      } else {
        _expansionController.reverse();
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();

      // If search query is empty, collapse all sections
      if (_searchQuery.isEmpty) {
        _sectionExpansionState.forEach((key, value) {
          _sectionExpansionState[key] = false;
        });
        _expansionController.reverse();
      }
    });
  }

  bool _shouldShowSection(String sectionTitle) {
    // If no search query, show all visible sections
    if (_searchQuery.isEmpty) {
      return visibleSections.contains(_sectionVisibilityKeys[sectionTitle]);
    }

    // If search query exists, only show matching sections that are also visible
    return sectionTitle.toLowerCase().contains(_searchQuery) &&
        visibleSections.contains(_sectionVisibilityKeys[sectionTitle]);
  }

  Widget _buildSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget pageContent,
    Color color = Colors.white,
  }) {
    return AnimatedBuilder(
      animation: _sectionAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _sectionFadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _sectionSlideAnimation.value),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: SizeTransition(
                    axisAlignment: 1.0,
                    sizeFactor: _heightFactor,
                    child: Container(
                      height: isExpanded ? null : 0,
                      child: isExpanded
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ConstrainedBox(constraints: BoxConstraints(
                                maxHeight:
                                MediaQuery.of(context).size.height * 0.6),
                            child: pageContent),
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search sections...',
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSections() {
    List<Widget> sections = [];

    // Helper function to add a section if it should be shown
    void addSectionIfVisible(String title, Widget content) {
      if (_shouldShowSection(title)) {
        sections.add(
          _buildSection(
            title: title,
            isExpanded: _sectionExpansionState[title]!,
            onTap: () => _toggleSectionExpansion(title),
            pageContent: content,
            color: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }

    // Add all sections with their respective content
    addSectionIfVisible(
      'Profit & Loss',
      PnLDataTable(from: widget.fromDate, to: widget.toDate, units: unit, unitsVg: vgUnit),
    );

    addSectionIfVisible(
      'Production Detail',
      _isProdQty
          ? ProductionDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit)
          : ProductionDataRightTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Embroidery',
      EmbroideryDetailTable(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'OT Detail',
      OTDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Finishing Asking Detail',
      FinishingDataTable(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'Audit Data(Fail %)',
      AuditDetailTable(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'Cut To Ship(%)',
      CutShipTable(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'Sam Produced',
      SamProdTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Sam Revision Detail',
      SamRevisionTable(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'Manpower Table',
      ManPowerDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'ATT Manpower Today - Tailor',
      AttManpowerTailorTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'ATT Manpower Today - Staff',
      AttManpowerStaffTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Additional Loss',
      AdditionalLossTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Audit VS Actual',
      AuditVsActualTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Energy Cost',
      EnergyDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Factory Finishing Turnover',
      FinishTurnDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Ontime Delivery',
      OnTimeTable1(from: widget.fromDate, to: widget.toDate, units: unit),
    );

    addSectionIfVisible(
      'Category2 Styles',
      Category2DataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Category3 Styles',
      Category3DataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Production TNA',
      ProdTnaDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    addSectionIfVisible(
      'Sam Revision',
      SamRevDataTable(from: widget.fromDate, to: widget.toDate, units: unit, vgUnit: vgUnit),
    );

    if (sections.isEmpty && _searchQuery.isNotEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No matching sections found',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary
              ),
            ),
          ),
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        bottom: const PreferredSize(
            preferredSize: Size(7, 7),
            child: Divider(
              color: Colors.white,
              indent: 16,
              endIndent: 16,
            )),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        leading: AnimatedBuilder(
          animation: _backButtonController,
          builder: (context, child) {
            final value = _backButtonController.value;
            double offset;

            if (value < 0.4) {
              offset = Curves.easeOut.transform(value / 0.4) * 0.2;
            } else {
              offset = 0.2 + Curves.easeIn.transform((value - 0.4) / 0.6) * -1.7;
            }

            return Transform.translate(
              offset: Offset(offset * 30, 0),
              child: Container(
                margin: const EdgeInsets.only(left: 12, top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: _handleBack,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _displayText,
                key: ValueKey(_showFullTitle),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _showFullTitle ? 14 : 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: _showFullTitle ? 0.0 : 0.5,
                ),
              ),
            ),
            if (_showCursor && _typingController.value < 1.0 && _typingController.value > 0)
              Container(
                width: 6,
                height: 20,
                margin: const EdgeInsets.only(left: 2),
                color: Colors.grey,
              ),
          ],
        ),
        centerTitle: true,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        actions: [
          if (_showSearchIcon && !_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchFocusNode.requestFocus();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching) _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ..._buildFilteredSections(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}