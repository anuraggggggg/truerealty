import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class TelecallerCommunicationScreen extends StatelessWidget {
  const TelecallerCommunicationScreen({super.key});

  static const List<_CallStat> _stats = [
    _CallStat(
      title: 'Total Calls\nToday',
      value: '145',
      trend: '18% vs yesterday',
      icon: Icons.call_outlined,
      iconColor: Color(0xFF3B82F6),
      iconBackground: Color(0xFFF3F8FF),
      borderColor: Color(0xFFD9E8FF),
    ),
    _CallStat(
      title: 'Connected\nCalls',
      value: '92',
      trend: '22% vs yesterday',
      icon: Icons.check_circle_outline_rounded,
      iconColor: Color(0xFF10B981),
      iconBackground: Color(0xFFF0FFF8),
      borderColor: Color(0xFFD4F6E8),
    ),
    _CallStat(
      title: 'Missed\nCalls',
      value: '21',
      trend: '12% vs yesterday',
      icon: Icons.call_missed_outgoing_outlined,
      iconColor: Color(0xFFFF4D4F),
      iconBackground: Color(0xFFFFF5F5),
      borderColor: Color(0xFFFFD9DA),
      isPositive: false,
    ),
    _CallStat(
      title: 'Outgoing\nCalls',
      value: '118',
      trend: '15% vs yesterday',
      icon: Icons.north_east_rounded,
      iconColor: Color(0xFFB250FF),
      iconBackground: Color(0xFFFAF4FF),
      borderColor: Color(0xFFF0DBFF),
    ),
    _CallStat(
      title: 'Incoming\nCalls',
      value: '27',
      trend: '8% vs yesterday',
      icon: Icons.south_west_rounded,
      iconColor: Color(0xFF06B6D4),
      iconBackground: Color(0xFFF1FDFF),
      borderColor: Color(0xFFD8F6FB),
    ),
    _CallStat(
      title: 'Total Talk\nTime',
      value: '14h35m',
      trend: '20% vs yesterday',
      icon: Icons.access_time_rounded,
      iconColor: Color(0xFFFF8A1D),
      iconBackground: Color(0xFFFFF8EF),
      borderColor: Color(0xFFFFE5C2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _CommunicationHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call History',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        height: 1.4,
                        letterSpacing: 0,
                        color: const Color(0xFF002149),
                      ),
                ),

                    SizedBox(height: 10.h),
                    Text(
                      'Track all incoming and outgoing customer call\nactivities.',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w400, // Normal
                        height: 1.38,
                        color: Color(0xFF475569),
                      ),
                    ),

                    SizedBox(height: 18.h),
                    const _DateRangeCard(),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.download_outlined,
                            label: 'Export',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.filter_alt_rounded,
                            label: 'Filters',
                            onTap: () => _showFiltersBottomSheet(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 0.86,
                      ),
                      itemBuilder: (context, index) {
                        return _StatCard(data: _stats[index]);
                      },
                    ),
                    SizedBox(height: 18.h),
                    const _CallHistoryDetailCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showFiltersBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FiltersBottomSheet(),
    );
  }
}

class _CommunicationHeader extends StatelessWidget {
  const _CommunicationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D101828),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: AppColors.navy, size: 25.sp),
          SizedBox(width: 14.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'TRUE',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  TextSpan(
                    text: 'ROOT',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(Icons.search_rounded, color: AppColors.navy, size: 23.sp),
          SizedBox(width: 14.w),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.orangeDeep,
                size: 23.sp,
              ),
              Positioned(
                top: 1.h,
                right: 1.w,
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: AppColors.orangeDeep,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3E8EF)),
            ),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: const Color(0xFFF3F4F6),
              backgroundImage: const AssetImage('assets/app_icon.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDDE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: const Color(0xFF667085),
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            '20 May 2025 - 20 May 2025',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
              color: Color(0xFF002149),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFDDE4EE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.navy, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400, // Normal
                  height: 1.33,
                  letterSpacing: 0.24,
                  color: Color(0xFF002149),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersBottomSheet extends StatelessWidget {
  const _FiltersBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 8.h, 0, 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DDE5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              const Divider(height: 1, color: Color(0xFFE7EBF2)),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 0),
                child: const Column(
                  children: [
                    _FilterSearchField(),
                    _FilterSheetGap(),
                    _FilterDropdownField(label: 'All Projects'),
                    _FilterSheetGap(),
                    _FilterDropdownField(label: 'All Types'),
                    _FilterSheetGap(),
                    _FilterDropdownField(label: 'All Status'),
                    _FilterSheetGap(),
                    _FilterDropdownField(label: 'All Executives'),
                    _FilterSheetGap(),
                    _FilterDateField(label: '20 May 2025 - 20 May 2025'),
                    _FilterSheetGap(),
                    _FilterDropdownField(label: 'All Duration'),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFE7EBF2)),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 12.sp,
                      color: const Color(0xFF4B5563),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Reset Filters',
                      style: GoogleFonts.inter(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orangeDeep,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.inter(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSearchField extends StatelessWidget {
  const _FilterSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 15.sp, color: const Color(0xFF98A2B3)),
          SizedBox(width: 8.w),
          Text(
            'Search lead name / mobile num',
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              color: const Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdownField extends StatelessWidget {
  const _FilterDropdownField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                color: AppColors.navy,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16.sp,
            color: const Color(0xFF667085),
          ),
        ],
      ),
    );
  }
}

class _FilterDateField extends StatelessWidget {
  const _FilterDateField({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE1E7EF)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14.sp,
            color: const Color(0xFF667085),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheetGap extends StatelessWidget {
  const _FilterSheetGap();

  @override
  Widget build(BuildContext context) => SizedBox(height: 10.h);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _CallStat data;

  @override
  Widget build(BuildContext context) {
    final trendColor = data.isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFFF4D4F);

    return
      Container(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDDE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
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
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: data.iconBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: data.borderColor),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Color(0xFF74777F),
                    ),
                  ),
                  ),
                ),

            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                data.isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16.sp,
                color: trendColor,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  data.trend,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFF10B981),
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

class _CallStat {
  const _CallStat({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.borderColor,
    this.isPositive = true,
  });

  final String title;
  final String value;
  final String trend;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color borderColor;
  final bool isPositive;
}

class _CallHistoryDetailCard extends StatelessWidget {
  const _CallHistoryDetailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDDE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      margin: EdgeInsets.only(top: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: const Color(0xFFD8E0EA)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E8),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFC89E)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'RS',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orangeDeep,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rahul Sharma',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '+91 98765 43210',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.message_outlined,
                                size: 13.sp,
                                color: const Color(0xFF10B981),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _TopActionIcon(
                      icon: Icons.call_outlined,
                      color: const Color(0xFF2563EB),
                    ),
                    SizedBox(width: 8.w),
                    _TopActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(width: 8.w),
                    const _OverflowMenuPreview(),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.apartment_rounded,
                        size: 16.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Primus',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'DLF Sector 82A',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _DetailMetaItem(
                        label: 'CALL TYPE',
                        value: 'Outgoing',
                        icon: Icons.north_east_rounded,
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _DetailMetaTextItem(
                        label: 'DURATION',
                        value: '08m 35s',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    const Expanded(
                      child: _DetailMetaTextItem(
                        label: 'CALL DATE',
                        value: '20 May 2025',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    const Expanded(
                      child: _DetailMetaTextItem(
                        label: 'CALL TIME',
                        value: '10:15 AM',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _StatusChip(
                      label: 'Connected',
                      background: const Color(0xFFE8F8EC),
                      foreground: const Color(0xFF16A34A),
                    ),
                    _StatusChip(
                      label: 'Follow-up Added',
                      background: const Color(0xFFEEF2FF),
                      foreground: const Color(0xFF2563EB),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(height: 1, color: const Color(0xFFE6EBF2)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13.r,
                      backgroundColor: const Color(0xFFE91E63),
                      child: Text(
                        'AK',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amit Kumar',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          'Telecaller',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: const Color(0xFF8B95A7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'CALL NOTES',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.navy,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFDDE4EE)),
              ),
              child: Text(
                'Discussed about 3 BHK pricing and\namenities. Customer is interested and\nrequested site visit this weekend.',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  height: 1.55,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'CALL RECORDING',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.navy,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 16.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFDDE4EE)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF2E8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.orangeDeep,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: SizedBox(
                          height: 24.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(
                              14,
                              (index) => Padding(
                                padding: EdgeInsets.only(right: 3.w),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 3.w,
                                    height: [10, 16, 22, 13, 20, 24, 18, 15, 19, 21, 11, 14, 9, 16][index].h,
                                    decoration: BoxDecoration(
                                      color: index < 10
                                          ? const Color(0xFFFF9B54)
                                          : const Color(0xFFB8C0CC),
                                      borderRadius: BorderRadius.circular(3.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '00:00 / 08m 35s',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.download_rounded,
                        size: 17.sp,
                        color: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'ID: CALL_20250520_1015',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: const Color(0xFF8B95A7),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'Recording available for 30 days',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Divider(height: 1, color: const Color(0xFFE6EBF2)),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'CUSTOMER RESPONSE',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.navy,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'Customer is interested in 3 BHK. Budget\naround ₹ 1.2 Cr. Wants to visit this Saturday\nwith family.',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                height: 1.55,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'NEXT FOLLOW-UP',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.navy,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15.sp,
                  color: AppColors.orangeDeep,
                ),
                SizedBox(width: 8.w),
                Text(
                  '22 May 2025, 11:00 AM',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: _StatusChip(
              label: 'Site Visit',
              background: const Color(0xFFE8F8EC),
              foreground: const Color(0xFF16A34A),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Divider(height: 1, color: const Color(0xFFE6EBF2)),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'PREVIOUS CALLS (3)',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.navy,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Column(
              children: const [
                _PreviousCallRow(dateTime: '19 May 2025, 06:30 PM', duration: '04m 12s'),
                _PreviousCallRow(dateTime: '18 May 2025, 11:45 AM', duration: '05m 20s'),
                _PreviousCallRow(dateTime: '16 May 2025, 07:10 PM', duration: '02m 35s', showDivider: false),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              'View All Calls',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.orangeDeep,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          const _CompactCallPreviewCard(),
          SizedBox(height: 16.h),
          const _MinimalCallPreviewCard(),
          SizedBox(height: 16.h),
          const _PaginationSection(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

class _TopActionIcon extends StatelessWidget {
  const _TopActionIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDDE4EE)),
      ),
      child: Icon(icon, size: 18.sp, color: color),
    );
  }
}

class _OverflowMenuPreview extends StatelessWidget {
  const _OverflowMenuPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      height: 32.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDDE4EE)),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                size: 16.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Positioned(
            top: 35.h,
            right: -56.w,
            child: Container(
              width: 88.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
                border: Border.all(color: const Color(0xFFDDE4EE)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Text(
                      'Add Note',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.navy,
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

class _DetailMetaItem extends StatelessWidget {
  const _DetailMetaItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0.7,
            color: const Color(0xFF8B95A7),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(icon, size: 18.sp, color: iconColor),
            SizedBox(width: 4.w),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailMetaTextItem extends StatelessWidget {
  const _DetailMetaTextItem({required this.label, required this.value});

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
            letterSpacing: 0.7,
            color: const Color(0xFF8B95A7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}

class _PreviousCallRow extends StatelessWidget {
  const _PreviousCallRow({
    required this.dateTime,
    required this.duration,
    this.showDivider = true,
  });

  final String dateTime;
  final String duration;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dateTime,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              Text(
                duration,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFEDEFF4)),
      ],
    );
  }
}

class _CompactCallPreviewCard extends StatelessWidget {
  const _CompactCallPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDDE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: const Color(0xFFD8E0EA)),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDCE5FF)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'NK',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Neha Kapoor',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '+91 98123 45678',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.message_outlined,
                          size: 13.sp,
                          color: const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _TopActionIcon(
                icon: Icons.call_outlined,
                color: const Color(0xFF2563EB),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDDE4EE)),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 16.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'M3M',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B5CCC),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M3M Capital',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sector 113',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: const [
              Expanded(
                child: _DetailMetaItem(
                  label: 'CALL TYPE',
                  value: 'Incoming',
                  icon: Icons.south_west_rounded,
                  iconColor: Color(0xFF06B6D4),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _DetailMetaTextItem(
                  label: 'DURATION',
                  value: '05m 12s',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _StatusChip(
                label: 'Busy',
                background: const Color(0xFFFFF1E8),
                foreground: AppColors.orangeDeep,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBE8),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: const Color(0xFFFFC107)),
                ),
                child: Text(
                  'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE0A300),
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

class _MinimalCallPreviewCard extends StatelessWidget {
  const _MinimalCallPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDDE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: const Color(0xFFD8E0EA)),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC89E)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'VS',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.orangeDeep,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vikram Singh',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '+91 98234 56789',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  size: 16.sp,
                  color: const Color(0xFF4B5563),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Godrej Air',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sector 85',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: const Color(0xFFE6EBF2)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _StatusChip(
                label: 'Connected',
                background: const Color(0xFFE8F8EC),
                foreground: const Color(0xFF16A34A),
              ),
              _StatusChip(
                label: 'Site Visit Scheduled',
                background: const Color(0xFFEEF5FF),
                foreground: const Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationSection extends StatelessWidget {
  const _PaginationSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 14.h),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0xFFE6EBF2))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rows per page:',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: const Color(0xFF667085),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFDDE4EE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '10',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.sp,
                      color: const Color(0xFF98A2B3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageButton(
                label: '',
                icon: Icons.chevron_left_rounded,
                foreground: const Color(0xFFD0D5DD),
              ),
              SizedBox(width: 4.w),
              const _PageButton(
                label: '1',
                background: AppColors.navy,
                foreground: Colors.white,
              ),
              SizedBox(width: 4.w),
              const _PageButton(label: '2'),
              SizedBox(width: 4.w),
              const _PageButton(label: '3'),
              SizedBox(width: 8.w),
              Text(
                '...',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  color: const Color(0xFF667085),
                ),
              ),
              SizedBox(width: 8.w),
              const _PageButton(label: '15'),
              SizedBox(width: 4.w),
              const _PageButton(
                label: '',
                icon: Icons.chevron_right_rounded,
                foreground: AppColors.navy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    this.icon,
    this.background = Colors.white,
    this.foreground = AppColors.navy,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: background == Colors.white
              ? const Color(0xFFDDE4EE)
              : AppColors.navy,
        ),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 20.sp, color: foreground)
          : Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
    );
  }
}
