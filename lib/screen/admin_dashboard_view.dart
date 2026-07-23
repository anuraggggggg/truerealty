import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/notification_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  static const List<_DashboardMetric> _topMetrics = [
    _DashboardMetric(
      icon: Icons.groups_2_outlined,
      title: 'Total Leads',
      value: '0',
      iconColor: AppColors.navy,
    ),
    _DashboardMetric(
      icon: Icons.person_add_alt_1_outlined,
      title: 'Follow-ups Due',
      value: '0',
      iconColor: Color(0xFF10B981),
    ),
    _DashboardMetric(
      icon: Icons.assignment_ind_outlined,
      title: 'Overdue Follow-ups',
      value: '0',
      iconColor: AppColors.orangeDeep,
    ),
    _DashboardMetric(
      icon: Icons.person_off_outlined,
      title: 'Site Visits Pending',
      value: '0',
      iconColor: Color(0xFFDC2626),
    ),
    _DashboardMetric(
      icon: Icons.calendar_month_outlined,
      title: 'Site Visits Completed',
      value: '0',
      iconColor: Color(0xFF4C6793),
    ),
    _DashboardMetric(
      icon: Icons.event_busy_outlined,
      title: 'Bookings Today',
      value: '0',
      iconColor: Color(0xFFB91C1C),
    ),
  ];

  static const List<_DashboardMetric> _bottomMetrics = [
    _DashboardMetric(
      icon: Icons.calendar_today_outlined,
      title: 'Teams Need Attention',
      value: '0',
      iconColor: Color(0xFF2563EB),
    ),
    _DashboardMetric(
      icon: Icons.verified_user_outlined,
      title: 'Visit Execution Pending',
      value: '0',
      iconColor: AppColors.navy,
    ),
    _DashboardMetric(
      icon: Icons.currency_rupee,
      title: 'Visit Execution Overdue',
      value: '0',
      iconColor: AppColors.orangeDeep,
    ),
    _DashboardMetric(
      icon: Icons.check_circle_outline,
      title: 'Total Teams',
      value: '0',
      iconColor: Color(0xFF10B981),
    ),
  ];

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  static const String _allFilterValue = 'all';
  static const List<_FilterOption> _dateRangeOptions = [
    _FilterOption(value: 'today', label: 'Today'),
    _FilterOption(value: 'week', label: 'This Week'),
    _FilterOption(value: 'month', label: 'This Month'),
    _FilterOption(value: 'quarter', label: 'This Quarter'),
    _FilterOption(value: 'year', label: 'This Year'),
    _FilterOption(value: 'custom', label: 'Custom Range'),
  ];
  static const List<_FilterOption> _leadSourceOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Source'),
    _FilterOption(value: 'MagicBricks', label: 'MagicBricks'),
    _FilterOption(value: '99Acres', label: '99Acres'),
    _FilterOption(value: 'Google Ads', label: 'Google Ads'),
    _FilterOption(value: 'Meta Ads', label: 'Meta Ads'),
    _FilterOption(value: 'Referral', label: 'Referral'),
  ];
  static const List<_FilterOption> _leadStatusOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Status'),
    _FilterOption(value: 'New Lead', label: 'New Lead'),
    _FilterOption(value: 'Contacted', label: 'Contacted'),
    _FilterOption(value: 'Interested', label: 'Interested'),
    _FilterOption(value: 'Site Visit Scheduel', label: 'Site Visit Scheduled'),
    _FilterOption(value: 'Site Visit Done', label: 'Site Visit Done'),
    _FilterOption(value: 'Re-Visit Done', label: 'Re-Visit Done'),
    _FilterOption(value: 'Booked', label: 'Booked'),
  ];
  static const List<_FilterOption> _leadTypeOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Lead Types'),
    _FilterOption(value: 'Hot', label: 'Hot'),
    _FilterOption(value: 'Warm', label: 'Warm'),
    _FilterOption(value: 'Cold', label: 'Cold'),
  ];
  static const List<_FilterOption> _propertyTypeOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Property Type'),
    _FilterOption(value: 'Apartment', label: 'Apartment'),
    _FilterOption(value: 'Villa', label: 'Villa'),
    _FilterOption(value: 'Plot', label: 'Plot'),
    _FilterOption(value: 'Commercial', label: 'Commercial'),
  ];
  static const List<_FilterOption> _configurationOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Configuration'),
    _FilterOption(value: '1 BHK', label: '1 BHK'),
    _FilterOption(value: '2 BHK', label: '2 BHK'),
    _FilterOption(value: '3 BHK', label: '3 BHK'),
    _FilterOption(value: '4 BHK', label: '4 BHK'),
  ];
  static const List<_FilterOption> _assignedToOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Assigned To'),
    _FilterOption(value: 'telecaller', label: 'Telecaller'),
    _FilterOption(value: 'fieldExecutive', label: 'Field Executive'),
    _FilterOption(value: 'salesManager', label: 'Sales Manager'),
  ];
  static const List<_FilterOption> _teamOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Teams'),
    _FilterOption(value: 'Sales Alpha', label: 'Sales Alpha'),
    _FilterOption(value: 'Sales Beta', label: 'Sales Beta'),
  ];
  static const List<_FilterOption> _areaOptions = [
    _FilterOption(value: _allFilterValue, label: 'All Areas'),
    _FilterOption(value: 'Mumbai', label: 'Mumbai'),
    _FilterOption(value: 'Gurgaon', label: 'Gurgaon'),
    _FilterOption(value: 'Noida', label: 'Noida'),
    _FilterOption(value: 'Greater Noida', label: 'Greater Noida'),
  ];
  static const List<_FilterOption> _slaStatusOptions = [
    _FilterOption(value: _allFilterValue, label: 'All SLA Statuses'),
    _FilterOption(value: 'On Track', label: 'On Track'),
    _FilterOption(value: 'At Risk', label: 'At Risk'),
    _FilterOption(value: 'Overdue', label: 'Overdue'),
  ];

  Object? _dashboardData;
  Object? _currentEmployee;
  int _notificationCount = 0;
  bool _isLoadingDashboard = false;
  bool _showAdvancedFilters = false;
  String _selectedDateRange = 'today';
  DateTimeRange? _customDateRange;
  String _selectedLeadSource = _allFilterValue;
  String _selectedLeadStatus = _allFilterValue;
  String _selectedLeadType = _allFilterValue;
  String _selectedPropertyType = _allFilterValue;
  String _selectedConfiguration = _allFilterValue;
  String _selectedAssignedTo = _allFilterValue;
  String _selectedTeam = _allFilterValue;
  String _selectedArea = _allFilterValue;
  String _selectedSlaStatus = _allFilterValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDashboardApis();
      }
    });
  }

  Future<bool> _loadDashboardApis() async {
    setState(() => _isLoadingDashboard = true);

    final dashboardProvider = context.read<DashboardProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final employeeProvider = context.read<EmployeeProvider>();

    final selectedRange = _dashboardDateRange();
    final dashboardResponse = await dashboardProvider.fetchAdminDashboard(
      range: _selectedDateRange,
      dateFrom: _dateForApi(selectedRange.start),
      dateTo: _dateForApi(selectedRange.end),
      source: _apiFilterValue(_selectedLeadSource),
      status: _apiFilterValue(_selectedLeadStatus),
      leadType: _apiFilterValue(_selectedLeadType),
      propertyType: _apiFilterValue(_selectedPropertyType),
      configuration: _apiFilterValue(_selectedConfiguration),
      assignedTo: _apiFilterValue(_selectedAssignedTo),
      team: _apiFilterValue(_selectedTeam),
      area: _apiFilterValue(_selectedArea),
      slaStatus: _apiFilterValue(_selectedSlaStatus),
    );
    final notificationResponse = await notificationProvider.fetchNotifications(
      unreadOnly: true,
      limit: 20,
    );
    final employeeResponse = await employeeProvider.fetchCurrentEmployee();

    if (!mounted) {
      return false;
    }

    setState(() {
      _dashboardData = dashboardResponse?.data;
      _currentEmployee = employeeResponse?.data;
      _notificationCount = _countUnread(notificationResponse?.data);
      _isLoadingDashboard = false;
    });
    return dashboardResponse != null;
  }

  List<_DashboardMetric> get _topMetrics {
    return [
      _metricWithApiValue(AdminDashboardView._topMetrics[0], const [
        'totalLeads',
        'total_leads',
        'leadsTotal',
        'leadCount',
      ]),
      _metricWithApiValue(AdminDashboardView._topMetrics[1], const [
        'followUpsDueToday',
        'follow_ups_due_today',
      ]),
      _metricWithApiValue(AdminDashboardView._topMetrics[2], const [
        'overdueFollowUps',
        'overdue_follow_ups',
      ]),
      _metricWithApiValue(AdminDashboardView._topMetrics[3], const [
        'siteVisitsPendingToday',
        'site_visits_pending_today',
      ]),
      _metricWithApiValue(AdminDashboardView._topMetrics[4], const [
        'siteVisitsCompletedToday',
        'site_visits_completed_today',
      ]),
      _metricWithApiValue(AdminDashboardView._topMetrics[5], const [
        'bookingsDoneToday',
        'bookings_done_today',
      ]),
    ];
  }

  List<_DashboardMetric> get _bottomMetrics {
    return [
      _metricWithApiValue(AdminDashboardView._bottomMetrics[0], const [
        'teamsNeedingAttention',
        'teams_needing_attention',
      ]),
      _metricWithApiValue(AdminDashboardView._bottomMetrics[1], const [
        'pending',
      ]),
      _metricWithApiValue(AdminDashboardView._bottomMetrics[2], const [
        'overdue',
      ]),
      _metricWithApiValue(AdminDashboardView._bottomMetrics[3], const [
        'totalTeams',
        'total_teams',
      ]),
    ];
  }

  _DashboardMetric _metricWithApiValue(
    _DashboardMetric fallback,
    List<String> keys,
  ) {
    final value = _findFirstValue(_dashboardData, keys);
    if (value == null) {
      return fallback;
    }

    return fallback.copyWith(value: _formatMetricValue(value));
  }

  String get _filterLabel {
    if (_selectedDateRange == 'custom' && _customDateRange != null) {
      return '${_shortDate(_customDateRange!.start)} - '
          '${_shortDate(_customDateRange!.end)}';
    }
    return _labelForValue(_dateRangeOptions, _selectedDateRange);
  }

  int get _activeFilterCount {
    var count = 0;
    if (_selectedDateRange != 'today') count++;
    for (final value in [
      _selectedLeadSource,
      _selectedLeadStatus,
      _selectedLeadType,
      _selectedPropertyType,
      _selectedConfiguration,
      _selectedAssignedTo,
      _selectedTeam,
      _selectedArea,
      _selectedSlaStatus,
    ]) {
      if (value != _allFilterValue) {
        count++;
      }
    }
    return count;
  }

  String? _apiFilterValue(String value) {
    return value == _allFilterValue ? null : value;
  }

  String _labelForValue(List<_FilterOption> options, String value) {
    return options
        .firstWhere(
          (option) => option.value == value,
          orElse: () => options.first,
        )
        .label;
  }

  Future<void> _applyDashboardFilters() async {
    if (_selectedDateRange == 'custom' && _customDateRange == null) {
      await _pickCustomDateRange();
      if (!mounted || _customDateRange == null) {
        return;
      }
    }
    final applied = await _loadDashboardApis();
    if (!mounted) {
      return;
    }
    setState(() => _showAdvancedFilters = false);
    _showApiMessage(
      applied
          ? 'Filters applied.'
          : context.read<DashboardProvider>().error ??
                'Unable to apply filters.',
    );
  }

  Future<void> _resetDashboardFilters() async {
    setState(() {
      _selectedDateRange = 'today';
      _customDateRange = null;
      _selectedLeadSource = _allFilterValue;
      _selectedLeadStatus = _allFilterValue;
      _selectedLeadType = _allFilterValue;
      _selectedPropertyType = _allFilterValue;
      _selectedConfiguration = _allFilterValue;
      _selectedAssignedTo = _allFilterValue;
      _selectedTeam = _allFilterValue;
      _selectedArea = _allFilterValue;
      _selectedSlaStatus = _allFilterValue;
    });
    final reset = await _loadDashboardApis();
    if (!mounted) {
      return;
    }
    _showApiMessage(reset ? 'Filters reset.' : 'Unable to reset filters.');
  }

  Future<void> _pickCustomDateRange() async {
    final today = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 1, 12, 31),
      initialDateRange:
          _customDateRange ?? DateTimeRange(start: today, end: today),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.orangeAccent),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateRange = 'custom';
      _customDateRange = picked;
    });
  }

  String _dateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTimeRange _dashboardDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedDateRange) {
      case 'custom':
        return _customDateRange ?? DateTimeRange(start: today, end: today);
      case 'week':
        final start = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 6)),
        );
      case 'month':
        return DateTimeRange(
          start: DateTime(today.year, today.month),
          end: DateTime(today.year, today.month + 1, 0),
        );
      case 'quarter':
        final startMonth = ((today.month - 1) ~/ 3) * 3 + 1;
        return DateTimeRange(
          start: DateTime(today.year, startMonth),
          end: DateTime(today.year, startMonth + 3, 0),
        );
      case 'year':
        return DateTimeRange(
          start: DateTime(today.year),
          end: DateTime(today.year, 12, 31),
        );
      case 'today':
      default:
        return DateTimeRange(start: today, end: today);
    }
  }

  String _shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _openNotifications() async {
    final provider = context.read<NotificationProvider>();
    final response = await provider.fetchNotifications(limit: 20);

    if (!mounted) {
      return;
    }

    final notifications = _extractList(response?.data);
    setState(() => _notificationCount = _countUnread(response?.data));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (sheetContext) {
        return _NotificationsSheet(
          notifications: notifications,
          error: provider.error,
          onCountChanged: (count) {
            if (mounted) {
              setState(() => _notificationCount = count);
            }
          },
        );
      },
    );
  }

  Future<void> _openProfile() async {
    final provider = context.read<EmployeeProvider>();
    final response = await provider.fetchCurrentEmployee();

    if (!mounted) {
      return;
    }

    setState(() => _currentEmployee = response?.data ?? _currentEmployee);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (_) {
        return _ProfileSheet(
          profile: response?.data ?? _currentEmployee,
          error: provider.error,
        );
      },
    );
  }

  Future<void> _openGlobalSearch() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      builder: (_) => const _GlobalSearchSheet(),
    );
  }

  Future<void> _openQuickCreateLead() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateLeadDialog(),
    );

    if (result == true && mounted) {
      await _loadDashboardApis();
    }
  }

  void _handleQuickAction(String label) {
    switch (label) {
      case 'Add New Lead':
        _openQuickCreateLead();
        break;
      case 'Import Leads':
        _showApiMessage(
          'Lead import API is integrated. Build the import form to send rows.',
        );
        break;
      case 'Assign Leads':
        Navigator.of(context).pushNamed(AppRouter.assignLeads);
        break;
      case 'Create Task':
        Navigator.of(context).pushNamed(AppRouter.tasks);
        break;
      case 'Schedule Visit':
        Navigator.of(context).pushNamed(AppRouter.siteVisits);
        break;
      case 'Send Notification':
        _openNotifications();
        break;
      case 'View Reports':
        Navigator.of(context).pushNamed(AppRouter.reports);
        break;
    }
  }

  void _showApiMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.15)),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 88.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHero(
                  onMenuTap: widget.onMenuTap,
                  onSearchTap: _openGlobalSearch,
                  onNotificationTap: _openNotifications,
                  onProfileTap: _openProfile,
                  notificationCount: _notificationCount,
                  profileName: _profileName(_currentEmployee),
                  isLoading: _isLoadingDashboard,
                ),
                Transform.translate(
                  offset: Offset(0, -34.h),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(26.r),
                        topRight: Radius.circular(26.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AdvancedFiltersPanel(
                          isExpanded: _showAdvancedFilters,
                          activeCount: _activeFilterCount,
                          dateLabel: _filterLabel,
                          selectedDateRange: _selectedDateRange,
                          customDateRangeLabel: _customDateRange == null
                              ? null
                              : _filterLabel,
                          selectedLeadSource: _selectedLeadSource,
                          selectedLeadStatus: _selectedLeadStatus,
                          selectedLeadType: _selectedLeadType,
                          selectedPropertyType: _selectedPropertyType,
                          selectedConfiguration: _selectedConfiguration,
                          selectedAssignedTo: _selectedAssignedTo,
                          selectedTeam: _selectedTeam,
                          selectedArea: _selectedArea,
                          selectedSlaStatus: _selectedSlaStatus,
                          dateRangeOptions: _dateRangeOptions,
                          leadSourceOptions: _leadSourceOptions,
                          leadStatusOptions: _leadStatusOptions,
                          leadTypeOptions: _leadTypeOptions,
                          propertyTypeOptions: _propertyTypeOptions,
                          configurationOptions: _configurationOptions,
                          assignedToOptions: _assignedToOptions,
                          teamOptions: _teamOptions,
                          areaOptions: _areaOptions,
                          slaStatusOptions: _slaStatusOptions,
                          onToggle: () {
                            setState(
                              () =>
                                  _showAdvancedFilters = !_showAdvancedFilters,
                            );
                          },
                          onDateRangeChanged: (value) async {
                            setState(() {
                              _selectedDateRange = value;
                              if (value != 'custom') {
                                _customDateRange = null;
                              }
                            });
                            if (value == 'custom') {
                              await _pickCustomDateRange();
                            }
                          },
                          onLeadSourceChanged: (value) =>
                              setState(() => _selectedLeadSource = value),
                          onLeadStatusChanged: (value) =>
                              setState(() => _selectedLeadStatus = value),
                          onLeadTypeChanged: (value) =>
                              setState(() => _selectedLeadType = value),
                          onPropertyTypeChanged: (value) =>
                              setState(() => _selectedPropertyType = value),
                          onConfigurationChanged: (value) =>
                              setState(() => _selectedConfiguration = value),
                          onAssignedToChanged: (value) =>
                              setState(() => _selectedAssignedTo = value),
                          onTeamChanged: (value) =>
                              setState(() => _selectedTeam = value),
                          onAreaChanged: (value) =>
                              setState(() => _selectedArea = value),
                          onSlaStatusChanged: (value) =>
                              setState(() => _selectedSlaStatus = value),
                          onApply: _applyDashboardFilters,
                          onReset: _resetDashboardFilters,
                        ),
                        SizedBox(height: 20.h),
                        _MetricSection(
                          metrics: _topMetrics,
                          columns: 3,
                          itemHeight: 112.h,
                        ),
                        SizedBox(height: 8.h),
                        _MetricSection(
                          metrics: _bottomMetrics,
                          columns: 2,
                          itemHeight: 104.h,
                        ),
                        SizedBox(height: 16.h),
                        const _LeadsBySourceCard(),
                        SizedBox(height: 16.h),
                        const _LeadFunnelOverviewCard(),
                        SizedBox(height: 16.h),
                        const _SiteVisitsOverviewCard(),
                        SizedBox(height: 16.h),
                        const _SlaHealthCard(),
                        SizedBox(height: 16.h),
                        const _LiveExecutivesMapCard(),
                        SizedBox(height: 16.h),
                        const _SystemUsersCard(),
                        SizedBox(height: 16.h),
                        const _TeamPerformanceCard(),
                        SizedBox(height: 16.h),
                        _QuickActionsCard(onActionTap: _handleQuickAction),
                        SizedBox(height: 16.h),
                        const _ReportsShortcutsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: 18.h,
            child: _FloatingAddButton(onTap: _openQuickCreateLead),
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.notificationCount,
    required this.profileName,
    required this.isLoading,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final int notificationCount;
  final String? profileName;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.h,
      child: Stack(
        children: [
          Positioned(
            left: 18.w,
            right: 18.w,
            top: 18.h,
            child: Row(
              children: [
                _HeaderIconButton(icon: Icons.menu, onTap: onMenuTap),
                SizedBox(width: 12.w),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/app_icon.png',
                      width: 164.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                _HeaderIconButton(icon: Icons.search, onTap: onSearchTap),
                SizedBox(width: 14.w),
                _NotificationBell(
                  count: notificationCount,
                  onTap: onNotificationTap,
                ),
                SizedBox(width: 14.w),
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE6ECF5),
                      border: Border.all(color: AppColors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x12000000),
                          blurRadius: 8.r,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? Padding(
                            padding: EdgeInsets.all(8.r),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.navy,
                            ),
                          )
                        : Center(
                            child: Text(
                              _initials(profileName),
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12.w,
            top: 108.h,
            child: SizedBox(
              width: 220.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF49515F),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Here\'s what\'s happening with your business today.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/dashboard_headers.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 26.w,
        height: 26.w,
        child: Icon(icon, size: 23.sp, color: AppColors.navy),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 26.w,
        height: 28.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.notifications_none_outlined,
                size: 23.sp,
                color: AppColors.navy,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -1.h,
                right: -2.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.orangeDeep,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _AdvancedFiltersPanel extends StatelessWidget {
  const _AdvancedFiltersPanel({
    required this.isExpanded,
    required this.activeCount,
    required this.dateLabel,
    required this.selectedDateRange,
    required this.selectedLeadSource,
    required this.selectedLeadStatus,
    required this.selectedLeadType,
    required this.selectedPropertyType,
    required this.selectedConfiguration,
    required this.selectedAssignedTo,
    required this.selectedTeam,
    required this.selectedArea,
    required this.selectedSlaStatus,
    required this.dateRangeOptions,
    required this.leadSourceOptions,
    required this.leadStatusOptions,
    required this.leadTypeOptions,
    required this.propertyTypeOptions,
    required this.configurationOptions,
    required this.assignedToOptions,
    required this.teamOptions,
    required this.areaOptions,
    required this.slaStatusOptions,
    required this.onToggle,
    required this.onDateRangeChanged,
    required this.onLeadSourceChanged,
    required this.onLeadStatusChanged,
    required this.onLeadTypeChanged,
    required this.onPropertyTypeChanged,
    required this.onConfigurationChanged,
    required this.onAssignedToChanged,
    required this.onTeamChanged,
    required this.onAreaChanged,
    required this.onSlaStatusChanged,
    required this.onApply,
    required this.onReset,
    this.customDateRangeLabel,
  });

  final bool isExpanded;
  final int activeCount;
  final String dateLabel;
  final String? customDateRangeLabel;
  final String selectedDateRange;
  final String selectedLeadSource;
  final String selectedLeadStatus;
  final String selectedLeadType;
  final String selectedPropertyType;
  final String selectedConfiguration;
  final String selectedAssignedTo;
  final String selectedTeam;
  final String selectedArea;
  final String selectedSlaStatus;
  final List<_FilterOption> dateRangeOptions;
  final List<_FilterOption> leadSourceOptions;
  final List<_FilterOption> leadStatusOptions;
  final List<_FilterOption> leadTypeOptions;
  final List<_FilterOption> propertyTypeOptions;
  final List<_FilterOption> configurationOptions;
  final List<_FilterOption> assignedToOptions;
  final List<_FilterOption> teamOptions;
  final List<_FilterOption> areaOptions;
  final List<_FilterOption> slaStatusOptions;
  final VoidCallback onToggle;
  final ValueChanged<String> onDateRangeChanged;
  final ValueChanged<String> onLeadSourceChanged;
  final ValueChanged<String> onLeadStatusChanged;
  final ValueChanged<String> onLeadTypeChanged;
  final ValueChanged<String> onPropertyTypeChanged;
  final ValueChanged<String> onConfigurationChanged;
  final ValueChanged<String> onAssignedToChanged;
  final ValueChanged<String> onTeamChanged;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onSlaStatusChanged;
  final Future<void> Function() onApply;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDCE5F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Advanced filters',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0B2B52),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$activeCount active',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF40516A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.tune_rounded,
                  size: 18.sp,
                ),
                label: Text(isExpanded ? 'Hide' : 'Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0B2B52),
                  textStyle: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            isExpanded
                ? 'Refine dashboard by source, status, ownership, SLA, and date.'
                : 'Current range: $dateLabel',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF52647D),
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: 14.h),
            const Divider(height: 1, color: Color(0xFFE8EEF6)),
            SizedBox(height: 14.h),
            LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 360.w;
                final fieldWidth = useTwoColumns
                    ? (constraints.maxWidth - 10.w) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 12.h,
                  children: [
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Lead Source',
                      value: selectedLeadSource,
                      options: leadSourceOptions,
                      helperText: _helperText(
                        selectedLeadSource,
                        'No lead source selected',
                      ),
                      onChanged: onLeadSourceChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Lead Status',
                      value: selectedLeadStatus,
                      options: leadStatusOptions,
                      helperText: _helperText(
                        selectedLeadStatus,
                        'No lead status selected',
                      ),
                      onChanged: onLeadStatusChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Lead Type',
                      value: selectedLeadType,
                      options: leadTypeOptions,
                      helperText: _helperText(
                        selectedLeadType,
                        'No lead type selected',
                      ),
                      onChanged: onLeadTypeChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Property Type',
                      value: selectedPropertyType,
                      options: propertyTypeOptions,
                      helperText: _helperText(
                        selectedPropertyType,
                        'No property type selected',
                      ),
                      onChanged: onPropertyTypeChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Configuration',
                      value: selectedConfiguration,
                      options: configurationOptions,
                      helperText: _helperText(
                        selectedConfiguration,
                        'No configuration selected',
                      ),
                      onChanged: onConfigurationChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Assigned To',
                      value: selectedAssignedTo,
                      options: assignedToOptions,
                      helperText: _helperText(
                        selectedAssignedTo,
                        'No assigned to selected',
                      ),
                      onChanged: onAssignedToChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Team-wise',
                      value: selectedTeam,
                      options: teamOptions,
                      helperText: _helperText(
                        selectedTeam,
                        'No team-wise selected',
                      ),
                      onChanged: onTeamChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Area-wise',
                      value: selectedArea,
                      options: areaOptions,
                      helperText: _helperText(
                        selectedArea,
                        'No area-wise selected',
                      ),
                      onChanged: onAreaChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'Date Range',
                      value: selectedDateRange,
                      options: dateRangeOptions,
                      helperText: customDateRangeLabel ?? dateLabel,
                      onChanged: onDateRangeChanged,
                    ),
                    _MobileFilterDropdown(
                      width: fieldWidth,
                      title: 'SLA Status',
                      value: selectedSlaStatus,
                      options: slaStatusOptions,
                      helperText: _helperText(
                        selectedSlaStatus,
                        'No SLA status selected',
                      ),
                      onChanged: onSlaStatusChanged,
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              alignment: WrapAlignment.end,
              children: [
                _FilterActionButton(
                  label: 'Apply Filter',
                  icon: Icons.filter_alt_outlined,
                  onTap: onApply,
                  isPrimary: true,
                ),
                _FilterActionButton(
                  label: 'Reset',
                  icon: Icons.refresh_rounded,
                  onTap: onReset,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _helperText(String value, String emptyText) {
    return value == _AdminDashboardViewState._allFilterValue
        ? emptyText
        : 'Selected';
  }
}

class _MobileFilterDropdown extends StatelessWidget {
  const _MobileFilterDropdown({
    required this.width,
    required this.title,
    required this.value,
    required this.options,
    required this.helperText,
    required this.onChanged,
  });

  final double width;
  final String title;
  final String value;
  final List<_FilterOption> options;
  final String helperText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0B2B52),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 62.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: const Color(0xFFDCE5F1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: const Color(0xFF0B2B52),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          isExpanded: true,
                          isDense: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18.sp,
                            color: const Color(0xFF64748B),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF52647D),
                          ),
                          items: options
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.value,
                                  child: Text(
                                    option.label,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onChanged(value);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        helperText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
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
    );
  }
}

class _FilterActionButton extends StatefulWidget {
  const _FilterActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onTap;
  final bool isPrimary;

  @override
  State<_FilterActionButton> createState() => _FilterActionButtonState();
}

class _FilterActionButtonState extends State<_FilterActionButton> {
  bool _isRunning = false;

  Future<void> _handleTap() async {
    if (_isRunning) {
      return;
    }
    setState(() => _isRunning = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isPrimary
        ? AppColors.white
        : const Color(0xFF0F172A);
    return Material(
      color: AppColors.transparentWhite,
      child: InkWell(
        onTap: _isRunning ? null : _handleTap,
        borderRadius: BorderRadius.circular(9.r),
        child: Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.orangeAccent : AppColors.white,
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(
              color: widget.isPrimary
                  ? AppColors.orangeAccent
                  : const Color(0xFFDCE5F1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRunning)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              else
                Icon(widget.icon, size: 16.sp, color: foreground),
              SizedBox(width: 7.w),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricSection extends StatelessWidget {
  const _MetricSection({
    required this.metrics,
    required this.columns,
    required this.itemHeight,
  });

  final List<_DashboardMetric> metrics;
  final int columns;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: 10.h,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  child: _MetricCard(metric: metric, height: itemHeight),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.height});

  final _DashboardMetric metric;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 9.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE0E4EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D0F172A),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, size: 20.sp, color: metric.iconColor),
          SizedBox(height: 6.h),
          Text(
            metric.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.5.sp,
              height: 1.18,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: (metric.valueFontSize ?? 16).sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadsBySourceCard extends StatelessWidget {
  const _LeadsBySourceCard();

  static const _items = [
    _LegendItem('Referral', '1 (20.0%)', Color(0xFF8B4CCB)),
    _LegendItem('Meta Ads', '1 (20.0%)', Color(0xFFFF8A26)),
    _LegendItem('Google Ads', '1 (20.0%)', Color(0xFF3F7EE8)),
    _LegendItem('99Acres', '1 (20.0%)', Color(0xFF67C92E)),
    _LegendItem('MagicBricks', '1 (20.0%)', Color(0xFFF54747)),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Row(
        children: [
          Text(
            'Leads by Source',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF27364B),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRouter.reports),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Text(
                'View Report',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.orangeDeep,
                ),
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 132.w,
              height: 132.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(132.w, 132.w),
                    painter: _DonutChartPainter(
                      colors: _items.map((item) => item.color).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '5',
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF22324A),
                        ),
                      ),
                      Text(
                        'Total Leads',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7A8597),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                children: _items
                    .map(
                      (item) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.h),
                        child: Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF27364B),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                item.value,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6D7787),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadFunnelOverviewCard extends StatelessWidget {
  const _LeadFunnelOverviewCard();

  static const _items = [
    _LegendItem('Interested', '1 (20.0%)', Color(0xFF0D2F63)),
    _LegendItem('Booked', '1 (20.0%)', Color(0xFFFF7A1A)),
    _LegendItem('New Lead', '1 (20.0%)', Color(0xFF3665D8)),
    _LegendItem('Negotiation', '1 (20.0%)', Color(0xFF18B97E)),
    _LegendItem('Site Visit', '1 (20.0%)', Color(0xFFF54747)),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Row(
        children: [
          Text(
            'Lead Funnel Overview',
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202733),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRouter.reports),
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                'View Report',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E6CE5),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: _items
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: 9.h),
                        child: _FunnelBar(
                          color: entry.value.color,
                          widthFactor: [1.0, 0.96, 0.92, 0.88, 0.78][entry.key],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            SizedBox(height: 28.h),
            Column(
              children: _items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 7.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF232F43),
                              ),
                            ),
                          ),
                          Text(
                            item.value,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6D7787),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFD8DEE9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A0F172A),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, child],
      ),
    );
  }
}

class _SiteVisitsOverviewCard extends StatelessWidget {
  const _SiteVisitsOverviewCard();

  static const _chartPointsBlue = [
    Offset(0.18, 0.52),
    Offset(0.50, 0.52),
    Offset(0.82, 0.18),
  ];

  static const _chartPointsOrange = [
    Offset(0.18, 0.52),
    Offset(0.50, 0.52),
    Offset(0.82, 0.86),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Text(
        'Site Visits Overview',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF27364B),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            SizedBox(
              height: 170.h,
              child: CustomPaint(
                size: Size(double.infinity, 170.h),
                painter: _SiteVisitsChartPainter(
                  bluePoints: _chartPointsBlue,
                  orangePoints: _chartPointsOrange,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 8.h, 0, 16.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 24.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ['2', '1.5', '1', '0.5', '0']
                              .map(
                                (label) => Text(
                                  label,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    color: const Color(0xFF98A2B3),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: const [
                Expanded(
                  child: _MiniStatCard(
                    title: 'Scheduled',
                    value: '1',
                    background: Color(0xFFEEF5FF),
                    titleColor: Color(0xFF4A6FAF),
                    valueColor: Color(0xFF2F5DB3),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Completed',
                    value: '2',
                    background: Color(0xFFEAFBF1),
                    titleColor: Color(0xFF18A45E),
                    valueColor: Color(0xFF0D9E55),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Cancelled',
                    value: '0',
                    background: Color(0xFFFFEFEF),
                    titleColor: Color(0xFFF05C5C),
                    valueColor: Color(0xFFF54747),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: const [
                Expanded(
                  child: _MiniStatCard(
                    title: 'No-Show',
                    value: '0',
                    background: Color(0xFFFFF5E9),
                    titleColor: Color(0xFFFF8A26),
                    valueColor: Color(0xFFFF8A26),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MiniStatCard(
                    title: 'Conv. Rate',
                    value: '100.0%',
                    background: Color(0xFFF2F5FA),
                    titleColor: Color(0xFF667085),
                    valueColor: Color(0xFF22324A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlaHealthCard extends StatelessWidget {
  const _SlaHealthCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Row(
        children: [
          Text(
            'SLA Health',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF27364B),
            ),
          ),
          const Spacer(),
          Text(
            'Open Queue',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3E6CE5),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: _SlaMetricCard(
                    title: 'Breached Today',
                    tag: 'BREACHED',
                    subtitle: 'Needs manager action now',
                    value: '27',
                    background: Color(0xFFFFF0F0),
                    accent: Color(0xFFF54747),
                    tagBg: Color(0xFFFEE2E2),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SlaMetricCard(
                    title: 'At Risk',
                    tag: 'DUE SOON',
                    subtitle: 'Due in next 60 mins',
                    value: '14',
                    background: Color(0xFFFFF5E9),
                    accent: Color(0xFFFF8A26),
                    tagBg: Color(0xFFFFEDD5),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: const [
                Expanded(
                  child: _SlaMetricCard(
                    title: 'Within SLA',
                    tag: 'ON TIME',
                    subtitle: 'Across active lead queue',
                    value: '66.2%',
                    background: Color(0xFFEAFBF1),
                    accent: Color(0xFF10B981),
                    tagBg: Color(0xFFD1FAE5),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SlaMetricCard(
                    title: 'Avg First Response',
                    subtitle: '6m faster than last week',
                    value: '18m 42s',
                    background: Color(0xFFF1F5FF),
                    accent: Color(0xFF4A6FAF),
                    valueFontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveExecutivesMapCard extends StatelessWidget {
  const _LiveExecutivesMapCard();

  static const _items = [
    _ExecutiveMapItem(
      initials: 'PS',
      name: 'Priya Singh',
      area: 'Andheri East',
      statusText: 'Showing Green Heights',
      avatarColor: Color(0xFF173A6D),
    ),
    _ExecutiveMapItem(
      initials: 'AK',
      name: 'Amit Kumar',
      area: 'Bandra Kurla Complex',
      statusText: 'Meeting a new lead',
      avatarColor: Color(0xFFEF6C0F),
    ),
    _ExecutiveMapItem(
      initials: 'NV',
      name: 'Neha Verma',
      area: 'Chembur',
      statusText: 'Heading to site visit',
      avatarColor: Color(0xFFE11D48),
    ),
    _ExecutiveMapItem(
      initials: 'RS',
      name: 'Ravi Sharma',
      area: 'Ghatkopar',
      statusText: 'Follow-up on location',
      avatarColor: Color(0xFF1885D1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Text(
        'Live Executives on Map',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF173A6D),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            const _MapPreviewCard(),
            SizedBox(height: 14.h),
            ..._items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _ExecutiveListTile(item: item),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.employeeDirectory);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(42.h),
                  side: const BorderSide(color: AppColors.orangeDeep),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'View Full Map',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orangeDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemUsersCard extends StatelessWidget {
  const _SystemUsersCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Text(
        'System Users',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2A44),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: _UserStatCard(
                    icon: Icons.person_outline,
                    title: 'Total\nUsers',
                    value: '5',
                    iconColor: Color(0xFF2962FF),
                    borderColor: Color(0xFFD6E2FF),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _UserStatCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Inactive\nUsers',
                    value: '0',
                    iconColor: Color(0xFFF2553D),
                    borderColor: Color(0xFFF9D8D2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _UserStatCard(
                    icon: Icons.check_circle_outline,
                    title: 'Active\nUsers',
                    value: '5',
                    iconColor: Color(0xFF16A34A),
                    borderColor: Color(0xFFD8EFDD),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.employeeDirectory);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(42.h),
                  side: const BorderSide(color: Color(0xFF173A6D)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Manage Users',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF173A6D),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPerformanceCard extends StatelessWidget {
  const _TeamPerformanceCard();

  static const _telecallers = [
    _PerformanceRow('Sneha Iyer', '0', '0'),
    _PerformanceRow('Ravi Kumar', '0', '0'),
    _PerformanceRow('Khushvinder Kaur', '0', '0'),
    _PerformanceRow('Telecaller Test', '0', '0'),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2A44),
          ),
          children: [
            const TextSpan(text: 'Team Performance '),
            TextSpan(
              text: '(This Month)',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: _TabPill(label: 'Telecallers', selected: true),
                  ),
                  Expanded(child: _TabPill(label: 'Field Execs')),
                  Expanded(child: _TabPill(label: 'Managers')),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text('TELECALLER', style: _tableHeaderStyle()),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'LEADS',
                    textAlign: TextAlign.center,
                    style: _tableHeaderStyle(),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CALLS DONE',
                    textAlign: TextAlign.center,
                    style: _tableHeaderStyle(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            ..._telecallers.map((row) => _TeamPerformanceRowTile(row: row)),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5FA),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FooterMetric(
                      title: 'Avg SLA\nCompliance',
                      value: '66.2%',
                      valueColor: const Color(0xFF10B981),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44.h,
                    color: const Color(0xFFD8DEE9),
                  ),
                  Expanded(
                    child: _FooterMetric(
                      title: 'Fastest Team',
                      value: 'Team Alpha',
                      valueColor: const Color(0xFF1F2A44),
                      valueFontSize: 14,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44.h,
                    color: const Color(0xFFD8DEE9),
                  ),
                  Expanded(
                    child: _FooterMetric(
                      title: 'Needs Attention',
                      value: 'Team Delta',
                      valueColor: const Color(0xFFDC2626),
                      valueFontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.employeeDirectory);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(42.h),
                  side: const BorderSide(color: AppColors.orangeDeep),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'View All Telecallers',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.orangeDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _tableHeaderStyle() {
    return GoogleFonts.inter(
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF4B5563),
      letterSpacing: 0.4,
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.onActionTap});

  final ValueChanged<String> onActionTap;

  static const _actions = [
    _QuickActionChipData('Add New Lead', false),
    _QuickActionChipData('Import Leads', true),
    _QuickActionChipData('Assign Leads', false),
    _QuickActionChipData('Create Task', false),
    _QuickActionChipData('Schedule Visit', true),
    _QuickActionChipData('Send Notification', false),
    _QuickActionChipData('View Reports', false),
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Text(
        'Quick Actions',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2A44),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _actions
              .map(
                (action) => _QuickActionChip(
                  action: action,
                  onTap: () => onActionTap(action.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ReportsShortcutsCard extends StatelessWidget {
  const _ReportsShortcutsCard();

  static const _reports = [
    'Daily Report',
    'Weekly Report',
    'Monthly Report',
    'Booking Report',
    'Revenue Report',
    'Source Report',
  ];

  @override
  Widget build(BuildContext context) {
    return _DashboardSectionCard(
      header: Text(
        'Reports Shortcuts',
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF173A6D),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 14.h),
        child: Column(
          children: [
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: _reports
                  .map(
                    (report) => _ReportChip(
                      label: report,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRouter.reports),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 194.w,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.reports);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(42.h),
                  side: const BorderSide(color: AppColors.orangeDeep),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'View All Reports',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.orangeDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet({
    required this.notifications,
    required this.error,
    required this.onCountChanged,
  });

  final List<dynamic> notifications;
  final String? error;
  final ValueChanged<int> onCountChanged;

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late List<dynamic> _notifications = widget.notifications;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _error = widget.error;
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    final provider = context.read<NotificationProvider>();
    final response = await provider.fetchNotifications(limit: 20);
    if (!mounted) return;
    setState(() {
      _notifications = _extractList(response?.data);
      _error = provider.error;
      _isLoading = false;
    });
    widget.onCountChanged(_countUnread(response?.data));
  }

  Future<void> _markAllRead() async {
    setState(() => _isLoading = true);
    final provider = context.read<NotificationProvider>();
    await provider.markAllNotificationsRead();
    final response = await provider.fetchNotifications(limit: 20);
    if (!mounted) return;
    setState(() {
      _notifications = _extractList(response?.data);
      _error = provider.error;
      _isLoading = false;
    });
    widget.onCountChanged(_countUnread(response?.data));
  }

  Future<void> _markRead(Object? item) async {
    final id = _itemId(item);
    if (id == null) {
      return;
    }
    final provider = context.read<NotificationProvider>();
    await provider.markNotificationRead(id);
    final response = await provider.fetchNotifications(limit: 20);
    if (!mounted) return;
    setState(() {
      _notifications = _extractList(response?.data);
      _error = provider.error;
    });
    widget.onCountChanged(_countUnread(response?.data));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : _refresh,
                  icon: const Icon(Icons.refresh),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _markAllRead,
                  child: const Text('Mark all read'),
                ),
              ],
            ),
            if (_isLoading) const LinearProgressIndicator(),
            if (_error != null) ...[
              SizedBox(height: 8.h),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFFB91C1C),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 480.h),
              child: _notifications.isEmpty
                  ? const _EmptyApiState(message: 'No notifications found.')
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.notifications_none_outlined,
                            color: _isUnread(item)
                                ? AppColors.orangeDeep
                                : const Color(0xFF6B7280),
                          ),
                          title: Text(
                            _itemTitle(item),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          subtitle: Text(
                            _itemSubtitle(item),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _markRead(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalSearchSheet extends StatefulWidget {
  const _GlobalSearchSheet();

  @override
  State<_GlobalSearchSheet> createState() => _GlobalSearchSheetState();
}

class _GlobalSearchSheetState extends State<_GlobalSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, List<dynamic>> _results = {};
  String? _error;
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results.clear();
        _error = 'Enter a search term.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    final leadProvider = context.read<LeadProvider>();
    final employeeProvider = context.read<EmployeeProvider>();
    final projectProvider = context.read<ProjectProvider>();

    final leadResponse = await leadProvider.fetchLeads(
      search: query,
      limit: 10,
    );
    final employeeResponse = await employeeProvider.fetchEmployees(
      search: query,
      limit: 10,
      status: null,
    );
    final projectResponse = await projectProvider.fetchProjects(search: query);

    if (!mounted) {
      return;
    }

    setState(() {
      _results
        ..clear()
        ..addAll({
          'Leads': _extractList(leadResponse?.data),
          'Employees': _extractList(employeeResponse?.data),
          'Projects': _extractList(projectResponse?.data),
        });
      _error =
          leadProvider.error ?? employeeProvider.error ?? projectProvider.error;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18.w,
          right: 18.w,
          top: 16.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Global Search',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search leads, employees, projects',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _isSearching ? null : _search,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            if (_isSearching) ...[
              SizedBox(height: 12.h),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(
                _error!,
                style: GoogleFonts.inter(
                  color: const Color(0xFFB91C1C),
                  fontSize: 12.sp,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 520.h),
              child: _results.isEmpty
                  ? const _EmptyApiState(
                      message: 'Search results will appear here.',
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: _results.entries
                          .map(
                            (entry) => _SearchResultGroup(
                              title: entry.key,
                              items: entry.value,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultGroup extends StatelessWidget {
  const _SearchResultGroup({required this.title, required this.items});

  final String title;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (${items.length})',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 6.h),
          if (items.isEmpty)
            Text(
              'No matching $title',
              style: GoogleFonts.inter(fontSize: 12.sp),
            )
          else
            ...items.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(_itemTitle(item)),
                subtitle: Text(
                  _itemSubtitle(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.profile, required this.error});

  final Object? profile;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final rows = _displayRows(profile);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 22.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 14.h),
            if (error != null)
              Text(error!, style: const TextStyle(color: Color(0xFFB91C1C)))
            else if (rows.isEmpty)
              const _EmptyApiState(message: 'Profile details are unavailable.')
            else
              ...rows.map(
                (row) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 118.w,
                        child: Text(
                          row.key,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CreateLeadDialog extends StatefulWidget {
  const _CreateLeadDialog();

  @override
  State<_CreateLeadDialog> createState() => _CreateLeadDialogState();
}

class _CreateLeadDialogState extends State<_CreateLeadDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      setState(() => _error = 'Name and mobile are required.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final response = await context.read<LeadProvider>().createLeadFromApi({
      'name': name,
      'mobile': mobile,
      if (_emailController.text.trim().isNotEmpty)
        'email': _emailController.text.trim(),
      if (_remarksController.text.trim().isNotEmpty)
        'remarks': _remarksController.text.trim(),
    });

    if (!mounted) {
      return;
    }

    if (response != null) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead created successfully.')),
      );
      return;
    }

    setState(() {
      _isSaving = false;
      _error = context.read<LeadProvider>().error ?? 'Unable to create lead.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Lead'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogTextField(controller: _nameController, label: 'Name'),
            SizedBox(height: 10.h),
            _DialogTextField(
              controller: _mobileController,
              label: 'Mobile',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10.h),
            _DialogTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10.h),
            _DialogTextField(
              controller: _remarksController,
              label: 'Remarks',
              maxLines: 2,
            ),
            if (_error != null) ...[
              SizedBox(height: 10.h),
              Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _EmptyApiState extends StatelessWidget {
  const _EmptyApiState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 160.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: const Color(0xFFDCE9F7),
              child: CustomPaint(painter: _MapFallbackPainter()),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0x5A102A54),
                    const Color(0xBE102A54),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              top: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'Maps',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2F5DB3),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.open_in_new,
                      size: 15.sp,
                      color: const Color(0xFF2F5DB3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live now',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '4 executives',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14.w,
              bottom: 10.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Primary zone',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    'Mumbai\nCentral',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExecutiveListTile extends StatelessWidget {
  const _ExecutiveListTile({required this.item});

  final _ExecutiveMapItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD8DEE9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: item.avatarColor,
            child: Text(
              item.initials,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF173A6D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.area,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF173A6D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF6D7787),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD9FBE7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'LIVE',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserStatCard extends StatelessWidget {
  const _UserStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.borderColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34.sp, color: iconColor),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF60708A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2A44),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0x120F172A),
                  blurRadius: 6.r,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _TeamPerformanceRowTile extends StatelessWidget {
  const _TeamPerformanceRowTile({required this.row});

  final _PerformanceRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              row.name,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2A44),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              row.leads,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.callsDone,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterMetric extends StatelessWidget {
  const _FooterMetric({
    required this.title,
    required this.value,
    required this.valueColor,
    this.valueFontSize,
  });

  final String title;
  final String value;
  final Color valueColor;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              height: 1.2,
              color: const Color(0xFF4B5563),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: (valueFontSize ?? 17).sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.action, required this.onTap});

  final _QuickActionChipData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: action.highlighted
              ? AppColors.orangeDeep
              : const Color(0xFF173A6D),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          action.label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFD6E2F3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF173A6D),
          ),
        ),
      ),
    );
  }
}

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          color: AppColors.orangeDeep,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0x33FF6B00),
              blurRadius: 16.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.add, color: Colors.white, size: 30.sp),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.background,
    required this.titleColor,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color background;
  final Color titleColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlaMetricCard extends StatelessWidget {
  const _SlaMetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.background,
    required this.accent,
    this.tag,
    this.tagBg,
    this.valueFontSize,
  });

  final String title;
  final String subtitle;
  final String value;
  final String? tag;
  final Color background;
  final Color accent;
  final Color? tagBg;
  final double? valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF27364B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (tag != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: tagBg ?? accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    tag!,
                    style: GoogleFonts.inter(
                      fontSize: 7.5.sp,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 8.sp,
              height: 1.35,
              color: const Color(0xFF6D7787),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: (valueFontSize ?? 22).sp,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelBar extends StatelessWidget {
  const _FunnelBar({required this.color, required this.widthFactor});

  final Color color;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 280.w * widthFactor,
        child: Container(
          width: double.infinity,
          height: 40.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

class _SiteVisitsChartPainter extends CustomPainter {
  _SiteVisitsChartPainter({
    required this.bluePoints,
    required this.orangePoints,
  });

  final List<Offset> bluePoints;
  final List<Offset> orangePoints;

  @override
  void paint(Canvas canvas, Size size) {
    final chartLeft = 28.0;
    final chartTop = 6.0;
    final chartWidth = size.width - 34.0;
    final chartHeight = size.height - 26.0;

    final bluePath = _smoothPath(
      bluePoints,
      chartLeft,
      chartTop,
      chartWidth,
      chartHeight,
    );
    final orangePath = _smoothPath(
      orangePoints,
      chartLeft,
      chartTop,
      chartWidth,
      chartHeight,
    );

    final bluePaint = Paint()
      ..color = const Color(0xFF173A6D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final orangePaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(bluePath, bluePaint);
    canvas.drawPath(orangePath, orangePaint);

    for (final point in bluePoints) {
      final position = Offset(
        chartLeft + (chartWidth * point.dx),
        chartTop + (chartHeight * point.dy),
      );
      canvas.drawCircle(
        position,
        2.5,
        Paint()..color = const Color(0xFF173A6D),
      );
      if (point == bluePoints.last) {
        canvas.drawCircle(
          position,
          4,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFF173A6D),
        );
      }
    }
    for (final point in orangePoints) {
      final position = Offset(
        chartLeft + (chartWidth * point.dx),
        chartTop + (chartHeight * point.dy),
      );
      canvas.drawCircle(
        position,
        2.5,
        Paint()..color = const Color(0xFFFF6B00),
      );
    }

    final labelStyle = GoogleFonts.inter(
      fontSize: 9,
      color: const Color(0xFF98A2B3),
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labels = ['22 Jun', '24 Jun', '25 Jun'];
    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(text: labels[i], style: labelStyle);
      textPainter.layout();
      final x =
          chartLeft + (chartWidth * bluePoints[i].dx) - (textPainter.width / 2);
      textPainter.paint(canvas, Offset(x, chartTop + chartHeight + 6));
    }
  }

  Path _smoothPath(
    List<Offset> points,
    double left,
    double top,
    double width,
    double height,
  ) {
    final translated = points
        .map(
          (point) =>
              Offset(left + (width * point.dx), top + (height * point.dy)),
        )
        .toList();
    final path = Path()..moveTo(translated.first.dx, translated.first.dy);
    for (var i = 0; i < translated.length - 1; i++) {
      final current = translated[i];
      final next = translated[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      path.cubicTo(controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapFallbackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFDCE9F7);
    canvas.drawRect(Offset.zero & size, bg);

    final linePaint = Paint()
      ..color = const Color(0xA6B6CAE2)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), linePaint);
    }
    for (double y = 12; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 8), linePaint);
    }

    final river = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.62,
        size.width * 0.38,
        size.height * 0.9,
        size.width * 0.58,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.56,
        size.width * 0.9,
        size.height * 0.74,
        size.width,
        size.height * 0.66,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0x8091B5DE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18,
    );

    for (final marker in [
      Offset(size.width * 0.22, size.height * 0.3),
      Offset(size.width * 0.36, size.height * 0.46),
      Offset(size.width * 0.72, size.height * 0.36),
      Offset(size.width * 0.82, size.height * 0.58),
    ]) {
      final pin = Paint()..color = const Color(0xFF5C708D);
      canvas.drawCircle(marker, 5, pin);
      canvas.drawLine(
        Offset(marker.dx, marker.dy + 5),
        Offset(marker.dx, marker.dy + 12),
        pin..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 24.w;
    final rect = Offset.zero & size;
    final startAngleBase = -1.1;
    final sweep = (3.141592653589793 * 2) / colors.length;

    for (var i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngleBase + (i * sweep),
        sweep - 0.06,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Object? _findFirstValue(Object? source, List<String> keys) {
  if (source is List) {
    for (final item in source) {
      final value = _findFirstValue(item, keys);
      if (value != null) return value;
    }
    return null;
  }

  if (source is! Map) {
    return null;
  }

  for (final entry in source.entries) {
    final key = entry.key.toString().toLowerCase();
    if (keys.any((candidate) => candidate.toLowerCase() == key)) {
      return entry.value;
    }
  }

  for (final key in const [
    'data',
    'result',
    'payload',
    'summary',
    'stats',
    'counts',
    'kpi',
    'meta',
    'visitExecutionSummary',
    'teamHealthSummary',
    'dashboard',
    'user',
    'employee',
  ]) {
    if (source.containsKey(key)) {
      final value = _findFirstValue(source[key], keys);
      if (value != null) return value;
    }
  }

  return null;
}

List<dynamic> _extractList(Object? source) {
  if (source is List) {
    return source;
  }

  if (source is Map) {
    for (final key in const [
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'notifications',
      'leads',
      'employees',
      'projects',
    ]) {
      final value = source[key];
      if (value is List) {
        return value;
      }
    }

    for (final key in const ['data', 'result', 'payload']) {
      final value = source[key];
      final nested = _extractList(value);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  }

  return const [];
}

int _countUnread(Object? source) {
  final directCount = _findFirstValue(source, const [
    'unreadCount',
    'unread_count',
    'unread',
  ]);
  if (directCount is num) {
    return directCount.toInt();
  }
  if (directCount is String) {
    return int.tryParse(directCount) ?? 0;
  }

  final items = _extractList(source);
  return items.where(_isUnread).length;
}

bool _isUnread(Object? item) {
  if (item is! Map) {
    return false;
  }

  final isRead = _findFirstValue(item, const ['isRead', 'read']);
  if (isRead is bool) {
    return !isRead;
  }
  final readAt = _findFirstValue(item, const ['readAt', 'read_at']);
  if (readAt != null && readAt.toString().isNotEmpty) {
    return false;
  }
  final status = _findFirstValue(item, const ['status']);
  if (status != null) {
    return status.toString().toLowerCase() != 'read';
  }
  return true;
}

String _formatMetricValue(Object value) {
  if (value is num) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
  return value.toString();
}

String? _profileName(Object? source) {
  final value = _findFirstValue(source, const [
    'fullName',
    'full_name',
    'name',
    'email',
  ]);
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'AD';
  }

  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _itemTitle(Object? item) {
  final value = _findFirstValue(item, const [
    'title',
    'name',
    'fullName',
    'full_name',
    'customerName',
    'projectName',
    'email',
    'message',
  ]);
  return value?.toString() ?? 'Untitled';
}

String _itemSubtitle(Object? item) {
  if (item is! Map) {
    return item?.toString() ?? '';
  }

  final values = <String>[];
  for (final key in const [
    'email',
    'mobile',
    'phone',
    'role',
    'status',
    'source',
    'location',
    'description',
    'message',
    'createdAt',
  ]) {
    final value = _findFirstValue(item, [key]);
    if (value != null && value.toString().trim().isNotEmpty) {
      values.add(value.toString());
    }
  }
  return values.take(3).join(' • ');
}

String? _itemId(Object? item) {
  final value = _findFirstValue(item, const [
    'id',
    '_id',
    'notificationId',
    'notification_id',
  ]);
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<MapEntry<String, String>> _displayRows(Object? source) {
  final profile = source is Map && source['data'] is Map
      ? source['data'] as Map
      : source is Map && source['user'] is Map
      ? source['user'] as Map
      : source is Map && source['employee'] is Map
      ? source['employee'] as Map
      : source is Map
      ? source
      : const {};

  final rows = <MapEntry<String, String>>[];
  for (final key in const [
    'fullName',
    'name',
    'email',
    'phone',
    'role',
    'designation',
    'status',
  ]) {
    final value = _findFirstValue(profile, [key]);
    if (value != null && value.toString().trim().isNotEmpty) {
      rows.add(MapEntry(_prettifyKey(key), value.toString()));
    }
  }
  return rows;
}

String _prettifyKey(String key) {
  return key
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .trim()
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class _LegendItem {
  const _LegendItem(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

class _ExecutiveMapItem {
  const _ExecutiveMapItem({
    required this.initials,
    required this.name,
    required this.area,
    required this.statusText,
    required this.avatarColor,
  });

  final String initials;
  final String name;
  final String area;
  final String statusText;
  final Color avatarColor;
}

class _PerformanceRow {
  const _PerformanceRow(this.name, this.leads, this.callsDone);

  final String name;
  final String leads;
  final String callsDone;
}

class _QuickActionChipData {
  const _QuickActionChipData(this.label, this.highlighted);

  final String label;
  final bool highlighted;
}

class _DashboardMetric {
  const _DashboardMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.valueFontSize,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final double? valueFontSize;

  _DashboardMetric copyWith({
    IconData? icon,
    String? title,
    String? value,
    Color? iconColor,
    double? valueFontSize,
  }) {
    return _DashboardMetric(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      value: value ?? this.value,
      iconColor: iconColor ?? this.iconColor,
      valueFontSize: valueFontSize ?? this.valueFontSize,
    );
  }
}
