import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/lead_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class LeadProvider extends ApiProviderBase {
  LeadProvider({LeadRepository? repository})
    : _repository = repository ?? LeadRepository();

  final LeadRepository _repository;
  final List<LeadModel> _leads = [];
  final Map<String, int> _statusCounts = {};
  int _totalCount = 0;

  List<LeadModel> get leads => _leads;

  int get totalCount => _totalCount > 0 ? _totalCount : _leads.length;

  int get totalLeads => totalCount;

  List<String> get statusNames => _statusCounts.keys.toList();

  int countForStatus(String status) => _statusCounts[_cleanStatus(status)] ?? 0;

  int get hotLeads => _leads.where((e) => e.isHot).length;

  int get qualifiedLeads =>
      _leads.where((e) => e.status.toLowerCase().contains('qualified')).length;

  int get convertedLeads =>
      _leads.where((e) => e.status.toLowerCase().contains('converted')).length;

  int get newLeads =>
      _leads.where((e) => e.status.toLowerCase().contains('new')).length;

  int get pendingLeads =>
      _leads.where((e) => e.status.toLowerCase().contains('pending')).length;

  int get contactedLeads =>
      _leads.where((e) => e.status.toLowerCase().contains('contacted')).length;

  void addLead(LeadModel lead) {
    _leads.add(lead);
    notifyListeners();
  }

  void removeLead(int index) {
    _leads.removeAt(index);
    notifyListeners();
  }

  Future<ApiResponse<dynamic>?> fetchLeads({
    String? search,
    int page = 1,
    int limit = 10,
    String? source,
    String? status,
    String? leadType,
    String? configuration,
    String? project,
    String? propertyType,
    String? assignedTo,
    String? team,
    String? area,
    String? slaStatus,
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await runApiRequest(
      () => _repository.listLeads(
        search: search,
        page: page,
        limit: limit,
        source: source,
        status: status,
        leadType: leadType,
        configuration: configuration,
        project: project,
        propertyType: propertyType,
        assignedTo: assignedTo,
        team: team,
        area: area,
        slaStatus: slaStatus,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
    if (response != null) {
      final parsedLeads = _extractLeadList(
        response.data,
      ).map(LeadModel.fromJson).toList();
      final statusFilter = _cleanStatus(status ?? '');
      final visibleLeads = statusFilter.isEmpty
          ? parsedLeads
          : _filterLeadsByStatus(parsedLeads, statusFilter);

      _leads
        ..clear()
        ..addAll(visibleLeads);
      _totalCount = statusFilter.isEmpty
          ? (_extractTotalCount(response.data) ?? _leads.length)
          : _leads.length;
      if (statusFilter.isEmpty || _statusCounts.isEmpty) {
        _replaceStatusSummary(parsedLeads);
      } else {
        _mergeStatusSummary(parsedLeads);
      }
      notifyListeners();
    }
    return response;
  }

  void _replaceStatusSummary(List<LeadModel> leads) {
    _statusCounts
      ..clear()
      ..addAll(_buildStatusSummary(leads));
  }

  void _mergeStatusSummary(List<LeadModel> leads) {
    final nextCounts = _buildStatusSummary(leads);
    for (final entry in nextCounts.entries) {
      _statusCounts[entry.key] = entry.value;
    }
  }

  Map<String, int> _buildStatusSummary(List<LeadModel> leads) {
    final counts = <String, int>{};
    for (final lead in leads) {
      final status = _cleanStatus(lead.status);
      if (status.isEmpty) {
        continue;
      }
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  List<LeadModel> _filterLeadsByStatus(
    List<LeadModel> apiLeads,
    String status,
  ) {
    return apiLeads
        .where((lead) => _statusMatches(lead.status, status))
        .toList();
  }

  Future<ApiResponse<dynamic>?> fetchDeletedLeads({
    String search = '',
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listDeletedLeads(
        search: search,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchLead(String leadId) {
    return runApiRequest(() => _repository.getLead(leadId));
  }

  Future<ApiResponse<dynamic>?> createLeadFromApi(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createLead(body));
  }

  Future<ApiResponse<dynamic>?> updateLeadFromApi({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateLead(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> deleteLeadFromApi({
    required String leadId,
    String? deleteReason,
  }) {
    return runApiRequest(
      () => _repository.deleteLead(leadId: leadId, deleteReason: deleteReason),
    );
  }

  Future<ApiResponse<dynamic>?> restoreLead(String deletedLeadId) {
    return runApiRequest(() => _repository.restoreLead(deletedLeadId));
  }

  Future<ApiResponse<dynamic>?> assignLead({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.assignLead(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> bulkAssignLeads(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.bulkAssignLeads(body));
  }

  Future<ApiResponse<dynamic>?> bulkUpdateSource(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.bulkUpdateSource(body));
  }

  Future<ApiResponse<dynamic>?> moveLeadInPipeline({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.moveLeadInPipeline(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchLeadPipeline({
    String search = '',
    String teamId = 'all',
    int? limitPerColumn,
  }) {
    return runApiRequest(
      () => _repository.leadPipeline(
        search: search,
        teamId: teamId,
        limitPerColumn: limitPerColumn,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchFollowUps({
    int page = 1,
    int limit = 10,
    String? due,
    String? status,
    String? type,
  }) {
    return runApiRequest(
      () => _repository.listFollowUps(
        page: page,
        limit: limit,
        due: due,
        status: status,
        type: type,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchMyFollowUps() {
    return runApiRequest(_repository.myFollowUps);
  }

  Future<ApiResponse<dynamic>?> fetchFieldExecutiveFollowUps() {
    return runApiRequest(_repository.fieldExecutiveFollowUps);
  }

  Future<ApiResponse<dynamic>?> createFollowUp({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createFollowUp(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> updateFollowUp({
    required String leadId,
    required String followUpId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateFollowUp(
        leadId: leadId,
        followUpId: followUpId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchLeadBookings(String leadId) {
    return runApiRequest(() => _repository.listLeadBookings(leadId));
  }

  Future<ApiResponse<dynamic>?> createLeadBooking({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createLeadBooking(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> updateLeadBooking({
    required String leadId,
    required String bookingId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateLeadBooking(
        leadId: leadId,
        bookingId: bookingId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchLeadTimeline(String leadId) {
    return runApiRequest(() => _repository.leadTimeline(leadId));
  }

  Future<ApiResponse<dynamic>?> createLeadTask({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createLeadTask(leadId: leadId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> updateLeadTask({
    required String leadId,
    required String taskId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateLeadTask(
        leadId: leadId,
        taskId: taskId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createLeadNote({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createLeadNote(leadId: leadId, body: body),
    );
  }
}

class LeadModel {
  final String? id;
  final String? displayId;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String? stage;
  final String? source;
  final String? project;
  final String? location;
  final String? assignedTo;
  final String? dueLabel;
  final String? createdLabel;
  final Map<String, dynamic>? raw;

  LeadModel({
    this.id,
    this.displayId,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.stage,
    this.source,
    this.project,
    this.location,
    this.assignedTo,
    this.dueLabel,
    this.createdLabel,
    this.raw,
  });

  factory LeadModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final requirement = map['requirement'] is Map<String, dynamic>
        ? map['requirement'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return LeadModel(
      id: _readString(map, const ['id', '_id', 'leadId']),
      displayId: _readString(map, const [
        'displayId',
        'display_id',
        'leadDisplayId',
      ]),
      name:
          _readString(map, const ['name', 'leadName', 'customerName']) ??
          'Unknown Lead',
      email: _readString(map, const ['email']) ?? '-',
      phone: _readString(map, const ['phone', 'mobile', 'number']) ?? '-',
      status:
          _readString(map, const ['statusName', 'status', 'leadStatus']) ??
          _readString(map, const ['stageName', 'stage']) ??
          'New',
      stage: _readString(map, const ['stageName', 'stage']),
      source: _readString(map, const ['sourceName', 'source']),
      project:
          _readString(map, const ['projectName', 'preferredProjectId']) ??
          _readString(requirement, const [
            'preferredProjectId',
            'preferredProject',
          ]),
      location:
          _readString(map, const ['location', 'preferredLocation']) ??
          _readString(requirement, const ['preferredLocation', 'location']),
      assignedTo: _readString(map, const [
        'assignedToName',
        'telecallerName',
        'fieldExecutiveName',
        'ownerName',
        'managerName',
      ]),
      dueLabel: _readString(map, const [
        'dueLabel',
        'followUpDate',
        'nextFollowUpLabel',
        'scheduledLabel',
      ]),
      createdLabel: _readString(map, const [
        'createdLabel',
        'createdAt',
        'addedDate',
      ]),
      raw: map,
    );
  }

  bool get isHot {
    final text = '${status.toLowerCase()} ${stage?.toLowerCase() ?? ''}';
    return text.contains('hot');
  }

  String get titleWithId => displayId == null ? name : '$name • $displayId';
}

List<dynamic> _extractLeadList(Object? source) {
  if (source is List) {
    return source;
  }

  if (source is Map) {
    for (final key in const [
      'leads',
      'items',
      'results',
      'rows',
      'records',
      'data',
    ]) {
      final value = source[key];
      if (value is List) {
        return value;
      }
      if (value is Map) {
        final nested = _extractLeadList(value);
        if (nested.isNotEmpty) {
          return nested;
        }
      }
    }
  }

  return const [];
}

int? _extractTotalCount(Object? source) {
  if (source is! Map) {
    return null;
  }

  for (final key in const ['total', 'totalCount', 'count', 'recordsTotal']) {
    final value = source[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }

  for (final key in const ['pagination', 'meta', 'data']) {
    final nested = _extractTotalCount(source[key]);
    if (nested != null) return nested;
  }

  return null;
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

String _cleanStatus(String status) {
  return status.trim().replaceAll(RegExp(r'\s+'), ' ');
}

bool _statusMatches(String leadStatus, String selectedStatus) {
  return _cleanStatus(leadStatus).toLowerCase() ==
      _cleanStatus(selectedStatus).toLowerCase();
}
