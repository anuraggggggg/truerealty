import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

const double _telecallerHeaderActionIconSize = 30;
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

class TelecallerDashboardView extends StatelessWidget {
  const TelecallerDashboardView({
    super.key,
    this.onMenuTap,
    this.bottomSpacing = 16,
  });

  final VoidCallback? onMenuTap;
  final double bottomSpacing;

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

  @override
  Widget build(BuildContext context) {
    final headerHeight = 302.h;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              SizedBox(
                height: headerHeight + 66.h, // Extra room for scaled header content
                width: double.infinity,
                child: _DashboardHeader(onMenuTap: onMenuTap),
              ),
              Padding(
                padding: EdgeInsets.only(top: 206.h, left: 16.w, right: 16.w),
                child: const _DashboardPanel(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _TodayTasksSection(),
                const _SectionGap(),
                const _SiteVisitsSection(),
                const _SectionGap(),
                const _ActionOnlySection(
                  title: 'Upcoming Follow-ups',
                  actionText: 'View All Follow-ups',
                ),
                const _SectionGap(),
                const _ActionOnlySection(
                  title: 'Recent Activities',
                  actionText: 'View All Activities',
                ),
                const _SectionGap(),
                const _PerformanceSection(),
                const _SectionGap(),
                const _SlaActionQueueSection(),
                const _SectionGap(),
                const _DailyCallingTrendSection(),
                const _SectionGap(),
                const _LeadStatusDistributionSection(),
                const _SectionGap(),
                const _ConversionFunnelSection(),
                const _SectionGap(),
                const _QuickActionsSection(),
                SizedBox(height: bottomSpacing.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 76.h),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onMenuTap,
                borderRadius: BorderRadius.circular(18.r),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: _telecallerHeaderActionIconSize,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF8A1D),
                        ),
                      ),
                      TextSpan(
                        text: ' \u203a Telecaller Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _HeaderIcon(
                    icon: Icons.notifications_none_rounded,
                    badgeText: '25',
                  ),
                  SizedBox(width: 12.w),
                  const _HeaderIcon(
                    icon: Icons.mail_outline_rounded,
                    badgeText: '8',
                  ),
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8B3DDA),
                    radius: 17.r,
                    child: Text(
                      'TT',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 36.h),
          Text(
            'Telecaller Dashboard',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
              height: 1.0,
              letterSpacing: 0,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Welcome back, Telecaller Test. Here's your today's overview.",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              height: 1.72,
              letterSpacing: 0,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.badgeText});

  final IconData icon;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30.w,
      height: 30.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Icon(
              icon,
              color: Colors.white,
              size: _telecallerHeaderActionIconSize.sp,
            ),
          ),
          Positioned(
            top: -7.h,
            right: -8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A1A),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.navy, width: 1.2),
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
    );
  }
}

class _DashboardPanel extends StatelessWidget {
  const _DashboardPanel();

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
                  Expanded(
                    child: _MetricCard(
                      data: TelecallerDashboardView._topRows[row * 3 + index],
                    ),
                  ),
                  if (index != 2) SizedBox(width: 10.w),
                ],
              ],
            ),
            SizedBox(height: 14.h),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricCard(
                  data: TelecallerDashboardView._bottomRows[0],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _MetricCard(
                  data: TelecallerDashboardView._bottomRows[1],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricCard(
                  data: TelecallerDashboardView._bottomRows[2],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _MetricCard(
                  data: TelecallerDashboardView._bottomRows[3],
                ),
              ),
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
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: _SectionCard(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('Site Visits', fontSize: 19)),
              Text(
                'View All ›',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF97316),
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
    ));
  }

  Widget _buildVisitItem(String name, String location, String time, String status) {
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
  const _TodayTasksSection();

  static const List<_TaskStatData> _items = [
    _TaskStatData(
      icon: Icons.call_outlined,
      label: 'Make\nCalls',
      value: '5',
      iconColor: Color(0xFF98A2B3),
      valueColor: Color(0xFFFF6B00),
    ),
    _TaskStatData(
      icon: Icons.calendar_month_outlined,
      label: 'Follow-ups',
      value: '0',
      iconColor: Color(0xFF98A2B3),
      valueColor: AppColors.navy,
    ),
    _TaskStatData(
      icon: Icons.location_on_outlined,
      label: 'Site\nVisits',
      value: '0',
      iconColor: Color(0xFF98A2B3),
      valueColor: AppColors.navy,
    ),
    _TaskStatData(
      icon: Icons.ring_volume_outlined,
      label: 'Missed\nFollow-ups',
      value: '0',
      iconColor: Color(0xFF98A2B3),
      valueColor: AppColors.navy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle("Today's Tasks", fontSize: 19)),
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B00),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '5',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              return Expanded(
                child: Row(
                  children: [
                    if (index != 0)
                      Container(
                        width: 1,
                        height: 76.h,
                        margin: EdgeInsets.only(right: 12.w),
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
                          SizedBox(height: 8.h),
                          Text(
                            item.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.31,
                              color: const Color(0xFF2D2C2C),
                            ),
                          ),
                          SizedBox(height: 8.h),
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
        ],
      ),
    );
  }
}

class _ActionOnlySection extends StatelessWidget {
  const _ActionOnlySection({required this.title, required this.actionText});

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      child: SizedBox(
        height: 58.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(title),
            Align(
              alignment: Alignment.center,
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
          ],
        ),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection();

  static const List<_PerformanceData> _items = [
    _PerformanceData(
      title: 'Calls Made',
      value: '00',
      icon: Icons.call_outlined,
      color: Color(0xFFFF6B00),
    ),
    _PerformanceData(
      title: 'Connected',
      value: '00',
      icon: Icons.add_ic_call_outlined,
      color: Color(0xFF10B981),
    ),
    _PerformanceData(
      title: 'Missed',
      value: '00',
      icon: Icons.call_split_outlined,
      color: Color(0xFFFF6B00),
    ),
    _PerformanceData(
      title: 'Follow-ups',
      value: '00',
      icon: Icons.event_note_outlined,
      color: Color(0xFF2563EB),
    ),
    _PerformanceData(
      title: 'Site Visits',
      value: '00',
      icon: Icons.location_on_outlined,
      color: Color(0xFFEF4444),
    ),
    _PerformanceData(
      title: 'Conv. Rate',
      value: '0.0%',
      icon: Icons.check_circle_outline,
      color: Color(0xFFD946EF),
    ),
  ];

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
  const _SlaActionQueueSection();

  static const List<_SlaCardData> _items = [
    _SlaCardData(
      title: 'OVERDUE\nFOLLOW-UPS',
      value: '06',
      subtitle: 'Requires immediate action',
      badge: 'Breached',
      badgeColor: Color(0xFFEF4444),
      badgeBackground: Color(0xFFFFE8E8),
    ),
    _SlaCardData(
      title: 'DUE IN NEXT\nHOUR',
      value: '04',
      subtitle: 'Prioritize these first',
      badge: 'Due Soon',
      badgeColor: Color(0xFFFF8A1D),
      badgeBackground: Color(0xFFFFF1E8),
    ),
    _SlaCardData(
      title: 'MISSED\nSLA',
      value: '03',
      subtitle: 'Escalate if not resolved',
      badge: 'Breached',
      badgeColor: Color(0xFFEF4444),
      badgeBackground: Color(0xFFFFE8E8),
    ),
    _SlaCardData(
      title: 'NEEDS IMMEDIATE\nRESPONSE',
      value: '08',
      subtitle: 'High-intent live queue',
      badge: 'On Time',
      badgeColor: Color(0xFF16A34A),
      badgeBackground: Color(0xFFE8F8EC),
    ),
  ];

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
  const _LeadStatusDistributionSection();

  static const List<_LeadStatusItem> _items = [
    _LeadStatusItem('New Leads', Color(0xFF3F7DE8)),
    _LeadStatusItem('Interested', Color(0xFF10B981)),
    _LeadStatusItem('Not Interested', Color(0xFF6B7280)),
    _LeadStatusItem('Converted', Color(0xFFFF7A1A)),
  ];

  @override
  Widget build(BuildContext context) {
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
                      '0',
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
                  children: _items
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
                            '0 (0.0%)',
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
  const _ConversionFunnelSection();

  static const List<_FunnelStage> _stages = [
    _FunnelStage('05', 'Total Leads'),
    _FunnelStage('00', 'Contacted'),
    _FunnelStage('00', 'Interested'),
    _FunnelStage('00', 'Site Visit'),
    _FunnelStage('00', 'Converted'),
  ];

  @override
  Widget build(BuildContext context) {
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
                  children: _stages
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
                  '12.5%',
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
  const _LeadStatusItem(this.label, this.color);

  final String label;
  final Color color;
}

class _FunnelStage {
  const _FunnelStage(this.value, this.label);

  final String value;
  final String label;
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  static const List<_QuickActionItemData> _items = [
    _QuickActionItemData(
      title: 'Call Lead',
      subtitle: 'Make a call to lead',
      icon: Icons.call,
      iconColor: Color(0xFF2563EB),
      iconBackground: Color(0xFFEAF2FF),
    ),
    _QuickActionItemData(
      title: 'Add Follow-up',
      subtitle: 'Add new follow-up',
      icon: Icons.event_outlined,
      iconColor: Color(0xFFFF7A1A),
      iconBackground: Color(0xFFFFF1E8),
    ),
    _QuickActionItemData(
      title: 'Schedule Site Visit',
      subtitle: 'Book site visit',
      icon: Icons.location_on,
      iconColor: Color(0xFF0F2E63),
      iconBackground: Color(0xFFF3F6FB),
    ),
    _QuickActionItemData(
      title: 'Update Status',
      subtitle: 'Update lead status',
      icon: Icons.check_circle,
      iconColor: Color(0xFF10B981),
      iconBackground: Color(0xFFE8F8EC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Quick Actions', fontSize: 17),
          SizedBox(height: 16.h),
          for (int i = 0; i < _items.length; i++) ...[
            _QuickActionTile(data: _items[i]),
            if (i != _items.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});

  final _QuickActionItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: data.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              color: data.iconColor,
              size: _telecallerQuickActionIconSize.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    height: 1.33,
                    letterSpacing: 0.6,
                    color: const Color(0xFF000B20),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  data.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFFFF6B00),
            size: _telecallerQuickActionIconSize.sp,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItemData {
  const _QuickActionItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}
