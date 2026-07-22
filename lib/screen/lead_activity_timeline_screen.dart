import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';

const double _timelineFontScale = 0.92;

double _timelineFontSize(double size) => size * _timelineFontScale;

class LeadActivityTimelineSection extends StatelessWidget {
  const LeadActivityTimelineSection({super.key});

  static final List<_TimelineEvent> _events = [
    _TimelineEvent(
      tone: _TimelineTone.green,
      icon: Icons.person_add_alt_1_rounded,
      title: 'New Lead Assigned',
      subtitle: 'Lead assigned to you',
      date: '22 May 2025',
      time: '10:30 AM',
    ),
    _TimelineEvent(
      tone: _TimelineTone.blue,
      icon: Icons.call_outlined,
      title: 'First Call',
      subtitle: 'You called the lead',
      date: '22 May 2025',
      time: '11:15 AM',
      details: const [
        _TimelineDetail(
          label: 'Call Duration',
          value: '04:32 min',
          accent: Color(0xFF2563EB),
        ),
        _TimelineDetail(
          label: 'Call Disposition',
          value: 'Interested',
          accent: Color(0xFF2563EB),
        ),
        _TimelineDetail(
          label: 'Notes',
          value: 'Custom short notes entered in 3 BHK.',
          isNote: true,
        ),
      ],
    ),
    _TimelineEvent(
      tone: _TimelineTone.orange,
      icon: Icons.event_note_outlined,
      title: 'Follow-up Scheduled',
      subtitle: 'Follow-up scheduled',
      date: '23 May 2025',
      time: '11:00 AM',
      details: const [
        _TimelineDetail(label: 'Follow-up Type', value: 'Phone Call'),
        _TimelineDetail(label: 'Scheduled On', value: '24 May 2025, 11:30 AM'),
        _TimelineDetail(label: 'Reminder', value: '15 min before'),
      ],
    ),
    _TimelineEvent(
      tone: _TimelineTone.purple,
      icon: Icons.support_agent_outlined,
      title: 'Follow-up Call',
      subtitle: 'You called the lead',
      date: '24 May 2025',
      time: '11:22 AM',
      details: const [
        _TimelineDetail(
          label: 'Call Duration',
          value: '06:18 min',
          accent: Color(0xFF7C3AED),
        ),
        _TimelineDetail(
          label: 'Call Disposition',
          value: 'Interested',
          accent: Color(0xFF7C3AED),
        ),
        _TimelineDetail(
          label: 'Notes',
          value: 'Prefers site visit this weekend.',
          isNote: true,
        ),
      ],
    ),
    _TimelineEvent(
      tone: _TimelineTone.green,
      icon: Icons.apartment_outlined,
      title: 'Site Visit Scheduled',
      subtitle: 'Site visit scheduled',
      date: '25 May 2025',
      time: '04:00 PM',
      details: const [
        _TimelineDetail(
          label: 'Project',
          value: 'Trueroot Heights',
          accent: Color(0xFF009D6C),
        ),
        _TimelineDetail(
          label: 'Date & Time',
          value: '26 May 2025, 03:30 PM',
          accent: Color(0xFF009D6C),
        ),
        _TimelineDetail(label: 'With', value: 'Sales Executive'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.leadDetailCardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.05),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Lead Activity Timeline',
                    style: GoogleFonts.manrope(
                      fontSize: _timelineFontSize(14),
                      fontWeight: FontWeight.w600, // 600 = SemiBold
                      height: 1.43, // line-height
                      letterSpacing: 0,
                      color: const Color(0xFF002149),
                    ),
                  ),
                ),

                Text(
                  'Expand All',
                  style: GoogleFonts.inter(
                    fontSize: _timelineFontSize(12),
                    fontWeight: FontWeight.w600, // SemiBold
                    height: 1.33, // line-height
                    letterSpacing: 0.6,
                    color: const Color(0xFFF97316),
                  ),
                ),

                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: AppColors.orangeDeep,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            for (var i = 0; i < _events.length; i++) ...[
              _TimelineRow(
                event: _events[i],
                showConnector: i != _events.length - 1,
              ),
              if (i != _events.length - 1) SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event, required this.showConnector});

  final _TimelineEvent event;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final tone = _toneData(event.tone);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30.w,
          child: Column(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: tone.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(event.icon, size: 13.sp, color: tone.foreground),
              ),
              if (showConnector)
                Container(
                  width: 1.5,
                  height: event.details.isEmpty ? 38.h : 106.h,
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: tone.line,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: <String>{
                                    'New Lead Assigned',
                                    'First Call',
                                    'Follow-up Scheduled',
                                    'Follow-up Call',
                                    'Site Visit Scheduled',
                                  }.contains(event.title)
                              ? GoogleFonts.inter(
                                  fontSize: _timelineFontSize(17),
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  color: const Color(0xFF002149),
                                )
                              : GoogleFonts.inter(
                                  fontSize: _timelineFontSize(18).sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          event.subtitle,
                          style: <String>{
                                    'Lead assigned to you',
                                    'You called the lead',
                                    'Follow-up scheduled',
                                    'Site visit scheduled',
                                  }.contains(event.subtitle)
                              ? GoogleFonts.inter(
                                  fontSize: _timelineFontSize(14),
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal,
                                  height: 1.33,
                                  letterSpacing: 0,
                                  color: const Color(0xFF74777F),
                                )
                              : GoogleFonts.inter(
                                  fontSize: _timelineFontSize(15).sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 88.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          event.date,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: _timelineFontSize(16).sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          event.time,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: _timelineFontSize(16).sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (event.details.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _TimelineDetailCard(event: event, tone: tone),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineDetailCard extends StatelessWidget {
  const _TimelineDetailCard({required this.event, required this.tone});

  final _TimelineEvent event;
  final _TimelineToneData tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: tone.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < event.details.length; i++) ...[
            Expanded(
              child: _TimelineDetailCell(
                detail: event.details[i],
                defaultAccent: tone.foreground,
              ),
            ),
            if (i != event.details.length - 1)
              Container(
                width: 1,
                height: 44.h,
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                color: tone.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _TimelineDetailCell extends StatelessWidget {
  const _TimelineDetailCell({
    required this.detail,
    required this.defaultAccent,
  });

  final _TimelineDetail detail;
  final Color defaultAccent;

  @override
  Widget build(BuildContext context) {
    final useMutedLabelStyle = <String>{
      'Call Duration',
      'Call Disposition',
      'Notes',
      'Follow-up Type',
      'Scheduled On',
      'Reminder',
      'Project',
      'Date & Time',
      'With',
    }.contains(detail.label);
    final useMutedValueStyle = <String>{
      'Scheduled On',
      'Date & Time',
      'Reminder',
    }.contains(detail.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.label.toUpperCase(),
          style: useMutedLabelStyle
              ? GoogleFonts.inter(
                  fontSize: _timelineFontSize(12),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0.45,
                  color: const Color(0xFF74777F),
                )
              : GoogleFonts.inter(
                  fontSize: _timelineFontSize(14).sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: const Color(0xFF94A3B8),
                ),
        ),
        SizedBox(height: 6.h),
        Text(
          detail.value,
          style: detail.isNote
              ? GoogleFonts.inter(
                  fontSize: _timelineFontSize(11),
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: 0,
                  color: const Color(0xFF44474E),
                )
              : useMutedValueStyle
                  ? GoogleFonts.inter(
                      fontSize: _timelineFontSize(17),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0,
                      color: const Color(0xFF74777F),
                    )
              : GoogleFonts.inter(
                  fontSize: detail.accent != null
                      ? _timelineFontSize(12)
                      : _timelineFontSize(15).sp,
                  fontWeight:
                      detail.accent != null ? FontWeight.w500 : FontWeight.w600,
                  height: detail.accent != null ? 1.33 : 1.35,
                  letterSpacing: 0,
                  color: detail.accent ?? defaultAccent,
                ),
        ),
      ],
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.tone,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    this.details = const [],
  });

  final _TimelineTone tone;
  final IconData icon;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final List<_TimelineDetail> details;
}

class _TimelineDetail {
  const _TimelineDetail({
    required this.label,
    required this.value,
    this.accent,
    this.isNote = false,
  });

  final String label;
  final String value;
  final Color? accent;
  final bool isNote;
}

enum _TimelineTone { green, blue, orange, purple }

class _TimelineToneData {
  const _TimelineToneData({
    required this.background,
    required this.surface,
    required this.border,
    required this.divider,
    required this.line,
    required this.foreground,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color divider;
  final Color line;
  final Color foreground;
}

_TimelineToneData _toneData(_TimelineTone tone) {
  return switch (tone) {
    _TimelineTone.green => const _TimelineToneData(
      background: Color(0xFFE8F8EC),
      surface: Color(0xFFF6FBF7),
      border: Color(0xFFD7EFDF),
      divider: Color(0xFFD7EFDF),
      line: Color(0xFFA7D7B8),
      foreground: Color(0xFF16A34A),
    ),
    _TimelineTone.blue => const _TimelineToneData(
      background: Color(0xFFE8F0FF),
      surface: Color(0xFFF6F9FF),
      border: Color(0xFFD7E4FF),
      divider: Color(0xFFD7E4FF),
      line: Color(0xFFB6CBFF),
      foreground: Color(0xFF2563EB),
    ),
    _TimelineTone.orange => const _TimelineToneData(
      background: Color(0xFFFFF1E8),
      surface: Color(0xFFFFF8F4),
      border: Color(0xFFFFE1CF),
      divider: Color(0xFFFFE1CF),
      line: Color(0xFFF4C29F),
      foreground: Color(0xFFF97316),
    ),
    _TimelineTone.purple => const _TimelineToneData(
      background: Color(0xFFF3E8FF),
      surface: Color(0xFFFBF7FF),
      border: Color(0xFFE8D8FF),
      divider: Color(0xFFE8D8FF),
      line: Color(0xFFD1B5FF),
      foreground: Color(0xFF7C3AED),
    ),
  };
}
