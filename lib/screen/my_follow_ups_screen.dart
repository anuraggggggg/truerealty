import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';

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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: slots.length > 4 ? 4 : slots.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.softBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      slots[index].key,
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
                          '${slots[index].value}',
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
  const _FollowUpsListSection({required this.followUps});
  final List<_TelecallerFollowUpData> followUps;

  @override
  Widget build(BuildContext context) {
    final visibleFollowUps = followUps.take(4).toList(growable: false);
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
              for (var i = 0; i < visibleFollowUps.length; i++) ...[
                _FollowUpRow(
                  name: visibleFollowUps[i].name,
                  project: visibleFollowUps[i].project,
                  status: visibleFollowUps[i].status,
                  time: visibleFollowUps[i].time,
                  avatarBg: visibleFollowUps[i].avatarBg,
                  avatarColor: visibleFollowUps[i].avatarColor,
                  statusBg: visibleFollowUps[i].statusBg,
                  statusColor: visibleFollowUps[i].statusColor,
                ),
                if (i != visibleFollowUps.length - 1)
                  Divider(height: 1, color: const Color(0xFFEAEFF5)),
              ],
            ],
          ),
        ),
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

  return _TelecallerFollowUpData(
    name: read(const ['leadName', 'customerName', 'name', 'lead']),
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
              SizedBox(
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
