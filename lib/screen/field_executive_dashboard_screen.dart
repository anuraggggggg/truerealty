import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
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
  bool _attendanceActionLoading = false;
  _FieldAttendanceData _attendance = const _FieldAttendanceData();
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
    final attendanceProvider = context.read<AttendanceProvider>();
    final response = await provider.fetchFieldExecutiveDashboard();
    final attendanceResponse = await attendanceProvider.fetchTodayAttendance();
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _attendance = _FieldAttendanceData.fromApi(attendanceResponse?.data);
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
      _attendance = _FieldAttendanceData.fromApi(attendanceResponse?.data);
      _loading = false;
      _loaded = true;
      if (attendanceResponse == null) {
        _error =
            attendanceProvider.error ?? 'Unable to load today’s attendance.';
      }
    });
  }

  Future<void> _punchIn() async {
    if (_attendanceActionLoading || !_attendance.canPunchIn) return;
    setState(() => _attendanceActionLoading = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.punchIn();
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(provider.error ?? 'Unable to punch in.');
      return;
    }
    await _refreshAttendance(successMessage: 'Punch in completed.');
  }

  Future<void> _punchOut() async {
    if (_attendanceActionLoading || !_attendance.canPunchOut) return;
    setState(() => _attendanceActionLoading = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.punchOut();
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(provider.error ?? 'Unable to punch out.');
      return;
    }
    await _refreshAttendance(successMessage: 'Punch out completed.');
  }

  Future<void> _refreshAttendance({String? successMessage}) async {
    final provider = context.read<AttendanceProvider>();
    final response = await provider.fetchTodayAttendance();
    if (!mounted) return;
    setState(() {
      _attendanceActionLoading = false;
      if (response != null) {
        _attendance = _FieldAttendanceData.fromApi(response.data);
      }
    });
    if (response == null) {
      _showAttendanceMessage(
        provider.error ?? 'Unable to refresh attendance status.',
      );
    } else if (successMessage != null) {
      _showAttendanceMessage(successMessage);
    }
  }

  void _showAttendanceMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            if (_loading) const LinearProgressIndicator(),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 14.h, 8.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                      ],
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
                    _FieldAttendanceCard(
                      data: _attendance,
                      isLoading: _attendanceActionLoading,
                      onPunchIn: _punchIn,
                      onPunchOut: _punchOut,
                    ),
                    SizedBox(height: 14.h),
                    _ExecutiveMetrics(data: _data),
                    SizedBox(height: 14.h),
                    _UpcomingSiteVisitsCard(
                      items: _data.todayStops,
                      onViewSchedule: () =>
                          context.read<DashboardProvider>().selectTab(3),
                    ),
                    SizedBox(height: 12.h),
                    _MyDayCard(
                      data: _data,
                      onViewSchedule: () =>
                          context.read<DashboardProvider>().selectTab(3),
                    ),
                    SizedBox(height: 12.h),
                    _ExecutiveRouteMapCard(
                      stops: _data.todayStops,
                      points: _data.routePoints,
                    ),
                    SizedBox(height: 12.h),
                    _DynamicSiteVisitFunnelCard(data: _data),
                    SizedBox(height: 12.h),

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

class _FieldAttendanceCard extends StatelessWidget {
  const _FieldAttendanceCard({
    required this.data,
    required this.isLoading,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  final _FieldAttendanceData data;
  final bool isLoading;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTENDANCE',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Today’s punch',
                      style: GoogleFonts.inter(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF123B7A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF123B7A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _AttendanceInfoBox(
            label: 'CURRENT STATUS',
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                border: Border.all(color: data.statusColor),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: data.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      data.status,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _AttendanceInfoBox(
            label: 'SHIFT',
            child: Text(
              data.shiftLabel,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF123B7A),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _AttendanceInfoBox(
            label: 'PUNCH LOG',
            child: Text(
              'In ${data.checkInLabel}  Out ${data.checkOutLabel}',
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF123B7A),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading || !data.canPunchIn ? null : onPunchIn,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(46.h),
                elevation: 0,
                backgroundColor: AppColors.orangeDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
              icon: isLoading
                  ? SizedBox(
                      width: 17.w,
                      height: 17.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.login_rounded),
              label: const Text('Punch In'),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isLoading || !data.canPunchOut ? null : onPunchOut,
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(46.h),
                foregroundColor: const Color(0xFF123B7A),
                side: const BorderSide(color: Color(0xFF123B7A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Punch Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceInfoBox extends StatelessWidget {
  const _AttendanceInfoBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
              color: const Color(0xFF29313D),
            ),
          ),
          SizedBox(height: 7.h),
          child,
        ],
      ),
    );
  }
}

class _FieldAttendanceData {
  const _FieldAttendanceData({
    this.status = 'Not Checked In',
    this.shiftLabel = 'No shift assigned',
    this.checkInAt,
    this.checkOutAt,
    this.canPunchIn = false,
    this.canPunchOut = false,
  });

  factory _FieldAttendanceData.fromApi(Object? source) {
    var root = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    if (root['data'] is Map) {
      root = Map<String, dynamic>.from(root['data'] as Map);
    }
    final record = root['record'] is Map
        ? Map<String, dynamic>.from(root['record'] as Map)
        : root['attendance'] is Map
        ? Map<String, dynamic>.from(root['attendance'] as Map)
        : const <String, dynamic>{};
    final shiftSource = root['shift'] ?? record['shift'];
    final shift = shiftSource is Map
        ? Map<String, dynamic>.from(shiftSource)
        : const <String, dynamic>{};
    final checkIn = _fieldAttendanceDate(
      root['checkInAt'] ?? record['checkInAt'],
    );
    final checkOut = _fieldAttendanceDate(
      root['checkOutAt'] ?? record['checkOutAt'],
    );
    final status = _dashboardFirstText([
      root['status'],
      record['status'],
      checkIn == null ? 'Not Checked In' : 'Checked In',
    ]);
    final schedule = _dashboardFirstText([
      shift['scheduleLabel'],
      _fieldShiftSchedule(shift),
    ]);
    final shiftLabel = [
      _dashboardText(shift['name']),
      schedule,
    ].where((value) => value.isNotEmpty).join('  ');
    return _FieldAttendanceData(
      status: status,
      shiftLabel: shiftLabel.isEmpty ? 'No shift assigned' : shiftLabel,
      checkInAt: checkIn,
      checkOutAt: checkOut,
      canPunchIn: root['canPunchIn'] is bool
          ? root['canPunchIn'] as bool
          : checkIn == null,
      canPunchOut: root['canPunchOut'] is bool
          ? root['canPunchOut'] as bool
          : checkIn != null && checkOut == null,
    );
  }

  final String status;
  final String shiftLabel;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool canPunchIn;
  final bool canPunchOut;

  String get checkInLabel => _fieldPunchTime(checkInAt);
  String get checkOutLabel => _fieldPunchTime(checkOutAt);

  Color get statusColor {
    final value = status.toLowerCase();
    if (value.contains('not checked') || value.contains('absent')) {
      return const Color(0xFFFF6B00);
    }
    if (value.contains('late') || value.contains('half')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }
}

DateTime? _fieldAttendanceDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String _fieldPunchTime(DateTime? value) {
  if (value == null) return '--';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '${hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')} '
      '${value.hour < 12 ? 'AM' : 'PM'}';
}

String _fieldShiftSchedule(Map<String, dynamic> shift) {
  final start = _fieldMinutesLabel(shift['startTimeMinutes']);
  final end = _fieldMinutesLabel(shift['endTimeMinutes']);
  return start.isEmpty || end.isEmpty ? '' : '($start - $end)';
}

String _fieldMinutesLabel(Object? value) {
  final minutes = value is num ? value.toInt() : int.tryParse('$value');
  if (minutes == null) return '';
  final hour24 = minutes ~/ 60;
  final minute = minutes % 60;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')} '
      '${hour24 < 12 ? 'am' : 'pm'}';
}

class _ExecutiveMetricCard extends StatelessWidget {
  const _ExecutiveMetricCard({required this.data});

  final _ExecutiveMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 118.h),
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
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
              Icon(data.icon, size: 25.sp, color: data.iconColor),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 26.sp,
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
      _ExecutiveMetricData(
        title: 'Visits Pending\nStart',
        value: '${data.visitsPendingStart}',
        icon: Icons.assignment_turned_in_outlined,
        iconColor: const Color(0xFFF97316),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        mainAxisExtent: 122.h,
      ),
      itemBuilder: (_, index) => _ExecutiveMetricCard(data: metrics[index]),
    );
  }
}

class _UpcomingSiteVisitsCard extends StatelessWidget {
  const _UpcomingSiteVisitsCard({
    required this.items,
    required this.onViewSchedule,
  });

  final List<String> items;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s Upcoming Site Visits',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0xFFF0F1FF),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Text(
                      'No site visits scheduled for today',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < items.take(3).length; index++) ...[
              _ExecutiveActivityRow(text: items[index]),
              if (index != items.take(3).length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: const Divider(height: 1),
                ),
            ],
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewSchedule,
              child: const Text('View Full Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyDayCard extends StatelessWidget {
  const _MyDayCard({required this.data, required this.onViewSchedule});

  final _FieldDashboardData data;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Today’s visits:', data.myDayTodaysVisits),
      ('Follow-ups today:', data.myDayFollowUpsToday),
      ('Visits pending start:', data.myDayCheckInsPending),
      ('Completed visits:', data.myDayCompletedVisits),
    ];
    return _ExecutiveSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFFF97316)),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'My Day',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          for (final row in rows)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Text(
                    '${row.$2}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next visit:',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  data.myDayNextVisit.isEmpty ? '-' : data.myDayNextVisit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewSchedule,
              child: const Text('View My Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveRouteMapCard extends StatelessWidget {
  const _ExecutiveRouteMapCard({required this.stops, required this.points});

  static const _mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  final List<String> stops;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    final ready = _mapsApiKey.isNotEmpty && points.isNotEmpty;
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s Route on Google Maps',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  ready ? 'Live route' : 'Planned route',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: 180.h,
              width: double.infinity,
              child: ready
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: points.first,
                        zoom: 12,
                      ),
                      markers: {
                        for (var index = 0; index < points.length; index++)
                          Marker(
                            markerId: MarkerId('route-stop-$index'),
                            position: points[index],
                            infoWindow: InfoWindow(
                              title: index < stops.length
                                  ? stops[index]
                                  : 'Stop ${index + 1}',
                            ),
                          ),
                      },
                      polylines: {
                        if (points.length > 1)
                          Polyline(
                            polylineId: const PolylineId('today-route'),
                            points: points,
                            color: AppColors.orangeDeep,
                            width: 5,
                          ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    )
                  : Container(
                      color: const Color(0xFFF1F5F9),
                      padding: EdgeInsets.all(18.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            size: 38,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(height: 9.h),
                          Text(
                            _mapsApiKey.isEmpty
                                ? 'Configure GOOGLE_MAPS_API_KEY to enable the live route map.'
                                : 'Route coordinates are not available from the API yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              height: 1.4,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicSiteVisitFunnelCard extends StatelessWidget {
  const _DynamicSiteVisitFunnelCard({required this.data});

  final _FieldDashboardData data;

  @override
  Widget build(BuildContext context) {
    final rows = data.funnel.isEmpty
        ? [
            _VisitFunnelData('Scheduled', data.todaySiteVisits),
            _VisitFunnelData('Checked In', data.checkedIn),
            _VisitFunnelData('Visit Completed', data.completedVisits),
          ]
        : data.funnel;
    final maximum = rows
        .map((item) => item.value)
        .fold<int>(1, (value, item) => item > value ? item : value);
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Visit Funnel Overview',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 16.h),
          for (var index = 0; index < rows.length; index++) ...[
            Text(
              '${rows[index].label} (${rows[index].value})',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 7.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(99.r),
              child: LinearProgressIndicator(
                value: rows[index].value / maximum,
                minHeight: 7.h,
                backgroundColor: const Color(0xFFE9EAFE),
                color: index == rows.length - 1
                    ? AppColors.orangeDeep
                    : const Color(0xFFB9C5F5),
              ),
            ),
            if (index != rows.length - 1) SizedBox(height: 13.h),
          ],
        ],
      ),
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
  const _ExecutiveSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
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
              fontSize: 21.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          if (items.length >= 4) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CheckInMetricTile(item: items[0])),
                SizedBox(width: 20.w),
                Expanded(child: _CheckInMetricTile(item: items[1])),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CheckInMetricTile(item: items[2])),
                SizedBox(width: 20.w),
                Expanded(child: _CheckInMetricTile(item: items[3])),
              ],
            ),
          ],
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          item.value,
          style: GoogleFonts.inter(
            fontSize: 30.sp,
            fontWeight: FontWeight.w700,
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

class _VisitFunnelData {
  const _VisitFunnelData(this.label, this.value);

  final String label;
  final int value;
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
    this.routePoints = const [],
    this.myDayTodaysVisits = 0,
    this.myDayFollowUpsToday = 0,
    this.myDayCheckInsPending = 0,
    this.myDayCompletedVisits = 0,
    this.myDayNextVisit = '',
    this.funnel = const [],
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
  final List<LatLng> routePoints;
  final int myDayTodaysVisits;
  final int myDayFollowUpsToday;
  final int myDayCheckInsPending;
  final int myDayCompletedVisits;
  final String myDayNextVisit;
  final List<_VisitFunnelData> funnel;

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
    final kpis = _dashboardMap(root['kpis']);
    final myDay = _dashboardMap(root['myDay']);
    final checkInStatus = _dashboardMap(root['checkInStatus']);
    final firstName = _dashboardText(user['firstName'] ?? session['firstName']);
    final lastName = _dashboardText(user['lastName'] ?? session['lastName']);
    final combinedName = '$firstName $lastName'.trim();
    final alerts = _dashboardTextList(
      root['followUps'] ??
          _dashboardValue(root, const [
            'alerts',
            'notifications',
            'pendingAlerts',
          ]),
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
        'todaySchedule',
        'routeStops',
        'stops',
        'todayVisits',
        'visitsToday',
      ]),
      stop: true,
    );
    final routePoints = _dashboardRoutePoints(
      _dashboardValue(root, const [
        'todayStops',
        'todaySchedule',
        'routeStops',
        'stops',
        'todayVisits',
        'visitsToday',
        'route',
      ]),
    );
    final funnel = _dashboardFunnel(root['funnel']);

    return _FieldDashboardData(
      employeeName: _dashboardFirstText([
        user['name'],
        user['fullName'],
        combinedName,
        session['name'],
        session['fullName'],
      ]),
      assignedLeads: _dashboardInt(kpis, const [
        'assignedLeads',
        'assignedLeadCount',
        'totalAssignedLeads',
      ]),
      todaySiteVisits: _dashboardInt(kpis, const [
        'todaySiteVisits',
        'todaysSiteVisits',
        'todaysVisits',
        'visitsToday',
      ]),
      upcomingVisits: _dashboardInt(kpis, const [
        'upcomingVisits',
        'upcomingSiteVisits',
      ]),
      completedVisits: _dashboardInt(kpis, const [
        'completedVisits',
        'completedSiteVisits',
      ]),
      missedVisits: _dashboardInt(kpis, const [
        'missedVisits',
        'missedSiteVisits',
      ]),
      pendingFollowUps: _dashboardInt(kpis, const [
        'pendingFollowUps',
        'pendingFollowups',
        'followUpsPending',
      ]),
      bookingsAssisted: _dashboardInt(kpis, const [
        'bookingsAssisted',
        'assistedBookings',
        'bookingCount',
      ]),
      visitsPendingStart: _dashboardInt(kpis, const [
        'visitsPendingStart',
        'pendingStartVisits',
        'notStartedVisits',
        'checkInsPending',
      ]),
      checkedIn: _dashboardInt(checkInStatus, const [
        'checkedIn',
        'checkedInCount',
        'checkIns',
      ]),
      pendingCheckIns: _dashboardInt(checkInStatus, const [
        'pendingCheckIns',
        'pendingCheckIn',
        'checkInPending',
        'pending',
      ]),
      checkedOut: _dashboardInt(checkInStatus, const [
        'checkedOut',
        'checkedOutCount',
        'checkOuts',
      ]),
      missedCheckIns: _dashboardInt(checkInStatus, const [
        'missedCheckIns',
        'missedCheckIn',
        'checkInMissed',
      ]),
      alerts: alerts,
      activities: activities,
      todayStops: stops,
      routePoints: routePoints,
      myDayTodaysVisits: _dashboardInt(myDay, const ['todaysVisits']),
      myDayFollowUpsToday: _dashboardInt(myDay, const ['followUpsToday']),
      myDayCheckInsPending: _dashboardInt(myDay, const ['checkInsPending']),
      myDayCompletedVisits: _dashboardInt(myDay, const ['completedVisits']),
      myDayNextVisit: _dashboardText(myDay['nextVisit']),
      funnel: funnel,
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
        final nextAction = _dashboardText(map['nextAction']);
        if (nextAction.isNotEmpty) {
          return [
            _dashboardText(map['leadName']),
            nextAction,
          ].where((part) => part.isNotEmpty).join(' • ');
        }
        final title = _dashboardText(map['title']);
        final description = _dashboardText(map['description']);
        if (title.isNotEmpty || description.isNotEmpty) {
          return [
            title,
            description,
          ].where((part) => part.isNotEmpty).join(' — ');
        }
        return _dashboardFirstText([
          map['message'],
          map['activity'],
          map['text'],
          map['name'],
        ]);
      })
      .where((text) => text.isNotEmpty)
      .toList();
}

List<_VisitFunnelData> _dashboardFunnel(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return _VisitFunnelData(
          _dashboardText(map['label']),
          _dashboardInt(map, const ['value', 'count']),
        );
      })
      .where((item) => item.label.isNotEmpty)
      .toList();
}

List<LatLng> _dashboardRoutePoints(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    value =
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['data'] ??
        map['visits'] ??
        map['stops'] ??
        map['route'];
  }
  if (value is! List) return const [];
  final points = <LatLng>[];
  for (final item in value) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final location = map['location'] is Map
        ? Map<String, dynamic>.from(map['location'] as Map)
        : map['coordinates'] is Map
        ? Map<String, dynamic>.from(map['coordinates'] as Map)
        : map['project'] is Map
        ? Map<String, dynamic>.from(map['project'] as Map)
        : const <String, dynamic>{};
    final latitude = _dashboardCoordinate(
      map['latitude'] ?? map['lat'] ?? location['latitude'] ?? location['lat'],
    );
    final longitude = _dashboardCoordinate(
      map['longitude'] ??
          map['lng'] ??
          map['lon'] ??
          location['longitude'] ??
          location['lng'] ??
          location['lon'],
    );
    if (latitude != null && longitude != null) {
      points.add(LatLng(latitude, longitude));
    }
  }
  return points;
}

double? _dashboardCoordinate(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}
