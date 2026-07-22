import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_line/dotted_line.dart';

class TelecallerDocumentsTabContent extends StatelessWidget {
  const TelecallerDocumentsTabContent({super.key});

  static const _documents = [
    _DocumentItem(
      title: 'Trueroot Heights\nBrochure',
      subtitle: 'Brochure - 12 MB',
      meta: 'Added by Amit Verma • 22 May 2025, 11:20 AM',
      type: 'PDF',
      accent: Color(0xFFEF4444),
    ),
    _DocumentItem(
      title: 'Price Sheet - May 2025',
      subtitle: 'Price Sheet - 245 kB',
      meta: 'Added by Amit Verma • 22 May 2025, 11:29 AM',
      type: 'XLS',
      accent: Color(0xFF22C55E),
    ),
    _DocumentItem(
      title: 'Tentative Payment Plan',
      subtitle: 'Payment Plan - 512 kB',
      meta: 'Added by Amit Verma • 22 May 2025, 11:48 AM',
      type: 'PDF',
      accent: Color(0xFFEF4444),
    ),
    _DocumentItem(
      title: 'Typical Floor Plan\n(Tower A)',
      subtitle: 'Floor Plan - 820 kB',
      meta: 'Added by Amit Verma • 22 May 2025, 11:32 AM',
      type: 'XLS',
      accent: Color(0xFF22C55E),
    ),
    _DocumentItem(
      title: 'Agreement to Book',
      subtitle: 'Agreement - 1.5 MB',
      meta: 'Added by Amit Verma • 22 May 2025, 11:40 AM',
      type: 'PDF',
      accent: Color(0xFFEF4444),
    ),
    _DocumentItem(
      title: 'KYC - Rahul Mehta',
      subtitle: 'KYC - 756 kB',
      meta: 'Added by Rahul Mehta • 22 May 2025, 07:54 PM',
      type: 'PDF',
      accent: Color(0xFFEF4444),
    ),
    _DocumentItem(
      title: 'All Project Images',
      subtitle: 'Folder - 12 Files',
      meta: 'Added by Amit Verma • 22 May 2025, 11:02 PM',
      type: 'FOLDER',
      accent: Color(0xFFF59E0B),
    ),
    _DocumentItem(
      title: 'Location Map',
      subtitle: 'Others - 360 kB',
      meta: 'Added by Amit Verma • 22 May 2025, 01:21 PM',
      type: 'XLS',
      accent: Color(0xFF22C55E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DocumentsHeader(),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _documents.length; i++) ...[
                  _DocumentTile(item: _documents[i]),
                  if (i != _documents.length - 1)
                    Divider(height: 1, color: const Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _DottedUploadAttachmentBox(
            child: Padding(
              padding:EdgeInsetsGeometry.only(left: 60,right: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Text(
                          'Upload Attachment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.71,
                            letterSpacing: 0,
                            color: const Color(0xFF002149),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'PDF, JPG, PNG up to 10 MB',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )

          ),
        ],
      ),
    );
  }
}

class _DottedUploadAttachmentBox extends StatelessWidget {
  const _DottedUploadAttachmentBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = 12.r;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DottedLine(
                      lineLength: constraints.maxWidth,
                      dashColor: const Color(0xFFCFE0FF),
                      dashGapLength: 4.w,
                      dashLength: 4.w,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: constraints.maxHeight,
                      dashColor: const Color(0xFFCFE0FF),
                      dashGapLength: 4.h,
                      dashLength: 4.h,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: constraints.maxHeight,
                      dashColor: const Color(0xFFCFE0FF),
                      dashGapLength: 4.h,
                      dashLength: 4.h,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DottedLine(
                      lineLength: constraints.maxWidth,
                      dashColor: const Color(0xFFCFE0FF),
                      dashGapLength: 4.w,
                      dashLength: 4.w,
                      lineThickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
                    child: Center(child: child),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DocumentsHeader extends StatelessWidget {
  const _DocumentsHeader();

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('All', true),
      ('Brochures', false),
      ('Price Sheets', false),
      ('Floor Plans', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Documents (8)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.75, // line-height
                  letterSpacing: 0,
                  color: Color(0xFF000B20),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFD0D7E2)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.search_rounded,
                            size: 18.sp,
                            color: const Color(0xFF9AA4B2),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Search documents',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFD0D7E2)),
                    ),
                    child: Icon(
                      Icons.filter_alt_outlined,
                      size: 18.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final chip in chips) ...[
                _DocumentCategoryChip(
                  label: chip.$1,
                  isActive: chip.$2,
                ),
                SizedBox(width: 10.w),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentCategoryChip extends StatelessWidget {
  const _DocumentCategoryChip({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFF3EB) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isActive ? const Color(0xFFF97316) : const Color(0xFFD0D7E2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFFF97316) : const Color(0xFF667085),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.item});

  final _DocumentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: _DocumentTypeIcon(item: item),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: const Color(0xFF556377),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.meta,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.3,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            flex: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _ActionIcon(icon: Icons.file_download_outlined),
                SizedBox(width: 6),
                _ActionIcon(icon: Icons.remove_red_eye_outlined),
                SizedBox(width: 6),
                Icon(Icons.more_vert, size: 20, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTypeIcon extends StatelessWidget {
  const _DocumentTypeIcon({required this.item});

  final _DocumentItem item;

  @override
  Widget build(BuildContext context) {
    if (item.type == 'FOLDER') {
      return Icon(Icons.folder_rounded, size: 21.sp, color: item.accent);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.picture_as_pdf_outlined, size: 19.sp, color: item.accent),
        SizedBox(height: 3.h),
        Text(
          item.type,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: item.accent,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 15.sp, color: const Color(0xFF64748B)),
    );
  }
}

class _DocumentItem {
  const _DocumentItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.type,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String type;
  final Color accent;
}
