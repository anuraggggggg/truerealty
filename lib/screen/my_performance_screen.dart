import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/reports_provider.dart';

class MyPerformanceScreen extends StatefulWidget {
  const MyPerformanceScreen({
    super.key,
    this.title = 'My Performance',
    this.subtitle = 'Track calls, follow-ups and conversion.',
  });

  final String title;
  final String subtitle;

  static const Color pageBackground = Color(0xFFF4F6FB);

  @override
  State<MyPerformanceScreen> createState() => _MyPerformanceScreenState();

  static const double headerIconSize = 22;
  static const double actionIconSize = 22;
  static const double badgeIconSize = 17;
  static const double metricIconSize = 24;

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    height: 1.0,
    letterSpacing: 0.0,
    color: Color(0xFF002149),
  );

  static const TextStyle itemLabelStyle = TextStyle(
    fontFamily: 'NimbusSans',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF002149),
  );

  static const TextStyle summaryDateStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    height: 1.71,
    letterSpacing: 0,
    color: Color(0xFF131B2E),
  );

  static const TextStyle summaryItemLabelStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 19,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    height: 1.33,
    letterSpacing: 0,
    color: Color(0xFF1F2937),
  );

  static const TextStyle countPercentageStyle = TextStyle(
    fontFamily: 'NimbusSans',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF374151),
  );

  static const TextStyle conversionStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 1.33,
    letterSpacing: 0.6,
    color: Color(0xFF16A34A),
  );

  static const List<_DailySummary> _dailySummaries = [];

  /*
   * Historical UI mock values are excluded from the compiled application.
   * Runtime values are built in _MyPerformanceScreenState from API responses.
   *
  static const List<_PerformanceMetric> _topMetrics = [
    _PerformanceMetric(
      label: 'Leads Assigned',
      value: '5',
      icon: Icons.group_add_outlined,
      color: Color(0xFF2563EB),
    ),
    _PerformanceMetric(
      label: 'Total Calls',
      value: '5',
      icon: Icons.call_outlined,
      color: Color(0xFFF97316),
    ),
    _PerformanceMetric(
      label: 'Connected Calls',
      value: '5',
      icon: Icons.phone_in_talk_outlined,
      color: Color(0xFF10B981),
    ),
    _PerformanceMetric(
      label: 'Interested Leads',
      value: '0',
      icon: Icons.thumb_up_alt_outlined,
      color: Color(0xFFF97316),
    ),
    _PerformanceMetric(
      label: 'Converted Leads',
      value: '2',
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFF2563EB),
    ),
    _PerformanceMetric(
      label: 'Conversion %',
      value: '0',
      icon: Icons.pie_chart_outline,
      color: Color(0xFF10B981),
    ),
  ];
   */
}

class _MyPerformanceScreenState extends State<MyPerformanceScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;
  Object? _dashboardData;
  Object? _performanceData;
  Object? _conversionData;
  List<LeadModel> _leads = const [];
  List<dynamic> _followUps = const [];
  String _selectedPeriod = 'This Week';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPerformance());
  }

  Future<void> _loadPerformance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final dashboardProvider = context.read<DashboardProvider>();
    final reportsProvider = context.read<ReportsProvider>();
    final leadProvider = context.read<LeadProvider>();
    final dashboard = await dashboardProvider.fetchTelecallerDashboard();
    final performance = await dashboardProvider.fetchAdminPerformance(
      dateFrom: _dateKey(_rangeStart),
      dateTo: _dateKey(_rangeEnd),
      role: 'telecaller',
      limit: 100,
    );
    final conversion = await reportsProvider.fetchConversionAnalytics(
      dateFrom: _dateKey(_rangeStart),
      dateTo: _dateKey(_rangeEnd),
    );
    final leads = await leadProvider.fetchLeads(
      limit: 500,
      dateFrom: _dateKey(_rangeStart),
      dateTo: _dateKey(_rangeEnd),
    );
    final leadItems = List<LeadModel>.from(leadProvider.leads);
    final followUps = await leadProvider.fetchFollowUps(limit: 500);
    if (!mounted) return;
    setState(() {
      _dashboardData = dashboard?.data;
      _performanceData = performance?.data;
      _conversionData = conversion?.data;
      _leads = leadItems;
      _followUps = _extractList(followUps?.data);
      _error = dashboard == null && leads == null
          ? dashboardProvider.error ??
                leadProvider.error ??
                'Unable to load performance.'
          : null;
      _isLoading = false;
    });
  }

  DateTime get _weekStart {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  DateTime get _rangeStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedPeriod) {
      case 'Today':
        return today;
      case 'This Month':
        return DateTime(now.year, now.month);
      default:
        return _weekStart;
    }
  }

  DateTime get _rangeEnd {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedPeriod) {
      case 'Today':
        return today;
      case 'This Month':
        return DateTime(now.year, now.month + 1, 0);
      default:
        return _weekEnd;
    }
  }

  List<Object?> get _metricSource => [_kpiMap, _performanceMap, _dashboardData];

  Map<String, dynamic> get _kpiMap {
    if (_dashboardData is! Map) return const {};
    final root = Map<String, dynamic>.from(_dashboardData as Map);
    final kpi = root['kpi'] ?? root['kpis'] ?? root['performance'];
    return kpi is Map
        ? Map<String, dynamic>.from(kpi)
        : Map<String, dynamic>.from(root);
  }

  Map<String, dynamic> get _performanceMap {
    if (_dashboardData is! Map && _performanceData is! Map) return const {};
    final fromDashboard = _dashboardData is Map
        ? Map<String, dynamic>.from(_dashboardData as Map)['performance']
        : null;
    if (fromDashboard is Map) {
      return Map<String, dynamic>.from(fromDashboard);
    }
    if (_performanceData is Map) {
      return Map<String, dynamic>.from(_performanceData as Map);
    }
    return const {};
  }

  int _kpiCount(List<String> keys, {int fallback = 0}) {
    for (final key in keys) {
      if (!_kpiMap.containsKey(key) && !_performanceMap.containsKey(key)) {
        continue;
      }
      final value = _kpiMap[key] ?? _performanceMap[key];
      final parsed = _parseCount(value);
      if (parsed != null) return parsed;
    }
    final nested = _findInt(_metricSource, keys);
    return nested > 0 ? nested : fallback;
  }

  int? _parseCount(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is Map) {
      final nested = value['value'] ?? value['count'] ?? value['total'];
      if (nested is num) return nested.toInt();
      return int.tryParse(nested?.toString() ?? '');
    }
    return int.tryParse(value.toString());
  }

  String _formatCount(int value) {
    if (value < 10) return value.toString().padLeft(2, '0');
    return value.toString();
  }

  int get _totalLeads => _kpiCount(const [
    'totalAssignedLeads',
    'totalLeads',
    'assignedLeads',
  ], fallback: _leads.length);
  int get _totalCalls => _kpiCount(const [
    'totalCalls',
    'callsMade',
    'callCount',
  ], fallback: _findInt(_metricSource, const ['totalCalls', 'callsMade']));
  int get _connectedCalls =>
      _kpiCount(const ['connectedCalls', 'callsConnected', 'connected']);
  int get _interested => _kpiCount(
    const ['interestedLeads', 'interested'],
    fallback: _leads
        .where(
          (lead) =>
              lead.status.toLowerCase().contains('interested') &&
              !lead.status.toLowerCase().contains('not'),
        )
        .length,
  );
  int get _hotLeads => _kpiCount(
    const ['hotLeads', 'hot'],
    fallback: _leads
        .where(
          (lead) => '${lead.status} ${lead.leadType ?? ''}'
              .toLowerCase()
              .contains('hot'),
        )
        .length,
  );
  int get _converted => _kpiCount(
    const ['bookingsDone', 'convertedLeads', 'bookingDone'],
    fallback: _leads
        .where(
          (lead) =>
              lead.status.toLowerCase().contains('converted') ||
              lead.status.toLowerCase().contains('booking') ||
              lead.raw?['convertedAt'] != null,
        )
        .length,
  );
  int get _siteVisitDone => _kpiCount(
    const ['siteVisitDone', 'siteVisitsDone'],
    fallback: _leads
        .where((lead) => lead.status.toLowerCase().contains('site visit'))
        .length,
  );
  int get _todayFollowUps => _kpiCount(const [
    'todaysFollowUps',
    'todayFollowUps',
  ], fallback: _activeFollowUpsToday);
  int get _missedFollowUps => _kpiCount(const [
    'missedFollowUps',
    'overdueFollowUps',
  ], fallback: _overdueFollowUps);

  int get _activeFollowUpsToday {
    final now = DateTime.now();
    return _followUps.where((item) {
      final map = item is Map
          ? Map<String, dynamic>.from(item)
          : const <String, dynamic>{};
      final date = _findDate(map, const [
        'scheduledAt',
        'dueAt',
        'nextFollowUpAt',
      ]);
      final status = _findText(map, const [
        'status',
        'followUpStatus',
      ]).toLowerCase();
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day &&
          !status.contains('complete') &&
          !status.contains('cancel');
    }).length;
  }

  int get _overdueFollowUps {
    final now = DateTime.now();
    return _followUps.where((item) {
      final Map<String, dynamic> map = item is Map
          ? Map<String, dynamic>.from(item)
          : const {};
      final date = _findDate(map, const [
        'scheduledAt',
        'dueAt',
        'nextFollowUpAt',
      ]);
      final status = _findText(map, const [
        'status',
        'followUpStatus',
      ]).toLowerCase();
      return date != null &&
          date.isBefore(DateTime(now.year, now.month, now.day)) &&
          !status.contains('complete') &&
          !status.contains('cancel');
    }).length;
  }

  String get _conversionRate {
    if (_totalLeads == 0) return '0.0%';
    return '${((_converted / _totalLeads) * 100).toStringAsFixed(1)}%';
  }

  List<_PerformanceMetric> get _topMetrics => [
    _PerformanceMetric(
      label: 'TOTAL LEADS',
      value: _formatCount(_totalLeads),
      icon: Icons.groups_outlined,
      color: const Color(0xFF2563EB),
    ),
    _PerformanceMetric(
      label: 'TOTAL CALLS',
      value: _formatCount(_totalCalls),
      icon: Icons.call_outlined,
      color: const Color(0xFFF97316),
      badge: _selectedPeriod,
      badgeBackground: const Color(0xFFFFF1E8),
    ),
    _PerformanceMetric(
      label: 'CONNECTED CALLS',
      value: _formatCount(_connectedCalls),
      icon: Icons.phone_in_talk_outlined,
      color: const Color(0xFF10B981),
    ),
    _PerformanceMetric(
      label: 'TODAY FOLLOW UP',
      value: _formatCount(_todayFollowUps),
      icon: Icons.person_search_outlined,
      color: const Color(0xFFF97316),
      badge: 'Today',
      badgeBackground: const Color(0xFFFFF1E8),
    ),
    _PerformanceMetric(
      label: 'MISSED FOLLOW UP',
      value: _formatCount(_missedFollowUps),
      icon: Icons.person_remove_outlined,
      color: const Color(0xFFEF4444),
      badge: 'Overdue',
      badgeBackground: const Color(0xFFFFEBEE),
    ),
    _PerformanceMetric(
      label: 'INTERESTED LEADS',
      value: _formatCount(_interested),
      icon: Icons.thumb_up_alt_outlined,
      color: const Color(0xFF22C55E),
    ),
    _PerformanceMetric(
      label: 'HOT LEADS',
      value: _formatCount(_hotLeads),
      icon: Icons.local_fire_department_outlined,
      color: const Color(0xFFEF4444),
    ),
    _PerformanceMetric(
      label: 'SITE VISIT DONE',
      value: _formatCount(_siteVisitDone),
      icon: Icons.home_work_outlined,
      color: const Color(0xFF9333EA),
    ),
    _PerformanceMetric(
      label: 'BOOKING DONE',
      value: _formatCount(_converted),
      icon: Icons.check_circle_outline_rounded,
      color: const Color(0xFF16A34A),
      badge: _selectedPeriod,
      badgeBackground: const Color(0xFFE8F8EC),
    ),
    _PerformanceMetric(
      label: 'CONVERSION %',
      value: _conversionRate,
      icon: Icons.pie_chart_outline,
      color: const Color(0xFF0F766E),
    ),
  ];

  List<_PerformanceMetric> get _wideMetrics => [
    _PerformanceMetric(
      label: 'AVG RESPONSE TIME',
      value: _findDisplay(_metricSource, const [
        'avgResponseTime',
        'averageResponseTime',
      ]),
      icon: Icons.alarm_outlined,
      color: const Color(0xFFF97316),
    ),
    _PerformanceMetric(
      label: 'ON-TIME FOLLOW-UP %',
      value: _findDisplay(_metricSource, const [
        'onTimeFollowUpPercentage',
        'onTimeFollowUpRate',
      ], suffix: '%'),
      icon: Icons.check_circle_outline,
      color: const Color(0xFF10B981),
    ),
    _PerformanceMetric(
      label: 'SITE VISITS SCHEDULED',
      value: _formatCount(
        _kpiCount(const [
          'siteVisitScheduled',
          'siteVisitsScheduled',
          'scheduledSiteVisits',
        ]),
      ),
      icon: Icons.event_note_outlined,
      color: const Color(0xFF9333EA),
    ),
    _PerformanceMetric(
      label: 'FOLLOW-UP BREACHES',
      value: _formatCount(_overdueFollowUps),
      icon: Icons.event_busy_outlined,
      color: const Color(0xFFDC2626),
      badge: 'SLA',
      badgeBackground: const Color(0xFFFFEBEE),
    ),
  ];

  List<_CallOutcome> get _leadStatuses {
    final counts = <String, int>{};
    for (final lead in _leads) {
      final status = lead.status.trim().isEmpty
          ? 'Unknown'
          : lead.status.trim();
      counts[status] = (counts[status] ?? 0) + 1;
    }
    const colors = [
      Color(0xFF10B981),
      Color(0xFF0EA5E9),
      Color(0xFFF59E0B),
      Color(0xFFA855F7),
      Color(0xFF3B82F6),
      Color(0xFFEF4444),
    ];
    return counts.entries.toList().asMap().entries.map((entry) {
      final count = entry.value.value;
      final percentage = _leads.isEmpty ? 0 : count * 100 / _leads.length;
      return _CallOutcome(
        label: entry.value.key,
        count: count.toString(),
        percentage: '(${percentage.toStringAsFixed(1)}%)',
        color: colors[entry.key % colors.length],
      );
    }).toList();
  }

  List<_CallOutcome> get _callOutcomes {
    final list = _findList(_metricSource, const [
      'callOutcomes',
      'callOutcomeDistribution',
    ]);
    return list
        .asMap()
        .entries
        .map((entry) {
          final map = entry.value is Map
              ? Map<String, dynamic>.from(entry.value as Map)
              : const <String, dynamic>{};
          final count = _findInt(map, const ['count', 'value', 'total']);
          final percentage = _totalCalls == 0 ? 0 : count * 100 / _totalCalls;
          const colors = [
            Color(0xFF0F2F66),
            Color(0xFFF97316),
            Color(0xFFEAB308),
            Color(0xFF3B82F6),
            Color(0xFFA855F7),
            Color(0xFFEF4444),
          ];
          return _CallOutcome(
            label: _findText(map, const ['label', 'name', 'outcome']),
            count: count.toString(),
            percentage: '(${percentage.toStringAsFixed(1)}%)',
            color: colors[entry.key % colors.length],
          );
        })
        .where((item) => item.label.isNotEmpty)
        .toList();
  }

  List<_BarSeries> get _barSeries {
    final previous = _findMap(_conversionData, const [
      'previousPeriod',
      'lastWeek',
    ]);
    return [
      _BarSeries(
        label: 'Leads Assigned',
        backgroundValue: _findInt(previous, const [
          'leadsAssigned',
          'leads',
        ]).toDouble(),
        value: _totalLeads.toDouble(),
      ),
      _BarSeries(
        label: 'Calls Made',
        backgroundValue: _findInt(previous, const [
          'callsMade',
          'totalCalls',
        ]).toDouble(),
        value: _totalCalls.toDouble(),
      ),
      _BarSeries(
        label: 'Connected',
        backgroundValue: _findInt(previous, const [
          'connectedCalls',
          'connected',
        ]).toDouble(),
        value: _connectedCalls.toDouble(),
      ),
    ];
  }

  Future<void> _exportPerformance() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final rows = <List<String>>[
        ['My Performance Export'],
        ['Period', _selectedPeriod],
        ['Date From', _dateKey(_rangeStart)],
        ['Date To', _dateKey(_rangeEnd)],
        [],
        ['Summary Metric', 'Value'],
        ..._topMetrics.map(
          (metric) => [metric.label.replaceAll('\n', ' '), metric.value],
        ),
        ..._wideMetrics.map((metric) => [metric.label, metric.value]),
        [],
        ['Call Outcome', 'Count', 'Percentage'],
        if (_callOutcomes.isEmpty)
          ['Not available', '—', '—']
        else
          ..._callOutcomes.map(
            (outcome) => [outcome.label, outcome.count, outcome.percentage],
          ),
        [],
        ['Lead Status', 'Count', 'Percentage'],
        if (_leadStatuses.isEmpty)
          ['No lead status data', '0', '0%']
        else
          ..._leadStatuses.map(
            (status) => [status.label, status.count, status.percentage],
          ),
      ];
      final csv = rows.map((row) => row.map(_csvValue).join(',')).join('\r\n');
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/my-performance-${_dateKey(DateTime.now())}.csv',
      );
      await file.writeAsString('\uFEFF$csv');
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'My Performance - $_selectedPeriod',
        text:
            'Performance report for ${_formatDate(_rangeStart)} to ${_formatDate(_rangeEnd)}.',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to export performance: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _csvValue(String value) => '"${value.replaceAll('"', '""')}"';

  /*
  static const List<_PerformanceMetric> _wideMetrics = [
    _PerformanceMetric(
      label: 'Avg Response Time',
      value: '08m 14s',
      icon: Icons.alarm_outlined,
      color: Color(0xFFF97316),
    ),
    _PerformanceMetric(
      label: 'On-time Follow-up %',
      value: '91%',
      icon: Icons.check_circle,
      color: Color(0xFF10B981),
    ),
    _PerformanceMetric(
      label: 'Site Visits Scheduled',
      value: '\u20B9 12,00,000',
      icon: Icons.event_note_outlined,
      color: Color(0xFF9333EA),
    ),
    _PerformanceMetric(
      label: 'Breaches',
      value: '2',
      icon: Icons.calendar_today_outlined,
      color: Color(0xFFDC2626),
    ),
  ];

  static const List<_BarSeries> _barSeries = [
    _BarSeries(label: 'Leads Assigned', backgroundValue: 95, value: 118),
    _BarSeries(label: 'Calls Made', backgroundValue: 196, value: 238),
    _BarSeries(label: 'Connected', backgroundValue: 112, value: 136),
  ];

  static const List<_CallOutcome> _callOutcomes = [
    _CallOutcome(
      label: 'Connected',
      count: '154',
      percentage: '(62.86%)',
      color: Color(0xFF0F2F66),
    ),
    _CallOutcome(
      label: 'Not Answered',
      count: '45',
      percentage: '(18.37%)',
      color: Color(0xFFF97316),
    ),
    _CallOutcome(
      label: 'Busy',
      count: '24',
      percentage: '(9.80%)',
      color: Color(0xFFEAB308),
    ),
    _CallOutcome(
      label: 'Switched Off',
      count: '15',
      percentage: '(6.12%)',
      color: Color(0xFF3B82F6),
    ),
    _CallOutcome(
      label: 'Wrong Number',
      count: '5',
      percentage: '(2.04%)',
      color: Color(0xFFA855F7),
    ),
    _CallOutcome(
      label: 'Call Dropped',
      count: '2',
      percentage: '(0.82%)',
      color: Color(0xFFEF4444),
    ),
  ];

  static const List<_CallOutcome> _leadStatuses = [
    _CallOutcome(
      label: 'New',
      count: '28',
      percentage: '(22.40%)',
      color: Color(0xFF10B981),
    ),
    _CallOutcome(
      label: 'Contacted',
      count: '36',
      percentage: '(28.80%)',
      color: Color(0xFF0EA5E9),
    ),
    _CallOutcome(
      label: 'Follow-up',
      count: '27',
      percentage: '(21.60%)',
      color: Color(0xFFF59E0B),
    ),
    _CallOutcome(
      label: 'Site Visit',
      count: '18',
      percentage: '(14.40%)',
      color: Color(0xFFA855F7),
    ),
    _CallOutcome(
      label: 'Negotiation',
      count: '10',
      percentage: '(8.00%)',
      color: Color(0xFF3B82F6),
    ),
    _CallOutcome(
      label: 'Converted',
      count: '6',
      percentage: '(4.80%)',
      color: Color(0xFFEF4444),
    ),
  ];

  static const List<_DailySummary> _dailySummaries = [
    _DailySummary(
      date: '20 May 2025',
      conversion: '4.76% Conv.',
      items: [
        _SummaryItem(label: 'Leads Assigned', value: '28'),
        _SummaryItem(label: 'Calls Made', value: '56'),
        _SummaryItem(label: 'Connected Calls', value: '34'),
        _SummaryItem(label: 'Site Visits', value: '4'),
        _SummaryItem(label: 'Interested Leads', value: '8'),
        _SummaryItem(label: 'Converted Leads', value: '2'),
        _SummaryItem(label: 'Follow-ups Added', value: '22'),
        _SummaryItem(label: 'Remarks Added', value: '18'),
      ],
    ),
    _DailySummary(
      date: '19 May 2025',
      conversion: '3.85% Conv.',
      items: [
        _SummaryItem(label: 'Leads Assigned', value: '26'),
        _SummaryItem(label: 'Calls Made', value: '52'),
        _SummaryItem(label: 'Connected Calls', value: '31'),
        _SummaryItem(label: 'Site Visits', value: '3'),
        _SummaryItem(label: 'Interested Leads', value: '6'),
        _SummaryItem(label: 'Converted Leads', value: '1'),
        _SummaryItem(label: 'Follow-ups Added', value: '20'),
        _SummaryItem(label: 'Remarks Added', value: '16'),
      ],
    ),
    _DailySummary(
      date: '18 May 2025',
      conversion: '4.17% Conv.',
      items: [
        _SummaryItem(label: 'Leads Assigned', value: '24'),
        _SummaryItem(label: 'Calls Made', value: '49'),
        _SummaryItem(label: 'Connected Calls', value: '29'),
        _SummaryItem(label: 'Site Visits', value: '3'),
        _SummaryItem(label: 'Interested Leads', value: '6'),
        _SummaryItem(label: 'Converted Leads', value: '1'),
        _SummaryItem(label: 'Follow-ups Added', value: '18'),
        _SummaryItem(label: 'Remarks Added', value: '14'),
      ],
    ),
    _DailySummary(
      date: '17 May 2025',
      conversion: '4.55% Conv.',
      items: [
        _SummaryItem(label: 'Leads Assigned', value: '22'),
        _SummaryItem(label: 'Calls Made', value: '45'),
        _SummaryItem(label: 'Connected Calls', value: '28'),
        _SummaryItem(label: 'Site Visits', value: '2'),
        _SummaryItem(label: 'Interested Leads', value: '5'),
        _SummaryItem(label: 'Converted Leads', value: '1'),
        _SummaryItem(label: 'Follow-ups Added', value: '16'),
        _SummaryItem(label: 'Remarks Added', value: '12'),
      ],
    ),
    _DailySummary(
      date: 'Total / Average',
      conversion: '4.80% Conv.',
      isTotal: true,
      items: [
        _SummaryItem(label: 'Leads Assigned', value: '125'),
        _SummaryItem(label: 'Calls Made', value: '245'),
        _SummaryItem(label: 'Connected Calls', value: '154'),
        _SummaryItem(label: 'Site Visits', value: '18'),
        _SummaryItem(label: 'Interested Leads', value: '32'),
        _SummaryItem(label: 'Converted Leads', value: '6'),
        _SummaryItem(label: 'Follow-ups Added', value: '91'),
        _SummaryItem(label: 'Remarks Added', value: '71'),
      ],
    ),
  ];

  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyPerformanceScreen.pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orangeStrong,
          onRefresh: _loadPerformance,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: const BorderSide(color: Color(0xFFD9E3EF)),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isLoading || _isExporting
                          ? null
                          : _exportPerformance,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: _isExporting
                          ? SizedBox.square(
                              dimension: 14.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.download_outlined, size: 16.sp),
                      label: Text(
                        'Export',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isLoading) ...[
                  SizedBox(height: 12.h),
                  const LinearProgressIndicator(),
                ],
                if (_error != null) ...[
                  SizedBox(height: 12.h),
                  _PerformanceError(
                    message: _error!,
                    onRetry: _loadPerformance,
                  ),
                ],
                SizedBox(height: 16.h),
                _PeriodChips(
                  selected: _selectedPeriod,
                  onChanged: (period) {
                    if (period == _selectedPeriod) return;
                    setState(() => _selectedPeriod = period);
                    _loadPerformance();
                  },
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFD9E3EF)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18.sp,
                        color: AppColors.orangeStrong,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '${_formatDate(_rangeStart)}  –  ${_formatDate(_rangeEnd)}',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _MetricsPanel(
                  topMetrics: _topMetrics,
                  wideMetrics: _wideMetrics,
                ),
                SizedBox(height: 16.h),
                _OverviewCard(series: _barSeries),
                SizedBox(height: 14.h),
                _OutcomeCard(outcomes: _callOutcomes, totalCalls: _totalCalls),
                SizedBox(height: 14.h),
                _LeadStatusCard(
                  statuses: _leadStatuses,
                  totalLeads: _totalLeads,
                ),
                SizedBox(height: 14.h),
                _FollowUpSnapshotCard(
                  today: _todayFollowUps,
                  missed: _missedFollowUps,
                  breaches: _overdueFollowUps,
                  onTimeLabel: _findDisplay(_metricSource, const [
                    'onTimeFollowUpPercentage',
                    'onTimeFollowUpRate',
                  ], suffix: '%'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.series});

  final List<_BarSeries> series;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              textAlign: TextAlign.left,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Compared against previous period where available.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 210.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < series.length; i++) ...[
                    Expanded(child: _BarGroup(series: series[i])),
                    if (i != series.length - 1) SizedBox(width: 10.w),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: const [
                _LegendSwatch(color: Color(0xFFD7DCE6), label: 'Previous'),
                SizedBox(width: 14),
                _LegendSwatch(color: Color(0xFFFF7A00), label: 'Current'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.outcomes, required this.totalCalls});

  final List<_CallOutcome> outcomes;
  final int totalCalls;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Call Outcome Distribution',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: SizedBox(
              height: 180.h,
              width: 180.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(180.w, 180.h),
                    painter: _DonutChartPainter(
                      segments: outcomes,
                      strokeWidth: 34,
                      gapRadians: 0.06,
                    ),
                  ),
                  Container(
                    width: 86.w,
                    height: 86.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalCalls.toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F2F66),
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Total Leads',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          if (outcomes.isEmpty)
            const _InlineUnavailable(
              'Call outcome distribution was not found in the telecaller dashboard response.',
            )
          else
            ...outcomes.map(
              (outcome) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: outcome.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        outcome.label,
                        style: MyPerformanceScreen.itemLabelStyle,
                      ),
                    ),
                    Text(
                      '${outcome.count} ${outcome.percentage}',
                      style: MyPerformanceScreen.countPercentageStyle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeadStatusCard extends StatelessWidget {
  const _LeadStatusCard({required this.statuses, required this.totalLeads});

  final List<_CallOutcome> statuses;
  final int totalLeads;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Status Distribution',
            textAlign: TextAlign.left,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: SizedBox(
              height: 188.h,
              width: 188.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(188.w, 188.h),
                    painter: _DonutChartPainter(
                      segments: statuses,
                      strokeWidth: 36,
                      gapRadians: 0.04,
                    ),
                  ),
                  Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          totalLeads.toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0F2F66),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Total Leads',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF64748B),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          if (statuses.isEmpty)
            const _InlineUnavailable('No lead status data was returned.')
          else
            ...statuses.map(
              (status) => Padding(
                padding: EdgeInsets.only(bottom: 9.h),
                child: Row(
                  children: [
                    _LegendDot(color: status.color),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        status.label,
                        style: MyPerformanceScreen.itemLabelStyle,
                      ),
                    ),
                    Text(
                      '${status.count} ${status.percentage}',
                      style: MyPerformanceScreen.countPercentageStyle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _DailyPerformanceCard extends StatelessWidget {
  const _DailyPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: Text(
            'Daily Performance Summary',
            textAlign: TextAlign.left,
            style: MyPerformanceScreen.sectionHeaderStyle,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (
                var i = 0;
                i < MyPerformanceScreen._dailySummaries.length;
                i++
              ) ...[
                _DailySummaryBlock(
                  summary: MyPerformanceScreen._dailySummaries[i],
                ),
                if (i != MyPerformanceScreen._dailySummaries.length - 1)
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DailySummaryBlock extends StatelessWidget {
  const _DailySummaryBlock({required this.summary});

  final _DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.date,
                  style: MyPerformanceScreen.summaryDateStyle,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: summary.isTotal
                      ? const Color(0xFF2F66D8)
                      : const Color(0xFFEAFBF0),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      summary.isTotal
                          ? Icons.star_outline_rounded
                          : Icons.trending_up_rounded,
                      size: MyPerformanceScreen.badgeIconSize.sp,
                      color: summary.isTotal
                          ? Colors.white
                          : const Color(0xFF16A34A),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      summary.conversion,
                      style: summary.isTotal
                          ? MyPerformanceScreen.conversionStyle.copyWith(
                              color: Colors.white,
                            )
                          : MyPerformanceScreen.conversionStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: 14.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14.h,
              crossAxisSpacing: 18.w,
              mainAxisExtent: 62.h,
            ),
            itemBuilder: (context, index) {
              final item = summary.items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: MyPerformanceScreen.summaryItemLabelStyle,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.value,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF111827),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 46.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _PerformanceMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 124.h),
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(metric.icon, color: metric.color, size: 22.sp),
              if (metric.badge != null)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: metric.badgeBackground,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        metric.badge!,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: metric.color,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 34.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                metric.label,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: const Color(0xFF2D2C2C),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarGroup extends StatelessWidget {
  const _BarGroup({required this.series});

  final _BarSeries series;

  @override
  Widget build(BuildContext context) {
    const maxValue = 260.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 28.w,
                  height:
                      (math.min(series.backgroundValue, maxValue) / maxValue) *
                      185.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DCE6),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 28.w,
                  height: (math.min(series.value, maxValue) / maxValue) * 185.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF255FAA),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 72.w,
          child: Text(
            series.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF303746),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, this.label});

  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        if (label != null) ...[
          SizedBox(width: 6.w),
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475467),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashedGuideLine extends StatelessWidget {
  const _DashedGuideLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentCount = math.max(
          1,
          math.min(200, (constraints.maxWidth / 6).floor()),
        );

        return Row(
          children: List.generate(
            segmentCount,
            (_) => Expanded(
              child: Container(
                height: 1,
                margin: EdgeInsets.only(right: 3.w),
                color: const Color(0xFFD9DEE7),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7.w,
      height: 7.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.segments,
    this.strokeWidth = 24,
    this.gapRadians = 0,
  });

  final List<_CallOutcome> segments;
  final double strokeWidth;
  final double gapRadians;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + double.parse(segment.count),
    );
    var startAngle = -math.pi / 2;

    for (final segment in segments) {
      final fullSweep = (double.parse(segment.count) / total) * math.pi * 2;
      final sweepAngle = math.max(0.0, fullSweep - gapRadians);
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += fullSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _PerformanceMetric {
  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.badgeBackground = const Color(0xFFF1F5F9),
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color badgeBackground;
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _periods = ['Today', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _periods.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _PeriodChip(
              label: _periods[i],
              selected: selected == _periods[i],
              onTap: () => onChanged(_periods[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.orangeStrong : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? AppColors.orangeStrong : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.topMetrics, required this.wideMetrics});

  final List<_PerformanceMetric> topMetrics;
  final List<_PerformanceMetric> wideMetrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 10.w;
          final three = (constraints.maxWidth - (spacing * 2)) / 3;
          final two = (constraints.maxWidth - spacing) / 2;
          return Column(
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: 10.h,
                children: [
                  for (final metric in topMetrics)
                    SizedBox(
                      width: three,
                      child: _MetricCard(metric: metric),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: spacing,
                runSpacing: 10.h,
                children: [
                  for (final metric in wideMetrics)
                    SizedBox(
                      width: two,
                      child: _MetricCard(metric: metric),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FollowUpSnapshotCard extends StatelessWidget {
  const _FollowUpSnapshotCard({
    required this.today,
    required this.missed,
    required this.breaches,
    required this.onTimeLabel,
  });

  final int today;
  final int missed;
  final int breaches;
  final String onTimeLabel;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Today Follow-ups',
        today.toString().padLeft(2, '0'),
        const Color(0xFFF97316),
        Icons.today_outlined,
      ),
      (
        'Missed Follow-ups',
        missed.toString().padLeft(2, '0'),
        const Color(0xFFEF4444),
        Icons.event_busy_outlined,
      ),
      (
        'SLA Breaches',
        breaches.toString().padLeft(2, '0'),
        const Color(0xFFDC2626),
        Icons.warning_amber_rounded,
      ),
      (
        'On-time Rate',
        onTimeLabel,
        const Color(0xFF16A34A),
        Icons.verified_outlined,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-up Snapshot',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Live follow-up health for your assigned leads.',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 10.w;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 10.h,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: cardWidth,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.$4, color: item.$3, size: 18.sp),
                            SizedBox(height: 8.h),
                            Text(
                              item.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475467),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.$2,
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UnavailablePerformanceCard extends StatelessWidget {
  const _UnavailablePerformanceCard({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD9E2EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MyPerformanceScreen.sectionHeaderStyle),
          SizedBox(height: 10.h),
          const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B)),
          SizedBox(height: 8.h),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineUnavailable extends StatelessWidget {
  const _InlineUnavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class _PerformanceError extends StatelessWidget {
  const _PerformanceError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      color: const Color(0xFFFFF1F2),
      child: Row(
        children: [
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

String _dateKey(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String _formatDate(DateTime value) {
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
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String _valueOrDash(int value) => value == 0 ? '—' : value.toString();

String _findDisplay(Object? source, List<String> keys, {String suffix = ''}) {
  final value = _findValue(source, keys);
  if (value == null || value.toString().trim().isEmpty) return '—';
  final text = value.toString();
  return suffix.isNotEmpty && !text.endsWith(suffix) ? '$text$suffix' : text;
}

int _findInt(Object? source, List<String> keys) {
  final value = _findValue(source, keys);
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _findText(Map<String, dynamic> source, List<String> keys) {
  final value = _findValue(source, keys);
  return value?.toString().trim() ?? '';
}

DateTime? _findDate(Map<String, dynamic> source, List<String> keys) {
  final text = _findText(source, keys);
  return text.isEmpty ? null : DateTime.tryParse(text)?.toLocal();
}

Object? _findValue(Object? source, List<String> keys) {
  if (source is Map) {
    final map = Map<String, dynamic>.from(source);
    for (final key in keys) {
      for (final entry in map.entries) {
        if (entry.key.toLowerCase() == key.toLowerCase() &&
            entry.value != null) {
          return entry.value;
        }
      }
    }
    for (final value in map.values) {
      final nested = _findValue(value, keys);
      if (nested != null) return nested;
    }
  }
  if (source is List) {
    for (final item in source) {
      final nested = _findValue(item, keys);
      if (nested != null) return nested;
    }
  }
  return null;
}

List<dynamic> _findList(Object? source, List<String> keys) {
  final value = _findValue(source, keys);
  return value is List ? value : const [];
}

Map<String, dynamic> _findMap(Object? source, List<String> keys) {
  final value = _findValue(source, keys);
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

List<dynamic> _extractList(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'followUps',
    ]) {
      final value = source[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
  }
  return const [];
}

class _BarSeries {
  const _BarSeries({
    required this.label,
    required this.backgroundValue,
    required this.value,
  });

  final String label;
  final double backgroundValue;
  final double value;
}

class _CallOutcome {
  const _CallOutcome({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  final String label;
  final String count;
  final String percentage;
  final Color color;
}

class _DailySummary {
  const _DailySummary({
    required this.date,
    required this.conversion,
    required this.items,
    // ignore: unused_element_parameter
    this.isTotal = false,
  });

  final String date;
  final String conversion;
  final List<_SummaryItem> items;
  final bool isTotal;
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}
