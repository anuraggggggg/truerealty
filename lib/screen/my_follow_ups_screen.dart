import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/follow_up_model.dart';
import 'package:truerealtycrm/provider/follow_ups_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:truerealtycrm/widget/follow_up_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MyFollowUpsScreen extends StatefulWidget {
  const MyFollowUpsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<MyFollowUpsScreen> createState() => _MyFollowUpsScreenState();
}

class _MyFollowUpsScreenState extends State<MyFollowUpsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FollowUpsProvider>().loadFollowUps(limit: 500);
    });
  }

  Future<void> _refresh() {
    return context.read<FollowUpsProvider>().loadFollowUps(limit: 500);
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty || cleaned == '-') return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = _whatsAppDigits(phone);
    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number for WhatsApp.')),
      );
      return;
    }

    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$digits'),
      Uri.parse('https://api.whatsapp.com/send?phone=$digits'),
      Uri.parse('https://wa.me/$digits'),
    ];

    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {
        // Try the next scheme/fallback.
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open WhatsApp. Please install WhatsApp.'),
      ),
    );
  }

  String _whatsAppDigits(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    // Indian 10-digit mobiles need country code for WhatsApp deep links.
    if (digits.length == 10) {
      digits = '91$digits';
    }
    return digits;
  }

  void _openLead(FollowUpModel item) {
    final lead = item.leadRaw;
    if (lead == null) return;
    Navigator.of(
      context,
    ).pushNamed(AppRouter.leadDetail, arguments: LeadModel.fromJson(lead));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FollowUpsProvider>();
    final summary = provider.summary;
    final visible = provider.visibleItems;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        leading: widget.onMenuTap == null
            ? null
            : IconButton(
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
        title: Text(
          'My Follow-Ups',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track and action only the follow-ups assigned to you from the same premium workspace.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SummaryMetricsGrid(
                      summary: summary,
                      onSelect: provider.setFilter,
                    ),
                    SizedBox(height: 14.h),
                    _QueueSlaSection(summary: summary),
                    SizedBox(height: 14.h),
                    const _QueueGuidanceSection(),
                    SizedBox(height: 14.h),
                    _FilterTabs(provider: provider),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
            if (provider.isLoading && !provider.hasLoaded)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: const SliverToBoxAdapter(
                  child: AppListSkeleton(itemCount: 4, itemHeight: 168),
                ),
              )
            else if (provider.error != null && provider.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.error!,
                  onRetry: _refresh,
                ),
              )
            else if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.items.isEmpty
                      ? 'No follow-ups found.'
                      : 'No follow-ups in this filter.',
                  onRetry: provider.items.isEmpty ? _refresh : null,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return FollowUpLeadCard(
                      item: item,
                      onTap: () => _openLead(item),
                      onCall: () => _call(item.phone),
                      onWhatsApp: () => _openWhatsApp(item.phone),
                    );
                  },
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _PerformanceSection(summary: summary),
                    SizedBox(height: 14.h),
                    _BestTimeSection(slots: provider.bestTimeSlots),
                    SizedBox(height: 14.h),
                    _CalendarSection(
                      markedDays: provider.scheduledDaysInCurrentMonth,
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

class _SummaryMetricsGrid extends StatelessWidget {
  const _SummaryMetricsGrid({required this.summary, required this.onSelect});

  final FollowUpQueueSummary summary;
  final ValueChanged<FollowUpListFilter> onSelect;
  static const double _cardHeight = 190;

  @override
  Widget build(BuildContext context) {
    final cards = [
      FollowUpMetricCardData(
        title: "Today's Follow-Ups",
        value: '${summary.todayCount}',
        subtitle: 'Due in the current queue',
        footer: '${summary.todayCount} total',
        icon: Icons.event_available_outlined,
        iconColor: AppColors.blueBright,
      ),
      FollowUpMetricCardData(
        title: 'Overdue Follow-Ups',
        value: '${summary.overdueCount}',
        subtitle: 'Needs immediate attention',
        footer: '${summary.overdueCount} delayed',
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.orangeDeep,
      ),
      FollowUpMetricCardData(
        title: 'Upcoming Follow-Ups',
        value: '${summary.upcomingCount}',
        subtitle: 'Scheduled next actions',
        footer: '${summary.upcomingCount} upcoming',
        icon: Icons.calendar_month_outlined,
        iconColor: AppColors.greenDeep,
      ),
      FollowUpMetricCardData(
        title: 'Completed Today',
        value: '${summary.completedTodayCount}',
        subtitle: 'Marked complete',
        footer: '${summary.completedTodayCount} closed',
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.purpleDeep,
      ),
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12.w) / 2;
            return Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                for (var i = 0; i < cards.length; i++)
                  SizedBox(
                    width: width,
                    height: _cardHeight.h,
                    child: FollowUpMetricCard(
                      data: cards[i],
                      onTap: () => onSelect(switch (i) {
                        0 => FollowUpListFilter.today,
                        1 => FollowUpListFilter.overdue,
                        2 => FollowUpListFilter.upcoming,
                        _ => FollowUpListFilter.completed,
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: _cardHeight.h,
          child: FollowUpMetricCard(
            data: FollowUpMetricCardData(
              title: 'Pending Queue',
              value: '${summary.pendingCount}',
              subtitle: 'Open follow-up workload',
              footer: '${summary.pendingCount} total',
              icon: Icons.assignment_late_outlined,
              iconColor: AppColors.blueBright,
            ),
            onTap: () => onSelect(FollowUpListFilter.all),
          ),
        ),
      ],
    );
  }
}

class _QueueSlaSection extends StatelessWidget {
  const _QueueSlaSection({required this.summary});

  final FollowUpQueueSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      FollowUpSlaTileData(
        value: summary.breachedCount.toString().padLeft(2, '0'),
        label: 'Breached follow-ups',
        badge: 'Breached',
        badgeColor: const Color(0xFFEF4444),
        badgeBackground: const Color(0xFFFFE8E8),
      ),
      FollowUpSlaTileData(
        value: summary.dueNextHourCount.toString().padLeft(2, '0'),
        label: 'Next 60 minutes',
        badge: 'Due Soon',
        badgeColor: const Color(0xFFF97316),
        badgeBackground: const Color(0xFFFFF1E8),
      ),
      FollowUpSlaTileData(
        value: summary.managerAttentionCount.toString().padLeft(2, '0'),
        label: 'Manager attention',
        badge: summary.managerAttentionCount > 0 ? 'Breached' : 'On Time',
        badgeColor: summary.managerAttentionCount > 0
            ? const Color(0xFFEF4444)
            : AppColors.greenDeep,
        badgeBackground: summary.managerAttentionCount > 0
            ? const Color(0xFFFFE8E8)
            : AppColors.greenBg,
      ),
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue SLA Snapshot',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Follow-up response health across the current queue',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < tiles.length; i++) ...[
            FollowUpSlaTile(data: tiles[i]),
            if (i != tiles.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _QueueGuidanceSection extends StatelessWidget {
  const _QueueGuidanceSection();

  static const _points = [
    'Prioritize overdue follow-ups before starting fresh outreach.',
    'Use reschedule and next-action updates to keep the queue accurate.',
    'Completed follow-ups move out of the live queue automatically.',
  ];

  @override
  Widget build(BuildContext context) {
    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue Guidance',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < _points.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Icon(
                    Icons.circle_outlined,
                    size: 14.sp,
                    color: AppColors.blueBright,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _points[i],
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      height: 1.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (i != _points.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.provider});

  final FollowUpsProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in FollowUpListFilter.values) ...[
            _FilterChip(
              label: '${filter.label} (${provider.countFor(filter)})',
              selected: provider.filter == filter,
              onTap: () => provider.setFilter(filter),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.white,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected ? AppColors.navy : const Color(0xFFD9E3EF),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.summary});

  final FollowUpQueueSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Completed',
        summary.completedCount,
        AppColors.greenDeep,
        AppColors.greenBg,
      ),
      (
        'Pending',
        summary.pendingStatusCount,
        AppColors.blueBright,
        const Color(0xFFEAF2FF),
      ),
      (
        'Contacted',
        summary.contactedCount,
        AppColors.purpleDeep,
        AppColors.purpleSoft,
      ),
      (
        'Best Slot',
        summary.dueNextHourCount,
        AppColors.orangeDeep,
        AppColors.orangeSoft,
      ),
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-Up Performance',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 10.w) / 2;
              return Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: item.$4,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: item.$3,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '${item.$2}',
                              style: GoogleFonts.inter(
                                fontSize: 22.sp,
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

class _BestTimeSection extends StatelessWidget {
  const _BestTimeSection({required this.slots});

  final Map<String, int> slots;

  @override
  Widget build(BuildContext context) {
    final entries = slots.entries.toList();
    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Time to Follow-Up',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Derived from scheduled slots in the current queue',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          if (entries.isEmpty)
            Text(
              'No scheduled time slots yet.',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 10.w) / 2;
                final colors = [
                  AppColors.purpleBg,
                  AppColors.greenBg,
                  AppColors.softBlue,
                  AppColors.orangeBg,
                ];
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      SizedBox(
                        width: width,
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE6ECF4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entries[i].key,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${entries[i].value} scheduled',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
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

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({required this.markedDays});

  final Set<int> markedDays;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-Up Calendar',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Current Queue View · ${months[now.month - 1]} ${now.year}',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday = day == now.day;
              final isMarked = markedDays.contains(day);
              return Container(
                margin: EdgeInsets.all(2.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.blueBright
                      : isMarked
                      ? AppColors.orangeSoft
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$day',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: isToday || isMarked
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isToday
                        ? Colors.white
                        : isMarked
                        ? AppColors.orangeDeep
                        : AppColors.navy,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 42.sp,
            color: AppColors.iconMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
