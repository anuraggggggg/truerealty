import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';

class MyLeadsFilterScreen extends StatefulWidget {
  const MyLeadsFilterScreen({super.key});

  @override
  State<MyLeadsFilterScreen> createState() => _MyLeadsFilterScreenState();
}

class _MyLeadsFilterScreenState extends State<MyLeadsFilterScreen> {
  static const double _fieldLabelFontSize = 19;
  static const double _bodyFontSize = 18;
  static const double _sectionFontSize = 20;
  static const double _headerFontSize = 18;

  String _status = 'All';
  String _temperature = 'All';
  bool _slaBreachedOnly = false;

  static const List<String> _statusOptions = [
    'All',
    'New',
    'Contacted',
    'Qualified',
  ];

  static const List<String> _temperatureOptions = [
    'All',
    'Hot',
    'Warm',
    'Cold',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('LEAD DETAILS'),
                    SizedBox(height: 12.h),
                    _dropdownField('Project', 'All Projects'),
                    SizedBox(height: 12.h),
                    _dropdownField('Source', 'All Sources'),
                    SizedBox(height: 16.h),
                    Divider(color: const Color(0xFFE7EBF2), height: 1.h),
                    SizedBox(height: 16.h),
                    _sectionLabel('STATUS & ENGAGEMENT'),
                    SizedBox(height: 12.h),
                    CommonWidgets.fieldLabelScaled(
                      'Status',
                      fontSize: _fieldLabelFontSize,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _statusOptions
                          .map((item) => _choiceChip(
                                label: item,
                                selected: _status == item,
                                onTap: () => setState(() => _status = item),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 14.h),
                    CommonWidgets.fieldLabelScaled(
                      'Temperature',
                      fontSize: _fieldLabelFontSize,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _temperatureOptions
                          .map(
                            (item) => _choiceChip(
                              label: item,
                              selected: _temperature == item,
                              onTap: () => setState(() => _temperature = item),
                              showDot: item == 'Hot',
                              dotColor: const Color(0xFFFF7A1A),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: const Color(0xFFE7EBF2), height: 1.h),
                    SizedBox(height: 16.h),
                    _sectionLabel('ASSIGNMENT'),
                    SizedBox(height: 12.h),
                    CommonWidgets.fieldLabelScaled(
                      'Lead Owner',
                      fontSize: _fieldLabelFontSize,
                    ),
                    SizedBox(height: 8.h),
                    _searchField(),
                    SizedBox(height: 12.h),
                    _dropdownField('Manager', 'All Managers'),
                    SizedBox(height: 16.h),
                    Divider(color: const Color(0xFFE7EBF2), height: 1.h),
                    SizedBox(height: 16.h),
                    _sectionLabel('PERFORMANCE'),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'SLA Breached Only',
                            style: GoogleFonts.inter(
                              fontSize: _bodyFontSize.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF232A36),
                            ),
                          ),
                        ),
                        Switch(
                          value: _slaBreachedOnly,
                          onChanged: (value) {
                            setState(() => _slaBreachedOnly = value);
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF123464),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFD7DDEA),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    _dropdownField('Date Range', 'All Time'),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _status = 'All';
                                _temperature = 'All';
                                _slaBreachedOnly = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(38.h),
                              side: const BorderSide(color: Color(0xFFD6DCE8)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: _bodyFontSize.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2F3745),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(38.h),
                              backgroundColor: const Color(0xFFFF7A1A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Apply filter',
                              style: GoogleFonts.inter(
                                fontSize: _bodyFontSize.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(38.h),
                          backgroundColor: const Color(0xFFFF7A1A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Export leads',
                          style: GoogleFonts.inter(
                            fontSize: _bodyFontSize.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFD),
        border: Border(bottom: BorderSide(color: Color(0xFFE7EBF2))),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, size: 16.sp, color: const Color(0xFF1F2937)),
          ),
          SizedBox(width: 12.w),
          Text(
            'Filters',
            style: GoogleFonts.inter(
              fontSize: _headerFontSize.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: _sectionFontSize.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        color: const Color(0xFF7A8393),
      ),
    );
  }

  Widget _dropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonWidgets.fieldLabelScaled(label, fontSize: _fieldLabelFontSize),
        SizedBox(height: 7.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFD7DEE9)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: _bodyFontSize.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5A6472),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.sp,
                color: const Color(0xFF71798A),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD7DEE9)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15.sp, color: const Color(0xFF98A2B3)),
          SizedBox(width: 8.w),
          Text(
            'Search owners...',
            style: GoogleFonts.inter(
              fontSize: _bodyFontSize.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool showDot = false,
    Color dotColor = Colors.transparent,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected ? AppColors.navy : const Color(0xFFD7DEE9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Icon(Icons.local_fire_department_outlined, size: 10.sp, color: dotColor),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: _bodyFontSize.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
