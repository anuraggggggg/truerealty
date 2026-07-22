import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddActivityScreen extends StatelessWidget {
  const AddActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              SizedBox(height: 18.h),
              Text(
                'Add Activity',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16325C),
                ),
              ),
              SizedBox(height: 10.h),
              _buildBreadcrumbs(),
              SizedBox(height: 18.h),
              const _LeadSummaryCard(),
              SizedBox(height: 20.h),
              Text(
                'Activity Information',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16325C),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: const [
                  Expanded(
                    child: _FieldCard(
                      label: 'Activity Type',
                      requiredMark: true,
                      value: 'Follow-up Call',
                      icon: Icons.phone_in_talk_outlined,
                      hasDropdown: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _FieldCard(
                      label: 'Related To',
                      requiredMark: true,
                      value: 'Lead',
                      icon: Icons.person_outline,
                      hasDropdown: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: const [
                  Expanded(
                    child: _FieldCard(
                      label: 'Date',
                      requiredMark: true,
                      value: '20 May 2025',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _FieldCard(
                      label: 'Time',
                      requiredMark: true,
                      value: '11:30 AM',
                      icon: Icons.access_time,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: const [
                  Expanded(
                    child: _FieldCard(
                      label: 'Duration',
                      value: '15 mins',
                      icon: Icons.timer_outlined,
                      hasDropdown: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _FieldCard(
                      label: 'Priority',
                      value: 'High',
                      icon: Icons.star_border,
                      hasDropdown: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              const _AssignedToCard(),
              SizedBox(height: 14.h),
              const _FieldCard(
                label: 'Outcome / Result',
                requiredMark: true,
                value: 'Interested',
                icon: Icons.access_time,
                hasDropdown: true,
              ),
              SizedBox(height: 14.h),
              const _TextInputCard(
                label: 'Subject',
                value: 'Discussed budget and site visit',
                icon: Icons.description_outlined,
                counterText: '34/120',
              ),
              SizedBox(height: 14.h),
              const _NotesCard(),
              SizedBox(height: 18.h),
              Text(
                'Add Call Recording',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16325C),
                ),
              ),
              SizedBox(height: 10.h),
              const _UploadCard(
                icon: Icons.graphic_eq,
                iconBg: Color(0xffEEF4FF),
                iconColor: Color(0xff2563EB),
                title: 'Upload call recording',
                subtitle: 'MP3, WAV or M4A (Max 10MB)',
              ),
              SizedBox(height: 16.h),
              Text(
                'Add Attachment (Optional)',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff16325C),
                ),
              ),
              SizedBox(height: 10.h),
              const _UploadCard(
                icon: Icons.attach_file,
                iconBg: Color(0xffECFDF3),
                iconColor: Color(0xff22C55E),
                title: 'Upload files or documents',
                subtitle: 'PDF, DOC, JPG or PNG (Max 10MB)',
              ),
              SizedBox(height: 22.h),
              const _BottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final muted = const Color(0xff7C8CA5);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text('Dashboard', style: TextStyle(fontSize: 14.sp, color: muted)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(Icons.chevron_right, size: 15.sp, color: muted),
          ),
          Text('Leads', style: TextStyle(fontSize: 14.sp, color: const Color(0xffFF6B00))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(Icons.chevron_right, size: 15.sp, color: muted),
          ),
          Text('Rahul Sharma', style: TextStyle(fontSize: 14.sp, color: const Color(0xffFF6B00))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(Icons.chevron_right, size: 15.sp, color: muted),
          ),
          Text('Add Activity', style: TextStyle(fontSize: 14.sp, color: muted)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.arrow_back_ios_new, size: 18.sp, color: const Color(0xff16325C)),
        SizedBox(width: 18.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'TRUE',
                    style: TextStyle(
                      color: const Color(0xffFF6B00),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'ROOT',
                    style: TextStyle(
                      color: const Color(0xff16325C),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'REALTY',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff16325C),
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'PROPERTY WAHI JO HAI SAHI',
              style: TextStyle(
                fontSize: 7.sp,
                color: const Color(0xffFF8A00),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.search, size: 20.sp, color: const Color(0xff16325C)),
        SizedBox(width: 10.w),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none, size: 21.sp, color: const Color(0xff16325C)),
            Positioned(
              top: -4,
              right: -3,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: const BoxDecoration(color: Color(0xffFF6B00), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('12', style: TextStyle(fontSize: 8.sp, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 11.r,
          backgroundColor: const Color(0xffE2E8F0),
          child: Icon(Icons.person, size: 13.sp, color: const Color(0xff64748B)),
        ),
      ],
    );
  }
}

class _LeadSummaryCard extends StatelessWidget {
  const _LeadSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xffDCE4EE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0F172A).withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21.r,
                backgroundColor: const Color(0xffEAF1FF),
                child: Text('RS', style: TextStyle(fontSize: 17.sp, color: const Color(0xff3B5CCC), fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rahul Sharma',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xff16325C)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          ),
                          Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xffDBEAFE),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text('Contacted', style: TextStyle(fontSize: 13.sp, color: const Color(0xff2563EB), fontWeight: FontWeight.w700)),
                          ),
                          ],
                          ),
                          SizedBox(height: 4.h),
                          Text('LD-2025-001248', style: TextStyle(fontSize: 16.sp, color: const Color(0xff475569))),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 20.sp, color: const Color(0xff475569)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(child: _MiniInfo(icon: Icons.call_outlined, text: '+91 98765 43210')),
              Expanded(child: _MiniInfo(icon: Icons.location_on_outlined, text: 'Noida, Uttar Pradesh')),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: const [
              Expanded(child: _MiniInfo(icon: Icons.apartment_outlined, text: '2 BHK Apartment')),
              Expanded(child: _MiniInfo(icon: Icons.circle, dotGreen: true, text: 'Amit Singh (Telecaller)')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.text, this.dotGreen = false});

  final IconData icon;
  final String text;
  final bool dotGreen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: dotGreen ? 8.sp : 15.sp, color: dotGreen ? const Color(0xff6FCF97) : const Color(0xff475569)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16.sp, color: const Color(0xff475569)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.value,
    required this.icon,
    this.requiredMark = false,
    this.hasDropdown = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool requiredMark;
  final bool hasDropdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w600),
            ),
            if (requiredMark)
              Text(
                ' *',
                style: TextStyle(fontSize: 17.sp, color: const Color(0xffEF4444), fontWeight: FontWeight.w700),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xffDCE4EE)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xff64748B)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasDropdown)
                Icon(Icons.keyboard_arrow_down, size: 18.sp, color: const Color(0xff64748B)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssignedToCard extends StatelessWidget {
  const _AssignedToCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Assigned To',
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w600),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 17.sp, color: const Color(0xffEF4444), fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xffDCE4EE)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: const Color(0xff1F2937),
                child: Icon(Icons.person, size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amit Singh', style: TextStyle(fontSize: 18.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w700)),
                    SizedBox(height: 2.h),
                    Text('Telecaller', style: TextStyle(fontSize: 15.sp, color: const Color(0xff94A3B8))),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 18.sp, color: const Color(0xff64748B)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TextInputCard extends StatelessWidget {
  const _TextInputCard({
    required this.label,
    required this.value,
    required this.icon,
    this.requiredMark = false,
    this.counterText,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool requiredMark;
  final String? counterText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w600),
            ),
            if (requiredMark)
              Text(
                ' *',
                style: TextStyle(fontSize: 17.sp, color: const Color(0xffEF4444), fontWeight: FontWeight.w700),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xffDCE4EE)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xff64748B)),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (counterText != null)
                Text(
                  counterText!,
                  style: TextStyle(fontSize: 15.sp, color: const Color(0xff64748B)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Notes',
              style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w600),
            ),
            Text(
              ' *',
              style: TextStyle(fontSize: 17.sp, color: const Color(0xffEF4444), fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xffDCE4EE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spoke with Rahul regarding 2 BHK apartments in\nNoida.\nHe is interested in visiting the Green Valley\nResidency project.',
                style: TextStyle(
                  fontSize: 17.sp,
                  height: 1.65,
                  color: const Color(0xff16325C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '138/1000',
                  style: TextStyle(fontSize: 15.sp, color: const Color(0xff64748B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xffFFCAA8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: iconColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 17.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 15.sp, color: const Color(0xff64748B)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xffDCE4EE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            ),
            icon: Icon(Icons.file_upload_outlined, size: 14.sp, color: const Color(0xff16325C)),
            label: Text(
              'Upload File',
              style: TextStyle(fontSize: 15.sp, color: const Color(0xff16325C), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xff2563EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 18.sp, color: const Color(0xff2563EB), fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF97316),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Save Activity',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.check, size: 16.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
