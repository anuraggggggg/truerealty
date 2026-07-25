import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class AttendanceRepository {
  AttendanceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listAttendance({
    String? employeeId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/attendance',
      queryParameters: {
        'employeeId': employeeId,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<ApiResponse<dynamic>> todayAttendance() {
    return _apiClient.get('/attendance/today');
  }

  Future<ApiResponse<dynamic>> monthlyAttendance({
    required String employeeId,
    required int month,
    required int year,
  }) {
    return _apiClient.get(
      '/attendance',
      queryParameters: {'employeeId': employeeId, 'month': month, 'year': year},
    );
  }

  Future<ApiResponse<dynamic>> attendanceReportPdf({
    String? employeeId,
    required int month,
    required int year,
  }) {
    return _apiClient.get(
      '/attendance/report.pdf',
      queryParameters: {'employeeId': employeeId, 'month': month, 'year': year},
    );
  }

  Future<ApiResponse<dynamic>> punchIn({String? checkInImageUrl}) {
    return _apiClient.post(
      '/attendance/punch-in',
      body: checkInImageUrl == null
          ? null
          : {'checkInImageUrl': checkInImageUrl},
    );
  }

  Future<ApiResponse<dynamic>> punchOut() {
    return _apiClient.post('/attendance/punch-out');
  }

  Future<ApiResponse<dynamic>> correctAttendance({
    required String attendanceId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/attendance/$attendanceId/correct', body: body);
  }

  Future<ApiResponse<dynamic>> listShifts() {
    return _apiClient.get('/shifts');
  }

  Future<ApiResponse<dynamic>> createShift(Map<String, dynamic> body) {
    return _apiClient.post('/shifts', body: body);
  }

  Future<ApiResponse<dynamic>> updateShift({
    required String shiftId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/shifts/$shiftId', body: body);
  }

  Future<ApiResponse<dynamic>> listHolidays({required int year, int? month}) {
    return _apiClient.get(
      '/holidays',
      queryParameters: {'year': year, 'month': month},
    );
  }

  Future<ApiResponse<dynamic>> createHoliday(Map<String, dynamic> body) {
    return _apiClient.post('/holidays', body: body);
  }

  Future<ApiResponse<dynamic>> updateHoliday({
    required String holidayId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/holidays/$holidayId', body: body);
  }

  Future<ApiResponse<dynamic>> deleteHoliday(String holidayId) {
    return _apiClient.delete('/holidays/$holidayId');
  }

  Future<ApiResponse<dynamic>> listLeaves({
    String? employeeId,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) {
    return _apiClient.get(
      '/leaves',
      queryParameters: {
        'employeeId': employeeId,
        'status': status,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
      },
    );
  }

  Future<ApiResponse<dynamic>> createLeave(Map<String, dynamic> body) {
    return _apiClient.post('/leaves', body: body);
  }

  Future<ApiResponse<dynamic>> cancelLeave(String leaveId) {
    return _apiClient.patch('/leaves/$leaveId/cancel');
  }

  Future<ApiResponse<dynamic>> leaveDecision({
    required String leaveId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/leaves/$leaveId/decision', body: body);
  }
}
