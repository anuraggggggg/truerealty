import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/user_profile_model.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _profile;
  List<ProfileAttendanceRecord> _attendance = const [];
  late DateTime _selectedMonth;
  bool _loading = true;
  bool _loadingAttendance = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final employeeProvider = context.read<EmployeeProvider>();
    final response = await employeeProvider.fetchCurrentEmployee();
    if (!mounted) return;
    final data = _map(response?.data);
    if (data.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            employeeProvider.error ?? 'We could not load your profile details.';
      });
      return;
    }
    final profile = UserProfileModel.fromJson(data);
    setState(() {
      _profile = profile;
      _loading = false;
    });
    await _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final profile = _profile;
    if (profile == null || profile.id.isEmpty) return;
    setState(() => _loadingAttendance = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.fetchMonthlyAttendance(
      employeeId: profile.id,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );
    if (!mounted) return;
    setState(() {
      _attendance = ProfileAttendanceRecord.listFrom(response?.data);
      _loadingAttendance = false;
      if (response == null) {
        _error = provider.error ?? 'We could not load attendance details.';
      }
    });
  }

  Future<void> _changeMonth(int offset) async {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
      _error = null;
    });
    await _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        foregroundColor: AppColors.navy,
        title: Text(
          'My Profile',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: AppListSkeleton(itemCount: 4, itemHeight: 150, gap: 16),
              )
            : _profile == null
            ? _ProfileError(message: _error, onRetry: _load)
            : RefreshIndicator(
                color: AppColors.orangeDeep,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    _ProfileHeaderCard(
                      profile: _profile!,
                      onEdit: () => Navigator.of(
                        context,
                      ).pushNamed(AppRouter.personalSettings),
                    ),
                    const SizedBox(height: 16),
                    _EmployeeInformationCard(profile: _profile!),
                    const SizedBox(height: 16),
                    _AttendanceSummaryCard(
                      month: _selectedMonth,
                      records: _attendance,
                      loading: _loadingAttendance,
                      onPreviousMonth: () => _changeMonth(-1),
                      onNextMonth: () => _changeMonth(1),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _InlineError(message: _error!, onRetry: _loadAttendance),
                    ],
                    const SizedBox(height: 16),
                    _TodayAttendanceCard(records: _attendance),
                    const SizedBox(height: 16),
                    _AttendanceHistoryCard(
                      records: _attendance,
                      loading: _loadingAttendance,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.onEdit});

  final UserProfileModel profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.avatarBg,
                backgroundImage:
                    profile.imageUrl != null && profile.imageUrl!.isNotEmpty
                    ? NetworkImage(profile.imageUrl!)
                    : null,
                child: profile.imageUrl == null || profile.imageUrl!.isEmpty
                    ? Text(
                        _initials(profile.name),
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.headerBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _readable(profile.role).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.blueBright,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.name,
                      style: GoogleFonts.inter(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.email.isEmpty
                          ? _readable(profile.role)
                          : profile.email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueBright,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeInformationCard extends StatelessWidget {
  const _EmployeeInformationCard({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoData(
        Icons.calendar_month_outlined,
        'Join date',
        _formatDate(profile.joinDate),
      ),
      _InfoData(
        Icons.work_outline,
        'Department',
        profile.department ?? 'Not assigned',
      ),
      _InfoData(
        Icons.schedule_outlined,
        'Employment type',
        profile.employmentType ?? 'Active',
      ),
      _InfoData(
        Icons.currency_rupee,
        'Basic salary',
        _salary(profile.basicSalary),
      ),
      _InfoData(
        Icons.verified_outlined,
        'Employee code',
        profile.employeeCode ?? 'Not available',
      ),
      _InfoData(
        Icons.email_outlined,
        'Work email',
        profile.email.isEmpty ? 'Not available' : profile.email,
      ),
      if (profile.phone != null)
        _InfoData(Icons.phone_outlined, 'Phone', profile.phone!),
      if (profile.address != null)
        _InfoData(Icons.home_outlined, 'Address', profile.address!),
    ];

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.people_outline,
            title: 'Employee information',
            subtitle: 'Employment profile and contact details.',
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _InformationRow(data: item)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _CompactInfoTile(
                  icon: Icons.account_tree_outlined,
                  label: 'Reporting to',
                  value: profile.reportingManager ?? 'Not assigned',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompactInfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Office location',
                  value: profile.officeLocation ?? 'Not assigned',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.month,
    required this.records,
    required this.loading,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime month;
  final List<ProfileAttendanceRecord> records;
  final bool loading;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final present = _count(records, const ['present']);
    final absent = _count(records, const ['absent']);
    final leave = _count(records, const ['leave']);
    final halfDay = _count(records, const ['half day', 'half-day']);
    final late = _count(records, const ['late']);
    final workingTotal = present + absent + leave + halfDay + late;
    final percentage = workingTotal == 0
        ? 0
        : (((present + halfDay * .5) / workingTotal) * 100).round();

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_monthName(month.month)} ${month.year} Summary',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Previous month',
                onPressed: loading ? null : onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: loading ? null : onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: 12),
            const AppSkeleton(height: 154),
          ] else ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.verified_outlined,
                    label: 'Present',
                    value: present,
                    color: AppColors.greenDeep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.person_off_outlined,
                    label: 'Absent',
                    value: absent,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.description_outlined,
                    label: 'Leave',
                    value: leave,
                    color: AppColors.purpleDeep,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.calendar_today_outlined,
                    label: 'Half day',
                    value: halfDay,
                    color: AppColors.blueBright,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Attendance',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '$percentage%',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: percentage / 100,
                backgroundColor: AppColors.inputIconBg,
                color: AppColors.blueBright,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayAttendanceCard extends StatelessWidget {
  const _TodayAttendanceCard({required this.records});

  final List<ProfileAttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    ProfileAttendanceRecord? today;
    for (final record in records) {
      if (_sameDay(record.date, now)) {
        today = record;
        break;
      }
    }
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(now),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _StatusChip(status: today?.status ?? 'No entry'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            today?.shiftName ?? 'Shift information unavailable',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          if (today?.shiftStartMinutes != null &&
              today?.shiftEndMinutes != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_minutesTime(today!.shiftStartMinutes!)} - '
              '${_minutesTime(today.shiftEndMinutes!)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          if (today?.note != null) ...[
            const SizedBox(height: 8),
            Text(
              today!.note!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.orangeDeep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceHistoryCard extends StatelessWidget {
  const _AttendanceHistoryCard({required this.records, required this.loading});

  final List<ProfileAttendanceRecord> records;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            icon: Icons.event_note_outlined,
            title: 'Monthly attendance',
            subtitle: 'Daily attendance and check-in history.',
          ),
          const SizedBox(height: 12),
          if (loading)
            const AppListSkeleton(itemCount: 4, itemHeight: 64, gap: 8)
          else if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No attendance records for this month.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            ...records.map(
              (record) => Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderSoft),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        record.date.day.toString(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_weekday(record.date.weekday)}, '
                            '${_monthName(record.date.month)} ${record.date.day}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _attendanceTime(record),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusChip(status: record.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderCard),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.navy, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({required this.data});

  final _InfoData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 21, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data.value,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
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

class _CompactInfoTile extends StatelessWidget {
  const _CompactInfoTile({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.blueBright),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          Text(
            'Days',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.$1.withValues(alpha: .25)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.$1,
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 48,
              color: AppColors.iconMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Unable to load profile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.orangeDeep),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textBody),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InfoData {
  const _InfoData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

Map<String, dynamic> _map(Object? value) {
  if (value is! Map) return const {};
  final map = Map<String, dynamic>.from(value);
  final nested = map['data'];
  return nested is Map ? Map<String, dynamic>.from(nested) : map;
}

int _count(List<ProfileAttendanceRecord> records, List<String> matches) {
  return records.where((record) {
    final status = record.status.toLowerCase().trim();
    return matches.any((match) => status == match);
  }).length;
}

(Color, Color) _statusColors(String status) {
  final value = status.toLowerCase();
  if (value.contains('present')) {
    return (AppColors.greenDeep, AppColors.greenBg);
  }
  if (value.contains('absent')) {
    return (const Color(0xFFEF4444), const Color(0xFFFFEBEE));
  }
  if (value.contains('holiday')) {
    return (AppColors.blueBright, AppColors.headerBlue);
  }
  if (value.contains('leave')) {
    return (AppColors.purpleDeep, AppColors.purpleSoft);
  }
  if (value.contains('late') || value.contains('half')) {
    return (AppColors.orangeDeep, AppColors.orangeSoft);
  }
  return (AppColors.textTertiary, AppColors.inputIconBg);
}

String _attendanceTime(ProfileAttendanceRecord record) {
  if (record.checkInAt == null) return record.note ?? 'No attendance';
  final checkIn = _clockTime(record.checkInAt!);
  final checkOut = record.checkOutAt == null
      ? 'Not checked out'
      : _clockTime(record.checkOutAt!);
  return '$checkIn – $checkOut';
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

String _readable(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map(
        (part) =>
            '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Not available';
  return '${date.day.toString().padLeft(2, '0')} '
      '${_monthName(date.month).substring(0, 3)} ${date.year}';
}

String _salary(num? amount) {
  if (amount == null) return 'Not available';
  final digits = amount.round().toString();
  if (digits.length <= 3) return '₹$digits';
  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final chunks = <String>[];
  while (head.length > 2) {
    chunks.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) chunks.insert(0, head);
  return '₹${chunks.join(',')},$tail';
}

String _clockTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour >= 12 ? 'pm' : 'am'}';
}

String _minutesTime(int minutes) {
  final hour24 = minutes ~/ 60;
  final minute = (minutes % 60).toString().padLeft(2, '0');
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$hour:$minute ${hour24 >= 12 ? 'pm' : 'am'}';
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _monthName(int month) {
  return const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

String _weekday(int weekday) {
  return const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}
