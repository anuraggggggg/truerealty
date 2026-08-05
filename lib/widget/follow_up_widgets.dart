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
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
  const FollowUpMetricCard({
    super.key,
    required this.data,
    this.onTap,
  });

  final FollowUpMetricCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: FollowUpSectionCard(
          padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              SizedBox(height: 10.h),
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
    final typeColors = _typeColors(item.leadType);
    final leadStatusColors = _leadStatusColors(item.leadStatus);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: FollowUpSectionCard(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFFFFF1E8),
                    child: Text(
                      _initials(item.leadName),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orangeDeep,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.leadName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.phone,
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
                  if (onMore != null) ...[
                    SizedBox(width: 2.w),
                    IconButton(
                      onPressed: onMore,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                item.project,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                item.propertyLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  FollowUpStatusChip(
                    label: item.source,
                    foreground: AppColors.textSecondary,
                    background: const Color(0xFFF1F5F9),
                  ),
                  FollowUpStatusChip(
                    label: item.leadStatus,
                    foreground: leadStatusColors.$1,
                    background: leadStatusColors.$2,
                  ),
                  if (item.leadType.trim().isNotEmpty && item.leadType != '-')
                    FollowUpStatusChip(
                      label: item.leadType,
                      foreground: typeColors.$1,
                      background: typeColors.$2,
                      borderColor: typeColors.$1.withValues(alpha: 0.35),
                    ),
                  FollowUpStatusChip(
                    label: item.type,
                    foreground: AppColors.blueBright,
                    background: const Color(0xFFEAF2FF),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFE6ECF4)),
              SizedBox(height: 12.h),
              _MetaRow(
                icon: Icons.person_outline_rounded,
                label: 'Executive',
                value: item.assignedToName,
              ),
              SizedBox(height: 8.h),
              _MetaRow(
                icon: Icons.event_outlined,
                label: 'Follow-up',
                value: _formatDateTime(item.scheduledAt),
              ),
              SizedBox(height: 8.h),
              _MetaRow(
                icon: Icons.history_rounded,
                label: 'Last contact',
                value: _formatDateTime(item.lastContactAt),
                trailing: item.isOverdue
                    ? FollowUpStatusChip(
                        label: 'Overdue',
                        foreground: const Color(0xFFEF4444),
                        background: const Color(0xFFFFE8E8),
                      )
                    : null,
              ),
              SizedBox(height: 8.h),
              _MetaRow(
                icon: Icons.notes_rounded,
                label: 'Remark',
                value: (item.notes?.trim().isNotEmpty == true)
                    ? item.notes!.trim()
                    : (item.nextAction?.trim().isNotEmpty == true)
                    ? item.nextAction!.trim()
                    : 'No remarks added',
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
                          icon: Icon(Icons.call_outlined, size: 18.sp),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.orangeDeep,
                            side: const BorderSide(color: Color(0xFFFFD8C2)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                        ),
                      ),
                    if (onCall != null && onWhatsApp != null)
                      SizedBox(width: 12.w),
                    if (onWhatsApp != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onWhatsApp,
                          icon: Icon(Icons.chat_outlined, size: 18.sp),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF168553),
                            side: const BorderSide(color: Color(0xFFB7E4C7)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
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

  static (Color, Color) _typeColors(String type) {
    final value = type.toLowerCase();
    if (value.contains('hot')) {
      return (const Color(0xFFDC2626), const Color(0xFFFFE8E8));
    }
    if (value.contains('warm')) {
      return (const Color(0xFF16A34A), const Color(0xFFE8F8EC));
    }
    if (value.contains('cold')) {
      return (AppColors.blueBright, const Color(0xFFEAF2FF));
    }
    return (AppColors.textSecondary, const Color(0xFFF1F5F9));
  }

  static (Color, Color) _leadStatusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('visit')) {
      return (AppColors.blueBright, const Color(0xFFEAF2FF));
    }
    if (value.contains('interest')) {
      return (AppColors.purpleDeep, AppColors.purpleSoft);
    }
    if (value.contains('book')) {
      return (AppColors.greenDeep, AppColors.greenBg);
    }
    return (AppColors.blueBright, const Color(0xFFEAF2FF));
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textTertiary),
        SizedBox(width: 8.w),
        SizedBox(
          width: 88.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
      ],
    );
  }
}
