import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';
import '../provider/leads_provider.dart';

class LeadListWidget extends StatelessWidget {
  const LeadListWidget({super.key, this.isInsideScrollView = false});
  final bool isInsideScrollView;
  static const double _sectionGap = 18;
  static const double _cardGap = 14;

  @override
  Widget build(BuildContext context) {
    final leadProvider = context.watch<LeadProvider>();

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        SizedBox(height: 12.h),
        _buildBreadcrumbs(),
        SizedBox(height: _sectionGap.h),
        _buildStatsRow(),
        SizedBox(height: _sectionGap.h),
        _buildSearchAndActions(context),
        SizedBox(height: 14.h),
        _buildTabs(),
        SizedBox(height: _sectionGap.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadProvider.leads.length,
          separatorBuilder: (_, __) => SizedBox(height: _cardGap.h),
          itemBuilder: (context, index) => _buildLeadCard(context, leadProvider.leads[index], index),
        ),
        SizedBox(height: 20.h),
        _buildBottomSection(context),
      ],
    );

    if (isInsideScrollView) {
      return Container(
        color: AppColors.leadListBg,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: bodyContent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.leadListBg,
      body: SafeArea(
        child: Container(
          color: AppColors.leadListBg,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 380;
    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.arrow_back_ios_new, size: 20.sp, color: AppColors.textIconDark),
        SizedBox(width: 8.w),
        Text(
          'Lead List',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: const Color(0xFF0F172A),
          ),

            overflow: TextOverflow.ellipsis,
    ) ]);

    final addButton = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparentWhite,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/add.png', height: 15.h, width: 15.w, fit: BoxFit.contain),
                SizedBox(width: 6.w),
                Text(
                  'Add Lead',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          SizedBox(height: 12.h),
          addButton,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleRow),
        SizedBox(width: 12.w),
        addButton,
      ],
    );
  }

  Widget _buildBreadcrumbs() {
    final muted = AppColors.textTertiary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('Dashboard',  style: GoogleFonts.inter(
            fontSize: 16.5.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: const Color(0xFF64748B),
          ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Icon(Icons.chevron_right, size: 16.sp, color: muted),
          ),
          Text(
            'Leads',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: const Color(0xFFF97316),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Icon(Icons.chevron_right, size: 12.sp, color: muted),
          ),
          Text('Lead List',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCard(
                  Icons.groups_2_outlined,
                  AppColors.blueStrong,
                  'Total\nLeads',
                  '1,248',
                  '+12.5%',
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _statCard(
                  Icons.local_fire_department_outlined,
                  AppColors.orangeStrong,
                  'Hot\nLeads',
                  '328',
                  '+8.3%',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCard(
                  Icons.filter_alt_rounded,
                  AppColors.purpleStrong,
                  'Qualified\nLeads',
                  '512',
                  '+15.2%',
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _statCard(
                  Icons.task_alt_outlined,
                  AppColors.greenStrong,
                  'Converted\nLeads',
                  '96',
                  '+10.5%',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions(BuildContext context) {
    final searchField = Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(36, 10, 12, 10),
          filled: true,
          hintText: 'Search by name, phone, email...',
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: AppColors.inputHint,
          ),
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search, size: 22.sp, color: AppColors.iconMuted),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconActionButton(Icons.filter_alt_rounded),
        SizedBox(width: 6.w),
        _iconActionButton(Icons.swap_vert_rounded),
        SizedBox(width: 6.w),
        _iconActionButton(Icons.view_list_rounded),
      ],
    );

    return Row(
      children: [
        Expanded(child: searchField),
        SizedBox(width: 6.w),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: actionButtons,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabChip('All (1,248)', isSelected: true),
          SizedBox(width: 10.w),
          _tabChip('New (256)'),
          SizedBox(width: 10.w),
          _tabChip(
            'Pending (184)',
            textColor: AppColors.blueBright,
            backgroundColor: AppColors.windowBlue,
          ),
          SizedBox(width: 10.w),
          _tabChip(
            'Contacted (856)',
            textColor: AppColors.orangeDeep,
            backgroundColor: AppColors.orangeSoft,
          ),
          SizedBox(width: 10.w),
          _tabChip(
            'Qualified (136)',
            textColor: AppColors.purpleDeep,
            backgroundColor: AppColors.purpleSoft,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead, int index) {
    final statusThemes = <String, Map<String, dynamic>>{
      'Hot': {'bg': AppColors.orangeSoft, 'fg': AppColors.orangeDeep, 'icon': Icons.local_fire_department_outlined},
      'Warm': {'bg': AppColors.leadWarmBg, 'fg': AppColors.orangeStrong, 'icon': Icons.wb_sunny_outlined},
      'New': {'bg': AppColors.windowBlue, 'fg': AppColors.blueBright, 'icon': Icons.brightness_1},
      'Pending': {'bg': AppColors.windowBlue, 'fg': AppColors.blueBright, 'icon': Icons.pending_actions_outlined},
      'Contacted': {'bg': AppColors.purpleSoft, 'fg': AppColors.purpleDeep, 'icon': Icons.chat_bubble_outline},
    };

    final timelineLabels = ['Today', 'Tomorrow', 'Pending', 'Today', 'Tomorrow'];
    final timelineColors = [
      AppColors.greenDeep,
      AppColors.leadTimelineAlert,
      AppColors.blueBright,
      AppColors.greenDeep,
      AppColors.leadTimelineAlert,
    ];
    final ownerNames = ['Amit Singh', 'Neha Verma', 'Amit Singh', 'Amit Singh', 'Priya Mehta'];
    final statusOrder = ['Hot', 'Warm', 'New', 'Pending', 'Contacted'];
    final areaLabels = ['Andheri East, Mumbai, Maharashtra', 'Gurgaon', 'Noida Sector 150', 'Noida Extension', 'Greater Noida'];
    final sourceLabels = ['Source: 99acres', 'Source: 99acres', 'Source: Justdial', 'Source: Housing', 'Source: 99acres'];
    final timeLabels = ['10:30 AM', 'Yesterday', '11:15 AM', '10:30 AM', 'Today'];

    final status = statusOrder[index % statusOrder.length];
    final theme = statusThemes[status]!;
    final timelineText = timelineLabels[index % timelineLabels.length];
    final timelineColor = timelineColors[index % timelineColors.length];

    final isNarrow = MediaQuery.sizeOf(context).width < 430;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.leadDetail, arguments: lead),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.leadCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.windowBlue,
                  child: Text(
                    lead.name.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      color: AppColors.blueDeep,
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isNarrow) ...[
                        Text(
                          lead.name,
                          style: GoogleFonts.inter(
                            fontSize: 17.5.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        _buildStatusChip(status, theme),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                lead.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            _buildStatusChip(status, theme),
                          ],
                        ),
                      SizedBox(height: 4.h),
                      Text(
                        lead.email,
                        style: GoogleFonts.inter(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: const Color(0xFF4F5153),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        lead.phone,
                        style: GoogleFonts.inter(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: const Color(0xFF4F5153),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _showLeadActionsSheet(context, lead),
                  child: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(Icons.more_vert, size: 16.sp, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Wrap(
              runSpacing: 8.h,
              spacing: 12.w,
              children: [
                _buildMetaItem(
                  Icons.location_on_outlined,
                  areaLabels[index % areaLabels.length],
                ),
                _buildMetaItem(
                  Icons.currency_rupee,
                  sourceLabels[index % sourceLabels.length],
                ),
                _buildMetaItem(
                  Icons.person_outline,
                  ownerNames[index % ownerNames.length],
                  isCompact: isNarrow,
                ),
                _buildMetaItem(
                  Icons.access_time,
                  timeLabels[index % timeLabels.length],
                  isCompact: isNarrow,
                ),
                _buildMetaItem(
                  Icons.calendar_today_outlined,
                  timelineText,
                  iconColor: timelineColor,
                  textColor: timelineColor,
                  fontWeight: FontWeight.w700,
                  isCompact: isNarrow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLeadActionsSheet(BuildContext context, LeadModel lead) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 8.h, 0, 14.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DDE6),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: const Color(0xFFE8EFFD),
                          child: Text(
                            _leadInitials(lead.name),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF415A93),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              lead.phone,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Divider(color: const Color(0xFFE9EDF4), height: 1.h),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.remove_red_eye_outlined,
                          iconColor: const Color(0xFF4D7CFE),
                          iconBackground: const Color(0xFFF1F5FF),
                          title: 'View',
                          subtitle: 'Open lead details',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.pushNamed(
                              context,
                              AppRouter.leadProfileManagement,
                              arguments: lead,
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        _buildSheetAction(
                          context: sheetContext,
                          icon: Icons.event_note_outlined,
                          iconColor: const Color(0xFF7C3AED),
                          iconBackground: const Color(0xFFF5F0FF),
                          title: 'Create Follow-Up',
                          subtitle: 'Schedule next follow-up',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showCreateFollowUpSheet(context, lead);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(36.h),
                          side: const BorderSide(color: Color(0xFFE1E6EF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF344054),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCreateFollowUpSheet(BuildContext context, LeadModel lead) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC7D2FE),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.event_note_outlined,
                              size: 18.sp,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create Follow-Up',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Schedule the next follow-up for this CRM lead and keep the team updated.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: const Color(0xFF52525B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(sheetContext),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.close,
                                size: 20.sp,
                                color: const Color(0xFF3F3F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(height: 1.h, color: const Color(0xFFE4E7EC)),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Follow-Up',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Choose the lead, follow-up type, schedule, and handoff details.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: const Color(0xFF52525B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1.h, color: const Color(0xFFE4E7EC)),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFD9DFEA)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D101828),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SELECTED DETAILS',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFF374151),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Selected Lead',
                                    value: lead.name,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Phone',
                                    value: lead.phone,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Status',
                                    value: lead.status,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _buildFollowUpDetailBlock(
                                    label: 'Email',
                                    value: lead.email,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF97316),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.priority_high,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scheduling Tip',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9A3412),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Use the searchable lead field instead of typing IDs. Details are still sent internally to the CRM.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                      color: const Color(0xFF57534E),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetAction({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEEF1F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16.sp,
              color: const Color(0xFFB09AFD),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpDetailBlock({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF52525B),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  String _leadInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Widget _buildStatusChip(String status, Map<String, dynamic> theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme['bg'] as Color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(theme['icon'] as IconData, size: 8.sp, color: theme['fg'] as Color),
          SizedBox(width: 3.w),
          Text(
            status,
            style: TextStyle(
              fontSize: 15.5.sp,
              color: theme['fg'] as Color,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
      IconData icon,
      String text, {
        Color? iconColor,
        Color? textColor,
        FontWeight fontWeight = FontWeight.w500,
        bool isCompact = false,
      }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11.sp,
          color: iconColor ?? AppColors.iconMuted,
        ),
        SizedBox(width: 5.w),
        SizedBox(
          width: isCompact ? 74.w : null,
          child: Text(
            text,
            maxLines: isCompact ? 1 : null,
            overflow: isCompact ? TextOverflow.ellipsis : null,
            textAlign: isCompact ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: 16.5.sp,
              color: textColor ?? AppColors.textBody,
              fontWeight: fontWeight,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 430;
    final pagination = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageArrow(Icons.chevron_left),
        SizedBox(width: 8.w),
        _pageChip('1', isSelected: true),
        SizedBox(width: 8.w),
        _pageChip('2'),
        SizedBox(width: 8.w),
        _pageChip('3'),
        SizedBox(width: 8.w),
        Text(
          '...',
          style: TextStyle(
            fontSize: 21.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        _pageChip('125'),
        SizedBox(width: 8.w),
        _pageArrow(Icons.chevron_right),
      ],
    );

    return Column(
      children: [
        if (isNarrow) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing 1 to 10 of 1,248 leads',
              style: TextStyle(
                fontSize: 21.5.sp,
                color: AppColors.textTertiary,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: pagination,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: Text(
                  'Showing 1 to 10 of 1,248 leads',
                  style: TextStyle(
                    fontSize: 19.5.sp,
                    color: AppColors.textTertiary,
                    height: 1.2,
                  ),
                ),
              ),
              pagination,
            ],
          ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppColors.orangeAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColors.white, size: 28.sp),
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, Color color, String title, String value, String growth) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.3),
        border: Border.all(
          color: const Color.fromRGBO(195, 198, 209, 0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 1.3,
            offset: const Offset(0, 0.7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.sp, color: color),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: const Color(0xFF43474F),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700, // bold
              height: 1.33,
              color: const Color(0xFF002149),
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: growth,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: const Color(0xFF16A34A),
                  ),
                ),
                TextSpan(
                  text: '  vs month',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: const Color(0xFF747781),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconActionButton(IconData icon) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all( color: Color(0xFFE2E8F0),),
      ),
      child: Icon(icon, size: 18.sp, color: AppColors.textSecondary),
    );
  }

  Widget _tabChip(
      String label, {
        bool isSelected = false,
        Color? backgroundColor,
        Color? textColor,
      }) {
    final bg = isSelected ? AppColors.darkButton : (backgroundColor ?? AppColors.white);
    final fg = isSelected ? AppColors.white : (textColor ?? AppColors.textSecondary);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isSelected ? AppColors.darkButton : AppColors.borderSoft,
          width: 1.w,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 21.5.sp,
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pageArrow(IconData icon) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Icon(icon, size: 16.sp, color: AppColors.iconMuted),
    );
  }

  Widget _pageChip(String label, {bool isSelected = false}) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.darkButton : AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isSelected ? AppColors.darkButton : AppColors.borderSoft,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 21.5.sp,
          color: isSelected ? AppColors.white : AppColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
