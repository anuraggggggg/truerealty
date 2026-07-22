import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  static const List<_DashboardMetric> _topMetrics = [
    _DashboardMetric(
      icon: Icons.groups_2_outlined,
      title: 'Total Leads',
      value: '5',
      iconColor: AppColors.navy,
    ),
    _DashboardMetric(
      icon: Icons.person_add_alt_1_outlined,
      title: 'New Leads',
      value: '5',
      iconColor: Color(0xFF10B981),
    ),
    _DashboardMetric(
      icon: Icons.assignment_ind_outlined,
      title: 'Assigned',
      value: '5',
      iconColor: AppColors.orangeDeep,
    ),
    _DashboardMetric(
      icon: Icons.person_off_outlined,
      title: 'Unassigned',
      value: '0',
      iconColor: Color(0xFFDC2626),
    ),
    _DashboardMetric(
      icon: Icons.calendar_month_outlined,
      title: 'Follow-ups',
      value: '2',
      iconColor: Color(0xFF4C6793),
    ),
    _DashboardMetric(
      icon: Icons.event_busy_outlined,
      title: 'Missed',
      value: '0',
      iconColor: Color(0xFFB91C1C),
    ),
  ];

  static const List<_DashboardMetric> _bottomMetrics = [
    _DashboardMetric(
      icon: Icons.calendar_today_outlined,
      title: 'Scheduled',
      value: '1',
      iconColor: Color(0xFF2563EB),
    ),
    _DashboardMetric(
      icon: Icons.verified_user_outlined,
      title: 'Bookings',
      value: '1',
      iconColor: AppColors.navy,
    ),
    _DashboardMetric(
      icon: Icons.currency_rupee,
      title: 'Revenue Pipeline',
      value: 'Rs 12,00,000',
      iconColor: AppColors.orangeDeep,
      valueFontSize: 18,
    ),
    _DashboardMetric(
      icon: Icons.check_circle_outline,
      title: 'Completed',
      value: '2',
      iconColor: Color(0xFF10B981),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.15),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 88.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHero(onMenuTap: onMenuTap),
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
                        const _FilterBar(),
                        SizedBox(height: 20.h),
                        _MetricSection(
                          metrics: _topMetrics,
                          columns: 3,
                          itemHeight: 104.h,
                        ),
                        SizedBox(height: 8.h),
                        _MetricSection(
                          metrics: _bottomMetrics,
                          columns: 2,
                          itemHeight: 96.h,
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
                        const _QuickActionsCard(),
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
            child: const _FloatingAddButton(),
          ),
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.onMenuTap});

  final VoidCallback onMenuTap;

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
                const _HeaderIconButton(icon: Icons.search),
                SizedBox(width: 14.w),
                const _NotificationBell(),
                SizedBox(width: 14.w),
                Container(
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
                  child: Icon(
                    Icons.person_outline,
                    size: 18.sp,
                    color: AppColors.navy,
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
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                '12',
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
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterChip(
            icon: Icons.calendar_today_outlined,
            label: '01 May 2025 - 31 May 2025',
          ),
        ),
        SizedBox(width: 12.w),
        _FilterChip(
          icon: Icons.filter_alt_outlined,
          label: 'All Filters',
          horizontalPadding: 14.w,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    this.horizontalPadding = 12,
  });

  final IconData icon;
  final String label;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFC8D1DF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
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
          SizedBox(height: 8.h),
          Text(
            metric.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const Spacer(),
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
          Text(
            'View Report',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.orangeDeep,
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
                    .map((item) => Padding(
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
                        ))
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
          Container(
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
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 18.h),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: _items.asMap().entries
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
                onPressed: () {},
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
                onPressed: () {},
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
                  Expanded(
                    child: _TabPill(label: 'Field Execs'),
                  ),
                  Expanded(
                    child: _TabPill(label: 'Managers'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'TELECALLER',
                    style: _tableHeaderStyle(),
                  ),
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
            ..._telecallers.map(
              (row) => _TeamPerformanceRowTile(row: row),
            ),
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
                  Container(width: 1, height: 44.h, color: const Color(0xFFD8DEE9)),
                  Expanded(
                    child: _FooterMetric(
                      title: 'Fastest Team',
                      value: 'Team Alpha',
                      valueColor: const Color(0xFF1F2A44),
                      valueFontSize: 14,
                    ),
                  ),
                  Container(width: 1, height: 44.h, color: const Color(0xFFD8DEE9)),
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
                onPressed: () {},
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
  const _QuickActionsCard();

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
              .map((action) => _QuickActionChip(action: action))
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
                  .map((report) => _ReportChip(label: report))
                  .toList(),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: 194.w,
              child: OutlinedButton(
                onPressed: () {},
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
              child: CustomPaint(
                painter: _MapFallbackPainter(),
              ),
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
                  color: Colors.white.withOpacity(0.92),
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
                      color: Colors.white.withOpacity(0.9),
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
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
  const _QuickActionChip({required this.action});

  final _QuickActionChipData action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: action.highlighted ? AppColors.orangeDeep : const Color(0xFF173A6D),
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
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
        border: Border.all(color: accent.withOpacity(0.12)),
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
                    color: tagBg ?? accent.withOpacity(0.12),
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

    final bluePath = _smoothPath(bluePoints, chartLeft, chartTop, chartWidth, chartHeight);
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
      canvas.drawCircle(position, 2.5, Paint()..color = const Color(0xFF173A6D));
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
      canvas.drawCircle(position, 2.5, Paint()..color = const Color(0xFFFF6B00));
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
      final x = chartLeft + (chartWidth * bluePoints[i].dx) - (textPainter.width / 2);
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
        .map((point) => Offset(left + (width * point.dx), top + (height * point.dy)))
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
}
