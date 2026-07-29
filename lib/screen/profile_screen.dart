import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/user_profile_model.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/payroll_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _loadingPayslips = false;
  bool _payslipsLoaded = false;
  int _selectedSection = 0;
  List<_EmployeePayslip> _payslips = const [];
  String? _payrollError;
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
    final session = context.read<AuthProvider>().session;
    final employeeId =
        _sessionEmployeeId(session?.user) ?? _sessionEmployeeId(session?.raw);
    if (kDebugMode) {
      debugPrint(
        '[ProfileScreen] authenticated employeeId=${employeeId ?? 'missing'}',
      );
    }
    final response = employeeId == null
        ? await employeeProvider.fetchCurrentEmployee()
        : await employeeProvider.fetchEmployee(employeeId);
    if (!mounted) return;
    final data = _map(response?.data);
    if (kDebugMode) {
      debugPrint('[ProfileScreen] employee API data=$data');
    }
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
    if (profile == null) return;
    if (profile.id.isEmpty) {
      setState(() {
        _loadingAttendance = false;
        _error = 'Employee ID is missing, so attendance cannot be loaded.';
      });
      return;
    }
    setState(() => _loadingAttendance = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.fetchMonthlyAttendance(
      employeeId: profile.id,
      month: _selectedMonth.month,
      year: _selectedMonth.year,
    );
    if (!mounted) return;
    if (response == null || response.data == null) {
      setState(() {
        _loadingAttendance = false;
        _error = provider.error ?? 'We could not load attendance details.';
      });
      return;
    }
    final records = ProfileAttendanceRecord.listFrom(response.data);
    if (kDebugMode) {
      debugPrint(
        '[ProfileScreen] attendance employeeId=${profile.id} '
        'month=${_selectedMonth.month} year=${_selectedMonth.year} '
        'records=${records.length}',
      );
      debugPrint(
        '[ProfileScreen] attendance statuses='
        '${records.map((record) => '${record.date.day}:${record.status}').join(', ')}',
      );
    }
    setState(() {
      _attendance = records;
      _loadingAttendance = false;
      _error = null;
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

  Future<void> _selectSection(int value) async {
    setState(() => _selectedSection = value);
    if (value == 1 && !_payslipsLoaded && !_loadingPayslips) {
      await _loadPayslips();
    }
  }

  Future<void> _loadPayslips() async {
    setState(() {
      _loadingPayslips = true;
      _payrollError = null;
    });
    final provider = context.read<PayrollProvider>();
    final response = await provider.fetchPayslips();
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loadingPayslips = false;
        _payslipsLoaded = true;
        _payrollError = provider.error ?? 'Unable to load payroll history.';
      });
      return;
    }
    final payslips =
        _payslipRows(
            response.data,
          ).whereType<Map>().map(_EmployeePayslip.fromMap).toList()
          ..sort((a, b) => b.period.compareTo(a.period));
    setState(() {
      _payslips = payslips;
      _loadingPayslips = false;
      _payslipsLoaded = true;
    });
  }

  Future<void> _openPayslip(_EmployeePayslip payslip) async {
    final url = payslip.pdfUrl;
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payslip PDF is not available.')),
      );
      return;
    }
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the payslip PDF.')),
      );
    }
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
                onRefresh: () async {
                  await _load();
                  if (_selectedSection == 1) await _loadPayslips();
                },
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
                    _ProfileSectionTabs(
                      selectedIndex: _selectedSection,
                      onSelected: _selectSection,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedSection == 0) ...[
                      _AttendanceSummaryCard(
                        month: _selectedMonth,
                        records: _attendance,
                        loading: _loadingAttendance,
                        onPreviousMonth: () => _changeMonth(-1),
                        onNextMonth: () => _changeMonth(1),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        _InlineError(
                          message: _error!,
                          onRetry: _loadAttendance,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _TodayAttendanceCard(records: _attendance),
                      const SizedBox(height: 16),
                      _AttendanceHistoryCard(
                        month: _selectedMonth,
                        records: _attendance,
                        loading: _loadingAttendance,
                      ),
                    ] else
                      _PayrollHistoryCard(
                        payslips: _payslips,
                        loading: _loadingPayslips,
                        error: _payrollError,
                        onRetry: _loadPayslips,
                        onOpen: _openPayslip,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileSectionTabs extends StatelessWidget {
  const _ProfileSectionTabs({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDCE3EC))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileSectionTab(
              icon: Icons.calendar_month_outlined,
              label: 'Attendance',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _ProfileSectionTab(
              icon: Icons.description_outlined,
              label: 'Payroll History',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTab extends StatelessWidget {
  const _ProfileSectionTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.orangeDeep : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollHistoryCard extends StatelessWidget {
  const _PayrollHistoryCard({
    required this.payslips,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onOpen,
  });

  final List<_EmployeePayslip> payslips;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<_EmployeePayslip> onOpen;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payroll History',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Your generated salary records and payslips.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),
          if (loading)
            const AppListSkeleton(itemCount: 3, itemHeight: 96, gap: 12)
          else if (error != null)
            _InlineError(message: error!, onRetry: onRetry)
          else if (payslips.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE3EC)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 34,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No payroll records available.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < payslips.length; index++) ...[
              _PayslipTile(
                payslip: payslips[index],
                onOpen: () => onOpen(payslips[index]),
              ),
              if (index != payslips.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _PayslipTile extends StatelessWidget {
  const _PayslipTile({required this.payslip, required this.onOpen});

  final _EmployeePayslip payslip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE3EC)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.orangeDeep,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payslip.periodLabel,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      payslip.status.isEmpty ? 'Payslip' : payslip.status,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (payslip.netPay != null)
                Text(
                  _salary(payslip.netPay),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
            ],
          ),
          if (payslip.grossPay != null || payslip.deductions != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PayslipAmount(
                    label: 'Gross',
                    amount: payslip.grossPay,
                  ),
                ),
                Expanded(
                  child: _PayslipAmount(
                    label: 'Deductions',
                    amount: payslip.deductions,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: payslip.pdfUrl.isEmpty ? null : onOpen,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                payslip.pdfUrl.isEmpty ? 'PDF not available' : 'View Payslip',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayslipAmount extends StatelessWidget {
  const _PayslipAmount({required this.label, required this.amount});

  final String label;
  final num? amount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
      ),
      const SizedBox(height: 3),
      Text(
        amount == null ? '-' : _salary(amount),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    ],
  );
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
  const _AttendanceHistoryCard({
    required this.month,
    required this.records,
    required this.loading,
  });

  final DateTime month;
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
          else
            _MonthlyAttendanceCalendar(month: month, records: records),
        ],
      ),
    );
  }
}

class _MonthlyAttendanceCalendar extends StatelessWidget {
  const _MonthlyAttendanceCalendar({
    required this.month,
    required this.records,
  });

  final DateTime month;
  final List<ProfileAttendanceRecord> records;

  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final gridStart = firstDay.subtract(
      Duration(days: firstDay.weekday % DateTime.daysPerWeek),
    );
    final recordsByDay = <String, ProfileAttendanceRecord>{
      for (final record in records) _dayKey(record.date): record,
    };
    final days = List.generate(42, (index) {
      final date = gridStart.add(Duration(days: index));
      return (date: date, record: recordsByDay[_dayKey(date)]);
    });

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD9E2EC)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xFFD9E2EC)),
                verticalInside: BorderSide(color: Color(0xFFD9E2EC)),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                  children: _weekdays
                      .map(
                        (day) => SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              day,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF536783),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                for (var week = 0; week < 6; week++)
                  TableRow(
                    children: [
                      for (var day = 0; day < 7; day++)
                        _AttendanceCalendarDay(
                          date: days[(week * 7) + day].date,
                          record: days[(week * 7) + day].record,
                          isCurrentMonth:
                              days[(week * 7) + day].date.month == month.month,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          child: const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AttendanceLegendItem('Present', _AttendanceTone.present),
              _AttendanceLegendItem('Absent', _AttendanceTone.absent),
              _AttendanceLegendItem('Holiday', _AttendanceTone.holiday),
              _AttendanceLegendItem('Late', _AttendanceTone.late),
              _AttendanceLegendItem('Leave', _AttendanceTone.leave),
            ],
          ),
        ),
      ],
    );
  }

  static String _dayKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';
}

class _AttendanceCalendarDay extends StatelessWidget {
  const _AttendanceCalendarDay({
    required this.date,
    required this.record,
    required this.isCurrentMonth,
  });

  final DateTime date;
  final ProfileAttendanceRecord? record;
  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final cellDate = DateTime(date.year, date.month, date.day);
    final isFutureGenerated =
        cellDate.isAfter(todayDate) &&
        record?.isGenerated == true &&
        record?.checkInAt == null;
    final visibleRecord = isFutureGenerated ? null : record;
    final status = visibleRecord?.status ?? '';
    final tone = _attendanceTone(status);
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return InkWell(
      onTap: visibleRecord == null
          ? null
          : () => _showAttendanceDetails(context, visibleRecord),
      child: Container(
        height: 92,
        padding: const EdgeInsets.fromLTRB(5, 7, 5, 5),
        decoration: BoxDecoration(
          color: isCurrentMonth ? Colors.white : const Color(0xFFF3F6F9),
          border: isToday ? Border.all(color: AppColors.navy, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date.day.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrentMonth
                    ? AppColors.navy
                    : const Color(0xFF94A3B8),
              ),
            ),
            const Spacer(),
            if (!isCurrentMonth || visibleRecord == null)
              Text(
                'No entry',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: const Color(0xFF8CA0BD),
                ),
              )
            else ...[
              _AttendanceDayChip(
                label: _shortAttendanceStatus(status),
                tone: tone,
              ),
              const SizedBox(height: 5),
              Text(
                _calendarRecordDetail(visibleRecord),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _AttendanceTone { present, absent, holiday, late, leave, neutral }

class _AttendancePalette {
  const _AttendancePalette(this.foreground, this.background, this.border);

  final Color foreground;
  final Color background;
  final Color border;
}

_AttendancePalette _attendancePalette(_AttendanceTone tone) {
  return switch (tone) {
    _AttendanceTone.present => const _AttendancePalette(
      Color(0xFF16A05D),
      Color(0xFFECFDF3),
      Color(0xFFA7F3D0),
    ),
    _AttendanceTone.absent => const _AttendancePalette(
      Color(0xFFEF4444),
      Color(0xFFFFF1F2),
      Color(0xFFFECACA),
    ),
    _AttendanceTone.holiday => const _AttendancePalette(
      Color(0xFF3B82F6),
      Color(0xFFEFF6FF),
      Color(0xFFBFDBFE),
    ),
    _AttendanceTone.late => const _AttendancePalette(
      Color(0xFFF59E0B),
      Color(0xFFFFFBEB),
      Color(0xFFFCD34D),
    ),
    _AttendanceTone.leave => const _AttendancePalette(
      Color(0xFF7C3AED),
      Color(0xFFF5F3FF),
      Color(0xFFDDD6FE),
    ),
    _AttendanceTone.neutral => const _AttendancePalette(
      Color(0xFF64748B),
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ),
  };
}

_AttendanceTone _attendanceTone(String status) {
  final value = status.toLowerCase();
  if (value.contains('present')) return _AttendanceTone.present;
  if (value.contains('absent')) return _AttendanceTone.absent;
  if (value.contains('holiday') || value.contains('week off')) {
    return _AttendanceTone.holiday;
  }
  if (value.contains('late') || value.contains('half day')) {
    return _AttendanceTone.late;
  }
  if (value.contains('leave')) return _AttendanceTone.leave;
  return _AttendanceTone.neutral;
}

class _AttendanceDayChip extends StatelessWidget {
  const _AttendanceDayChip({required this.label, required this.tone});

  final String label;
  final _AttendanceTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _attendancePalette(tone);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: palette.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: palette.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceLegendItem extends StatelessWidget {
  const _AttendanceLegendItem(this.label, this.tone);

  final String label;
  final _AttendanceTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _attendancePalette(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: palette.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 9, color: palette.foreground),
          ),
        ],
      ),
    );
  }
}

String _shortAttendanceStatus(String status) {
  final value = status.toLowerCase();
  if (value.contains('not checked')) return 'Not in';
  if (value.contains('half day')) return 'Half day';
  return status;
}

String _calendarRecordDetail(ProfileAttendanceRecord record) {
  if (record.checkInAt != null) return _calendarTime(record.checkInAt!);
  return record.note?.trim().isNotEmpty == true
      ? record.note!
      : 'No attendance';
}

String _calendarTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour >= 12 ? 'pm' : 'am'}';
}

void _showAttendanceDetails(
  BuildContext context,
  ProfileAttendanceRecord record,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) {
      final tone = _attendanceTone(record.status);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_monthName(record.date.month)} ${record.date.day}, '
                      '${record.date.year}',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 104,
                    child: _AttendanceDayChip(label: record.status, tone: tone),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _AttendanceDetailLine(
                label: 'Check in',
                value: record.checkInAt == null
                    ? 'Not recorded'
                    : _calendarTime(record.checkInAt!),
              ),
              _AttendanceDetailLine(
                label: 'Check out',
                value: record.checkOutAt == null
                    ? 'Not recorded'
                    : _calendarTime(record.checkOutAt!),
              ),
              _AttendanceDetailLine(
                label: 'Shift',
                value: record.shiftName ?? 'Not assigned',
              ),
              if (record.isLate)
                _AttendanceDetailLine(
                  label: 'Late by',
                  value: '${record.lateMinutes} minutes',
                ),
              _AttendanceDetailLine(
                label: 'Reason',
                value:
                    record.derivedStatusReason ??
                    record.note ??
                    'No additional details',
              ),
              _AttendanceDetailLine(
                label: 'Record type',
                value: record.isGenerated
                    ? 'System generated'
                    : 'Punch recorded',
                isLast: true,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _AttendanceDetailLine extends StatelessWidget {
  const _AttendanceDetailLine({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
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

class _EmployeePayslip {
  const _EmployeePayslip({
    required this.id,
    required this.period,
    required this.month,
    required this.year,
    required this.status,
    required this.netPay,
    required this.grossPay,
    required this.deductions,
    required this.pdfUrl,
  });

  factory _EmployeePayslip.fromMap(Map<dynamic, dynamic> value) {
    final map = Map<String, dynamic>.from(value);
    final nested = map['payslip'] is Map
        ? Map<String, dynamic>.from(map['payslip'] as Map)
        : const <String, dynamic>{};
    String read(List<String> keys) {
      for (final source in [map, nested]) {
        for (final key in keys) {
          final value = source[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString().trim();
          }
        }
      }
      return '';
    }

    num? number(List<String> keys) {
      final value = read(keys).replaceAll(',', '');
      return num.tryParse(value);
    }

    final rawMonth = read(const ['month', 'payrollMonth', 'salaryMonth']);
    final rawYear = read(const ['year', 'payrollYear', 'salaryYear']);
    final month = _payslipMonth(rawMonth);
    final year = int.tryParse(rawYear) ?? 0;
    final date = _payslipDate(
      read(const [
        'period',
        'payPeriod',
        'payrollDate',
        'generatedAt',
        'createdAt',
      ]),
    );
    final resolvedMonth = month > 0 ? month : date?.month ?? 1;
    final resolvedYear = year > 0 ? year : date?.year ?? 1970;
    return _EmployeePayslip(
      id: read(const ['id', '_id', 'payslipId', 'payrollId']),
      period: DateTime(resolvedYear, resolvedMonth),
      month: resolvedMonth,
      year: resolvedYear,
      status: read(const ['status', 'payrollStatus', 'paymentStatus']),
      netPay: number(const [
        'netPay',
        'netSalary',
        'netAmount',
        'payableAmount',
      ]),
      grossPay: number(const [
        'grossPay',
        'grossSalary',
        'grossAmount',
        'totalEarnings',
      ]),
      deductions: number(const [
        'deductions',
        'totalDeductions',
        'deductionAmount',
      ]),
      pdfUrl: read(const [
        'pdfUrl',
        'payslipUrl',
        'fileUrl',
        'documentUrl',
        'downloadUrl',
        'url',
      ]),
    );
  }

  final String id;
  final DateTime period;
  final int month;
  final int year;
  final String status;
  final num? netPay;
  final num? grossPay;
  final num? deductions;
  final String pdfUrl;

  String get periodLabel =>
      year <= 1970 ? 'Payroll record' : '${_monthName(month)} $year';
}

List<dynamic> _payslipRows(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'payslips',
      'payroll',
      'items',
      'results',
      'rows',
      'data',
    ]) {
      final value = source[key];
      if (value is List) return value;
      final nested = _payslipRows(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

int _payslipMonth(String value) {
  if (value.trim().isEmpty) return 0;
  final numeric = int.tryParse(value);
  if (numeric != null && numeric >= 1 && numeric <= 12) return numeric;
  final normalized = value.trim().toLowerCase();
  const months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];
  for (var index = 0; index < months.length; index++) {
    if (months[index].startsWith(normalized) ||
        normalized.startsWith(months[index].substring(0, 3))) {
      return index + 1;
    }
  }
  return 0;
}

DateTime? _payslipDate(String value) {
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _sessionEmployeeId(Object? source, [int depth = 0]) {
  if (source == null || depth > 5) return null;
  if (source is Map) {
    for (final key in const ['employeeId', 'id', 'userId']) {
      final value = source[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    for (final key in const ['employee', 'user', 'profile', 'data', 'result']) {
      final value = _sessionEmployeeId(source[key], depth + 1);
      if (value != null) return value;
    }
  }
  return null;
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
