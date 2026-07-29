import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';

class TelecallerCommunicationScreen extends StatefulWidget {
  const TelecallerCommunicationScreen({super.key});

  @override
  State<TelecallerCommunicationScreen> createState() =>
      _TelecallerCommunicationScreenState();
}

class _TelecallerCommunicationScreenState
    extends State<TelecallerCommunicationScreen> {
  static const int _pageSize = 8;

  List<_CallRecord> _allCalls = const [];
  bool _loading = true;
  String? _error;
  String _search = '';
  DateTime? _from;
  DateTime? _to;
  int _page = 1;

  List<_CallRecord> get _filteredCalls {
    final query = _search.trim().toLowerCase();
    return _allCalls
        .where((call) {
          final matchesSearch =
              query.isEmpty ||
              call.leadName.toLowerCase().contains(query) ||
              call.mobile.toLowerCase().contains(query) ||
              call.project.toLowerCase().contains(query);
          final localDate = call.scheduledAt?.toLocal();
          final matchesFrom =
              _from == null ||
              localDate == null ||
              !localDate.isBefore(
                DateTime(_from!.year, _from!.month, _from!.day),
              );
          final matchesTo =
              _to == null ||
              localDate == null ||
              localDate.isBefore(DateTime(_to!.year, _to!.month, _to!.day + 1));
          return matchesSearch && matchesFrom && matchesTo;
        })
        .toList(growable: false);
  }

  int get _totalPages {
    final count = _filteredCalls.length;
    return count == 0 ? 1 : (count / _pageSize).ceil();
  }

  List<_CallRecord> get _visibleCalls {
    final calls = _filteredCalls;
    final start = (_page - 1) * _pageSize;
    if (start >= calls.length) return const [];
    final end = (start + _pageSize).clamp(0, calls.length);
    return calls.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCalls());
  }

  Future<void> _loadCalls() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final provider = context.read<LeadProvider>();
    final response = await provider.fetchFollowUps(
      page: 1,
      limit: 500,
      type: 'Call',
      status: 'completed',
    );
    if (!mounted) return;
    final calls =
        response == null
              ? const <_CallRecord>[]
              : _apiRows(
                  response.data,
                ).whereType<Map>().map(_CallRecord.fromMap).toList()
          ..sort((a, b) {
            final left = a.completedAt ?? a.scheduledAt;
            final right = b.completedAt ?? b.scheduledAt;
            if (left == null && right == null) return 0;
            if (left == null) return 1;
            if (right == null) return -1;
            return right.compareTo(left);
          });
    setState(() {
      _allCalls = calls;
      _page = 1;
      _error = response == null
          ? provider.error ?? 'Unable to load completed calls.'
          : null;
      _loading = false;
    });
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_CallFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CallFiltersSheet(
        initialSearch: _search,
        initialFrom: _from,
        initialTo: _to,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _search = result.search;
      _from = result.from;
      _to = result.to;
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uniqueLeads = _allCalls.map((call) => call.leadId).toSet().length;
    final reminders = _allCalls.where((call) => call.setReminder).length;
    final withNotes = _allCalls.where((call) => call.notes.isNotEmpty).length;
    final projects = _allCalls
        .map((call) => call.project)
        .where((value) => value.isNotEmpty)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          'Call History',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadCalls,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCalls,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
          children: [
            Text(
              'Track completed customer call activities.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            _DateRangeCard(calls: _allCalls),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openFilters,
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(
                  _search.isEmpty && _from == null && _to == null
                      ? 'Filters'
                      : 'Filters applied',
                ),
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.5,
              children: [
                _MetricCard(
                  label: 'Completed Calls',
                  value: '${_allCalls.length}',
                  icon: Icons.call_rounded,
                  color: const Color(0xFF2563EB),
                ),
                _MetricCard(
                  label: 'Leads Contacted',
                  value: '$uniqueLeads',
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF10B981),
                ),
                _MetricCard(
                  label: 'Reminders Set',
                  value: '$reminders',
                  icon: Icons.notifications_active_outlined,
                  color: const Color(0xFFF97316),
                ),
                _MetricCard(
                  label: 'Calls With Notes',
                  value: '$withNotes',
                  icon: Icons.notes_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                _MetricCard(
                  label: 'Projects',
                  value: '$projects',
                  icon: Icons.apartment_rounded,
                  color: const Color(0xFF0891B2),
                ),
                _MetricCard(
                  label: 'Filtered Results',
                  value: '${_filteredCalls.length}',
                  icon: Icons.filter_list_rounded,
                  color: const Color(0xFF475569),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _MessageCard(
                message: _error!,
                action: TextButton(
                  onPressed: _loadCalls,
                  child: const Text('Retry'),
                ),
              )
            else if (_visibleCalls.isEmpty)
              const _MessageCard(message: 'No completed call records found.')
            else ...[
              Text(
                'Completed Calls',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 10.h),
              for (final call in _visibleCalls) ...[
                _CallRecordCard(call: call),
                SizedBox(height: 12.h),
              ],
              _Pagination(
                page: _page,
                totalPages: _totalPages,
                onChanged: (value) => setState(() => _page = value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.calls});

  final List<_CallRecord> calls;

  @override
  Widget build(BuildContext context) {
    final dates =
        calls
            .map((call) => call.completedAt ?? call.scheduledAt)
            .whereType<DateTime>()
            .toList()
          ..sort();
    final label = dates.isEmpty
        ? 'No call dates available'
        : '${_formatDate(dates.first)} - ${_formatDate(dates.last)}';
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B)),
          SizedBox(width: 10.w),
          Expanded(child: Text(label, style: GoogleFonts.inter())),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22.sp),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallRecordCard extends StatelessWidget {
  const _CallRecordCard({required this.call});

  final _CallRecord call;

  @override
  Widget build(BuildContext context) {
    final displayDate = call.completedAt ?? call.scheduledAt;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEAF2FF),
                child: Text(
                  call.initials,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.leadName,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    if (call.mobile.isNotEmpty)
                      Text(
                        call.mobile,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              _StatusChip(label: call.status),
            ],
          ),
          if (call.project.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _InfoRow(icon: Icons.apartment_rounded, text: call.project),
          ],
          if (displayDate != null) ...[
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.schedule_rounded,
              text: '${_formatDate(displayDate)} • ${_formatTime(displayDate)}',
            ),
          ],
          if (call.notes.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              call.notes,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                height: 1.4,
                color: const Color(0xFF475569),
              ),
            ),
          ],
          SizedBox(height: 10.h),
          Text(
            'ID: ${call.id}',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
      SizedBox(width: 7.w),
      Expanded(
        child: Text(text, style: GoogleFonts.inter(fontSize: 13.sp)),
      ),
    ],
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: const Color(0xFFEAFBF0),
      borderRadius: BorderRadius.circular(999.r),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF059669),
      ),
    ),
  );
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.onChanged,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: page > 1 ? () => onChanged(page - 1) : null,
        icon: const Icon(Icons.chevron_left),
      ),
      Text(
        '$page of $totalPages',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      IconButton(
        onPressed: page < totalPages ? () => onChanged(page + 1) : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(28.r),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        action ?? const SizedBox.shrink(),
      ],
    ),
  );
}

class _CallFiltersSheet extends StatefulWidget {
  const _CallFiltersSheet({
    required this.initialSearch,
    required this.initialFrom,
    required this.initialTo,
  });

  final String initialSearch;
  final DateTime? initialFrom;
  final DateTime? initialTo;

  @override
  State<_CallFiltersSheet> createState() => _CallFiltersSheetState();
}

class _CallFiltersSheetState extends State<_CallFiltersSheet> {
  late final TextEditingController _searchController;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
    _from = widget.initialFrom;
    _to = widget.initialTo;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool from) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (from ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (from) {
        _from = selected;
      } else {
        _to = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Filter calls',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Lead, mobile, or project',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text(
                      _from == null ? 'From date' : _formatDate(_from!),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text(_to == null ? 'To date' : _formatDate(_to!)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    const _CallFilter(search: '', from: null, to: null),
                  ),
                  child: const Text('Reset'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _CallFilter(
                      search: _searchController.text,
                      from: _from,
                      to: _to,
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _CallFilter {
  const _CallFilter({
    required this.search,
    required this.from,
    required this.to,
  });

  final String search;
  final DateTime? from;
  final DateTime? to;
}

class _CallRecord {
  const _CallRecord({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.mobile,
    required this.project,
    required this.status,
    required this.notes,
    required this.setReminder,
    required this.scheduledAt,
    required this.completedAt,
  });

  factory _CallRecord.fromMap(Map<dynamic, dynamic> value) {
    final map = Map<String, dynamic>.from(value);
    final lead = map['lead'] is Map
        ? Map<String, dynamic>.from(map['lead'] as Map)
        : const <String, dynamic>{};
    final requirement = lead['requirement'] is Map
        ? Map<String, dynamic>.from(lead['requirement'] as Map)
        : const <String, dynamic>{};
    String read(Map<String, dynamic> source, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value is Map) {
          final nested = value['name'] ?? value['title'];
          if (nested != null) return nested.toString();
        } else if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    return _CallRecord(
      id: read(map, const ['id']),
      leadId: read(map, const ['leadId']),
      leadName:
          read(lead, const ['name', 'leadName', 'customerName']).isNotEmpty
          ? read(lead, const ['name', 'leadName', 'customerName'])
          : read(map, const ['leadName']),
      mobile: read(lead, const ['mobile', 'phone', 'number']),
      project:
          read(lead, const [
            'projectName',
            'project',
            'preferredProject',
          ]).isNotEmpty
          ? read(lead, const ['projectName', 'project', 'preferredProject'])
          : read(requirement, const ['preferredProject', 'preferredProjectId']),
      status: read(map, const ['status', 'statusId']),
      notes: read(map, const ['notes', 'remarks', 'nextAction']),
      setReminder:
          map['setReminder'] == true || map['remindTelecaller'] == true,
      scheduledAt: _parseDate(map['scheduledAt']),
      completedAt: _parseDate(map['completedAt']),
    );
  }

  final String id;
  final String leadId;
  final String leadName;
  final String mobile;
  final String project;
  final String status;
  final String notes;
  final bool setReminder;
  final DateTime? scheduledAt;
  final DateTime? completedAt;

  String get initials {
    final parts = leadName
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .take(2);
    final value = parts.map((part) => part[0].toUpperCase()).join();
    return value.isEmpty ? '?' : value;
  }
}

List<dynamic> _apiRows(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const ['data', 'items', 'results', 'followUps']) {
      final value = source[key];
      if (value is List) return value;
      final nested = _apiRows(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String _formatDate(DateTime value) {
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
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')} '
      '${months[local.month - 1]} ${local.year}';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14.r),
  border: Border.all(color: const Color(0xFFDDE4EE)),
  boxShadow: const [
    BoxShadow(color: Color(0x080F172A), blurRadius: 8, offset: Offset(0, 2)),
  ],
);
