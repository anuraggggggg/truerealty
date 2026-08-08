import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/follow_up_model.dart';
import 'package:truerealtycrm/provider/follow_ups_provider.dart';
import 'package:truerealtycrm/provider/lead_master_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:truerealtycrm/widget/follow_up_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MyFollowUpsScreen extends StatefulWidget {
  const MyFollowUpsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<MyFollowUpsScreen> createState() => _MyFollowUpsScreenState();
}

class _MyFollowUpsScreenState extends State<MyFollowUpsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FollowUpsProvider>().loadFollowUps(limit: 500);
    });
  }

  Future<void> _refresh() {
    return context.read<FollowUpsProvider>().loadFollowUps(limit: 500);
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty || cleaned == '-') return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = _whatsAppDigits(phone);
    if (digits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid phone number for WhatsApp.')),
      );
      return;
    }

    final candidates = <Uri>[
      Uri.parse('whatsapp://send?phone=$digits'),
      Uri.parse('https://api.whatsapp.com/send?phone=$digits'),
      Uri.parse('https://wa.me/$digits'),
    ];

    for (final uri in candidates) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      } catch (_) {
        // Try the next scheme/fallback.
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open WhatsApp. Please install WhatsApp.'),
      ),
    );
  }

  String _whatsAppDigits(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    // Indian 10-digit mobiles need country code for WhatsApp deep links.
    if (digits.length == 10) {
      digits = '91$digits';
    }
    return digits;
  }

  void _openLead(FollowUpModel item) {
    final lead = item.leadRaw;
    if (lead == null) return;
    Navigator.of(
      context,
    ).pushNamed(AppRouter.leadDetail, arguments: LeadModel.fromJson(lead));
  }

  Future<void> _openReschedule(FollowUpModel item) async {
    if (item.leadId == null || item.leadId!.isEmpty || item.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up identifiers are unavailable.')),
      );
      return;
    }
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RescheduleFollowUpDialog(item: item),
    );
    if (updated == true && mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FollowUpsProvider>();
    final summary = provider.summary;
    final visible = provider.visibleItems;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        leading: widget.onMenuTap == null
            ? null
            : IconButton(
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
        title: Text(
          'My Follow-Ups',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track and action only the follow-ups assigned to you from the same premium workspace.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SummaryMetricsGrid(
                      summary: summary,
                      onSelect: provider.setFilter,
                    ),
                    SizedBox(height: 14.h),
                    _QueueSlaSection(summary: summary),
                    SizedBox(height: 14.h),
                    _PipelineFilterTabs(provider: provider),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
            if (provider.isLoading && !provider.hasLoaded)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: const SliverToBoxAdapter(
                  child: AppListSkeleton(itemCount: 4, itemHeight: 168),
                ),
              )
            else if (provider.error != null && provider.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.error!,
                  onRetry: _refresh,
                ),
              )
            else if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.items.isEmpty
                      ? 'No follow-ups found.'
                      : 'No follow-ups in this filter.',
                  onRetry: provider.items.isEmpty ? _refresh : null,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return FollowUpLeadCard(
                      item: item,
                      onTap: () => _openReschedule(item),
                      onCall: () => _call(item.phone),
                      onWhatsApp: () => _openWhatsApp(item.phone),
                      onMore: () => _openLead(item),
                    );
                  },
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _PerformanceSection(summary: summary),
                    SizedBox(height: 14.h),
                    _BestTimeSection(slots: provider.bestTimeSlots),
                    SizedBox(height: 14.h),
                    _CalendarSection(
                      markedDays: provider.scheduledDaysInCurrentMonth,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RescheduleFollowUpDialog extends StatefulWidget {
  const _RescheduleFollowUpDialog({required this.item});

  final FollowUpModel item;

  @override
  State<_RescheduleFollowUpDialog> createState() =>
      _RescheduleFollowUpDialogState();
}

class _RescheduleFollowUpDialogState extends State<_RescheduleFollowUpDialog> {
  static const _budgetOptions = [
    '50 Lakh - 75 Lakh',
    '75 Lakh - 1 Cr',
    '1 Cr - 1.5 Cr',
    '1.5 Cr - 2 Cr',
    '2 Cr - 3 Cr',
    '3 Cr+',
  ];
  static const _configurationOptions = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '5 BHK',
    'Studio',
    'Penthouse',
  ];
  late final TextEditingController _remarksController;
  late DateTime _date;
  late TimeOfDay _time;
  bool _setReminder = true;
  bool _saving = false;
  bool _loadingOptions = true;
  String? _error;
  String? _statusId;
  String? _temperatureId;
  String? _budget;
  String? _configuration;
  List<_FollowUpOption> _statuses = const [];
  List<_FollowUpOption> _temperatures = const [];

  @override
  void initState() {
    super.initState();
    final scheduled = widget.item.scheduledAt ?? DateTime.now();
    _date = scheduled;
    _time = TimeOfDay.fromDateTime(scheduled);
    _remarksController = TextEditingController(
      text: widget.item.nextAction ?? '',
    );
    final raw = widget.item.leadRaw ?? const <String, dynamic>{};
    final requirement = raw['requirement'] is Map
        ? Map<String, dynamic>.from(raw['requirement'] as Map)
        : const <String, dynamic>{};
    _statusId = _dialogText(raw['statusId']);
    _temperatureId = _dialogText(raw['temperatureId']);
    _budget = _dialogText(requirement['budgetRange']);
    _configuration = _dialogText(requirement['configuration']);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<List<_FollowUpOption>> _masterOptions(List<String> categories) async {
    final provider = context.read<LeadMasterProvider>();
    for (final category in categories) {
      final response = await provider.fetchMasterValues(
        masterCategory: category,
      );
      final options = _followUpOptions(response?.data);
      if (options.isNotEmpty) return options;
    }
    return const [];
  }

  Future<void> _loadOptions() async {
    final values = await Future.wait([
      _masterOptions(const ['status', 'lead_status', 'lead-status']),
      _masterOptions(const [
        'temperature',
        'lead_temperature',
        'lead-temperature',
      ]),
    ]);
    if (!mounted) return;
    setState(() {
      _statuses = values[0];
      _temperatures = values[1];
      _loadingOptions = false;
    });
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(context: context, initialTime: _time);
    if (value != null && mounted) setState(() => _time = value);
  }

  DateTime get _scheduledAt =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  String get _apiScheduledAt {
    final value = _scheduledAt;
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')} '
        '${value.hour < 12 ? 'AM' : 'PM'}';
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final reminderBody = <String, dynamic>{
      'scheduledAt': _apiScheduledAt,
      'remarks': _remarksController.text.trim(),
      'setReminder': _setReminder,
      'status': 'Rescheduled',
    };
    final leadBody = <String, dynamic>{
      ...reminderBody,
      if (_statusId != null) 'statusId': _statusId,
      if (_temperatureId != null) 'temperatureId': _temperatureId,
      if (_budget != null) 'budgetRange': _budget,
      if (_configuration != null) 'configuration': _configuration,
    };
    final provider = context.read<LeadProvider>();
    final leadResponse = await provider.updateLeadFromApi(
      leadId: widget.item.leadId!,
      body: leadBody,
    );
    if (leadResponse == null) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = provider.error ?? 'Unable to update the lead reminder.';
      });
      return;
    }
    final followUpResponse = await provider.updateFollowUp(
      leadId: widget.item.leadId!,
      followUpId: widget.item.id,
      body: reminderBody,
    );
    if (!mounted) return;
    if (followUpResponse == null) {
      setState(() {
        _saving = false;
        _error = provider.error ?? 'Unable to update the follow-up.';
      });
      return;
    }
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Follow-up rescheduled successfully.')),
    );
  }

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFD8E0EC)),
    ),
  );

  Widget _masterDropdown(
    String label,
    String? value,
    List<_FollowUpOption> options,
    ValueChanged<String?> onChanged,
  ) {
    final selected = options.any((option) => option.id == value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: _dropdownDecoration(label),
      hint: Text('Select $label'),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option.id,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: options.isEmpty ? null : onChanged,
    );
  }

  Widget _valueDropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final values = <String>{...options, ?value}.toList();
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _dropdownDecoration(label),
      hint: Text('Select $label'),
      items: values
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _dialogFieldGrid(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 500
            ? constraints.maxWidth
            : (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFD8E0EC)),
      ),
    );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 720.w, maxHeight: 760.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update reminder, status & remark',
                          style: GoogleFonts.inter(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Update lead fields, save the current follow-up remark, and create the next reminder for ${widget.item.leadName}.',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
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
              SizedBox(height: 18.h),
              if (_loadingOptions)
                const LinearProgressIndicator(minHeight: 2)
              else
                _dialogFieldGrid([
                  _masterDropdown(
                    'Lead Status',
                    _statusId,
                    _statuses,
                    (value) => setState(() => _statusId = value),
                  ),
                  _masterDropdown(
                    'Lead Type',
                    _temperatureId,
                    _temperatures,
                    (value) => setState(() => _temperatureId = value),
                  ),
                ]),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFDCE3ED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-up reminder',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final dateButton = OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            '${_date.day.toString().padLeft(2, '0')}/'
                            '${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(48.h),
                          ),
                        );
                        final timeButton = OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.schedule_rounded),
                          label: Text(_time.format(context)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(48.h),
                          ),
                        );
                        if (constraints.maxWidth < 480) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              dateButton,
                              SizedBox(height: 12.h),
                              timeButton,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: dateButton),
                            SizedBox(width: 12.w),
                            Expanded(child: timeButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _dialogFieldGrid([
                _valueDropdown(
                  'Budget',
                  _budget,
                  _budgetOptions,
                  (value) => setState(() => _budget = value),
                ),
                _valueDropdown(
                  'Configuration',
                  _configuration,
                  _configurationOptions,
                  (value) => setState(() => _configuration = value),
                ),
              ]),
              SizedBox(height: 16.h),
              TextField(
                controller: _remarksController,
                minLines: 3,
                maxLines: 5,
                decoration: decoration('Remark'),
              ),
              SizedBox(height: 8.h),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _setReminder,
                activeColor: AppColors.orangeStrong,
                title: Text(
                  'Set reminder for assigned owner',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
                onChanged: (value) =>
                    setState(() => _setReminder = value ?? true),
              ),
              if (_error != null) ...[
                SizedBox(height: 8.h),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeStrong,
                      foregroundColor: Colors.white,
                      minimumSize: Size(142.w, 48.h),
                    ),
                    child: _saving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpOption {
  const _FollowUpOption({required this.id, required this.label});

  final String id;
  final String label;

  factory _FollowUpOption.fromMap(Map<dynamic, dynamic> map) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
      return '';
    }

    final id = read(const ['id', '_id', 'value', 'slug', 'key']);
    final label = read(const [
      'name',
      'label',
      'title',
      'displayName',
      'value',
    ]);
    return _FollowUpOption(id: id, label: label.isEmpty ? id : label);
  }
}

String? _dialogText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == '-' ? null : text;
}

List<_FollowUpOption> _followUpOptions(Object? source) {
  if (source is List) {
    return source
        .map((item) {
          if (item is String) return _FollowUpOption(id: item, label: item);
          if (item is Map) return _FollowUpOption.fromMap(item);
          return const _FollowUpOption(id: '', label: '');
        })
        .where((option) => option.id.isNotEmpty && option.label.isNotEmpty)
        .toList();
  }
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'values',
      'masterValues',
    ]) {
      final options = _followUpOptions(source[key]);
      if (options.isNotEmpty) return options;
    }
  }
  return const [];
}

class _SummaryMetricsGrid extends StatelessWidget {
  const _SummaryMetricsGrid({required this.summary, required this.onSelect});

  final FollowUpQueueSummary summary;
  final ValueChanged<FollowUpListFilter> onSelect;
  static const double _cardHeight = 190;

  @override
  Widget build(BuildContext context) {
    final cards = [
      FollowUpMetricCardData(
        title: "Today's Follow-Ups",
        value: '${summary.todayCount}',
        subtitle: 'Due in the current queue',
        footer: '${summary.todayCount} total',
        icon: Icons.event_available_outlined,
        iconColor: AppColors.blueBright,
      ),
      FollowUpMetricCardData(
        title: 'Overdue Follow-Ups',
        value: '${summary.overdueCount}',
        subtitle: 'Needs immediate attention',
        footer: '${summary.overdueCount} delayed',
        icon: Icons.trending_up_rounded,
        iconColor: AppColors.orangeDeep,
      ),
      FollowUpMetricCardData(
        title: 'Upcoming Follow-Ups',
        value: '${summary.upcomingCount}',
        subtitle: 'Scheduled next actions',
        footer: '${summary.upcomingCount} upcoming',
        icon: Icons.calendar_month_outlined,
        iconColor: AppColors.greenDeep,
      ),
      FollowUpMetricCardData(
        title: 'Completed Today',
        value: '${summary.completedTodayCount}',
        subtitle: 'Marked complete',
        footer: '${summary.completedTodayCount} closed',
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.purpleDeep,
      ),
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12.w) / 2;
            return Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                for (var i = 0; i < cards.length; i++)
                  SizedBox(
                    width: width,
                    height: _cardHeight.h,
                    child: FollowUpMetricCard(
                      data: cards[i],
                      onTap: () => onSelect(switch (i) {
                        0 => FollowUpListFilter.today,
                        1 => FollowUpListFilter.overdue,
                        2 => FollowUpListFilter.upcoming,
                        _ => FollowUpListFilter.completed,
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: _cardHeight.h,
          child: FollowUpMetricCard(
            data: FollowUpMetricCardData(
              title: 'Pending Queue',
              value: '${summary.pendingCount}',
              subtitle: 'Open follow-up workload',
              footer: '${summary.pendingCount} total',
              icon: Icons.assignment_late_outlined,
              iconColor: AppColors.blueBright,
            ),
            onTap: () => onSelect(FollowUpListFilter.all),
          ),
        ),
      ],
    );
  }
}

class _QueueSlaSection extends StatelessWidget {
  const _QueueSlaSection({required this.summary});

  final FollowUpQueueSummary summary;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      FollowUpSlaTileData(
        value: summary.breachedCount.toString().padLeft(2, '0'),
        label: 'Breached follow-ups',
        badge: 'Breached',
        badgeColor: const Color(0xFFEF4444),
        badgeBackground: const Color(0xFFFFE8E8),
      ),
      FollowUpSlaTileData(
        value: summary.dueNextHourCount.toString().padLeft(2, '0'),
        label: 'Next 60 minutes',
        badge: 'Due Soon',
        badgeColor: const Color(0xFFF97316),
        badgeBackground: const Color(0xFFFFF1E8),
      ),
      FollowUpSlaTileData(
        value: summary.managerAttentionCount.toString().padLeft(2, '0'),
        label: 'Manager attention',
        badge: summary.managerAttentionCount > 0 ? 'Breached' : 'On Time',
        badgeColor: summary.managerAttentionCount > 0
            ? const Color(0xFFEF4444)
            : AppColors.greenDeep,
        badgeBackground: summary.managerAttentionCount > 0
            ? const Color(0xFFFFE8E8)
            : AppColors.greenBg,
      ),
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue SLA Snapshot',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Follow-up response health across the current queue',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          for (var i = 0; i < tiles.length; i++) ...[
            FollowUpSlaTile(data: tiles[i]),
            if (i != tiles.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _PipelineFilterTabs extends StatelessWidget {
  const _PipelineFilterTabs({required this.provider});

  final FollowUpsProvider provider;

  static const tabs = [
    'All',
    'New Lead',
    'Interested',
    'Hot Lead',
    'Site Visit Schedule',
    'Site Visit Done',
    'Re-Visit Done',
    'Follow Up',
    'OBM Done',
    'Not Interested',
    'Booking Done',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _FilterChip(
              label: '$tab (${provider.countForPipeline(tab)})',
              selected: provider.pipelineFilter == tab,
              onTap: () => provider.setPipelineFilter(tab),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy : Colors.white,
      borderRadius: BorderRadius.circular(999.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected ? AppColors.navy : const Color(0xFFD9E3EF),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.summary});

  final FollowUpQueueSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Completed',
        summary.completedCount,
        AppColors.greenDeep,
        AppColors.greenBg,
      ),
      (
        'Pending',
        summary.pendingStatusCount,
        AppColors.blueBright,
        const Color(0xFFEAF2FF),
      ),
      (
        'Contacted',
        summary.contactedCount,
        AppColors.purpleDeep,
        AppColors.purpleSoft,
      ),
      (
        'Best Slot',
        summary.dueNextHourCount,
        AppColors.orangeDeep,
        AppColors.orangeSoft,
      ),
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-Up Performance',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 10.w) / 2;
              return Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: width,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: item.$4,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$1,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: item.$3,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '${item.$2}',
                              style: GoogleFonts.inter(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
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

class _BestTimeSection extends StatelessWidget {
  const _BestTimeSection({required this.slots});

  final Map<String, int> slots;

  @override
  Widget build(BuildContext context) {
    final entries = slots.entries.toList();
    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Time to Follow-Up',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Derived from scheduled slots in the current queue',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          if (entries.isEmpty)
            Text(
              'No scheduled time slots yet.',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 10.w) / 2;
                final colors = [
                  AppColors.purpleBg,
                  AppColors.greenBg,
                  AppColors.softBlue,
                  AppColors.orangeBg,
                ];
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: [
                    for (var i = 0; i < entries.length; i++)
                      SizedBox(
                        width: width,
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE6ECF4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entries[i].key,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${entries[i].value} scheduled',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
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

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({required this.markedDays});

  final Set<int> markedDays;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    const months = [
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
    ];

    return FollowUpSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow-Up Calendar',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Current Queue View · ${months[now.month - 1]} ${now.year}',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday = day == now.day;
              final isMarked = markedDays.contains(day);
              return Container(
                margin: EdgeInsets.all(2.r),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.blueBright
                      : isMarked
                      ? AppColors.orangeSoft
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$day',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: isToday || isMarked
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isToday
                        ? Colors.white
                        : isMarked
                        ? AppColors.orangeDeep
                        : AppColors.navy,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 42.sp,
            color: AppColors.iconMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 12.h),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
