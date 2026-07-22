import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'documents_screen.dart';

class LeadDetailScreenArgs {
  const LeadDetailScreenArgs({this.initialTabIndex = 0});

  final int initialTabIndex;
}

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            const _LeadDetailHeader(),
            _DetailTabs(
              selectedIndex: _selectedTabIndex,
              onTabSelected: _handleTabSelection,
            ),
// ...
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _selectedTabIndex == 4
                    ? DocumentsTabContent(key: ValueKey('documents'))
                    : _selectedTabIndex == 5
                        ? const SingleChildScrollView(
                            child: _NotesFeedTabContent(key: ValueKey('notes')),
                          )
                        : _selectedTabIndex == 1
                        ? const SingleChildScrollView(child: _TimelineTabContent(key: ValueKey('timeline')))
                        : const SingleChildScrollView(child: _OverviewTabContent(key: ValueKey('overview'))),
              ),
            ),
// ...
          ],
        ),
      ),
    );
  }

  void _handleTabSelection(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, AppRouter.addActivity);
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(context, AppRouter.siteVisits);
      return;
    }
    setState(() {
      _selectedTabIndex = index;
    });
  }
}

class _LeadDetailHeader extends StatelessWidget {
  const _LeadDetailHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldLight,
      padding: EdgeInsets.fromLTRB(12.w, 18.h, 12.w, 10.h),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: 19.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 10.w),
              Text(
                'Lead Detail',
                style: TextStyle(
                  color: AppColors.textHeading,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
            decoration: BoxDecoration(
              color: AppColors.leadDetailHeaderBg,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack05,
                  offset: Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: AppColors.shadowBlack05,
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.leadDetailAvatarBg,
                      child: Text(
                        'RS',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  'Rahul Sharma',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 21.5.sp,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    letterSpacing: 0,
                                    color: AppColors.white,
                                  ),

                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.leadChipBg,
                                  border: Border.all(
                                    color: AppColors.leadChipBorder,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                // decoration: BoxDecoration(
                                //   color: const Color(0xFF4F2A0A),
                                //   borderRadius: BorderRadius.circular(16.r),
                                // ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_outlined,
                                      size: 10.sp,
                                      color: AppColors.orangeStrong,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Hot Lead',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.orangeDeep,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _miniInfo(
                            Image.asset(
                              'assets/email.png',
                              width: 18.w,
                              height: 18.h,
                              color: AppColors.leadDetailIconTint,
                            ),
                            'rahul.sharma@gmail.co',
                          ),
                          SizedBox(height: 10.h),
                          _miniInfo(
                            Image.asset(
                              'assets/calling.png',
                              width: 18.w,
                              height: 18.h,
                              color: AppColors.leadDetailIconTint,
                            ),
                            '+919876543210',
                          ),
                          SizedBox(height: 10.h),
                          _miniInfo(
                            Image.asset(
                              'assets/locations.png',
                              width: 18.w,
                              height: 18.h,
                              color: AppColors.leadDetailIconTint,
                            ),
                            'Andheri East, Mumbai, Maharashtra',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Lead ID',
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: AppColors.mailBorder,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'LD-2025-\n001248',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Source',
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: AppColors.mailBorder,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '99acres',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _HeaderStat(
                          title: 'Lead Stage',
                          value: 'Contacted',
                          accent: AppColors.windowBlue,
                          valueColor: AppColors.blueBright,
                          isPill: true,
                        ),
                      ),
                      Expanded(
                        child: _HeaderStat(
                          title: 'Lead Score',
                          value: '85',
                          valueColor: AppColors.greenStrong,
                        ),
                      ),
                      Expanded(child: _AssignedStat()),
                      Expanded(
                        child: _HeaderStat(
                          title: 'Created On',
                          value: '20 May\n2025',
                          valueColor: AppColors.textBody,
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

  Widget _miniInfo(Widget icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.leadDetailTextTint,
              fontSize: 17.5.sp,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.title,
    required this.value,
    required this.valueColor,
    this.accent,
    this.isPill = false,
  });

  final String title;
  final String value;
  final Color valueColor;
  final Color? accent;
  final bool isPill;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: 7.h),
        if (isPill)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5.sp,
              height: 1.35,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _AssignedStat extends StatelessWidget {
  const _AssignedStat();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Assigned To',
          style: TextStyle(
            fontSize: 14.5.sp,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 12.r,
              backgroundColor: AppColors.leadDetailMetaBg,
              child: Icon(
                Icons.person,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amit\nSingh',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.25,
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Telecaller',
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    height: 1.25,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.selectedIndex, required this.onTabSelected});

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.apps_rounded, 'Overview'),
      (Icons.timeline, 'Timeline'),
      (Icons.assignment_outlined, 'Activities'),
      (Icons.apartment_outlined, 'Site Visits'),
      (Icons.description_outlined, 'Documents'),
      (Icons.edit_note_outlined, 'Notes'),
    ];

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(4.w, 12.h, 4.w, 8.h),
      child: Row(
        children: List.generate(
          items.length,
              (index) => Expanded(
            child: _tabItem(
              items[index].$1,
              items[index].$2,
              selectedIndex == index,
              onTap: () => onTabSelected(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabItem(
      IconData icon,
      String label,
      bool active, {
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: active ? AppColors.orangeStrong : AppColors.textSecondary,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: active ? AppColors.orangeStrong : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.orangeStrong
                  : AppColors.transparentOrange,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTabContent extends StatelessWidget {
  const _OverviewTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: const [
        _LeadInformationCard(),
        SizedBox(height: 10),
        _LeadStatusCard(),
        SizedBox(height: 10),
        _LeadSummaryCard(),
      ],
    );
  }
}

class _TimelineTabContent extends StatelessWidget {
  const _TimelineTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 8.h, 4.w, 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Lead Timeline',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    height: 1.35,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(Icons.filter_alt_outlined, 'Filters'),
                    SizedBox(width: 8.w),
                    _filterChip(
                      Icons.keyboard_arrow_down_rounded,
                      'All Time',
                      trailingFirst: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        const _TimelineItem(
          icon: Icons.call_rounded,
          iconBg: AppColors.leadDetailSuccessBg,
          iconColor: AppColors.greenStrong,
          title: 'Follow-up Call',
          badgeText: 'Completed',
          badgeBg: AppColors.leadDetailSuccessBg,
          badgeColor: AppColors.greenStrong,
          trailingTop: 'Today, 10:30 AM',
          description: 'Spoke with Rahul regarding 2 BHK apartments in Noida.',
          owner: 'Amit Singh',
          role: 'Telecaller',
          avatarBg: AppColors.gray900,
        ),
        const _TimelineItem(
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: AppColors.leadDetailPurpleBg,
          iconColor: AppColors.purpleDeep,
          title: 'WhatsApp Message',
          badgeText: 'Completed',
          badgeBg: AppColors.leadDetailSuccessBg,
          badgeColor: AppColors.greenStrong,
          trailingTop: 'Today, 09:15 AM',
          description: 'Sent property details and brochure on WhatsApp.',
          owner: 'Amit Singh',
          role: 'Telecaller',
          avatarBg: AppColors.leadDetailPurpleAvatar,
        ),
        const _TimelineItem(
          icon: Icons.calendar_month_outlined,
          iconBg: AppColors.leadDetailOrangeBg,
          iconColor: AppColors.orangeStrong,
          title: 'Site Visit Scheduled',
          badgeText: 'Upcoming',
          badgeBg: AppColors.windowBlue,
          badgeColor: AppColors.blueBright,
          trailingTop: '21 May 2025\n11:30 AM',
          description: 'Green Valley Residency - 2 BHK Unit',
          owner: 'Amit Singh',
          role: 'Telecaller',
          avatarBg: AppColors.gray900,
        ),
        const _TimelineItem(
          icon: Icons.note_alt_outlined,
          iconBg: AppColors.leadDetailYellowBg,
          iconColor: AppColors.leadDetailYellow,
          title: 'Note Added',
          badgeText: 'Note',
          badgeBg: AppColors.leadDetailPinkBg,
          badgeColor: AppColors.purpleDeep,
          trailingTop: '20 May 2025\n04:45 PM',
          description:
          'Rahul is interested in ready to move properties. Budget: 50-70 Lakhs.',
          owner: 'Neha Verma',
          role: 'Manager',
          avatarBg: AppColors.leadDetailBrownAvatar,
        ),
        const _TimelineItem(
          icon: Icons.call_made_rounded,
          iconBg: AppColors.leadDetailOrangeBg,
          iconColor: AppColors.orangeStrong,
          title: 'Follow-up Call',
          badgeText: 'Completed',
          badgeBg: AppColors.leadDetailSuccessBg,
          badgeColor: AppColors.greenStrong,
          trailingTop: '19 May 2025\n02:30 PM',
          description:
          'Discussed budget and requirement. He is open for site visit.',
          owner: 'Amit Singh',
          role: 'Telecaller',
          avatarBg: AppColors.gray900,
        ),
        const _TimelineItem(
          icon: Icons.person_add_alt_1_outlined,
          iconBg: AppColors.leadDetailPurpleBg,
          iconColor: AppColors.purpleDeep,
          title: 'Lead Created',
          badgeText: 'New',
          badgeBg: AppColors.windowBlue,
          badgeColor: AppColors.blueBright,
          trailingTop: '19 May 2025\n11:20 AM',
          description: 'Lead created via Website Enquiry',
          owner: 'System',
          role: '',
          avatarBg: AppColors.leadDetailPurpleAvatar,
        ),
      ],
    );
  }

  Widget _filterChip(IconData icon, String label, {bool trailingFirst = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: trailingFirst
            ? [
          Icon(icon, size: 14.sp, color: AppColors.iconMuted),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]
            : [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(icon, size: 15.sp, color: AppColors.iconMuted),
        ],
      ),
    );
  }
}

class _NotesTabContent extends StatelessWidget {
  const _NotesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leadSummaryCard(),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.leadDetailCardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18.sp, color: AppColors.textMuted),
                      SizedBox(width: 10.w),
                      Text(
                        'Search notes...',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.leadDetailCardBorder),
                ),
                child: Icon(
                  Icons.filter_alt_outlined,
                  size: 20.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.upload_outlined, size: 18.sp, color: AppColors.white),
                    SizedBox(width: 8.w),
                    Text(
                      'Upload',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _notesChip('All', true),
                SizedBox(width: 10.w),
                _notesChip('General', false),
                SizedBox(width: 10.w),
                _notesChip('Call Notes', false),
                SizedBox(width: 10.w),
                _notesChip('Site Visit', false),
                SizedBox(width: 10.w),
                _notesChip('Follow-up', false),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E7),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 16.sp,
                        color: AppColors.orangeDeep,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E7),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0xFFFFC89B)),
                      ),
                      child: Text(
                        'FOLLOW-UP',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeDeep,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.push_pin_outlined,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.more_vert,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Rahul liked the location but is concerned about the maintenance charges. Need to send a detailed breakdown of the costs by tomorrow.',
                  style: GoogleFonts.inter(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.65,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 18.h),
                Container(height: 1, color: AppColors.leadDetailDivider),
                SizedBox(height: 10.h),
                Text(
                  'Added by Amit Singh • 21 May 2025, 12:30 PM',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesChip(String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE6F0FF) : AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active ? const Color(0xFFBED8FF) : AppColors.leadDetailCardBorder,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: active ? AppColors.blueBright : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _leadSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFFE8F0FF),
                      child: Text(
                        'RS',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rahul\nSharma',
                            style: GoogleFonts.inter(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              'Contacted',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueBright,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  '# LD-2025-001248',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                _miniLeadLine(Icons.phone_outlined, '+91 98765 43210'),
                SizedBox(height: 8.h),
                _miniLeadLine(Icons.location_on_outlined, 'Noida, UP'),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 148.w,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
                    width: double.infinity,
                    height: 86.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Green Valley Residency',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '2 BHK Apartment',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Sector 62',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangeDeep,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLeadLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotesFeedTabContent extends StatelessWidget {
  const _NotesFeedTabContent({super.key});

  static const double _sectionGap = 16;
  static const double _cardGap = 14;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 410;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _leadSummaryCard(),
          SizedBox(height: _sectionGap.h),
          if (isNarrow) ...[
            _notesSearchField(),
            SizedBox(height: 10.h),
            Row(
              children: [
                _notesFilterButton(),
                SizedBox(width: 10.w),
                Expanded(child: _notesUploadButton()),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(child: _notesSearchField()),
                SizedBox(width: 10.w),
                _notesFilterButton(),
                SizedBox(width: 10.w),
                _notesUploadButton(),
              ],
            ),
          SizedBox(height: _sectionGap.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _notesChip('All', true),
                SizedBox(width: 10.w),
                _notesChip('General', false),
                SizedBox(width: 10.w),
                _notesChip('Call Notes', false),
                SizedBox(width: 10.w),
                _notesChip('Site Visit', false),
                SizedBox(width: 10.w),
                _notesChip('Follow-up', false),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          _noteCard(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFEAF1FF),
            iconColor: AppColors.blueBright,
            tag: 'GENERAL',
            tagBg: const Color(0xFFF3F7FF),
            tagBorder: const Color(0xFFCFE0FF),
            tagColor: AppColors.blueBright,
            note:
                'Customer is looking for 2 BHK ready-to-move properties under 80L budget in Noida Extension.',
            footer: 'Added by Amit Singh • 20 May 2025, 10:45 AM',
          ),
          SizedBox(height: _cardGap.h),
          _noteCard(
            icon: Icons.call_outlined,
            iconBg: const Color(0xFFE9FBEE),
            iconColor: AppColors.greenStrong,
            tag: 'CALL NOTES',
            tagBg: const Color(0xFFF1FDF4),
            tagBorder: const Color(0xFFB9EDC7),
            tagColor: AppColors.greenStrong,
            note:
                'Spoke with Rahul regarding pricing flexibility. He is willing to close if we offer a 5% discount on the base price.',
            footer: 'Added by Amit Singh • 19 May 2025, 04:15 PM',
          ),
          SizedBox(height: _cardGap.h),
          _noteCard(
            icon: Icons.lock_outline,
            iconBg: const Color(0xFFF4EAFF),
            iconColor: AppColors.purpleDeep,
            tag: 'INTERNAL',
            tagBg: const Color(0xFFF9F1FF),
            tagBorder: const Color(0xFFE5CCFF),
            tagColor: AppColors.purpleDeep,
            note:
                'Lead appears serious. Has pre-approved loan from HDFC. Prioritize for weekend site visit.',
            footer: 'Added by Neha Verma • 19 May 2025, 01:10 PM',
            italicNote: true,
          ),
          SizedBox(height: _sectionGap.h),
          _notesPrivacyCard(),
          SizedBox(height: 24.h),
          _addNewNoteButton(),
        ],
      ),
    );
  }

  Widget _notesSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.sp, color: AppColors.textMuted),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Search notes...',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesFilterButton() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Icon(
        Icons.filter_alt_outlined,
        size: 20.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _notesUploadButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.upload_outlined, size: 18.sp, color: AppColors.white),
          SizedBox(width: 8.w),
          Text(
            'Upload',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesChip(String label, bool active) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE6F0FF) : AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active ? const Color(0xFFBED8FF) : AppColors.leadDetailCardBorder,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: active ? AppColors.blueBright : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _leadSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: const Color(0xFFE8F0FF),
                      child: Text(
                        'RS',
                        style: GoogleFonts.inter(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rahul\nSharma',
                            style: GoogleFonts.inter(
                              fontSize: 15.5.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              'Contacted',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueBright,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  '# LD-2025-001248',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                _miniLeadLine(Icons.phone_outlined, '+91 98765 43210'),
                SizedBox(height: 8.h),
                _miniLeadLine(Icons.location_on_outlined, 'Noida, UP'),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 148.w,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab',
                    width: double.infinity,
                    height: 86.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Green Valley Residency',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '2 BHK Apartment',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Sector 62',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'View',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangeDeep,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLeadLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _noteCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String tag,
    required Color tagBg,
    required Color tagBorder,
    required Color tagColor,
    required String note,
    required String footer,
    bool italicNote = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 16.sp, color: iconColor),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: tagBorder),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: tagColor,
                      ),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            note,
            style: GoogleFonts.inter(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
              fontStyle: italicNote ? FontStyle.italic : FontStyle.normal,
              height: 1.65,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: AppColors.leadDetailDivider),
          SizedBox(height: 10.h),
          Text(
            footer,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD8E7FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 17.sp,
              color: const Color(0xFFC5D6F7),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes are private',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Notes help the team track discussions internally. They are never shared with clients or external portals.',
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addNewNoteButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7410),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 18.sp, color: AppColors.white),
          SizedBox(width: 10.w),
          Text(
            'Add New Note',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
    required this.trailingTop,
    required this.description,
    required this.owner,
    required this.role,
    required this.avatarBg,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  final String trailingTop;
  final String description;
  final String owner;
  final String role;
  final Color avatarBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            padding: EdgeInsets.only(top: 12.h),
            alignment: Alignment.topCenter,
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 18.sp, color: iconColor),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                letterSpacing: 0.2,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 72.w, maxWidth: 92.w),
                        child: Text(
                          trailingTop,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      color: AppColors.textBody,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 11.r,
                        backgroundColor: avatarBg,
                        child: Text(
                          owner.substring(0, 1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            owner,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (role.isNotEmpty)
                            Text(
                              role,
                              style: TextStyle(
                                fontSize: 10.5.sp,
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
      ),
    );
  }
}

class _LeadInformationCard extends StatelessWidget {
  const _LeadInformationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lead Information',
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _InfoRow(
            icon: Image.asset(
              'assets/admin.png',
              width: 18.w,
              height: 18.h,
              color: AppColors.iconMuted,
            ),
            label: 'Full Name',
            value: 'Rahul Sharma',
          ),
          _InfoRow(
            icon: Image.asset(
              'assets/email.png',
              width: 18.w,
              height: 18.h,
              color: AppColors.iconMuted,
            ),
            label: 'Email',
            value: 'rahul.sharma@gmail.co',
          ),
          _InfoRow(
            icon: Image.asset(
              'assets/calling.png',
              width: 18.w,
              height: 18.h,
              color: AppColors.iconMuted,
            ),
            label: 'Phone',
            value: '+919876543210',
            trailingIcon: Icons.verified,
            trailingColor: AppColors.greenStrong,
          ),
          const _InfoRow(
            icon: Icon(
              Icons.phone_android_outlined,
              color: AppColors.iconMuted,
            ),
            label: 'Alternate Phone',
            value: '+91 91234 56789',
          ),
          _InfoRow(
            icon: Image.asset(
              'assets/locations.png',
              width: 18.w,
              height: 18.h,
              color: AppColors.iconMuted,
            ),
            label: 'Location',
            value: 'Andheri East, Mumbai, Maharashtra',
          ),
          const _InfoRow(
            icon: Icon(Icons.work_outline, color: AppColors.iconMuted),
            label: 'Occupation',
            value: 'IT Professional',
          ),
          const _InfoRow(
            icon: Icon(Icons.business_outlined, color: AppColors.iconMuted),
            label: 'Company',
            value: 'TCS',
          ),
          const _InfoRow(
            icon: Icon(Icons.currency_rupee, color: AppColors.iconMuted),
            label: 'Budget',
            value: 'Rs 50 Lakhs - Rs 70 Lakhs',
          ),
          const _InfoRow(
            icon: Icon(Icons.pin_drop_outlined, color: AppColors.iconMuted),
            label: 'Preferred Location',
            value: 'Noida, Greater Noida',
          ),
          const _InfoRow(
            icon: Icon(Icons.home_outlined, color: AppColors.iconMuted),
            label: 'Property Type',
            value: '2 BHK Apartment',
          ),
          const _InfoRow(
            icon: Icon(Icons.check_box_outlined, color: AppColors.iconMuted),
            label: 'Requirement',
            value: 'Ready to Move',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingIcon,
    this.trailingColor,
  });

  final Widget icon;
  final String label;
  final String value;
  final IconData? trailingIcon;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: SizedBox(
              width: 18.w,
              height: 18.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF475569),
                    BlendMode.srcIn,
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 96.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF475569), // Darker than AppColors.iconMuted
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                      height: 1.5,
                      letterSpacing: 0,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  SizedBox(width: 6.w),
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Icon(
                      trailingIcon,
                      size: 16.sp,
                      color: trailingColor ?? AppColors.iconMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadStatusCard extends StatelessWidget {
  const _LeadStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Lead Status'),
          const SizedBox(height: 12),
          _StatusRow(
            icon: Image.asset(
              'assets/circle_contracted.png',
              width: 42.w,
              height: 42.h,
              fit: BoxFit.contain,
            ),
            label: 'Current Stage',
            value: 'Contacted',
            valueColor: AppColors.blueBright,
          ),
          _StatusRow(
            icon: Image.asset(
              'assets/circle_priority.png',
              width: 42.w,
              height: 42.h,
              fit: BoxFit.contain,
            ),
            label: 'Priority',
            value: 'High',
            valueColor: AppColors.leadTimelineAlert,
          ),
          const _StatusRow(
            icon: Icon(
              Icons.thermostat_outlined,
              color: AppColors.leadDetailRed,
            ),
            iconColor: AppColors.leadDetailRed,
            label: 'Temperature',
            value: 'Hot',
            valueColor: AppColors.leadDetailRed,
          ),
          const _StatusRow(
            icon: Icon(Icons.language, color: AppColors.purpleStrong),
            iconColor: AppColors.purpleStrong,
            label: 'Source',
            value: '99acres',
            valueColor: AppColors.textBody,
          ),
          const _StatusRow(
            icon: Icon(
              Icons.track_changes_outlined,
              color: AppColors.leadDetailAmber,
            ),
            iconColor: AppColors.leadDetailAmber,
            label: 'Sub Source',
            value: 'Website',
            valueColor: AppColors.textBody,
          ),
          _OwnerRow(),
        ],
      ),
    );
  }
}

class _LeadSummaryCard extends StatelessWidget {
  const _LeadSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Lead Summary'),
          SizedBox(height: 12.h),
          Text(
            'Rahul is looking for a 2 BHK apartment in Noida or Greater Noida. His budget is between Rs 50-70 Lakhs and he is interested in ready to move properties. He showed interest in our Green Valley project.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: AppColors.textPrimary, // Changed from textBody to textPrimary
            ),
          ),
          SizedBox(height: 20.h),
          Container(height: 1, color: AppColors.leadDetailDivider),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Image.asset(
                    'assets/circle_calling.png',
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                    // color: AppColors.greenStrong,
                  ),
                  title: 'Total Calls',
                  value: '34',
                  subtitle: 'Last call: 19 May 2025',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _SummaryMetric(
                  icon: Image.asset(
                    'assets/circle_message.png',
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                  ),
                  title: 'Total Messages',
                  value: '12',
                  subtitle: 'Last msg: 18 May 2025',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _SummaryMetric(
                  icon: Image.asset(
                    'assets/circle_timer.png',
                    width: 50.w,
                    height: 50.h,
                    fit: BoxFit.cover,
                  ),
                  title: 'Total Activities',
                  value: '8',
                  subtitle: 'Last activity: 20 May 2025',
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'REASSIGN LEAD',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.navy),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'CONVERT LEAD',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeDeep,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              icon: Icon(Icons.call, size: 18.sp),
              label: Text(
                'FOLLOW UP NOW',
                style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.iconColor,
  });

  final Widget icon;
  final Color? iconColor;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: iconColor == null ? 42.w : 36.w,
            height: iconColor == null ? 42.h : 36.w,
            decoration: BoxDecoration(
              color: iconColor?.withOpacity(0.12) ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: iconColor == null
                  ? icon
                  : SizedBox(
                width: 24.w,
                height: 24.h,
                child: FittedBox(fit: BoxFit.contain, child: icon),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF475569), // Darker than AppColors.iconMuted
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: valueColor == AppColors.textBody ? const Color(0xFF1E293B) : valueColor,
                    fontWeight: FontWeight.w700,
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

class _OwnerRow extends StatelessWidget {
  const _OwnerRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.gray900,
            child: Icon(Icons.person, size: 18.sp, color: AppColors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lead Owner',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF475569), // Darker label
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Amit Singh',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: const Color(0xFF1E293B), // Darker value
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Telecaller',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF64748B), // Slightly darker than original iconMuted
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 46.w,
          height: 46.h,
          child: FittedBox(fit: BoxFit.contain, child: icon),
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: const Color(0xFF0A1B4A),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}



class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.title,
    required this.date,
    required this.icon,
  });

  final String title;
  final String date;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.orangeStrong),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.download_outlined, size: 20.sp, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
