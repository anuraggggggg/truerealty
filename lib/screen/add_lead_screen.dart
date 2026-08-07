import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/lead_master_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';

const List<_ApiOption> _leadSourceOptions = [
  _ApiOption(id: 'MagicBricks', label: 'MagicBricks'),
  _ApiOption(id: '99Acres', label: '99Acres'),
  _ApiOption(id: 'Google Ads', label: 'Google Ads'),
  _ApiOption(id: 'Meta Ads', label: 'Meta Ads'),
  _ApiOption(id: 'Referral', label: 'Referral'),
  _ApiOption(id: 'Walk-in', label: 'Walk-in'),
];

const List<_ApiOption> _leadStatusOptions = [
  _ApiOption(id: 'New Lead', label: 'New Lead'),
  _ApiOption(id: 'Interested', label: 'Interested'),
  _ApiOption(id: 'Follow-Up', label: 'Follow-Up'),
  _ApiOption(id: 'Site Visit Done', label: 'Site Visit Done'),
  _ApiOption(id: 'Booking Done', label: 'Booking Done'),
  _ApiOption(id: 'Lost', label: 'Lost'),
  _ApiOption(id: 'Re-Visit Done', label: 'Re-Visit Done'),
  _ApiOption(id: 'Site Visit Schedule', label: 'Site Visit Schedule'),
  _ApiOption(id: 'Not Interested', label: 'Not Interested'),
  _ApiOption(id: 'Out Station Lead', label: 'Out Station Lead'),
  _ApiOption(id: 'CP', label: 'CP'),
  _ApiOption(id: 'Already Purchased', label: 'Already Purchased'),
];

const List<_ApiOption> _leadStageOptions = [
  _ApiOption(id: 'new-lead', label: 'New Lead'),
  _ApiOption(id: 'qualified', label: 'Qualified'),
  _ApiOption(id: 'site-visit', label: 'Site Visit'),
];

const List<_ApiOption> _employeeFallbackOptions = [
  _ApiOption(
    id: 'Telecaller Test',
    label: 'Telecaller Test',
    subtitle: 'Telecaller',
  ),
  _ApiOption(
    id: 'Khushvinder Kaur',
    label: 'Khushvinder Kaur',
    subtitle: 'Sales Agent',
  ),
  _ApiOption(id: 'Sneha Iyer', label: 'Sneha Iyer', subtitle: 'Sales Agent'),
  _ApiOption(id: 'Ravi Kumar', label: 'Ravi Kumar', subtitle: 'Sales Agent'),
  _ApiOption(
    id: 'Sales Manager Test',
    label: 'Sales Manager Test',
    subtitle: 'Sales Manager',
  ),
];

const List<_ApiOption> _projectFallbackOptions = [
  _ApiOption(
    id: 'sunset-residency',
    label: 'Sunset Residency',
    subtitle: 'Malad, Mumbai · Sunset Homes',
    data: {'location': 'Malad, Mumbai', 'developer': 'Sunset Homes'},
  ),
  _ApiOption(
    id: 'palm-springs',
    label: 'Palm Springs',
    subtitle: 'Andheri (W), Mumbai · Palm Habitat',
    data: {'location': 'Andheri (W), Mumbai', 'developer': 'Palm Habitat'},
  ),
  _ApiOption(
    id: 'lakeview-residency',
    label: 'Lakeview Residency',
    subtitle: 'Powai, Mumbai · Lakeview Infra',
    data: {'location': 'Powai, Mumbai', 'developer': 'Lakeview Infra'},
  ),
  _ApiOption(
    id: 'skyline-enclave',
    label: 'Skyline Enclave',
    subtitle: 'Goregaon (E), Mumbai · Truroot Realty',
    data: {'location': 'Goregaon (E), Mumbai', 'developer': 'Truroot Realty'},
  ),
  _ApiOption(id: 'ocean-heights', label: 'Ocean Heights'),
];

const List<String> _propertyTypeOptions = [
  'Apartment',
  'Villa',
  'Plot',
  'Commercial',
];

const List<String> _budgetOptions = [
  '50 Lakh - 75 Lakh',
  '75 Lakh - 1 Cr',
  '1 Cr - 1.5 Cr',
  '1.5 Cr - 2 Cr',
  '2 Cr - 3 Cr',
  '3 Cr+',
];

const List<String> _configurationOptions = [
  '1 BHK',
  '2 BHK',
  '3 BHK',
  '4 BHK',
  '5 BHK',
  'Studio',
  'Penthouse',
];

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileCodeController = TextEditingController(text: '+91');
  final _mobileController = TextEditingController();
  final _alternateCodeController = TextEditingController(text: '+91');
  final _alternateMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _remarksController = TextEditingController();
  final _propertyTypeController = TextEditingController();
  final _configurationController = TextEditingController();
  final _budgetRangeController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _budgetUnitController = TextEditingController();
  final _preferredLocationController = TextEditingController();
  final _possessionTimelineController = TextEditingController();
  final _carpetAreaRangeController = TextEditingController();
  final _purposeController = TextEditingController();
  final _minAreaController = TextEditingController();
  final _maxAreaController = TextEditingController();
  final _zoneController = TextEditingController();
  final _occupationController = TextEditingController();
  final _followUpMessageController = TextEditingController();

  final DateTime _createdAt = DateTime.now();
  DateTime _followUpDate = DateTime.now();
  TimeOfDay _followUpTime = TimeOfDay.now();
  bool _isLoadingOptions = true;
  bool _isSaving = false;
  bool _scheduleFollowUp = false;
  bool _remindTelecaller = true;
  int _currentStep = 0;
  String? _error;

  List<_ApiOption> _sources = const [];
  List<_ApiOption> _stages = const [];
  // Keep project selection usable while the remote options are loading or
  // unavailable. API projects are merged into these options in _loadOptions.
  List<_ApiOption> _projects = _projectFallbackOptions;
  List<_ApiOption> _employees = const [];

  _ApiOption? _selectedSource;
  _ApiOption _selectedStatus = const _ApiOption(
    id: 'New Lead',
    label: 'New Lead',
  );
  _ApiOption? _selectedStage;
  _ApiOption? _selectedProject;
  _ApiOption? _selectedEmployee;
  String _followUpType = 'Call';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOptions();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileCodeController.dispose();
    _mobileController.dispose();
    _alternateCodeController.dispose();
    _alternateMobileController.dispose();
    _emailController.dispose();
    _remarksController.dispose();
    _propertyTypeController.dispose();
    _configurationController.dispose();
    _budgetRangeController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _budgetUnitController.dispose();
    _preferredLocationController.dispose();
    _possessionTimelineController.dispose();
    _carpetAreaRangeController.dispose();
    _purposeController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    _zoneController.dispose();
    _occupationController.dispose();
    _followUpMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoadingOptions = true;
      _error = null;
    });

    final results = await Future.wait([
      _loadMasterOptions(const ['source', 'lead_source', 'lead-source']),
      _loadMasterOptions(const ['status', 'lead_status', 'lead-status']),
      _loadMasterOptions(const ['stage', 'lead_stage', 'lead-stage']),
      _loadProjects(),
      _loadEmployees(),
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      final statuses = _mergeOptions(results[1], _leadStatusOptions);
      final employees = _mergeOptions(results[4], _employeeFallbackOptions);
      _sources = _mergeOptions(results[0], _leadSourceOptions);
      _stages = _mergeOptions(results[2], _leadStageOptions);
      _projects = _mergeOptions(results[3], _projectFallbackOptions);
      _employees = employees;
      _selectedStatus = _newLeadStatus(statuses);
      _selectedEmployee = _currentUserEmployee(employees);
      _isLoadingOptions = false;
    });
  }

  _ApiOption _newLeadStatus(List<_ApiOption> statuses) {
    return statuses.firstWhere(
      (option) => option.label.trim().toLowerCase() == 'new lead',
      orElse: () => const _ApiOption(id: 'New Lead', label: 'New Lead'),
    );
  }

  _ApiOption? _currentUserEmployee(List<_ApiOption> employees) {
    final user = context.read<AuthProvider>().session?.user;
    if (user == null) return null;
    String read(List<String> keys) {
      for (final key in keys) {
        final value = user[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    final id = read(const ['employeeId', 'id', 'userId', '_id']);
    final match = employees.where((option) => option.id == id).firstOrNull;
    if (match != null) return match;
    if (id.isEmpty) return null;
    final name = read(const ['name', 'fullName', 'displayName', 'email']);
    return _ApiOption(
      id: id,
      label: name.isEmpty ? 'Current user' : name,
      subtitle: context.read<AuthProvider>().roleName,
      data: user,
    );
  }

  Future<List<_ApiOption>> _loadMasterOptions(List<String> categories) async {
    final provider = context.read<LeadMasterProvider>();
    for (final category in categories) {
      final response = await provider.fetchMasterValues(
        masterCategory: category,
      );
      final options = _extractApiList(response?.data)
          .map(_ApiOption.fromJson)
          .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
          .toList();
      if (options.isNotEmpty) {
        return options;
      }
    }
    return const [];
  }

  Future<List<_ApiOption>> _loadProjects() async {
    final response = await context.read<ProjectProvider>().fetchProjects();
    return _extractApiList(response?.data)
        .map(_ApiOption.fromJson)
        .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
        .toList();
  }

  Future<List<_ApiOption>> _loadEmployees() async {
    final response = await context.read<EmployeeProvider>().fetchEmployees(
      limit: 100,
    );
    return _extractApiList(response?.data)
        .map(_ApiOption.fromJson)
        .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _error = 'Please complete the required fields.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'mobileCountryCode': _mobileCodeController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'alternateCountryCode': _alternateCodeController.text.trim(),
      if (_alternateMobileController.text.trim().isNotEmpty)
        'alternateMobile': _alternateMobileController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'email': _emailController.text.trim(),
      if (_selectedSource != null) 'sourceId': _selectedSource!.id,
      'statusId': _selectedStatus.id,
      if (_selectedStage != null) 'stageId': _selectedStage!.id,
      if (_remarksController.text.trim().isNotEmpty)
        'remarks': _remarksController.text.trim(),
      if (_selectedEmployee != null) 'ownerId': _selectedEmployee!.id,
      'requirement': {
        'propertyType': _propertyTypeController.text.trim(),
        if (_configurationController.text.trim().isNotEmpty)
          'configuration': _configurationController.text.trim(),
        if (_budgetRangeController.text.trim().isNotEmpty)
          'budgetRange': _budgetRangeController.text.trim(),
        if (_readNumber(_minBudgetController.text) != null)
          'minBudget': _readNumber(_minBudgetController.text),
        if (_readNumber(_maxBudgetController.text) != null)
          'maxBudget': _readNumber(_maxBudgetController.text),
        if (_budgetUnitController.text.trim().isNotEmpty)
          'budgetUnit': _budgetUnitController.text.trim(),
        'preferredLocation': _preferredLocationController.text.trim(),
        if (_selectedProject != null)
          'preferredProjectId': _selectedProject!.id,
        if (_possessionTimelineController.text.trim().isNotEmpty)
          'possessionTimeline': _possessionTimelineController.text.trim(),
        if (_carpetAreaRangeController.text.trim().isNotEmpty)
          'carpetAreaRange': _carpetAreaRangeController.text.trim(),
        if (_purposeController.text.trim().isNotEmpty)
          'purpose': _purposeController.text.trim(),
        if (_readNumber(_minAreaController.text) != null)
          'minArea': _readNumber(_minAreaController.text),
        if (_readNumber(_maxAreaController.text) != null)
          'maxArea': _readNumber(_maxAreaController.text),
        if (_zoneController.text.trim().isNotEmpty)
          'zone': _zoneController.text.trim(),
        if (_occupationController.text.trim().isNotEmpty)
          'occupation': _occupationController.text.trim(),
      },
    };

    final leadProvider = context.read<LeadProvider>();
    final response = await leadProvider.createLeadFromApi(body);

    if (!mounted) {
      return;
    }

    if (response == null) {
      setState(() {
        _isSaving = false;
        _error = leadProvider.error ?? 'Unable to create lead.';
      });
      return;
    }

    final leadId = _createdLeadId(response.data);
    if (_scheduleFollowUp && leadId != null) {
      await leadProvider.createFollowUp(
        leadId: leadId,
        body: {
          'followUpType': _followUpType,
          'scheduledAt': _scheduledFollowUp.toUtc().toIso8601String(),
          'remindTelecaller': _remindTelecaller,
          if (_followUpMessageController.text.trim().isNotEmpty)
            'message': _followUpMessageController.text.trim(),
        },
      );
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lead ${_leadDisplayId(response.data)} created.')),
    );
    Navigator.of(context).pop(true);
  }

  DateTime get _scheduledFollowUp {
    return DateTime(
      _followUpDate.year,
      _followUpDate.month,
      _followUpDate.day,
      _followUpTime.hour,
      _followUpTime.minute,
    );
  }

  void _continueToFollowUp() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _error = 'Please complete the required fields.');
      return;
    }
    setState(() {
      _currentStep = 1;
      _error = null;
    });
  }

  void _backToBasicInfo() {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentStep = 0;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: SafeArea(
          child: Column(
            children: [
              _AddLeadHeader(createdAt: _createdAt, onClose: _close),
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StepCards(currentStep: _currentStep),
                            SizedBox(height: 18.h),
                            if (_isLoadingOptions) ...[
                              const LinearProgressIndicator(minHeight: 2),
                              SizedBox(height: 14.h),
                            ],
                            if (_error != null) ...[
                              _InlineError(message: _error!),
                              SizedBox(height: 14.h),
                            ],
                            if (_currentStep == 0) ...[
                              _BasicInfoSection(
                                createdAt: _createdAt,
                                sources: _sources,
                                stages: _stages,
                                projects: _projects,
                                employees: _employees,
                                selectedSource: _selectedSource,
                                selectedStage: _selectedStage,
                                selectedProject: _selectedProject,
                                selectedEmployee: _selectedEmployee,
                                nameController: _nameController,
                                mobileCodeController: _mobileCodeController,
                                mobileController: _mobileController,
                                alternateCodeController:
                                    _alternateCodeController,
                                alternateMobileController:
                                    _alternateMobileController,
                                emailController: _emailController,
                                remarksController: _remarksController,
                                onSourceChanged: (value) =>
                                    setState(() => _selectedSource = value),
                                onStageChanged: (value) =>
                                    setState(() => _selectedStage = value),
                                onProjectChanged: (value) {
                                  setState(() {
                                    _selectedProject = value;
                                    final location = value == null
                                        ? ''
                                        : _optionLocation(value.data);
                                    if (location.isNotEmpty) {
                                      _preferredLocationController.text =
                                          location;
                                    }
                                  });
                                },
                                onEmployeeChanged: (value) =>
                                    setState(() => _selectedEmployee = value),
                              ),
                              SizedBox(height: 16.h),
                              _RequirementSection(
                                propertyTypeController: _propertyTypeController,
                                configurationController:
                                    _configurationController,
                                budgetRangeController: _budgetRangeController,
                                minBudgetController: _minBudgetController,
                                maxBudgetController: _maxBudgetController,
                                budgetUnitController: _budgetUnitController,
                                preferredLocationController:
                                    _preferredLocationController,
                                possessionTimelineController:
                                    _possessionTimelineController,
                                carpetAreaRangeController:
                                    _carpetAreaRangeController,
                                purposeController: _purposeController,
                                minAreaController: _minAreaController,
                                maxAreaController: _maxAreaController,
                                zoneController: _zoneController,
                                occupationController: _occupationController,
                              ),
                            ] else
                              _FollowUpSection(
                                enabled: _scheduleFollowUp,
                                type: _followUpType,
                                date: _followUpDate,
                                time: _followUpTime,
                                messageController: _followUpMessageController,
                                onEnabledChanged: (value) =>
                                    setState(() => _scheduleFollowUp = value),
                                onTypeChanged: (value) =>
                                    setState(() => _followUpType = value),
                                remindTelecaller: _remindTelecaller,
                                onRemindTelecallerChanged: (value) =>
                                    setState(() => _remindTelecaller = value),
                                onPickDate: _pickFollowUpDate,
                                onPickTime: _pickFollowUpTime,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _AddLeadFooter(
                currentStep: _currentStep,
                isSaving: _isSaving,
                onCancel: _close,
                onBack: _backToBasicInfo,
                onContinue: _continueToFollowUp,
                onSubmit: _isSaving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFollowUpDate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _followUpDate = picked);
    }
  }

  Future<void> _pickFollowUpTime() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _followUpTime,
    );
    if (picked != null && mounted) {
      setState(() => _followUpTime = picked);
    }
  }

  void _close() => Navigator.of(context).maybePop();
}

class _AddLeadHeader extends StatelessWidget {
  const _AddLeadHeader({required this.createdAt, required this.onClose});

  final DateTime createdAt;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add lead',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Capture the basic contact details first, then add requirement and follow-up context.',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          );
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TimestampPill(date: createdAt),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFF64748B),
              ),
            ],
          );

          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _TimestampPill(date: createdAt),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              SizedBox(width: 12.w),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _TimestampPill extends StatelessWidget {
  const _TimestampPill({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AUTO TIMESTAMP',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatDateTime(date),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCards extends StatelessWidget {
  const _StepCards({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final first = _StepCard(
          number: '1',
          title: 'Lead information',
          subtitle: 'Contact, source, project and initial assignment',
          active: currentStep == 0,
          completed: currentStep > 0,
        );
        final second = _StepCard(
          number: '2',
          title: 'Follow-up details',
          subtitle: 'Schedule the next action and reminder',
          active: currentStep == 1,
        );

        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              first,
              SizedBox(height: 10.h),
              second,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            SizedBox(width: 10.w),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    this.active = false,
    this.completed = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFFBF8) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: active ? AppColors.orangeDeep : const Color(0xFFD9E3EF),
          width: active ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11.r,
            backgroundColor: active || completed
                ? AppColors.orangeDeep
                : const Color(0xFFEFF4FA),
            child: completed
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    number,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.white : AppColors.navy,
                    ),
                  ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
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

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.createdAt,
    required this.sources,
    required this.stages,
    required this.projects,
    required this.employees,
    required this.selectedSource,
    required this.selectedStage,
    required this.selectedProject,
    required this.selectedEmployee,
    required this.nameController,
    required this.mobileCodeController,
    required this.mobileController,
    required this.alternateCodeController,
    required this.alternateMobileController,
    required this.emailController,
    required this.remarksController,
    required this.onSourceChanged,
    required this.onStageChanged,
    required this.onProjectChanged,
    required this.onEmployeeChanged,
  });

  final DateTime createdAt;
  final List<_ApiOption> sources;
  final List<_ApiOption> stages;
  final List<_ApiOption> projects;
  final List<_ApiOption> employees;
  final _ApiOption? selectedSource;
  final _ApiOption? selectedStage;
  final _ApiOption? selectedProject;
  final _ApiOption? selectedEmployee;
  final TextEditingController nameController;
  final TextEditingController mobileCodeController;
  final TextEditingController mobileController;
  final TextEditingController alternateCodeController;
  final TextEditingController alternateMobileController;
  final TextEditingController emailController;
  final TextEditingController remarksController;
  final ValueChanged<_ApiOption?> onSourceChanged;
  final ValueChanged<_ApiOption?> onStageChanged;
  final ValueChanged<_ApiOption?> onProjectChanged;
  final ValueChanged<_ApiOption?> onEmployeeChanged;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Lead information',
      icon: Icons.badge_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget adaptivePair(Widget first, Widget second) {
            if (constraints.maxWidth < 680) {
              return Column(
                children: [
                  first,
                  SizedBox(height: 18.h),
                  second,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: first),
                SizedBox(width: 16.w),
                Expanded(child: second),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadonlyField(
                label: 'Date & time',
                value: _formatDateTime(createdAt),
                icon: Icons.calendar_month_outlined,
                suffix: 'Auto generated',
              ),
              SizedBox(height: 18.h),
              _TextInput(
                controller: nameController,
                label: 'Lead name *',
                hint: 'Enter lead full name',
                validator: _required('Lead name is required.'),
              ),
              SizedBox(height: 18.h),
              _PhoneInput(
                codeController: mobileCodeController,
                numberController: mobileController,
                label: 'Primary phone number *',
                validator: _phoneValidator(required: true),
              ),
              SizedBox(height: 18.h),
              _PhoneInput(
                codeController: alternateCodeController,
                numberController: alternateMobileController,
                label: 'Alternate phone number',
                required: false,
                validator: _phoneValidator(required: false),
              ),
              SizedBox(height: 18.h),
              _TextInput(
                controller: emailController,
                label: 'Email',
                hint: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),
              SizedBox(height: 18.h),
              adaptivePair(
                _OptionDropdown(
                  label: 'Project *',
                  hint: 'Select Project',
                  value: selectedProject,
                  items: projects,
                  validatorMessage: 'Project is required.',
                  onChanged: onProjectChanged,
                ),
                _OptionDropdown(
                  label: 'Source *',
                  hint: 'Select lead source',
                  value: selectedSource,
                  items: sources,
                  validatorMessage: 'Lead source is required.',
                  onChanged: onSourceChanged,
                ),
              ),
              SizedBox(height: 18.h),
              adaptivePair(
                _ReadonlyField(
                  label: 'Project area / location',
                  value: selectedProject == null
                      ? 'Selected project location'
                      : _optionLocation(selectedProject!.data),
                  icon: Icons.location_on_outlined,
                  suffix: 'Auto-filled',
                ),
                _OptionDropdown(
                  label: 'Lead Stage',
                  hint: 'Select lead stage',
                  value: selectedStage,
                  items: stages,
                  onChanged: onStageChanged,
                ),
              ),
              SizedBox(height: 18.h),
              _TextInput(
                controller: remarksController,
                label: 'Requirements / Notes',
                hint: 'Add lead context or notes',
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              SizedBox(height: 18.h),
              _OptionDropdown(
                label: 'Assign To',
                hint: 'Select employee',
                value: selectedEmployee,
                items: employees,
                onChanged: onEmployeeChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequirementSection extends StatelessWidget {
  const _RequirementSection({
    required this.propertyTypeController,
    required this.configurationController,
    required this.budgetRangeController,
    required this.minBudgetController,
    required this.maxBudgetController,
    required this.budgetUnitController,
    required this.preferredLocationController,
    required this.possessionTimelineController,
    required this.carpetAreaRangeController,
    required this.purposeController,
    required this.minAreaController,
    required this.maxAreaController,
    required this.zoneController,
    required this.occupationController,
  });

  final TextEditingController propertyTypeController;
  final TextEditingController configurationController;
  final TextEditingController budgetRangeController;
  final TextEditingController minBudgetController;
  final TextEditingController maxBudgetController;
  final TextEditingController budgetUnitController;
  final TextEditingController preferredLocationController;
  final TextEditingController possessionTimelineController;
  final TextEditingController carpetAreaRangeController;
  final TextEditingController purposeController;
  final TextEditingController minAreaController;
  final TextEditingController maxAreaController;
  final TextEditingController zoneController;
  final TextEditingController occupationController;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: 'Requirement details',
      icon: Icons.tune_rounded,
      child: Column(
        children: [
          _ResponsiveFieldPair(
            first: _TextControllerOptionField(
              controller: propertyTypeController,
              label: 'Property type',
              hint: 'Select property type',
              searchHint: 'Search property types...',
              items: _propertyTypeOptions,
            ),
            second: _TextControllerOptionField(
              controller: configurationController,
              label: 'Configuration',
              hint: 'Select configuration',
              searchHint: 'Search configurations...',
              items: _configurationOptions,
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextControllerOptionField(
              controller: budgetRangeController,
              label: 'Budget',
              hint: 'Select budget',
              searchHint: 'Search budgets...',
              items: _budgetOptions,
            ),
            second: _TextInput(
              controller: budgetUnitController,
              label: 'Budget unit',
              hint: 'Lakh, Cr, INR',
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextInput(
              controller: minBudgetController,
              label: 'Min budget',
              hint: 'Enter minimum budget',
              keyboardType: TextInputType.number,
            ),
            second: _TextInput(
              controller: maxBudgetController,
              label: 'Max budget',
              hint: 'Enter maximum budget',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextInput(
              controller: preferredLocationController,
              label: 'Preferred location',
              hint: 'Enter preferred location',
            ),
            second: _TextInput(
              controller: possessionTimelineController,
              label: 'Possession timeline',
              hint: 'Immediate, 6 months, 1 year',
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextInput(
              controller: carpetAreaRangeController,
              label: 'Carpet area range',
              hint: 'Example: 700 - 950 sq.ft.',
            ),
            second: _TextInput(
              controller: purposeController,
              label: 'Purpose',
              hint: 'Investment, self-use',
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextInput(
              controller: minAreaController,
              label: 'Min area',
              hint: 'Minimum area',
              keyboardType: TextInputType.number,
            ),
            second: _TextInput(
              controller: maxAreaController,
              label: 'Max area',
              hint: 'Maximum area',
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(height: 14.h),
          _ResponsiveFieldPair(
            first: _TextInput(
              controller: zoneController,
              label: 'Zone',
              hint: 'Enter zone',
            ),
            second: _TextInput(
              controller: occupationController,
              label: 'Occupation',
              hint: 'Enter occupation',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFieldPair extends StatelessWidget {
  const _ResponsiveFieldPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              first,
              SizedBox(height: 14.h),
              second,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            SizedBox(width: 12.w),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _FollowUpSection extends StatelessWidget {
  const _FollowUpSection({
    required this.enabled,
    required this.type,
    required this.date,
    required this.time,
    required this.messageController,
    required this.onEnabledChanged,
    required this.onTypeChanged,
    required this.remindTelecaller,
    required this.onRemindTelecallerChanged,
    required this.onPickDate,
    required this.onPickTime,
  });

  final bool enabled;
  final String type;
  final DateTime date;
  final TimeOfDay time;
  final TextEditingController messageController;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onTypeChanged;
  final bool remindTelecaller;
  final ValueChanged<bool> onRemindTelecallerChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFD9E3EF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule follow-up',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Set the next customer touchpoint before saving the lead.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5EAF2)),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final autoAssign = _FollowUpCheckTile(
                          value: enabled,
                          title: 'Auto assign next follow-up',
                          subtitle:
                              'Create the next action immediately when this lead is saved.',
                          onChanged: onEnabledChanged,
                        );
                        final typeField = _PlainDropdown(
                          label: 'Follow-up type',
                          value: type,
                          items: const [
                            'Call',
                            'WhatsApp',
                            'Email',
                            'Site Visit',
                          ],
                          onChanged: onTypeChanged,
                        );

                        if (constraints.maxWidth < 620) {
                          return Column(
                            children: [
                              autoAssign,
                              SizedBox(height: 14.h),
                              typeField,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: autoAssign),
                            SizedBox(width: 16.w),
                            Expanded(child: typeField),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 14.h),
                    _FieldLabel(
                      label: 'Follow-up date and time',
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final dateField = _PickerField(
                            label: '',
                            value: _formatDate(date),
                            icon: Icons.calendar_month_outlined,
                            onTap: onPickDate,
                          );
                          final timeField = _PickerField(
                            label: '',
                            value: _formatTime(time),
                            icon: Icons.schedule_rounded,
                            onTap: onPickTime,
                          );
                          if (constraints.maxWidth < 520) {
                            return Column(
                              children: [
                                dateField,
                                SizedBox(height: 12.h),
                                timeField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: dateField),
                              SizedBox(width: 12.w),
                              Expanded(child: timeField),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _FollowUpCheckTile(
                      value: remindTelecaller,
                      title: 'Set reminder for telecaller',
                      subtitle:
                          'Keep the assigned telecaller notified about the scheduled follow-up.',
                      onChanged: onRemindTelecallerChanged,
                    ),
                    if (enabled) ...[
                      SizedBox(height: 14.h),
                      _TextInput(
                        controller: messageController,
                        label: 'Follow-up message',
                        hint: 'Add reminder context',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpCheckTile extends StatelessWidget {
  const _FollowUpCheckTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: const Color(0xFFD9E3EF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (next) => onChanged(next ?? false),
              activeColor: AppColors.orangeDeep,
              side: const BorderSide(color: Color(0xFFD9E3EF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r),
              ),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
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

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.orangeDeep, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: textInputAction,
        onFieldSubmitted: textInputAction == TextInputAction.next
            ? (_) => FocusScope.of(context).nextFocus()
            : null,
        decoration: _inputDecoration(hint),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.codeController,
    required this.numberController,
    required this.label,
    this.validator,
    this.required = true,
  });

  final TextEditingController codeController;
  final TextEditingController numberController;
  final String label;
  final String? Function(String?)? validator;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      child: Row(
        children: [
          SizedBox(
            width: 72.w,
            child: TextFormField(
              controller: codeController,
              decoration: _inputDecoration('+91'),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextFormField(
              controller: numberController,
              validator: validator,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              decoration: _inputDecoration(
                required ? 'Enter mobile number' : 'Enter alternate number',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionDropdown extends StatelessWidget {
  const _OptionDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validatorMessage,
  });

  final String label;
  final String hint;
  final _ApiOption? value;
  final List<_ApiOption> items;
  final ValueChanged<_ApiOption?> onChanged;
  final String? validatorMessage;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      child: FormField<_ApiOption>(
        initialValue: value,
        validator: validatorMessage == null
            ? null
            : (value) => value == null ? validatorMessage : null,
        builder: (field) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: items.isEmpty
                    ? null
                    : () async {
                        final selected =
                            await _showSearchablePicker<_ApiOption>(
                              context: context,
                              title: label.replaceAll('*', '').trim(),
                              searchHint: _searchHintFor(label),
                              items: items,
                              selected: field.value,
                              labelFor: (item) => item.label,
                              subtitleFor: (item) => item.subtitle,
                            );
                        if (selected != null) {
                          field.didChange(selected);
                          onChanged(selected);
                        }
                      },
                borderRadius: BorderRadius.circular(8.r),
                child: InputDecorator(
                  decoration: _inputDecoration(hint).copyWith(
                    errorText: field.errorText,
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  child: Text(
                    field.value?.label ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: field.value == null
                          ? const Color(0xFF64748B)
                          : AppColors.navy,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TextControllerOptionField extends StatefulWidget {
  const _TextControllerOptionField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.searchHint,
    required this.items,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String searchHint;
  final List<String> items;

  @override
  State<_TextControllerOptionField> createState() =>
      _TextControllerOptionFieldState();
}

class _TextControllerOptionFieldState
    extends State<_TextControllerOptionField> {
  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text.trim();
    return _FieldLabel(
      label: widget.label,
      child: InkWell(
        onTap: () async {
          final selected = await _showSearchablePicker<String>(
            context: context,
            title: widget.label,
            searchHint: widget.searchHint,
            items: widget.items,
            selected: value.isEmpty ? null : value,
            labelFor: (item) => item,
          );
          if (selected == null || !mounted) {
            return;
          }
          setState(() => widget.controller.text = selected);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: InputDecorator(
          decoration: _inputDecoration(
            widget.hint,
          ).copyWith(suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded)),
          child: Text(
            value.isEmpty ? widget.hint : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: value.isEmpty ? const Color(0xFF64748B) : AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> _showSearchablePicker<T>({
  required BuildContext context,
  required String title,
  required String searchHint,
  required List<T> items,
  required String Function(T item) labelFor,
  String? Function(T item)? subtitleFor,
  T? selected,
}) async {
  // Do not let Flutter restore focus to the last text field when this route
  // closes; that would call ensureVisible and jump the form back up.
  FocusManager.instance.primaryFocus?.unfocus();

  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (dialogContext) => _SearchablePickerDialog<T>(
      title: title,
      searchHint: searchHint,
      items: items,
      selected: selected,
      labelFor: labelFor,
      subtitleFor: subtitleFor,
    ),
  );
}

class _SearchablePickerDialog<T> extends StatefulWidget {
  const _SearchablePickerDialog({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.labelFor,
    this.subtitleFor,
    this.selected,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final String Function(T item) labelFor;
  final String? Function(T item)? subtitleFor;
  final T? selected;

  @override
  State<_SearchablePickerDialog<T>> createState() =>
      _SearchablePickerDialogState<T>();
}

class _SearchablePickerDialogState<T>
    extends State<_SearchablePickerDialog<T>> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = widget.selected == null
        ? null
        : widget.labelFor(widget.selected as T);
    final normalizedQuery = _query.trim().toLowerCase();
    final visibleItems = normalizedQuery.isEmpty
        ? widget.items
        : widget.items.where((item) {
            final label = widget.labelFor(item).toLowerCase();
            final subtitle =
                widget.subtitleFor?.call(item)?.toLowerCase() ?? '';
            return label.contains(normalizedQuery) ||
                subtitle.contains(normalizedQuery);
          }).toList();

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: const BorderSide(color: AppColors.orangeDeep),
      ),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 420.h, maxWidth: 520.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
              child: Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: _inputDecoration(widget.searchHint).copyWith(
                  prefixIcon: const Icon(Icons.search_rounded),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Divider(height: 1.h, color: const Color(0xFFE5EAF2)),
            Flexible(
              child: visibleItems.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(18.r),
                      child: Text(
                        'No options found.',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: visibleItems.length > 6,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        itemCount: visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = visibleItems[index];
                          final isSelected =
                              selectedLabel != null &&
                              selectedLabel == widget.labelFor(item);
                          final subtitle = widget.subtitleFor?.call(item);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(item),
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: subtitle == null ? 11.h : 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF8FAFC)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.orangeDeep,
                                          width: 1.2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.labelFor(item),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    if (subtitle != null &&
                                        subtitle.isNotEmpty) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _searchHintFor(String label) {
  final normalized = label.replaceAll('*', '').trim().toLowerCase();
  if (normalized.contains('source')) return 'Search lead sources...';
  if (normalized.contains('status')) return 'Search lead statuses...';
  if (normalized.contains('stage')) return 'Search lead stages...';
  if (normalized.contains('employee')) return 'Search employees...';
  if (normalized.contains('project')) return 'Search projects...';
  if (normalized.contains('priority')) return 'Search priorities...';
  return 'Search options...';
}

class _PlainDropdown extends StatelessWidget {
  const _PlainDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: _inputDecoration('Select option'),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.suffix,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return _FieldLabel(
      label: label,
      suffix: suffix,
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD9E3EF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
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
    final field = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD9E3EF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (label.isEmpty) {
      return field;
    }
    return _FieldLabel(label: label, child: field);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child, this.suffix});

  final String label;
  final Widget child;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
            if (suffix != null)
              Text(
                suffix!,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
          ],
        ),
        SizedBox(height: 7.h),
        child,
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFB91C1C),
        ),
      ),
    );
  }
}

class _AddLeadFooter extends StatelessWidget {
  const _AddLeadFooter({
    required this.currentStep,
    required this.isSaving,
    required this.onCancel,
    required this.onBack,
    required this.onContinue,
    required this.onSubmit,
  });

  final int currentStep;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 12.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cancelButton = OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD9E3EF)),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          );
          final backButton = OutlinedButton(
            onPressed: isSaving ? null : onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD9E3EF)),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Back',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800),
            ),
          );
          final primaryButton = ElevatedButton.icon(
            onPressed: currentStep == 0 ? onContinue : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeDeep,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            icon: isSaving && currentStep == 1
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    currentStep == 0
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
            label: Text(
              currentStep == 0 ? 'Continue to follow-up' : 'Save lead',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                primaryButton,
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(child: cancelButton),
                    if (currentStep == 1) ...[
                      SizedBox(width: 10.w),
                      Expanded(child: backButton),
                    ],
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              cancelButton,
              const Spacer(),
              if (currentStep == 1) ...[backButton, SizedBox(width: 10.w)],
              primaryButton,
            ],
          );
        },
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF64748B),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: Color(0xFFD9E3EF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: Color(0xFFD9E3EF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: AppColors.orangeDeep),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
  );
}

String? Function(String?) _required(String message) {
  return (value) => value == null || value.trim().isEmpty ? message : null;
}

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return null;
  final valid = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  return valid ? null : 'Enter a valid email address.';
}

String? Function(String?) _phoneValidator({required bool required}) {
  return (value) {
    final phone = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (phone.isEmpty) {
      return required ? 'Phone number is required.' : null;
    }
    if (phone.length < 7 || phone.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  };
}

List<_ApiOption> _mergeOptions(
  List<_ApiOption> options,
  List<_ApiOption> fallback,
) {
  final merged = <_ApiOption>[];
  final labels = <String>{};

  for (final option in [...options, ...fallback]) {
    final key = option.label.trim().toLowerCase();
    if (option.id.isEmpty || option.label.isEmpty || labels.contains(key)) {
      continue;
    }
    labels.add(key);
    merged.add(option);
  }

  return merged;
}

List<dynamic> _extractApiList(Object? source) {
  if (source is List) {
    return source;
  }
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'projects',
      'employees',
      'values',
    ]) {
      final value = source[key];
      if (value is List) {
        return value;
      }
      if (value is Map) {
        final nested = _extractApiList(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
  }
  return const [];
}

Object? _readValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    if (map.containsKey(key) && map[key] != null) {
      return map[key];
    }
    final normalized = key.toLowerCase();
    for (final entry in map.entries) {
      if (entry.key.toString().toLowerCase() == normalized &&
          entry.value != null) {
        return entry.value;
      }
    }
  }
  return null;
}

String _readString(Map<String, dynamic> map, List<String> keys) {
  final value = _readValue(map, keys);
  return value?.toString().trim() ?? '';
}

num? _readNumber(String value) {
  final clean = value.trim();
  if (clean.isEmpty) {
    return null;
  }
  return num.tryParse(clean);
}

String? _createdLeadId(Object? source) {
  final lead = _createdLeadMap(source);
  return lead == null ? null : _readString(lead, const ['id', 'leadId']);
}

String _leadDisplayId(Object? source) {
  final lead = _createdLeadMap(source);
  final value = lead == null
      ? ''
      : _readString(lead, const ['displayId', 'leadDisplayId', 'id']);
  return value.isEmpty ? 'created' : value;
}

Map<String, dynamic>? _createdLeadMap(Object? source) {
  if (source is Map) {
    if (source['data'] is Map) {
      return Map<String, dynamic>.from(source['data'] as Map);
    }
    if (source['lead'] is Map) {
      return Map<String, dynamic>.from(source['lead'] as Map);
    }
    return Map<String, dynamic>.from(source);
  }
  return null;
}

String _optionLocation(Object? source) {
  if (source is! Map) {
    return 'Selected project location';
  }
  final map = Map<String, dynamic>.from(source);
  final value = _readString(map, const [
    'location',
    'address',
    'area',
    'projectLocation',
    'city',
  ]);
  return value.isEmpty ? 'Selected project location' : value;
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)}, ${_formatClock(date)}';
}

String _formatDate(DateTime date) {
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

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'am' : 'pm';
  return '$hour:$minute $period';
}

String _formatClock(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'pm' : 'am';
  return '$hour:$minute $period';
}

class _ApiOption {
  const _ApiOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.data,
  });

  final String id;
  final String label;
  final String? subtitle;
  final Object? data;

  factory _ApiOption.fromJson(Object? source) {
    if (source is String) {
      return _ApiOption(id: source, label: source, data: source);
    }
    if (source is! Map) {
      return const _ApiOption(id: '', label: '');
    }

    final map = Map<String, dynamic>.from(source);
    final id = _readString(map, const [
      'id',
      '_id',
      'value',
      'slug',
      'key',
      'userId',
      'employeeId',
    ]);
    var label = _readString(map, const [
      'name',
      'label',
      'title',
      'displayName',
      'fullName',
      'email',
      'value',
    ]);
    if (label.isEmpty) {
      label = [
        _readString(map, const ['firstName', 'first_name']),
        _readString(map, const ['lastName', 'last_name']),
      ].where((part) => part.isNotEmpty).join(' ');
    }
    final subtitle = _readString(map, const [
      'role',
      'roleName',
      'designation',
      'department',
      'employeeRole',
    ]);

    return _ApiOption(
      id: id,
      label: label.isEmpty ? id : label,
      subtitle: subtitle.isEmpty ? null : subtitle,
      data: source,
    );
  }
}
