import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

class EmployeeDirectoryScreen extends StatelessWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldLight,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackToDirectoryButton(
              onTap: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(height: 20.h),
            const _EmployeeProfileCard(),
            SizedBox(height: 18.h),
            const _AttendanceSection(),
          ],
        ),
      ),
    );
  }
}

class _BackToDirectoryButton extends StatelessWidget {
  const _BackToDirectoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowBlack05,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 20.sp, color: AppColors.navy),
            SizedBox(width: 8.w),
            Text(
              'Back to directory',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeProfileCard extends StatelessWidget {
  const _EmployeeProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.leadDetailCardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 10.h),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.asset(
                    'assets/admin.png',
                    width: 66.w,
                    height: 66.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 66.w,
                      height: 66.w,
                      color: AppColors.avatarBg,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        size: 30.sp,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FIELD EXECUTIVE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Khushvinder Kaur',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.leadDetailDivider, height: 18.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'Employment profile and attendance records\nfor this employee.',
              style: TextStyle(
                color: AppColors.textBody,
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: const [
                _DetailTile(
                  title: 'DEPARTMENT',
                  value: '-',
                ),
                _DetailTile(
                  title: 'DESIGNATION',
                  value: 'Field Executive',
                ),
                _DetailTile(
                  title: 'JOINED ON',
                  value: '01 Jan 2025',
                ),
                _DetailTile(
                  title: 'BASE SALARY',
                  value: '\u20B935,000',
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const _FullWidthDetailTile(
            title: 'EMAIL',
            value: 'field.executive@gmail.com',
          ),
          SizedBox(height: 12.h),
          const _EmployeeCodeTile(
            title: 'EMPLOYEE CODE',
            code: 'EMP-8D1899AA',
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175.w,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullWidthDetailTile extends StatelessWidget {
  const _FullWidthDetailTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCodeTile extends StatelessWidget {
  const _EmployeeCodeTile({
    required this.title,
    required this.code,
  });

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.windowBlue,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  const _AttendanceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.leadDetailCardBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowBlack05,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'June 2026 summary',
                style: TextStyle(
                  color: AppColors.textBody,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: const [
                  _SummaryTile(
                    title: 'Present',
                    value: '0',
                    backgroundColor: Color(0xFFF2FFF6),
                    borderColor: Color(0xFFD6F0DB),
                  ),
                  _SummaryTile(
                    title: 'Absent',
                    value: '0',
                    backgroundColor: Color(0xFFFFF1F1),
                    borderColor: Color(0xFFF5D8D8),
                  ),
                  _SummaryTile(
                    title: 'Leave',
                    value: '0',
                    backgroundColor: Color(0xFFFFF6EF),
                    borderColor: Color(0xFFF3DEC9),
                  ),
                  _SummaryTile(
                    title: 'Holidays',
                    value: '0',
                    backgroundColor: Color(0xFFF8FAFF),
                    borderColor: Color(0xFFD8E2FF),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              const _TopTab(
                icon: Icons.calendar_today_outlined,
                label: 'Attendance',
                selected: true,
              ),
              SizedBox(width: 26.w),
              const _TopTab(
                icon: Icons.history,
                label: 'Payroll history',
                selected: false,
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Container(
            height: 1.2,
            color: AppColors.borderMuted,
          ),
        ),
        SizedBox(height: 42.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Attendance',
            style: TextStyle(
              color: const Color(0xFF09162F),
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Monthly attendance records for Khushvinder Kaur.',
            style: TextStyle(
              color: AppColors.textBody,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FE),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: _SegmentButton(
                    label: 'Calendar',
                    selected: true,
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'List',
                    selected: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),
        const _AttendanceCalendarCard(),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String title;
  final String value;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 174.w,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),



        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textBody,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.vividBlue : AppColors.textBody;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15.sp, color: color),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 3.h,
          width: selected ? 86.w : 0,
          decoration: BoxDecoration(
            color: AppColors.vividBlue,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: selected ? Border.all(color: AppColors.vividBlue) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF18223B) : AppColors.textSecondary,
            fontSize: 16.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _AttendanceCalendarCard extends StatelessWidget {
  const _AttendanceCalendarCard();

  static const List<String> _weekdays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  static const List<_CalendarDayData> _days = [
    _CalendarDayData(day: '31', muted: true, note: 'No entry'),
    _CalendarDayData(day: '1', note: 'Not in'),
    _CalendarDayData(day: '2', note: 'Not in'),
    _CalendarDayData(day: '3', note: 'Not in'),
    _CalendarDayData(day: '4', note: 'Not in'),
    _CalendarDayData(day: '5', note: 'Not in'),
    _CalendarDayData(day: '6', note: 'Not in'),
    _CalendarDayData(day: '7'),
    _CalendarDayData(day: '8', note: 'Not in'),
    _CalendarDayData(day: '9', note: 'Not in'),
    _CalendarDayData(day: '10', note: 'Not in'),
    _CalendarDayData(day: '11', note: 'Not in'),
    _CalendarDayData(day: '12', note: 'Not in'),
    _CalendarDayData(day: '13', note: 'Not in'),
    _CalendarDayData(day: '14'),
    _CalendarDayData(day: '15', note: 'Not in'),
    _CalendarDayData(day: '16'),
    _CalendarDayData(day: '17'),
    _CalendarDayData(day: '18'),
    _CalendarDayData(day: '19'),
    _CalendarDayData(day: '20'),
    _CalendarDayData(day: '21'),
    _CalendarDayData(day: '22'),
    _CalendarDayData(day: '23'),
    _CalendarDayData(day: '24'),
    _CalendarDayData(day: '25'),
    _CalendarDayData(day: '26', highlighted: true),
    _CalendarDayData(day: '27'),
    _CalendarDayData(day: '28'),
    _CalendarDayData(day: '29', note: 'Not in'),
    _CalendarDayData(day: '30'),
    _CalendarDayData(day: '1', muted: true, note: 'No entry'),
    _CalendarDayData(day: '2', muted: true, note: 'No entry'),
    _CalendarDayData(day: '3', muted: true, note: 'No entry'),
    _CalendarDayData(day: '4', muted: true, note: 'No entry'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.leadDetailCardBorder),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowBlack05,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 10.h),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            child: _FilterButton(label: 'June'),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _FilterButton(label: 'All statuses'),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: const [
                          _OutlineChip(label: 'Today'),
                          SizedBox(width: 14),
                          Expanded(
                            child: _MonthNavigator(),
                          ),
                          SizedBox(width: 14),
                          _IconChip(),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.leadDetailDivider),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          children: _weekdays
                              .map(
                                (day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _days.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 0.78,
                            ),
                        itemBuilder: (context, index) {
                          final day = _days[index];
                          return _CalendarCell(data: day);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 10.h,
            children: const [
              _LegendChip(
                color: Color(0xFF20C16A),
                label: 'Present',
              ),
              _LegendChip(
                color: Color(0xFFC62828),
                label: 'Absent',
              ),
              _LegendChip(
                color: Color(0xFF2563EB),
                label: 'Holiday',
              ),
              _LegendChip(
                color: Color(0xFFA855F7),
                label: 'Leave',
              ),
              _LegendChip(
                color: Color(0xFFFF7A1A),
                label: 'Late',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF1F2937),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.chevron_left, size: 22.sp, color: AppColors.textSecondary),
          Text(
            'June 2026',
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.chevron_right, size: 22.sp, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.orangeAccent),
      ),
      child: Icon(Icons.download_outlined, size: 18.sp, color: AppColors.orangeAccent),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({required this.data});

  final _CalendarDayData data;

  @override
  Widget build(BuildContext context) {
    final dayColor = data.highlighted
        ? AppColors.vividBlue
        : data.muted
        ? AppColors.textTertiary
        : const Color(0xFF374151);

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.leadDetailDivider),
          right: BorderSide(color: AppColors.leadDetailDivider),
        ),
      ),
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Text(
              data.day,
              style: TextStyle(
                color: dayColor,
                fontSize: 14.sp,
                fontWeight: data.highlighted ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const Spacer(),
          if (data.note != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: data.note == 'No entry'
                  ? Text(
                      data.note!,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FA),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '\u2022 ${data.note}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowBlack05,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF1F2937),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayData {
  const _CalendarDayData({
    required this.day,
    this.note,
    this.muted = false,
    this.highlighted = false,
  });

  final String day;
  final String? note;
  final bool muted;
  final bool highlighted;
}
