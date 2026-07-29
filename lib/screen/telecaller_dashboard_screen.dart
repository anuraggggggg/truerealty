import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/notification_provider.dart';
import 'package:truerealtycrm/provider/upload_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/telecaller_activities_screen.dart';

const double _telecallerMetricIconSize = 24;
const double _telecallerSectionIconSize = 26;
const double _telecallerQuickActionIconSize = 26;

class TelecallerDashboardScreen extends StatelessWidget {
  const TelecallerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F6FB),
      body: SafeArea(child: TelecallerDashboardView()),
    );
  }
}

class TelecallerDashboardView extends StatefulWidget {
  const TelecallerDashboardView({
    super.key,
    this.onMenuTap,
    this.bottomSpacing = 16,
  });

  final VoidCallback? onMenuTap;
  final double bottomSpacing;

  @override
  State<TelecallerDashboardView> createState() =>
      _TelecallerDashboardViewState();
}

class _TelecallerDashboardViewState extends State<TelecallerDashboardView> {
  static const List<_MetricCardData> _topRows = [
    _MetricCardData(
      title: 'TOTAL ASSIGNED\nLEADS',
      value: '05',
      icon: Icons.groups_outlined,
      color: Color(0xFF2563EB),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'NEW LEADS',
      value: '00',
      icon: Icons.sell_outlined,
      color: Color(0xFF22C55E),
      badge: 'Today',
      badgeBackground: Color(0xFFE8F8EC),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'TODAY\'S\nFOLLOWUPS',
      value: '00',
      icon: Icons.person_search_outlined,
      color: Color(0xFFF97316),
      badge: 'Today',
      badgeBackground: Color(0xFFFFF1E8),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'MISSED\nFOLLOW-UPS',
      value: '05',
      icon: Icons.person_remove_outlined,
      color: Color(0xFFEF4444),
      badge: 'Overdue',
      badgeBackground: Color(0xFFFFEBEE),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'HOT LEADS',
      value: '00',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFEF4444),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'COLD LEADS',
      value: '00',
      icon: Icons.ac_unit_rounded,
      color: Color(0xFF3B82F6),
      cardHeight: 132,
    ),
  ];

  static const List<_MetricCardData> _bottomRows = [
    _MetricCardData(
      title: 'INTERESTED LEADS',
      value: '05',
      icon: Icons.thumb_up_alt_outlined,
      color: Color(0xFF22C55E),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'NOT INTERESTED',
      value: '00',
      icon: Icons.thumb_down_alt_outlined,
      color: Color(0xFFA855F7),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'SITE VISIT SCHEDULED',
      value: '00',
      icon: Icons.calendar_today_outlined,
      color: Color(0xFF9333EA),
      cardHeight: 132,
    ),
    _MetricCardData(
      title: 'CONVERTED\nLEADS',
      value: '00',
      icon: Icons.check_circle_outline_rounded,
      color: Color(0xFF16A34A),
      badge: 'This Month',
      badgeBackground: Color(0xFFE8F8EC),
      cardHeight: 132,
    ),
  ];

  List<LeadModel> _leads = const [];
  List<_FollowUpDashboardItem> _followUps = const [];
  List<_TelecallerNotificationItem> _notifications = const [];
  bool _isLoading = true;
  bool _hasLoaded = false;
  bool _attendanceActionLoading = false;
  String? _error;
  _TodayAttendanceData _todayAttendance = const _TodayAttendanceData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  Future<void> _loadDashboardData({bool force = false}) async {
    if (_isLoading && _hasLoaded && !force) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final leadProvider = context.read<LeadProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final leadsResponse = await leadProvider.fetchLeads(limit: 500);
    final followUpsResponse = await leadProvider.fetchFollowUps(limit: 500);
    final notificationsResponse = await notificationProvider.fetchNotifications(
      limit: 20,
    );
    final attendanceResponse = await attendanceProvider.fetchTodayAttendance();

    if (!mounted) {
      return;
    }

    final parsedLeads = leadsResponse == null
        ? leadProvider.leads
        : _extractLeadItems(
            leadsResponse.data,
          ).map(LeadModel.fromJson).toList();
    final parsedFollowUps = followUpsResponse == null
        ? const <_FollowUpDashboardItem>[]
        : _extractApiList(
            followUpsResponse.data,
          ).map(_FollowUpDashboardItem.fromJson).toList();
    final parsedNotifications = notificationsResponse?.data == null
        ? _notifications
        : _extractApiList(
            notificationsResponse?.data,
          ).map(_TelecallerNotificationItem.fromJson).toList();

    setState(() {
      _leads = parsedLeads;
      _followUps = parsedFollowUps;
      _notifications = parsedNotifications;
      _todayAttendance = _TodayAttendanceData.fromApi(attendanceResponse?.data);
      _error =
          leadsResponse == null ||
              followUpsResponse == null ||
              notificationsResponse == null
          ? leadProvider.error ??
                notificationProvider.error ??
                'Unable to refresh dashboard data.'
          : null;
      _isLoading = false;
      _hasLoaded = true;
    });
  }

  _TelecallerDashboardSummary get _summary {
    return _TelecallerDashboardSummary.fromData(
      leads: _leads,
      followUps: _followUps,
      now: DateTime.now(),
    );
  }

  List<_MetricCardData> _metricRows(
    List<_MetricCardData> templates,
    Map<String, int> values,
  ) {
    return templates
        .map((item) => item.copyWith(value: _formatCount(values[item.title])))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = 302.h;
    final user = context.watch<AuthProvider>().session?.user;
    final userName = (user?['fullName'] ?? user?['name'] ?? 'Telecaller')
        .toString()
        .trim();
    final summary = _summary;
    final topRows = _metricRows(_topRows, {
      'TOTAL ASSIGNED\nLEADS': summary.totalLeads,
      'NEW LEADS': summary.newLeads,
      'TODAY\'S\nFOLLOWUPS': summary.todayFollowUps,
      'MISSED\nFOLLOW-UPS': summary.missedFollowUps,
      'HOT LEADS': summary.hotLeads,
      'COLD LEADS': summary.coldLeads,
    });
    final bottomRows = _metricRows(_bottomRows, {
      'INTERESTED LEADS': summary.interestedLeads,
      'NOT INTERESTED': summary.notInterestedLeads,
      'SITE VISIT SCHEDULED': summary.siteVisitScheduledLeads,
      'CONVERTED\nLEADS': summary.convertedLeads,
    });

    return RefreshIndicator(
      color: AppColors.orangeDeep,
      onRefresh: () => _loadDashboardData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading && !_hasLoaded) const LinearProgressIndicator(),
            Stack(
              children: [
                SizedBox(
                  height:
                      headerHeight +
                      66.h, // Extra room for scaled header content
                  width: double.infinity,
                  child: _DashboardHeader(
                    userName: userName.isEmpty ? 'Telecaller' : userName,
                    notificationCount: _unreadNotificationCount,
                    onNotificationTap: _openNotifications,
                    onProfileTap: _openProfile,
                    onAddLeadTap: () =>
                        Navigator.of(context).pushNamed(AppRouter.addLead),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 180.h, left: 16.w, right: 16.w),
                  child: _DashboardPanel(
                    topRows: topRows,
                    bottomRows: bottomRows,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    _DashboardDataStateCard(
                      message: _error!,
                      onRetry: () => _loadDashboardData(force: true),
                    ),
                    const _SectionGap(),
                  ],
                  _LeadStatusDistributionSection(summary: summary),
                  const _SectionGap(),
                  _ConversionFunnelSection(summary: summary),
                  const _SectionGap(),
                  _TodayTasksSection(summary: summary),
                  const _SectionGap(),
                  const _SiteVisitsSection(),
                  const _SectionGap(),
                  _UpcomingFollowUpsSection(items: summary.upcomingFollowUps),
                  const _SectionGap(),
                  _ActionOnlySection(
                    title: 'Recent Activities',
                    actionText: 'View All Activities',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TelecallerActivitiesScreen(),
                      ),
                    ),
                  ),
                  const _SectionGap(),
                  _TodayPunchCard(
                    data: _todayAttendance,
                    isLoading: _attendanceActionLoading,
                    onPunchIn: _openPunchIn,
                    onPunchOut: _punchOut,
                  ),
                  const _SectionGap(),
                  _PerformanceSection(summary: summary),
                  const _SectionGap(),
                  _SlaActionQueueSection(summary: summary),
                  const _SectionGap(),
                  const _DailyCallingTrendSection(),
                  SizedBox(height: widget.bottomSpacing.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPunchIn() async {
    final imagePath = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PunchInSelfieDialog(),
    );
    if (imagePath == null || !mounted) return;

    setState(() => _attendanceActionLoading = true);
    final uploadProvider = context.read<UploadProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final uploadResponse = await uploadProvider.uploadImage(imagePath);
    final imageUrl = _extractUploadedImageUrl(uploadResponse?.data);
    if (imageUrl == null) {
      if (mounted) {
        setState(() => _attendanceActionLoading = false);
        _showAttendanceMessage(
          uploadProvider.error ?? 'Unable to upload the punch-in selfie.',
        );
      }
      return;
    }

    final response = await attendanceProvider.punchIn(
      checkInImageUrl: imageUrl,
    );
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(attendanceProvider.error ?? 'Unable to punch in.');
      return;
    }
    await _refreshTodayAttendance();
    _showAttendanceMessage('Punch in completed successfully.');
  }

  Future<void> _punchOut() async {
    setState(() => _attendanceActionLoading = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.punchOut();
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(provider.error ?? 'Unable to punch out.');
      return;
    }
    await _refreshTodayAttendance();
    _showAttendanceMessage('Punch out completed successfully.');
  }

  Future<void> _refreshTodayAttendance() async {
    final response = await context
        .read<AttendanceProvider>()
        .fetchTodayAttendance();
    if (!mounted) return;
    setState(() {
      _todayAttendance = _TodayAttendanceData.fromApi(response?.data);
      _attendanceActionLoading = false;
    });
  }

  void _showAttendanceMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int get _unreadNotificationCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  Future<void> _openNotifications() async {
    final provider = context.read<NotificationProvider>();
    final response = await provider.fetchNotifications(limit: 20);

    if (!mounted) {
      return;
    }

    final notifications = response?.data == null
        ? _notifications
        : _extractApiList(
            response?.data,
          ).map(_TelecallerNotificationItem.fromJson).toList();

    setState(() => _notifications = notifications);

    await _showNotificationPopover(
      context: context,
      child: Builder(
        builder: (popupContext) {
          return _TelecallerNotificationsPopup(
            notifications: notifications,
            error: provider.error,
            onViewAll: () async {
              Navigator.of(popupContext).pop();
              await Navigator.of(context).pushNamed(AppRouter.notifications);
              if (!mounted) {
                return;
              }
              final refreshed = await provider.fetchNotifications(limit: 20);
              if (!mounted || refreshed?.data == null) {
                return;
              }
              setState(() {
                _notifications = _extractApiList(
                  refreshed?.data,
                ).map(_TelecallerNotificationItem.fromJson).toList();
              });
            },
            onNotificationTap: (notification) async {
              await _markNotificationRead(notification);
              if (!popupContext.mounted) {
                return;
              }
              Navigator.of(popupContext).pop();
              if (!mounted) {
                return;
              }
              Navigator.of(context).pushNamed(AppRouter.leadDetail);
            },
            onMarkAllRead: () async {
              await provider.markAllNotificationsRead();
              final refreshed = await provider.fetchNotifications(limit: 20);
              if (!mounted) {
                return;
              }
              final refreshedItems = refreshed?.data == null
                  ? _notifications.map((item) => item.copyAsRead()).toList()
                  : _extractApiList(
                      refreshed?.data,
                    ).map(_TelecallerNotificationItem.fromJson).toList();
              setState(() => _notifications = refreshedItems);
            },
          );
        },
      ),
    );
  }

  Future<void> _showNotificationPopover({
    required BuildContext context,
    required Widget child,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss notifications',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _TelecallerNotificationPopoverFrame(child: child);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _openProfile() {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss profile menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _TelecallerProfilePopoverFrame(
          child: _TelecallerProfilePopup(
            onProfileTap: (popupContext) {
              Navigator.of(popupContext).pop();
              Navigator.of(context).pushNamed(AppRouter.profile);
            },
            onSettingsTap: (popupContext) {
              Navigator.of(popupContext).pop();
              Navigator.of(context).pushNamed(AppRouter.personalSettings);
            },
            onSignOutTap: (popupContext) {
              Navigator.of(popupContext).pop();
              Navigator.of(context).pushNamed(AppRouter.logoutConfirmation);
            },
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _markNotificationRead(
    _TelecallerNotificationItem notification,
  ) async {
    if (notification.id == null || notification.isRead) {
      return;
    }

    await context.read<NotificationProvider>().markNotificationRead(
      notification.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _notifications = _notifications
          .map((item) => item.id == notification.id ? item.copyAsRead() : item)
          .toList();
    });
  }
}

class _DashboardDataStateCard extends StatelessWidget {
  const _DashboardDataStateCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFEF4444),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingFollowUpsSection extends StatelessWidget {
  const _UpcomingFollowUpsSection({required this.items});

  final List<_FollowUpDashboardItem> items;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(3).toList();

    return _SectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle('Upcoming Follow-ups', fontSize: 17),
              ),
              InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.myFollowUps),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                  child: Text(
                    'View All Follow-ups ›',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF97316),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (visibleItems.isEmpty)
            _InlineEmptyState(
              icon: Icons.event_available_outlined,
              message: 'No upcoming follow-ups.',
            )
          else
            for (int i = 0; i < visibleItems.length; i++) ...[
              _FollowUpListTile(item: visibleItems[i]),
              if (i != visibleItems.length - 1) ...[
                SizedBox(height: 12.h),
                const Divider(height: 1, color: Color(0xFFE6ECF4)),
                SizedBox(height: 12.h),
              ],
            ],
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: const Color(0xFF98A2B3)),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpListTile extends StatelessWidget {
  const _FollowUpListTile({required this.item});

  final _FollowUpDashboardItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.lead == null
          ? null
          : () => Navigator.of(context).pushNamed(
              AppRouter.leadDetail,
              arguments: LeadModel.fromJson(item.lead),
            ),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFFFF1E8),
              child: Icon(
                Icons.event_note_outlined,
                color: const Color(0xFFF97316),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.leadName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.project,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: item.isOverdue
                        ? const Color(0xFFFFE8E8)
                        : const Color(0xFFE8F8EC),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: item.isOverdue
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF16A34A),
                    ),
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

class _TelecallerDashboardSummary {
  const _TelecallerDashboardSummary({
    required this.totalLeads,
    required this.newLeads,
    required this.todayFollowUps,
    required this.missedFollowUps,
    required this.hotLeads,
    required this.coldLeads,
    required this.interestedLeads,
    required this.notInterestedLeads,
    required this.siteVisitScheduledLeads,
    required this.convertedLeads,
    required this.todayCallFollowUps,
    required this.dueNextHour,
    required this.missedSla,
    required this.needsImmediateResponse,
    required this.upcomingFollowUps,
  });

  final int totalLeads;
  final int newLeads;
  final int todayFollowUps;
  final int missedFollowUps;
  final int hotLeads;
  final int coldLeads;
  final int interestedLeads;
  final int notInterestedLeads;
  final int siteVisitScheduledLeads;
  final int convertedLeads;
  final int todayCallFollowUps;
  final int dueNextHour;
  final int missedSla;
  final int needsImmediateResponse;
  final List<_FollowUpDashboardItem> upcomingFollowUps;

  String get conversionRateLabel {
    if (totalLeads == 0) {
      return '0.0%';
    }
    return '${((convertedLeads / totalLeads) * 100).toStringAsFixed(1)}%';
  }

  factory _TelecallerDashboardSummary.fromData({
    required List<LeadModel> leads,
    required List<_FollowUpDashboardItem> followUps,
    required DateTime now,
  }) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final nextHour = now.add(const Duration(hours: 1));
    final activeFollowUps = followUps.where((item) => !item.isClosed).toList();
    final todayFollowUps = activeFollowUps
        .where(
          (item) =>
              item.scheduledAt != null && _isSameDay(item.scheduledAt!, now),
        )
        .length;
    final missedFollowUps = activeFollowUps
        .where(
          (item) =>
              item.scheduledAt != null &&
              item.scheduledAt!.isBefore(todayStart),
        )
        .length;
    final dueNextHour = activeFollowUps
        .where(
          (item) =>
              item.scheduledAt != null &&
              !item.scheduledAt!.isBefore(now) &&
              item.scheduledAt!.isBefore(nextHour),
        )
        .length;
    final missedSla = activeFollowUps.where((item) {
      if (item.slaDueAt == null) {
        return item.scheduledAt != null &&
            item.scheduledAt!.isBefore(todayStart);
      }
      return item.slaDueAt!.isBefore(now);
    }).length;
    final upcoming =
        activeFollowUps
            .where(
              (item) =>
                  item.scheduledAt != null &&
                  (item.scheduledAt!.isAfter(now) ||
                      _isSameDay(item.scheduledAt!, now)),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));

    return _TelecallerDashboardSummary(
      totalLeads: leads.length,
      newLeads: leads.where((lead) => _isLeadCreatedToday(lead, now)).length,
      todayFollowUps: todayFollowUps,
      missedFollowUps: missedFollowUps,
      hotLeads: leads.where(_isHotLead).length,
      coldLeads: leads.where(_isColdLead).length,
      interestedLeads: leads.where(_isInterestedLead).length,
      notInterestedLeads: leads.where(_isNotInterestedLead).length,
      siteVisitScheduledLeads: leads.where(_isSiteVisitScheduledLead).length,
      convertedLeads: leads.where(_isConvertedLead).length,
      todayCallFollowUps: activeFollowUps
          .where(
            (item) =>
                item.type.toLowerCase().contains('call') &&
                item.scheduledAt != null &&
                item.scheduledAt!.isAfter(todayStart) &&
                item.scheduledAt!.isBefore(tomorrowStart),
          )
          .length,
      dueNextHour: dueNextHour,
      missedSla: missedSla,
      needsImmediateResponse: missedFollowUps + dueNextHour,
      upcomingFollowUps: upcoming,
    );
  }
}

class _FollowUpDashboardItem {
  const _FollowUpDashboardItem({
    required this.id,
    required this.leadId,
    required this.lead,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.completedAt,
    required this.slaDueAt,
    required this.notes,
    required this.nextAction,
    required this.leadName,
    required this.project,
  });

  final String? id;
  final String? leadId;
  final Map<String, dynamic>? lead;
  final String type;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? slaDueAt;
  final String? notes;
  final String? nextAction;
  final String leadName;
  final String project;

  bool get isClosed {
    final normalized = status.toLowerCase();
    return completedAt != null ||
        normalized.contains('completed') ||
        normalized.contains('done') ||
        normalized.contains('cancelled') ||
        normalized.contains('canceled') ||
        normalized.contains('closed');
  }

  bool get isOverdue {
    final date = scheduledAt;
    if (date == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !isClosed && date.isBefore(today);
  }

  String get statusLabel => isOverdue ? 'Overdue' : status;

  String get timeLabel {
    final date = scheduledAt;
    if (date == null) {
      return 'Not set';
    }
    return _formatFollowUpTime(date);
  }

  factory _FollowUpDashboardItem.fromJson(Object? source) {
    final map = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    final leadValue = map['lead'];
    final lead = leadValue is Map ? Map<String, dynamic>.from(leadValue) : null;
    final leadRequirement = lead?['requirement'] is Map
        ? Map<String, dynamic>.from(lead?['requirement'] as Map)
        : const <String, dynamic>{};

    return _FollowUpDashboardItem(
      id: _readString(map, const ['id', '_id', 'followUpId']),
      leadId:
          _readString(map, const ['leadId', 'lead_id']) ??
          _readString(lead, const ['id', '_id', 'leadId']),
      lead: lead,
      type:
          _readString(map, const ['typeName', 'typeId', 'type']) ?? 'Follow-up',
      status:
          _readString(map, const ['statusName', 'statusId', 'status']) ??
          'Scheduled',
      scheduledAt: _readDate(map, const [
        'scheduledAt',
        'followUpDate',
        'dueAt',
      ]),
      completedAt: _readDate(map, const ['completedAt', 'completed_at']),
      slaDueAt: _readDate(map, const ['slaDueAt', 'sla_due_at']),
      notes: _readString(map, const ['notes', 'remarks']),
      nextAction: _readString(map, const ['nextAction', 'next_action']),
      leadName:
          _readString(lead, const ['name', 'leadName', 'customerName']) ??
          'Unknown Lead',
      project:
          _readString(lead, const ['projectName', 'project']) ??
          _readString(leadRequirement, const ['preferredProjectId']) ??
          _readString(leadRequirement, const ['preferredLocation']) ??
          'Project not available',
    );
  }
}

class _TelecallerNotificationItem {
  const _TelecallerNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.message,
    required this.badge,
    required this.entityId,
    required this.leadId,
    required this.leadName,
    required this.leadDisplayId,
    required this.followUpType,
    required this.scheduledAt,
    required this.createdAt,
    required this.readAt,
  });

  final String? id;
  final String title;
  final String description;
  final String message;
  final String? badge;
  final String? entityId;
  final String? leadId;
  final String? leadName;
  final String? leadDisplayId;
  final String? followUpType;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  String get subtitle {
    if (message.isNotEmpty) {
      return message;
    }
    if (description.isNotEmpty) {
      return description;
    }
    return 'Notification update';
  }

  String get leadLabel {
    if (leadName == null && leadDisplayId == null) {
      return badge ?? 'Telecaller';
    }
    if (leadName == null) {
      return leadDisplayId!;
    }
    if (leadDisplayId == null) {
      return leadName!;
    }
    return '$leadName • $leadDisplayId';
  }

  _TelecallerNotificationItem copyAsRead() {
    return _TelecallerNotificationItem(
      id: id,
      title: title,
      description: description,
      message: message,
      badge: badge,
      entityId: entityId,
      leadId: leadId,
      leadName: leadName,
      leadDisplayId: leadDisplayId,
      followUpType: followUpType,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }

  factory _TelecallerNotificationItem.fromJson(Object? source) {
    final map = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    final detailsValue = map['details'];
    final details = detailsValue is Map
        ? Map<String, dynamic>.from(detailsValue)
        : const <String, dynamic>{};

    return _TelecallerNotificationItem(
      id: _readString(map, const ['id', '_id', 'notificationId']),
      title: _readString(map, const ['title']) ?? 'Notification',
      description: _readString(map, const ['description']) ?? '',
      message: _readString(map, const ['message']) ?? '',
      badge: _readString(map, const ['badge', 'type']),
      entityId: _readString(map, const ['entityId', 'entity_id']),
      leadId:
          _readString(details, const ['leadId', 'lead_id']) ??
          _readString(map, const ['leadId', 'entityId']),
      leadName: _readString(details, const ['leadName', 'name']),
      leadDisplayId: _readString(details, const ['leadDisplayId', 'displayId']),
      followUpType: _readString(details, const ['followUpType', 'type']),
      scheduledAt: _readDate(details, const ['scheduledAt']),
      createdAt: _readDate(map, const ['createdAt', 'created_at']),
      readAt: _readDate(map, const ['readAt', 'read_at']),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.userName,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onAddLeadTap,
  });

  final String userName;
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onAddLeadTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 64.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5EAF2))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 112.w,
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const Spacer(),
                _AddLeadHeaderButton(onTap: onAddLeadTap),
                SizedBox(width: 10.w),
                _HeaderIcon(
                  icon: Icons.notifications_none_rounded,
                  badgeText: _formatBadgeCount(notificationCount),
                  onTap: onNotificationTap,
                ),
                SizedBox(width: 10.w),
                _TelecallerProfileButton(onTap: onProfileTap),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telecaller Dashboard',
                    style: GoogleFonts.inter(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "Welcome back, $userName. Here's today's overview.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
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

class _AddLeadHeaderButton extends StatelessWidget {
  const _AddLeadHeaderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.orangeDeep,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          height: 36.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
                SizedBox(width: 5.w),
                Text(
                  'Add Lead',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TelecallerProfileButton extends StatelessWidget {
  const _TelecallerProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: const Color(0xFFEFF4FA),
        child: Text(
          'TE',
          style: GoogleFonts.inter(
            color: AppColors.navy,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.badgeText, this.onTap});

  final IconData icon;
  final String badgeText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: 34.w,
        height: 34.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Icon(icon, color: AppColors.navy, size: 25.sp),
            ),
            if (badgeText.isNotEmpty)
              Positioned(
                top: -3.h,
                right: -5.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A1A),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.inter(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

class _TelecallerNotificationPopoverFrame extends StatelessWidget {
  const _TelecallerNotificationPopoverFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(34.w, 42.h, 16.w, 0),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 300.w, maxWidth: 360.w),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TelecallerNotificationsPopup extends StatefulWidget {
  const _TelecallerNotificationsPopup({
    required this.notifications,
    required this.error,
    required this.onViewAll,
    required this.onNotificationTap,
    required this.onMarkAllRead,
  });

  final List<_TelecallerNotificationItem> notifications;
  final String? error;
  final VoidCallback onViewAll;
  final Future<void> Function(_TelecallerNotificationItem notification)
  onNotificationTap;
  final Future<void> Function() onMarkAllRead;

  @override
  State<_TelecallerNotificationsPopup> createState() =>
      _TelecallerNotificationsPopupState();
}

class _TelecallerNotificationsPopupState
    extends State<_TelecallerNotificationsPopup> {
  late List<_TelecallerNotificationItem> _notifications = widget.notifications;
  bool _isMarkingAllRead = false;

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications
        .where((notification) => !notification.isRead)
        .length;

    return _NotificationPopoverSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 10.w, 0),
            child: SizedBox(
              height: 44.h,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    TextButton(
                      onPressed: _isMarkingAllRead
                          ? null
                          : () async {
                              setState(() => _isMarkingAllRead = true);
                              await widget.onMarkAllRead();
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _notifications = _notifications
                                    .map((item) => item.copyAsRead())
                                    .toList();
                                _isMarkingAllRead = false;
                              });
                            },
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1.h, color: const Color(0xFFE1E7F0)),
          if (_isMarkingAllRead) const LinearProgressIndicator(minHeight: 2),
          if (widget.error != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
              child: Text(
                widget.error!,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB91C1C),
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _notifications.isEmpty ? 92.h : 0,
              maxHeight: 340.h,
            ),
            child: _notifications.isEmpty
                ? const _InlineEmptyState(
                    icon: Icons.notifications_none_rounded,
                    message: 'No notifications yet.',
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1.h,
                      indent: 16.w,
                      endIndent: 16.w,
                      color: const Color(0xFFE6ECF4),
                    ),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return _NotificationListTile(
                        item: item,
                        onTap: () async {
                          await widget.onNotificationTap(item);
                          if (!mounted) {
                            return;
                          }
                          setState(() {
                            _notifications = _notifications
                                .map(
                                  (notification) => notification.id == item.id
                                      ? notification.copyAsRead()
                                      : notification,
                                )
                                .toList();
                          });
                        },
                      );
                    },
                  ),
          ),
          Divider(height: 1.h, color: const Color(0xFFE1E7F0)),
          SizedBox(
            height: 46.h,
            child: Center(
              child: TextButton(
                onPressed: widget.onViewAll,
                child: Text(
                  'View all notifications',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelecallerProfilePopoverFrame extends StatelessWidget {
  const _TelecallerProfilePopoverFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(32.w, 68.h, 16.w, 0),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 176.w, maxWidth: 196.w),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TelecallerProfilePopup extends StatelessWidget {
  const _TelecallerProfilePopup({
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onSignOutTap,
  });

  final ValueChanged<BuildContext> onProfileTap;
  final ValueChanged<BuildContext> onSettingsTap;
  final ValueChanged<BuildContext> onSignOutTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.orangeDeep, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2206172A),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
              child: Text(
                'My Account',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
            Divider(height: 1.h, color: const Color(0xFFE1E7F0)),
            _TelecallerProfileMenuItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () => onProfileTap(context),
            ),
            _TelecallerProfileMenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => onSettingsTap(context),
            ),
            Divider(height: 1.h, color: const Color(0xFFE1E7F0)),
            _TelecallerProfileMenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              onTap: () => onSignOutTap(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelecallerProfileMenuItem extends StatelessWidget {
  const _TelecallerProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              Icon(icon, color: AppColors.navy, size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPopoverSurface extends StatelessWidget {
  const _NotificationPopoverSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x2406172A),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12.r), child: child),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  const _NotificationListTile({required this.item, required this.onTap});

  final _TelecallerNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = item.isRead ? const Color(0xFF64748B) : AppColors.navy;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundColor: item.isRead
            ? const Color(0xFFF1F5F9)
            : const Color(0xFFEAF2FF),
        child: Icon(
          Icons.notifications_none_rounded,
          color: accentColor,
          size: 21.sp,
        ),
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${item.leadLabel} • ${_formatNotificationTime(item.createdAt ?? item.scheduledAt)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel({required this.topRows, required this.bottomRows});

  final List<_MetricCardData> topRows;
  final List<_MetricCardData> bottomRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x140F172A),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int row = 0; row < 2; row++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int index = 0; index < 3; index++) ...[
                  Expanded(child: _MetricCard(data: topRows[row * 3 + index])),
                  if (index != 2) SizedBox(width: 10.w),
                ],
              ],
            ),
            SizedBox(height: 14.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _MetricCard(data: bottomRows[0])),
              SizedBox(width: 14.w),
              Expanded(child: _MetricCard(data: bottomRows[1])),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _MetricCard(data: bottomRows[2])),
              SizedBox(width: 14.w),
              Expanded(child: _MetricCard(data: bottomRows[3])),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    final minHeight = (data.cardHeight ?? data.minHeight ?? 110).h;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A0F172A),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              Icon(
                data.icon,
                color: data.color,
                size: _telecallerMetricIconSize.sp,
              ),
              if (data.badge != null)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: data.badgeBackground,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.badge!,
                        maxLines: 1,
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: data.color,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 38.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                data.title,
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.42,
                  letterSpacing: -0.25,
                  color: const Color(0xFF2D2C2C),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
    this.badgeBackground = Colors.transparent,
    this.minHeight,
    this.cardHeight,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? badge;
  final Color badgeBackground;
  final double? minHeight;
  final double? cardHeight;

  _MetricCardData copyWith({String? value}) {
    return _MetricCardData(
      title: title,
      value: value ?? this.value,
      icon: icon,
      color: color,
      badge: badge,
      badgeBackground: badgeBackground,
      minHeight: minHeight,
      cardHeight: cardHeight,
    );
  }
}

class _SectionGap extends StatelessWidget {
  const _SectionGap();

  @override
  Widget build(BuildContext context) => SizedBox(height: 18.h);
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(18.w),
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
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.fontSize = 17});

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w700, // bold
        height: 1.43, // line-height: 1.43
        color: const Color(0xFF082B63),
      ),
    );
  }
}

class _SiteVisitsSection extends StatelessWidget {
  const _SiteVisitsSection();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: _SectionCard(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: _SectionTitle('Site Visits', fontSize: 19),
                ),
                InkWell(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.siteVisits),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    child: Text(
                      'View All ›',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildVisitItem(
              'Aniket Singh',
              'Lodha Amara, Thane',
              'Oct 24, 02:30 PM',
              'Scheduled',
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFE6ECF4)),
            SizedBox(height: 12.h),
            _buildVisitItem(
              'Rahul Sharma',
              'Godrej Exquisite, Thane',
              'Oct 25, 11:00 AM',
              'Scheduled',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitItem(
    String name,
    String location,
    String time,
    String status,
  ) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: const Color(0xFF2563EB),
            size: _telecallerSectionIconSize.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                location,
                style: GoogleFonts.inter(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EC),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayTasksSection extends StatelessWidget {
  const _TodayTasksSection({required this.summary});

  final _TelecallerDashboardSummary summary;

  List<_TaskStatData> get _items {
    return [
      _TaskStatData(
        icon: Icons.call_outlined,
        label: 'Make Calls',
        value: _formatCount(summary.todayFollowUps),
        iconColor: const Color(0xFF98A2B3),
        valueColor: const Color(0xFFFF6B00),
      ),
      _TaskStatData(
        icon: Icons.calendar_month_outlined,
        label: 'Follow-ups',
        value: _formatCount(summary.todayFollowUps),
        iconColor: const Color(0xFF98A2B3),
        valueColor: AppColors.navy,
      ),
      const _TaskStatData(
        icon: Icons.location_on_outlined,
        label: 'Site Visits',
        value: '0',
        iconColor: Color(0xFF98A2B3),
        valueColor: AppColors.navy,
      ),
      _TaskStatData(
        icon: Icons.ring_volume_outlined,
        label: 'Missed Follow-ups',
        value: _formatCount(summary.missedFollowUps),
        iconColor: const Color(0xFF98A2B3),
        valueColor: AppColors.navy,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle("Today's Tasks", fontSize: 19),
              ),
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B00),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _formatCount(summary.todayFollowUps),
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return SizedBox(
                  width: 102.w,
                  child: Row(
                    children: [
                      if (index != 0)
                        Container(
                          width: 1,
                          height: 76.h,
                          margin: EdgeInsets.only(right: 10.w),
                          color: const Color(0xFFE6ECF4),
                        ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              item.icon,
                              color: item.iconColor,
                              size: _telecallerSectionIconSize.sp,
                            ),
                            SizedBox(height: 7.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D2C2C),
                                ),
                              ),
                            ),
                            SizedBox(height: 7.h),
                            Text(
                              item.value,
                              style: GoogleFonts.inter(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w800,
                                color: item.valueColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionOnlySection extends StatelessWidget {
  const _ActionOnlySection({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 58),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(title),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTap,
                child: Text(
                  '$actionText ›',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    color: const Color(0xFFF97316),
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

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.summary});

  final _TelecallerDashboardSummary summary;

  List<_PerformanceData> get _items {
    return [
      _PerformanceData(
        title: 'Calls Made',
        value: _formatCount(summary.todayCallFollowUps),
        icon: Icons.call_outlined,
        color: const Color(0xFFFF6B00),
      ),
      const _PerformanceData(
        title: 'Connected',
        value: '00',
        icon: Icons.add_ic_call_outlined,
        color: Color(0xFF10B981),
      ),
      _PerformanceData(
        title: 'Missed',
        value: _formatCount(summary.missedFollowUps),
        icon: Icons.call_split_outlined,
        color: const Color(0xFFFF6B00),
      ),
      _PerformanceData(
        title: 'Follow-ups',
        value: _formatCount(summary.todayFollowUps),
        icon: Icons.event_note_outlined,
        color: const Color(0xFF2563EB),
      ),
      const _PerformanceData(
        title: 'Site Visits',
        value: '00',
        icon: Icons.location_on_outlined,
        color: Color(0xFFEF4444),
      ),
      _PerformanceData(
        title: 'Conv. Rate',
        value: summary.conversionRateLabel,
        icon: Icons.check_circle_outline,
        color: const Color(0xFFD946EF),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
          child: const _SectionTitle('My Performance Today', fontSize: 19),
        ),
        for (int row = 0; row < 3; row++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PerformanceCard(data: _items[row * 2])),
              SizedBox(width: 10.w),
              Expanded(child: _PerformanceCard(data: _items[row * 2 + 1])),
            ],
          ),
          if (row != 2) SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.data});

  final _PerformanceData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 50.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              data.icon,
              color: data.color,
              size: _telecallerQuickActionIconSize.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: TextScaler.noScaling,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      height: 0.83,
                      color: const Color(0xFF2D2C2C),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    data.value,
                    textScaler: TextScaler.noScaling,
                    style: GoogleFonts.inter(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
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

class _TaskStatData {
  const _TaskStatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color valueColor;
}

class _PerformanceData {
  const _PerformanceData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _SlaActionQueueSection extends StatelessWidget {
  const _SlaActionQueueSection({required this.summary});

  final _TelecallerDashboardSummary summary;

  List<_SlaCardData> get _items {
    return [
      _SlaCardData(
        title: 'OVERDUE\nFOLLOW-UPS',
        value: _formatCount(summary.missedFollowUps),
        subtitle: 'Requires immediate action',
        badge: 'Breached',
        badgeColor: const Color(0xFFEF4444),
        badgeBackground: const Color(0xFFFFE8E8),
      ),
      _SlaCardData(
        title: 'DUE IN NEXT\nHOUR',
        value: _formatCount(summary.dueNextHour),
        subtitle: 'Prioritize these first',
        badge: 'Due Soon',
        badgeColor: const Color(0xFFFF8A1D),
        badgeBackground: const Color(0xFFFFF1E8),
      ),
      _SlaCardData(
        title: 'MISSED\nSLA',
        value: _formatCount(summary.missedSla),
        subtitle: 'Escalate if not resolved',
        badge: 'Breached',
        badgeColor: const Color(0xFFEF4444),
        badgeBackground: const Color(0xFFFFE8E8),
      ),
      _SlaCardData(
        title: 'NEEDS IMMEDIATE\nRESPONSE',
        value: _formatCount(summary.needsImmediateResponse),
        subtitle: 'High-intent live queue',
        badge: summary.needsImmediateResponse > 0 ? 'Due Soon' : 'On Time',
        badgeColor: summary.needsImmediateResponse > 0
            ? const Color(0xFFFF8A1D)
            : const Color(0xFF16A34A),
        badgeBackground: summary.needsImmediateResponse > 0
            ? const Color(0xFFFFF1E8)
            : const Color(0xFFE8F8EC),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
          child: const _SectionTitle('SLA Action Queue', fontSize: 17),
        ),
        for (int row = 0; row < 2; row++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _SlaActionCard(data: _items[row * 2])),
              SizedBox(width: 12.w),
              Expanded(child: _SlaActionCard(data: _items[row * 2 + 1])),
            ],
          ),
          if (row != 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _SlaActionCard extends StatelessWidget {
  const _SlaActionCard({required this.data});

  final _SlaCardData data;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 88.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.33,
                      letterSpacing: -0.25,
                      color: const Color(0xFF2D2C2C),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: data.badgeBackground,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    data.badge,
                    style: GoogleFonts.inter(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w700,
                      color: data.badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              data.value,
              style: GoogleFonts.inter(
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                height: 1.36,
                color: const Color(0xFF2D2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCallingTrendSection extends StatelessWidget {
  const _DailyCallingTrendSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('Daily Calling Trend')),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FB),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          SizedBox(height: 176.h, child: const _DailyCallingTrendChart()),
        ],
      ),
    );
  }
}

class _DailyCallingTrendChart extends StatelessWidget {
  const _DailyCallingTrendChart();

  static const List<double> _bars = [1.2, 1.6, 3.4, 1.0, 0.8, 1.4, 2.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 16.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _axisLabel('4'),
              _axisLabel('3'),
              _axisLabel('2'),
              _axisLabel('1'),
              _axisLabel('0'),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_bars.length, (index) {
                    final isActive = index == 2;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: (_bars[index] / 4) * 140.h,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF3F7DE8)
                                  : const Color(0xFFDCE8FB),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _bottomLabel('12 AM', Alignment.centerLeft),
                  const Spacer(),
                  _bottomLabel('12 PM', Alignment.center),
                  const Spacer(),
                  _bottomLabel('12 AM', Alignment.centerRight),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _axisLabel(String value) {
    return Text(
      value,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF98A2B3),
      ),
    );
  }

  Widget _bottomLabel(String value, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF98A2B3),
        ),
      ),
    );
  }
}

class _SlaCardData {
  const _SlaCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeBackground,
  });

  final String title;
  final String value;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeBackground;
}

class _LeadStatusDistributionSection extends StatelessWidget {
  const _LeadStatusDistributionSection({required this.summary});

  final _TelecallerDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      _LeadStatusItem('New Leads', const Color(0xFF3F7DE8), summary.newLeads),
      _LeadStatusItem(
        'Interested',
        const Color(0xFF10B981),
        summary.interestedLeads,
      ),
      _LeadStatusItem(
        'Not Interested',
        const Color(0xFF6B7280),
        summary.notInterestedLeads,
      ),
      _LeadStatusItem(
        'Converted',
        const Color(0xFFFF7A1A),
        summary.convertedLeads,
      ),
    ];

    return _SectionCard(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Lead Status Distribution'),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 90.w,
                child: Column(
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatCount(summary.totalLeads),
                      style: GoogleFonts.inter(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: items
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Text(
                                '${_formatCount(item.value)} '
                                '(${_percentage(item.value, summary.totalLeads)})',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4B5563),
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
        ],
      ),
    );
  }
}

class _ConversionFunnelSection extends StatelessWidget {
  const _ConversionFunnelSection({required this.summary});

  final _TelecallerDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final stages = [
      _FunnelStage(_formatCount(summary.totalLeads), 'Total Leads'),
      _FunnelStage(
        _formatCount((summary.totalLeads - summary.newLeads).clamp(0, 999999)),
        'Contacted',
      ),
      _FunnelStage(_formatCount(summary.interestedLeads), 'Interested'),
      _FunnelStage(_formatCount(summary.siteVisitScheduledLeads), 'Site Visit'),
      _FunnelStage(_formatCount(summary.convertedLeads), 'Converted'),
    ];

    return _SectionCard(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Conversion Funnel', fontSize: 17),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 168.h,
                  child: const Center(child: _ConversionFunnelGraphic()),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 138.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stages
                      .map(
                        (stage) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 34.w,
                                child: Text(
                                  stage.value,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  stage.label,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF44474E),
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
          SizedBox(height: 2.h),
          Center(
            child: Column(
              children: [
                Text(
                  'Conversion Rate',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    height: 1.0,
                    letterSpacing: 0,
                    color: const Color(0xFF44474E),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  summary.conversionRateLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.normal,
                    height: 1.0,
                    letterSpacing: 0,
                    color: const Color(0xFFFF6B00),
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

class _ConversionFunnelGraphic extends StatelessWidget {
  const _ConversionFunnelGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144.w,
      height: 124.h,
      child: Center(
        child: CustomPaint(
          size: Size(116.w, 116.h),
          painter: _ConversionFunnelPainter(),
        ),
      ),
    );
  }
}

class _ConversionFunnelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topHeight = size.height * 0.39;
    final middleHeight = size.height * 0.34;
    final bottomHeight = size.height - topHeight - middleHeight;

    _drawSegment(
      canvas,
      color: const Color(0xFF4F86E8),
      topY: 0,
      height: topHeight,
      topWidth: size.width,
      bottomWidth: size.width * 0.70,
      centerX: size.width / 2,
    );
    _drawSegment(
      canvas,
      color: const Color(0xFF78A9E8),
      topY: topHeight,
      height: middleHeight,
      topWidth: size.width * 0.70,
      bottomWidth: size.width * 0.34,
      centerX: size.width / 2,
    );
    _drawSegment(
      canvas,
      color: const Color(0xFF10B981),
      topY: topHeight + middleHeight,
      height: bottomHeight,
      topWidth: size.width * 0.34,
      bottomWidth: size.width * 0.18,
      centerX: size.width / 2,
    );
  }

  void _drawSegment(
    Canvas canvas, {
    required Color color,
    required double topY,
    required double height,
    required double topWidth,
    required double bottomWidth,
    required double centerX,
  }) {
    final path = Path()
      ..moveTo(centerX - topWidth / 2, topY)
      ..lineTo(centerX + topWidth / 2, topY)
      ..lineTo(centerX + bottomWidth / 2, topY + height)
      ..lineTo(centerX - bottomWidth / 2, topY + height)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeadStatusItem {
  const _LeadStatusItem(this.label, this.color, this.value);

  final String label;
  final Color color;
  final int value;
}

String _percentage(int value, int total) {
  if (total == 0) return '0.0%';
  return '${(value / total * 100).toStringAsFixed(1)}%';
}

class _FunnelStage {
  const _FunnelStage(this.value, this.label);

  final String value;
  final String label;
}

List<dynamic> _extractApiList(Object? source) {
  if (source is List) {
    return source;
  }

  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'followUps',
      'follow_ups',
      'leads',
    ]) {
      final value = source[key];
      if (value is List) {
        return value;
      }
      if (value is Map) {
        final nested = _extractApiList(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
  }

  return const [];
}

List<dynamic> _extractLeadItems(Object? source) => _extractApiList(source);

String _formatCount(int? value) {
  final count = value ?? 0;
  if (count < 10) {
    return count.toString().padLeft(2, '0');
  }
  return count.toString();
}

String? _readString(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) {
    return null;
  }

  for (final key in keys) {
    final value = _readValue(map, key);
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

DateTime? _readDate(Map<String, dynamic> map, List<String> keys) {
  final text = _readString(map, keys);
  if (text == null) {
    return null;
  }
  return _parseApiDate(text);
}

Object? _readValue(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) {
    return map[key];
  }

  final normalizedKey = key.toLowerCase();
  for (final entry in map.entries) {
    if (entry.key.toString().toLowerCase() == normalizedKey) {
      return entry.value;
    }
  }
  return null;
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

bool _isLeadCreatedToday(LeadModel lead, DateTime now) {
  final createdAt = lead.raw == null
      ? null
      : _readDate(lead.raw!, const ['createdAt', 'created_at']);
  if (createdAt != null) {
    return _isSameDay(createdAt, now);
  }
  return _leadText(lead).contains('new');
}

bool _isHotLead(LeadModel lead) {
  final text = _leadText(lead);
  return text.contains('hot') || text.contains('high');
}

bool _isColdLead(LeadModel lead) => _leadText(lead).contains('cold');

bool _isInterestedLead(LeadModel lead) {
  final text = _leadText(lead);
  return text.contains('interested') && !text.contains('not interested');
}

bool _isNotInterestedLead(LeadModel lead) {
  final text = _leadText(lead);
  return text.contains('not interested') || text.contains('lost');
}

bool _isSiteVisitScheduledLead(LeadModel lead) {
  final text = _leadText(lead);
  return text.contains('site visit') && text.contains('schedu');
}

bool _isConvertedLead(LeadModel lead) {
  final text = _leadText(lead);
  return text.contains('converted') || text.contains('booked');
}

String _leadText(LeadModel lead) {
  final raw = lead.raw;
  final rawStatus = raw == null
      ? ''
      : [
          _readString(raw, const ['statusName', 'status', 'leadStatus']),
          _readString(raw, const ['stageName', 'stage']),
          _readString(raw, const ['temperatureName', 'temperature']),
          _readString(raw, const ['priorityName', 'priority']),
        ].whereType<String>().join(' ');

  return [
    lead.status,
    lead.stage,
    lead.source,
    rawStatus,
  ].whereType<String>().join(' ').trim().toLowerCase();
}

String _formatFollowUpTime(DateTime date) {
  final now = DateTime.now();
  final dateLabel = _isSameDay(date, now)
      ? 'Today'
      : _isSameDay(date, now.add(const Duration(days: 1)))
      ? 'Tomorrow'
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  return '$dateLabel, ${_formatClock(date)}';
}

String _formatClock(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

DateTime? _parseApiDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed != null) {
    return parsed.toLocal();
  }

  final match = RegExp(
    r'^[A-Za-z]{3}\s+([A-Za-z]{3})\s+(\d{1,2})\s+(\d{4})\s+'
    r'(\d{2}):(\d{2}):(\d{2})\s+GMT([+-]\d{4})',
  ).firstMatch(value);
  if (match == null) {
    return null;
  }

  final month = const {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  }[match.group(1)];
  if (month == null) {
    return null;
  }

  final offsetText = match.group(7)!;
  final offsetSign = offsetText.startsWith('-') ? -1 : 1;
  final offsetHours = int.parse(offsetText.substring(1, 3));
  final offsetMinutes = int.parse(offsetText.substring(3, 5));
  final offset = Duration(
    hours: offsetSign * offsetHours,
    minutes: offsetSign * offsetMinutes,
  );
  final localInSourceTimezone = DateTime(
    int.parse(match.group(3)!),
    month,
    int.parse(match.group(2)!),
    int.parse(match.group(4)!),
    int.parse(match.group(5)!),
    int.parse(match.group(6)!),
  );

  return localInSourceTimezone.subtract(offset).toLocal();
}

String _formatBadgeCount(int count) {
  if (count <= 0) {
    return '';
  }
  return count > 99 ? '99+' : count.toString();
}

String _formatNotificationTime(DateTime? date) {
  if (date == null) {
    return 'Recently';
  }
  final now = DateTime.now();
  if (_isSameDay(date, now)) {
    return _formatClock(date);
  }
  if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _TodayPunchCard extends StatelessWidget {
  const _TodayPunchCard({
    required this.data,
    required this.isLoading,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  final _TodayAttendanceData data;
  final bool isLoading;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  @override
  Widget build(BuildContext context) {
    final isCheckedOut = data.checkOut != null;
    final isCheckedIn = data.checkIn != null && !isCheckedOut;
    final accent = isCheckedOut
        ? const Color(0xFF0F766E)
        : isCheckedIn
        ? const Color(0xFF2563EB)
        : AppColors.orangeDeep;
    final softAccent = isCheckedOut
        ? const Color(0xFFECFDF5)
        : isCheckedIn
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFFFF7ED);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, softAccent],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF334155), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
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
                    Text(
                      'ATTENDANCE',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Today’s punch',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: softAccent,
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(color: accent.withValues(alpha: .45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current status',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 8.h),
                _AttendanceStatusChip(text: data.statusLabel, color: accent),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final shift = _PunchInfoBox(
                label: 'SHIFT',
                value: data.shiftLabel,
                accent: accent,
              );
              final log = _PunchInfoBox(
                label: 'PUNCH LOG',
                value: '${data.checkInLabel} – ${data.checkOutLabel}',
                accent: accent,
              );
              if (constraints.maxWidth < 620) {
                return Column(
                  children: [
                    shift,
                    SizedBox(height: 10.h),
                    log,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: shift),
                  SizedBox(width: 12.w),
                  Expanded(child: log),
                ],
              );
            },
          ),
          SizedBox(height: 12.h),
          if (isCheckedOut)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Today’s attendance is complete',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final punchIn = ElevatedButton.icon(
                  onPressed: !isLoading && data.canPunchIn ? onPunchIn : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    backgroundColor: AppColors.orangeDeep,
                    foregroundColor: Colors.white,
                  ),
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login_rounded),
                  label: const Text('Punch In'),
                );
                final punchOut = OutlinedButton.icon(
                  onPressed: !isLoading && data.canPunchOut ? onPunchOut : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Punch Out'),
                );
                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      punchIn,
                      SizedBox(height: 10.h),
                      punchOut,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: punchIn),
                    SizedBox(width: 12.w),
                    Expanded(child: punchOut),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PunchInfoBox extends StatelessWidget {
  const _PunchInfoBox({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF64748B), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
              color: accent,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStatusChip extends StatelessWidget {
  const _AttendanceStatusChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: Colors.white),
          SizedBox(width: 7.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PunchInSelfieDialog extends StatefulWidget {
  const _PunchInSelfieDialog();

  @override
  State<_PunchInSelfieDialog> createState() => _PunchInSelfieDialogState();
}

class _PunchInSelfieDialogState extends State<_PunchInSelfieDialog>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  String? _imagePath;
  Uint8List? _preview;
  bool _isCameraLoading = true;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  Future<void> _startCamera() async {
    if (mounted) {
      setState(() {
        _isCameraLoading = true;
        _error = null;
      });
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _isCameraLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCameraLoading = false;
          _error = 'Camera access is required: $error';
        });
      }
    }
  }

  Future<void> _capture() async {
    if (_preview != null) {
      await _cameraController?.resumePreview();
      setState(() {
        _imagePath = null;
        _preview = null;
      });
      return;
    }
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    setState(() {
      _isCapturing = true;
      _error = null;
    });
    try {
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      await controller.pausePreview();
      setState(() {
        _imagePath = image.path;
        _preview = bytes;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Camera access is required: $error');
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16.r),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(18.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capture punch-in selfie',
                          style: GoogleFonts.inter(
                            fontSize: 21.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Text(
                          'Take a clear front-camera photo, review it, and confirm to complete today’s punch in.',
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(18.r),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final preview = Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_preview != null)
                            Image.memory(_preview!, fit: BoxFit.cover)
                          else if (_cameraController?.value.isInitialized ??
                              false)
                            CameraPreview(_cameraController!)
                          else
                            Center(
                              child: _isCameraLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Icon(
                                      Icons.no_photography_outlined,
                                      size: 64,
                                      color: Colors.white54,
                                    ),
                            ),
                          if (_preview == null &&
                              (_cameraController?.value.isInitialized ?? false))
                            Center(
                              child: Container(
                                width: constraints.maxWidth < 720 ? 190.w : 260,
                                height: constraints.maxWidth < 720
                                    ? 230.h
                                    : 320,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(120.r),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 12.w,
                            right: 12.w,
                            bottom: 14.h,
                            child: Text(
                              _preview == null
                                  ? 'Align your face inside the frame'
                                  : 'Review your selfie before confirming',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 5),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    final actions = Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SelfieTip(
                          icon: Icons.camera_alt_outlined,
                          title: 'Capture a clear selfie',
                          description:
                              'Use the front camera in a well-lit area and keep your face centred.',
                        ),
                        if (_error != null) ...[
                          SizedBox(height: 12.h),
                          _SelfieError(message: _error!),
                        ],
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed:
                              _isCameraLoading || _isCapturing || _error != null
                              ? null
                              : _capture,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeDeep,
                            foregroundColor: Colors.white,
                          ),
                          icon: _isCapturing
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_outlined),
                          label: Text(
                            _preview == null
                                ? 'Capture selfie'
                                : 'Retake selfie',
                          ),
                        ),
                        SizedBox(height: 10.h),
                        ElevatedButton.icon(
                          onPressed: _imagePath == null
                              ? null
                              : () => Navigator.pop(context, _imagePath),
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Confirm punch-in selfie'),
                        ),
                        SizedBox(height: 10.h),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 720) {
                      return Column(
                        children: [
                          Expanded(flex: 3, child: preview),
                          SizedBox(height: 14.h),
                          Flexible(
                            flex: 2,
                            child: SingleChildScrollView(child: actions),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(flex: 3, child: preview),
                        SizedBox(width: 18.w),
                        Expanded(flex: 2, child: actions),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelfieTip extends StatelessWidget {
  const _SelfieTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.navy),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
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

class _SelfieError extends StatelessWidget {
  const _SelfieError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _TodayAttendanceData {
  const _TodayAttendanceData({
    this.checkIn,
    this.checkOut,
    this.shiftLabel = 'Telecalling shift',
  });

  final DateTime? checkIn;
  final DateTime? checkOut;
  final String shiftLabel;

  factory _TodayAttendanceData.fromApi(Object? source) {
    final map = _firstApiMap(source);
    final checkIn = _attendanceDate(
      map['checkInAt'] ?? map['punchInAt'] ?? map['checkIn'] ?? map['inTime'],
    );
    final checkOut = _attendanceDate(
      map['checkOutAt'] ??
          map['punchOutAt'] ??
          map['checkOut'] ??
          map['outTime'],
    );
    final shift = map['shift'] is Map
        ? Map<String, dynamic>.from(map['shift'] as Map)
        : const <String, dynamic>{};
    final shiftName = (shift['name'] ?? map['shiftName'] ?? 'Telecalling shift')
        .toString();
    final start = (shift['startTime'] ?? map['shiftStartTime'])?.toString();
    final end = (shift['endTime'] ?? map['shiftEndTime'])?.toString();
    final schedule = start == null || end == null ? '' : ' ($start - $end)';
    return _TodayAttendanceData(
      checkIn: checkIn,
      checkOut: checkOut,
      shiftLabel: '$shiftName$schedule',
    );
  }

  bool get canPunchIn => checkIn == null;
  bool get canPunchOut => checkIn != null && checkOut == null;
  String get statusLabel => checkIn == null
      ? 'Not Checked In'
      : checkOut == null
      ? 'Checked In'
      : 'Checked Out';
  String get checkInLabel => checkIn == null ? '–' : _formatClock(checkIn!);
  String get checkOutLabel => checkOut == null ? '–' : _formatClock(checkOut!);
}

Map<String, dynamic> _firstApiMap(Object? source) {
  if (source is Map) {
    final map = Map<String, dynamic>.from(source);
    for (final key in const ['data', 'attendance', 'record', 'today']) {
      if (map[key] is Map) {
        return _firstApiMap(map[key]);
      }
    }
    return map;
  }
  return const {};
}

DateTime? _attendanceDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String? _extractUploadedImageUrl(Object? source) {
  if (source is Map) {
    final map = Map<String, dynamic>.from(source);
    for (final key in const [
      'url',
      'fileUrl',
      'imageUrl',
      'path',
      'location',
    ]) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    for (final key in const ['data', 'file', 'image', 'upload']) {
      final nested = _extractUploadedImageUrl(map[key]);
      if (nested != null) return nested;
    }
  }
  return null;
}
