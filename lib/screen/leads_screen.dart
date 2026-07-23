import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';
import '../provider/leads_provider.dart';

class LeadListWidget extends StatefulWidget {
  const LeadListWidget({super.key, this.isInsideScrollView = false});
  final bool isInsideScrollView;

  @override
  State<LeadListWidget> createState() => _LeadListWidgetState();
}

class _LeadListWidgetState extends State<LeadListWidget> {
  final TextEditingController _searchController = TextEditingController();
  int _page = 1;
  String _selectedTab = 'All';

  static const double _sectionGap = 18;
  static const double _cardGap = 14;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchLeads();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeads({int page = 1}) async {
    _page = page;
    await context.read<LeadProvider>().fetchLeads(
      search: _searchController.text.trim(),
      page: page,
      limit: 10,
      status: _statusFilterForTab(_selectedTab),
    );
  }

  Future<void> _selectTab(String tab) async {
    if (_selectedTab == tab && _page == 1) {
      return;
    }
    setState(() {
      _selectedTab = tab;
    });
    await _fetchLeads(page: 1);
  }

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
        _buildStatsRow(leadProvider),
        SizedBox(height: _sectionGap.h),
        _buildSearchAndActions(context, leadProvider),
        SizedBox(height: 14.h),
        _buildTabs(leadProvider),
        SizedBox(height: _sectionGap.h),
        if (leadProvider.isLoading && leadProvider.leads.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (leadProvider.error != null && leadProvider.leads.isEmpty)
          _buildErrorState(leadProvider.error!)
        else if (leadProvider.leads.isEmpty)
          _buildEmptyState()
        else
          RefreshIndicator(
            onRefresh: () => _fetchLeads(page: _page),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadProvider.leads.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: _cardGap.h),
              itemBuilder: (context, index) =>
                  _buildLeadCard(context, leadProvider.leads[index], index),
            ),
          ),
        SizedBox(height: 20.h),
        _buildBottomSection(context, leadProvider),
      ],
    );

    if (widget.isInsideScrollView) {
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
      children: [
        Icon(
          Icons.arrow_back_ios_new,
          size: 20.sp,
          color: AppColors.textIconDark,
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            'Lead List',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: const Color(0xFF0F172A),
            ),

            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

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
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.leadProfileManagement),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/add.png',
                  height: 15.h,
                  width: 15.w,
                  fit: BoxFit.contain,
                ),
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
          Text(
            'Dashboard',
            style: GoogleFonts.inter(
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
          Text(
            'Lead List',
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

  Widget _buildStatsRow(LeadProvider leadProvider) {
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
                  _formatCount(leadProvider.totalLeads),
                  'Live',
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _statCard(
                  Icons.local_fire_department_outlined,
                  AppColors.orangeStrong,
                  'Hot\nLeads',
                  _formatCount(leadProvider.hotLeads),
                  'Live',
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
                  _formatCount(leadProvider.qualifiedLeads),
                  'Live',
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _statCard(
                  Icons.task_alt_outlined,
                  AppColors.greenStrong,
                  'Converted\nLeads',
                  _formatCount(leadProvider.convertedLeads),
                  'Live',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions(
    BuildContext context,
    LeadProvider leadProvider,
  ) {
    final searchField = Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _fetchLeads(page: 1),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(36, 10, 12, 10),
          filled: true,
          hintText: 'Search by name, phone, email...',
          hintStyle: TextStyle(fontSize: 16.sp, color: AppColors.inputHint),
          fillColor: Colors.white,
          prefixIcon: Icon(
            Icons.search,
            size: 22.sp,
            color: AppColors.iconMuted,
          ),
          suffixIcon: leadProvider.isLoading
              ? Padding(
                  padding: EdgeInsets.all(12.r),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: () => _fetchLeads(page: 1),
                  icon: Icon(Icons.arrow_forward, size: 18.sp),
                ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconActionButton(
          Icons.filter_alt_rounded,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.myLeadsFilter),
        ),
        SizedBox(width: 6.w),
        _iconActionButton(Icons.swap_vert_rounded, onTap: () => _fetchLeads()),
        SizedBox(width: 6.w),
        _iconActionButton(Icons.view_list_rounded, onTap: () => _fetchLeads()),
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

  Widget _buildTabs(LeadProvider leadProvider) {
    final statusNames = leadProvider.statusNames;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabChip(
            'All (${_formatCount(leadProvider.totalLeads)})',
            isSelected: _selectedTab == 'All',
            onTap: () => _selectTab('All'),
          ),
          for (final status in statusNames) ...[
            SizedBox(width: 8.w),
            _tabChip(
              '$status (${_formatCount(leadProvider.countForStatus(status))})',
              isSelected: _selectedTab == status,
              textColor: _tabTextColor(status),
              backgroundColor: _tabBackgroundColor(status),
              onTap: () => _selectTab(status),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, LeadModel lead, int index) {
    final statusThemes = <String, Map<String, dynamic>>{
      'Hot': {
        'bg': AppColors.orangeSoft,
        'fg': AppColors.orangeDeep,
        'icon': Icons.local_fire_department_outlined,
      },
      'Warm': {
        'bg': AppColors.leadWarmBg,
        'fg': AppColors.orangeStrong,
        'icon': Icons.wb_sunny_outlined,
      },
      'New': {
        'bg': AppColors.windowBlue,
        'fg': AppColors.blueBright,
        'icon': Icons.brightness_1,
      },
      'Pending': {
        'bg': AppColors.windowBlue,
        'fg': AppColors.blueBright,
        'icon': Icons.pending_actions_outlined,
      },
      'Contacted': {
        'bg': AppColors.purpleSoft,
        'fg': AppColors.purpleDeep,
        'icon': Icons.chat_bubble_outline,
      },
      'Booked': {
        'bg': AppColors.greenBg,
        'fg': AppColors.greenDeep,
        'icon': Icons.task_alt_outlined,
      },
      'Interested': {
        'bg': AppColors.purpleSoft,
        'fg': AppColors.purpleDeep,
        'icon': Icons.thumb_up_alt_outlined,
      },
    };

    final status = _normalizeStatus(lead.status);
    final theme =
        statusThemes[status] ??
        {
          'bg': AppColors.windowBlue,
          'fg': AppColors.blueBright,
          'icon': Icons.info_outline,
        };
    final timelineText = lead.dueLabel ?? lead.createdLabel ?? 'No follow-up';
    final timelineColor = lead.dueLabel == null
        ? AppColors.iconMuted
        : AppColors.greenDeep;

    final isNarrow = MediaQuery.sizeOf(context).width < 430;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRouter.leadDetail, arguments: lead),
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
                          lead.titleWithId,
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
                    child: Icon(
                      Icons.more_vert,
                      size: 16.sp,
                      color: AppColors.textMuted,
                    ),
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
                  lead.location ?? lead.project ?? 'Project not assigned',
                ),
                _buildMetaItem(
                  Icons.currency_rupee,
                  'Source: ${lead.source ?? '-'}',
                ),
                _buildMetaItem(
                  Icons.person_outline,
                  lead.assignedTo ?? 'Unassigned',
                  isCompact: isNarrow,
                ),
                _buildMetaItem(
                  Icons.access_time,
                  lead.stage ?? lead.status,
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
              child: Icon(icon, size: 14.sp, color: iconColor),
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
          Icon(
            theme['icon'] as IconData,
            size: 8.sp,
            color: theme['fg'] as Color,
          ),
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
        Icon(icon, size: 11.sp, color: iconColor ?? AppColors.iconMuted),
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

  Widget _buildBottomSection(BuildContext context, LeadProvider leadProvider) {
    final isNarrow = MediaQuery.sizeOf(context).width < 430;
    final total = leadProvider.totalLeads;
    final shownFrom = total == 0 ? 0 : ((_page - 1) * 10) + 1;
    final shownTo = total == 0
        ? 0
        : (((_page - 1) * 10) + leadProvider.leads.length).clamp(0, total);
    final pagination = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pageArrow(
          Icons.chevron_left,
          onTap: _page <= 1 ? null : () => _fetchLeads(page: _page - 1),
        ),
        SizedBox(width: 8.w),
        _pageChip(_page.toString(), isSelected: true),
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
        _pageChip(_totalPages(total).toString()),
        SizedBox(width: 8.w),
        _pageArrow(
          Icons.chevron_right,
          onTap: _page >= _totalPages(total)
              ? null
              : () => _fetchLeads(page: _page + 1),
        ),
      ],
    );

    return Column(
      children: [
        if (isNarrow) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing $shownFrom to $shownTo of ${_formatCount(total)} leads',
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
                  'Showing $shownFrom to $shownTo of ${_formatCount(total)} leads',
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
          child: InkWell(
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.leadProfileManagement),
            borderRadius: BorderRadius.circular(24.r),
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
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    Color color,
    String title,
    String value,
    String growth,
  ) {
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
              color: color.withValues(alpha: 0.10),
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
                  text: growth == 'Live' ? '  from API' : '  vs month',
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

  Widget _iconActionButton(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 18.sp, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _tabChip(
    String label, {
    bool isSelected = false,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    final bg = isSelected
        ? AppColors.darkButton
        : (backgroundColor ?? AppColors.white);
    final fg = isSelected
        ? AppColors.white
        : (textColor ?? AppColors.textSecondary);

    return Material(
      color: AppColors.transparentWhite,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 32.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? AppColors.darkButton : AppColors.borderSoft,
              width: 1.w,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.1,
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageArrow(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: onTap == null ? AppColors.borderMuted : AppColors.iconMuted,
        ),
      ),
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

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB91C1C),
            ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton(
            onPressed: () => _fetchLeads(page: _page),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Text(
        'No leads found.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 100000) {
      return '${(count / 100000).toStringAsFixed(1)}L';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  int _totalPages(int total) {
    if (total <= 0) {
      return 1;
    }
    return ((total + 9) / 10).floor();
  }

  String _normalizeStatus(String status) {
    final normalized = status.trim();
    if (normalized.isEmpty) return 'New';
    final lower = normalized.toLowerCase();
    if (lower.contains('hot')) return 'Hot';
    if (lower.contains('warm')) return 'Warm';
    if (lower.contains('book')) return 'Booked';
    if (lower.contains('interested')) return 'Interested';
    if (lower.contains('contacted')) return 'Contacted';
    if (lower.contains('pending')) return 'Pending';
    if (lower.contains('new')) return 'New';
    return normalized;
  }

  String? _statusFilterForTab(String tab) {
    return tab == 'All' ? null : tab;
  }

  Color? _tabTextColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('contact')) return AppColors.orangeDeep;
    if (lower.contains('visit')) return AppColors.blueBright;
    if (lower.contains('book')) return AppColors.greenDeep;
    if (lower.contains('interest') || lower.contains('qualif')) {
      return AppColors.purpleDeep;
    }
    if (lower.contains('pending')) return AppColors.blueBright;
    return AppColors.textSecondary;
  }

  Color? _tabBackgroundColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('contact')) return AppColors.orangeSoft;
    if (lower.contains('visit')) return AppColors.windowBlue;
    if (lower.contains('book')) return AppColors.greenBg;
    if (lower.contains('interest') || lower.contains('qualif')) {
      return AppColors.purpleSoft;
    }
    if (lower.contains('pending')) return AppColors.windowBlue;
    return AppColors.white;
  }
}
