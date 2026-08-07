import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/provider/follow_ups_provider.dart';

class TodaysFollowUpsFab extends StatefulWidget {
  const TodaysFollowUpsFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<TodaysFollowUpsFab> createState() => _TodaysFollowUpsFabState();
}

class _TodaysFollowUpsFabState extends State<TodaysFollowUpsFab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<FollowUpsProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadFollowUps(limit: 500);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FollowUpsProvider>();
    final count = provider.summary.todayCount;
    final countLabel = count > 99 ? '99+' : '$count';

    return SizedBox(
      width: 78.r,
      height: 78.r,
      child: FloatingActionButton(
        heroTag: null,
        tooltip: "Today's Follow-Ups: $count",
        onPressed: widget.onPressed,
        elevation: 5,
        backgroundColor: const Color(0xFF2864F0),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                provider.isLoading && !provider.hasLoaded
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        countLabel,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                SizedBox(height: 4.h),
                Text(
                  "Today's\nFollow-Ups",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
