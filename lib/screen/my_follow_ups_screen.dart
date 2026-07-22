import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

// Copying necessary data structures for Follow-ups
class _TelecallerFollowUpData {
  const _TelecallerFollowUpData({
    required this.name,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;
}

// In a real app, this data should come from a Provider, 
// for now reusing the sample data structure
const _followUps = [
  _TelecallerFollowUpData(
    name: 'Rahul Mehta',
    project: 'Trueroot Heights',
    status: 'Hot Lead',
    time: '11:00 AM',
    avatarBg: Color(0xFFFFF4EA),
    avatarColor: Color(0xFFFFA94D),
    statusBg: Color(0xFFFFF1E7),
    statusColor: Color(0xFFFF6B00),
  ),
  _TelecallerFollowUpData(
    name: 'Neha Kapoor',
    project: 'Trueroot Urbania',
    status: 'Interested',
    time: '12:30 PM',
    avatarBg: Color(0xFFEAFBF2),
    avatarColor: Color(0xFF22C55E),
    statusBg: Color(0xFFEAFBF2),
    statusColor: Color(0xFF10B981),
  ),
  _TelecallerFollowUpData(
    name: 'Amit Sharma',
    project: 'Trueroot Homes',
    status: 'New Lead',
    time: '03:00 PM',
    avatarBg: Color(0xFFF3E8FF),
    avatarColor: Color(0xFF8B5CF6),
    statusBg: Color(0xFFEAF2FF),
    statusColor: Color(0xFF2563EB),
  ),
  _TelecallerFollowUpData(
    name: 'Sneha Iyer',
    project: 'Trueroot Skyview',
    status: 'Hot Lead',
    time: '04:30 PM',
    avatarBg: Color(0xFFEAF2FF),
    avatarColor: Color(0xFF2563EB),
    statusBg: Color(0xFFFFF1E7),
    statusColor: Color(0xFFFF6B00),
  ),
];

class MyFollowUpsScreen extends StatelessWidget {
  const MyFollowUpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        title: Text(
          'My Follow-ups',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BestTimeFollowUpSection(),
            SizedBox(height: 24.h),
            const _FollowUpsListSection(),
          ],
        ),
      ),
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
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Derived from scheduled slots in the current queue',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: slots[index].$2.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slots[index].$1,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scheduled',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '0',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
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

class _FollowUpsListSection extends StatelessWidget {
  const _FollowUpsListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Follow Ups',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFDDE6F0)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _followUps.length; i++) ...[
                _FollowUpRow(
                  name: _followUps[i].name,
                  project: _followUps[i].project,
                  status: _followUps[i].status,
                  time: _followUps[i].time,
                  avatarBg: _followUps[i].avatarBg,
                  avatarColor: _followUps[i].avatarColor,
                  statusBg: _followUps[i].statusBg,
                  statusColor: _followUps[i].statusColor,
                ),
                if (i != _followUps.length - 1)
                  Divider(height: 1, color: const Color(0xFFEAEFF5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  const _FollowUpRow({
    required this.name,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: avatarBg,
            child: Icon(Icons.person, size: 18.sp, color: avatarColor),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  project,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15.sp,
                color: const Color(0xFF94A3B8),
              ),
              SizedBox(width: 4.w),
              Text(
                time,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 48.w,
                height: 48.w,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    'assets/whats_app.png',
                    fit: BoxFit.contain,
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
