import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool?> showCreateSiteVisitSheet(
  BuildContext context, {
  LeadModel? initialLead,
  Future<void> Function()? onCreated,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CreateSiteVisitSheet(
      initialLead: initialLead,
      onCreated: onCreated ?? () async {},
    ),
  );
}

class SiteVisitDetailsScreen extends StatefulWidget {
  const SiteVisitDetailsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  static const Color _bg = Color(0xFFF8FAFD);
  static const Color _cardBorder = Color(0xFFDCE6F3);
  static const Color _title = Color(0xFF0F2B57);
  static const Color _orange = Color(0xFFFF7315);

  @override
  State<SiteVisitDetailsScreen> createState() => _SiteVisitDetailsScreenState();
}

class _SiteVisitDetailsScreenState extends State<SiteVisitDetailsScreen> {
  static const Color _bg = SiteVisitDetailsScreen._bg;
  static const Color _cardBorder = SiteVisitDetailsScreen._cardBorder;
  static const Color _title = SiteVisitDetailsScreen._title;
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
    if (options.isEmpty &&
        mounted &&
        context.read<AuthProvider>().canViewModule('employees')) {
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
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: _orange,
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 14.h),
                        Divider(
                          color: const Color(0xFFBCC6D6),
                          thickness: 0.8.h,
                          height: 1.h,
                        ),
                        SizedBox(height: 24.h),
                        _buildExecutiveDropdown(),
                        SizedBox(height: 12.h),
                        _buildFiltersRow(provider),
                        SizedBox(height: 12.h),
                        _buildCreateButton(context),
                        SizedBox(height: 24.h),
                        if (provider.isLoading && provider.siteVisits.isEmpty)
                          const AppListSkeleton(itemCount: 4, itemHeight: 154)
                        else if (provider.error != null &&
                            provider.siteVisits.isEmpty)
                          _ApiErrorCard(
                            message: provider.error!,
                            onRetry: _load,
                          )
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Site Visits',
          style: GoogleFonts.inter(
            fontSize: 30.sp,
            fontWeight: FontWeight.w700,
            color: _title,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Central visit control for scheduled property tours, revisits, virtual visits, and field execution.',
          textAlign: TextAlign.left,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            height: 1.33,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF44474E),
          ),
        ),
      ],
    );
    if (widget.onMenuTap == null) return content;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Open navigation',
          visualDensity: VisualDensity.compact,
          onPressed: widget.onMenuTap,
          icon: Icon(Icons.menu_rounded, size: 24.sp, color: _title),
        ),
        SizedBox(width: 6.w),
        Expanded(child: content),
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
    showCreateSiteVisitSheet(context, onCreated: _load);
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
      height: 134.h,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: metric.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(metric.icon, size: 18.sp, color: metric.iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            metric.value,
            style: GoogleFonts.inter(
              fontSize: 23.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF082B63),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                size: 12.sp,
                color: metric.iconColor,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  metric.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: metric.iconColor,
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
  const _CreateSiteVisitSheet({required this.onCreated, this.initialLead});

  final Future<void> Function() onCreated;
  final LeadModel? initialLead;

  @override
  State<_CreateSiteVisitSheet> createState() => _CreateSiteVisitSheetState();
}

class _CreateSiteVisitSheetState extends State<_CreateSiteVisitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _meetingPointController = TextEditingController();
  final _specialRequestController = TextEditingController();
  List<_VisitOption> _leads = const [];
  List<_VisitOption> _projects = const [];
  List<_VisitOption> _units = const [];
  List<_VisitOption> _executives = const [];
  List<_VisitOption> _types = const [
    _VisitOption(id: 'SITE_VISIT', label: 'Site Visit'),
    _VisitOption(id: 'REVISIT', label: 'Revisit'),
    _VisitOption(id: 'VIRTUAL_VISIT', label: 'Virtual Visit'),
  ];
  _VisitOption? _lead;
  _VisitOption? _project;
  _VisitOption? _unit;
  _VisitOption? _executive;
  _VisitOption? _type;
  String _transport = 'Own Vehicle';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _duration = 60;
  int _visitors = 1;
  bool _loading = true;
  bool _loadingUnits = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = _types.first;
    final initialLead = widget.initialLead;
    if (initialLead?.id != null) {
      _lead = _VisitOption(
        id: initialLead!.id!,
        label: '${initialLead.name} · ${initialLead.phone}',
      );
    }
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
      context.read<ProjectProvider>().fetchProjects(status: 'Active'),
      context.read<EmployeeProvider>().fetchEmployees(
        role: 'all',
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
      _projects = projects.isNotEmpty ? projects : apiProjects;
      _executives = executives.isNotEmpty ? executives : apiExecutives;
      final initialId = widget.initialLead?.id;
      if (initialId != null) {
        final matches = _leads.where((option) => option.id == initialId);
        if (matches.isNotEmpty) {
          _lead = matches.first;
        } else if (_lead != null) {
          _leads = [_lead!, ..._leads];
        }
      }
      if (apiTypes.isNotEmpty) {
        _types = apiTypes;
        _type = apiTypes.first;
      }
      if (_projects.isEmpty || _executives.isEmpty) {
        final missing = [
          if (_projects.isEmpty) 'projects',
          if (_executives.isEmpty) 'executives',
        ].join(' and ');
        _error = 'No active $missing were returned by the CRM.';
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

  Future<void> _selectProject(_VisitOption? project) async {
    setState(() {
      _project = project;
      _unit = null;
      _units = const [];
      _loadingUnits = project != null;
      _error = null;
    });
    if (project == null) return;
    final response = await context.read<ProjectProvider>().fetchUnits(
      project.id,
    );
    if (!mounted) return;
    setState(() {
      _units = _visitOptions(response?.data);
      _loadingUnits = false;
      if (response == null) {
        _error =
            context.read<ProjectProvider>().error ??
            'Unable to fetch units for ${project.label}.';
      }
    });
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
          if (_unit != null) 'unitId': _unit!.id,
          'assignedExecutiveId': _executive!.id,
          'visitType': _type!.label,
          'scheduledAt': scheduledAt.toIso8601String(),
          'durationMinutes': _duration,
          'visitorCount': _visitors,
          'status': 'Scheduled',
          'transportMode': _transport,
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
    Navigator.of(context).pop(true);
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
                              onChanged: _selectProject,
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              key: ValueKey(
                                'units-${_project?.id ?? 'no-project'}',
                              ),
                              label: 'Unit',
                              required: false,
                              hint: _loadingUnits
                                  ? 'Loading units...'
                                  : _project == null
                                  ? 'Select a project first'
                                  : _units.isEmpty
                                  ? 'No units available'
                                  : 'Select unit',
                              value: _unit,
                              items: _units,
                              onChanged: _project == null || _loadingUnits
                                  ? null
                                  : (value) => setState(() => _unit = value),
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
                            DropdownButtonFormField<String>(
                              initialValue: _transport,
                              decoration: _visitInputDecoration('Transport'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Own Vehicle',
                                  child: Text('Own Vehicle'),
                                ),
                                DropdownMenuItem(
                                  value: 'Company Vehicle',
                                  child: Text('Company Vehicle'),
                                ),
                                DropdownMenuItem(
                                  value: 'Public Transport',
                                  child: Text('Public Transport'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cab',
                                  child: Text('Cab'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _transport = value ?? 'Own Vehicle',
                              ),
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
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                16.h + MediaQuery.viewPaddingOf(context).bottom,
              ),
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

class _VisitsListCard extends StatefulWidget {
  const _VisitsListCard({required this.visits, required this.onRefresh});

  final List<SiteVisitModel> visits;
  final Future<void> Function() onRefresh;

  @override
  State<_VisitsListCard> createState() => _VisitsListCardState();
}

class _VisitsListCardState extends State<_VisitsListCard> {
  String _selectedTab = 'All';
  bool _tableView = false;
  bool _exporting = false;

  List<SiteVisitModel> get _filteredVisits {
    final now = DateTime.now();
    switch (_selectedTab) {
      case 'Upcoming':
        return widget.visits
            .where(
              (visit) =>
                  visit.scheduledAt?.isAfter(now) == true &&
                  !visit.status.toLowerCase().contains('completed') &&
                  !visit.status.toLowerCase().contains('cancel'),
            )
            .toList();
      case 'Scheduled':
        return widget.visits
            .where((visit) => visit.status.toLowerCase().contains('scheduled'))
            .toList();
      case 'Completed':
        return widget.visits
            .where((visit) => visit.status.toLowerCase().contains('completed'))
            .toList();
      default:
        return widget.visits;
    }
  }

  int _count(String tab) {
    final now = DateTime.now();
    return widget.visits.where((visit) {
      final status = visit.status.toLowerCase();
      return switch (tab) {
        'Upcoming' =>
          visit.scheduledAt?.isAfter(now) == true &&
              !status.contains('completed') &&
              !status.contains('cancel'),
        'Scheduled' => status.contains('scheduled'),
        'Completed' => status.contains('completed'),
        _ => true,
      };
    }).length;
  }

  Future<void> _exportVisits() async {
    final visits = _filteredVisits;
    if (_exporting || visits.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final rows = <List<String>>[
        const [
          'Lead ID',
          'Lead Name',
          'Phone',
          'Project',
          'Location',
          'Visit Type',
          'Status',
          'Executive',
          'Scheduled At',
        ],
        ...visits.map(
          (visit) => [
            visit.leadId,
            visit.leadName,
            visit.phone,
            visit.project,
            visit.location,
            visit.type,
            visit.status,
            visit.executiveName,
            visit.scheduledAt?.toIso8601String() ?? '',
          ],
        ),
      ];
      final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\r\n');
      final directory = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final file = File('${directory.path}/site-visits-$date.csv');
      await file.writeAsString('\uFEFF$csv');
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'TrueRoot Realty site visits',
        text: '${visits.length} site visits exported.',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to export site visits: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  @override
  Widget build(BuildContext context) {
    final visits = _filteredVisits;
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
                    label: 'All Visits (${widget.visits.length})',
                    selected: _selectedTab == 'All',
                    onTap: () => setState(() => _selectedTab = 'All'),
                  ),
                  _VisitTab(
                    label: 'Upcoming (${_count('Upcoming')})',
                    selected: _selectedTab == 'Upcoming',
                    onTap: () => setState(() => _selectedTab = 'Upcoming'),
                  ),
                  _VisitTab(
                    label: 'Scheduled (${_count('Scheduled')})',
                    selected: _selectedTab == 'Scheduled',
                    onTap: () => setState(() => _selectedTab = 'Scheduled'),
                  ),
                  _VisitTab(
                    label: 'Completed (${_count('Completed')})',
                    selected: _selectedTab == 'Completed',
                    onTap: () => setState(() => _selectedTab = 'Completed'),
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
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _tableView = !_tableView),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(44.h),
                      alignment: Alignment.centerLeft,
                      side: const BorderSide(
                        color: SiteVisitDetailsScreen._cardBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: Icon(
                      _tableView
                          ? Icons.view_agenda_outlined
                          : Icons.table_rows_outlined,
                      size: 18.sp,
                    ),
                    label: Text(_tableView ? 'View: Cards' : 'View: Table'),
                  ),
                ),
                SizedBox(width: 10.w),
                OutlinedButton.icon(
                  onPressed: visits.isEmpty || _exporting
                      ? null
                      : _exportVisits,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 44.h),
                    side: const BorderSide(
                      color: SiteVisitDetailsScreen._cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  icon: _exporting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.download_outlined, size: 16.sp),
                  label: Text(_exporting ? 'Exporting' : 'Export'),
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
          else if (_tableView)
            _SiteVisitsTable(visits: visits)
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteVisitsTable extends StatelessWidget {
  const _SiteVisitsTable({required this.visits});

  final List<SiteVisitModel> visits;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: DataTable(
        headingTextStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF173A6D),
        ),
        dataTextStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF475467),
        ),
        columns: const [
          DataColumn(label: Text('Lead')),
          DataColumn(label: Text('Project')),
          DataColumn(label: Text('Schedule')),
          DataColumn(label: Text('Executive')),
          DataColumn(label: Text('Status')),
        ],
        rows: visits
            .map(
              (visit) => DataRow(
                cells: [
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        visit.leadName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        visit.project,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text('${visit.date}\n${visit.time}')),
                  DataCell(Text(visit.executiveName)),
                  DataCell(Text(visit.status)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SiteVisitListItem extends StatelessWidget {
  const _SiteVisitListItem({required this.visit});

  final SiteVisitModel visit;

  String get _callNumber {
    final raw = visit.phone.trim();
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return raw.startsWith('+') ? '+$digits' : digits;
  }

  bool get _canCall => _callNumber.replaceAll('+', '').length >= 7;

  Future<void> _callLead(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _callNumber);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final supported = await canLaunchUrl(uri);
      if (!supported) {
        if (context.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('No phone dialer is available on this device.'),
            ),
          );
        }
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Unable to open the phone dialer.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        final needsRestart = error.toString().contains(
          'MissingPluginException',
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              needsRestart
                  ? 'Please fully restart the app to enable phone calls.'
                  : 'Unable to call this lead: $error',
            ),
          ),
        );
      }
    }
  }

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
        if (_canCall) ...[
          Divider(height: 1, color: const Color(0xFFDCE6F3)),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _callLead(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(44.h),
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
          ),
        ],
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
  const _VisitTab({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        margin: EdgeInsets.only(right: 20.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
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
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = true,
  });

  final String label;
  final String hint;
  final _VisitOption? value;
  final List<_VisitOption> items;
  final ValueChanged<_VisitOption?>? onChanged;
  final bool required;

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
      validator: required && onChanged != null
          ? (selected) => selected == null ? 'Required' : null
          : null,
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
      'unitName',
      'unitNumber',
      'unitNo',
      'number',
      'displayId',
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
      'units',
      'unitOptions',
      'inventory',
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
