import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/router/app_router.dart';

class MyLeadsScreen extends StatelessWidget {
  const MyLeadsScreen({super.key});

  static const double panelIconSize = 18;
  static const double cardIconSize = 12;
  static const double avatarIconSize = 22;
  static const double actionIconSize = 16;
  static const double inlineIconSize = 14;

  static const TextStyle myLeadsTitleStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    height: 1.33,
    letterSpacing: 0,
    color: Color(0xFF000B20),
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    height: 1.33,
    letterSpacing: 0,
    color: Color(0xFF44474E),
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.4,
    letterSpacing: 0,
    color: Color(0xFF64748B),
  );

  static const TextStyle newLeadsTitleStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    height: 1.4,
    letterSpacing: 0,
    color: Color(0xFF002149),
  );

  static const TextStyle showingLeadsInfoStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.4,
    letterSpacing: 0,
    color: Color(0xFF46474B),
  );

  static const TextStyle leadNameStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF181C23),
  );

  static const TextStyle leadInfoLabelStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF44474E),
  );

  static const TextStyle slaStatusStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 15,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF44474E),
  );

  static const TextStyle leadInfoValueStyle = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    height: 1.5,
    letterSpacing: 0,
    color: Color(0xFF181C23),
  );

  static const List<_LeadSummaryData> _cards = [
    _LeadSummaryData(
      title: 'My Leads',
      value: '120',
      subtitle: 'Telecaller-assigned\nleads',
      icon: Icons.groups_2_outlined,
      iconColor: Color(0xFF2563EB),
      iconBackground: Color(0xFFEAF1FF),
    ),
    _LeadSummaryData(
      title: 'Upcoming\nFollow-Ups',
      value: '24',
      subtitle: 'Due for telecalling',
      icon: Icons.person_add_alt_1_outlined,
      iconColor: Color(0xFF22C55E),
      iconBackground: Color(0xFFE9F9EF),
    ),
    _LeadSummaryData(
      title: 'Priority Leads',
      value: '18',
      subtitle: 'Hot or urgent leads',
      icon: Icons.local_fire_department_outlined,
      iconColor: Color(0xFFF97316),
      iconBackground: Color(0xFFFFF1E8),
    ),
    _LeadSummaryData(
      title: 'Overdue Follow-ups',
      value: '6',
      subtitle: 'Ready for field\ncoordination',
      icon: Icons.place_outlined,
      iconColor: Color(0xFFA855F7),
      iconBackground: Color(0xFFF3E8FF),
    ),
  ];

  static const List<_NewLeadData> _newLeads = [
    _NewLeadData(
      name: 'Siddharth Nair',
      leadId: 'TR000005',
      phone: '+91 9543210987',
      alternateNumber: '-',
      email: 'siddharth.nair@gmail.com',
      location: 'Powai, Mumbai',
      occupation: 'Consultant',
      source: '99Acres',
      budget: '\u20B91.20 Cr',
      propertyType: '2 BHK Apartment',
      project: 'Lakeview Residences',
      carpetArea: '1,150 sq ft',
      possession: '6 Months',
      floorPreference: 'Mid Floor',
      timelineTitle: 'Introductory discussion completed',
      timelineDate: '24 Jun 2026',
      timelineTime: '10:30 am',
      timelineNote: 'Buyer asked for sample floor plans and budget options.',
      followUpState: 'PENDING',
      followUpDate: '01 Jul 2026',
      followUpTime: '11:00 am',
      followUpType: 'Call',
      followUpOwner: 'Sneha Iyer',
      followUpNotes: 'Share shortlisted 2 BHK inventory and payment plan.',
      stage: 'Booked',
      status: 'Booked',
      priority: 'Medium',
      sla: 'On Time',
      assignedTo: 'Telecaller Test',
      manager: 'Sales Manager Test',
      lastFollowUp: '24 Oct, 10:30 AM',
      nextFollowUp: 'Not Set',
      createdOn: '24 Jun 2026',
      updatedOn: '29 Jun 2026',
      aiLeadScore: 26,
      aiLeadStage: 'Early',
      estConversion: '21%',
      estRevenue: 'INR 1.20 Cr',
      temperature: 'Cool',
      engagement: '62%',
      slaState: 'BREACHED',
      slaSummary: 'Escalation required because this lead has an active SLA breach.',
      breachDate: '30 Jun 2026',
      responseTime: '18m 20s',
      ownerName: 'Telecaller Test',
      slaStatus: 'Active Breach',
      slaActivity: 'Initial callback not completed',
    ),
    _NewLeadData(
      name: 'Anjali Desai',
      leadId: 'TR000004',
      phone: '+91 9654321098',
      alternateNumber: '+91 9988776655',
      email: 'anjali.desai@gmail.com',
      location: 'Kandivali, Mumbai',
      occupation: 'Entrepreneur',
      source: 'Referral',
      budget: '\u20B93.50 Cr',
      propertyType: '3 BHK Apartment',
      project: 'Skyline Crest',
      carpetArea: '1,620 sq ft',
      possession: 'Ready',
      floorPreference: 'High Floor',
      timelineTitle: 'Negotiation round scheduled',
      timelineDate: '28 Jun 2026',
      timelineTime: '04:10 pm',
      timelineNote: 'Customer requested final pricing with modular kitchen add-on.',
      followUpState: 'TODAY',
      followUpDate: '02 Jul 2026',
      followUpTime: '03:00 pm',
      followUpType: 'Meeting',
      followUpOwner: 'Sneha Iyer',
      followUpNotes: 'Review revised pricing and builder discount options.',
      stage: 'Negotiation',
      status: 'Negotiation',
      priority: 'Medium',
      sla: 'On Time',
      assignedTo: 'Telecaller Test',
      manager: 'Sales Manager Test',
      lastFollowUp: '23 Oct, 02:15 PM',
      nextFollowUp: 'Not Set',
      createdOn: '26 Jun 2026',
      updatedOn: '29 Jun 2026',
      aiLeadScore: 44,
      aiLeadStage: 'Developing',
      estConversion: '32%',
      estRevenue: 'INR 3.10 Cr',
      temperature: 'Warm',
      engagement: '84%',
      slaState: 'AT RISK',
      slaSummary: 'Follow-up window is nearing breach and needs attention.',
      breachDate: '30 Jun 2026',
      responseTime: '09m 42s',
      ownerName: 'Telecaller Test',
      slaStatus: 'At Risk',
      slaActivity: 'Proposal review follow-up pending',
    ),
    _NewLeadData(
      name: 'Vikram Malhotra',
      leadId: 'TR000003',
      phone: '+91 9765432109',
      alternateNumber: '-',
      email: 'vikram.malhotra@gmail.com',
      location: 'Andheri (W), Mumbai',
      occupation: 'Not captured',
      source: 'MagicBricks',
      budget: 'INR 28M-33M',
      propertyType: '3 BHK Apartment',
      project: 'Palm Springs',
      carpetArea: 'Not captured',
      possession: 'Not captured',
      floorPreference: 'Not captured',
      timelineTitle: 'Planned luxury virtual visit',
      timelineDate: '29 Jun 2026',
      timelineTime: '03:46 pm',
      timelineNote: 'Will share Palm Springs amenity deck over video call.',
      followUpState: 'OVERDUE',
      followUpDate: '30 Jun 2026',
      followUpTime: '05:30 am',
      followUpType: 'Email',
      followUpOwner: 'Sneha Iyer',
      followUpNotes: 'Looking for 3 BHK in a ready luxury inventory.',
      stage: 'Site Visit',
      status: 'Site Visit',
      priority: 'Medium',
      sla: 'On Time',
      assignedTo: 'Telecaller Test',
      manager: 'Sales Manager Test',
      lastFollowUp: '22 Oct, 11:00 AM',
      nextFollowUp: 'Not Set',
      createdOn: '29 Jun 2026',
      updatedOn: '29 Jun 2026',
      aiLeadScore: 38,
      aiLeadStage: 'Developing',
      estConversion: '38%',
      estRevenue: 'INR 3.30 Cr',
      temperature: 'Warm',
      engagement: '100%',
      slaState: 'BREACHED',
      slaSummary: 'Escalation required because this lead has an active SLA breach.',
      breachDate: '30 Jun 2026',
      responseTime: '12m 00s',
      ownerName: 'Telecaller Test',
      slaStatus: 'Active Breach',
      slaActivity: 'Planned luxury virtual visit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabRow(),
                      SizedBox(height: 24.h),
                      _buildHeading(),
                      SizedBox(height: 14.h),
                      Divider(
                        color: const Color(0xFFBCC6D6),
                        thickness: 0.8.h,
                        height: 1.h,
                      ),
                      SizedBox(height: 24.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cards.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.94,
                        ),
                        itemBuilder: (context, index) {
                          return _LeadSummaryCard(data: _cards[index]);
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildNewLeadsSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Leads',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.orangeStrong,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '24',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orangeStrong,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          width: 92.w,
          height: 2.h,
          color: AppColors.orangeStrong,
        ),
        SizedBox(height: 9.h),
        Divider(
          color: const Color(0xFFD5DCE8),
          thickness: 0.9.h,
          height: 1.h,
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Leads',
          style: MyLeadsScreen.myLeadsTitleStyle,
        ),
        SizedBox(height: 8.h),
        Text(
          'Leads assigned to you as telecaller. Track follow-ups, qualification, and next actions from the same premium workspace.',
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            height: 1.33,
            letterSpacing: 0,
            color: Color(0xFF44474E),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildNewLeadsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Leads',
                      style: MyLeadsScreen.newLeadsTitleStyle,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Showing 1 to 8 of 120 leads',
                      style: MyLeadsScreen.showingLeadsInfoStyle,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRouter.myLeadsFilter),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFDCE3EE)),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: MyLeadsScreen.panelIconSize.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          for (int i = 0; i < _newLeads.length; i++) ...[
            _NewLeadCard(data: _newLeads[i], isDarkAvatar: i == 0),
            if (i != _newLeads.length - 1) SizedBox(height: 16.h),
          ],
          SizedBox(height: 16.h),
          const _PaginationRow(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'TRUEROOTREALTY',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          CircleAvatar(
            radius: 16.r,
            backgroundColor: const Color(0xFFF3F4F6),
            backgroundImage: const AssetImage('assets/admin.png'),
          ),
        ],
      ),
    );
  }
}

class _LeadSummaryCard extends StatelessWidget {
  const _LeadSummaryCard({required this.data});

  final _LeadSummaryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEAEBED)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: data.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: MyLeadsScreen.cardIconSize.sp,
                  color: data.iconColor,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 2,
                  style: MyLeadsScreen.cardTitleStyle,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.slate900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            data.subtitle,
            style: MyLeadsScreen.cardSubtitleStyle,
          ),
        ],
      ),
    );
  }
}

class _LeadSummaryData {
  const _LeadSummaryData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

class _NewLeadCard extends StatelessWidget {
  const _NewLeadCard({required this.data, required this.isDarkAvatar});

  final _NewLeadData data;
  final bool isDarkAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 17.w,
                      height: 17.w,
                      margin: EdgeInsets.only(top: 14.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: const Color(0xFFD8DFEA)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkAvatar ? const Color(0xFF252525) : const Color(0xFF2C2C2C),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: MyLeadsScreen.avatarIconSize.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: MyLeadsScreen.leadNameStyle,
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(999.r),
                              border: Border.all(color: const Color(0xFFC5DAFF)),
                            ),
                            child: Text(
                              data.leadId,
                              style: GoogleFonts.inter(
                                fontSize: 12.8.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2C6BFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLeadActions(context),
                        borderRadius: BorderRadius.circular(18.r),
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 2.h),
                          child: Icon(
                            Icons.more_vert,
                            size: (MyLeadsScreen.actionIconSize + 2).sp,
                            color: const Color(0xFF4B4E57),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.smartphone_outlined,
                      size: MyLeadsScreen.inlineIconSize.sp,
                      color: const Color(0xFF444A55),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        data.phone,
                        style: MyLeadsScreen.leadInfoValueStyle,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0xFFB8D1FF)),
                      ),
                      child: Text(
                        data.source,
                        style: GoogleFonts.inter(
                          fontSize: 12.3.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D6AFF),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LeadMetaBlock(label: 'BUDGET', value: data.budget),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: _LeadMetaBlock(label: 'PROPERTY TYPE', value: data.propertyType),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(color: const Color(0xFFE6EBF2), height: 1.h),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildChip(
                      text: data.stage,
                      textColor: const Color(0xFF1B4D9B),
                      backgroundColor: const Color(0xFFE8F0FF),
                    ),
                    _buildChip(
                      text: data.priority,
                      textColor: const Color(0xFFFF6B00),
                      backgroundColor: const Color(0xFFFFF1E8),
                      icon: Icons.bolt,
                    ),
                    _buildChip(
                      text: data.sla,
                      textColor: const Color(0xFF00A86B),
                      backgroundColor: const Color(0xFFE7F8F1),
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'Within configured SLA',
                  style: MyLeadsScreen.slaStatusStyle,
                ),
                SizedBox(height: 14.h),


              ],
            ),
          ),





          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(0, 12.h, 0, 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      _LeadInfoRow(label: 'Assigned To:', value: data.assignedTo),
                      SizedBox(height: 10.h),
                      _LeadInfoRow(label: 'Last Follow-up:', value: data.lastFollowUp),
                      SizedBox(height: 10.h),
                      _LeadInfoRow(label: 'Next Follow-up:', value: data.nextFollowUp),
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

  Widget _buildChip({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: (MyLeadsScreen.inlineIconSize - 2).sp,
              color: textColor,
            ),
            SizedBox(width: 5.w),
          ],
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.8.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeadActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _LeadActionsSheet(data: data);
      },
    );
  }
}

class _LeadMetaBlock extends StatelessWidget {
  const _LeadMetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: MyLeadsScreen.leadInfoLabelStyle,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: MyLeadsScreen.leadInfoValueStyle,
        ),
      ],
    );
  }
}

class _LeadInfoRow extends StatelessWidget {
  const _LeadInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: MyLeadsScreen.leadInfoLabelStyle,
          ),
        ),
        Text(
          value,
          style: MyLeadsScreen.leadInfoValueStyle,
        ),
      ],
    );
  }
}

class _NewLeadData {
  const _NewLeadData({
    required this.name,
    required this.leadId,
    required this.phone,
    required this.alternateNumber,
    required this.email,
    required this.location,
    required this.occupation,
    required this.source,
    required this.budget,
    required this.propertyType,
    required this.project,
    required this.carpetArea,
    required this.possession,
    required this.floorPreference,
    required this.timelineTitle,
    required this.timelineDate,
    required this.timelineTime,
    required this.timelineNote,
    required this.followUpState,
    required this.followUpDate,
    required this.followUpTime,
    required this.followUpType,
    required this.followUpOwner,
    required this.followUpNotes,
    required this.stage,
    required this.status,
    required this.priority,
    required this.sla,
    required this.assignedTo,
    required this.manager,
    required this.lastFollowUp,
    required this.nextFollowUp,
    required this.createdOn,
    required this.updatedOn,
    required this.aiLeadScore,
    required this.aiLeadStage,
    required this.estConversion,
    required this.estRevenue,
    required this.temperature,
    required this.engagement,
    required this.slaState,
    required this.slaSummary,
    required this.breachDate,
    required this.responseTime,
    required this.ownerName,
    required this.slaStatus,
    required this.slaActivity,
  });

  final String name;
  final String leadId;
  final String phone;
  final String alternateNumber;
  final String email;
  final String location;
  final String occupation;
  final String source;
  final String budget;
  final String propertyType;
  final String project;
  final String carpetArea;
  final String possession;
  final String floorPreference;
  final String timelineTitle;
  final String timelineDate;
  final String timelineTime;
  final String timelineNote;
  final String followUpState;
  final String followUpDate;
  final String followUpTime;
  final String followUpType;
  final String followUpOwner;
  final String followUpNotes;
  final String stage;
  final String status;
  final String priority;
  final String sla;
  final String assignedTo;
  final String manager;
  final String lastFollowUp;
  final String nextFollowUp;
  final String createdOn;
  final String updatedOn;
  final int aiLeadScore;
  final String aiLeadStage;
  final String estConversion;
  final String estRevenue;
  final String temperature;
  final String engagement;
  final String slaState;
  final String slaSummary;
  final String breachDate;
  final String responseTime;
  final String ownerName;
  final String slaStatus;
  final String slaActivity;
}

class _LeadActionsSheet extends StatelessWidget {
  const _LeadActionsSheet({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
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
                        _initials(data.name),
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
                          data.name,
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          data.phone,
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
                    _sheetAction(
                      context: context,
                      icon: Icons.remove_red_eye_outlined,
                      iconColor: const Color(0xFF4D7CFE),
                      iconBackground: const Color(0xFFF1F5FF),
                      title: 'View',
                      subtitle: 'Open lead details',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _LeadViewDetailScreen(data: data),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                    _sheetAction(
                      context: context,
                      icon: Icons.event_note_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      iconBackground: const Color(0xFFF5F0FF),
                      title: 'Create Follow-Up',
                      subtitle: 'Schedule next follow-up',
                      onTap: () {
                        Navigator.pop(context);
                        Future<void>.delayed(Duration.zero, () {
                          _showCreateFollowUpSheet(context, data);
                        });
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
                    onPressed: () => Navigator.pop(context),
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
  }

  Widget _sheetAction({
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
                size: MyLeadsScreen.inlineIconSize.sp,
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
              size: MyLeadsScreen.actionIconSize.sp,
              color: const Color(0xFFB09AFD),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateFollowUpSheet(
    BuildContext context,
    _NewLeadData data,
  ) {
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
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 18.sp,
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
                                _buildFollowUpSectionCard(
                                  title: 'Lead Context',
                                  icon: Icons.person_outline,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFollowUpTextField(
                                        label: 'Lead *',
                                        value: '${data.name} - ${data.phone}',
                                        caption: 'SELECTED LEAD',
                                      ),
                                      SizedBox(height: 14.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Lead Stage',
                                              value: 'Site Visit',
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Source',
                                              value: data.source,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                _buildFollowUpSectionCard(
                                  title: 'Property Details',
                                  icon: Icons.apartment_outlined,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFollowUpTextField(
                                        label: 'Project *',
                                        value: '${data.project} - ${data.location}',
                                        showChevron: true,
                                      ),
                                      SizedBox(height: 14.h),
                                      _buildFollowUpTextField(
                                        label: 'Unit',
                                        value: '${data.propertyType} - ${data.budget} - Avail...',
                                        showChevron: true,
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 14.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Location',
                                              value: _compactLocation(data.location),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Price',
                                              value: data.budget,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                _buildFollowUpSectionCard(
                                  title: 'Field Handoff',
                                  icon: Icons.access_time_outlined,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFollowUpTextField(
                                        label: 'Visit Type *',
                                        value: 'Site Visit',
                                        showChevron: true,
                                      ),
                                      SizedBox(height: 14.h),
                                      _buildFollowUpTextField(
                                        label: 'Assigned Executive *',
                                        value: 'Search executive',
                                        showChevron: true,
                                        valueColor: const Color(0xFF6B7280),
                                      ),
                                      SizedBox(height: 14.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Visit Date *',
                                              value: 'mm/dd/yyyy',
                                              valueColor: const Color(0xFF6B7280),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Visit Time *',
                                              value: '10:00 AM',
                                              showChevron: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 14.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Duration',
                                              value: '60 Minutes',
                                              showChevron: true,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Visitors',
                                              value: '2 Visitors',
                                              showChevron: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 14.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Transport',
                                              value: 'Own Vehicle',
                                              showChevron: true,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _buildFollowUpTextField(
                                              label: 'Meeting Point',
                                              value: 'Sales Gallery',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 14.h),
                                      _buildFollowUpTextField(
                                        label: 'Special Request',
                                        value: 'Parking needs, senior citizen assistance, preferred sample flat, negotiation context...',
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                              ],
                            ),
                          ),
                       ] ),
                    ),
                  ),
                  Container(height: 1.h, color: const Color(0xFFD9DFEA)),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                    child: Column(
                      children: [
                        Text(
                          'Required: lead, project, date, time, and executive.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3F3F46),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size.fromHeight(46.h),
                                  side: const BorderSide(color: Color(0xFF344054)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.fromHeight(46.h),
                                  elevation: 0,
                                  backgroundColor: AppColors.orangeDeep,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.event_available_outlined,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Schedule Visit',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
            ),
          ),
        );
      },
    );
  }

  Widget _followUpDetailBlock({
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

  Widget _buildFollowUpSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
          Row(
            children: [
              Icon(
                icon,
                size: 20.sp,
                color: const Color(0xFF111827),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 1.h,
            color: const Color(0xFFD9E2F2),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildFollowUpTextField({
    required String label,
    required String value,
    String? caption,
    bool showChevron = false,
    int maxLines = 1,
    Color valueColor = const Color(0xFF1F2937),
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: label.contains('*')
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF52525B),
            ),
          ),
          if (caption != null) ...[
            SizedBox(height: 8.h),
            Text(
              caption,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF52525B),
                letterSpacing: 0.5,
              ),
            ),
          ],
          SizedBox(height: caption != null ? 6.h : 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: valueColor,
                  ),
                ),
              ),
              if (showChevron) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: const Color(0xFF4B5563),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _compactLocation(String location) {
    if (location.length <= 18) {
      return location;
    }
    return '${location.substring(0, 18)}...';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _LeadViewDetailScreen extends StatelessWidget {
  const _LeadViewDetailScreen({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: Column(
            children: [
              const _LeadViewTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(14.w, 24.h, 14.w, 24.h),
                  child: Column(
                    children: [
                      _LeadViewSummaryCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadAiScoreCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadAiMetricsCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadSlaSummaryCard(data: data),
                      SizedBox(height: 18.h),
                      const _LeadDetailTabsRow(),
                      SizedBox(height: 16.h),
                      _LeadAboutCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadPropertyRequirementsCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadActivityTimelineCard(data: data),
                      SizedBox(height: 16.h),
                      _LeadNextFollowUpCard(data: data),
                      SizedBox(height: 16.h),
                      const _LeadNotesCard(),
                      SizedBox(height: 16.h),
                      const _LeadCommunicationQuickViewCard(),
                      SizedBox(height: 16.h),
                      const _LeadLatestBookingCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadViewTopBar extends StatelessWidget {
  const _LeadViewTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      child: Row(
        children: [
          _LeadViewIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, 34.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                side: const BorderSide(color: Color(0xFFD8DCE3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Create Site Visit',
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(0, 34.h),
                elevation: 0,
                backgroundColor: AppColors.orangeDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Schedule Follow-Up',
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _LeadViewIconButton(
            icon: Icons.more_vert,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _LeadViewIconButton extends StatelessWidget {
  const _LeadViewIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFD8DCE3)),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: const Color(0xFF101828),
        ),
      ),
    );
  }
}

class _LeadViewSummaryCard extends StatelessWidget {
  const _LeadViewSummaryCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F101828),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _LeadActionsSheet._initials(data.name),
                  style: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF101828),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E8),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        data.stage.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeDeep,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            data.name,
                            style: GoogleFonts.manrope(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.verified,
                          size: 18.sp,
                          color: const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '#${data.leadId}',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          _LeadViewInfoLine(
            icon: Icons.call_outlined,
            value: data.phone,
          ),
          SizedBox(height: 14.h),
          _LeadViewInfoLine(
            icon: Icons.mail_outline_rounded,
            value: data.email,
          ),
          SizedBox(height: 14.h),
          _LeadViewInfoLine(
            icon: Icons.location_on_outlined,
            value: data.location,
          ),
          SizedBox(height: 14.h),
          _LeadViewInfoLine(
            icon: Icons.campaign_outlined,
            value: data.source,
          ),
          SizedBox(height: 18.h),
          Divider(color: const Color(0xFFE5E7EB), height: 1.h),
          SizedBox(height: 22.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _LeadViewStatBlock(label: 'Stage', value: data.stage),
                    SizedBox(height: 18.h),
                    _LeadViewStatBlock(label: 'Assigned To', value: data.assignedTo),
                    SizedBox(height: 18.h),
                    _LeadViewStatBlock(label: 'Created On', value: data.createdOn),
                  ],
                ),
              ),
              SizedBox(width: 22.w),
              Expanded(
                child: Column(
                  children: [
                    _LeadViewStatBlock(label: 'Status', value: data.status),
                    SizedBox(height: 18.h),
                    _LeadViewStatBlock(label: 'Manager', value: data.manager),
                    SizedBox(height: 18.h),
                    _LeadViewStatBlock(label: 'Last Updated', value: data.updatedOn),
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

class _LeadViewInfoLine extends StatelessWidget {
  const _LeadViewInfoLine({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: const Color(0xFF6B7280),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF202939),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadViewStatBlock extends StatelessWidget {
  const _LeadViewStatBlock({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1F2937),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _LeadAiScoreCard extends StatelessWidget {
  const _LeadAiScoreCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'AI Lead Score',
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: 132.w,
            height: 132.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: data.aiLeadScore / 100,
                    strokeWidth: 14.w,
                    backgroundColor: const Color(0xFFECEEF3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orangeDeep),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${data.aiLeadScore}',
                      style: GoogleFonts.manrope(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '/100',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            data.aiLeadStage,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'View Scoring Logic',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF243B6B),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadAiMetricsCard extends StatelessWidget {
  const _LeadAiMetricsCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LeadAiMetricBlock(
                  label: 'Est. Conversion',
                  value: data.estConversion,
                  valueColor: const Color(0xFF111827),
                  footer: 'Low',
                  footerColor: const Color(0xFFF04438),
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: _LeadAiMetricBlock(
                  label: 'Est. Revenue',
                  value: data.estRevenue,
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LeadAiMetricBlock(
                  label: 'Temperature',
                  value: data.temperature,
                  valueColor: const Color(0xFF1F2937),
                  leadingIcon: Icons.local_fire_department_outlined,
                  leadingColor: AppColors.orangeDeep,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: _LeadAiMetricBlock(
                  label: 'Engagement',
                  value: data.engagement,
                  valueColor: const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadAiMetricBlock extends StatelessWidget {
  const _LeadAiMetricBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    this.footer,
    this.footerColor,
    this.leadingIcon,
    this.leadingColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? footer;
  final Color? footerColor;
  final IconData? leadingIcon;
  final Color? leadingColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 14.sp,
                color: leadingColor,
              ),
              SizedBox(width: 4.w),
            ],
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
        if (footer != null) ...[
          SizedBox(height: 4.h),
          Text(
            footer!,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: footerColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _LeadSlaSummaryCard extends StatelessWidget {
  const _LeadSlaSummaryCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'SLA Summary',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE4E2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        data.slaState,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Operational response and follow-up health',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F3),
              border: Border(
                top: BorderSide(color: const Color(0xFFEFD0CC)),
                bottom: BorderSide(color: const Color(0xFFEFD0CC)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 22.sp,
                  color: const Color(0xFFBE2026),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    data.slaSummary,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LeadViewStatBlock(
                        label: 'Breach Date',
                        value: data.breachDate,
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: _LeadViewStatBlock(
                        label: 'Response Time',
                        value: data.responseTime,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LeadViewStatBlock(
                        label: 'Owner',
                        value: data.ownerName,
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Expanded(
                      child: _LeadViewStatBlock(
                        label: 'Status',
                        value: data.slaStatus,
                        valueColor: const Color(0xFFD92D20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _LeadViewStatBlock(
                  label: 'Activity',
                  value: data.slaActivity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadDetailTabsRow extends StatelessWidget {
  const _LeadDetailTabsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 6.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9DFEA)),
        ),
      ),
      child: Row(
        children: [
          _LeadDetailTab(label: 'Overview', selected: true),
          SizedBox(width: 28.w),
          _LeadDetailTab(label: 'Activities Timeline'),
          SizedBox(width: 28.w),
          _LeadDetailTab(label: 'Property'),
        ],
      ),
    );
  }
}

class _LeadDetailTab extends StatelessWidget {
  const _LeadDetailTab({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        border: selected
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.orangeDeep,
                  width: 2,
                ),
              )
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 15.sp,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          color: selected ? AppColors.orangeDeep : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _LeadAboutCard extends StatelessWidget {
  const _LeadAboutCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20.sp,
                color: const Color(0xFF1B2A57),
              ),
              SizedBox(width: 8.w),
              Text(
                'About Lead',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _LeadInfoDividerRow(label: 'Full Name', value: data.name),
          _LeadInfoDividerRow(label: 'Mobile', value: data.phone),
          _LeadInfoDividerRow(label: 'Alternate Number', value: data.alternateNumber),
          _LeadInfoDividerRow(label: 'Email Address', value: data.email),
          _LeadInfoDividerRow(
            label: 'Occupation',
            value: data.occupation,
            mutedValue: data.occupation == 'Not captured',
          ),
          _LeadInfoDividerRow(
            label: 'Address',
            value: data.location,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _LeadInfoDividerRow extends StatelessWidget {
  const _LeadInfoDividerRow({
    required this.label,
    required this.value,
    this.showDivider = true,
    this.mutedValue = false,
  });

  final String label;
  final String value;
  final bool showDivider;
  final bool mutedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: mutedValue ? const Color(0xFF8A8F98) : const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadPropertyRequirementsCard extends StatelessWidget {
  const _LeadPropertyRequirementsCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_work_outlined,
                size: 20.sp,
                color: const Color(0xFF1B2A57),
              ),
              SizedBox(width: 8.w),
              Text(
                'Property Requirements',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _LeadRequirementTile(
                  icon: Icons.apartment_outlined,
                  label: 'Property Type',
                  value: data.propertyType,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _LeadRequirementTile(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget Range',
                  value: data.budget,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _LeadRequirementTile(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: data.location.replaceAll(', Mumbai', ''),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: _LeadRequirementTile(
                  icon: Icons.corporate_fare_outlined,
                  label: 'Project',
                  value: data.project,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Divider(color: const Color(0xFFE5E7EB), height: 1.h),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LeadViewStatBlock(
                  label: 'Carpet Area',
                  value: data.carpetArea,
                  valueColor: data.carpetArea == 'Not captured'
                      ? const Color(0xFF8A8F98)
                      : const Color(0xFF1F2937),
                ),
              ),
              Expanded(
                child: _LeadViewStatBlock(
                  label: 'Possession',
                  value: data.possession,
                  valueColor: data.possession == 'Not captured'
                      ? const Color(0xFF8A8F98)
                      : const Color(0xFF1F2937),
                ),
              ),
              Expanded(
                child: _LeadViewStatBlock(
                  label: 'Floor Pref.',
                  value: data.floorPreference,
                  valueColor: data.floorPreference == 'Not captured'
                      ? const Color(0xFF8A8F98)
                      : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadRequirementTile extends StatelessWidget {
  const _LeadRequirementTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: const Color(0xFF4B5563),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadActivityTimelineCard extends StatelessWidget {
  const _LeadActivityTimelineCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20.sp,
                color: const Color(0xFF1B2A57),
              ),
              SizedBox(width: 8.w),
              Text(
                'Activity Timeline',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD9DFEA)),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.event_note_outlined,
                      size: 14.sp,
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 90.h,
                    color: const Color(0xFFE5E7EB),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.timelineTitle,
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${data.timelineDate}  •  ${data.timelineTime}',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFD9DFEA)),
                      ),
                      child: Text(
                        data.timelineNote,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              'View Full Timeline',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadNextFollowUpCard extends StatelessWidget {
  const _LeadNextFollowUpCard({required this.data});

  final _NewLeadData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3B6B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 20.sp,
                color: const Color(0xFFD92D20),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Next Follow-up',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  data.followUpState,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 15.sp, color: const Color(0xFF6B7280)),
              SizedBox(width: 8.w),
              Text(
                data.followUpDate,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(width: 22.w),
              Icon(Icons.access_time_outlined, size: 15.sp, color: const Color(0xFF6B7280)),
              SizedBox(width: 8.w),
              Text(
                data.followUpTime,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _LeadViewStatBlock(label: 'Follow-up Type', value: data.followUpType),
          SizedBox(height: 14.h),
          _LeadViewStatBlock(label: 'Assigned To', value: data.followUpOwner),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFC),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFD9DFEA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  data.followUpNotes,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.orangeDeep,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Mark as Completed',
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
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

class _LeadNotesCard extends StatelessWidget {
  const _LeadNotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 20.sp,
                color: const Color(0xFF1B2A57),
              ),
              SizedBox(width: 8.w),
              Text(
                'Notes',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 34.h),
          Center(
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 24.sp,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Center(
            child: Text(
              'No internal notes yet',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCommunicationQuickViewCard extends StatelessWidget {
  const _LeadCommunicationQuickViewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Communication Quick View',
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: const [
              Expanded(
                child: _LeadQuickViewMetricTile(
                  icon: Icons.call_outlined,
                  iconColor: Color(0xFF64748B),
                  iconBackground: Color(0xFFF3F4F6),
                  label: 'TOTAL CALLS',
                  value: '0',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LeadQuickViewMetricTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: Color(0xFF22C55E),
                  iconBackground: Color(0xFFEAFBF0),
                  label: 'WHATSAPP',
                  value: '0',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: const [
              Expanded(
                child: _LeadQuickViewMetricTile(
                  icon: Icons.apartment_outlined,
                  iconColor: Color(0xFFF59E0B),
                  iconBackground: Color(0xFFFFF4E5),
                  label: 'SITE VISITS',
                  value: '1',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LeadQuickViewMetricTile(
                  icon: Icons.task_alt_outlined,
                  iconColor: Color(0xFF16A34A),
                  iconBackground: Color(0xFFEAFBF0),
                  label: 'TASKS',
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

class _LeadQuickViewMetricTile extends StatelessWidget {
  const _LeadQuickViewMetricTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
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
              size: 15.sp,
              color: iconColor,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
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

class _LeadLatestBookingCard extends StatelessWidget {
  const _LeadLatestBookingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD9DFEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 20.sp,
                color: const Color(0xFF1B2A57),
              ),
              SizedBox(width: 8.w),
              Text(
                'Latest Booking',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 34.h),
          Center(
            child: Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.add_business_outlined,
                size: 28.sp,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              'No bookings recorded yet',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: Size(196.w, 42.h),
                side: const BorderSide(color: Color(0xFF1B2A57)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Create New Booking',
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2A57),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationRow extends StatelessWidget {
  const _PaginationRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pageButton(icon: Icons.chevron_left, isFilled: false),
        SizedBox(width: 6.w),
        _pageLabel('1', isFilled: true),
        SizedBox(width: 6.w),
        _pageLabel('2'),
        SizedBox(width: 6.w),
        Text(
          '...',
          style: GoogleFonts.inter(
            fontSize: 21.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(width: 6.w),
        _pageButton(icon: Icons.chevron_right, isFilled: false),
        const Spacer(),
        Text(
          'Rows per page:',
          style: GoogleFonts.inter(
            fontSize: 14.2.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF454B57),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFC9D1DE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '8',
                style: GoogleFonts.inter(
                  fontSize: 14.2.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3A404B),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: MyLeadsScreen.actionIconSize.sp,
                color: const Color(0xFF5B6170),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageButton({required IconData icon, required bool isFilled}) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFF05122D) : Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFC9D1DE)),
      ),
      child: Icon(
        icon,
        size: MyLeadsScreen.actionIconSize.sp,
        color: isFilled ? Colors.white : const Color(0xFF4B5563),
      ),
    );
  }

  Widget _pageLabel(String label, {bool isFilled = false}) {
    return Container(
      width: 32.w,
      height: 32.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFF05122D) : Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: isFilled ? const Color(0xFF05122D) : const Color(0xFFC9D1DE),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.2.sp,
          fontWeight: FontWeight.w600,
          color: isFilled ? Colors.white : const Color(0xFF3C4350),
        ),
      ),
    );
  }
}
