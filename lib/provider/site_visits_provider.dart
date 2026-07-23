import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/site_visit_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class SiteVisitModel {
  final String leadName;
  final String project;
  final String date;
  final String time;
  final String status;
  final String type;

  SiteVisitModel({
    required this.leadName,
    required this.project,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
  });
}

class SiteVisitProvider extends ApiProviderBase {
  SiteVisitProvider({SiteVisitRepository? repository})
    : _repository = repository ?? SiteVisitRepository();

  final SiteVisitRepository _repository;
  final List<SiteVisitModel> _siteVisits = [
    SiteVisitModel(
      leadName: "Rahul Sharma",
      project: "Green Valley",
      date: "15 June, 2026",
      time: "10:30 AM",
      status: "Scheduled",
      type: "Initial",
    ),
    SiteVisitModel(
      leadName: "Priya Mehta",
      project: "Skyline Residency",
      date: "16 June, 2026",
      time: "02:00 PM",
      status: "Completed",
      type: "Follow-up",
    ),
    SiteVisitModel(
      leadName: "Amit Singh",
      project: "Emerald Heights",
      date: "17 June, 2026",
      time: "11:00 AM",
      status: "Cancelled",
      type: "Initial",
    ),
    SiteVisitModel(
      leadName: "Sanjay Gupta",
      project: "Green Valley",
      date: "18 June, 2026",
      time: "04:30 PM",
      status: "Scheduled",
      type: "Initial",
    ),
  ];

  List<SiteVisitModel> get siteVisits => _siteVisits;

  int get totalVisits => _siteVisits.length;
  int get scheduledVisits =>
      _siteVisits.where((v) => v.status == "Scheduled").length;
  int get completedVisits =>
      _siteVisits.where((v) => v.status == "Completed").length;
  int get cancelledVisits =>
      _siteVisits.where((v) => v.status == "Cancelled").length;

  Future<ApiResponse<dynamic>?> fetchSiteVisits({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? fieldExecutiveId,
  }) {
    return runApiRequest(
      () => _repository.listSiteVisits(
        search: search,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
        fieldExecutiveId: fieldExecutiveId,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchSiteVisitOptions() {
    return runApiRequest(_repository.siteVisitOptions);
  }

  Future<ApiResponse<dynamic>?> createSiteVisitFromApi(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.createSiteVisit(body));
  }

  Future<ApiResponse<dynamic>?> fetchSiteVisit(String siteVisitId) {
    return runApiRequest(() => _repository.getSiteVisit(siteVisitId));
  }

  Future<ApiResponse<dynamic>?> updateSiteVisitFromApi({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateSiteVisit(siteVisitId: siteVisitId, body: body),
    );
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
