import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class FollowUpTestScreen extends StatelessWidget {
  const FollowUpTestScreen({super.key});

  static const List<_FollowUpMetric> _topMetrics = [
    _FollowUpMetric(
      title: "Today's\nFollow-Ups",
      value: '0',
      subtitle: 'Due in the current queue',
      footer: '0 total',
      icon: Icons.calendar_today_outlined,
      iconColor: Color(0xFF2563EB),
    ),
    _FollowUpMetric(
      title: 'Overdue\nFollow-Ups',
      value: '0',
      subtitle: 'Needs immediate attention',
      footer: '0 delayed',
      icon: Icons.trending_up,
      iconColor: Color(0xFFF97316),
    ),
    _FollowUpMetric(
      title: 'Completed\nToday',
      value: '0',
      subtitle: 'Marked complete',
      footer: '0 closed',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.navy,
    ),
    _FollowUpMetric(
      title: 'Upcoming\nFollow-Ups',
      value: '0',
      subtitle: 'Scheduled next actions',
      footer: '0 upcoming',
      icon: Icons.calendar_month_outlined,
      iconColor: Color(0xFF10B981),
    ),
  ];

  static const _FollowUpMetric _queueMetric = _FollowUpMetric(
    title: 'Pending Queue',
    value: '0',
    subtitle: 'Open follow-up workload',
    footer: '0 total',
    icon: Icons.assignment_late_outlined,
    iconColor: Color(0xFF3B82F6),
  );

  static const List<_SlaMetric> _slaMetrics = [
    _SlaMetric(
      value: '23',
      title: 'Breached\nfollow-ups',
      badge: 'BREACHED',
      badgeColor: Color(0xFFEF4444),
      badgeBackground: Color(0xFFFFE1DE),
    ),
    _SlaMetric(
      value: '19',
      title: 'Next 60\nminutes',
      badge: 'DUE SOON',
      badgeColor: Color(0xFFF97316),
      badgeBackground: Color(0xFFFFE9D8),
    ),
    _SlaMetric(
      value: '07',
      title: 'Manager\nattention',
      badge: 'BREACHED',
      badgeColor: Color(0xFFEF4444),
      badgeBackground: Color(0xFFFFE1DE),
    ),
  ];

  static const _FollowUpLeadCardData _leadCard = _FollowUpLeadCardData(
    name: 'Siddharth Nair',
    status: 'Overdue',
    property: '2 BHK | Goregaon (E), Mumbai',
    source: '99Acres',
    followUpLabel: 'Today',
    followUpTime: '03:30 pm',
    typeValue: 'Call',
    typeMeta: 'Not Available',
    lastContactDate: '24 Jun',
    lastContactTime: '03:30 pm',
    nextAction: 'sdf',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'My Follow-Ups',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.29, // line-height
                        letterSpacing: -0.28,
                        color: Color(0xFF001F42), // Darker Navy
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.vividBlue,
                      size: 26.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Track and action only the follow-ups assigned to you\nfrom the same premium workspace.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Slightly bolder
                  height: 1.43,
                  color: Color(0xFF2D2F33), // Darker Grey for better contrast
                ),
              ),
              SizedBox(height: 22.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topMetrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  return _FollowUpMetricCard(data: _topMetrics[index]);
                },
              ),
              SizedBox(height: 12.h),
              _FollowUpMetricCard(data: _queueMetric, fullWidth: true),
              SizedBox(height: 14.h),
              const _QueueSlaSnapshotCard(),
              SizedBox(height: 14.h),
              const _FollowUpsQueueCard(),
              SizedBox(height: 14.h),
              const _FollowUpPerformanceCard(),
              SizedBox(height: 14.h),
              const _BestTimeFollowUpSection(),
              SizedBox(height: 14.h),
              const _QueueGuidanceSection(),
              SizedBox(height: 14.h),
              const _QueueCalendarSection(),
              SizedBox(height: 14.h),
              const _OverdueFollowUpsSection(),
              SizedBox(height: 14.h),
              const _QuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverdueFollowUpsSection extends StatelessWidget {
  const _OverdueFollowUpsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEDE0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF6EF),
            Color(0x00FFFFFF), // transparent white
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Overdue Follow-Ups (1)',
                style: GoogleFonts.inter(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: const AssetImage(
                  'assets/img.png',
                ), // Placeholder
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siddharth Nair',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.5, // line-height equivalent
                        letterSpacing: 0,
                        color: Color(0xFF002149),
                      ),
                    ),
                    Text(
                      '2 BHK | Goregaon (E), Mumbai',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        height: 1.5, // line-height
                        color: Color(0xFF1E2022),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Overdue',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.43, // line-height equivalent
                  letterSpacing: 0,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 16.h),
          _QuickActionTile(
            iconPath: 'assets/dollor_icon.png',
            title: 'Add Follow-Up',
            subtitle: 'Schedule a new follow-up',
          ),
          Divider(),
          _QuickActionTile(
            iconPath: 'assets/Icon Container.png',
            title: 'View Today Queue',
            subtitle: 'Focus on today\'s active queue',
          ),
          Divider(),
          _QuickActionTile(
            iconPath: 'assets/riben.png',
            title: 'Review Overdue',
            subtitle: 'Handle delayed follow-ups first',
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    this.icon,
    this.iconPath,
    required this.title,
    required this.subtitle,
  });
  final IconData? icon;
  final String? iconPath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: iconPath != null
          ? SizedBox(
              width: 50.w,
              height: 50.w,
              child: Image.asset(iconPath!, fit: BoxFit.contain),
            )
          : Icon(icon, color: AppColors.vividBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1.5, // line-height
          color: Color(0xFF002149),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          fontWeight: FontWeight.normal,
          height: 1.5, // line-height
          color: Color(0xFF64748B),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.orange),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _QueueCalendarSection extends StatelessWidget {
  const _QueueCalendarSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.chevron_left, color: AppColors.vividBlue),
              Text(
                'Current Queue View',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.43, // line-height equivalent
                  letterSpacing: 0,
                  color: Color(0xFF2563EB),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.vividBlue),
            ],
          ),
          SizedBox(height: 16.h),
          _CalendarGrid(),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map(
                (day) => Text(
                  day,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    height: 1.4, // line-height equivalent
                    letterSpacing: 0.5,
                    color: Color(0xFF44474E),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == 21;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.vividBlue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$day',
                    style: GoogleFonts.inter(
                      fontSize: 17.sp,
                      color: isSelected ? Colors.white : AppColors.navy,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 4.r,
                      height: 4.r,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QueueGuidanceSection extends StatelessWidget {
  const _QueueGuidanceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue Guidance',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4, // line-height equivalent
              letterSpacing: 0,
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 16.h),
          _GuidancePoint(
            text:
                'Prioritize overdue follow-ups before starting fresh outreach.',
          ),
          SizedBox(height: 12.h),
          _GuidancePoint(
            text:
                'Use reschedule and next-action updates to keep the queue accurate.',
          ),
          SizedBox(height: 12.h),
          _GuidancePoint(
            text:
                'Completed follow-ups move out of the live queue automatically.',
          ),
        ],
      ),
    );
  }
}

class _GuidancePoint extends StatelessWidget {
  const _GuidancePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Icon(
            Icons.circle_outlined,
            size: 16.sp,
            color: AppColors.vividBlue,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1.43, // line-height equivalent
              letterSpacing: 0,
              color: Color(0xFF002149),
            ),
          ),
        ),
      ],
    );
  }
}

class _BestTimeFollowUpSection extends StatelessWidget {
  const _BestTimeFollowUpSection();

  @override
  Widget build(BuildContext context) {
    final slots = [
      ('09 AM', AppColors.purpleBg),
      ('11 AM', AppColors.greenBg),
      ('02 PM', AppColors.softBlue),
      ('05 PM', AppColors.orangeBg),
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Time to Follow-Up',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Derived from scheduled slots in the current queue',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: slot.$1 == '11 AM'
                    ? BoxDecoration(
                        color: const Color(0x80F0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(22, 163, 74, 0.09),
                          width: 1,
                        ),
                      )
                    : slot.$1 == '02 PM'
                    ? BoxDecoration(
                        color: const Color(0xFFF0FDF4).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFF16A34A,
                          ).withValues(alpha: 0.09),
                          width: 1,
                        ),
                      )
                    : BoxDecoration(
                        color: const Color(0xFFFEF9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFBE9FF),
                          width: 1,
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slot.$1,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scheduled',
                          style: GoogleFonts.inter(
                            fontSize: 17.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '0',
                          style: GoogleFonts.inter(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.vividBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ... (Keep the rest of the existing classes from the original file)

class _QueueSlaSnapshotCard extends StatelessWidget {
  const _QueueSlaSnapshotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDDE3EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue SLA Snapshot',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.56,
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Follow-up response health across the current\nqueue',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1.43,
              color: Color(0xFF44474E),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(FollowUpTestScreen._slaMetrics.length, (
              index,
            ) {
              final item = FollowUpTestScreen._slaMetrics[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == FollowUpTestScreen._slaMetrics.length - 1
                        ? 0
                        : 6.w,
                  ),
                  child: _SlaMetricCard(data: item),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SlaMetricCard extends StatelessWidget {
  const _SlaMetricCard({required this.data});

  final _SlaMetric data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1.67,
              color: Color(0xFF44474E),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: data.badgeBackground,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              data.badge,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.88,
                letterSpacing: 0.5,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpsQueueCard extends StatelessWidget {
  const _FollowUpsQueueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDDE3EC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FollowUpTabs(),
          SizedBox(height: 16.h),
          const _FollowUpChannelFilters(),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF7A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Add Follow-Up',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 102.w,
                height: 38.h,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.filter_alt_outlined,
                    size: 16.sp,
                    color: const Color(0xFF4B5563),
                  ),
                  label: Text(
                    'Filters',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      color: const Color(0xFF44474E),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC8D1E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _FollowUpLeadCard(data: FollowUpTestScreen._leadCard),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailBlock(
                  label: 'Owner',
                  primary: 'Telecaller Test',
                  secondary: '',
                  primaryColor: AppColors.navy,
                  leadingIcon: Icons.person_outline,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFD8DFEA), height: 1),
          SizedBox(height: 14.h),
          Text(
            'Notes',
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.trending_up,
                color: const Color(0xFF10B981),
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Reach out and capture next update.',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFD8DFEA), height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Showing 0 follow-ups',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFC8D1E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rows 10',
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16.sp,
                      color: const Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowUpPerformanceCard extends StatelessWidget {
  const _FollowUpPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F3FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-Up Performance',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Live queue summary',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14.h,
            crossAxisSpacing: 14.w,
            childAspectRatio: 1.1,
            children: const [
              _PerformanceTile(
                title: 'Completed',
                value: '0',
                footer: '0 done',
                accent: Color(0xFF16B943),
              ),
              _PerformanceTile(
                title: 'Pending',
                value: '1',
                footer: '0 due today',
                accent: Color(0xFF2563EB),
              ),
              _PerformanceTile(
                title: 'Contacted',
                value: '1',
                footer: '100%',
                accent: Color(0xFF7C3AED),
              ),
              _PerformanceTile(
                title: 'Best Slot',
                value: '09 AM',
                footer: '0 follow-ups',
                accent: Color(0xFFF97316),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceTile extends StatelessWidget {
  const _PerformanceTile({
    required this.title,
    required this.value,
    required this.footer,
    required this.accent,
  });

  final String title;
  final String value;
  final String footer;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: title == 'Best Slot'
                ? const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: Color(0xFFF97316),
                  )
                : GoogleFonts.inter(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1.05,
                  ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              footer,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.33,
                letterSpacing: 0.6,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpTabs extends StatelessWidget {
  const _FollowUpTabs();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _tabText('All Follow-Ups (0)', const Color(0xFF2563EB), true),
              SizedBox(width: 28.w),
              _tabText('Today (0)', const Color(0xFF3F3F46), false),
              SizedBox(width: 28.w),
              _tabText('Overdue (0)', const Color(0xFFDC2626), false),
              SizedBox(width: 18.w),
              Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF111827),
                size: 18.sp,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Container(
              width: 82.w,
              height: 2.h,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: const Color(0xFFD8DFEA)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tabText(String text, Color color, bool selected) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: selected ? const Color(0xFF2563EB) : color,
      ),
    );
  }
}

class _FollowUpChannelFilters extends StatelessWidget {
  const _FollowUpChannelFilters();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _FilterChipButton(
            label: 'All',
            icon: Icons.grid_view_rounded,
            selected: true,
          ),
          _FilterChipButton(label: 'Call', icon: Icons.phone_in_talk_outlined),
          _FilterChipButton(label: 'WhatsApp', icon: Icons.chat_bubble_outline),
          _FilterChipButton(label: 'Email', icon: Icons.mail_outline),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? const Color(0xFF2563EB) : const Color(0xFFC8D1E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: selected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF4B5563),
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpLeadCard extends StatelessWidget {
  const _FollowUpLeadCard({required this.data});

  final _FollowUpLeadCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE1E7F0)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF2FF),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'SN',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.name,
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFDAD6),
                                  borderRadius: BorderRadius.circular(
                                    9999,
                                  ), // pill shape
                                ),
                                child: Text(
                                  data.status,
                                  style: GoogleFonts.inter(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.more_vert,
                                color: const Color(0xFF374151),
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      data.property,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.source,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.33, // line-height equivalent
                        letterSpacing: 0,
                        color: Color(0xFF74777F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFD8DFEA), height: 1),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailBlock(
                  label: 'Follow-Up Time',
                  primary: data.followUpLabel,
                  secondary: data.followUpTime,
                  primaryColor: const Color(0xFF2563EB),
                ),
              ),
              Expanded(
                child: _DetailBlock(
                  label: 'Type',
                  primary: data.typeValue,
                  secondary: data.typeMeta,
                  primaryColor: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFD8DFEA), height: 1),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailBlock(
                  label: 'Last Contact',
                  primary: data.lastContactDate,
                  secondary: data.lastContactTime,
                ),
              ),
              Expanded(
                child: _DetailBlock(
                  label: 'Next Action',
                  primary: data.nextAction,
                  secondary: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.label,
    required this.primary,
    required this.secondary,
    this.primaryColor = AppColors.navy,
    this.leadingIcon,
  });

  final String label;
  final String primary;
  final String secondary;
  final Color primaryColor;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            height: 1.4, // line-height equivalent
            letterSpacing: 0,
            color: const Color(0xFF44474E),
          ),
        ),
        SizedBox(height: 6.h),
        if (leadingIcon == null)
          Text(
            primary,
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F6FB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  leadingIcon,
                  size: 13.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                primary,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.38, // line-height equivalent
                  letterSpacing: 0,
                  color: const Color(0xFF002149),
                ),
              ),
            ],
          ),

        if (secondary.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            secondary,
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ],
    );
  }
}

class _FollowUpMetricCard extends StatelessWidget {
  const _FollowUpMetricCard({required this.data, this.fullWidth = false});

  final _FollowUpMetric data;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66C4C6D0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                child: Icon(data.icon, color: data.iconColor, size: 22.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: fullWidth ? 8.h : 6.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              data.value,
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: fullWidth ? 16.h : 14.h),
          Text(
            data.subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              height: 1.4,
              color: Color(0xFF44474E),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            data.footer,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpMetric {
  const _FollowUpMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.footer,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final String footer;
  final IconData icon;
  final Color iconColor;
}

class _SlaMetric {
  const _SlaMetric({
    required this.value,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeBackground,
  });

  final String value;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeBackground;
}

class _FollowUpLeadCardData {
  const _FollowUpLeadCardData({
    required this.name,
    required this.status,
    required this.property,
    required this.source,
    required this.followUpLabel,
    required this.followUpTime,
    required this.typeValue,
    required this.typeMeta,
    required this.lastContactDate,
    required this.lastContactTime,
    required this.nextAction,
  });

  final String name;
  final String status;
  final String property;
  final String source;
  final String followUpLabel;
  final String followUpTime;
  final String typeValue;
  final String typeMeta;
  final String lastContactDate;
  final String lastContactTime;
  final String nextAction;
}
