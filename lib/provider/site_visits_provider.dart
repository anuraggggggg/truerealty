import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/site_visit_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class SiteVisitModel {
  const SiteVisitModel({
    required this.id,
    required this.leadName,
    required this.project,
    required this.status,
    required this.type,
    this.leadId = '',
    this.phone = '',
    this.location = '',
    this.executiveName = '',
    this.executiveId = '',
    this.scheduledAt,
    this.durationMinutes,
    this.raw = const {},
  });

  final String id;
  final String leadId;
  final String leadName;
  final String phone;
  final String project;
  final String location;
  final String status;
  final String type;
  final String executiveName;
  final String executiveId;
  final DateTime? scheduledAt;
  final int? durationMinutes;
  final Map<String, dynamic> raw;

  String get date {
    final value = scheduledAt;
    if (value == null) return 'Date not available';
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
    return '${value.day} ${months[value.month - 1]}, ${value.year}';
  }

  String get time {
    final value = scheduledAt;
    if (value == null) return 'Time not available';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  factory SiteVisitModel.fromJson(Map<String, dynamic> json) {
    final lead = _map(json['lead']);
    final project = _map(json['project'] ?? json['property']);
    final executive = _map(
      json['fieldExecutive'] ??
          json['assignedExecutive'] ??
          json['executive'] ??
          json['assignedTo'],
    );
    final schedule = _map(json['schedule']);

    final firstName = _text(lead['firstName']);
    final lastName = _text(lead['lastName']);
    final combinedLeadName = '$firstName $lastName'.trim();
    final dateValue =
        json['scheduledAt'] ??
        json['visitDateTime'] ??
        json['startAt'] ??
        json['visitDate'] ??
        schedule['scheduledAt'] ??
        schedule['date'];

    return SiteVisitModel(
      id: _text(json['id'] ?? json['_id']),
      leadId: _text(
        json['leadId'] ??
            lead['displayId'] ??
            lead['leadId'] ??
            lead['id'] ??
            lead['_id'],
      ),
      leadName: _firstNonEmpty([
        json['leadName'],
        lead['name'],
        lead['fullName'],
        combinedLeadName,
        json['customerName'],
      ], fallback: 'Unknown lead'),
      phone: _firstNonEmpty([
        lead['phone'],
        lead['mobile'],
        json['phone'],
        json['mobile'],
      ]),
      project: _firstNonEmpty([
        json['projectName'],
        project['name'],
        project['projectName'],
        json['propertyName'],
      ], fallback: 'Project not available'),
      location: _firstNonEmpty([
        json['location'],
        project['location'],
        project['address'],
        project['city'],
        json['meetingPoint'],
      ]),
      status: _pretty(
        _firstNonEmpty([
          json['status'],
          json['visitStatus'],
        ], fallback: 'Scheduled'),
      ),
      type: _pretty(
        _firstNonEmpty([
          json['visitType'],
          json['type'],
        ], fallback: 'Site visit'),
      ),
      executiveName: _firstNonEmpty([
        json['fieldExecutiveName'],
        executive['name'],
        executive['fullName'],
        '${_text(executive['firstName'])} ${_text(executive['lastName'])}'
            .trim(),
      ], fallback: 'Unassigned'),
      executiveId: _text(
        json['fieldExecutiveId'] ?? executive['id'] ?? executive['_id'],
      ),
      scheduledAt: _date(dateValue),
      durationMinutes: _integer(
        json['durationMinutes'] ?? json['duration'] ?? schedule['duration'],
      ),
      raw: json,
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static String _text(dynamic value) =>
      value == null ? '' : value.toString().trim();

  static String _firstNonEmpty(
    Iterable<dynamic> values, {
    String fallback = '',
  }) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static int? _integer(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static String _pretty(String value) {
    final spaced = value
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .trim();
    if (spaced.isEmpty) return spaced;
    return spaced
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class SiteVisitProvider extends ApiProviderBase {
  SiteVisitProvider({SiteVisitRepository? repository})
    : _repository = repository ?? SiteVisitRepository();

  final SiteVisitRepository _repository;
  final List<SiteVisitModel> _siteVisits = [];
  dynamic _options;

  List<SiteVisitModel> get siteVisits => List.unmodifiable(_siteVisits);
  dynamic get options => _options;

  int get totalVisits => _siteVisits.length;
  int get scheduledVisits => _countStatus('scheduled');
  int get completedVisits => _countStatus('completed');
  int get cancelledVisits => _countStatus('cancel');
  int get upcomingVisits {
    final now = DateTime.now();
    return _siteVisits
        .where(
          (visit) =>
              visit.scheduledAt != null &&
              visit.scheduledAt!.isAfter(now) &&
              !_isStatus(visit, 'completed') &&
              !_isStatus(visit, 'cancel'),
        )
        .length;
  }

  int get activeVisits => _siteVisits
      .where(
        (visit) =>
            !_isStatus(visit, 'completed') && !_isStatus(visit, 'cancel'),
      )
      .length;

  int _countStatus(String status) =>
      _siteVisits.where((visit) => _isStatus(visit, status)).length;

  bool _isStatus(SiteVisitModel visit, String status) =>
      visit.status.toLowerCase().contains(status);

  Future<ApiResponse<dynamic>?> fetchSiteVisits({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? fieldExecutiveId,
  }) async {
    final response = await runApiRequest(
      () => _repository.listSiteVisits(
        search: search,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
        fieldExecutiveId: fieldExecutiveId,
      ),
    );
    if (response != null) {
      _siteVisits
        ..clear()
        ..addAll(
          _extractList(
            response.data,
          ).map(SiteVisitModel.fromJson).where((visit) => visit.id.isNotEmpty),
        );
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<dynamic>?> fetchSiteVisitOptions() async {
    final response = await runApiRequest(_repository.siteVisitOptions);
    if (response != null) {
      _options = response.data;
      notifyListeners();
    }
    return response;
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    dynamic value = payload;
    for (var i = 0; i < 4 && value is Map; i++) {
      final map = Map<String, dynamic>.from(value);
      final next =
          map['data'] ??
          map['items'] ??
          map['siteVisits'] ??
          map['visits'] ??
          map['results'] ??
          map['rows'];
      if (next == null || identical(next, value)) break;
      value = next;
    }
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<ApiResponse<dynamic>?> createSiteVisitFromApi(
    Map<String, dynamic> body,
  ) async {
    final response = await runApiRequest(
      () => _repository.createSiteVisit(body),
    );
    if (response != null) await fetchSiteVisits();
    return response;
  }

  Future<ApiResponse<dynamic>?> fetchSiteVisit(String siteVisitId) {
    return runApiRequest(() => _repository.getSiteVisit(siteVisitId));
  }

  Future<ApiResponse<dynamic>?> updateSiteVisitFromApi({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) async {
    final response = await runApiRequest(
      () => _repository.updateSiteVisit(siteVisitId: siteVisitId, body: body),
    );
    if (response != null) await fetchSiteVisits();
    return response;
  }

  Future<ApiResponse<dynamic>?> checkIn({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.checkIn(siteVisitId: siteVisitId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> checkOut({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.checkOut(siteVisitId: siteVisitId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> trackingPing(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.trackingPing(body));
  }

  Future<ApiResponse<dynamic>?> stopTracking() {
    return runApiRequest(_repository.stopTracking);
  }

  Future<ApiResponse<dynamic>?> fetchLiveTracking() {
    return runApiRequest(_repository.liveTracking);
  }
}
