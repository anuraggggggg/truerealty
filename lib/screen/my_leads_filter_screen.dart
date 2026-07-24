import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class MyLeadsFilterResult {
  const MyLeadsFilterResult({
    this.project,
    this.source,
    this.status,
    this.leadType,
  });

  final String? project;
  final String? source;
  final String? status;
  final String? leadType;

  bool get isEmpty =>
      project == null && source == null && status == null && leadType == null;
}

class MyLeadsFilterScreen extends StatefulWidget {
  const MyLeadsFilterScreen({
    super.key,
    this.initial = const MyLeadsFilterResult(),
    this.projects = const [],
    this.sources = const [],
    this.statuses = const [],
  });

  final MyLeadsFilterResult initial;
  final List<String> projects;
  final List<String> sources;
  final List<String> statuses;

  @override
  State<MyLeadsFilterScreen> createState() => _MyLeadsFilterScreenState();
}

class _MyLeadsFilterScreenState extends State<MyLeadsFilterScreen> {
  String? _project;
  String? _source;
  String? _status;
  String? _leadType;

  @override
  void initState() {
    super.initState();
    _project = widget.initial.project;
    _source = widget.initial.source;
    _status = widget.initial.status;
    _leadType = widget.initial.leadType;
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
                            label: 'Source',
                            value: _source,
                            values: widget.sources,
                            onChanged: (value) =>
                                setState(() => _source = value),
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
                            label: 'Temperature',
                            value: _leadType,
                            values: const ['Hot', 'Warm', 'Cold'],
                            onChanged: (value) =>
                                setState(() => _leadType = value),
                          ),
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
                        _source = null;
                        _status = null;
                        _leadType = null;
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
                        source: _source,
                        status: _status,
                        leadType: _leadType,
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
