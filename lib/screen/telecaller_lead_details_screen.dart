import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class TelecallerLeadDetailsScreen extends StatelessWidget {
  const TelecallerLeadDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 156.h,
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lead Details',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 28.w,
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -32.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                  child: Column(
                    children: const [
                      _RequirementsCard(),
                      _CustomerInformationCard(),
                      _LeadTimelineCard(),
                      _CommunicationHistoryCard(),
                      _DetailsQuickActionsCard(),
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

class _DetailsCardShell extends StatelessWidget {
  const _DetailsCardShell({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE1E7F0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 13.sp,
                      color: AppColors.blueBright,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blueBright,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _RequirementItem(
        icon: Icons.apartment_rounded,
        title: 'Property\nType',
        value: 'Apartment',
      ),
      _RequirementItem(
        icon: Icons.bed_rounded,
        title: 'BHK',
        value: '3\nBHK',
      ),
      _RequirementItem(
        icon: Icons.calendar_today_rounded,
        title: 'Possession\nWithin',
        value: '6\nMonths',
      ),
      _RequirementItem(
        icon: Icons.place_rounded,
        title: 'Preferred Area',
        value: 'Noida\nExtension',
      ),
      _RequirementItem(
        icon: Icons.layers_rounded,
        title: 'Floor\nPreference',
        value: 'Mid Floor',
      ),
    ];

    return _DetailsCardShell(
      title: 'Requirements',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: _RequirementTile(item: item),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFE7EDF4), height: 1),
          SizedBox(height: 12.h),
          Text(
            'Remarks',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Looking for a spacious 3 BHK with good connectivity to metro.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem {
  const _RequirementItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({required this.item});

  final _RequirementItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, size: 19.sp, color: const Color(0xFF64748B)),
        SizedBox(height: 10.h),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.35,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _CustomerInformationCard extends StatelessWidget {
  const _CustomerInformationCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _CustomerInfoItem(
        icon: Icons.call_rounded,
        title: 'Mobile Number',
        value: '+91 98765 43210',
      ),
      _CustomerInfoItem(
        icon: Icons.work_rounded,
        title: 'Profession',
        value: 'Software Engineer',
      ),
      _CustomerInfoItem(
        icon: Icons.email_rounded,
        title: 'Email Address',
        value: 'rahulmehta@gmail.\ncom',
      ),
      _CustomerInfoItem(
        icon: Icons.group_rounded,
        title: 'Family Size',
        value: '4 Members',
      ),
      _CustomerInfoItem(
        icon: Icons.place_rounded,
        title: 'Location',
        value: 'Noida, Uttar\nPradesh',
      ),
      _CustomerInfoItem(
        icon: Icons.currency_rupee_rounded,
        title: 'Budget',
        value: '75 L - 90 L',
      ),
    ];

    return _DetailsCardShell(
      title: 'Customer Information',
      child: Wrap(
        spacing: 12.w,
        runSpacing: 16.h,
        children: items
            .map(
              (item) => SizedBox(
                width: (1.sw - 50.w) / 2,
                child: _CustomerInfoTile(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CustomerInfoItem {
  const _CustomerInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _CustomerInfoTile extends StatelessWidget {
  const _CustomerInfoTile({required this.item});

  final _CustomerInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F5FA),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 16.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeadTimelineCard extends StatelessWidget {
  const _LeadTimelineCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _TimelineItem(
        dotColor: Color(0xFF22C55E),
        icon: Icons.call_rounded,
        iconColor: Color(0xFF64748B),
        title: 'New Lead Assigned',
        time: '22 May 2025 • 10:30 AM',
        status: 'Completed',
        statusColor: Color(0xFF22C55E),
        statusBg: Color(0xFFEAFBF2),
      ),
      _TimelineItem(
        dotColor: Color(0xFFF97316),
        icon: Icons.call_rounded,
        iconColor: Color(0xFFF97316),
        title: 'First Call',
        time: '22 May 2025 • 11:15 AM',
        status: 'Completed',
        statusColor: Color(0xFFF97316),
        statusBg: Color(0xFFFFF1E8),
      ),
      _TimelineItem(
        dotColor: Color(0xFF3B82F6),
        icon: Icons.calendar_today_rounded,
        iconColor: Color(0xFF3B82F6),
        title: 'Follow-up Scheduled',
        time: '23 May 2025 • 11:00 AM',
        status: 'Upcoming',
        statusColor: Color(0xFF3B82F6),
        statusBg: Color(0xFFEAF2FF),
      ),
    ];

    return _DetailsCardShell(
      title: 'Lead Timeline',
      child: Column(
        children: items
            .map((item) => _TimelineRow(item: item))
            .toList(),
      ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  final Color dotColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusBg;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18.h, right: 8.w),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: item.dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Icon(item.icon, size: 17.sp, color: item.iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: item.statusBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              item.status,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: item.statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunicationHistoryCard extends StatelessWidget {
  const _CommunicationHistoryCard();

  @override
  Widget build(BuildContext context) {
    return _DetailsCardShell(
      title: 'Communication History',
      child: Column(
        children: const [
          _CommunicationRow(
            icon: Icons.call_rounded,
            iconColor: Color(0xFF22C55E),
            title: 'Call',
            subtitle: '22 May 2025 • 11:15 AM',
            trailingTextTop: 'Duration',
            trailingTextBottom: '04:32',
            showPlayButton: true,
          ),
          Divider(color: Color(0xFFE7EDF4), height: 24),
          _CommunicationRow(
            icon: Icons.whatshot,
            iconColor: Color(0xFF22C55E),
            title: 'WhatsApp',
            subtitle: '22 May 2025 • 11:45 AM',
            trailingTextBottom: '2 Messages',
            showChevron: true,
          ),
        ],
      ),
    );
  }
}

class _CommunicationRow extends StatelessWidget {
  const _CommunicationRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingTextTop,
    this.trailingTextBottom,
    this.showPlayButton = false,
    this.showChevron = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingTextTop;
  final String? trailingTextBottom;
  final bool showPlayButton;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFBF2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (trailingTextTop != null)
              Text(
                trailingTextTop!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
            if (trailingTextBottom != null) ...[
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingTextBottom!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (showChevron) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        if (showPlayButton) ...[
          SizedBox(width: 10.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 18.sp,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailsQuickActionsCard extends StatelessWidget {
  const _DetailsQuickActionsCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _QuickActionItem(
        icon: Icons.call_rounded,
        label: 'Call',
        bgColor: Color(0xFF22C55E),
      ),
      _QuickActionItem(
        icon: Icons.chat_rounded,
        label: 'WhatsApp',
        bgColor: Color(0xFF22C55E),
      ),
      _QuickActionItem(
        icon: Icons.calendar_today_rounded,
        label: 'Follow-up',
        bgColor: Color(0xFFFFF4EA),
        iconColor: Color(0xFFF97316),
      ),
      _QuickActionItem(
        icon: Icons.place_rounded,
        label: 'Schedule Visit',
        bgColor: Color(0xFFEAF2FF),
        iconColor: Color(0xFF3B82F6),
      ),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE1E7F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((item) => _QuickActionIconTile(item: item))
            .toList(),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
}

class _QuickActionIconTile extends StatelessWidget {
  const _QuickActionIconTile({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: item.bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 20.sp, color: item.iconColor),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 68.w,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}
