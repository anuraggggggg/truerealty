import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';

class LeadDetailScreenArgs {
  const LeadDetailScreenArgs({this.initialTabIndex = 0, this.lead});

  final int initialTabIndex;
  final LeadModel? lead;
}

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, this.initialTabIndex = 0, this.lead});

  final int initialTabIndex;
  final LeadModel? lead;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late int _selectedTab;
  Map<String, dynamic>? _lead;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex.clamp(0, 2);
    _lead = widget.lead?.raw;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLead());
  }

  Future<void> _loadLead() async {
    final id = widget.lead?.id ?? _string(_lead?['id']);
    if (id == null || id.isEmpty) {
      if (_lead == null && mounted) {
        setState(() => _error = 'Lead details are not available.');
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await context.read<LeadProvider>().fetchLead(id);
    if (!mounted) return;
    final data = response?.data;
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    final nested = map['data'];
    setState(() {
      if (nested is Map) {
        _lead = Map<String, dynamic>.from(nested);
      } else if (map.isNotEmpty) {
        _lead = map;
      }
      _loading = false;
      if (_lead == null) _error = 'Unable to load this lead.';
    });
  }

  Future<void> _editLead(_LeadData data) async {
    final leadId = _string(data.raw['id']) ?? widget.lead?.id;
    if (leadId == null || leadId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lead ID is unavailable.')));
      return;
    }
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLeadSheet(leadId: leadId, lead: data),
    );
    if (updated == true && mounted) await _loadLead();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.lead == null
        ? null
        : <String, dynamic>{
            'id': widget.lead!.id,
            'displayId': widget.lead!.displayId,
            'name': widget.lead!.name,
            'email': widget.lead!.email,
            'mobile': widget.lead!.phone,
            'statusName': widget.lead!.status,
            'stageName': widget.lead!.stage,
            'sourceName': widget.lead!.source,
            'preferredProjectName': widget.lead!.project,
            'preferredLocation': widget.lead!.location,
            'fieldExecutiveName': widget.lead!.assignedTo,
          };
    final data = _LeadData(_lead ?? fallback ?? const {});

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onEdit: () => _editLead(data)),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: _error != null && _lead == null && fallback == null
                  ? _ErrorState(message: _error!, onRetry: _loadLead)
                  : RefreshIndicator(
                      onRefresh: _loadLead,
                      color: AppColors.orangeDeep,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 30.h),
                        child: Column(
                          children: [
                            _SummaryCard(data: data),
                            SizedBox(height: 10.h),
                            _NotesCard(data: data),
                            SizedBox(height: 10.h),
                            _ScoreCard(data: data),
                            SizedBox(height: 10.h),
                            _MetricsCard(data: data),
                            if (data.hasSla) ...[
                              SizedBox(height: 10.h),
                              _SlaCard(data: data),
                            ],
                            SizedBox(height: 12.h),
                            _Tabs(
                              selected: _selectedTab,
                              onChanged: (value) =>
                                  setState(() => _selectedTab = value),
                            ),
                            SizedBox(height: 10.h),
                            if (_selectedTab == 0) ...[
                              _AboutCard(data: data),
                              SizedBox(height: 10.h),
                              _RequirementsCard(data: data),
                              SizedBox(height: 10.h),
                              _TimelineCard(data: data, previewOnly: true),
                              SizedBox(height: 10.h),
                              _FollowUpCard(data: data),
                              SizedBox(height: 10.h),
                              _CommunicationCard(data: data),
                              SizedBox(height: 10.h),
                              _BookingCard(data: data),
                            ] else if (_selectedTab == 1)
                              _TimelineCard(data: data)
                            else
                              _RequirementsCard(data: data),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditLeadSheet extends StatefulWidget {
  const _EditLeadSheet({required this.leadId, required this.lead});

  final String leadId;
  final _LeadData lead;

  @override
  State<_EditLeadSheet> createState() => _EditLeadSheetState();
}

class _EditLeadSheetState extends State<_EditLeadSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _alternateMobile;
  late final TextEditingController _email;
  late final TextEditingController _occupation;
  late final TextEditingController _propertyType;
  late final TextEditingController _configuration;
  late final TextEditingController _budget;
  late final TextEditingController _location;
  late final TextEditingController _remarks;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final raw = widget.lead.raw;
    final requirement = widget.lead.requirement;
    _name = TextEditingController(text: _string(raw['name']) ?? '');
    _mobile = TextEditingController(
      text: _string(raw['mobile'] ?? raw['phone']) ?? '',
    );
    _alternateMobile = TextEditingController(
      text: _string(raw['alternateMobile'] ?? raw['alternateNumber']) ?? '',
    );
    _email = TextEditingController(text: _string(raw['email']) ?? '');
    _occupation = TextEditingController(text: _string(raw['occupation']) ?? '');
    _propertyType = TextEditingController(
      text: _string(requirement['propertyType']) ?? '',
    );
    _configuration = TextEditingController(
      text: _string(requirement['configuration']) ?? '',
    );
    _budget = TextEditingController(
      text: _string(requirement['budgetRange'] ?? requirement['budget']) ?? '',
    );
    _location = TextEditingController(
      text:
          _string(
            requirement['preferredLocation'] ?? raw['preferredLocation'],
          ) ??
          '',
    );
    _remarks = TextEditingController();
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _mobile,
      _alternateMobile,
      _email,
      _occupation,
      _propertyType,
      _configuration,
      _budget,
      _location,
      _remarks,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _input(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 19.sp),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11.r),
        borderSide: BorderSide(color: AppColors.orangeDeep, width: 1.5),
      ),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final requirement = <String, dynamic>{
      ...widget.lead.requirement,
      'propertyType': _propertyType.text.trim(),
      'configuration': _configuration.text.trim(),
      'budgetRange': _budget.text.trim(),
      'preferredLocation': _location.text.trim(),
    };
    final response = await context.read<LeadProvider>().updateLeadFromApi(
      leadId: widget.leadId,
      body: {
        'name': _name.text.trim(),
        'mobile': _mobile.text.trim(),
        'alternateMobile': _alternateMobile.text.trim(),
        'email': _email.text.trim(),
        'occupation': _occupation.text.trim(),
        'requirement': requirement,
        if (_remarks.text.trim().isNotEmpty) 'remarks': _remarks.text.trim(),
      },
    );
    if (!mounted) return;
    if (response != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead details updated successfully.')),
      );
    } else {
      setState(() {
        _saving = false;
        _error = context.read<LeadProvider>().error ?? 'Unable to update lead.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      padding: EdgeInsets.only(bottom: keyboard),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 14.h, 10.w, 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  SizedBox(width: 11.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Lead Details',
                          style: _text(17, FontWeight.w800),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Keep contact and property preferences up to date.',
                          style: _text(
                            10.5,
                            FontWeight.w500,
                            const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact information',
                        style: _text(12, FontWeight.w800),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _name,
                        decoration: _input('Full name', Icons.person_outline),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _mobile,
                        keyboardType: TextInputType.phone,
                        decoration: _input(
                          'Mobile number',
                          Icons.phone_outlined,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Mobile number is required'
                            : null,
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _alternateMobile,
                        keyboardType: TextInputType.phone,
                        decoration: _input(
                          'Alternate mobile',
                          Icons.phone_forwarded_outlined,
                        ),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _input('Email address', Icons.mail_outline),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _occupation,
                        decoration: _input('Occupation', Icons.work_outline),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Property requirements',
                        style: _text(12, FontWeight.w800),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: _propertyType,
                        decoration: _input(
                          'Property type',
                          Icons.apartment_outlined,
                        ),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _configuration,
                        decoration: _input(
                          'Configuration',
                          Icons.grid_view_outlined,
                        ),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _budget,
                        decoration: _input(
                          'Budget range',
                          Icons.currency_rupee_rounded,
                        ),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _location,
                        decoration: _input(
                          'Preferred location',
                          Icons.location_on_outlined,
                        ),
                      ),
                      SizedBox(height: 11.h),
                      TextFormField(
                        controller: _remarks,
                        minLines: 3,
                        maxLines: 5,
                        decoration: _input(
                          'Add note (optional)',
                          Icons.note_alt_outlined,
                          hint: 'Add context for the team',
                        ),
                      ),
                      if (_error != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          _error!,
                          style: _text(11, FontWeight.w600, Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 14.h),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving...' : 'Save Changes'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orangeDeep,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                      ),
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

class _ScheduleFollowUpSheet extends StatefulWidget {
  const _ScheduleFollowUpSheet({required this.leadId, required this.lead});

  final String leadId;
  final _LeadData lead;

  @override
  State<_ScheduleFollowUpSheet> createState() => _ScheduleFollowUpSheetState();
}

class _ScheduleFollowUpSheetState extends State<_ScheduleFollowUpSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nextActionController = TextEditingController();
  final _notesController = TextEditingController();
  final _remarksController = TextEditingController();
  final _types = const ['Call', 'WhatsApp', 'Email', 'SMS'];
  List<_AssigneeOption> _assignees = const [];
  String _type = 'Call';
  String? _assigneeId;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _reminder = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAssignees());
  }

  @override
  void dispose() {
    _nextActionController.dispose();
    _notesController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignees() async {
    final responses = await Future.wait([
      context.read<EmployeeProvider>().fetchEmployees(
        role: 'all',
        status: null,
        limit: 100,
      ),
      context.read<SiteVisitProvider>().fetchSiteVisitOptions(),
    ]);
    if (!mounted) return;
    final employeeMaps = _extractMaps(responses[0]?.data);
    final optionMaps = _extractNamedMaps(responses[1]?.data, const [
      'fieldExecutives',
      'executives',
      'employees',
      'users',
    ]);
    final byId = <String, _AssigneeOption>{};
    for (final item
        in [...employeeMaps, ...optionMaps]
            .map(_AssigneeOption.fromMap)
            .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)) {
      byId[item.id] = item;
    }
    final preferredId = _from(widget.lead.raw, [
      'fieldExecutiveId',
      'telecallerId',
      'ownerId',
      'assignedToId',
    ], '');
    if (preferredId.isNotEmpty && !byId.containsKey(preferredId)) {
      final preferredName = _from(widget.lead.raw, [
        'fieldExecutiveName',
        'telecallerName',
        'ownerName',
        'assignedToName',
      ], '');
      if (preferredName.isNotEmpty) {
        byId[preferredId] = _AssigneeOption(
          id: preferredId,
          name: preferredName,
        );
      }
    }
    final assignees = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    debugPrint(
      '[ScheduleFollowUp] Assignees loaded: employees=${employeeMaps.length}, '
      'options=${optionMaps.length}, usable=${assignees.length}',
    );
    setState(() {
      _assignees = assignees;
      _assigneeId = assignees.any((item) => item.id == preferredId)
          ? preferredId
          : (assignees.isNotEmpty ? assignees.first.id : null);
      _loading = false;
      if (assignees.isEmpty) {
        _error =
            context.read<EmployeeProvider>().error ??
            'Unable to load active assignees.';
      }
    });
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null && mounted) setState(() => _time = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final assignedToId = _assigneeId;
    if (assignedToId == null) {
      setState(() => _error = 'Please select an assignee.');
      return;
    }
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
    final notes = _notesController.text.trim();
    final remarks = _remarksController.text.trim();
    final body = <String, dynamic>{
      'scheduledAt': scheduledAt.toIso8601String(),
      'followUpType': _type,
      'assignedToId': assignedToId,
      'nextAction': _nextActionController.text.trim(),
      'notes': notes,
      'remarks': remarks.isEmpty ? notes : remarks,
      'status': 'Scheduled',
      'setReminder': _reminder,
    };
    debugPrint(
      '[ScheduleFollowUp] POST /leads/${widget.leadId}/follow-ups '
      'payload=$body',
    );
    final response = await context.read<LeadProvider>().createFollowUp(
      leadId: widget.leadId,
      body: body,
    );
    if (!mounted) return;
    if (response == null) {
      final message =
          context.read<LeadProvider>().error ?? 'Unable to schedule follow-up.';
      debugPrint('[ScheduleFollowUp] Failed: $message');
      setState(() {
        _saving = false;
        _error = message;
      });
      return;
    }
    debugPrint('[ScheduleFollowUp] Created successfully: ${response.data}');
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFD8E0EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.orangeDeep, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final navigationInset = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 8.w, 12.h),
              child: Row(
                children: [
                  Icon(Icons.event_note_outlined, color: AppColors.orangeDeep),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule Follow-Up',
                          style: _text(16, FontWeight.w800),
                        ),
                        Text(
                          widget.lead.name,
                          style: _text(10, FontWeight.w500, Colors.grey[700]),
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
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _type,
                              decoration: _decoration('Follow-Up Type *'),
                              items: _types
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _type = value ?? 'Call'),
                            ),
                            SizedBox(height: 13.h),
                            DropdownButtonFormField<String>(
                              initialValue: _assigneeId,
                              isExpanded: true,
                              decoration: _decoration('Assigned To *'),
                              items: _assignees
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(
                                        item.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _assigneeId = value),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                            SizedBox(height: 13.h),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDate,
                                    child: InputDecorator(
                                      decoration: _decoration('Date *'),
                                      child: Text(_formatFollowUpDate(_date)),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickTime,
                                    child: InputDecorator(
                                      decoration: _decoration('Time *'),
                                      child: Text(_time.format(context)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 13.h),
                            TextFormField(
                              controller: _nextActionController,
                              decoration: _decoration(
                                'Next Action *',
                                hint: 'e.g. Meet at the property',
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            SizedBox(height: 13.h),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: _decoration('Notes'),
                            ),
                            SizedBox(height: 13.h),
                            TextFormField(
                              controller: _remarksController,
                              maxLines: 2,
                              decoration: _decoration('Remarks'),
                            ),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Set reminder'),
                              value: _reminder,
                              activeThumbColor: AppColors.orangeDeep,
                              onChanged: (value) =>
                                  setState(() => _reminder = value),
                            ),
                            if (_error != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFD92D20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                16.w,
                11.h,
                16.w,
                14.h + navigationInset,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFDCE1E8))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeDeep,
                        foregroundColor: Colors.white,
                      ),
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.event_available_outlined),
                      label: Text(
                        _saving ? 'Scheduling...' : 'Schedule Follow-Up',
                      ),
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

class _AssigneeOption {
  const _AssigneeOption({required this.id, required this.name});
  final String id;
  final String name;

  factory _AssigneeOption.fromMap(Map<String, dynamic> map) {
    final first = _from(map, ['firstName'], '');
    final last = _from(map, ['lastName'], '');
    return _AssigneeOption(
      id: _from(map, ['id', '_id', 'employeeId', 'userId'], ''),
      name: _from(map, [
        'name',
        'fullName',
        'displayName',
      ], '$first $last'.trim()),
    );
  }
}

List<Map<String, dynamic>> _extractMaps(Object? source) {
  if (source is List) {
    return source.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'employees',
      'users',
    ]) {
      final result = _extractMaps(source[key]);
      if (result.isNotEmpty) return result;
    }
  }
  return const [];
}

List<Map<String, dynamic>> _extractNamedMaps(
  Object? source,
  List<String> keys,
) {
  if (source is! Map) return const [];
  for (final key in keys) {
    final result = _extractMaps(source[key]);
    if (result.isNotEmpty) return result;
  }
  for (final value in source.values) {
    final result = _extractNamedMaps(value, keys);
    if (result.isNotEmpty) return result;
  }
  return const [];
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 21.sp,
                  color: const Color(0xFF0F2B57),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lead Details',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F2B57),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Complete lead overview',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          FilledButton.icon(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 16.sp),
            label: const Text('Edit'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orangeDeep,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27.r,
                backgroundColor: const Color(0xFF0F2B57),
                child: Text(
                  data.initials,
                  style: _text(15, FontWeight.w800, Colors.white),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _text(18, FontWeight.w800),
                    ),
                    Text(
                      '#${data.displayId}',
                      style: _text(
                        12,
                        FontWeight.w600,
                        const Color(0xFF586A91),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _InfoLine(Icons.phone_outlined, data.phone),
          _InfoLine(Icons.mail_outline, data.email),
          _InfoLine(Icons.location_on_outlined, data.location),
          _InfoLine(Icons.campaign_outlined, data.source),
          Divider(height: 24.h, color: const Color(0xFFE4E7EC)),
          _TwoColumns(
            left: [
              ('Assigned To', data.assignedTo),
              ('Created On', data.createdOn),
            ],
            right: [
              ('Status', data.status),
              ('Manager', data.manager),
              ('Last Updated', data.updatedOn),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(Icons.auto_awesome_outlined, 'ALL Lead Score'),
          SizedBox(height: 10.h),
          Center(
            child: SizedBox(
              width: 105.w,
              height: 105.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: (data.score / 100).clamp(0, 1),
                      strokeWidth: 13.w,
                      backgroundColor: const Color(0xFFECEEF1),
                      color: AppColors.orangeDeep,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '${data.score}\n',
                      style: _text(18, FontWeight.w800),
                      children: [
                        TextSpan(
                          text: '/100',
                          style: _text(9, FontWeight.w500, Colors.grey),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(data.scoreLabel, style: _text(13, FontWeight.w800)),
          ),
          SizedBox(height: 4.h),
          Center(
            child: Text(
              'View Scoring Logic',
              style: _text(11, FontWeight.w600, const Color(0xFF385487)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: _TwoColumns(
        left: [
          ('Est. Conversion', data.conversion),
          ('Temperature', data.temperature),
        ],
        right: [
          ('Est. Revenue', data.revenue),
          ('Engagement', data.engagement),
        ],
      ),
    );
  }
}

class _SlaCard extends StatelessWidget {
  const _SlaCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      borderColor: data.slaBreached ? const Color(0xFFF4B4AE) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('SLA Summary', style: _text(14, FontWeight.w800)),
              ),
              _Chip(
                text: data.slaBreached
                    ? 'BREACHED'
                    : data.slaStatus.toUpperCase(),
                danger: data.slaBreached,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            data.slaMessage,
            style: _text(11, FontWeight.w400, Colors.grey[700]),
          ),
          Divider(height: 20.h),
          _TwoColumns(
            left: [('Breach Date', data.slaDate), ('Owner', data.slaOwner)],
            right: [
              ('Response Time', data.responseTime),
              ('Status', data.slaStatus),
            ],
          ),
          SizedBox(height: 12.h),
          _LabelValue('Activity', data.slaActivity),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Overview', 'Activities Timeline', 'Property Preferences'];
    return Row(
      children: List.generate(
        labels.length,
        (index) => Expanded(
          child: InkWell(
            onTap: () => onChanged(index),
            child: Container(
              padding: EdgeInsets.only(bottom: 9.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected == index
                        ? AppColors.orangeDeep
                        : const Color(0xFFDDE1E8),
                    width: selected == index ? 2 : 1,
                  ),
                ),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _text(
                  10,
                  selected == index ? FontWeight.w800 : FontWeight.w600,
                  selected == index ? AppColors.orangeDeep : Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          const _Title(Icons.person_outline, 'About Lead'),
          _DetailRow('Full Name', data.name),
          _DetailRow('Mobile', data.phone),
          _DetailRow('Alternate Number', data.alternatePhone),
          _DetailRow('Email Address', data.email),
          _DetailRow('Occupation', data.occupation),
          _DetailRow('Address', data.location, divider: false),
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(Icons.home_work_outlined, 'Property Requirements'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _Requirement('Property Type', data.propertyType)),
              SizedBox(width: 8.w),
              Expanded(child: _Requirement('Budget Range', data.budget)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _Requirement('Location', data.location)),
              SizedBox(width: 8.w),
              Expanded(child: _Requirement('Project', data.project)),
            ],
          ),
          Divider(height: 22.h),
          _ThreeValues(
            values: [
              ('Carpet Area', data.carpetArea),
              ('Possession', data.possession),
              ('Floor Pref.', data.floor),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.data, this.previewOnly = false});
  final _LeadData data;
  final bool previewOnly;

  @override
  Widget build(BuildContext context) {
    final activities = previewOnly
        ? data.activities.take(1).toList()
        : data.activities;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(Icons.access_time_rounded, 'Activity Timeline'),
          SizedBox(height: 12.h),
          if (activities.isEmpty)
            const _EmptyText('No activity recorded yet')
          else
            ...activities.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 18.sp,
                      color: AppColors.orangeDeep,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: _text(12, FontWeight.w800)),
                          Text(
                            item.date,
                            style: _text(10, FontWeight.w400, Colors.grey),
                          ),
                          if (item.note != '-') ...[
                            SizedBox(height: 6.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(9.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE1E5EB),
                                ),
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                              child: Text(
                                item.note,
                                style: _text(11, FontWeight.w400),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    final followUp = data.nextFollowUp;
    return _Card(
      borderColor: followUp?.overdue == true ? const Color(0xFFF3B1AC) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _Title(Icons.event_outlined, 'Next Follow-up'),
              ),
              if (followUp != null)
                _Chip(
                  text: followUp.overdue
                      ? 'OVERDUE'
                      : followUp.status.toUpperCase(),
                  danger: followUp.overdue,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (followUp == null)
            const _EmptyText('No follow-up scheduled')
          else ...[
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13.sp),
                SizedBox(width: 5.w),
                Text(followUp.date, style: _text(11, FontWeight.w800)),
              ],
            ),
            SizedBox(height: 12.h),
            _TwoColumns(
              left: [
                ('Follow-up Type', followUp.type),
                ('Assigned To', followUp.owner),
              ],
              right: [
                ('Status', followUp.status),
                ('Next Action', followUp.action),
              ],
            ),
            SizedBox(height: 10.h),
            _LabelValue('Notes', followUp.notes),
          ],
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(Icons.note_alt_outlined, 'Notes'),
          SizedBox(height: 14.h),
          if (data.notes.isEmpty)
            const _EmptyText('No internal notes yet')
          else
            ...data.notes.map(
              (note) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text('• $note', style: _text(11, FontWeight.w400)),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommunicationCard extends StatelessWidget {
  const _CommunicationCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Communication Quick View', style: _text(13, FontWeight.w800)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _CountTile('TOTAL CALLS', data.callCount, Icons.phone_outlined),
              _CountTile('WHATSAPP', data.whatsappCount, Icons.chat_outlined),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _CountTile(
                'SITE VISITS',
                data.siteVisitCount,
                Icons.home_outlined,
              ),
              _CountTile('TASKS', data.taskCount, Icons.task_alt_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.data});
  final _LeadData data;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title(Icons.sell_outlined, 'Latest Booking'),
          SizedBox(height: 20.h),
          Center(
            child: data.latestBooking == null
                ? const _EmptyText('No bookings recorded yet')
                : Text(data.latestBooking!, style: _text(12, FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.borderColor});
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor ?? const Color(0xFFE0E4EA)),
      ),
      child: child,
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: const Color(0xFF1F3159)),
        SizedBox(width: 6.w),
        Text(text, style: _text(13, FontWeight.w800)),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.icon, this.value);
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF667085)),
          SizedBox(width: 7.w),
          Expanded(child: Text(value, style: _text(11, FontWeight.w600))),
        ],
      ),
    );
  }
}

class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.left, required this.right});
  final List<(String, String)> left;
  final List<(String, String)> right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ValueColumn(values: left)),
        SizedBox(width: 12.w),
        Expanded(child: _ValueColumn(values: right)),
      ],
    );
  }
}

class _ValueColumn extends StatelessWidget {
  const _ValueColumn({required this.values});
  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < values.length; i++) ...[
          _LabelValue(values[i].$1, values[i].$2),
          if (i != values.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _text(10, FontWeight.w400, Colors.grey[700])),
        SizedBox(height: 3.h),
        Text(value, style: _text(11, FontWeight.w700)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.divider = true});
  final String label;
  final String value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEDF0F3))),
            )
          : null,
      child: Row(
        children: [
          Expanded(child: Text(label, style: _text(10, FontWeight.w400))),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: _text(10, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 62.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E5EB)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _text(9, FontWeight.w400, Colors.grey[700])),
          SizedBox(height: 5.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _text(10, FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ThreeValues extends StatelessWidget {
  const _ThreeValues({required this.values});
  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: values
          .map((value) => Expanded(child: _LabelValue(value.$1, value.$2)))
          .toList(),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile(this.label, this.count, this.icon);
  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE1E5EB)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.orangeDeep),
            SizedBox(width: 7.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _text(8, FontWeight.w500, Colors.grey)),
                Text('$count', style: _text(14, FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, this.danger = false});
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: danger ? const Color(0xFFFFE5E2) : const Color(0xFFFFF0E5),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: _text(
          8,
          FontWeight.w800,
          danger ? const Color(0xFFD92D20) : AppColors.orangeDeep,
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(text, style: _text(11, FontWeight.w400, Colors.grey)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          SizedBox(height: 10.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _LeadData {
  _LeadData(this.raw);
  final Map<String, dynamic> raw;

  Map<String, dynamic> get requirement => _map(raw['requirement']);
  String get name => value(['name'], 'Unknown Lead');
  String get displayId => value(['displayId', 'id'], '—');
  String get email => value(['email'], 'Not captured');
  String get phone {
    final mobile = value(['mobile', 'phone'], 'Not captured');
    final code = value(['mobileCountryCode'], '');
    return mobile == 'Not captured' || mobile.startsWith('+')
        ? mobile
        : '$code $mobile'.trim();
  }

  String get alternatePhone =>
      value(['alternateMobile', 'alternateNumber'], '—');
  String get stage => value(['stageName', 'stage'], 'Not set');
  String get status => value(['statusName', 'status'], 'Not set');
  String get source => value(['sourceName', 'source'], 'Not captured');
  String get location => value([
    'preferredProjectLocation',
    'preferredLocation',
    'location',
  ], _from(requirement, ['preferredLocation', 'location'], 'Not captured'));
  String get project => value([
    'preferredProjectName',
    'projectName',
  ], _from(requirement, ['preferredProjectName'], 'Not captured'));
  String get assignedTo => value([
    'fieldExecutiveName',
    'telecallerName',
    'ownerName',
  ], 'Unassigned');
  String get manager => value(['managerName'], 'Unassigned');
  String get createdOn => _date(value(['createdAt'], ''));
  String get updatedOn => _date(value(['updatedAt'], ''));
  String get occupation => value(['occupation'], 'Not captured');
  String get propertyType =>
      _from(requirement, ['propertyType', 'configuration'], 'Not captured');
  String get budget =>
      _from(requirement, ['budgetRange', 'budget'], 'Not captured');
  String get carpetArea =>
      _from(requirement, ['carpetArea', 'area'], 'Not captured');
  String get possession =>
      _from(requirement, ['possession', 'possessionStatus'], 'Not captured');
  String get floor =>
      _from(requirement, ['floorPreference', 'preferredFloor'], 'Not captured');
  int get score => _number(raw['leadScore']).round().clamp(0, 100);
  String get scoreLabel => value(['leadScoreLabel'], 'Not scored');
  String get temperature =>
      value(['temperatureName', 'temperatureId'], 'Not set');
  String get conversion => value(['estimatedConversion', 'conversion'], '—');
  String get revenue => value(['estimatedRevenue', 'revenue'], '—');
  String get engagement => value(['engagement'], '—');

  List<Map<String, dynamic>> get followUps => _list(raw['followUps']);
  List<Map<String, dynamic>> get activitiesRaw => _list(raw['activities']);
  List<Map<String, dynamic>> get siteVisits => _list(raw['siteVisits']);
  List<Map<String, dynamic>> get tasks => _list(raw['tasks']);
  List<Map<String, dynamic>> get bookings => _list(raw['bookings']);
  List<Map<String, dynamic>> get callLogs => _list(raw['callLogs']);
  List<Map<String, dynamic>> get whatsapp =>
      _list(raw['whatsappLogs'] ?? raw['whatsAppLogs']);

  List<_Activity> get activities {
    final source = activitiesRaw.isNotEmpty ? activitiesRaw : followUps;
    return source.map((item) {
      return _Activity(
        title: _from(item, [
          'title',
          'activityType',
          'type',
          'nextAction',
        ], 'Lead activity'),
        date: _date(
          _from(item, ['createdAt', 'completedAt', 'scheduledAt'], ''),
        ),
        note: _from(item, ['notes', 'description', 'remarks'], '—'),
      );
    }).toList();
  }

  _FollowUp? get nextFollowUp {
    if (followUps.isEmpty) return null;
    final pending = followUps.where((item) {
      final status = _from(item, ['status'], '').toLowerCase();
      return status != 'completed' && status != 'cancelled';
    });
    final item = pending.isNotEmpty ? pending.first : followUps.first;
    final rawDate = _from(item, [
      'scheduledAt',
      'nextFollowUpAt',
      'followUpAt',
    ], value(['nextFollowUpAt'], ''));
    final parsed = DateTime.tryParse(rawDate)?.toLocal();
    return _FollowUp(
      date: _dateTime(rawDate),
      type: _from(item, ['type', 'followUpType'], 'Not set'),
      owner: _from(item, ['assignedToName', 'ownerName'], assignedTo),
      action: _from(item, ['nextAction'], 'Not captured'),
      notes: _from(item, ['notes', 'remarks'], 'No notes'),
      status: _from(item, ['status'], 'Scheduled'),
      overdue: parsed != null && parsed.isBefore(DateTime.now()),
    );
  }

  List<String> get notes => _list(raw['notes'])
      .map((item) => _from(item, ['note', 'content', 'text'], ''))
      .where((item) => item.isNotEmpty)
      .toList();
  int get callCount => callLogs.length;
  int get whatsappCount => whatsapp.length;
  int get siteVisitCount => siteVisits.length;
  int get taskCount => tasks.length;
  String? get latestBooking => bookings.isEmpty
      ? null
      : _from(bookings.first, [
          'displayId',
          'bookingNumber',
          'status',
        ], 'Booking');
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'L';
    return parts.length == 1
        ? parts.first[0].toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get hasSla =>
      raw['sla'] is Map ||
      raw.containsKey('slaStatus') ||
      raw.containsKey('slaBreached');
  Map<String, dynamic> get sla => _map(raw['sla']);
  bool get slaBreached =>
      raw['slaBreached'] == true ||
      sla['breached'] == true ||
      slaStatus.toLowerCase().contains('breach');
  String get slaStatus =>
      value(['slaStatus'], _from(sla, ['status'], 'Active'));
  String get slaMessage => value([
    'slaMessage',
  ], _from(sla, ['message'], 'Operational response and follow-up health.'));
  String get slaDate =>
      _date(value(['slaBreachDate'], _from(sla, ['breachDate'], '')));
  String get responseTime =>
      value(['slaResponseTime'], _from(sla, ['responseTime'], '—'));
  String get slaOwner =>
      value(['slaOwnerName'], _from(sla, ['ownerName'], assignedTo));
  String get slaActivity =>
      value(['slaActivity'], _from(sla, ['activity'], 'Not captured'));

  String value(List<String> keys, [String fallback = '—']) =>
      _from(raw, keys, fallback);
}

class _Activity {
  const _Activity({
    required this.title,
    required this.date,
    required this.note,
  });
  final String title;
  final String date;
  final String note;
}

class _FollowUp {
  const _FollowUp({
    required this.date,
    required this.type,
    required this.owner,
    required this.action,
    required this.notes,
    required this.status,
    required this.overdue,
  });
  final String date;
  final String type;
  final String owner;
  final String action;
  final String notes;
  final String status;
  final bool overdue;
}

TextStyle _text(double size, FontWeight weight, [Color? color]) {
  return GoogleFonts.inter(
    fontSize: (size * 1.14).sp,
    fontWeight: weight,
    color: color ?? const Color(0xFF172033),
  );
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : <Map<String, dynamic>>[];

String? _string(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
}

String _from(
  Map<String, dynamic> map,
  List<String> keys, [
  String fallback = '—',
]) {
  for (final key in keys) {
    final value = _string(map[key]);
    if (value != null) return value;
  }
  return fallback;
}

num _number(Object? value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

String _date(String value) {
  if (value.isEmpty) return '—';
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value;
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _dateTime(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value.isEmpty ? 'Not scheduled' : value;
  final hour = date.hour == 0
      ? 12
      : (date.hour > 12 ? date.hour - 12 : date.hour);
  final period = date.hour >= 12 ? 'pm' : 'am';
  return '${_date(value)} • ${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
}

String _formatFollowUpDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
