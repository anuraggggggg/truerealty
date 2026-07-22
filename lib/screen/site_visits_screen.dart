import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SiteVisitDetailsScreen extends StatelessWidget {
  const SiteVisitDetailsScreen({super.key});

  static const Color _bg = Color(0xFFF8FAFE);
  static const Color _cardBorder = Color(0xFFDCE6F3);
  static const Color _title = Color(0xFF0F2B57);
  static const Color _body = Color(0xFF667085);
  static const Color _muted = Color(0xFF98A2B3);
  static const Color _orange = Color(0xFFFF7315);

  static const _metrics = [
    _SiteVisitMetric(
      icon: Icons.event_available_outlined,
      iconColor: Color(0xFF2563EB),
      iconBg: Color(0xFFEAF2FF),
      title: 'Total Visits',
      value: '0',
      subtitle: 'All active lead visits',
    ),
    _SiteVisitMetric(
      icon: Icons.access_time_outlined,
      iconColor: Color(0xFFFF8A26),
      iconBg: Color(0xFFFFF2E8),
      title: 'Upcoming',
      value: '0',
      subtitle: 'Next scheduled visits',
    ),
    _SiteVisitMetric(
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF10B981),
      iconBg: Color(0xFFE8FBF3),
      title: 'Completed',
      value: '0',
      subtitle: 'Completed tours',
    ),
    _SiteVisitMetric(
      icon: Icons.cancel_outlined,
      iconColor: Color(0xFFF04438),
      iconBg: Color(0xFFFFEFEF),
      title: 'Cancelled',
      value: '0',
      subtitle: 'Needs reschedule review',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 26.h),
                _buildExecutiveDropdown(),
                SizedBox(height: 12.h),
                _buildFiltersRow(),
                SizedBox(height: 12.h),
                _buildCreateButton(context),
                SizedBox(height: 24.h),
                _buildMetricsGrid(),
                SizedBox(height: 16.h),
                const _FieldExecutivesCard(),
                SizedBox(height: 16.h),
                const _VisitsListCard(),
                SizedBox(height: 16.h),
                const _TodayUpcomingCard(),
                SizedBox(height: 16.h),
                const _OperationsSnapshotCard(),
                SizedBox(height: 16.h),
                const _FieldActionsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 22.sp,
              color: _orange,
            ),
            SizedBox(width: 8.w),
            Text(
              'Site Visits',
              style: GoogleFonts.inter(
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                color: _title,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Text(
          'Central visit control for scheduled property tours, re-\nvisits, virtual visits, and field execution.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            height: 1.55,
            fontWeight: FontWeight.w400,
            color: _body,
          ),
        ),
      ],
    );
  }

  Widget _buildExecutiveDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'All Executives',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF344054),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22.sp,
            color: const Color(0xFF667085),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _cardBorder),
          ),
          child: Icon(
            Icons.refresh,
            size: 22.sp,
            color: const Color(0xFF344054),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_alt_rounded,
                  size: 18.sp,
                  color: const Color(0xFF475467),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475467),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showCreateSiteVisitSheet(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _orange,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: Icon(Icons.add, size: 20.sp, color: Colors.white),
        label: Text(
          'Create Site Visit',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCreateSiteVisitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateSiteVisitSheet(),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(metric: _metrics[0])),
            SizedBox(width: 12.w),
            Expanded(child: _MetricCard(metric: _metrics[1])),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(child: _MetricCard(metric: _metrics[2])),
            SizedBox(width: 12.w),
            Expanded(child: _MetricCard(metric: _metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _SiteVisitMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170.h,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: metric.iconBg,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(metric.icon, size: 17.sp, color: metric.iconColor),
          ),
          SizedBox(height: 16.h),
          Text(
            metric.title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            metric.value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Text(
            metric.subtitle,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: SiteVisitDetailsScreen._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldExecutivesCard extends StatelessWidget {
  const _FieldExecutivesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF4ECFF),
              borderRadius: BorderRadius.circular(19.r),
            ),
            child: Icon(
              Icons.groups_2_outlined,
              size: 18.sp,
              color: const Color(0xFF9333EA),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Field Executives',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '3',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Assigned this week',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      height: 1.33, // line-height
                      letterSpacing: 0,
                      color: const Color(0xFF74777F),
                    ),
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

class _CreateSiteVisitSheet extends StatelessWidget {
  const _CreateSiteVisitSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18.sp,
                        color: SiteVisitDetailsScreen._orange,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Site Visit',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Schedule a visit from existing CRM lead, project,\nand inventory records.',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsets.all(2.r),
                          child: Icon(
                            Icons.close,
                            size: 22.sp,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Plan Site Visit',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Choose the lead, property, schedule, and field\nhandoff details.',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF475467),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Divider(height: 1, color: const Color(0xFFDCE6F3)),
                  SizedBox(height: 20.h),
                  const _SelectedLeadSummaryCard(),
                  SizedBox(height: 14.h),
                  const _SchedulingTipCard(),
                  SizedBox(height: 16.h),
                  const _LeadContextCard(),
                  SizedBox(height: 16.h),
                  const _FieldHandoffCard(),
                ],
              ),
            ),
          ),
          const _SheetFooterBar(),
        ],
      ),
    );
  }
}

class _SelectedLeadSummaryCard extends StatelessWidget {
  const _SelectedLeadSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'SELECTED LEAD',
                  value: 'Not selected',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'PHONE',
                  value: '-',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'PROJECT',
                  value: 'Not selected',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'UNIT',
                  value: '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SchedulingTipCard extends StatelessWidget {
  const _SchedulingTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFA64D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
              color: SiteVisitDetailsScreen._orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info, size: 12.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduling Tip',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC05621),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Use the searchable lead field instead of typing IDs. IDs are\nstill sent internally to the API.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC05621),
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

class _LeadContextCard extends StatelessWidget {
  const _LeadContextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Lead Context',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            'Lead *',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          const _SheetInput(
            value: 'Search lead by name, phone, or lead ID',
            trailingIcon: Icons.keyboard_arrow_down,
            muted: true,
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Lead Stage',
                  value: '-',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Source',
                  value: '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldHandoffCard extends StatelessWidget {
  const _FieldHandoffCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Field Handoff',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Type *',
                  value: 'Site Visit',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Assigned Executive *',
                  value: 'Search executive',
                  trailingIcon: Icons.keyboard_arrow_down,
                  muted: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Date *',
                  value: 'dd-mm-yyyy',
                  muted: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Time *',
                  value: '10:00 AM',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Duration',
                  value: '60 Minutes',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visitors',
                  value: '2 Visitors',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Transport',
                  value: 'Own Vehicle',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Meeting Point',
                  value: 'Sales Gallery',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Special Request',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              'Parking needs, senior citizen assistance,\npreferred sample flat, negotiation context...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetFooterBar extends StatelessWidget {
  const _SheetFooterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFDCE6F3)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Required: lead, project, date, time, and executive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF98A2B3),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    side: const BorderSide(color: Color(0xFFB8C5D9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SiteVisitDetailsScreen._orange,
                    minimumSize: Size.fromHeight(42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.event_outlined,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Schedule Visit',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF98A2B3),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        SizedBox(height: 10.h),
        _SheetInput(
          value: value,
          muted: muted,
          trailingIcon: trailingIcon,
        ),
      ],
    );
  }
}

class _SheetInput extends StatelessWidget {
  const _SheetInput({
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: muted ? const Color(0xFF667085) : const Color(0xFF111827),
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: 18.sp,
              color: const Color(0xFF667085),
            ),
        ],
      ),
    );
  }
}

class _VisitsListCard extends StatelessWidget {
  const _VisitsListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _VisitTab(label: 'All Visits (0)', selected: true),
                  _VisitTab(label: 'Upcoming (0)'),
                  _VisitTab(label: 'Scheduled (0)'),
                  _VisitTab(label: 'Completed (0)'),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            color: const Color(0xFFDCE6F3),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 34.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'View: Table',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.sp,
                          color: const Color(0xFF667085),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  height: 34.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 16.sp,
                        color: const Color(0xFF667085),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Export',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: const Color(0xFFDCE6F3),
          ),
          const _SiteVisitListItem(),
          Divider(
            height: 1,
            color: const Color(0xFFDCE6F3),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Showing 0 to 0 of 0 visits',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ),
                    Row(
                      children: const [
                        _PagerIcon(icon: Icons.chevron_left),
                        _PagerNumber(label: '1', selected: true),
                        _PagerNumber(label: '2'),
                        _PagerNumber(label: '3'),
                        _PagerIcon(icon: Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rows per page',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '10',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: const Color(0xFF667085),
                            ),
                          ],
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

class _SiteVisitListItem extends StatelessWidget {
  const _SiteVisitListItem();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF8),
                  borderRadius: BorderRadius.circular(23.r),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 22.sp,
                  color: const Color(0xFF173A6D),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aniket Singh',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF173A6D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Lead ID: #49281',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B95A7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13.sp,
                          color: const Color(0xFF2962FF),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Scheduled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2962FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 13.sp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'In 2 hours',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.event_note_outlined,
                label: 'VISIT SCHEDULE',
                title: 'Oct 24, 2023',
                subtitle: '02:30 PM - 03:30 PM',
              ),
              SizedBox(height: 18.h),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'PROJECT & LOCATION',
                title: 'Lodha Amara',
                subtitle: 'Kolshet Road, Thane West',
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: _MiniInfoBlock(
                  label: 'Executive',
                  leading: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'RA',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A6FAF),
                      ),
                    ),
                  ),
                  value: 'Rahul Sharma',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MiniInfoBlock(
                  label: 'Visit Type',
                  value: 'First Visit',
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    side: const BorderSide(color: Color(0xFFB8C5D9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.call_outlined,
                    size: 18.sp,
                    color: const Color(0xFF173A6D),
                  ),
                  label: Text(
                    'Call Lead',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF173A6D),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SiteVisitDetailsScreen._orange,
                    minimumSize: Size.fromHeight(42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.event_outlined,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Reschedule',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayUpcomingCard extends StatelessWidget {
  const _TodayUpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today & Upcoming',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
          SizedBox(height: 34.h),
          Center(
            child: Text(
              'No upcoming events.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsSnapshotCard extends StatelessWidget {
  const _OperationsSnapshotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operations Snapshot',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Completion Rate',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
              ),
              Text(
                '0%',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFEFF3F8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF173A6D)),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: const [
              Expanded(
                child: _SnapshotMetricCard(
                  title: 'Active Visits',
                  value: '0',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SnapshotMetricCard(
                  title: 'Completed',
                  value: '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldActionsCard extends StatelessWidget {
  const _FieldActionsCard();

  static const _items = [
    _FieldActionItem(
      icon: Icons.near_me_outlined,
      iconColor: Color(0xFF16A34A),
      iconBg: Color(0xFFE9F9EE),
      title: 'Confirm upcoming visits',
      subtitle: 'Call leads and verify travel details',
    ),
    _FieldActionItem(
      icon: Icons.location_on_outlined,
      iconColor: Color(0xFF3BA4F3),
      iconBg: Color(0xFFEAF5FF),
      title: 'Share location links',
      subtitle: 'Send maps and meeting point',
    ),
    _FieldActionItem(
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF7C3AED),
      iconBg: Color(0xFFF3EEFF),
      title: 'Collect visit feedback',
      subtitle: 'Close loop after completed visits',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 20.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Field Actions',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
          SizedBox(height: 14.h),
          ..._items.map(
            (item) => _FieldActionTile(item: item),
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetricCard extends StatelessWidget {
  const _SnapshotMetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldActionTile extends StatelessWidget {
  const _FieldActionTile({required this.item});

  final _FieldActionItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(17.r),
            ),
            child: Icon(item.icon, size: 25.sp, color: item.iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF173A6D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20.sp,
            color: SiteVisitDetailsScreen._orange,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(
            icon,
            size: 16.sp,
            color: const Color(0xFF667085),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF98A2B3),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF475467),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniInfoBlock extends StatelessWidget {
  const _MiniInfoBlock({
    required this.label,
    required this.value,
    this.leading,
  });

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF667085),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: 6.w),
            ],
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisitTab extends StatelessWidget {
  const _VisitTab({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 28.w),
      padding: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: selected
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFF0F2B57),
                  width: 2,
                ),
              )
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? const Color(0xFF0F2B57) : const Color(0xFF667085),
        ),
      ),
    );
  }
}

class _PagerIcon extends StatelessWidget {
  const _PagerIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      margin: EdgeInsets.only(left: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Icon(icon, size: 16.sp, color: const Color(0xFF98A2B3)),
    );
  }
}

class _PagerNumber extends StatelessWidget {
  const _PagerNumber({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      margin: EdgeInsets.only(left: 6.w),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0F2B57) : Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: selected ? const Color(0xFF0F2B57) : SiteVisitDetailsScreen._cardBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF667085),
        ),
      ),
    );
  }
}

class _SiteVisitMetric {
  const _SiteVisitMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;
}

class _FieldActionItem {
  const _FieldActionItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
}
