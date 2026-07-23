import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/project_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class ProjectProvider extends ApiProviderBase {
  ProjectProvider({ProjectRepository? repository})
    : _repository = repository ?? ProjectRepository();

  final ProjectRepository _repository;

  Future<ApiResponse<dynamic>?> fetchProjects({
    String? search,
    String? status,
    String? location,
  }) {
    return runApiRequest(
      () => _repository.listProjects(
        search: search,
        status: status,
        location: location,
      ),
    );
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
}
