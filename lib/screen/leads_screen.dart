import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/lead_master_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/projects_screen.dart';
import '../provider/leads_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:truerealtycrm/widget/todays_follow_ups_fab.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadListWidget extends StatefulWidget {
  const LeadListWidget({
    super.key,
    this.isInsideScrollView = false,
    this.onMenuTap,
    this.statusTabs,
  });
  final bool isInsideScrollView;
  final VoidCallback? onMenuTap;

  /// When set, replaces dynamic status chips with these fixed pipeline tabs.
  final List<String>? statusTabs;

  @override
  State<LeadListWidget> createState() => _LeadListWidgetState();
}

class _LeadListWidgetState extends State<LeadListWidget> {
  int _page = 1;
  late String _selectedTab;
  bool _showFilters = false;
  bool _loadingFilters = false;
  // Kept for backwards-compatible helper code; export is no longer exposed.
  // ignore: unused_field
  bool _exportingPdf = false;
  bool _selectionMode = false;
  final Set<String> _selectedLeadIds = <String>{};
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String? _leadType;
  String? _leadStatus;
  String? _propertyType;
  String? _configuration;
  String? _assignedTo;
  String? _team;
  String? _area;
  String? _slaStatus;
  String? _dateRange;
  DateTime? _customDateFrom;
  DateTime? _customDateTo;
  List<String> _leadTypes = const ['Hot', 'Warm', 'Cold'];
  List<String> _configurations = const [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '5 BHK',
    'Studio',
    'Penthouse',
  ];
  List<String> _propertyTypes = const [
    'Apartment',
    'Villa',
    'Plot',
    'Commercial',
  ];
  List<String> _assignees = const [];
  List<String> _teams = const [];
  List<String> _areas = const [];
  final List<String> _slaStatuses = const [
    'On Track',
    'Due Soon',
    'Overdue',
    'No SLA',
  ];

  static const double _sectionGap = 18;
  static const double _cardGap = 14;

  bool get _usesPresetTabs =>
      widget.statusTabs != null && widget.statusTabs!.isNotEmpty;

  String get _defaultTab {
    if (!_usesPresetTabs) return 'All';
    final tabs = widget.statusTabs!;
    for (final tab in tabs) {
      if (tab.trim().toLowerCase() == 'all') return tab;
    }
    return tabs.first;
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = _defaultTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchLeads();
        _loadFilterOptions();
      }
    });
  }

  Future<void> _fetchLeads({int page = 1}) async {
    _page = page;
    final tabFilter = _filtersForSelectedTab();
    await context.read<LeadProvider>().fetchLeads(
      page: page,
      limit: 10,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      status: _leadStatus ?? tabFilter.status,
      leadType: _leadType ?? tabFilter.leadType,
      configuration: _configuration,
      propertyType: _propertyType,
      assignedTo: _assignedTo,
      team: _team,
      area: _area,
      slaStatus: _slaStatus,
      dateFrom: _dateBounds.$1,
      dateTo: _dateBounds.$2,
    );
    if (!mounted) return;
    _syncFilterOptionsFromLeads(context.read<LeadProvider>().leads);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _fetchLeads(page: 1);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    if (_loadingFilters) return;
    setState(() => _loadingFilters = true);
    try {
      final projectResponse = await context
          .read<ProjectProvider>()
          .fetchProjects();
      if (!mounted) return;
      final fromProjects = _configurationLabelsFromProjects(
        projectResponse?.data,
      );
      setState(() {
        _configurations = _mergeOptions(_configurations, fromProjects);
        _loadingFilters = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingFilters = false);
    }
  }

  void _syncFilterOptionsFromLeads(List<LeadModel> leads) {
    final types = <String>{..._leadTypes};
    final configs = <String>{..._configurations};
    final propertyTypes = <String>{..._propertyTypes};
    final assignees = <String>{..._assignees};
    final teams = <String>{..._teams};
    final areas = <String>{..._areas};
    for (final lead in leads) {
      final type = lead.leadType?.trim() ?? '';
      if (type.isNotEmpty) types.add(type);
      final config = lead.configuration?.trim() ?? '';
      if (config.isNotEmpty) configs.add(config);
      final propertyType = lead.propertyType?.trim() ?? '';
      if (propertyType.isNotEmpty) propertyTypes.add(propertyType);
      final assigned = lead.assignedTo?.trim() ?? '';
      if (assigned.isNotEmpty) assignees.add(assigned);
      final raw = lead.raw ?? const <String, dynamic>{};
      final team = _firstFilterValue(raw, const [
        'teamName',
        'team',
        'assignedTeamName',
      ]);
      if (team.isNotEmpty) teams.add(team);
      final area = _firstFilterValue(raw, const [
        'areaName',
        'area',
        'projectArea',
        'preferredLocation',
      ]);
      if (area.isNotEmpty) areas.add(area);
    }
    final nextTypes = types.toList()..sort();
    final nextConfigs = configs.toList()..sort();
    final nextPropertyTypes = propertyTypes.toList()..sort();
    final nextAssignees = assignees.toList()..sort();
    final nextTeams = teams.toList()..sort();
    final nextAreas = areas.toList()..sort();
    if (!_listEquals(nextTypes, _leadTypes) ||
        !_listEquals(nextConfigs, _configurations) ||
        !_listEquals(nextPropertyTypes, _propertyTypes) ||
        !_listEquals(nextAssignees, _assignees) ||
        !_listEquals(nextTeams, _teams) ||
        !_listEquals(nextAreas, _areas)) {
      setState(() {
        _leadTypes = nextTypes;
        _configurations = nextConfigs;
        _propertyTypes = nextPropertyTypes;
        _assignees = nextAssignees;
        _teams = nextTeams;
        _areas = nextAreas;
      });
    }
  }

  String _firstFilterValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<String> _mergeOptions(List<String> primary, List<String> extra) {
    final values = <String>{
      ...primary.map((e) => e.trim()).where((e) => e.isNotEmpty),
      ...extra.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };
    return values.toList()..sort();
  }

  List<String> _configurationLabelsFromProjects(Object? source) {
    final projects = _extractList(source);
    final values = <String>{};
    for (final project in projects) {
      if (project is! Map) continue;
      final configurations =
          project['configurations'] ?? project['configuration'];
      if (configurations is List) {
        for (final item in configurations) {
          final text = item.toString().trim();
          if (text.isNotEmpty) values.add(text);
        }
      } else if (configurations != null) {
        final text = configurations.toString().trim();
        if (text.isNotEmpty) values.add(text);
      }
    }
    return values.toList()..sort();
  }

  List<dynamic> _extractList(Object? source) {
    Object? value = source;
    for (var i = 0; i < 4 && value is Map; i++) {
      final map = Map<String, dynamic>.from(value);
      value =
          map['data'] ??
          map['items'] ??
          map['results'] ??
          map['rows'] ??
          map['projects'];
    }
    return value is List ? value : const [];
  }

  (String?, String?) get _dateBounds {
    final now = DateTime.now();
    DateTime? from;
    DateTime? to;
    switch (_dateRange) {
      case 'Today':
        from = DateTime(now.year, now.month, now.day);
      case 'Last 7 days':
        from = now.subtract(const Duration(days: 7));
      case 'Last 30 days':
        from = now.subtract(const Duration(days: 30));
      case 'This month':
        from = DateTime(now.year, now.month);
      case 'Date':
      case 'Custom date':
        from = _customDateFrom;
        to = _customDateTo;
    }
    String? date(DateTime? value) => value == null
        ? null
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return (date(from), from == null ? null : date(to ?? now));
  }

  Future<void> _selectDateFilter(String? value) async {
    if (value == null) {
      setState(() {
        _dateRange = null;
        _customDateFrom = null;
        _customDateTo = null;
      });
      return;
    }

    final now = DateTime.now();
    if (value == 'Date') {
      final selected = await showDatePicker(
        context: context,
        initialDate: _customDateFrom ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _dateRange = value;
        _customDateFrom = selected;
        _customDateTo = selected;
      });
      return;
    }

    if (value == 'Custom date') {
      final selected = await showDateRangePicker(
        context: context,
        initialDateRange: _customDateFrom == null || _customDateTo == null
            ? null
            : DateTimeRange(start: _customDateFrom!, end: _customDateTo!),
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _dateRange = value;
        _customDateFrom = selected.start;
        _customDateTo = selected.end;
      });
      return;
    }

    setState(() {
      _dateRange = value;
      _customDateFrom = null;
      _customDateTo = null;
    });
  }

  Future<void> _selectTab(String tab) async {
    if (_selectedTab == tab && _page == 1) {
      return;
    }
    setState(() => _selectedTab = tab);
    await _fetchLeads(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = context.watch<LeadProvider>();

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: _sectionGap.h),
        _buildSearchAndActions(context),
        if (_showFilters) ...[SizedBox(height: 14.h), _buildAdvancedFilters()],
        SizedBox(height: 14.h),
        _buildTabs(leadProvider),
        SizedBox(height: _sectionGap.h),
        if (leadProvider.isLoading && leadProvider.leads.isEmpty)
          const AppListSkeleton(itemCount: 4, itemHeight: 176)
        else if (leadProvider.error != null && leadProvider.leads.isEmpty)
          _buildErrorState(leadProvider.error!)
        else if (leadProvider.leads.isEmpty)
          _buildEmptyState()
        else
          RefreshIndicator(
            onRefresh: () => _fetchLeads(page: _page),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadProvider.leads.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: _cardGap.h),
              itemBuilder: (context, index) =>
                  _buildLeadCard(context, leadProvider.leads[index], index),
            ),
          ),
        SizedBox(height: 20.h),
        _buildBottomSection(context, leadProvider),
      ],
    );

    if (widget.isInsideScrollView) {
      return Container(
        color: AppColors.leadListBg,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: bodyContent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.leadListBg,
      floatingActionButton: TodaysFollowUpsFab(
        onPressed: () => Navigator.pushNamed(context, AppRouter.myFollowUps),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.leadListBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 380;
    final titleRow = Row(
      children: [
        IconButton(
          tooltip: widget.onMenuTap == null ? 'Back' : 'Open navigation',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 38.w, height: 38.w),
          onPressed: widget.onMenuTap ?? () => Navigator.maybePop(context),
          icon: Icon(
            widget.onMenuTap == null
                ? Icons.arrow_back_ios_new
                : Icons.menu_rounded,
            size: 21.sp,
            color: AppColors.textIconDark,
          ),
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            'Lead List',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final addButton = Container(
      decoration: BoxDecoration(
        color: AppColors.orangeStrong,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparentWhite,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => Navigator.pushNamed(context, AppRouter.addLead),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/add.png',
                  height: 15.h,
                  width: 15.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Add Lead',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          SizedBox(height: 12.h),
          addButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleRow),
        SizedBox(width: 12.w),
        addButton,
      ],
    );
  }

  Widget _buildSearchAndActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _fetchLeads(page: 1),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search leads by name, phone or project',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _fetchLeads(page: 1);
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.orangeStrong,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 48.w,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectionMode = !_selectionMode;
                    if (!_selectionMode) _selectedLeadIds.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _selectionMode
                      ? AppColors.orangeStrong
                      : AppColors.navy,
                  backgroundColor: _selectionMode
                      ? const Color(0xFFFFF4ED)
                      : Colors.white,
                  side: BorderSide(
                    color: _selectionMode
                        ? AppColors.orangeStrong
                        : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Icon(
                  _selectionMode
                      ? Icons.close_rounded
                      : Icons.checklist_rounded,
                  size: 21.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 48.w,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: _showFilters
                      ? AppColors.orangeStrong
                      : AppColors.navy,
                  backgroundColor: _showFilters
                      ? const Color(0xFFFFF4ED)
                      : Colors.white,
                  side: BorderSide(
                    color: _showFilters
                        ? AppColors.orangeStrong
                        : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Icon(
                  _showFilters
                      ? Icons.filter_alt_off_rounded
                      : Icons.filter_alt_rounded,
                  size: 21.sp,
                ),
              ),
            ),
          ],
        ),
        if (_selectionMode) ...[
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                '${_selectedLeadIds.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedLeadIds.isEmpty
                    ? null
                    : () => _openSelectedLeadUpdate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeStrong,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Update selected'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTabs(LeadProvider leadProvider) {
    final tabs = _usesPresetTabs
        ? widget.statusTabs!
        : leadProvider.statusNames
              .where((status) => !_isLostStatus(status))
              .toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (!_usesPresetTabs) ...[
            _tabChip(
              'All (${_formatCount(leadProvider.totalLeads)})',
              isSelected: _selectedTab == 'All',
              onTap: () => _selectTab('All'),
            ),
            if (tabs.isNotEmpty) SizedBox(width: 8.w),
          ],
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _tabChip(
              '${tabs[i]} (${_formatCount(_tabCount(leadProvider, tabs[i]))})',
              isSelected: _selectedTab == tabs[i],
              textColor: _tabTextColor(tabs[i]),
              backgroundColor: _tabBackgroundColor(tabs[i]),
              onTap: () => _selectTab(tabs[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final statusOptions = context
        .watch<LeadProvider>()
        .statusNames
        .where((status) => !_isLostStatus(status))
        .toList();
    final activeCount = [
      _leadStatus,
      _leadType,
      _propertyType,
      _configuration,
      _assignedTo,
      _team,
      _area,
      _dateRange,
      _slaStatus,
    ].where((value) => value != null).length;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Advanced filters',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _filterCountBadge(activeCount),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Refine leads by ownership, property, status, SLA, and date.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hide filters',
                onPressed: () => setState(() => _showFilters = false),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            ],
          ),
          Divider(height: 24.h),
          if (_loadingFilters)
            const LinearProgressIndicator()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 900
                    ? (constraints.maxWidth - 24.w) / 3
                    : constraints.maxWidth >= 560
                    ? (constraints.maxWidth - 12.w) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 14.h,
                  children: [
                    _filterDropdown(
                      'Lead Status',
                      _leadStatus,
                      statusOptions,
                      width,
                      (v) => setState(() {
                        _leadStatus = v;
                        if (v != null) _selectedTab = _defaultTab;
                      }),
                    ),
                    _filterDropdown(
                      'Lead Type',
                      _leadType,
                      _leadTypes,
                      width,
                      (v) => setState(() => _leadType = v),
                    ),
                    _filterDropdown(
                      'Property Type',
                      _propertyType,
                      _propertyTypes,
                      width,
                      (v) => setState(() => _propertyType = v),
                    ),
                    _filterDropdown(
                      'Configuration',
                      _configuration,
                      _configurations,
                      width,
                      (v) => setState(() => _configuration = v),
                    ),
                    _filterDropdown(
                      'Assigned To',
                      _assignedTo,
                      _assignees,
                      width,
                      (v) => setState(() => _assignedTo = v),
                    ),
                    _filterDropdown(
                      'Team-wise',
                      _team,
                      _teams,
                      width,
                      (v) => setState(() => _team = v),
                    ),
                    _filterDropdown(
                      'Area-wise',
                      _area,
                      _areas,
                      width,
                      (v) => setState(() => _area = v),
                    ),
                    _filterDropdown(
                      'Date Range',
                      _dateRange,
                      const [
                        'Date',
                        'Custom date',
                        'Today',
                        'Last 7 days',
                        'Last 30 days',
                        'This month',
                      ],
                      width,
                      _selectDateFilter,
                    ),
                    _filterDropdown(
                      'SLA Status',
                      _slaStatus,
                      _slaStatuses,
                      width,
                      (v) => setState(() => _slaStatus = v),
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: 18.h),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(minimumSize: Size(88.w, 44.h)),
                child: Text(
                  'Reset',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _fetchLeads(page: 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orangeStrong,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 13.h,
                  ),
                  minimumSize: Size(132.w, 44.h),
                ),
                icon: Icon(Icons.filter_alt_outlined, size: 17.sp),
                label: Text(
                  'Apply Filter',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(
    String label,
    String? value,
    List<String> options,
    double width,
    ValueChanged<String?> onChanged,
  ) {
    final unique = options.toSet().toList()..sort();
    final selected = unique.contains(value) ? value : null;
    final allLabel = switch (label) {
      'Lead Status' => 'All Status',
      'Lead Type' => 'All Lead Types',
      'Property Type' => 'All Property Types',
      'Configuration' => 'All Configurations',
      'Assigned To' => 'All Assigned To',
      'Team-wise' => 'All Teams',
      'Area-wise' => 'All Areas',
      'Date Range' => 'All Date Ranges',
      'SLA Status' => 'All SLA Statuses',
      _ => 'All $label',
    };
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 7.h),
          DropdownButtonFormField<String?>(
            key: ValueKey('$label-$selected-${unique.length}'),
            initialValue: selected,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp),
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFFCFDFE),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 13.w,
                vertical: 13.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFD8E0EC)),
              ),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(allLabel, overflow: TextOverflow.ellipsis),
              ),
              ...unique.map(
                (item) => DropdownMenuItem<String?>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _filterCountBadge(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        '$count active',
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Future<void> _resetFilters() async {
    setState(() {
      _leadStatus = null;
      _leadType = null;
      _propertyType = null;
      _configuration = null;
      _assignedTo = null;
      _team = null;
      _area = null;
      _slaStatus = null;
      _dateRange = null;
      _customDateFrom = null;
      _customDateTo = null;
      _selectedTab = _defaultTab;
    });
    await _fetchLeads(page: 1);
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead, int index) {
    final raw = lead.raw ?? const <String, dynamic>{};
    final requirement = raw['requirement'] is Map
        ? Map<String, dynamic>.from(raw['requirement'] as Map)
        : const <String, dynamic>{};
    final statusLabels = _cardStatusLabels(lead);
    final budget = _leadBudget(requirement);
    final rawRemark = raw['remarks']?.toString().trim() ?? '';
    final remark = rawRemark.isEmpty ? 'No remark added' : rawRemark;
    final nextFollowUp = _leadDate(raw['nextFollowUpAt']);
    final followUpLabel = nextFollowUp == null
        ? lead.dueLabel ?? 'Not scheduled'
        : _leadDateTimeLabel(nextFollowUp);
    final sla = _leadSla(nextFollowUp);
    final project = lead.project?.trim().isNotEmpty == true
        ? lead.project!
        : 'Project not assigned';
    final projectId =
        [
              raw['preferredProjectId'],
              requirement['preferredProjectId'],
              raw['projectId'],
            ]
            .where(
              (value) => value != null && value.toString().trim().isNotEmpty,
            )
            .map((value) => value.toString().trim())
            .firstOrNull;
    final location = lead.location?.trim().isNotEmpty == true
        ? lead.location!
        : '-';
    final leadKey = lead.id ?? lead.phone;
    final isSelected = _selectedLeadIds.contains(leadKey);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (_selectionMode) {
            setState(() {
              isSelected
                  ? _selectedLeadIds.remove(leadKey)
                  : _selectedLeadIds.add(leadKey);
            });
            return;
          }
          _showLeadUpdateSheet([lead]);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF8F3) : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.orangeStrong
                  : const Color(0xFFD5DDE8),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) {
                        setState(() {
                          isSelected
                              ? _selectedLeadIds.remove(leadKey)
                              : _selectedLeadIds.add(leadKey);
                        });
                      },
                      activeColor: AppColors.orangeStrong,
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFF10213D),
                    child: Text(
                      _leadInitials(lead.name),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.leadDetail,
                          arguments: lead,
                        ),
                        child: Text(
                          lead.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B1735),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF0B1735),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < statusLabels.length; i++) ...[
                        if (i > 0) SizedBox(height: 5.h),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 112.w),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _CompactLeadBadge(
                              text: statusLabels[i],
                              foreground: _leadStatusColors(statusLabels[i]).$1,
                              background: _leadStatusColors(statusLabels[i]).$2,
                              borderColor: _leadStatusColors(
                                statusLabels[i],
                              ).$3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 17.sp,
                    color: const Color(0xFF00A86B),
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      lead.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _professionalLeadValueStyle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.apartment_rounded,
                    size: 17.sp,
                    color: const Color(0xFF475467),
                  ),
                  SizedBox(width: 7.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: projectId == null
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProjectsScreen(
                                      initialProjectId: projectId,
                                    ),
                                  ),
                                ),
                          child: Text(
                            project,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _professionalLeadValueStyle.copyWith(
                              decoration: projectId == null
                                  ? null
                                  : TextDecoration.underline,
                            ),
                          ),
                        ),
                        if (location != '-')
                          Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF667085),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _LeadCardDetail(
                        icon: Icons.payments_outlined,
                        label: 'Budget',
                        value: budget,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _LeadCardDetail(
                        icon: Icons.event_available_outlined,
                        label: 'Next follow-up',
                        value: followUpLabel,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 11.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 17.sp,
                    color: const Color(0xFF667085),
                  ),
                  SizedBox(width: 7.w),
                  Text('Remark: ', style: _professionalLeadLabelStyle),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showAddRemarkDialog(lead),
                      child: Text(
                        remark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _professionalLeadFooterValueStyle.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.h),
              Row(
                children: [
                  Text('Owner: ', style: _professionalLeadLabelStyle),
                  Expanded(
                    child: Text(
                      lead.assignedTo ?? 'Unassigned',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _professionalLeadFooterValueStyle,
                    ),
                  ),
                  _CompactLeadBadge(
                    text: sla.$1,
                    foreground: sla.$2,
                    background: sla.$2.withValues(alpha: .08),
                    borderColor: sla.$2.withValues(alpha: .3),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddRemarkDialog(lead),
                        icon: Icon(Icons.add_comment_outlined, size: 15.sp),
                        label: FittedBox(
                          child: Text(
                            'Add Remark',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeStrong,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: OutlinedButton.icon(
                        onPressed: () => _callLead(lead.phone),
                        icon: Icon(Icons.call_outlined, size: 14.sp),
                        label: Text(
                          'Call',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.orangeDeep,
                          side: const BorderSide(color: Color(0xFFFFD8C2)),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 40.h,
                      child: OutlinedButton.icon(
                        onPressed: () => _openWhatsApp(lead.phone),
                        icon: Icon(Icons.chat_outlined, size: 14.sp),
                        label: Text(
                          'WhatsApp',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF168553),
                          side: const BorderSide(color: Color(0xFFB7E4C7)),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddRemarkDialog(LeadModel lead) async {
    final leadId = lead.id;
    if (leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead ID is unavailable.')));
      return;
    }
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddLeadRemarkDialog(lead: lead),
    );
    if (added == true && mounted) await _fetchLeads(page: _page);
  }

  Future<void> _openSelectedLeadUpdate() async {
    final selected = context
        .read<LeadProvider>()
        .leads
        .where((lead) => _selectedLeadIds.contains(lead.id ?? lead.phone))
        .toList();
    if (selected.isNotEmpty) await _showLeadUpdateSheet(selected);
  }

  Future<List<_LeadUpdateOption>> _loadUpdateOptions(
    List<String> categories,
  ) async {
    final provider = context.read<LeadMasterProvider>();
    for (final category in categories) {
      final response = await provider.fetchMasterValues(
        masterCategory: category,
      );
      final options = _updateOptionList(response?.data);
      if (options.isNotEmpty) return options;
    }
    return const [];
  }

  Future<void> _showLeadUpdateSheet(List<LeadModel> leads) async {
    final optionGroups = await Future.wait([
      _loadUpdateOptions(const ['status', 'lead_status', 'lead-status']),
      _loadUpdateOptions(const [
        'temperature',
        'lead_temperature',
        'lead-temperature',
      ]),
    ]);
    if (!mounted) return;

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LeadUpdateDialog(
        leads: leads,
        statuses: optionGroups[0],
        temperatures: optionGroups[1],
      ),
    );
    if (updated == true && mounted) {
      setState(() {
        _selectionMode = false;
        _selectedLeadIds.clear();
      });
      await _fetchLeads(page: _page);
    }
  }

  Future<void> _callLead(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty || cleaned == '-') return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the phone dialer.')),
      );
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number for WhatsApp.')),
      );
      return;
    }
    final normalized = digits.length == 10 ? '91$digits' : digits;
    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$normalized'),
      Uri.parse('https://api.whatsapp.com/send?phone=$normalized'),
      Uri.parse('https://wa.me/$normalized'),
    ];
    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {}
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open WhatsApp. Please install WhatsApp.'),
      ),
    );
  }

  // ignore: unused_element
  Future<void> _exportLeadsPdf() async {
    final allLeads = context.read<LeadProvider>().leads;
    final leads = _selectionMode && _selectedLeadIds.isNotEmpty
        ? allLeads
              .where((lead) => _selectedLeadIds.contains(lead.id ?? lead.phone))
              .toList()
        : allLeads;

    if (leads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectionMode
                ? 'Select at least one lead to export.'
                : 'No leads available to export.',
          ),
        ),
      );
      return;
    }

    setState(() => _exportingPdf = true);
    try {
      final doc = pw.Document();
      final now = DateTime.now();
      final stamp =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      String clean(String? value) {
        final text = (value ?? '-').trim();
        if (text.isEmpty) return '-';
        return text
            .replaceAll('—', '-')
            .replaceAll('–', '-')
            .replaceAll('•', '-')
            .replaceAll(RegExp(r'[^\x20-\x7E]'), ' ');
      }

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              'TrueRoot Realty - Lead List',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Exported on $stamp | $_selectedTab tab | ${leads.length} leads',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Name',
                'Phone',
                'Status',
                'Type',
                'Project',
                'Location',
                'Owner',
              ],
              data: leads
                  .map(
                    (lead) => [
                      clean(lead.name),
                      clean(lead.phone),
                      clean(lead.status),
                      clean(lead.leadType),
                      clean(lead.project),
                      clean(lead.location),
                      clean(lead.assignedTo),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0F2B57),
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 5,
              ),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.4),
            ),
          ],
        ),
      );

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/TrueRoot-Leads-$stamp.pdf');
      await file.writeAsBytes(await doc.save());
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'TrueRoot Realty lead list',
        text: '${leads.length} leads exported as PDF.',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to export PDF: $error')));
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  // ignore: unused_element
  Future<void> _showLeadActionsSheet(BuildContext context, LeadModel lead) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 8.h, 0, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DDE6),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: const Color(0xFFE8EFFD),
                          child: Text(
                            _leadInitials(lead.name),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF415A93),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              lead.phone,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: const Color(0xFFE9EDF4), height: 1.h),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.remove_red_eye_outlined,
                          iconColor: const Color(0xFF4D7CFE),
                          iconBackground: const Color(0xFFF1F5FF),
                          title: 'View',
                          subtitle: 'Open lead details',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.pushNamed(
                              context,
                              AppRouter.leadProfileManagement,
                              arguments: lead,
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.call_outlined,
                          iconColor: AppColors.orangeDeep,
                          iconBackground: const Color(0xFFFFF1E8),
                          title: 'Call',
                          subtitle: 'Call this lead',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _callLead(lead.phone);
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.chat_outlined,
                          iconColor: const Color(0xFF168553),
                          iconBackground: const Color(0xFFE8F8EF),
                          title: 'WhatsApp',
                          subtitle: 'Message on WhatsApp',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _openWhatsApp(lead.phone);
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.event_note_outlined,
                          iconColor: const Color(0xFF7C3AED),
                          iconBackground: const Color(0xFFF5F0FF),
                          title: 'Create Follow-Up',
                          subtitle: 'Schedule next follow-up',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showCreateFollowUpSheet(context, lead);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(36.h),
                          side: const BorderSide(color: Color(0xFFE1E6EF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF344054),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCreateFollowUpSheet(BuildContext context, LeadModel lead) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7D2FE),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.event_note_outlined,
                              size: 18.sp,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Follow-Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Schedule the next follow-up for this CRM lead and keep the team updated.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: const Color(0xFF52525B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(sheetContext),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.close,
                                size: 20.sp,
                                color: const Color(0xFF3F3F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 1.h, color: const Color(0xFFE4E7EC)),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Follow-Up',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Choose the lead, follow-up type, schedule, and handoff details.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: const Color(0xFF52525B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.h, color: const Color(0xFFE4E7EC)),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFD9DFEA)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D101828),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECTED DETAILS',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFF374151),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Selected Lead',
                                    value: lead.name,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Phone',
                                    value: lead.phone,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Status',
                                    value: lead.status,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Email',
                                    value: lead.email,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF97316),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.priority_high,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scheduling Tip',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9A3412),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Use the searchable lead field instead of typing IDs. Details are still sent internally to the CRM.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                      color: const Color(0xFF57534E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetAction({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEEF1F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14.sp, color: iconColor),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16.sp,
              color: const Color(0xFFB09AFD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpDetailBlock({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF52525B),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  String _leadInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  (Color, Color, Color) _leadStatusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('hot') || value.contains('overdue')) {
      return (
        const Color(0xFFFF641A),
        const Color(0xFFFFF1E8),
        const Color(0xFFFFC8AA),
      );
    }
    if (value.contains('not interest')) {
      return (
        const Color(0xFF7C3AED),
        const Color(0xFFF3E8FF),
        const Color(0xFFE9D5FF),
      );
    }
    if (value.contains('book') || value.contains('convert')) {
      return (
        const Color(0xFF168553),
        const Color(0xFFECFDF3),
        const Color(0xFFA7F3D0),
      );
    }
    if (value.contains('obm') ||
        value.contains('re-visit') ||
        value.contains('revisit')) {
      return (
        const Color(0xFF0F766E),
        const Color(0xFFCCFBF1),
        const Color(0xFF99F6E4),
      );
    }
    if (value.contains('site visit')) {
      return (
        const Color(0xFF2563EB),
        const Color(0xFFEFF6FF),
        const Color(0xFFBFDBFE),
      );
    }
    if (value.contains('follow')) {
      return (
        const Color(0xFFF97316),
        const Color(0xFFFFF7ED),
        const Color(0xFFFED7AA),
      );
    }
    if (value.contains('interest') || value.contains('qualif')) {
      return (
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
        const Color(0xFFDDD6FE),
      );
    }
    if (value.contains('new')) {
      return (
        const Color(0xFF16A34A),
        const Color(0xFFECFDF3),
        const Color(0xFFBBF7D0),
      );
    }
    return (
      const Color(0xFF2563EB),
      const Color(0xFFEFF6FF),
      const Color(0xFFBFDBFE),
    );
  }

  String _leadBudget(Map<String, dynamic> requirement) {
    String text(Object? value) => value?.toString().trim() ?? '';
    final explicit = text(requirement['budgetRange']);
    if (explicit.isNotEmpty && explicit != '-') return explicit;
    final min = text(requirement['minBudget']);
    final max = text(requirement['maxBudget']);
    final unit = text(requirement['budgetUnit']);
    final range = [
      min,
      max,
    ].where((value) => value.isNotEmpty && value != '-').join(' - ');
    return [range, unit]
            .where((value) => value.isNotEmpty && value != '-')
            .join(' ')
            .trim()
            .isEmpty
        ? '-'
        : [
            range,
            unit,
          ].where((value) => value.isNotEmpty && value != '-').join(' ');
  }

  DateTime? _leadDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  String _leadDateTimeLabel(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day} ${months[value.month - 1]}, '
        '$hour:$minute ${value.hour < 12 ? 'AM' : 'PM'}';
  }

  (String, Color) _leadSla(DateTime? nextFollowUp) {
    if (nextFollowUp == null) {
      return ('No SLA', const Color(0xFF667085));
    }
    if (nextFollowUp.isBefore(DateTime.now())) {
      return ('Overdue', const Color(0xFFDC2626));
    }
    return ('Due Soon', const Color(0xFFFF641A));
  }

  Widget _buildBottomSection(BuildContext context, LeadProvider leadProvider) {
    final isNarrow = MediaQuery.sizeOf(context).width < 430;
    final total = leadProvider.totalLeads;
    final shownFrom = total == 0 ? 0 : ((_page - 1) * 10) + 1;
    final shownTo = total == 0
        ? 0
        : (((_page - 1) * 10) + leadProvider.leads.length).clamp(0, total);
    final pagination = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageArrow(
          Icons.chevron_left,
          onTap: _page <= 1 ? null : () => _fetchLeads(page: _page - 1),
        ),
        SizedBox(width: 8.w),
        _pageChip(_page.toString(), isSelected: true),
        SizedBox(width: 8.w),
        Text(
          '...',
          style: TextStyle(
            fontSize: 21.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        _pageChip(_totalPages(total).toString()),
        SizedBox(width: 8.w),
        _pageArrow(
          Icons.chevron_right,
          onTap: _page >= _totalPages(total)
              ? null
              : () => _fetchLeads(page: _page + 1),
        ),
      ],
    );

    return Column(
      children: [
        if (isNarrow) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing $shownFrom to $shownTo of ${_formatCount(total)} leads',
              style: TextStyle(
                fontSize: 21.5.sp,
                color: AppColors.textTertiary,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: pagination,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: Text(
                  'Showing $shownFrom to $shownTo of ${_formatCount(total)} leads',
                  style: TextStyle(
                    fontSize: 19.5.sp,
                    color: AppColors.textTertiary,
                    height: 1.2,
                  ),
                ),
              ),
              pagination,
            ],
          ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, AppRouter.addLead),
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.orangeAccent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.white, size: 28.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabChip(
    String label, {
    bool isSelected = false,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final bg = isSelected
        ? AppColors.darkButton
        : (backgroundColor ?? AppColors.white);
    final fg = isSelected
        ? AppColors.white
        : (textColor ?? AppColors.textSecondary);

    return Material(
      color: AppColors.transparentWhite,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 32.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.darkButton : AppColors.borderSoft,
              width: 1.w,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.1,
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageArrow(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: onTap == null ? AppColors.borderMuted : AppColors.iconMuted,
        ),
      ),
    );
  }

  Widget _pageChip(String label, {bool isSelected = false}) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.darkButton : AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected ? AppColors.darkButton : AppColors.borderSoft,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 21.5.sp,
          color: isSelected ? AppColors.white : AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB91C1C),
            ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton(
            onPressed: () => _fetchLeads(page: _page),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Text(
        'No leads found.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 100000) {
      return '${(count / 100000).toStringAsFixed(1)}L';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  int _totalPages(int total) {
    if (total <= 0) {
      return 1;
    }
    return ((total + 9) / 10).floor();
  }

  String _normalizeStatus(String status) {
    final normalized = status.trim();
    if (normalized.isEmpty) return 'New';
    final lower = normalized.toLowerCase();
    if (lower.contains('hot')) return 'Hot';
    if (lower.contains('warm')) return 'Warm';
    if (lower.contains('book')) return 'Booked';
    if (lower.contains('interested')) return 'Interested';
    if (lower.contains('contacted')) return 'Contacted';
    if (lower.contains('pending')) return 'Pending';
    if (lower.contains('new')) return 'New';
    return normalized;
  }

  List<String> _cardStatusLabels(LeadModel lead) {
    if (!_usesPresetTabs) {
      return [_normalizeStatus(lead.status)];
    }

    final labels = <String>[_pipelineStatusLabel(lead)];
    if (_isHotTemperature(lead) &&
        !labels.any((label) => label.toLowerCase().contains('hot'))) {
      labels.add('Hot Lead');
    }
    return labels;
  }

  String _pipelineStatusLabel(LeadModel lead) {
    final text =
        '${lead.status} ${lead.stage ?? ''} ${lead.leadType ?? ''} '
                '${lead.raw?['statusName'] ?? ''} '
                '${lead.raw?['temperatureName'] ?? ''}'
            .toLowerCase();

    if (text.contains('not interested')) return 'Not Interested';
    if (text.contains('booking') ||
        text.contains('booked') ||
        text.contains('converted') ||
        lead.raw?['convertedAt'] != null) {
      return 'Booking Done';
    }
    if (text.contains('obm')) return 'OBM Done';
    if ((text.contains('re-visit') ||
            text.contains('revisit') ||
            text.contains('re visit')) &&
        (text.contains('done') || text.contains('complete'))) {
      return 'Re-Visit Done';
    }
    if (text.contains('site visit') &&
        (text.contains('done') || text.contains('complete'))) {
      return 'Site Visit Done';
    }
    if (text.contains('site visit') &&
        (text.contains('schedule') || text.contains('scheduled'))) {
      return 'Site Visit Schedule';
    }
    if (text.contains('follow up') || text.contains('follow-up')) {
      return 'Follow Up';
    }
    if (text.contains('hot')) return 'Hot Lead';
    if (text.contains('interested')) return 'Interested';
    if (text.contains('new')) return 'New Lead';

    final raw = lead.status.trim();
    if (raw.isEmpty || raw.toLowerCase() == 'new') return 'New Lead';
    return raw;
  }

  bool _isHotTemperature(LeadModel lead) {
    final text =
        '${lead.leadType ?? ''} ${lead.raw?['temperatureName'] ?? ''} '
                '${lead.raw?['temperature'] ?? ''} ${lead.status}'
            .toLowerCase();
    return text.contains('hot');
  }

  ({String? status, String? leadType}) _filtersForSelectedTab() {
    if (!_usesPresetTabs) {
      return (status: _statusFilterForTab(_selectedTab), leadType: null);
    }

    final lower = _selectedTab.trim().toLowerCase();
    if (lower == 'all') {
      return (status: null, leadType: null);
    }
    if (lower == 'hot lead' || lower == 'hot') {
      return (status: null, leadType: 'Hot');
    }
    return (status: _selectedTab, leadType: null);
  }

  String? _statusFilterForTab(String tab) {
    if (tab == 'All' || _isLostStatus(tab)) return null;
    return tab;
  }

  int _tabCount(LeadProvider provider, String tab) {
    final lower = tab.trim().toLowerCase();
    if (lower == 'all') {
      return provider.totalLeads;
    }
    if (lower == 'hot lead' || lower == 'hot') {
      return provider.leads.where(_isHotTemperature).length;
    }

    var total = 0;
    for (final status in provider.statusNames) {
      if (_tabMatchesLeadStatus(tab, status)) {
        total += provider.countForStatus(status);
      }
    }
    if (total > 0) return total;

    return provider.leads
        .where((lead) => _tabMatchesLeadStatus(tab, lead.status))
        .length;
  }

  bool _tabMatchesLeadStatus(String tab, String leadStatus) {
    final selected = tab.trim().toLowerCase();
    final lead = leadStatus.trim().toLowerCase();
    if (selected.isEmpty || lead.isEmpty) return false;
    if (selected == lead) return true;

    String compact(String value) => value.replaceAll(RegExp(r'[\s\-_/]+'), '');
    if (compact(selected) == compact(lead)) return true;

    if (selected.contains('not interested')) {
      return lead.contains('not interested');
    }
    if (selected == 'interested' || selected == 'interested lead') {
      return lead.contains('interested') && !lead.contains('not interested');
    }
    if (selected.contains('new')) {
      return lead == 'new' || lead.contains('new lead') || lead.contains('new');
    }
    if (selected.contains('site visit') && selected.contains('schedule')) {
      return lead.contains('site visit') &&
          (lead.contains('schedule') || lead.contains('scheduled'));
    }
    if (selected.contains('site visit') && selected.contains('done')) {
      return lead.contains('site visit') &&
          (lead.contains('done') || lead.contains('complete'));
    }
    if (selected.contains('re-visit') || selected.contains('revisit')) {
      return (lead.contains('re-visit') ||
              lead.contains('revisit') ||
              lead.contains('re visit')) &&
          (lead.contains('done') || lead.contains('complete'));
    }
    if (selected.contains('follow up') || selected.contains('follow-up')) {
      return lead.contains('follow up') || lead.contains('follow-up');
    }
    if (selected.contains('obm')) {
      return lead.contains('obm');
    }
    if (selected.contains('booking')) {
      return lead.contains('booking') ||
          lead.contains('booked') ||
          lead.contains('converted');
    }

    return lead.contains(selected) || selected.contains(lead);
  }

  bool _isLostStatus(String status) {
    return status.trim().toLowerCase().contains('lost');
  }

  Color? _tabTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('hot')) return const Color(0xFFDC2626);
    if (lower.contains('contact') || lower.contains('follow')) {
      return AppColors.orangeDeep;
    }
    if (lower.contains('visit') || lower.contains('obm')) {
      return AppColors.blueBright;
    }
    if (lower.contains('book')) return AppColors.greenDeep;
    if (lower.contains('not interest')) return const Color(0xFF7C3AED);
    if (lower.contains('interest') || lower.contains('qualif')) {
      return AppColors.purpleDeep;
    }
    if (lower.contains('pending') || lower.contains('new')) {
      return AppColors.blueBright;
    }
    return AppColors.textSecondary;
  }

  Color? _tabBackgroundColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('hot')) return const Color(0xFFFEE2E2);
    if (lower.contains('contact') || lower.contains('follow')) {
      return AppColors.orangeSoft;
    }
    if (lower.contains('visit') || lower.contains('obm')) {
      return AppColors.windowBlue;
    }
    if (lower.contains('book')) return AppColors.greenBg;
    if (lower.contains('not interest')) return const Color(0xFFF3E8FF);
    if (lower.contains('interest') || lower.contains('qualif')) {
      return AppColors.purpleSoft;
    }
    if (lower.contains('pending') || lower.contains('new')) {
      return AppColors.windowBlue;
    }
    return AppColors.white;
  }
}

TextStyle get _professionalLeadValueStyle => GoogleFonts.inter(
  fontSize: 12.sp,
  fontWeight: FontWeight.w600,
  color: const Color(0xFF111A32),
);

TextStyle get _professionalLeadLabelStyle =>
    GoogleFonts.inter(fontSize: 10.5.sp, color: const Color(0xFF667085));

TextStyle get _professionalLeadFooterValueStyle => GoogleFonts.inter(
  fontSize: 10.5.sp,
  fontWeight: FontWeight.w700,
  color: const Color(0xFF263248),
);

class _CompactLeadBadge extends StatelessWidget {
  const _CompactLeadBadge({
    required this.text,
    required this.foreground,
    required this.background,
    this.borderColor,
  });

  final String text;
  final Color foreground;
  final Color background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 88.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _LeadCardDetail extends StatelessWidget {
  const _LeadCardDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF475467)),
        SizedBox(width: 6.w),
        Flexible(
          child: Column(
            crossAxisAlignment: alignEnd
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: const Color(0xFF667085),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111A32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeadUpdateOption {
  const _LeadUpdateOption({required this.id, required this.label});

  final String id;
  final String label;

  factory _LeadUpdateOption.fromMap(Map<dynamic, dynamic> map) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    return _LeadUpdateOption(
      id: read(const ['id', '_id', 'value', 'slug', 'key', 'masterValueId']),
      label: read(const [
        'name',
        'label',
        'title',
        'displayName',
        'value',
        'masterValue',
      ]),
    );
  }
}

List<_LeadUpdateOption> _updateOptionList(Object? source) {
  if (source is List) {
    return source
        .map((item) {
          if (item is String) {
            return _LeadUpdateOption(id: item, label: item);
          }
          if (item is Map) return _LeadUpdateOption.fromMap(item);
          return const _LeadUpdateOption(id: '', label: '');
        })
        .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
        .toList();
  }
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'values',
      'masterValues',
    ]) {
      final options = _updateOptionList(source[key]);
      if (options.isNotEmpty) return options;
    }
  }
  return const [];
}

class _LeadUpdateDialog extends StatefulWidget {
  const _LeadUpdateDialog({
    required this.leads,
    required this.statuses,
    required this.temperatures,
  });

  final List<LeadModel> leads;
  final List<_LeadUpdateOption> statuses;
  final List<_LeadUpdateOption> temperatures;

  @override
  State<_LeadUpdateDialog> createState() => _LeadUpdateDialogState();
}

class _LeadUpdateDialogState extends State<_LeadUpdateDialog> {
  static const _budgets = [
    '50 Lakh - 75 Lakh',
    '75 Lakh - 1 Cr',
    '1 Cr - 1.5 Cr',
    '1.5 Cr - 2 Cr',
    '2 Cr - 3 Cr',
    '3 Cr+',
  ];
  static const _configurations = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '5 BHK',
    'Studio',
    'Penthouse',
  ];

  late final TextEditingController _remarkController;
  String? _statusId;
  String? _temperatureId;
  String? _budget;
  String? _configuration;
  DateTime? _followUpDate;
  TimeOfDay? _followUpTime;
  bool _saving = false;
  String? _error;

  LeadModel get _first => widget.leads.first;
  bool get _isSingle => widget.leads.length == 1;

  @override
  void initState() {
    super.initState();
    final raw = _first.raw ?? const <String, dynamic>{};
    final requirement = raw['requirement'] is Map
        ? Map<String, dynamic>.from(raw['requirement'] as Map)
        : const <String, dynamic>{};
    String? text(Object? value) {
      final result = value?.toString().trim() ?? '';
      return result.isEmpty || result == '-' ? null : result;
    }

    _statusId = _isSingle ? text(raw['statusId']) : null;
    _temperatureId = _isSingle ? text(raw['temperatureId']) : null;
    _budget = _isSingle ? text(requirement['budgetRange']) : null;
    _configuration = _isSingle ? text(requirement['configuration']) : null;
    _remarkController = TextEditingController(
      text: _isSingle ? text(raw['remarks']) ?? '' : '',
    );
    final followUp = _isSingle
        ? DateTime.tryParse(text(raw['nextFollowUpAt']) ?? '')?.toLocal()
        : null;
    if (followUp != null) {
      _followUpDate = followUp;
      _followUpTime = TimeOfDay.fromDateTime(followUp);
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  String? _validOption(String? value, List<_LeadUpdateOption> options) {
    return options.any((option) => option.id == value) ? value : null;
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null) setState(() => _followUpDate = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _followUpTime ?? TimeOfDay.now(),
    );
    if (value != null) setState(() => _followUpTime = value);
  }

  Future<void> _submit() async {
    final body = <String, dynamic>{
      if (_statusId != null) 'statusId': _statusId,
      if (_temperatureId != null) 'temperatureId': _temperatureId,
      if (_budget != null) 'budgetRange': _budget,
      if (_configuration != null) 'configuration': _configuration,
      if (_remarkController.text.trim().isNotEmpty)
        'remarks': _remarkController.text.trim(),
      if (_followUpDate != null && _followUpTime != null)
        'nextFollowUpAt': DateTime(
          _followUpDate!.year,
          _followUpDate!.month,
          _followUpDate!.day,
          _followUpTime!.hour,
          _followUpTime!.minute,
        ).toUtc().toIso8601String(),
    };
    if (body.isEmpty) {
      setState(() => _error = 'Choose at least one field to update.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final provider = context.read<LeadProvider>();
    var updated = 0;
    for (final lead in widget.leads) {
      final id = lead.id;
      if (id == null || id.isEmpty) continue;
      final response = await provider.updateLeadFromApi(leadId: id, body: body);
      if (response != null) updated++;
    }
    if (!mounted) return;
    if (updated == widget.leads.length) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated == 1
                ? 'Lead updated successfully.'
                : '$updated leads updated successfully.',
          ),
        ),
      );
    } else {
      setState(() {
        _saving = false;
        _error =
            provider.error ??
            'Updated $updated of ${widget.leads.length} leads.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720.w, maxHeight: 760.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 18.h, 12.w, 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update reminder, status & remark',
                          style: GoogleFonts.inter(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Update only the fields you fill. ${widget.leads.length} selected lead${widget.leads.length == 1 ? '' : 's'} will receive the updates.',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(22.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _responsiveFields([
                      _optionField(
                        'Status',
                        _validOption(_statusId, widget.statuses),
                        widget.statuses,
                        (value) => setState(() => _statusId = value),
                      ),
                      _optionField(
                        'Type',
                        _validOption(_temperatureId, widget.temperatures),
                        widget.temperatures,
                        (value) => setState(() => _temperatureId = value),
                      ),
                    ]),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFDCE3ED)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Follow-up reminder',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _responsiveFields([
                            _pickerField(
                              'Follow-up date',
                              _followUpDate == null
                                  ? 'dd/mm/yyyy'
                                  : '${_followUpDate!.day.toString().padLeft(2, '0')}/${_followUpDate!.month.toString().padLeft(2, '0')}/${_followUpDate!.year}',
                              Icons.calendar_today_outlined,
                              _pickDate,
                            ),
                            _pickerField(
                              'Follow-up time',
                              _followUpTime?.format(context) ?? 'Select time',
                              Icons.schedule_rounded,
                              _pickTime,
                            ),
                          ]),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _responsiveFields([
                      _stringDropdown('Budget', _budget, _budgets, (value) {
                        setState(() => _budget = value);
                      }),
                      _stringDropdown(
                        'Configuration',
                        _configuration,
                        _configurations,
                        (value) => setState(() => _configuration = value),
                      ),
                    ]),
                    SizedBox(height: 16.h),
                    _textField('Remark', _remarkController, maxLines: 3),
                    if (_error != null) ...[
                      SizedBox(height: 12.h),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeStrong,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 13.h,
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Update Lead'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responsiveFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 520;
        final width = twoColumns
            ? (constraints.maxWidth - 14.w) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 14.w,
          runSpacing: 14.h,
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  Widget _fieldLabel(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }

  InputDecoration get _decoration => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFD6DFEB)),
    ),
  );

  Widget _optionField(
    String label,
    String? value,
    List<_LeadUpdateOption> options,
    ValueChanged<String?> onChanged,
  ) {
    return _fieldLabel(
      label,
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        hint: Text(options.isEmpty ? 'No options available' : 'Select $label'),
        decoration: _decoration,
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option.id,
                child: Text(option.label, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: options.isEmpty ? null : onChanged,
      ),
    );
  }

  Widget _stringDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final values = <String>{...options, ?value}.toList();
    return _fieldLabel(
      label,
      DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        hint: Text('Select $label'),
        decoration: _decoration,
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return _fieldLabel(
      label,
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: _decoration.copyWith(hintText: 'Enter $label'),
      ),
    );
  }

  Widget _pickerField(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return _fieldLabel(
      label,
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: InputDecorator(
          decoration: _decoration.copyWith(prefixIcon: Icon(icon, size: 19.sp)),
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _AddLeadRemarkDialog extends StatefulWidget {
  const _AddLeadRemarkDialog({required this.lead});

  final LeadModel lead;

  @override
  State<_AddLeadRemarkDialog> createState() => _AddLeadRemarkDialogState();
}

class _AddLeadRemarkDialogState extends State<_AddLeadRemarkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _remarkController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;
  bool _showingHistory = false;
  bool _historyLoading = false;
  List<_RemarkHistoryEntry> _historyEntries = const [];
  String? _historyError;
  String? _error;

  Future<void> _openHistory() async {
    setState(() => _showingHistory = true);
    if (_historyEntries.isNotEmpty || _historyLoading) return;
    setState(() {
      _historyLoading = true;
      _historyError = null;
    });
    final provider = context.read<LeadProvider>();
    final response = await provider.fetchFollowUps(limit: 500);
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _historyLoading = false;
        _historyError = provider.error ?? 'Unable to load remark history.';
      });
      return;
    }
    final leadId = widget.lead.id ?? '';
    final entries =
        _remarkMaps(response.data)
            .map(_RemarkHistoryEntry.fromMap)
            .where((entry) => entry.leadId == leadId && entry.hasContent)
            .toList()
          ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    setState(() {
      _historyEntries = entries;
      _historyLoading = false;
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null && mounted) setState(() => _time = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final leadId = widget.lead.id!;
    final raw = widget.lead.raw ?? const <String, dynamic>{};
    final assignedToId =
        [
              raw['assignedToId'],
              raw['ownerId'],
              raw['telecallerId'],
              raw['fieldExecutiveId'],
            ]
            .where((value) => value != null && value.toString().isNotEmpty)
            .firstOrNull;
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    final response = await context.read<LeadProvider>().createFollowUp(
      leadId: leadId,
      body: {
        'followUpType': 'Call',
        'remarks': _remarkController.text.trim(),
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'status': 'Scheduled',
        if (assignedToId != null) 'assignedToId': assignedToId.toString(),
      },
    );
    if (!mounted) return;
    if (response != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remark added successfully.')),
      );
    } else {
      setState(() {
        _saving = false;
        _error = context.read<LeadProvider>().error ?? 'Unable to add remark.';
      });
    }
  }

  Widget _historyBody() {
    if (_historyLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_historyError!, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: _openHistory,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_historyEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 38.sp, color: Colors.grey),
            SizedBox(height: 10.h),
            const Text('No remark history available.'),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      itemCount: _historyEntries.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, index) =>
          _RemarkHistoryCard(entry: _historyEntries[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFD8E0EC)),
      ),
    );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_comment_outlined,
                      color: AppColors.orangeStrong,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _showingHistory ? 'Remark History' : 'Add Remark',
                        style: GoogleFonts.inter(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  widget.lead.titleWithId,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving
                              ? null
                              : () => setState(() => _showingHistory = false),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: !_showingHistory
                                ? AppColors.orangeStrong
                                : Colors.white,
                            foregroundColor: !_showingHistory
                                ? Colors.white
                                : AppColors.orangeStrong,
                            side: const BorderSide(
                              color: AppColors.orangeStrong,
                            ),
                          ),
                          icon: Icon(Icons.add_comment_outlined, size: 16.sp),
                          label: Text(
                            'Add Remark',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _openHistory,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _showingHistory
                                ? AppColors.orangeStrong
                                : Colors.white,
                            foregroundColor: _showingHistory
                                ? Colors.white
                                : AppColors.orangeStrong,
                            side: const BorderSide(
                              color: AppColors.orangeStrong,
                            ),
                          ),
                          icon: Icon(Icons.history_rounded, size: 16.sp),
                          label: Text(
                            'Remark History',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_showingHistory) ...[
                  SizedBox(height: 18.h),
                  TextFormField(
                    controller: _remarkController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: decoration('Remark'),
                    validator: (value) => value?.trim().isEmpty ?? true
                        ? 'Please enter a remark.'
                        : null,
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(48.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.schedule_rounded),
                          label: Text(_time.format(context)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(48.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: 10.w),
                      ElevatedButton.icon(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeStrong,
                          foregroundColor: Colors.white,
                          minimumSize: Size(130.w, 48.h),
                        ),
                        icon: _saving
                            ? SizedBox(
                                width: 17.w,
                                height: 17.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_outlined),
                        label: const Text('Add Remark'),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: 14.h),
                  SizedBox(height: 420.h, child: _historyBody()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemarkHistorySheet extends StatefulWidget {
  const _RemarkHistorySheet({required this.leadId, required this.leadName});

  final String leadId;
  final String leadName;

  @override
  State<_RemarkHistorySheet> createState() => _RemarkHistorySheetState();
}

class _RemarkHistorySheetState extends State<_RemarkHistorySheet> {
  bool _loading = true;
  String? _error;
  List<_RemarkHistoryEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<LeadProvider>();
    final response = await provider.fetchFollowUps(limit: 500);
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loading = false;
        _error = provider.error ?? 'Unable to load remark history.';
      });
      return;
    }
    final entries =
        _remarkMaps(response.data)
            .map(_RemarkHistoryEntry.fromMap)
            .where((entry) => entry.leadId == widget.leadId && entry.hasContent)
            .toList()
          ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .82,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 10.w, 12.h),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: AppColors.orangeStrong),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remark History',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            widget.leadName,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 12.h),
              OutlinedButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 38.sp, color: Colors.grey),
            SizedBox(height: 10.h),
            const Text('No remark history available.'),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: _entries.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, index) => _RemarkHistoryCard(entry: _entries[index]),
    );
  }
}

class _RemarkHistoryEntry {
  const _RemarkHistoryEntry({
    required this.leadId,
    required this.remark,
    required this.notes,
    required this.status,
    required this.addedBy,
    required this.scheduledAt,
    required this.createdAt,
  });

  final String leadId;
  final String remark;
  final String notes;
  final String status;
  final String addedBy;
  final DateTime? scheduledAt;
  final DateTime? createdAt;

  bool get hasContent => remark.isNotEmpty || notes.isNotEmpty;
  DateTime get sortDate => createdAt ?? scheduledAt ?? DateTime(1970);

  factory _RemarkHistoryEntry.fromMap(Map<String, dynamic> map) {
    final lead = map['lead'] is Map
        ? Map<String, dynamic>.from(map['lead'] as Map)
        : const <String, dynamic>{};
    String read(List<String> keys, [String fallback = '']) {
      for (final key in keys) {
        final value = map[key] ?? lead[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return fallback;
    }

    DateTime? date(List<String> keys) =>
        DateTime.tryParse(read(keys))?.toLocal();
    final directLeadId = map['leadId'] ?? map['lead_id'];
    final nestedLeadId = lead['id'] ?? lead['_id'] ?? lead['leadId'];
    return _RemarkHistoryEntry(
      leadId: (directLeadId ?? nestedLeadId ?? '').toString(),
      remark: read(const ['remarks', 'remark']),
      notes: read(const ['notes']),
      status: read(const ['statusName', 'status'], 'Not set'),
      addedBy: read(const [
        'assignedToName',
        'createdByName',
        'ownerName',
        'assignedToId',
      ], 'Not available'),
      scheduledAt: date(const ['scheduledAt', 'followUpDate']),
      createdAt: date(const ['createdAt', 'created_at']),
    );
  }
}

List<Map<String, dynamic>> _remarkMaps(Object? source) {
  if (source is List) {
    return source
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  if (source is Map) {
    for (final key in const [
      'followUps',
      'follow_ups',
      'items',
      'results',
      'rows',
      'data',
    ]) {
      final result = _remarkMaps(source[key]);
      if (result.isNotEmpty) return result;
    }
  }
  return const [];
}

class _RemarkHistoryCard extends StatelessWidget {
  const _RemarkHistoryCard({required this.entry});

  final _RemarkHistoryEntry entry;

  String _date(DateTime? value) {
    if (value == null) return 'Not available';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} '
        '$hour:${value.minute.toString().padLeft(2, '0')} ${value.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDCE3ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.addedBy,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              _CompactLeadBadge(
                text: entry.status,
                foreground: AppColors.orangeDeep,
                background: const Color(0xFFFFF4ED),
                borderColor: const Color(0xFFFFD8C2),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _date(entry.createdAt),
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),
          if (entry.remark.isNotEmpty)
            Text(
              entry.remark,
              style: GoogleFonts.inter(fontSize: 14.sp, height: 1.4),
            ),
          if (entry.notes.isNotEmpty && entry.notes != entry.remark) ...[
            SizedBox(height: 8.h),
            Text(
              'Notes: ${entry.notes}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF475467),
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15.sp, color: Colors.grey),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'Scheduled: ${_date(entry.scheduledAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
