import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/follow_up_model.dart';

/// Shared dashboard-style surface used across Follow-Up sections.
class FollowUpSectionCard extends StatelessWidget {
  const FollowUpSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((borderRadius ?? 18).r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FollowUpMetricCardData {
  const FollowUpMetricCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.footer,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final String footer;
  final IconData icon;
  final Color iconColor;
}

/// Metric card matching Dashboard card language (white, soft border, shadow).
class FollowUpMetricCard extends StatelessWidget {
  const FollowUpMetricCard({super.key, required this.data, this.onTap});

  final FollowUpMetricCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: FollowUpSectionCard(
          borderRadius: 14,
          padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 43.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(data.icon, color: data.iconColor, size: 22.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                data.value,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                data.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                data.footer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueBright,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FollowUpSlaTileData {
  const FollowUpSlaTileData({
    required this.value,
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.badgeBackground,
  });

  final String value;
  final String label;
  final String badge;
  final Color badgeColor;
  final Color badgeBackground;
}

class FollowUpSlaTile extends StatelessWidget {
  const FollowUpSlaTile({super.key, required this.data});

  final FollowUpSlaTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE6ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.value,
                  style: GoogleFonts.inter(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: data.badgeBackground,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  data.badge,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: data.badgeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D2C2C),
            ),
          ),
        ],
      ),
    );
  }
}

class FollowUpStatusChip extends StatelessWidget {
  const FollowUpStatusChip({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.borderColor,
  });

  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// Detailed follow-up lead card — dashboard card style, reusable elsewhere.
class FollowUpLeadCard extends StatelessWidget {
  const FollowUpLeadCard({
    super.key,
    required this.item,
    this.onTap,
    this.onCall,
    this.onWhatsApp,
    this.onMore,
  });

  final FollowUpModel item;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(item.statusLabel);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: FollowUpSectionCard(
          borderRadius: 14,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFF10213D),
                    child: Text(
                      _initials(item.leadName),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: onMore,
                          child: Text(
                            item.leadName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'Added on ${_formatDateTime(_leadCreatedAt(item))}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FollowUpStatusChip(
                    label: item.statusLabel,
                    foreground: statusColors.$1,
                    background: statusColors.$2,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _FollowUpCardDetail(
                      icon: Icons.phone_rounded,
                      label: 'Mobile Number',
                      value: item.phone,
                      iconColor: const Color(0xFF00A63E),
                      iconBackground: const Color(0xFFE8F8EE),
                    ),
                  ),
                  const _FollowUpVerticalDivider(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _FollowUpCardDetail(
                      icon: Icons.apartment_rounded,
                      label: item.project,
                      value: item.location.isEmpty ? '-' : item.location,
                      iconColor: const Color(0xFF1468D4),
                      iconBackground: const Color(0xFFEAF2FF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _FollowUpCardDetail(
                        icon: Icons.other_houses_outlined,
                        label: 'Configuration',
                        value: item.configuration.trim().isEmpty
                            ? 'Not specified'
                            : item.configuration,
                        iconColor: const Color(0xFF4D2DDB),
                        iconBackground: const Color(0xFFEDEAFF),
                      ),
                    ),
                    const _FollowUpVerticalDivider(),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _FollowUpCardDetail(
                        icon: Icons.event_available_outlined,
                        label: 'Next follow-up',
                        value: _formatDateTime(item.scheduledAt),
                        iconColor: const Color(0xFF4D2DDB),
                        iconBackground: const Color(0xFFEDEAFF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 11.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 17.sp,
                    color: const Color(0xFF1454D8),
                  ),
                  SizedBox(width: 7.w),
                  Text(
                    'Remark: ',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (item.notes?.trim().isNotEmpty == true)
                          ? item.notes!.trim()
                          : (item.nextAction?.trim().isNotEmpty == true)
                          ? item.nextAction!.trim()
                          : 'No remarks added',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF263248),
                      ),
                    ),
                  ),
                ],
              ),
              if ((onCall != null || onWhatsApp != null) &&
                  item.phone != '-') ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (onCall != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCall,
                          icon: Icon(Icons.phone_rounded, size: 17.sp),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.orangeDeep,
                            side: const BorderSide(color: Color(0xFFE97842)),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                    if (onCall != null && onWhatsApp != null)
                      SizedBox(width: 12.w),
                    if (onWhatsApp != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onWhatsApp,
                          icon: Icon(Icons.chat_rounded, size: 17.sp),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF168553),
                            side: const BorderSide(color: Color(0xFFB7E4C7)),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  static String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not set';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$day $month, ${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  static DateTime? _leadCreatedAt(FollowUpModel item) {
    final raw = item.leadRaw;
    if (raw == null) return item.lastContactAt;
    for (final key in const ['createdAt', 'created_at', 'addedDate']) {
      final parsed = DateTime.tryParse(raw[key]?.toString() ?? '');
      if (parsed != null) return parsed.toLocal();
    }
    return item.lastContactAt;
  }

  static (Color, Color) _statusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('overdue') || value.contains('breach')) {
      return (const Color(0xFFEF4444), const Color(0xFFFFE8E8));
    }
    if (value.contains('complete') || value.contains('done')) {
      return (AppColors.greenDeep, AppColors.greenBg);
    }
    if (value.contains('schedule') || value.contains('upcoming')) {
      return (AppColors.blueBright, const Color(0xFFEAF2FF));
    }
    return (AppColors.orangeDeep, AppColors.orangeSoft);
  }
}

class _FollowUpCardDetail extends StatelessWidget {
  const _FollowUpCardDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(9.r),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22.sp, color: iconColor),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9.5.sp,
                  color: const Color(0xFF667085),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111A32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FollowUpVerticalDivider extends StatelessWidget {
  const _FollowUpVerticalDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 48.h, color: const Color(0xFFE4E7EC));
}
