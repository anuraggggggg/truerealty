import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';

class TelecallerLeadDetailsScreen extends StatefulWidget {
  const TelecallerLeadDetailsScreen({super.key, this.lead});

  final LeadModel? lead;

  @override
  State<TelecallerLeadDetailsScreen> createState() =>
      _TelecallerLeadDetailsScreenState();
}

class _TelecallerLeadDetailsScreenState
    extends State<TelecallerLeadDetailsScreen> {
  Map<String, dynamic>? _lead;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lead = widget.lead?.raw;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLead());
  }

  Future<void> _loadLead() async {
    final id =
        widget.lead?.id ?? _value(_lead ?? const {}, const ['id', '_id']);
    if (id == '—' || id.isEmpty) {
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
    final payload = response?.data;
    final outer = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final nested = outer['data'];
    setState(() {
      if (nested is Map) {
        _lead = Map<String, dynamic>.from(nested);
      } else if (outer.isNotEmpty) {
        _lead = outer;
      }
      _loading = false;
      if (_lead == null) _error = 'Unable to load this lead.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _lead ?? widget.lead?.raw ?? const <String, dynamic>{};
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              Container(
                width: double.infinity,
                height: 156.h,
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Lead Details',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 28.w,
                        child: Icon(
                          Icons.more_horiz_rounded,
                          size: 22.sp,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -32.h),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                  child: Column(
                    children: [
                      if (_error != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      _RequirementsCard(data: data),
                      _CustomerInformationCard(data: data),
                      _LeadTimelineCard(data: data),
                      _CommunicationHistoryCard(data: data),
                      const _DetailsQuickActionsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCardShell extends StatelessWidget {
  const _DetailsCardShell({
    required this.title,
    required this.child,
    this.showEdit = true,
  });

  final String title;
  final Widget child;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE1E7F0)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.04),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (showEdit)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5FF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 13.sp,
                        color: AppColors.blueBright,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blueBright,
                        ),
                      ),
                    ],
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

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final requirement = _map(data['requirement']);
    final items = [
      _RequirementItem(
        icon: Icons.apartment_rounded,
        title: 'Property\nType',
        value: _valueFrom(
          [requirement, data],
          const ['propertyTypeName', 'propertyType', 'property_type'],
        ),
      ),
      _RequirementItem(
        icon: Icons.bed_rounded,
        title: 'BHK',
        value: _valueFrom(
          [requirement, data],
          const ['configurationName', 'configuration', 'bhk', 'unitType'],
        ),
      ),
      _RequirementItem(
        icon: Icons.calendar_today_rounded,
        title: 'Possession\nWithin',
        value: _valueFrom(
          [requirement, data],
          const ['possessionWithin', 'possession', 'possessionStatus'],
        ),
      ),
      _RequirementItem(
        icon: Icons.place_rounded,
        title: 'Preferred Area',
        value: _valueFrom(
          [requirement, data],
          const [
            'preferredLocation',
            'preferredArea',
            'location',
            'projectArea',
          ],
        ),
      ),
      _RequirementItem(
        icon: Icons.layers_rounded,
        title: 'Floor\nPreference',
        value: _valueFrom(
          [requirement, data],
          const ['floorPreference', 'preferredFloor', 'floor'],
        ),
      ),
    ];

    return _DetailsCardShell(
      title: 'Requirements',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: _RequirementTile(item: item),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFE7EDF4), height: 1),
          SizedBox(height: 12.h),
          Text(
            'Remarks',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _valueFrom(
              [requirement, data],
              const ['remarks', 'remark', 'notes', 'description'],
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementItem {
  const _RequirementItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({required this.item});

  final _RequirementItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, size: 19.sp, color: const Color(0xFF64748B)),
        SizedBox(height: 10.h),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 1.35,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _CustomerInformationCard extends StatelessWidget {
  const _CustomerInformationCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final requirement = _map(data['requirement']);
    final items = [
      _CustomerInfoItem(
        icon: Icons.call_rounded,
        title: 'Mobile Number',
        value: _value(data, const ['mobile', 'phone', 'phoneNumber', 'number']),
      ),
      _CustomerInfoItem(
        icon: Icons.work_rounded,
        title: 'Profession',
        value: _valueFrom(
          [data, requirement],
          const ['profession', 'occupation', 'jobTitle'],
        ),
      ),
      _CustomerInfoItem(
        icon: Icons.email_rounded,
        title: 'Email Address',
        value: _value(data, const ['email', 'emailAddress']),
      ),
      _CustomerInfoItem(
        icon: Icons.group_rounded,
        title: 'Family Size',
        value: _valueFrom(
          [data, requirement],
          const ['familySize', 'familyMembers'],
        ),
      ),
      _CustomerInfoItem(
        icon: Icons.place_rounded,
        title: 'Location',
        value: _valueFrom(
          [data, requirement],
          const [
            'address',
            'location',
            'city',
            'preferredLocation',
            'projectArea',
          ],
        ),
      ),
      _CustomerInfoItem(
        icon: Icons.currency_rupee_rounded,
        title: 'Budget',
        value: _budget(requirement, data),
      ),
    ];

    return _DetailsCardShell(
      title: 'Customer Information',
      child: Wrap(
        spacing: 12.w,
        runSpacing: 16.h,
        children: items
            .map(
              (item) => SizedBox(
                width: (1.sw - 50.w) / 2,
                child: _CustomerInfoTile(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CustomerInfoItem {
  const _CustomerInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _CustomerInfoTile extends StatelessWidget {
  const _CustomerInfoTile({required this.item});

  final _CustomerInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F5FA),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 16.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeadTimelineCard extends StatefulWidget {
  const _LeadTimelineCard({required this.data});

  final Map<String, dynamic> data;

  @override
  State<_LeadTimelineCard> createState() => _LeadTimelineCardState();
}

class _LeadTimelineCardState extends State<_LeadTimelineCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items =
        _listFrom(widget.data, const [
          'timeline',
          'activities',
          'activityTimeline',
          'leadActivities',
        ]).map((raw) {
          final status = _value(raw, const ['statusName', 'status']);
          final upcoming =
              status.toLowerCase().contains('upcoming') ||
              status.toLowerCase().contains('scheduled');
          final color = upcoming
              ? const Color(0xFF3B82F6)
              : const Color(0xFF22C55E);
          return _TimelineItem(
            dotColor: color,
            icon: _activityIcon(
              _value(raw, const ['type', 'activityType', 'title']),
            ),
            iconColor: color,
            title: _value(raw, const ['title', 'name', 'activityType', 'type']),
            time: _dateTime(
              _value(raw, const [
                'createdAt',
                'updatedAt',
                'performedAt',
                'activityAt',
                'scheduledAt',
                'date',
                'timestamp',
              ]),
            ),
            status: status,
            statusColor: color,
            statusBg: upcoming
                ? const Color(0xFFEAF2FF)
                : const Color(0xFFEAFBF2),
          );
        }).toList();
    final visibleItems = _expanded ? items : items.take(5).toList();

    return _DetailsCardShell(
      title: 'Lead Timeline',
      showEdit: false,
      child: items.isEmpty
          ? const Text('No timeline activity available.')
          : Column(
              children: [
                for (var i = 0; i < visibleItems.length; i++) ...[
                  _TimelineRow(item: visibleItems[i]),
                  if (i < visibleItems.length - 1)
                    const Divider(color: Color(0xFFF0F3F7), height: 1),
                ],
                if (items.length > 5) ...[
                  SizedBox(height: 6.h),
                  TextButton.icon(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18.sp,
                    ),
                    label: Text(
                      _expanded
                          ? 'Show less'
                          : 'View all ${items.length} activities',
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });

  final Color dotColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final Color statusBg;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item});

  final _TimelineItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18.h, right: 8.w),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: item.dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Icon(item.icon, size: 17.sp, color: item.iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          if (item.status != '—')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: item.statusBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                item.status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: item.statusColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommunicationHistoryCard extends StatelessWidget {
  const _CommunicationHistoryCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final rows = _listFrom(data, const [
      'communications',
      'communicationHistory',
      'callLogs',
      'interactions',
    ]);
    return _DetailsCardShell(
      title: 'Communication History',
      showEdit: false,
      child: rows.isEmpty
          ? const Text('No communication history available.')
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    const Divider(color: Color(0xFFE7EDF4), height: 24),
                  _CommunicationRow(
                    icon: _activityIcon(
                      _value(rows[i], const ['type', 'channel']),
                    ),
                    iconColor: const Color(0xFF22C55E),
                    title: _value(rows[i], const ['title', 'type', 'channel']),
                    subtitle: _value(rows[i], const [
                      'createdAt',
                      'date',
                      'timestamp',
                    ]),
                    trailingTextBottom: _value(rows[i], const [
                      'duration',
                      'messageCount',
                    ]),
                  ),
                ],
              ],
            ),
    );
  }
}

class _CommunicationRow extends StatelessWidget {
  const _CommunicationRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingTextBottom,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingTextBottom;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFBF2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (trailingTextBottom != null) ...[
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingTextBottom!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _DetailsQuickActionsCard extends StatelessWidget {
  const _DetailsQuickActionsCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      _QuickActionItem(
        icon: Icons.call_rounded,
        label: 'Call',
        bgColor: Color(0xFF22C55E),
      ),
      _QuickActionItem(
        icon: Icons.chat_rounded,
        label: 'WhatsApp',
        bgColor: Color(0xFF22C55E),
      ),
      _QuickActionItem(
        icon: Icons.calendar_today_rounded,
        label: 'Follow-up',
        bgColor: Color(0xFFFFF4EA),
        iconColor: Color(0xFFF97316),
      ),
      _QuickActionItem(
        icon: Icons.place_rounded,
        label: 'Schedule Visit',
        bgColor: Color(0xFFEAF2FF),
        iconColor: Color(0xFF3B82F6),
      ),
    ];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE1E7F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((item) => _QuickActionIconTile(item: item))
            .toList(),
      ),
    );
  }
}

class _QuickActionItem {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
}

class _QuickActionIconTile extends StatelessWidget {
  const _QuickActionIconTile({required this.item});

  final _QuickActionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: item.bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 20.sp, color: item.iconColor),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 68.w,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

String _value(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final raw = map[key];
    if (raw == null || raw is Map || raw is List) continue;
    final text = raw.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '—';
}

String _valueFrom(List<Map<String, dynamic>> maps, List<String> keys) {
  for (final map in maps) {
    final value = _value(map, keys);
    if (value != '—') return value;
  }
  return '—';
}

String _budget(Map<String, dynamic> requirement, Map<String, dynamic> data) {
  final range = _valueFrom(
    [requirement, data],
    const ['budgetRange', 'budget', 'budgetLabel'],
  );
  if (range != '—') return range;
  final minimum = _valueFrom(
    [requirement, data],
    const ['minimumBudget', 'minBudget', 'budgetMin'],
  );
  final maximum = _valueFrom(
    [requirement, data],
    const ['maximumBudget', 'maxBudget', 'budgetMax'],
  );
  if (minimum == '—' && maximum == '—') return '—';
  if (minimum == '—') return maximum;
  if (maximum == '—') return minimum;
  return '$minimum – $maximum';
}

List<Map<String, dynamic>> _listFrom(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }
  return const [];
}

IconData _activityIcon(String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('whatsapp') || normalized.contains('message')) {
    return Icons.chat_rounded;
  }
  if (normalized.contains('email')) return Icons.email_rounded;
  if (normalized.contains('follow') || normalized.contains('schedule')) {
    return Icons.calendar_today_rounded;
  }
  return Icons.call_rounded;
}

String _dateTime(String value) {
  if (value == '—') return '';
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
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
  final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final period = parsed.hour >= 12 ? 'PM' : 'AM';
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} • $hour:$minute $period';
}
