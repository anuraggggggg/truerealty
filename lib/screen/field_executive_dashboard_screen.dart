import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

class FieldExecutiveDashboardView extends StatefulWidget {
  const FieldExecutiveDashboardView({
    super.key,
    this.onMenuTap,
    this.bottomSpacing = 24,
  });

  final VoidCallback? onMenuTap;
  final double bottomSpacing;

  @override
  State<FieldExecutiveDashboardView> createState() =>
      _FieldExecutiveDashboardViewState();
}

class _FieldExecutiveDashboardViewState
    extends State<FieldExecutiveDashboardView> {
  _FieldDashboardData _data = const _FieldDashboardData();
  bool _loading = true;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<DashboardProvider>();
    final response = await provider.fetchFieldExecutiveDashboard();
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loading = false;
        _loaded = true;
        _error =
            provider.error ?? 'Unable to load the field executive dashboard.';
      });
      return;
    }
    final sessionUser = context.read<AuthProvider>().session?.user;
    setState(() {
      _data = _FieldDashboardData.fromApi(response.data, sessionUser);
      _loading = false;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.orangeDeep,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: widget.bottomSpacing.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 78.h,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
              color: AppColors.navy,
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/app_tellicaller.png',
                width: 188.w,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _data.employeeName.isEmpty
                        ? 'Your field operations overview.'
                        : 'Field operations overview for ${_data.employeeName}.',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: 14.h),
                    _ExecutiveErrorCard(message: _error!, onRetry: _load),
                  ],
                  if (!_loaded && _loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: AppListSkeleton(itemCount: 3, itemHeight: 116),
                    )
                  else ...[
                    SizedBox(height: 16.h),
                    _ExecutiveMetrics(data: _data),
                    SizedBox(height: 14.h),
                    _CheckInStatusCard(items: _data.checkInStatus),
                    SizedBox(height: 12.h),
                    _ExecutiveAlertCard(items: _data.alerts),
                    SizedBox(height: 12.h),
                    _ExecutiveRecentActivityCard(items: _data.activities),
                    SizedBox(height: 12.h),
                    _TodayStopsCard(items: _data.todayStops),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExecutiveMetricCard extends StatelessWidget {
  const _ExecutiveMetricCard({required this.data, this.fullWidth = false});

  final _ExecutiveMetricData data;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: fullWidth ? 84.h : 88.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, size: 18.sp, color: data.iconColor),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveMetrics extends StatelessWidget {
  const _ExecutiveMetrics({required this.data});

  final _FieldDashboardData data;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _ExecutiveMetricData(
        title: 'Assigned\nLeads',
        value: '${data.assignedLeads}',
        icon: Icons.groups_2_outlined,
        iconColor: const Color(0xFF0F2F66),
      ),
      _ExecutiveMetricData(
        title: 'Today\'s\nSite Visits',
        value: '${data.todaySiteVisits}',
        icon: Icons.location_on_outlined,
        iconColor: const Color(0xFF06B6D4),
      ),
      _ExecutiveMetricData(
        title: 'Upcoming\nVisits',
        value: '${data.upcomingVisits}',
        icon: Icons.schedule_outlined,
        iconColor: const Color(0xFFA855F7),
      ),
      _ExecutiveMetricData(
        title: 'Completed\nVisits',
        value: '${data.completedVisits}',
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF22C55E),
      ),
      _ExecutiveMetricData(
        title: 'Missed\nVisits',
        value: '${data.missedVisits}',
        icon: Icons.event_busy_outlined,
        iconColor: const Color(0xFFEF4444),
      ),
      _ExecutiveMetricData(
        title: 'Pending Follow-ups',
        value: '${data.pendingFollowUps}',
        icon: Icons.assignment_late_outlined,
        iconColor: const Color(0xFFF97316),
      ),
      _ExecutiveMetricData(
        title: 'Bookings Assisted',
        value: '${data.bookingsAssisted}',
        icon: Icons.handshake_outlined,
        iconColor: const Color(0xFF2563EB),
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              Expanded(child: _ExecutiveMetricCard(data: metrics[i])),
              if (i != 2) SizedBox(width: 10.w),
            ],
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: _ExecutiveMetricCard(data: metrics[3])),
            SizedBox(width: 12.w),
            Expanded(child: _ExecutiveMetricCard(data: metrics[4])),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: _ExecutiveMetricCard(data: metrics[5])),
            SizedBox(width: 12.w),
            Expanded(child: _ExecutiveMetricCard(data: metrics[6])),
          ],
        ),
        SizedBox(height: 10.h),
        _ExecutiveMetricCard(
          data: _ExecutiveMetricData(
            title: 'Visits Pending\nStart',
            value: '${data.visitsPendingStart}',
            icon: Icons.assignment_turned_in_outlined,
            iconColor: const Color(0xFFF97316),
          ),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _ExecutiveMetricData {
  const _ExecutiveMetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
}

class _ExecutiveSectionCard extends StatelessWidget {
  const _ExecutiveSectionCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CheckInStatusCard extends StatelessWidget {
  const _CheckInStatusCard({required this.items});

  final List<_StatusMetric> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in Status',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            runSpacing: 14.h,
            spacing: 8.w,
            children: items
                .map(
                  (item) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 64.w) / 2,
                    child: _CheckInMetricTile(item: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveAlertCard extends StatelessWidget {
  const _ExecutiveAlertCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 19.sp,
                color: const Color(0xFFF97316),
              ),
              SizedBox(width: 8.w),
              Text(
                'Alerts & Notifications',
                style: GoogleFonts.inter(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No alerts or notifications.')
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFF6D7BD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    Text(
                      items[i],
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBF5A2A),
                      ),
                    ),
                    if (i != items.length - 1) SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExecutiveRecentActivityCard extends StatelessWidget {
  const _ExecutiveRecentActivityCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No recent activity.')
          else
            for (int i = 0; i < items.length; i++) ...[
              _ExecutiveActivityRow(text: items[i]),
              if (i != items.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(height: 1, color: const Color(0xFFE5E7EB)),
                ),
            ],
        ],
      ),
    );
  }
}

class _TodayStopsCard extends StatelessWidget {
  const _TodayStopsCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Stops',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No route stops today.')
          else
            for (var i = 0; i < items.length; i++) ...[
              _ExecutiveActivityRow(text: items[i]),
              if (i != items.length - 1) SizedBox(height: 12.h),
            ],
        ],
      ),
    );
  }
}

class _CheckInMetricTile extends StatelessWidget {
  const _CheckInMetricTile({required this.item});

  final _StatusMetric item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item.value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: item.valueColor,
          ),
        ),
      ],
    );
  }
}

class _ExecutiveActivityRow extends StatelessWidget {
  const _ExecutiveActivityRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          margin: EdgeInsets.only(top: 2.h),
          decoration: const BoxDecoration(
            color: Color(0xFFE9F9EE),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 15.sp, color: const Color(0xFF22C55E)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusMetric {
  const _StatusMetric(this.label, this.value, this.valueColor);

  final String label;
  final String value;
  final Color valueColor;
}

class _ExecutiveEmptyText extends StatelessWidget {
  const _ExecutiveEmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF667085),
      ),
    );
  }
}

class _ExecutiveErrorCard extends StatelessWidget {
  const _ExecutiveErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFBE123C)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9F1239),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _FieldDashboardData {
  const _FieldDashboardData({
    this.employeeName = '',
    this.assignedLeads = 0,
    this.todaySiteVisits = 0,
    this.upcomingVisits = 0,
    this.completedVisits = 0,
    this.missedVisits = 0,
    this.pendingFollowUps = 0,
    this.bookingsAssisted = 0,
    this.visitsPendingStart = 0,
    this.checkedIn = 0,
    this.pendingCheckIns = 0,
    this.checkedOut = 0,
    this.missedCheckIns = 0,
    this.alerts = const [],
    this.activities = const [],
    this.todayStops = const [],
  });

  final String employeeName;
  final int assignedLeads;
  final int todaySiteVisits;
  final int upcomingVisits;
  final int completedVisits;
  final int missedVisits;
  final int pendingFollowUps;
  final int bookingsAssisted;
  final int visitsPendingStart;
  final int checkedIn;
  final int pendingCheckIns;
  final int checkedOut;
  final int missedCheckIns;
  final List<String> alerts;
  final List<String> activities;
  final List<String> todayStops;

  List<_StatusMetric> get checkInStatus => [
    _StatusMetric('Checked in', '$checkedIn', const Color(0xFF22C55E)),
    _StatusMetric('Pending', '$pendingCheckIns', const Color(0xFFF97316)),
    _StatusMetric('Checked out', '$checkedOut', const Color(0xFF2563EB)),
    _StatusMetric('Missed', '$missedCheckIns', const Color(0xFFEF4444)),
  ];

  factory _FieldDashboardData.fromApi(
    Object? source,
    Map<String, dynamic>? sessionUser,
  ) {
    final root = _dashboardMap(source);
    final user = _dashboardMap(
      _dashboardValue(root, const [
        'employee',
        'fieldExecutive',
        'executive',
        'user',
        'profile',
      ]),
    );
    final session = sessionUser ?? const <String, dynamic>{};
    final firstName = _dashboardText(user['firstName'] ?? session['firstName']);
    final lastName = _dashboardText(user['lastName'] ?? session['lastName']);
    final combinedName = '$firstName $lastName'.trim();
    final alerts = _dashboardTextList(
      _dashboardValue(root, const ['alerts', 'notifications', 'pendingAlerts']),
    );
    final activities = _dashboardTextList(
      _dashboardValue(root, const [
        'recentActivities',
        'recentActivity',
        'activities',
        'activity',
      ]),
    );
    final stops = _dashboardTextList(
      _dashboardValue(root, const [
        'todayStops',
        'routeStops',
        'stops',
        'todayVisits',
        'visitsToday',
      ]),
      stop: true,
    );

    return _FieldDashboardData(
      employeeName: _dashboardFirstText([
        user['name'],
        user['fullName'],
        combinedName,
        session['name'],
        session['fullName'],
      ]),
      assignedLeads: _dashboardInt(root, const [
        'assignedLeads',
        'assignedLeadCount',
        'totalAssignedLeads',
      ]),
      todaySiteVisits: _dashboardInt(root, const [
        'todaySiteVisits',
        'todaysSiteVisits',
        'visitsToday',
      ]),
      upcomingVisits: _dashboardInt(root, const [
        'upcomingVisits',
        'upcomingSiteVisits',
      ]),
      completedVisits: _dashboardInt(root, const [
        'completedVisits',
        'completedSiteVisits',
      ]),
      missedVisits: _dashboardInt(root, const [
        'missedVisits',
        'missedSiteVisits',
      ]),
      pendingFollowUps: _dashboardInt(root, const [
        'pendingFollowUps',
        'pendingFollowups',
        'followUpsPending',
      ]),
      bookingsAssisted: _dashboardInt(root, const [
        'bookingsAssisted',
        'assistedBookings',
        'bookingCount',
      ]),
      visitsPendingStart: _dashboardInt(root, const [
        'visitsPendingStart',
        'pendingStartVisits',
        'notStartedVisits',
      ]),
      checkedIn: _dashboardInt(root, const [
        'checkedIn',
        'checkedInCount',
        'checkIns',
      ]),
      pendingCheckIns: _dashboardInt(root, const [
        'pendingCheckIns',
        'pendingCheckIn',
        'checkInPending',
      ]),
      checkedOut: _dashboardInt(root, const [
        'checkedOut',
        'checkedOutCount',
        'checkOuts',
      ]),
      missedCheckIns: _dashboardInt(root, const [
        'missedCheckIns',
        'missedCheckIn',
        'checkInMissed',
      ]),
      alerts: alerts,
      activities: activities,
      todayStops: stops,
    );
  }
}

Map<String, dynamic> _dashboardMap(Object? value) {
  if (value is! Map) return const {};
  final map = Map<String, dynamic>.from(value);
  final data = map['data'];
  if (data is Map) return _dashboardMap(data);
  return map;
}

Object? _dashboardValue(
  Map<String, dynamic> root,
  List<String> keys, [
  int depth = 0,
]) {
  for (final key in keys) {
    if (root.containsKey(key) && root[key] != null) return root[key];
  }
  if (depth >= 3) return null;
  for (final value in root.values) {
    if (value is Map) {
      final found = _dashboardValue(
        Map<String, dynamic>.from(value),
        keys,
        depth + 1,
      );
      if (found != null) return found;
    }
  }
  return null;
}

int _dashboardInt(Map<String, dynamic> root, List<String> keys) {
  final value = _dashboardValue(root, keys);
  if (value is num) return value.toInt();
  if (value is List) return value.length;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _dashboardText(Object? value) => value?.toString().trim() ?? '';

String _dashboardFirstText(Iterable<Object?> values) {
  for (final value in values) {
    final text = _dashboardText(value);
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

List<String> _dashboardTextList(Object? value, {bool stop = false}) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    value =
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['data'] ??
        map['visits'] ??
        map['stops'];
  }
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is! Map) return _dashboardText(item);
        final map = Map<String, dynamic>.from(item);
        if (stop) {
          final lead = _dashboardMap(map['lead']);
          final project = _dashboardMap(map['project'] ?? map['property']);
          final name = _dashboardFirstText([
            map['title'],
            map['name'],
            map['leadName'],
            lead['name'],
            lead['fullName'],
          ]);
          final destination = _dashboardFirstText([
            map['projectName'],
            project['name'],
            map['location'],
            project['location'],
          ]);
          final time = _dashboardFirstText([
            map['time'],
            map['scheduledAt'],
            map['visitDateTime'],
          ]);
          return [
            name,
            destination,
            time,
          ].where((part) => part.isNotEmpty).join(' • ');
        }
        return _dashboardFirstText([
          map['message'],
          map['description'],
          map['title'],
          map['activity'],
          map['text'],
          map['name'],
        ]);
      })
      .where((text) => text.isNotEmpty)
      .toList();
}

class _ExecutiveOutlineButton extends StatelessWidget {
  const _ExecutiveOutlineButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(42.h),
          side: const BorderSide(color: Color(0xFF123B7A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF123B7A),
          ),
        ),
      ),
    );
  }
}

class _SiteVisitFunnelOverviewCard extends StatelessWidget {
  const _SiteVisitFunnelOverviewCard();

  static const List<_FunnelRowData> _items = [
    _FunnelRowData('Scheduled (0)', 0.0, Color(0xFFE5E7FF)),
    _FunnelRowData('Checked In (0)', 0.0, Color(0xFFDDE4FF)),
    _FunnelRowData('Visit Completed (2)', 1.0, Color(0xFFFF6B00)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Visit Funnel Overview',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          for (int i = 0; i < _items.length; i++) ...[
            _FunnelProgressRow(data: _items[i]),
            if (i != _items.length - 1) SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }
}

class _FunnelProgressRow extends StatelessWidget {
  const _FunnelProgressRow({required this.data});

  final _FunnelRowData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.label,
          style: GoogleFonts.inter(
            fontSize: 13.8.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999.r),
          child: LinearProgressIndicator(
            value: data.progress,
            minHeight: 8.h,
            backgroundColor: const Color(0xFFEEF2FF),
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
          ),
        ),
      ],
    );
  }
}

class _FunnelRowData {
  const _FunnelRowData(this.label, this.progress, this.color);

  final String label;
  final double progress;
  final Color color;
}
