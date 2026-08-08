import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';

class SiteVisitDetailScreen extends StatelessWidget {
  final SiteVisitModel visit;

  const SiteVisitDetailScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.leadListBg,
      appBar: AppBar(
        title: Text(
          'Visit Details',
          style: GoogleFonts.inter(color: AppColors.slate900),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.slate900),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visit.leadName,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          _detailRow(Icons.apartment, 'Project:', visit.project),
          _detailRow(Icons.calendar_today, 'Date:', visit.date),
          _detailRow(Icons.access_time, 'Time:', visit.time),
          _detailRow(Icons.info_outline, 'Type:', visit.type),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.iconMuted),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          SizedBox(width: 4.w),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Status',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.windowBlue,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              visit.status,
              style: const TextStyle(
                color: AppColors.blueBright,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
