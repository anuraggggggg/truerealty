import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class FieldExecutiveDashboardView extends StatelessWidget {
  const FieldExecutiveDashboardView({
    super.key,
    this.onMenuTap,
    this.bottomSpacing = 24,
  });

  final VoidCallback? onMenuTap;
  final double bottomSpacing;

  static const List<_ExecutiveMetricData> _topMetrics = [
    _ExecutiveMetricData(
      title: 'Assigned\nLeads',
      value: '5',
      icon: Icons.groups_2_outlined,
      iconColor: Color(0xFF0F2F66),
    ),
    _ExecutiveMetricData(
      title: 'Today\'s\nSite Visits',
      value: '5',
      icon: Icons.location_on_outlined,
      iconColor: Color(0xFF06B6D4),
    ),
    _ExecutiveMetricData(
      title: 'Upcoming\nVisits',
      value: '5',
      icon: Icons.schedule_outlined,
      iconColor: Color(0xFFA855F7),
    ),
  ];

  static const List<_ExecutiveMetricData> _middleMetrics = [
    _ExecutiveMetricData(
      title: 'Completed\nVisits',
      value: '0',
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF22C55E),
    ),
    _ExecutiveMetricData(
      title: 'Missed\nVisits',
      value: '0',
      icon: Icons.event_busy_outlined,
      iconColor: Color(0xFFEF4444),
    ),
  ];

  static const List<_ExecutiveMetricData> _bottomMetrics = [
    _ExecutiveMetricData(
      title: 'Pending Follow-ups',
      value: 'Rs 12,00,000',
      icon: Icons.assignment_late_outlined,
      iconColor: Color(0xFFF97316),
    ),
    _ExecutiveMetricData(
      title: 'Bookings Assisted',
      value: '2',
      icon: Icons.handshake_outlined,
      iconColor: Color(0xFF2563EB),
    ),
  ];

  static const _ExecutiveMetricData _fullWidthMetric = _ExecutiveMetricData(
    title: 'Visits Pending\nStart',
    value: '1',
    icon: Icons.assignment_turned_in_outlined,
    iconColor: Color(0xFFF97316),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, bottomSpacing.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onMenuTap != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: onMenuTap,
                borderRadius: BorderRadius.circular(14.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.menu_rounded,
                    size: 26.sp,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
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
            'Field operations overview for Khushvinder Kaur.',
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              for (int i = 0; i < _topMetrics.length; i++) ...[
                Expanded(child: _ExecutiveMetricCard(data: _topMetrics[i])),
                if (i != _topMetrics.length - 1) SizedBox(width: 10.w),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _ExecutiveMetricCard(data: _middleMetrics[0])),
              SizedBox(width: 12.w),
              Expanded(child: _ExecutiveMetricCard(data: _middleMetrics[1])),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _ExecutiveMetricCard(data: _bottomMetrics[0])),
              SizedBox(width: 12.w),
              Expanded(child: _ExecutiveMetricCard(data: _bottomMetrics[1])),
            ],
          ),
          SizedBox(height: 10.h),
          const _ExecutiveMetricCard(
            data: _fullWidthMetric,
            fullWidth: true,
          ),
          SizedBox(height: 14.h),
          const _CheckInStatusCard(),
          SizedBox(height: 12.h),
          const _ExecutiveAlertCard(),
          SizedBox(height: 12.h),
          const _ExecutiveRecentActivityCard(),
          SizedBox(height: 12.h),
          const _TodayStopsCard(),
        ],
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
              Icon(
                data.icon,
                size: 18.sp,
                color: data.iconColor,
              ),
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
  const _ExecutiveSectionCard({
    required this.child,
    this.padding,
  });

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
  const _CheckInStatusCard();

  static const List<_StatusMetric> _items = [
    _StatusMetric('Checked in', '0', Color(0xFF22C55E)),
    _StatusMetric('Pending', '0', Color(0xFFF97316)),
    _StatusMetric('Checked out', '0', Color(0xFF2563EB)),
    _StatusMetric('Missed', '1', Color(0xFFEF4444)),
  ];

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
            children: _items
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
  const _ExecutiveAlertCard();

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
                Text(
                  'Follow-up action due',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFBF5A2A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '1 pending follow-up',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFBF5A2A),
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

class _ExecutiveRecentActivityCard extends StatelessWidget {
  const _ExecutiveRecentActivityCard();

  static const List<String> _items = [
    'Completed Ocean Heights revisit -\nFamily shortlisted the west-facing sea\nview unit.',
    'Prepared Sunset Residency visit -\nMeeting point and family arrival\nconfirmed.',
  ];

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
          for (int i = 0; i < _items.length; i++) ...[
            _ExecutiveActivityRow(text: _items[i]),
            if (i != _items.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: Divider(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TodayStopsCard extends StatelessWidget {
  const _TodayStopsCard();

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
          Text(
            'No route stops today.',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563),
            ),
          ),
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
          child: Icon(
            Icons.check,
            size: 15.sp,
            color: const Color(0xFF22C55E),
          ),
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
