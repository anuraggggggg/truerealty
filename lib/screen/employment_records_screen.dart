import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/data/api/api_constants.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/payroll_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum EmploymentRecordType { leave, payslip, holiday }

class EmploymentRecordsScreen extends StatefulWidget {
  const EmploymentRecordsScreen({super.key, required this.type});
  final EmploymentRecordType type;

  @override
  State<EmploymentRecordsScreen> createState() =>
      _EmploymentRecordsScreenState();
}

class _EmploymentRecordsScreenState extends State<EmploymentRecordsScreen> {
  List<Map<String, dynamic>> _records = const [];
  bool _loading = true;
  String? _error;

  String get _title => switch (widget.type) {
    EmploymentRecordType.leave => 'My Leave',
    EmploymentRecordType.payslip => 'My Payslips',
    EmploymentRecordType.holiday => 'Holidays',
  };

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
    dynamic response;
    switch (widget.type) {
      case EmploymentRecordType.leave:
        final user = context.read<AuthProvider>().session?.user ?? const {};
        final employeeId = _read(Map<String, dynamic>.from(user), const [
          'employeeId',
          'id',
          'userId',
        ], '');
        response = await context.read<AttendanceProvider>().fetchLeaves(
          employeeId: employeeId.isEmpty ? null : employeeId,
        );
      case EmploymentRecordType.payslip:
        response = await context.read<PayrollProvider>().fetchPayslips();
      case EmploymentRecordType.holiday:
        response = await context.read<AttendanceProvider>().fetchHolidays(
          year: DateTime.now().year,
        );
    }
    if (!mounted) return;
    setState(() {
      _records = _rows(response?.data);
      _loading = false;
      if (response == null) _error = 'Unable to load $_title.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF103F75),
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back to navigation',
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          _title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 190.h),
                  _EmptyState(
                    message: _error ?? 'No ${_title.toLowerCase()} available.',
                    onRetry: _load,
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: _records.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (_, index) =>
                    _RecordCard(type: widget.type, data: _records[index]),
              ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.type, required this.data});
  final EmploymentRecordType type;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final title = switch (type) {
      EmploymentRecordType.leave => _read(data, const [
        'leaveTypeName',
        'leaveType',
        'type',
        'reason',
      ], 'Leave request'),
      EmploymentRecordType.payslip => _payslipTitle(data),
      EmploymentRecordType.holiday => _read(data, const [
        'name',
        'title',
        'holidayName',
        'occasion',
      ], 'Holiday'),
    };
    final status = _read(data, const [
      'statusName',
      'status',
      'paymentStatus',
    ], type == EmploymentRecordType.holiday ? 'Holiday' : 'Available');
    final details = _details(type, data);
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDDE3EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE4),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  _icon(type),
                  color: const Color(0xFFFF650D),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172033),
                  ),
                ),
              ),
              _StatusChip(status),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 10.h),
          for (final detail in details)
            Padding(
              padding: EdgeInsets.only(bottom: 7.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 90.w,
                    child: Text(
                      detail.$1,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      detail.$2,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF26334A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (type == EmploymentRecordType.payslip) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _downloadPayslip(context, data),
                icon: Icon(Icons.download_outlined, size: 18.sp),
                label: const Text('Download Payslip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF103F75),
                  side: const BorderSide(color: Color(0xFF103F75)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadPayslip(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    var url = _payslipUrl(data);
    if (url.isEmpty) {
      final id = _read(data, const ['id', '_id', 'payslipId', 'payrollId'], '');
      if (id.isNotEmpty) {
        final response = await context.read<PayrollProvider>().fetchPayslip(id);
        url = _payslipUrl(response?.data);
      }
    }
    if (url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Payslip download is not available.')),
      );
      return;
    }
    final uri = _downloadUri(url);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Invalid payslip download link.')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to download the payslip.')),
      );
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.value);
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF31527C),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 46.sp, color: Colors.grey),
          SizedBox(height: 10.h),
          Text(message, style: GoogleFonts.inter(color: Colors.grey[700])),
          TextButton(onPressed: onRetry, child: const Text('Refresh')),
        ],
      ),
    );
  }
}

List<(String, String)> _details(
  EmploymentRecordType type,
  Map<String, dynamic> data,
) => switch (type) {
  EmploymentRecordType.leave => [
    ('From', _date(_read(data, const ['dateFrom', 'startDate', 'from'], ''))),
    ('To', _date(_read(data, const ['dateTo', 'endDate', 'to'], ''))),
    ('Reason', _read(data, const ['reason', 'remarks', 'notes'], '—')),
  ],
  EmploymentRecordType.payslip => [
    ('Net Pay', _money(_read(data, const ['netPay', 'netSalary'], ''))),
    ('Gross Pay', _money(_read(data, const ['grossPay', 'grossSalary'], ''))),
    ('Generated', _date(_read(data, const ['generatedAt', 'createdAt'], ''))),
  ],
  EmploymentRecordType.holiday => [
    ('Date', _date(_read(data, const ['date', 'holidayDate'], ''))),
    ('Type', _read(data, const ['type', 'holidayType'], 'Public holiday')),
    ('Description', _read(data, const ['description', 'notes'], '—')),
  ],
};

String _payslipTitle(Map<String, dynamic> data) {
  final label = _read(data, const ['periodLabel', 'monthName', 'title'], '');
  if (label.isNotEmpty) return label;
  final month = _read(data, const ['month'], '');
  final year = _read(data, const ['year'], '');
  final value = '$month $year'.trim();
  return value.isEmpty ? 'Payslip' : value;
}

IconData _icon(EmploymentRecordType type) => switch (type) {
  EmploymentRecordType.leave => Icons.beach_access_outlined,
  EmploymentRecordType.payslip => Icons.receipt_long_outlined,
  EmploymentRecordType.holiday => Icons.celebration_outlined,
};

List<Map<String, dynamic>> _rows(Object? source) {
  if (source is List) {
    return source.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'leaves',
      'payslips',
      'holidays',
    ]) {
      final result = _rows(source[key]);
      if (result.isNotEmpty) return result;
    }
  }
  return const [];
}

String _read(Map<String, dynamic> map, List<String> keys, String fallback) {
  for (final key in keys) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty && value != 'null') return value;
  }
  return fallback;
}

String _date(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value.isEmpty ? '—' : value;
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _money(String value) {
  if (value.isEmpty) return '—';
  final amount = num.tryParse(value);
  return amount == null ? value : '₹${amount.toStringAsFixed(0)}';
}

String _payslipUrl(Object? source) {
  if (source is! Map) return '';
  final map = Map<String, dynamic>.from(source);
  final direct = _read(map, const [
    'pdfUrl',
    'payslipUrl',
    'fileUrl',
    'documentUrl',
    'downloadUrl',
    'url',
  ], '');
  if (direct.isNotEmpty) return direct;
  for (final key in const ['payslip', 'file', 'document', 'attachment']) {
    final nested = map[key];
    if (nested is Map) {
      final value = _payslipUrl(nested);
      if (value.isNotEmpty) return value;
    }
  }
  return '';
}

Uri? _downloadUri(String value) {
  final parsed = Uri.tryParse(value.trim());
  if (parsed == null) return null;
  if (parsed.hasScheme) return parsed;
  final base = Uri.tryParse(ApiConstants.baseUrl);
  if (base == null) return parsed;
  return base.resolve(value);
}
