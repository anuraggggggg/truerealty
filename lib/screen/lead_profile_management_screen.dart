import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';

class LeadProfileManagementScreen extends StatefulWidget {
  const LeadProfileManagementScreen({super.key, this.lead});

  final LeadModel? lead;

  @override
  State<LeadProfileManagementScreen> createState() =>
      _LeadProfileManagementScreenState();
}

class _LeadProfileManagementScreenState
    extends State<LeadProfileManagementScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final profile = _LeadProfileData.fromLead(widget.lead);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(onBack: () => Navigator.of(context).maybePop()),
              SizedBox(height: 22.h),
              _ProfileHeaderCard(profile: profile),
              SizedBox(height: 20.h),
              _ProfileInfoCard(profile: profile),
              SizedBox(height: 20.h),
              _LeadScoreCard(profile: profile),
              SizedBox(height: 20.h),
              _MetricGrid(profile: profile),
              SizedBox(height: 22.h),
              _ProfileTabBar(
                selectedIndex: _selectedTabIndex,
                onChanged: (index) => setState(() => _selectedTabIndex = index),
              ),
              SizedBox(height: 22.h),
              _LeadProfileTabContent(
                selectedIndex: _selectedTabIndex,
                profile: profile,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addActivity);
        },
        backgroundColor: AppColors.orangeDeep,
        child: const Icon(Icons.add, color: AppColors.white, size: 30),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(22.r),
          child: Padding(
            padding: EdgeInsets.all(6.r),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 19.sp,
              color: AppColors.slate900,
            ),
          ),
        ),
        const Spacer(),
        Icon(Icons.more_horiz, size: 24.sp, color: AppColors.textSecondary),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      // decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initials: profile.initials),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BadgeChip(label: profile.badge),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12.w,
                      runSpacing: 10.h,
                      children: [
                        Text(
                          profile.leadId,
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: 0.2,
                            color: AppColors.blueBright,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F6FF),
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(color: const Color(0xFFDDE7FF), width: 1.2),
                          ),
                          child: Text(
                            profile.status,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blueBright,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          _ContactRow(icon: Icons.call_rounded, value: profile.phone),
          SizedBox(height: 16.h),
          _ContactRow(icon: Icons.mail_outline_rounded, value: profile.email),
          SizedBox(height: 16.h),
          _ContactRow(icon: Icons.location_on_rounded, value: profile.location),
          SizedBox(height: 18.h),
          Divider(color: const Color(0xFFE8EDF4), height: 1.h),
          SizedBox(height: 18.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Lead Source: ',
                  style: GoogleFonts.inter(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                TextSpan(
                  text: profile.source,
                  style: GoogleFonts.inter(
                    fontSize: 16.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
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

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Lead Stage', profile.stage),
      MapEntry('Lead Status', profile.status),
      MapEntry('Assigned To', profile.assignedTo),
      MapEntry('Manager', profile.manager),
      MapEntry('Created On', profile.createdOn),
      MapEntry('Last Updated', profile.updatedOn),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: _cardDecoration(),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130.w,
                      child: Text(
                        row.key,
                        style: GoogleFonts.inter(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        row.value,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          height: 1.43, // line-height equivalent
                          letterSpacing: 0,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LeadScoreCard extends StatelessWidget {
  const _LeadScoreCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 18.h),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'AI Lead Score',
                style: GoogleFonts.inter(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHeading,
                ),
              ),
              const Spacer(),
              Icon(Icons.menu, size: 20.sp, color: AppColors.textSecondary),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 116.w,
            height: 116.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 112.w,
                  height: 112.w,
                  child: CircularProgressIndicator(
                    value: profile.score / 100,
                    strokeWidth: 12.w,
                    backgroundColor: const Color(0xFFE9EEF5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.green,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${profile.score}',
                      style: GoogleFonts.inter(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHeading,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -3.h),
                      child: Text(
                        '/100',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            profile.scoreLabel,
            style: GoogleFonts.inter(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'View Scoring Logic',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blueBright,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                title: 'Estimated Conversion',
                value: '${profile.estimatedConversion}%',
                emphasis: profile.estimatedConversionLabel,
                emphasisColor: AppColors.orangeDeep,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: _MetricTile(
                title: 'Estimated Revenue',
                value: profile.estimatedRevenue,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                title: 'Lead Temperature',
                customValue: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: const Color(0xFFD8E2F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 16.sp,
                        color: AppColors.orangeDeep,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        profile.temperature,
                        style: GoogleFonts.inter(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate900,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.expand_more,
                        size: 18.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: _MetricTile(
                title: 'Engagement Score',
                value: '${profile.engagementScore}%',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    this.value,
    this.emphasis,
    this.emphasisColor,
    this.customValue,
  });

  final String title;
  final String? value;
  final String? emphasis;
  final Color? emphasisColor;
  final Widget? customValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 10.h),
          customValue ??
              Text(
                value ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  height: 1.33,
                  letterSpacing: 0,
                  color: Color(0xFF0F172A),
                ),
              ),
          if (emphasis != null) ...[
            SizedBox(height: 6.h),
            Text(
              emphasis!,
              style: GoogleFonts.inter(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: emphasisColor ?? AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = ['Overview', 'Activities Timeline', 'Property Preferences'];

    return Container(
      padding: EdgeInsets.only(bottom: 2.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EDF4), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          items.length,
          (index) => Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60.h,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            items[index],
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: index == 0 ? 18.sp : 20.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.33,
                              color: selectedIndex == index
                                  ? AppColors.orangeDeep
                                  : const Color(0xFF002149),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? AppColors.orangeDeep
                            : AppColors.transparentWhite,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadProfileTabContent extends StatelessWidget {
  const _LeadProfileTabContent({
    required this.selectedIndex,
    required this.profile,
  });

  final int selectedIndex;
  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return _OverviewTabCard(profile: profile);
      case 1:
        return Column(
          children: [
            const _ActivitySummaryCard(),
            SizedBox(height: 14.h),
            const _TimelineFiltersCard(),
            SizedBox(height: 14.h),
            const _JourneyStagesCard(),
            SizedBox(height: 14.h),
            // _HighlightsAndActions(profile: profile),
            SizedBox(height: 16.h),
            const _LeadTimelineSection(),
          ],
        );
      default:
        return _PropertyPreferencesCard(profile: profile);
    }
  }
}

class _OverviewTabCard extends StatelessWidget {
  const _OverviewTabCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Full Name', profile.name),
      MapEntry('Mobile Number', profile.phone),
      MapEntry('Alternate Number', profile.alternatePhone),
      MapEntry('Email\nAddress', profile.email),
      MapEntry('Date of Birth', profile.dateOfBirth),
      MapEntry('Occupation', profile.occupation),
      MapEntry('Company Name', profile.companyName),
      MapEntry('Annual Income', profile.annualIncome),
      MapEntry('Marital Status', profile.maritalStatus),
      MapEntry('Address', profile.fullAddress),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Lead',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  color: const Color(0xFF002149),
                ),
              ),
              SizedBox(height: 12.h),
              ...rows.map(
                (row) => Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE4EAF2)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 144.w,
                        child: Text(
                          row.key,
                          style: GoogleFonts.inter(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7B97),
                            height: 1.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: const Color(0xFF002149),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _EngagementSummaryCard(profile: profile),
        SizedBox(height: 16.h),
        _CommunicationQuickViewCard(profile: profile),
        SizedBox(height: 16.h),
        _PropertyRequirementsCard(profile: profile),
        SizedBox(height: 16.h),
        _LatestBookingCard(profile: profile),
        SizedBox(height: 16.h),
        _NextFollowUpCard(profile: profile),
        SizedBox(height: 16.h),
        // const _QuickActionsCard(),
        // SizedBox(height: 16.h),
        _OverviewActivityTimelineCard(profile: profile),
      ],
    );
  }
}

class _EngagementSummaryCard extends StatelessWidget {
  const _EngagementSummaryCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _EngagementLegendItem('Calls', '7 (39%)', const Color(0xFF4F83FF)),
      _EngagementLegendItem('WhatsApp', '6\n(33%)', const Color(0xFF10B981)),
      _EngagementLegendItem('Emails', '2 (11%)', const Color(0xFFF59E0B)),
      _EngagementLegendItem('Site Visits', '2 (11%)', const Color(0xFF8B5CF6)),
      _EngagementLegendItem('Others', '1 (6%)', const Color(0xFFCBD5E1)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: _activityTimelineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Summary',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              height: 1.33,
              letterSpacing: 0,
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Container(
              width: 102.w,
              height: 102.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F4F8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${profile.interactions}',
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueDeep,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'INTERACTIONS',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22.h),
          Wrap(
            spacing: 20.w,
            runSpacing: 18.h,
            children: items
                .map(
                  (item) => SizedBox(
                    width: 150.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(top: 8.h),
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 2,
                            style: GoogleFonts.inter(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7B97),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            item.value,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: const Color(0xFF002149),
                            ),
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
    );
  }
}

class _CommunicationQuickViewCard extends StatelessWidget {
  const _CommunicationQuickViewCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickViewItem(
        'Total Calls',
        '${profile.totalCalls}',
        Icons.call_outlined,
        const Color(0xFF4F83FF),
        const Color(0xFFEAF2FF),
      ),
      _QuickViewItem(
        'Total WhatsApp',
        '${profile.totalWhatsApp}',
        Icons.chat_bubble_outline,
        const Color(0xFF10B981),
        const Color(0xFFE9FBF3),
      ),
      _QuickViewItem(
        'Total Emails',
        '${profile.totalEmails}',
        Icons.mail_outline,
        const Color(0xFFF97316),
        const Color(0xFFFFF1E8),
      ),
      _QuickViewItem(
        'Total Site Visits',
        '${profile.totalSiteVisits}',
        Icons.location_on_outlined,
        const Color(0xFF8B5CF6),
        const Color(0xFFF3E8FF),
      ),
      _QuickViewItem(
        'Total Tasks',
        '${profile.totalTasks}',
        Icons.check_circle_outline,
        const Color(0xFF64748B),
        const Color(0xFFF1F5F9),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Communication Quick View',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              height: 1.33,
              letterSpacing: 0,
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 14.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 9.h),
              child: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: item.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: 17.sp, color: item.color),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: const Color(0xFF002149),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueDeep,
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

class _PropertyRequirementsCard extends StatelessWidget {
  const _PropertyRequirementsCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _RequirementItem(
        Icons.apartment_outlined,
        'Property Type',
        profile.propertyType,
      ),
      _RequirementItem(
        Icons.account_balance_wallet_outlined,
        'Budget Range',
        profile.overviewBudgetRange,
      ),
      _RequirementItem(
        Icons.location_on_outlined,
        'Preferred\nLocation',
        profile.overviewPreferredLocation,
      ),
      _RequirementItem(
        Icons.favorite_border,
        'Preferred Project',
        profile.preferredProject,
      ),
      _RequirementItem(
        Icons.bed_outlined,
        'Configuration',
        profile.configuration,
      ),
      _RequirementItem(
        Icons.square_foot_outlined,
        'Carpet Area',
        profile.carpetArea,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Requirements',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              height: 1.33,
              letterSpacing: 0,
              color: Color(0xFF002149),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 18.h,
            children: items
                .map(
                  (item) => SizedBox(
                    width: 146.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item.icon,
                              size: 16.sp,
                              color: const Color(0xFF6B7B97),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7B97),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          item.value,
                          maxLines: 3,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: const Color(0xFF121C2A),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 16.h),
          Container(height: 1.h, color: const Color(0xFFE4EAF2)),
          SizedBox(height: 14.h),
          Text(
            'Amenities Required',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7B97),
            ),
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: profile.amenities
                  .map(
                    (amenity) => ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FF),
                          borderRadius: BorderRadius.circular(9999), // pill shape
                          border: Border.all(
                            color: const Color(0xFFC3C6D1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          amenity.toLowerCase(),
                          softWrap: true,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal,
                            height: 1.5, // line-height equivalent
                            letterSpacing: 0,
                            color: Color(0xFF43474F),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestBookingCard extends StatelessWidget {
  const _LatestBookingCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Latest Booking',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  height: 1.33,
                  letterSpacing: 0,
                  color: Color(0xFF002149),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7FBEF),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'CONFIRMED',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1F8),
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.latestBookingProject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: const Color(0xFF002149),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      profile.latestBookingType,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7B97),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      profile.latestBookingPrice,
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: AppColors.blueDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1.h, color: const Color(0xFFE4EAF2)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SourceValueBlock(
                  label: 'Booking Date',
                  value: profile.latestBookingDate,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: _SourceValueBlock(
                  label: 'Booking ID',
                  value: profile.latestBookingId,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Center(
            child: Text(
              'View Booking Details',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                height: 1.5,
                letterSpacing: 0,
                color: Color(0xFF002149),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextFollowUpCard extends StatelessWidget {
  const _NextFollowUpCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Follow-up\nType', profile.followUpType),
      MapEntry('Assigned To', profile.followUpAssignedTo),
      MapEntry('Notes', profile.followUpNotes),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFC9A6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Next Follow-up',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  fontStyle: FontStyle.normal,
                  height: 1.33,
                  letterSpacing: 0,
                  color: Color(0xFF002149),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.edit_outlined,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE7EDF4)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18.sp,
                  color: AppColors.orangeDeep,
                ),
                Text(
                  profile.followUpDate,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    height: 1.43,
                    letterSpacing: 0.7,
                    color: Color(0xFF002149),
                  ),
                ),
                Text(
                  profile.followUpTime,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    height: 1.43,
                    letterSpacing: 0.7,
                    color: Color(0xFF002149),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                    child: Text(
                      'IN 1 DAY',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeDeep,
                      ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ...rows.map(
            (row) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112.w,
                    child: Text(
                      row.key,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7B97),
                        height: 1.35,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        height: 1.43,
                        letterSpacing: 0.7,
                        color: Color(0xFF002149),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Follow-up marked as completed')),
              );
            },
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: double.infinity,
              height: 42.h,
              decoration: BoxDecoration(
                color: AppColors.orangeDeep,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'Mark as Completed',
                  style: GoogleFonts.inter(
                    fontSize: 15.5.sp,
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

class _OverviewActivityTimelineCard extends StatelessWidget {
  const _OverviewActivityTimelineCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _OverviewTimelineItem(
        '10:25 AM',
        Icons.person_add_alt_1_outlined,
        const Color(0xFF4F83FF),
        'Lead Created',
        '20 May 2025',
        'Lead created from\nMagicBricks',
      ),
      _OverviewTimelineItem(
        '10:30 AM',
        Icons.assignment_ind_outlined,
        AppColors.orangeDeep,
        'Lead Assigned',
        '20 May 2025',
        'Assigned to Sneha Iyer\nby Rahul Mehta',
      ),
      _OverviewTimelineItem(
        '11:15 AM',
        Icons.call_outlined,
        AppColors.blueBright,
        'Outgoing Call',
        '20 May 2025',
        'Spoke with Rahul\nSharma\nDuration: 05:24',
      ),
      _OverviewTimelineItem(
        '12:05 PM',
        Icons.chat_bubble_outline,
        AppColors.green,
        'WhatsApp\nMessage',
        '20 May\n2025',
        'Brochure sent via\nWhatsApp',
      ),
      _OverviewTimelineItem(
        '02:30 PM',
        Icons.calendar_today_outlined,
        AppColors.orangeDeep,
        'Site Visit\nScheduled',
        '20 May\n2025',
        'Ocean Heights - 21\nMay 2025, 11:00 AM',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Text(
                  'Activity Timeline',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.addActivity);
                },
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.orangeDeep.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18.sp,
                    color: AppColors.orangeDeep,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFDCE4EE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'All Activities',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.expand_more,
                      size: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return _OverviewTimelineRow(item: item, isLast: isLast);
          }),
          SizedBox(height: 16.h),
          Center(
            child: InkWell(
              onTap: () {
                // In a real app, this might scroll down or switch the tab
                // Assuming we want to switch to the "Activities Timeline" tab (index 1)
                // Since this is a stateless widget, we can't directly change state of parent here easily
                // without a callback, but for now we'll just show navigation intent
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switching to Activities Timeline tab')),
                );
              },
              child: Text(
                'View Full Timeline',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTimelineRow extends StatelessWidget {
  const _OverviewTimelineRow({required this.item, required this.isLast});

  final _OverviewTimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58.w,
            child: Text(
              item.time,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 28.w,
            child: Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, size: 12.sp, color: item.color),
                ),
                if (!isLast)
                  Container(
                    width: 1.4.w,
                    height: 100.h,
                    color: const Color(0xFFDCE4EE),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 13.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFDCE4EE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item.description,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7B97),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item.date,
                    textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7B97),
                        height: 1.3,
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

class _OverviewTimelineItem {
  const _OverviewTimelineItem(
    this.time,
    this.icon,
    this.color,
    this.title,
    this.date,
    this.description,
  );

  final String time;
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String description;
}

class _RequirementItem {
  const _RequirementItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _SourceValueBlock extends StatelessWidget {
  const _SourceValueBlock({required this.label, required this.value});

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
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7B97),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            height: 1.5,
            letterSpacing: 0,
            color: Color(0xFF002149),
          ),
        ),
      ],
    );
  }
}

class _EngagementLegendItem {
  const _EngagementLegendItem(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

class _QuickViewItem {
  const _QuickViewItem(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;
}

class _PropertyPreferencesCard extends StatelessWidget {
  const _PropertyPreferencesCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Preferred Location', profile.preferredLocation),
      MapEntry('Property Type', profile.propertyType),
      MapEntry('Budget Range', profile.budgetRange),
      MapEntry('Bedrooms', profile.bedrooms),
      MapEntry('Possession', profile.possession),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Preferences',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
            ),
          ),
          SizedBox(height: 12.h),
          ...rows.map(
            (row) => Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 144.w,
                    child: Text(
                      row.key,
                      style: GoogleFonts.inter(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
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

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard();

  @override
  Widget build(BuildContext context) {
    final leftItems = [
      _SummaryItem(
        'All Activities',
        '32',
        Icons.history,
        AppColors.blueBright,
        highlighted: true,
      ),
      _SummaryItem('WhatsApp', '8', Icons.chat_bubble_outline, AppColors.green),
      _SummaryItem('SMS', '4', Icons.sms_outlined, AppColors.textSecondary),
      _SummaryItem(
        'Tasks',
        '2',
        Icons.task_alt_outlined,
        AppColors.textSecondary,
      ),
      _SummaryItem(
        'Bookings',
        '0',
        Icons.apartment_outlined,
        AppColors.textSecondary,
      ),
    ];
    final rightItems = [
      _SummaryItem('Calls', '10', Icons.call_outlined, AppColors.textSecondary),
      _SummaryItem('Emails', '5', Icons.mail_outline, AppColors.textSecondary),
      _SummaryItem(
        'Site Visits',
        '2',
        Icons.calendar_today_outlined,
        AppColors.textSecondary,
      ),
      _SummaryItem('Notes', '1', Icons.note_add_outlined, AppColors.orangeDeep),
      _SummaryItem(
        'Documents',
        '0',
        Icons.attach_file,
        AppColors.textSecondary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Summary',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ActivityColumn(items: leftItems)),
              Container(
                width: 1.w,
                height: 164.h,
                color: const Color(0xFFE5EAF1),
              ),
              Expanded(child: _ActivityColumn(items: rightItems)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityColumn extends StatelessWidget {
  const _ActivityColumn({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: item.highlighted
                            ? EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 5.h,
                              )
                            : EdgeInsets.zero,
                        decoration: item.highlighted
                            ? BoxDecoration(
                                color: const Color(0xFFE9F1FF),
                                borderRadius: BorderRadius.circular(8.r),
                              )
                            : null,
                        child: Row(
                          children: [
                            Icon(item.icon, size: 16.sp, color: item.color),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: item.highlighted
                                      ? AppColors.blueBright
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.value,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: item.highlighted
                            ? AppColors.blueBright
                            : AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TimelineFiltersCard extends StatelessWidget {
  const _TimelineFiltersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: _activityTimelineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Filters',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: const [
              Expanded(
                child: _FilterDropdown(
                  label: 'Activity Type',
                  value: 'All Activities',
                ),
              ),
              Expanded(
                child: _FilterDropdown(label: 'Date Range', value: 'All Time'),
              ),
              Expanded(
                child: _FilterDropdown(
                  label: 'Team Member',
                  value: 'All Members',
                  applyRightPadding: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            height: 38.h,
            decoration: _activityTimelineDecoration(),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, size: 16.sp, color: AppColors.blueBright),
                SizedBox(width: 8.w),
                Text(
                  'Clear filters',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueBright,
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

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    this.applyRightPadding = true,
  });

  final String label;
  final String value;
  final bool applyRightPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: applyRightPadding ? 8.w : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: _activityTimelineDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 16.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStagesCard extends StatelessWidget {
  const _JourneyStagesCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      _JourneyStageItem('New Lead', 'May 15, 2025\n10:20 AM', true),
      _JourneyStageItem('Contacted', 'May 15, 2025\n11:15 AM', true),
      _JourneyStageItem('Interested', 'May 16, 2025\n09:10 AM', true),
      _JourneyStageItem(
        'Site Visit\nDone',
        'May 17, 2025\n05:30 PM',
        false,
        accent: AppColors.orangeDeep,
      ),
      _JourneyStageItem('Proposal', '', false),
      _JourneyStageItem('Negotiation', '', false),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: _activityTimelineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Journey Stages',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blueDeep,
            ),
          ),
          SizedBox(height: 22.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JourneyStageNode(item: item),
                    if (index != items.length - 1)
                      Container(
                        width: 32.w,
                        height: 2.h,
                        margin: EdgeInsets.only(top: 10.h),
                        color: _journeyConnectorColor(
                          current: item,
                          next: items[index + 1],
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStageNode extends StatelessWidget {
  const _JourneyStageNode({required this.item});

  final _JourneyStageItem item;

  @override
  Widget build(BuildContext context) {
    final isOrange = item.accent == AppColors.orangeDeep;
    return SizedBox(
      width: 80.w,
      child: Column(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: item.completed
                  ? AppColors.green
                  : (isOrange ? AppColors.orangeDeep : const Color(0xFFE2E8F0)),
              shape: BoxShape.circle,
              border: Border.all(
                color: item.completed
                    ? AppColors.green
                    : (isOrange
                          ? AppColors.orangeDeep
                          : const Color(0xFFE2E8F0)),
                width: 1.4,
              ),
            ),
            child: item.completed
                ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                : isOrange
                ? Center(
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(height: 10.h),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStageItem {
  const _JourneyStageItem(
    this.title,
    this.subtitle,
    this.completed, {
    this.accent,
  });

  final String title;
  final String subtitle;
  final bool completed;
  final Color? accent;
}

// class _HighlightsAndActions extends StatelessWidget {
//   const _HighlightsAndActions({required this.profile});
//
//   final _LeadProfileData profile;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth < 720.w) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _KeyHighlightsCard(profile: profile),
//               SizedBox(height: 14.h),
//               // const _QuickActionsCard(),
//             ],
//           );
//         }
//
//         // return Row(
//         //   crossAxisAlignment: CrossAxisAlignment.start,
//         //   children: [
//         //     Expanded(child: _KeyHighlightsCard(profile: profile)),
//         //     SizedBox(width: 14.w),
//         //     const Expanded(child: _QuickActionsCard()),
//         //   ],
//         // );
//       },
//     );
//   }
// }

class _KeyHighlightsCard extends StatelessWidget {
  const _KeyHighlightsCard({required this.profile});

  final _LeadProfileData profile;

  @override
  Widget build(BuildContext context) {
    final rows = [
      MapEntry('First Response\nTime', '55\nmins'),
      const MapEntry('Total Calls', '10'),
      const MapEntry('Last\nContacted', 'Today, 11:20\nAM'),
      const MapEntry('Lead Age', '5 Days'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: _activityTimelineDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Highlights',
            style: GoogleFonts.inter(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textHeading,
            ),
          ),
          SizedBox(height: 14.h),
          ...rows.map(
            (row) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.key,
                      style: GoogleFonts.inter(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    row.value,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1.h, color: const Color(0xFFE8EDF4)),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Engagement\nScore',
                  style: GoogleFonts.inter(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    height: 1.35,
                  ),
                ),
              ),
              Text(
                '${profile.engagementScore}',
                style: GoogleFonts.inter(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '/100',
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  value: profile.engagementScore / 100,
                  strokeWidth: 3.w,
                  backgroundColor: const Color(0xFFE8EDF4),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.green,
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

// class _QuickActionsCard extends StatelessWidget {
//   const _QuickActionsCard();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
//       decoration: _activityTimelineDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: GoogleFonts.inter(
//               fontSize: 19.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textHeading,
//             ),
//           ),
//           SizedBox(height: 14.h),
//           _QuickActionButton(
//             icon: Icons.call_outlined,
//             label: 'Call Now',
//             color: AppColors.blueBright,
//             onTap: () {},
//           ),
//           SizedBox(height: 12.h),
//           _QuickActionButton(
//             icon: Icons.chat_bubble_outline,
//             label: 'Send WhatsApp',
//             color: AppColors.green,
//             onTap: () {},
//           ),
//           SizedBox(height: 12.h),
//           _QuickActionButton(
//             icon: Icons.mail_outline,
//             label: 'Send Email',
//             color: const Color(0xFF8B5CF6),
//             onTap: () {},
//           ),
//           SizedBox(height: 12.h),
//           _QuickActionButton(
//             icon: Icons.calendar_today_outlined,
//             label: 'Schedule Visit',
//             color: AppColors.blueBright,
//             onTap: () {
//               Navigator.pushNamed(context, AppRouter.addActivity);
//             },
//           ),
//           SizedBox(height: 12.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _QuickActionButton(
//                   icon: Icons.add,
//                   label: 'Create Task',
//                   color: const Color(0xFFEF4444),
//                   compact: true,
//                   onTap: () {
//                     Navigator.pushNamed(context, AppRouter.addActivity);
//                   },
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _QuickActionButton(
//                   icon: Icons.note_add_outlined,
//                   label: 'Add Note',
//                   color: const Color(0xFFEF4444),
//                   compact: true,
//                   onTap: () {
//                     Navigator.pushNamed(context, AppRouter.addActivity);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: compact ? 36.h : 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: _activityTimelineDecoration(),
        child: Row(
          mainAxisAlignment: compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: compact ? 14.sp : 16.sp, color: color),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: compact ? 13.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadTimelineSection extends StatelessWidget {
  const _LeadTimelineSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LeadTimelineHeader(),
        SizedBox(height: 14),
        _LeadTimelineCard(
          icon: Icons.call,
          iconBg: Color(0xFFE6F8EA),
          iconColor: AppColors.green,
          title: 'Follow-up Call',
          badge: 'Completed',
          badgeColor: AppColors.green,
          timeLabel: 'Today, 10:30 AM',
          description: 'Spoke with Rahul regarding 2 BHK apartments\nin Noida.',
          assigneeName: 'Amit Singh',
          assigneeRole: 'Telecaller',
          lineHeight: 110,
        ),
        SizedBox(height: 12),
        _LeadTimelineCard(
          icon: Icons.chat_bubble_outline,
          iconBg: Color(0xFFF1E2FF),
          iconColor: Color(0xFFA855F7),
          title: 'WhatsApp Message',
          badge: 'Completed',
          badgeColor: AppColors.green,
          timeLabel: 'Today, 09:15 AM',
          description: 'Sent property details and brochure on\nWhatsApp.',
          assigneeName: 'Amit Singh',
          assigneeRole: 'Telecaller',
          lineHeight: 110,
        ),
        SizedBox(height: 12),
        _LeadTimelineCard(
          icon: Icons.calendar_today_outlined,
          iconBg: Color(0xFFFFEEDB),
          iconColor: AppColors.orangeDeep,
          title: 'Site Visit Scheduled',
          badge: 'Upcoming',
          badgeColor: AppColors.blueBright,
          timeLabel: '21 May 2025\n11:30 AM',
          description: 'Green Valley Residency - 2 BHK Unit',
          assigneeName: 'Amit Singh',
          assigneeRole: 'Telecaller',
          lineHeight: 0,
        ),
      ],
    );
  }
}

class _LeadTimelineHeader extends StatelessWidget {
  const _LeadTimelineHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Lead Timeline',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.blueDeep,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        const _HeaderPill(
          icon: Icons.filter_alt_outlined,
          label: 'Filter',
        ),
        SizedBox(width: 8.w),
        const _HeaderPill(
          icon: Icons.calendar_today_outlined,
          label: 'All Time',
          trailing: Icons.expand_more,
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: _activityTimelineDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppColors.textTertiary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 4.w),
            Icon(trailing, size: 16.sp, color: AppColors.textTertiary),
          ],
        ],
      ),
    );
  }
}

class _LeadTimelineCard extends StatelessWidget {
  const _LeadTimelineCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.timeLabel,
    required this.description,
    required this.assigneeName,
    required this.assigneeRole,
    required this.lineHeight,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final String timeLabel;
  final String description;
  final String assigneeName;
  final String assigneeRole;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 46.w,
          child: Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18.sp, color: iconColor),
              ),
              if (lineHeight > 0)
                Container(
                  width: 1.5.w,
                  height: lineHeight.h,
                  color: const Color(0xFFD8E2EE),
                ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: _activityTimelineDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 15.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHeading,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      timeLabel,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBody,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13.r,
                      backgroundColor: const Color(0xFF1F2937),
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assigneeName,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueDeep,
                          ),
                        ),
                        Text(
                          assigneeRole,
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineDateChip extends StatelessWidget {
  const _TimelineDateChip({this.label = 'May 20, 2025 (Today)'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: const Color(0xFFD8E2F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F172A),
              offset: Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textBody,
          ),
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.lineHeight,
    this.subtitle = 'Vikram Singh',
    this.duration,
    this.durationColor,
    this.statusLabel,
    this.statusColor,
  });

  final String time;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final double lineHeight;
  final String subtitle;
  final String? duration;
  final Color? durationColor;
  final String? statusLabel;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 62.w,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: 16.w,
            child: Column(
              children: [
                Container(
                  height: 18.h,
                  width: 1.4.w,
                  color: const Color(0xFFD6E0EC),
                ),
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 12.sp, color: iconColor),
                ),
                if (lineHeight > 0)
                  Container(
                    height: lineHeight.h,
                    width: 1.4.w,
                    color: const Color(0xFFD6E0EC),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (duration != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EC),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            duration!,
                            style: GoogleFonts.inter(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                              color: durationColor ?? AppColors.green,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.more_vert,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBody,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      if (statusLabel != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: (statusColor ?? AppColors.green).withOpacity(
                              0.12,
                            ),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            statusLabel!,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor ?? AppColors.green,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      CircleAvatar(
                        radius: 8.r,
                        backgroundColor: const Color(0xFF123B56),
                        child: Text(
                          'V',
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Vikram Singh',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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

class _SummaryItem {
  const _SummaryItem(
    this.label,
    this.value,
    this.icon,
    this.color, {
    this.highlighted = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlighted;
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20.sp, color: AppColors.blueBright),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
              height: 1.5,
              letterSpacing: 0,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86.w,
      height: 86.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE8D8), Color(0xFFB7D3E6)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: 28.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textHeading,
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EB),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.orangeDeep,
        ),
      ),
    );
  }
}

Color _journeyConnectorColor({
  required _JourneyStageItem current,
  required _JourneyStageItem next,
}) {
  final currentActive = current.completed || current.accent == AppColors.orangeDeep;
  final nextActive = next.completed || next.accent == AppColors.orangeDeep;
  return currentActive && nextActive
      ? AppColors.green
      : const Color(0xFFD7DEE8);
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ],
  );
}

BoxDecoration _activityTimelineDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.05),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );
}

class _LeadProfileData {
  const _LeadProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.source,
    required this.leadId,
    required this.status,
    required this.stage,
    required this.assignedTo,
    required this.manager,
    required this.createdOn,
    required this.updatedOn,
    required this.score,
    required this.scoreLabel,
    required this.badge,
    required this.estimatedConversion,
    required this.estimatedConversionLabel,
    required this.estimatedRevenue,
    required this.temperature,
    required this.engagementScore,
    required this.alternatePhone,
    required this.dateOfBirth,
    required this.occupation,
    required this.companyName,
    required this.annualIncome,
    required this.maritalStatus,
    required this.fullAddress,
    required this.preferredLocation,
    required this.propertyType,
    required this.budgetRange,
    required this.bedrooms,
    required this.possession,
    required this.interactions,
    required this.totalCalls,
    required this.totalWhatsApp,
    required this.totalEmails,
    required this.totalSiteVisits,
    required this.totalTasks,
    required this.overviewBudgetRange,
    required this.overviewPreferredLocation,
    required this.preferredProject,
    required this.configuration,
    required this.carpetArea,
    required this.amenities,
    required this.latestBookingProject,
    required this.latestBookingType,
    required this.latestBookingPrice,
    required this.latestBookingDate,
    required this.latestBookingId,
    required this.followUpDate,
    required this.followUpTime,
    required this.followUpType,
    required this.followUpAssignedTo,
    required this.followUpNotes,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String source;
  final String leadId;
  final String status;
  final String stage;
  final String assignedTo;
  final String manager;
  final String createdOn;
  final String updatedOn;
  final int score;
  final String scoreLabel;
  final String badge;
  final int estimatedConversion;
  final String estimatedConversionLabel;
  final String estimatedRevenue;
  final String temperature;
  final int engagementScore;
  final String alternatePhone;
  final String dateOfBirth;
  final String occupation;
  final String companyName;
  final String annualIncome;
  final String maritalStatus;
  final String fullAddress;
  final String preferredLocation;
  final String propertyType;
  final String budgetRange;
  final String bedrooms;
  final String possession;
  final int interactions;
  final int totalCalls;
  final int totalWhatsApp;
  final int totalEmails;
  final int totalSiteVisits;
  final int totalTasks;
  final String overviewBudgetRange;
  final String overviewPreferredLocation;
  final String preferredProject;
  final String configuration;
  final String carpetArea;
  final List<String> amenities;
  final String latestBookingProject;
  final String latestBookingType;
  final String latestBookingPrice;
  final String latestBookingDate;
  final String latestBookingId;
  final String followUpDate;
  final String followUpTime;
  final String followUpType;
  final String followUpAssignedTo;
  final String followUpNotes;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory _LeadProfileData.fromLead(LeadModel? lead) {
    final rawStatus = lead?.status ?? 'Hot';

    return _LeadProfileData(
      name: lead?.name ?? 'Rahul Sharma',
      email: lead?.email == 'rahul.sharma@gmail.co'
          ? 'rahul.sharma@gmail.co'
          : (lead?.email ?? 'rahul.sharma@gmail.co'),
      phone: lead?.phone ?? '+919876543210',
      location: 'Andheri East, Mumbai, Maharashtra',
      source: 'MagicBricks',
      leadId: 'TR001245',
      status: rawStatus == 'Hot' ? 'Active' : rawStatus,
      stage: 'Interested',
      assignedTo: 'Sneha Iyer (Telecaller)',
      manager: 'Rahul Mehta',
      createdOn: '20 May 2025, 10:25 AM',
      updatedOn: '20 May 2025, 10:45 AM',
      score: 92,
      scoreLabel: 'Excellent',
      badge: rawStatus.toUpperCase() == 'HOT'
          ? 'HOT LEAD'
          : '${rawStatus.toUpperCase()} LEAD',
      estimatedConversion: 78,
      estimatedConversionLabel: 'Very High',
      estimatedRevenue: 'INR 1.25 Cr',
      temperature: 'Hot',
      engagementScore: 85,
      alternatePhone: '+91 91234 56789',
      dateOfBirth: '15 Aug 1990',
      occupation: 'Business Owner',
      companyName: 'Sharma Enterprise',
      annualIncome: 'INR 25 - INR 30 Lakh',
      maritalStatus: 'Married',
      fullAddress: 'Andheri East, Mumbai, Maharashtra',
      preferredLocation: 'Andheri East, Powai, Thane',
      propertyType: '2 BHK Apartment',
      budgetRange: 'INR 90 Lakh - INR 1.30 Cr',
      bedrooms: '2 BHK',
      possession: 'Ready to Move',
      interactions: 18,
      totalCalls: 7,
      totalWhatsApp: 6,
      totalEmails: 2,
      totalSiteVisits: 2,
      totalTasks: 3,
      overviewBudgetRange: 'INR 1 Cr - INR 1.5 Cr',
      overviewPreferredLocation: 'Andheri, Goregaon,\nMalad',
      preferredProject: 'Ocean Heights',
      configuration: '2 BHK',
      carpetArea: '800 - 1000 sq.ft.',
      amenities: const [
        'PARKING',
        'GYM',
        'SWIMMING POOL',
        'KIDS PLAY AREA',
        'CLUB HOUSE',
      ],
      latestBookingProject: 'Ocean Heights',
      latestBookingType: '2 BHK Apartment',
      latestBookingPrice: 'INR 1.18 Cr',
      latestBookingDate: '19 May 2025',
      latestBookingId: 'BK001125',
      followUpDate: '21 May 2025',
      followUpTime: '11:00 AM',
      followUpType: 'Site Visit',
      followUpAssignedTo: 'Sneha Iyer',
      followUpNotes: 'Confirm site visit and share\nlocation details.',
    );
  }
}
