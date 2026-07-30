import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Copying necessary data structures for Follow-ups
class _TelecallerFollowUpData {
  const _TelecallerFollowUpData({
    required this.name,
    required this.phone,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String phone;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;
}

class MyFollowUpsScreen extends StatefulWidget {
  const MyFollowUpsScreen({super.key});

  @override
  State<MyFollowUpsScreen> createState() => _MyFollowUpsScreenState();
}

class _MyFollowUpsScreenState extends State<MyFollowUpsScreen> {
  List<_TelecallerFollowUpData> _followUps = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<LeadProvider>();
    final response = await provider.fetchMyFollowUps();
    if (!mounted) return;
    setState(() {
      _followUps = response == null
          ? const []
          : _followUpItems(
              response.data,
            ).map(_followUpFromApi).toList(growable: false);
      _error = response == null
          ? provider.error ?? 'Unable to load follow-ups.'
          : null;
      _loading = false;
    });
  }

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
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.r),
          children: [
            _BestTimeFollowUpSection(followUps: _followUps),
            SizedBox(height: 24.h),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _FollowUpMessage(message: _error!, onRetry: _load)
            else if (_followUps.isEmpty)
              const _FollowUpMessage(message: 'No follow-ups found.')
            else
              _FollowUpsListSection(followUps: _followUps),
          ],
        ),
      ),
    );
  }
}

class _BestTimeFollowUpSection extends StatelessWidget {
  const _BestTimeFollowUpSection({required this.followUps});
  final List<_TelecallerFollowUpData> followUps;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final item in followUps) {
      final slot = item.time.trim();
      if (slot.isNotEmpty && slot != '-') {
        counts[slot] = (counts[slot] ?? 0) + 1;
      }
    }
    final slots = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          if (slots.isEmpty)
            Text(
              'No scheduled time slots yet.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final visibleSlots = slots.take(4).toList(growable: false);
                final cardWidth = (constraints.maxWidth - 10.w) / 2;
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    for (final slot in visibleSlots)
                      SizedBox(
                        width: cardWidth,
                        child: _BestTimeSlotCard(
                          time: slot.key,
                          count: slot.value,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BestTimeSlotCard extends StatelessWidget {
  const _BestTimeSlotCard({required this.time, required this.count});

  final String time;
  final int count;

  @override
  Widget build(BuildContext context) {
    final moment = _FollowUpMoment.parse(time);
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDCE7F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            moment.date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            moment.time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 15.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  '$count scheduled',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
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

class _FollowUpsListSection extends StatelessWidget {
  const _FollowUpsListSection({required this.followUps});
  final List<_TelecallerFollowUpData> followUps;

  @override
  Widget build(BuildContext context) {
    final visibleFollowUps = followUps;
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
        SizedBox(height: 12.h),
        for (var i = 0; i < visibleFollowUps.length; i++) ...[
          _FollowUpRow(
            name: visibleFollowUps[i].name,
            phone: visibleFollowUps[i].phone,
            project: visibleFollowUps[i].project,
            status: visibleFollowUps[i].status,
            time: visibleFollowUps[i].time,
            avatarBg: visibleFollowUps[i].avatarBg,
            avatarColor: visibleFollowUps[i].avatarColor,
            statusBg: visibleFollowUps[i].statusBg,
            statusColor: visibleFollowUps[i].statusColor,
          ),
          if (i != visibleFollowUps.length - 1) SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

List<dynamic> _followUpItems(dynamic source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'followUps',
      'follow_ups',
      'items',
      'results',
      'data',
    ]) {
      final value = source[key];
      if (value is List) return value;
      final nested = _followUpItems(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

_TelecallerFollowUpData _followUpFromApi(dynamic value) {
  final map = value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};
  String read(List<String> keys, [String fallback = '-']) {
    for (final key in keys) {
      final candidate = map[key];
      if (candidate is Map) {
        for (final nested in const ['name', 'title', 'fullName']) {
          if (candidate[nested] != null) return candidate[nested].toString();
        }
      } else if (candidate != null && candidate.toString().trim().isNotEmpty) {
        return candidate.toString();
      }
    }
    return fallback;
  }

  String readPhone() {
    for (final source in [map, map['lead'], map['customer']]) {
      if (source is! Map) continue;
      for (final key in const ['phone', 'mobile', 'contactNumber']) {
        final candidate = source[key]?.toString().trim() ?? '';
        if (candidate.isNotEmpty) return candidate;
      }
    }
    return '';
  }

  return _TelecallerFollowUpData(
    name: read(const ['leadName', 'customerName', 'name', 'lead']),
    phone: readPhone(),
    project: read(const ['projectName', 'project', 'preferredProject']),
    status: read(const ['status', 'leadStatus'], 'Pending'),
    time: read(const ['time', 'scheduledAt', 'followUpDate', 'dueAt']),
    avatarBg: const Color(0xFFEAF2FF),
    avatarColor: const Color(0xFF2563EB),
    statusBg: const Color(0xFFFFF1E7),
    statusColor: const Color(0xFFFF6B00),
  );
}

class _FollowUpMessage extends StatelessWidget {
  const _FollowUpMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 48.h),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _FollowUpMoment {
  const _FollowUpMoment({required this.date, required this.time});

  final String date;
  final String time;

  factory _FollowUpMoment.parse(String source) {
    final parsed = DateTime.tryParse(source.trim())?.toLocal();
    if (parsed == null) {
      return _FollowUpMoment(
        date: source.trim().isEmpty || source == '-' ? 'Date not set' : source,
        time: 'Time not set',
      );
    }
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    return _FollowUpMoment(
      date:
          '${weekdays[parsed.weekday - 1]}, ${parsed.day} ${months[parsed.month - 1]}',
      time: '$hour:$minute ${parsed.hour >= 12 ? 'PM' : 'AM'}',
    );
  }
}

class _FollowUpRow extends StatelessWidget {
  const _FollowUpRow({
    required this.name,
    required this.phone,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String phone;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final moment = _FollowUpMoment.parse(time);
    final canCall = phone.trim().isNotEmpty;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDDE6F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                backgroundColor: avatarBg,
                child: Icon(
                  Icons.person_rounded,
                  size: 20.sp,
                  color: avatarColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: AppColors.slate900,
                      ),
                    ),
                    if (project.trim().isNotEmpty && project != '-') ...[
                      SizedBox(height: 4.h),
                      Text(
                        project,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Material(
                color: canCall
                    ? const Color(0xFFE8F8EC)
                    : const Color(0xFFF1F5F9),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: canCall
                      ? () => launchUrl(Uri(scheme: 'tel', path: phone.trim()))
                      : null,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: Icon(
                      Icons.call_rounded,
                      size: 21.sp,
                      color: canCall
                          ? const Color(0xFF159447)
                          : AppColors.iconMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: Text(
                        '${moment.date} • ${moment.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                constraints: BoxConstraints(maxWidth: 110.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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
