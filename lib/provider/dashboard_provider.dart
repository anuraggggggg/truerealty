import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/dashboard_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class DashboardProvider extends ApiProviderBase {
  DashboardProvider({DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository();

  final DashboardRepository _repository;
  int _selectedTab = 0;
  int _communicationTab = 0;
  String _selectedPeriod = 'This Month';

  int get selectedTab => _selectedTab;
  int get communicationTab => _communicationTab;
  String get selectedPeriod => _selectedPeriod;

  static const List<String> periods = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  static const List<String> tabTitles = [
    'Dashboard',
    'Leads',
    'Follow Ups',
    'Site Visit',
    'Projects',
  ];

  String get selectedTitle => tabTitles[_selectedTab];

  void selectTab(int index) {
    if (index == _selectedTab || index < 0 || index >= tabTitles.length) {
      return;
    }

    _selectedTab = index;
    notifyListeners();
  }

  void setCommunicationTab(int index) {
    if (_communicationTab == index) return;
    _communicationTab = index;
    notifyListeners();
  }

  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>?> fetchAdminDashboard({
    String range = 'today',
    String? dateFrom,
    String? dateTo,
    String? source,
    String? status,
    String? leadType,
    String? propertyType,
    String? configuration,
    String? assignedTo,
    String? team,
    String? area,
    String? slaStatus,
  }) {
    return runApiRequest(
      () => _repository.adminDashboard(
        range: range,
        dateFrom: dateFrom,
        dateTo: dateTo,
        source: source,
        status: status,
        leadType: leadType,
        propertyType: propertyType,
        configuration: configuration,
        assignedTo: assignedTo,
        team: team,
        area: area,
        slaStatus: slaStatus,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchAdminPerformance({
    String? dateFrom,
    String? dateTo,
    String role = 'all',
    String teamId = 'all',
    String userId = 'all',
    String activityType = 'all',
    int page = 1,
    int limit = 20,
  }) {
    return runApiRequest(
      () => _repository.adminPerformance(
        dateFrom: dateFrom,
        dateTo: dateTo,
        role: role,
        teamId: teamId,
        userId: userId,
        activityType: activityType,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchRankings({
    String range = 'monthly',
    String mode = 'both',
    String teamId = 'all',
    String userId = 'all',
  }) {
    return runApiRequest(
      () => _repository.rankings(
        range: range,
        mode: mode,
        teamId: teamId,
        userId: userId,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchTelecallerDashboard() {
    return runApiRequest(_repository.telecallerDashboard);
  }

  Future<ApiResponse<dynamic>?> fetchFieldExecutiveDashboard() {
    return runApiRequest(_repository.fieldExecutiveDashboard);
  }
}
