import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class MyLeadsFilterResult {
  const MyLeadsFilterResult({
    this.project,
    this.status,
    this.leadType,
    this.configuration,
    this.dateRange,
    this.customDate,
  });

  final String? project;
  final String? status;
  final String? leadType;
  final String? configuration;
  final MyLeadsDateRange? dateRange;
  final DateTime? customDate;

  bool get isEmpty =>
      project == null &&
      status == null &&
      leadType == null &&
      configuration == null &&
      dateRange == null;

  DateTime? get dateFrom {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (dateRange) {
      MyLeadsDateRange.lastWeek => today.subtract(const Duration(days: 7)),
      MyLeadsDateRange.lastMonth => DateTime(
        today.year,
        today.month - 1,
        today.day,
      ),
      MyLeadsDateRange.custom =>
        customDate == null
            ? null
            : DateTime(customDate!.year, customDate!.month, customDate!.day),
      null => null,
    };
  }

  DateTime? get dateTo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (dateRange) {
      MyLeadsDateRange.lastWeek || MyLeadsDateRange.lastMonth => today,
      MyLeadsDateRange.custom =>
        customDate == null
            ? null
            : DateTime(customDate!.year, customDate!.month, customDate!.day),
      null => null,
    };
  }
}

enum MyLeadsDateRange { lastWeek, lastMonth, custom }

extension MyLeadsDateRangeLabel on MyLeadsDateRange {
  String get label {
    return switch (this) {
      MyLeadsDateRange.lastWeek => 'Last 1 Week',
      MyLeadsDateRange.lastMonth => 'Last 1 Month',
      MyLeadsDateRange.custom => 'Custom Date',
    };
  }
}

class MyLeadsFilterScreen extends StatefulWidget {
  const MyLeadsFilterScreen({
    super.key,
    this.initial = const MyLeadsFilterResult(),
    this.projects = const [],
    this.statuses = const [],
    this.configurations = const [],
  });

  final MyLeadsFilterResult initial;
  final List<String> projects;
  final List<String> statuses;
  final List<String> configurations;

  @override
  State<MyLeadsFilterScreen> createState() => _MyLeadsFilterScreenState();
}

class _MyLeadsFilterScreenState extends State<MyLeadsFilterScreen> {
  String? _project;
  String? _status;
  String? _leadType;
  String? _configuration;
  MyLeadsDateRange? _dateRange;
  DateTime? _customDate;

  @override
  void initState() {
    super.initState();
    _project = widget.initial.project;
    _status = widget.initial.status;
    _leadType = widget.initial.leadType;
    _configuration = widget.initial.configuration;
    _dateRange = widget.initial.dateRange;
    _customDate = widget.initial.customDate;
    if (_dateRange == MyLeadsDateRange.custom && _customDate == null) {
      _customDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          'Filter leads',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(18.r),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Container(
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD9E3EF)),
                      ),
                      child: Column(
                        children: [
                          _dropdown(
                            label: 'Project',
                            value: _project,
                            values: widget.projects,
                            onChanged: (value) =>
                                setState(() => _project = value),
                          ),
                          SizedBox(height: 16.h),
                          _dropdown(
                            label: 'Status',
                            value: _status,
                            values: widget.statuses,
                            onChanged: (value) =>
                                setState(() => _status = value),
                          ),
                          SizedBox(height: 16.h),
                          _dropdown(
                            label: 'Lead Type',
                            value: _leadType,
                            values: const ['Hot', 'Warm', 'Cold'],
                            onChanged: (value) =>
                                setState(() => _leadType = value),
                          ),
                          SizedBox(height: 16.h),
                          _dropdown(
                            label: 'Configuration',
                            value: _configuration,
                            values: _configurationOptions,
                            onChanged: (value) =>
                                setState(() => _configuration = value),
                          ),
                          SizedBox(height: 16.h),
                          _dateRangeDropdown(),
                          if (_dateRange == MyLeadsDateRange.custom) ...[
                            SizedBox(height: 16.h),
                            _customDateField(context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              color: Colors.white,
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _project = null;
                        _status = null;
                        _leadType = null;
                        _configuration = null;
                        _dateRange = null;
                        _customDate = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      MyLeadsFilterResult(
                        project: _project,
                        status: _status,
                        leadType: _leadType,
                        configuration: _configuration,
                        dateRange: _dateRange,
                        customDate: _dateRange == MyLeadsDateRange.custom
                            ? _customDate
                            : null,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeStrong,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply filters'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> get _configurationOptions {
    const defaults = [
      '1 BHK',
      '2 BHK',
      '3 BHK',
      '4 BHK',
      '5 BHK',
      'Studio',
      'Penthouse',
    ];
    return {...defaults, ...widget.configurations}.toList();
  }

  Widget _dateRangeDropdown() {
    return DropdownButtonFormField<MyLeadsDateRange>(
      initialValue: _dateRange,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Date Range',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.r)),
      ),
      hint: const Text('All Dates'),
      items: [
        const DropdownMenuItem<MyLeadsDateRange>(
          value: null,
          child: Text('All Dates'),
        ),
        ...MyLeadsDateRange.values.map(
          (item) => DropdownMenuItem<MyLeadsDateRange>(
            value: item,
            child: Text(item.label),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _dateRange = value;
          if (value == MyLeadsDateRange.custom) {
            _customDate ??= DateTime.now();
          } else {
            _customDate = null;
          }
        });
      },
    );
  }

  Widget _customDateField(BuildContext context) {
    final value = _customDate;
    return InkWell(
      borderRadius: BorderRadius.circular(9.r),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: now,
        );
        if (picked != null && mounted) {
          setState(() => _customDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Custom Date',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.r)),
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: value == null ? const Color(0xFF64748B) : AppColors.navy,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    final options =
        values.toSet().where((item) => item.trim().isNotEmpty).toList()..sort();
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-${value ?? 'all'}'),
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.r)),
      ),
      hint: Text('All $label'),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('All $label')),
        ...options.map(
          (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
