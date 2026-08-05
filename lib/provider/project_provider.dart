import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/project_model.dart';
import 'package:truerealtycrm/data/repositories/project_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class ProjectProvider extends ApiProviderBase {
  ProjectProvider({ProjectRepository? repository})
    : _repository = repository ?? ProjectRepository();

  final ProjectRepository _repository;

  final List<ProjectModel> _projects = [];
  ProjectFilter _filter = ProjectFilter.all;
  String _searchQuery = '';
  bool _hasLoaded = false;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  ProjectFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  bool get hasLoaded => _hasLoaded;

  ProjectSummary get summary {
    var totalUnits = 0;
    var availableUnits = 0;
    var linkedLeads = 0;
    for (final project in _projects) {
      totalUnits += project.totalUnits;
      availableUnits += project.availableUnits;
      linkedLeads += project.activeLeads;
    }
    return ProjectSummary(
      totalProjects: _projects.length,
      totalUnits: totalUnits,
      availableUnits: availableUnits,
      linkedLeads: linkedLeads,
    );
  }

  List<ProjectModel> get visibleProjects {
    final query = _searchQuery.trim().toLowerCase();
    return _projects.where((project) {
      if (!_filter.matches(project)) return false;
      if (query.isEmpty) return true;
      return project.name.toLowerCase().contains(query) ||
          project.location.toLowerCase().contains(query) ||
          project.developer.toLowerCase().contains(query) ||
          project.status.toLowerCase().contains(query) ||
          project.configurations.any(
            (config) => config.toLowerCase().contains(query),
          );
    }).toList(growable: false);
  }

  int countFor(ProjectFilter filter) {
    return _projects.where(filter.matches).length;
  }

  void setFilter(ProjectFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>?> loadProjects({
    String? search,
    String? status,
    String? location,
  }) async {
    final response = await runApiRequest(
      () => _repository.listProjects(
        search: search,
        status: status,
        location: location,
      ),
    );
    if (response?.data != null) {
      _projects
        ..clear()
        ..addAll(_parseProjects(response!.data));
      _hasLoaded = true;
    }
    notifyListeners();
    return response;
  }

  Future<ApiResponse<dynamic>?> fetchProjects({
    String? search,
    String? status,
    String? location,
  }) {
    return loadProjects(search: search, status: status, location: location);
  }

  Future<ApiResponse<dynamic>?> createProject(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createProject(body));
  }

  Future<ApiResponse<dynamic>?> fetchProject(String projectId) {
    return runApiRequest(() => _repository.getProject(projectId));
  }

  Future<ApiResponse<dynamic>?> updateProject({
    required String projectId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateProject(projectId: projectId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchUnits(String projectId) {
    return runApiRequest(() => _repository.listUnits(projectId));
  }

  Future<ApiResponse<dynamic>?> fetchUnit({
    required String projectId,
    required String unitId,
  }) {
    return runApiRequest(
      () => _repository.getUnit(projectId: projectId, unitId: unitId),
    );
  }

  Future<ApiResponse<dynamic>?> createUnit({
    required String projectId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createUnit(projectId: projectId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> updateUnit({
    required String projectId,
    required String unitId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateUnit(
        projectId: projectId,
        unitId: unitId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchProjectLeads({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listProjectLeads(
        projectId: projectId,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> linkLeadToUnit({
    required String projectId,
    required String unitId,
    required String leadId,
  }) {
    return runApiRequest(
      () => _repository.linkLeadToUnit(
        projectId: projectId,
        unitId: unitId,
        leadId: leadId,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchBookings({
    int page = 1,
    int limit = 10,
    String? dateFrom,
    String? dateTo,
  }) {
    return runApiRequest(
      () => _repository.listBookings(
        page: page,
        limit: limit,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  List<ProjectModel> _parseProjects(Object? source) {
    final items = _extractList(source);
    return items
        .map(ProjectModel.fromJson)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _extractList(Object? source) {
    if (source is List) {
      return source
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (source is Map) {
      for (final key in const ['data', 'projects', 'items', 'results']) {
        final nested = _extractList(source[key]);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const [];
  }
}
