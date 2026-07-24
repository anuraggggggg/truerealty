import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';

class SiteVisitDetailsScreen extends StatefulWidget {
  const SiteVisitDetailsScreen({super.key});

  static const Color _bg = Color(0xFFF8FAFE);
  static const Color _cardBorder = Color(0xFFDCE6F3);
  static const Color _title = Color(0xFF0F2B57);
  static const Color _body = Color(0xFF667085);
  static const Color _muted = Color(0xFF98A2B3);
  static const Color _orange = Color(0xFFFF7315);

  @override
  State<SiteVisitDetailsScreen> createState() => _SiteVisitDetailsScreenState();
}

class _SiteVisitDetailsScreenState extends State<SiteVisitDetailsScreen> {
  static const Color _bg = SiteVisitDetailsScreen._bg;
  static const Color _cardBorder = SiteVisitDetailsScreen._cardBorder;
  static const Color _title = SiteVisitDetailsScreen._title;
  static const Color _body = SiteVisitDetailsScreen._body;
  static const Color _orange = SiteVisitDetailsScreen._orange;

  String _selectedStatus = 'All';
  String? _selectedExecutiveId;
  List<_VisitOption> _executives = const [];
  bool _loadingExecutives = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    await Future.wait([
      context.read<SiteVisitProvider>().fetchSiteVisits(
        status: _selectedStatus == 'All' ? null : _selectedStatus.toLowerCase(),
        fieldExecutiveId: _selectedExecutiveId,
      ),
      if (_executives.isEmpty) _loadExecutives(),
    ]);
  }

  Future<void> _loadExecutives() async {
    if (mounted) setState(() => _loadingExecutives = true);
    final response = await context
        .read<SiteVisitProvider>()
        .fetchSiteVisitOptions();
    var options = _namedOptionGroup(response?.data, const [
      'executives',
      'fieldExecutives',
      'employees',
    ]);
    if (options.isEmpty && mounted) {
      final employeeResponse = await context
          .read<EmployeeProvider>()
          .fetchEmployees(role: 'fieldExecutive', status: 'Active', limit: 100);
      options = _visitOptions(employeeResponse?.data);
    }
    if (!mounted) return;
    setState(() {
      _executives = options;
      _loadingExecutives = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SiteVisitProvider>();
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 26.h),
                _buildExecutiveDropdown(),
                SizedBox(height: 12.h),
                _buildFiltersRow(provider),
                SizedBox(height: 12.h),
                _buildCreateButton(context),
                SizedBox(height: 24.h),
                if (provider.isLoading && provider.siteVisits.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (provider.error != null && provider.siteVisits.isEmpty)
                  _ApiErrorCard(message: provider.error!, onRetry: _load)
                else ...[
                  _buildMetricsGrid(provider),
                  SizedBox(height: 16.h),
                  _FieldExecutivesCard(visits: provider.siteVisits),
                  SizedBox(height: 16.h),
                  _VisitsListCard(
                    visits: provider.siteVisits,
                    onRefresh: _load,
                  ),
                  SizedBox(height: 16.h),
                  _TodayUpcomingCard(visits: provider.siteVisits),
                  SizedBox(height: 16.h),
                  _OperationsSnapshotCard(provider: provider),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 22.sp, color: _orange),
            SizedBox(width: 8.w),
            Text(
              'Site Visits',
              style: GoogleFonts.inter(
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                color: _title,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Text(
          'Central visit control for scheduled property tours, re-\nvisits, virtual visits, and field execution.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            height: 1.55,
            fontWeight: FontWeight.w400,
            color: _body,
          ),
        ),
      ],
    );
  }

  Widget _buildExecutiveDropdown() {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedExecutiveId,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        suffixIcon: _loadingExecutives
            ? Padding(
                padding: EdgeInsets.all(13.r),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
      hint: const Text('All Executives'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All Executives'),
        ),
        ..._executives.map(
          (executive) => DropdownMenuItem<String?>(
            value: executive.id,
            child: Text(executive.label, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: _loadingExecutives
          ? null
          : (value) {
              setState(() => _selectedExecutiveId = value);
              _load();
            },
    );
  }

  Widget _buildFiltersRow(SiteVisitProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: provider.isLoading ? null : _load,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 48.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _cardBorder),
            ),
            child: provider.isLoading
                ? Padding(
                    padding: EdgeInsets.all(10.r),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.refresh,
                    size: 22.sp,
                    color: const Color(0xFF344054),
                  ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedStatus = value);
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All visits')),
              PopupMenuItem(value: 'Scheduled', child: Text('Scheduled')),
              PopupMenuItem(value: 'Completed', child: Text('Completed')),
              PopupMenuItem(value: 'Cancelled', child: Text('Cancelled')),
            ],
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    size: 18.sp,
                    color: const Color(0xFF475467),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedStatus == 'All'
                        ? 'Filter by status'
                        : _selectedStatus,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475467),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showCreateSiteVisitSheet(context),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _orange,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: Icon(Icons.add, size: 20.sp, color: Colors.white),
        label: Text(
          'Create Site Visit',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCreateSiteVisitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateSiteVisitSheet(onCreated: _load),
    );
  }

  Widget _buildMetricsGrid(SiteVisitProvider provider) {
    final metrics = [
      _SiteVisitMetric(
        icon: Icons.event_available_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEAF2FF),
        title: 'Total Visits',
        value: '${provider.totalVisits}',
        subtitle: 'All loaded visits',
      ),
      _SiteVisitMetric(
        icon: Icons.access_time_outlined,
        iconColor: const Color(0xFFFF8A26),
        iconBg: const Color(0xFFFFF2E8),
        title: 'Upcoming',
        value: '${provider.upcomingVisits}',
        subtitle: 'Future scheduled visits',
      ),
      _SiteVisitMetric(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFE8FBF3),
        title: 'Completed',
        value: '${provider.completedVisits}',
        subtitle: 'Completed tours',
      ),
      _SiteVisitMetric(
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFF04438),
        iconBg: const Color(0xFFFFEFEF),
        title: 'Cancelled',
        value: '${provider.cancelledVisits}',
        subtitle: 'Needs reschedule review',
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(metric: metrics[0])),
            SizedBox(width: 12.w),
            Expanded(child: _MetricCard(metric: metrics[1])),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(child: _MetricCard(metric: metrics[2])),
            SizedBox(width: 12.w),
            Expanded(child: _MetricCard(metric: metrics[3])),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _SiteVisitMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170.h,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: metric.iconBg,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(metric.icon, size: 17.sp, color: metric.iconColor),
          ),
          SizedBox(height: 16.h),
          Text(
            metric.title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            metric.value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Text(
            metric.subtitle,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: SiteVisitDetailsScreen._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldExecutivesCard extends StatelessWidget {
  const _FieldExecutivesCard({required this.visits});

  final List<SiteVisitModel> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF4ECFF),
              borderRadius: BorderRadius.circular(19.r),
            ),
            child: Icon(
              Icons.groups_2_outlined,
              size: 18.sp,
              color: const Color(0xFF9333EA),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Field Executives',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${visits.map((visit) => visit.executiveId.isNotEmpty ? visit.executiveId : visit.executiveName).where((id) => id.isNotEmpty && id != 'Unassigned').toSet().length}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Assigned this week',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      height: 1.33, // line-height
                      letterSpacing: 0,
                      color: const Color(0xFF74777F),
                    ),
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

class _CreateSiteVisitSheet extends StatefulWidget {
  const _CreateSiteVisitSheet({required this.onCreated});

  final Future<void> Function() onCreated;

  @override
  State<_CreateSiteVisitSheet> createState() => _CreateSiteVisitSheetState();
}

class _CreateSiteVisitSheetState extends State<_CreateSiteVisitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _meetingPointController = TextEditingController();
  final _specialRequestController = TextEditingController();
  List<_VisitOption> _leads = const [];
  List<_VisitOption> _projects = const [];
  List<_VisitOption> _executives = const [];
  List<_VisitOption> _types = const [
    _VisitOption(id: 'SITE_VISIT', label: 'Site Visit'),
    _VisitOption(id: 'REVISIT', label: 'Revisit'),
    _VisitOption(id: 'VIRTUAL_VISIT', label: 'Virtual Visit'),
  ];
  _VisitOption? _lead;
  _VisitOption? _project;
  _VisitOption? _executive;
  _VisitOption? _type;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _duration = 60;
  int _visitors = 1;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = _types.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final results = await Future.wait([
      context.read<LeadProvider>().fetchLeads(page: 1, limit: 100),
      context.read<ProjectProvider>().fetchProjects(),
      context.read<EmployeeProvider>().fetchEmployees(
        role: 'fieldExecutive',
        status: 'Active',
        limit: 100,
      ),
      context.read<SiteVisitProvider>().fetchSiteVisitOptions(),
    ]);
    if (!mounted) return;
    final apiTypes = _namedOptionGroup(results[3]?.data, const [
      'visitTypes',
      'types',
    ]);
    final apiLeads = _namedOptionGroup(results[3]?.data, const [
      'leads',
      'leadOptions',
    ]);
    final apiProjects = _namedOptionGroup(results[3]?.data, const [
      'projects',
      'projectOptions',
    ]);
    final apiExecutives = _namedOptionGroup(results[3]?.data, const [
      'fieldExecutives',
      'executives',
      'employees',
    ]);
    final leads = _visitOptions(results[0]?.data, leadOptions: true);
    final projects = _visitOptions(results[1]?.data);
    final executives = _visitOptions(results[2]?.data);
    setState(() {
      _leads = apiLeads.isNotEmpty ? apiLeads : leads;
      _projects = apiProjects.isNotEmpty ? apiProjects : projects;
      _executives = apiExecutives.isNotEmpty ? apiExecutives : executives;
      if (apiTypes.isNotEmpty) {
        _types = apiTypes;
        _type = apiTypes.first;
      }
      _loading = false;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null && mounted) setState(() => _time = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final response = await context
        .read<SiteVisitProvider>()
        .createSiteVisitFromApi({
          'leadId': _lead!.id,
          'projectId': _project!.id,
          'fieldExecutiveId': _executive!.id,
          'visitType': _type!.id,
          'scheduledAt': scheduledAt.toUtc().toIso8601String(),
          'durationMinutes': _duration,
          'visitors': _visitors,
          if (_meetingPointController.text.trim().isNotEmpty)
            'meetingPoint': _meetingPointController.text.trim(),
          if (_specialRequestController.text.trim().isNotEmpty)
            'specialRequest': _specialRequestController.text.trim(),
        });
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _saving = false;
        _error =
            context.read<SiteVisitProvider>().error ??
            'Unable to schedule this visit.';
      });
      return;
    }
    Navigator.of(context).pop();
    await widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: SiteVisitDetailsScreen._orange,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Site Visit',
                          style: GoogleFonts.inter(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF173A6D),
                          ),
                        ),
                        Text(
                          'Schedule from live CRM records',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VisitDropdown(
                              label: 'Lead *',
                              hint: 'Select lead',
                              value: _lead,
                              items: _leads,
                              onChanged: (value) =>
                                  setState(() => _lead = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Project *',
                              hint: 'Select project',
                              value: _project,
                              items: _projects,
                              onChanged: (value) =>
                                  setState(() => _project = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Assigned Executive *',
                              hint: 'Select field executive',
                              value: _executive,
                              items: _executives,
                              onChanged: (value) =>
                                  setState(() => _executive = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Visit Type *',
                              hint: 'Select visit type',
                              value: _type,
                              items: _types,
                              onChanged: (value) =>
                                  setState(() => _type = value),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _VisitPicker(
                                    label: 'Visit Date *',
                                    value:
                                        '${_twoDigits(_date.day)}-${_twoDigits(_date.month)}-${_date.year}',
                                    icon: Icons.calendar_month_outlined,
                                    onTap: _selectDate,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _VisitPicker(
                                    label: 'Visit Time *',
                                    value: _time.format(context),
                                    icon: Icons.access_time_outlined,
                                    onTap: _selectTime,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _VisitIntDropdown(
                                    label: 'Duration',
                                    value: _duration,
                                    values: const [30, 45, 60, 90, 120],
                                    suffix: 'minutes',
                                    onChanged: (value) =>
                                        setState(() => _duration = value),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _VisitIntDropdown(
                                    label: 'Visitors',
                                    value: _visitors,
                                    values: const [1, 2, 3, 4, 5, 6],
                                    suffix: '',
                                    onChanged: (value) =>
                                        setState(() => _visitors = value),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _meetingPointController,
                              decoration: _visitInputDecoration(
                                'Meeting point',
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _specialRequestController,
                              maxLines: 3,
                              decoration: _visitInputDecoration(
                                'Special request or visit notes',
                              ),
                            ),
                            if (_error != null) ...[
                              SizedBox(height: 12.h),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Color(0xFFD92D20),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFDCE6F3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _loading || _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SiteVisitDetailsScreen._orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.event_available_outlined),
                      label: Text(_saving ? 'Scheduling...' : 'Schedule Visit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Legacy presentation widgets retained for compatibility with older layouts.
// ignore: unused_element
class _SelectedLeadSummaryCard extends StatelessWidget {
  const _SelectedLeadSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'SELECTED LEAD',
                  value: 'Not selected',
                ),
              ),
              Expanded(
                child: _SummaryItem(label: 'PHONE', value: '-'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(label: 'PROJECT', value: 'Not selected'),
              ),
              Expanded(
                child: _SummaryItem(label: 'UNIT', value: '-'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SchedulingTipCard extends StatelessWidget {
  const _SchedulingTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFA64D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
              color: SiteVisitDetailsScreen._orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info, size: 12.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduling Tip',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC05621),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Use the searchable lead field instead of typing IDs. IDs are\nstill sent internally to the API.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC05621),
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

// ignore: unused_element
class _LeadContextCard extends StatelessWidget {
  const _LeadContextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Lead Context',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            'Lead *',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          const _SheetInput(
            value: 'Search lead by name, phone, or lead ID',
            trailingIcon: Icons.keyboard_arrow_down,
            muted: true,
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(label: 'Lead Stage', value: '-'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(label: 'Source', value: '-'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _FieldHandoffCard extends StatelessWidget {
  const _FieldHandoffCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Field Handoff',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Type *',
                  value: 'Site Visit',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Assigned Executive *',
                  value: 'Search executive',
                  trailingIcon: Icons.keyboard_arrow_down,
                  muted: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Date *',
                  value: 'dd-mm-yyyy',
                  muted: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Time *',
                  value: '10:00 AM',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Duration',
                  value: '60 Minutes',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visitors',
                  value: '2 Visitors',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Transport',
                  value: 'Own Vehicle',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Meeting Point',
                  value: 'Sales Gallery',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Special Request',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              'Parking needs, senior citizen assistance,\npreferred sample flat, negotiation context...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SheetFooterBar extends StatelessWidget {
  const _SheetFooterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFDCE6F3))),
      ),
      child: Column(
        children: [
          Text(
            'Required: lead, project, date, time, and executive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF98A2B3),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    side: const BorderSide(color: Color(0xFFB8C5D9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SiteVisitDetailsScreen._orange,
                    minimumSize: Size.fromHeight(42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.event_outlined,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Schedule Visit',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF98A2B3),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        SizedBox(height: 10.h),
        _SheetInput(value: value, muted: muted, trailingIcon: trailingIcon),
      ],
    );
  }
}

class _SheetInput extends StatelessWidget {
  const _SheetInput({
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: muted
                    ? const Color(0xFF667085)
                    : const Color(0xFF111827),
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 18.sp, color: const Color(0xFF667085)),
        ],
      ),
    );
  }
}

class _VisitsListCard extends StatelessWidget {
  const _VisitsListCard({required this.visits, required this.onRefresh});

  final List<SiteVisitModel> visits;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _VisitTab(
                    label: 'All Visits (${visits.length})',
                    selected: true,
                  ),
                  _VisitTab(
                    label:
                        'Upcoming (${visits.where((v) => v.scheduledAt?.isAfter(DateTime.now()) ?? false).length})',
                  ),
                  _VisitTab(
                    label:
                        'Scheduled (${visits.where((v) => v.status.toLowerCase().contains('scheduled')).length})',
                  ),
                  _VisitTab(
                    label:
                        'Completed (${visits.where((v) => v.status.toLowerCase().contains('completed')).length})',
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: const Color(0xFFDCE6F3)),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 34.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: SiteVisitDetailsScreen._cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'View: Table',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18.sp,
                          color: const Color(0xFF667085),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  height: 34.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: SiteVisitDetailsScreen._cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 16.sp,
                        color: const Color(0xFF667085),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Export',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFDCE6F3)),
          if (visits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 38.sp,
                    color: const Color(0xFF98A2B3),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'No site visits found',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475467),
                    ),
                  ),
                ],
              ),
            )
          else
            ...visits.map(
              (visit) => Column(
                children: [
                  _SiteVisitListItem(visit: visit),
                  if (visit != visits.last)
                    Divider(height: 1, color: const Color(0xFFDCE6F3)),
                ],
              ),
            ),
          Divider(height: 1, color: const Color(0xFFDCE6F3)),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        visits.isEmpty
                            ? 'Showing 0 visits'
                            : 'Showing 1 to ${visits.length} of ${visits.length} visits',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ),
                    Row(
                      children: const [
                        _PagerIcon(icon: Icons.chevron_left),
                        _PagerNumber(label: '1', selected: true),
                        _PagerNumber(label: '2'),
                        _PagerNumber(label: '3'),
                        _PagerIcon(icon: Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rows per page',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF667085),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: SiteVisitDetailsScreen._cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '10',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: const Color(0xFF667085),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SiteVisitListItem extends StatelessWidget {
  const _SiteVisitListItem({required this.visit});

  final SiteVisitModel visit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEF8),
                  borderRadius: BorderRadius.circular(23.r),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 22.sp,
                  color: const Color(0xFF173A6D),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.leadName,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF173A6D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Lead ID: ${visit.leadId.isEmpty ? '-' : visit.leadId}',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B95A7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13.sp,
                          color: const Color(0xFF2962FF),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          visit.status,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2962FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.alarm, size: 13.sp, color: Colors.black),
                      SizedBox(width: 4.w),
                      Text(
                        _relativeTime(visit.scheduledAt),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.event_note_outlined,
                label: 'VISIT SCHEDULE',
                title: _formatDate(visit.scheduledAt),
                subtitle: _formatTimeRange(
                  visit.scheduledAt,
                  visit.durationMinutes,
                ),
              ),
              SizedBox(height: 18.h),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'PROJECT & LOCATION',
                title: visit.project,
                subtitle: visit.location.isEmpty
                    ? 'Location not available'
                    : visit.location,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: _MiniInfoBlock(
                  label: 'Executive',
                  leading: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(visit.executiveName),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A6FAF),
                      ),
                    ),
                  ),
                  value: visit.executiveName,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MiniInfoBlock(label: 'Visit Type', value: visit.type),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: const Color(0xFFDCE6F3)),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    side: const BorderSide(color: Color(0xFFB8C5D9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.call_outlined,
                    size: 18.sp,
                    color: const Color(0xFF173A6D),
                  ),
                  label: Text(
                    'Call Lead',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF173A6D),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SiteVisitDetailsScreen._orange,
                    minimumSize: Size.fromHeight(42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.event_outlined,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Reschedule',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayUpcomingCard extends StatelessWidget {
  const _TodayUpcomingCard({required this.visits});

  final List<SiteVisitModel> visits;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming =
        visits
            .where(
              (visit) =>
                  visit.scheduledAt != null &&
                  visit.scheduledAt!.isAfter(now) &&
                  !visit.status.toLowerCase().contains('cancel') &&
                  !visit.status.toLowerCase().contains('completed'),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today & Upcoming',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
          SizedBox(height: 18.h),
          if (upcoming.isEmpty)
            Center(
              child: Text(
                'No upcoming events.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF667085),
                ),
              ),
            )
          else
            ...upcoming
                .take(3)
                .map(
                  (visit) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: SiteVisitDetailsScreen._orange,
                    ),
                    title: Text(
                      visit.leadName,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF173A6D),
                      ),
                    ),
                    subtitle: Text(
                      '${visit.project} • ${_formatDate(visit.scheduledAt)}, ${_formatClock(visit.scheduledAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _OperationsSnapshotCard extends StatelessWidget {
  const _OperationsSnapshotCard({required this.provider});

  final SiteVisitProvider provider;

  @override
  Widget build(BuildContext context) {
    final completionRate = provider.totalVisits == 0
        ? 0.0
        : provider.completedVisits / provider.totalVisits;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operations Snapshot',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Completion Rate',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
              ),
              Text(
                '${(completionRate * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFEFF3F8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF173A6D),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _SnapshotMetricCard(
                  title: 'Active Visits',
                  value: '${provider.activeVisits}',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _SnapshotMetricCard(
                  title: 'Completed',
                  value: '${provider.completedVisits}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetricCard extends StatelessWidget {
  const _SnapshotMetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF667085),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF173A6D),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(icon, size: 16.sp, color: const Color(0xFF667085)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF98A2B3),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF475467),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniInfoBlock extends StatelessWidget {
  const _MiniInfoBlock({
    required this.label,
    required this.value,
    this.leading,
  });

  final String label;
  final String value;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF667085),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 6.w)],
            Expanded(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisitTab extends StatelessWidget {
  const _VisitTab({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 28.w),
      padding: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: selected
            ? const Border(
                bottom: BorderSide(color: Color(0xFF0F2B57), width: 2),
              )
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? const Color(0xFF0F2B57) : const Color(0xFF667085),
        ),
      ),
    );
  }
}

class _PagerIcon extends StatelessWidget {
  const _PagerIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      margin: EdgeInsets.only(left: 6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Icon(icon, size: 16.sp, color: const Color(0xFF98A2B3)),
    );
  }
}

class _PagerNumber extends StatelessWidget {
  const _PagerNumber({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      margin: EdgeInsets.only(left: 6.w),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0F2B57) : Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: selected
              ? const Color(0xFF0F2B57)
              : SiteVisitDetailsScreen._cardBorder,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : const Color(0xFF667085),
        ),
      ),
    );
  }
}

class _SiteVisitMetric {
  const _SiteVisitMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;
}

class _ApiErrorCard extends StatelessWidget {
  const _ApiErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Color(0xFFD92D20)),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFFB42318),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _VisitOption {
  const _VisitOption({
    required this.id,
    required this.label,
    this.subtitle = '',
  });

  final String id;
  final String label;
  final String subtitle;
}

class _VisitDropdown extends StatelessWidget {
  const _VisitDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final _VisitOption? value;
  final List<_VisitOption> items;
  final ValueChanged<_VisitOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_VisitOption>(
      initialValue: value,
      isExpanded: true,
      decoration: _visitInputDecoration(label),
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.subtitle.isEmpty
                    ? item.label
                    : '${item.label} • ${item.subtitle}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) => selected == null ? 'Required' : null,
    );
  }
}

class _VisitPicker extends StatelessWidget {
  const _VisitPicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _visitInputDecoration(label),
        child: Row(
          children: [
            Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
            Icon(icon, size: 18.sp, color: const Color(0xFF667085)),
          ],
        ),
      ),
    );
  }
}

class _VisitIntDropdown extends StatelessWidget {
  const _VisitIntDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: _visitInputDecoration(label),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text('$item${suffix.isEmpty ? '' : ' $suffix'}'),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

InputDecoration _visitInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFDCE6F3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFDCE6F3)),
    ),
  );
}

List<_VisitOption> _visitOptions(Object? source, {bool leadOptions = false}) {
  final options = <_VisitOption>[];
  final ids = <String>{};
  for (final item in _extractVisitList(source)) {
    if (item is String && item.trim().isNotEmpty) {
      final value = item.trim();
      if (ids.add(value)) {
        options.add(_VisitOption(id: value, label: _prettyOption(value)));
      }
      continue;
    }
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final id = _visitText(map, const [
      'id',
      '_id',
      'employeeId',
      'userId',
      'leadId',
      'projectId',
      'value',
    ]);
    var label = _visitText(map, const [
      'name',
      'fullName',
      'displayName',
      'projectName',
      'title',
      'label',
    ]);
    if (label.isEmpty) {
      label = [
        _visitText(map, const ['firstName']),
        _visitText(map, const ['lastName']),
      ].where((part) => part.isNotEmpty).join(' ');
    }
    if (id.isEmpty || label.isEmpty || !ids.add(id)) continue;
    final subtitle = leadOptions
        ? _visitText(map, const ['displayId', 'phone', 'mobile', 'email'])
        : _visitText(map, const [
            'roleName',
            'designation',
            'location',
            'city',
          ]);
    options.add(_VisitOption(id: id, label: label, subtitle: subtitle));
  }
  options.sort((a, b) => a.label.compareTo(b.label));
  return options;
}

String _prettyOption(String value) {
  final words = value
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .trim()
      .split(RegExp(r'\s+'));
  return words
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

List<_VisitOption> _namedOptionGroup(Object? source, List<String> keys) {
  if (source is Map) {
    for (final key in keys) {
      final value = source[key];
      final parsed = _visitOptions(value);
      if (parsed.isNotEmpty) return parsed;
    }
    for (final value in source.values) {
      final parsed = _namedOptionGroup(value, keys);
      if (parsed.isNotEmpty) return parsed;
    }
  }
  return const [];
}

List<dynamic> _extractVisitList(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'leads',
      'projects',
      'employees',
      'fieldExecutives',
      'options',
      'values',
    ]) {
      final nested = _extractVisitList(source[key]);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

String _visitText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _formatDate(DateTime? value) {
  if (value == null) return 'Date not available';
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
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _formatClock(DateTime? value) {
  if (value == null) return 'Time not available';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '$hour:${_twoDigits(value.minute)} ${value.hour >= 12 ? 'PM' : 'AM'}';
}

String _formatTimeRange(DateTime? value, int? durationMinutes) {
  if (value == null) return 'Time not available';
  final end = value.add(Duration(minutes: durationMinutes ?? 60));
  return '${_formatClock(value)} - ${_formatClock(end)}';
}

String _relativeTime(DateTime? value) {
  if (value == null) return 'Time unavailable';
  final difference = value.difference(DateTime.now());
  if (difference.isNegative) {
    final elapsed = difference.abs();
    if (elapsed.inDays > 0) return '${elapsed.inDays}d ago';
    if (elapsed.inHours > 0) return '${elapsed.inHours}h ago';
    return '${elapsed.inMinutes}m ago';
  }
  if (difference.inDays > 0) return 'In ${difference.inDays}d';
  if (difference.inHours > 0) return 'In ${difference.inHours}h';
  return 'In ${difference.inMinutes.clamp(0, 59)}m';
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '--';
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}
