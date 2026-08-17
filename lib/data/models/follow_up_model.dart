class FollowUpModel {
  const FollowUpModel({
    required this.id,
    required this.leadId,
    required this.type,
    required this.status,
    required this.leadName,
    required this.leadDisplayId,
    required this.phone,
    required this.source,
    required this.project,
    required this.configuration,
    required this.location,
    required this.leadStatus,
    required this.leadType,
    required this.assignedToName,
    required this.nextAction,
    required this.notes,
    required this.scheduledAt,
    required this.completedAt,
    required this.lastContactAt,
    required this.slaDueAt,
    this.leadRaw,
  });

  final String id;
  final String? leadId;
  final String type;
  final String status;
  final String leadName;
  final String? leadDisplayId;
  final String phone;
  final String source;
  final String project;
  final String configuration;
  final String location;
  final String leadStatus;
  final String leadType;
  final String assignedToName;
  final String? nextAction;
  final String? notes;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime? lastContactAt;
  final DateTime? slaDueAt;
  final Map<String, dynamic>? leadRaw;

  bool get isClosed {
    final normalized = status.toLowerCase();
    return completedAt != null ||
        normalized.contains('completed') ||
        normalized.contains('done') ||
        normalized.contains('cancelled') ||
        normalized.contains('canceled') ||
        normalized.contains('closed');
  }

  bool get isOverdue {
    final date = scheduledAt;
    if (date == null || isClosed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  bool isDueToday([DateTime? now]) {
    final date = scheduledAt;
    if (date == null || isClosed) return false;
    final reference = now ?? DateTime.now();
    return date.year == reference.year &&
        date.month == reference.month &&
        date.day == reference.day;
  }

  bool isUpcoming([DateTime? now]) {
    final date = scheduledAt;
    if (date == null || isClosed || isOverdue) return false;
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    return date.isAfter(
          today
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1)),
        ) ||
        (!isDueToday(reference) && date.isAfter(reference));
  }

  bool get isCompletedToday {
    final date = completedAt;
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isDueWithinHours(int hours, [DateTime? now]) {
    final date = scheduledAt;
    if (date == null || isClosed) return false;
    final reference = now ?? DateTime.now();
    return !date.isBefore(reference) &&
        date.isBefore(reference.add(Duration(hours: hours)));
  }

  bool get isSlaBreached {
    if (isClosed) return false;
    if (isOverdue) return true;
    final sla = slaDueAt;
    if (sla == null) return false;
    return sla.isBefore(DateTime.now());
  }

  String get propertyLine {
    final parts = [
      if (configuration.trim().isNotEmpty) configuration.trim(),
      if (location.trim().isNotEmpty) location.trim(),
    ];
    if (parts.isEmpty) return project;
    return parts.join(' | ');
  }

  String get statusLabel => isOverdue ? 'Overdue' : status;

  String get completionLabel => isClosed ? 'Done' : 'Not Done';

  String get leadStatusLabel {
    final value = leadStatus.trim();
    if (value.isEmpty || value == '-') return 'Not Set';
    return value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  factory FollowUpModel.fromJson(Object? source) {
    final map = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    final leadValue = map['lead'];
    final lead = leadValue is Map
        ? Map<String, dynamic>.from(leadValue)
        : <String, dynamic>{};
    final requirement = lead['requirement'] is Map
        ? Map<String, dynamic>.from(lead['requirement'] as Map)
        : const <String, dynamic>{};

    final countryCode = _readString(lead, const [
      'mobileCountryCode',
      'countryCode',
    ]);
    final mobile = _readString(lead, const [
      'mobile',
      'phone',
      'contactNumber',
    ]);
    final phone = [
      if (countryCode != null && countryCode.isNotEmpty) countryCode,
      if (mobile != null && mobile.isNotEmpty) mobile,
    ].join(' ').trim();

    return FollowUpModel(
      id:
          _readString(map, const ['id', '_id', 'followUpId']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      leadId:
          _readString(map, const ['leadId', 'lead_id']) ??
          _readString(lead, const ['id', '_id', 'leadId']),
      type:
          _readString(map, const ['typeName', 'typeId', 'type']) ?? 'Follow-up',
      status:
          _readString(map, const ['statusName', 'statusId', 'status']) ??
          'Scheduled',
      leadName:
          _readString(lead, const ['name', 'leadName', 'customerName']) ??
          'Unknown Lead',
      leadDisplayId: _readString(lead, const ['displayId', 'display_id']),
      phone: phone.isEmpty ? '-' : phone,
      source: _readString(lead, const ['sourceName', 'source']) ?? '-',
      project:
          _readString(lead, const ['projectName', 'project']) ??
          _readString(requirement, const [
            'preferredProjectId',
            'preferredProject',
          ]) ??
          'Project not assigned',
      configuration:
          _readString(requirement, const ['configuration', 'bhk']) ?? '',
      location:
          _readString(lead, const [
            'projectArea',
            'preferredLocation',
            'location',
          ]) ??
          _readString(requirement, const ['preferredLocation', 'location']) ??
          '',
      leadStatus:
          _readString(lead, const ['statusName', 'status', 'leadStatus']) ??
          '-',
      leadType:
          _readString(lead, const [
            'leadType',
            'temperatureName',
            'temperature',
          ]) ??
          '-',
      assignedToName:
          _readString(map, const [
            'assignedToName',
            'ownerName',
            'telecallerName',
            'fieldExecutiveName',
          ]) ??
          _readString(lead, const [
            'fieldExecutiveName',
            'telecallerName',
            'ownerName',
          ]) ??
          '-',
      nextAction: _readString(map, const ['nextAction', 'next_action']),
      notes: _readString(map, const ['notes', 'remarks']),
      scheduledAt: _readDate(map, const [
        'scheduledAt',
        'followUpDate',
        'dueAt',
      ]),
      completedAt: _readDate(map, const ['completedAt', 'completed_at']),
      lastContactAt:
          _readDate(map, const ['lastContactAt', 'last_contact_at']) ??
          _readDate(lead, const ['lastContactedAt', 'last_contacted_at']),
      slaDueAt: _readDate(map, const ['slaDueAt', 'sla_due_at']),
      leadRaw: lead.isEmpty ? null : lead,
    );
  }
}

class FollowUpQueueSummary {
  const FollowUpQueueSummary({
    required this.todayCount,
    required this.overdueCount,
    required this.upcomingCount,
    required this.completedTodayCount,
    required this.pendingCount,
    required this.breachedCount,
    required this.dueNextHourCount,
    required this.managerAttentionCount,
    required this.completedCount,
    required this.pendingStatusCount,
    required this.contactedCount,
  });

  final int todayCount;
  final int overdueCount;
  final int upcomingCount;
  final int completedTodayCount;
  final int pendingCount;
  final int breachedCount;
  final int dueNextHourCount;
  final int managerAttentionCount;
  final int completedCount;
  final int pendingStatusCount;
  final int contactedCount;

  factory FollowUpQueueSummary.fromItems(List<FollowUpModel> items) {
    final now = DateTime.now();
    var today = 0;
    var overdue = 0;
    var upcoming = 0;
    var completedToday = 0;
    var pending = 0;
    var breached = 0;
    var dueNextHour = 0;
    var completed = 0;
    var pendingStatus = 0;
    var contacted = 0;

    for (final item in items) {
      if (item.isClosed) {
        completed += 1;
        if (item.isCompletedToday) completedToday += 1;
        final status = item.status.toLowerCase();
        if (status.contains('contact')) contacted += 1;
        continue;
      }

      pending += 1;
      pendingStatus += 1;
      if (item.isDueToday(now)) today += 1;
      if (item.isOverdue) overdue += 1;
      if (item.isUpcoming(now) ||
          (item.scheduledAt != null &&
              !item.isOverdue &&
              !item.isDueToday(now))) {
        upcoming += 1;
      }
      if (item.isSlaBreached) breached += 1;
      if (item.isDueWithinHours(1, now)) dueNextHour += 1;
    }

    return FollowUpQueueSummary(
      todayCount: today,
      overdueCount: overdue,
      upcomingCount: upcoming,
      completedTodayCount: completedToday,
      pendingCount: pending,
      breachedCount: breached,
      dueNextHourCount: dueNextHour,
      managerAttentionCount: overdue + breached,
      completedCount: completed,
      pendingStatusCount: pendingStatus,
      contactedCount: contacted,
    );
  }
}

enum FollowUpListFilter { all, today, overdue, upcoming, completed }

extension FollowUpListFilterX on FollowUpListFilter {
  String get label {
    switch (this) {
      case FollowUpListFilter.all:
        return 'All';
      case FollowUpListFilter.today:
        return 'Today';
      case FollowUpListFilter.overdue:
        return 'Overdue';
      case FollowUpListFilter.upcoming:
        return 'Upcoming';
      case FollowUpListFilter.completed:
        return 'Completed';
    }
  }
}

List<FollowUpModel> extractFollowUps(Object? source) {
  final list = _extractList(source);
  return list.map(FollowUpModel.fromJson).toList(growable: false);
}

List<dynamic> _extractList(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'followUps',
      'follow_ups',
      'items',
      'results',
      'rows',
      'data',
    ]) {
      final value = source[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
  }
  return const [];
}

String? _readString(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is Map) {
      for (final nestedKey in const [
        'name',
        'label',
        'title',
        'statusName',
        'value',
      ]) {
        final nested = value[nestedKey]?.toString().trim() ?? '';
        if (nested.isNotEmpty) return nested;
      }
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

DateTime? _readDate(Map<String, dynamic>? map, List<String> keys) {
  final text = _readString(map, keys);
  if (text == null) return null;
  return DateTime.tryParse(text)?.toLocal();
}
