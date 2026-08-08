import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/site_visit_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

enum SiteVisitListFilter { all, upcoming, scheduled, completed, cancelled }

extension SiteVisitListFilterX on SiteVisitListFilter {
  String get label {
    switch (this) {
      case SiteVisitListFilter.all:
        return 'All Visits';
      case SiteVisitListFilter.upcoming:
        return 'Upcoming';
      case SiteVisitListFilter.scheduled:
        return 'Scheduled';
      case SiteVisitListFilter.completed:
        return 'Completed';
      case SiteVisitListFilter.cancelled:
        return 'Cancelled';
    }
  }

  bool matches(SiteVisitModel visit) {
    final status = visit.status.toLowerCase();
    switch (this) {
      case SiteVisitListFilter.all:
        return true;
      case SiteVisitListFilter.upcoming:
        return status.contains('upcoming');
      case SiteVisitListFilter.scheduled:
        return status.contains('scheduled');
      case SiteVisitListFilter.completed:
        return status.contains('completed');
      case SiteVisitListFilter.cancelled:
        return status.contains('cancel');
    }
  }
}

class SiteVisitModel {
  const SiteVisitModel({
    required this.id,
    required this.leadName,
    required this.project,
    required this.status,
    required this.type,
    this.displayId = '',
    this.leadId = '',
    this.leadDisplayId = '',
    this.phone = '',
    this.location = '',
    this.unitLabel = '',
    this.projectImageUrl = '',
    this.executiveName = '',
    this.executiveId = '',
    this.executiveImageUrl = '',
    this.executiveRole = '',
    this.scheduledAt,
    this.reminderAt,
    this.durationMinutes,
    this.raw = const {},
  });

  final String id;
  final String displayId;
  final String leadId;
  final String leadDisplayId;
  final String leadName;
  final String phone;
  final String project;
  final String location;
  final String unitLabel;
  final String projectImageUrl;
  final String status;
  final String type;
  final String executiveName;
  final String executiveId;
  final String executiveImageUrl;
  final String executiveRole;
  final DateTime? scheduledAt;
  final DateTime? reminderAt;
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
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
  }

  String get time {
    final value = scheduledAt;
    if (value == null) return 'Time not available';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get reminderLabel {
    final value = reminderAt;
    if (value == null) return 'No reminder';
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
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final ampm = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year} $hour:$minute $ampm';
  }

  String get formattedPhone {
    final rawPhone = phone.trim();
    if (rawPhone.isEmpty) return '-';
    if (rawPhone.startsWith('+')) return rawPhone;
    final digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) return '+91 $digits';
    return rawPhone;
  }

  factory SiteVisitModel.fromJson(Map<String, dynamic> json) {
    final lead = _map(json['lead']);
    final project = _map(json['project'] ?? json['property']);
    final unit = _map(json['unit']);
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

    final countryCode = _text(
      lead['mobileCountryCode'] ?? json['mobileCountryCode'],
    );
    final mobile = _firstNonEmpty([
      json['leadPhone'],
      lead['phone'],
      lead['mobile'],
      json['phone'],
      json['mobile'],
    ]);
    final phone = mobile.isEmpty
        ? ''
        : mobile.startsWith('+')
        ? mobile
        : countryCode.isEmpty
        ? mobile
        : '$countryCode $mobile'.trim();

    return SiteVisitModel(
      id: _text(json['id'] ?? json['_id']),
      displayId: _text(json['displayId'] ?? json['visitId']),
      leadId: _text(json['leadId'] ?? lead['id'] ?? lead['_id']),
      leadDisplayId: _firstNonEmpty([
        json['leadDisplayId'],
        lead['displayId'],
        lead['leadId'],
      ]),
      leadName: _firstNonEmpty([
        json['leadName'],
        lead['name'],
        lead['fullName'],
        combinedLeadName,
        json['customerName'],
      ], fallback: 'Unknown lead'),
      phone: phone,
      project: _firstNonEmpty([
        json['projectName'],
        project['name'],
        project['projectName'],
        json['propertyName'],
      ], fallback: 'Project not available'),
      location: _firstNonEmpty([
        json['projectLocation'],
        json['location'],
        project['location'],
        project['address'],
        project['city'],
        json['meetingPoint'],
      ]),
      unitLabel: _firstNonEmpty([
        json['unitLabel'],
        unit['label'],
        unit['unitNumber'],
        unit['name'],
        [
          _text(unit['tower']),
          _text(unit['unitNumber']),
        ].where((part) => part.isNotEmpty).join(', '),
      ]),
      projectImageUrl: _firstNonEmpty([
        project['imageUrl'],
        json['projectImageUrl'],
        json['imageUrl'],
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
        ], fallback: 'Site Visit'),
      ),
      executiveName: _firstNonEmpty([
        json['assignedExecutiveName'],
        json['fieldExecutiveName'],
        executive['name'],
        executive['fullName'],
        '${_text(executive['firstName'])} ${_text(executive['lastName'])}'
            .trim(),
      ], fallback: 'Unassigned'),
      executiveId: _text(
        json['assignedExecutiveId'] ??
            json['fieldExecutiveId'] ??
            json['executiveId'] ??
            executive['employeeId'] ??
            executive['userId'] ??
            executive['id'] ??
            executive['_id'],
      ),
      executiveImageUrl: _firstNonEmpty([
        json['assignedExecutiveImage'],
        executive['image'],
        executive['imageUrl'],
        executive['avatar'],
      ]),
      executiveRole: _firstNonEmpty([
        json['assignedExecutiveRole'],
        executive['role'],
        executive['roleName'],
      ]),
      scheduledAt: _date(dateValue),
      reminderAt: _date(json['reminderAt'] ?? schedule['reminderAt']),
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
  SiteVisitListFilter _filter = SiteVisitListFilter.all;
  String? _selectedExecutiveId;
  String _searchQuery = '';
  dynamic _options;
  bool _hasLoaded = false;

  List<SiteVisitModel> get siteVisits => List.unmodifiable(_siteVisits);
  SiteVisitListFilter get filter => _filter;
  String? get selectedExecutiveId => _selectedExecutiveId;
  String get searchQuery => _searchQuery;
  dynamic get options => _options;
  bool get hasLoaded => _hasLoaded;

  int get totalVisits => _siteVisits.length;
  int get upcomingVisits => countFor(SiteVisitListFilter.upcoming);
  int get scheduledVisits => countFor(SiteVisitListFilter.scheduled);
  int get completedVisits => countFor(SiteVisitListFilter.completed);
  int get cancelledVisits => countFor(SiteVisitListFilter.cancelled);

  int get fieldExecutiveCount {
    final ids = <String>{};
    for (final visit in _siteVisits) {
      final id = visit.executiveId.trim();
      if (id.isNotEmpty) ids.add(id.toLowerCase());
    }
    return ids.length;
  }

  int get activeVisits => _siteVisits
      .where(
        (visit) =>
            !visit.status.toLowerCase().contains('completed') &&
            !visit.status.toLowerCase().contains('cancel'),
      )
      .length;

  double get completionRate {
    if (_siteVisits.isEmpty) return 0;
    return (completedVisits / _siteVisits.length) * 100;
  }

  List<SiteVisitModel> get visibleVisits {
    final query = _searchQuery.trim().toLowerCase();
    final executiveId = _selectedExecutiveId?.trim().toLowerCase() ?? '';
    return _siteVisits
        .where((visit) {
          if (!_filter.matches(visit)) return false;
          if (executiveId.isNotEmpty &&
              visit.executiveId.trim().toLowerCase() != executiveId) {
            return false;
          }
          if (query.isEmpty) return true;
          return visit.leadName.toLowerCase().contains(query) ||
              visit.phone.toLowerCase().contains(query) ||
              visit.project.toLowerCase().contains(query) ||
              visit.location.toLowerCase().contains(query) ||
              visit.executiveName.toLowerCase().contains(query) ||
              visit.leadDisplayId.toLowerCase().contains(query) ||
              visit.status.toLowerCase().contains(query) ||
              visit.type.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  List<SiteVisitModel> get todayAndUpcoming {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final items =
        _siteVisits.where((visit) {
          final status = visit.status.toLowerCase();
          if (status.contains('completed') || status.contains('cancel')) {
            return false;
          }
          final scheduled = visit.scheduledAt;
          if (scheduled == null) return status.contains('upcoming');
          return !scheduled.isBefore(startOfToday) ||
              status.contains('upcoming');
        }).toList()..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
    return items.take(5).toList(growable: false);
  }

  int countFor(SiteVisitListFilter filter) {
    return _siteVisits.where(filter.matches).length;
  }

  void setFilter(SiteVisitListFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSelectedExecutiveId(String? executiveId) {
    final next = executiveId?.trim().isEmpty == true ? null : executiveId;
    if (_selectedExecutiveId == next) return;
    _selectedExecutiveId = next;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  /// Clears UI-only filters when entering the shared Site Visits screen.
  ///
  /// The provider lives above the role dashboards, so these values otherwise
  /// survive navigation and even a role/session change. API-loaded visits are
  /// intentionally preserved until the screen refreshes them.
  void resetViewFilters() {
    final changed =
        _filter != SiteVisitListFilter.all ||
        _selectedExecutiveId != null ||
        _searchQuery.isNotEmpty;
    _filter = SiteVisitListFilter.all;
    _selectedExecutiveId = null;
    _searchQuery = '';
    if (changed) notifyListeners();
  }

  Future<ApiResponse<dynamic>?> fetchSiteVisits({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? fieldExecutiveId,
    int limit = 100,
    int page = 1,
  }) async {
    final response = await runApiRequest(
      () => _repository.listSiteVisits(
        search: search,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
        fieldExecutiveId: fieldExecutiveId,
        limit: limit,
        page: page,
      ),
    );
    if (response != null) {
      final visits = _extractList(response.data)
          .map(SiteVisitModel.fromJson)
          .where((visit) => visit.id.isNotEmpty)
          .toList();
      _siteVisits
        ..clear()
        ..addAll(visits);
      _hasLoaded = true;
      notifyListeners();
    }
    return response;
  }

  /// Loads the visits visible through a set of field executives.
  ///
  /// Some role scopes return an empty result for the unfiltered list while
  /// still granting access to specific executives through the options API.
  Future<void> fetchSiteVisitsForExecutives(
    Iterable<String> executiveIds,
  ) async {
    final ids = executiveIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return;

    final visitsById = <String, SiteVisitModel>{};
    for (final executiveId in ids) {
      final response = await runApiRequest(
        () => _repository.listSiteVisits(
          fieldExecutiveId: executiveId,
          limit: 100,
        ),
      );
      if (response == null) continue;
      for (final json in _extractList(response.data)) {
        final visit = SiteVisitModel.fromJson(json);
        if (visit.id.isNotEmpty) visitsById[visit.id] = visit;
      }
    }

    _siteVisits
      ..clear()
      ..addAll(visitsById.values);
    _hasLoaded = true;
    notifyListeners();
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
      if (next != null) {
        value = next;
        continue;
      }
      break;
    }
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    return const [];
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

  Future<ApiResponse<dynamic>?> liveTracking() {
    return runApiRequest(_repository.liveTracking);
  }
}
