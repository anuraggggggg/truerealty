import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/attendance_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class AttendanceProvider extends ApiProviderBase {
  AttendanceProvider({AttendanceRepository? repository})
    : _repository = repository ?? AttendanceRepository();

  final AttendanceRepository _repository;

  Future<ApiResponse<dynamic>?> fetchAttendance({
    String? employeeId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listAttendance(
        employeeId: employeeId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchTodayAttendance() {
    return runApiRequest(_repository.todayAttendance);
  }

  Future<ApiResponse<dynamic>?> fetchMonthlyAttendance({
    required String employeeId,
    required int month,
    required int year,
  }) {
    return runApiRequest(
      () => _repository.monthlyAttendance(
        employeeId: employeeId,
        month: month,
        year: year,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchAttendanceReportPdf({
    String? employeeId,
    required int month,
    required int year,
  }) {
    return runApiRequest(
      () => _repository.attendanceReportPdf(
        employeeId: employeeId,
        month: month,
        year: year,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> punchIn({String? checkInImageUrl}) {
    return runApiRequest(
      () => _repository.punchIn(checkInImageUrl: checkInImageUrl),
    );
  }

  Future<ApiResponse<dynamic>?> punchOut() {
    return runApiRequest(_repository.punchOut);
  }

  Future<ApiResponse<dynamic>?> correctAttendance({
    required String attendanceId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () =>
          _repository.correctAttendance(attendanceId: attendanceId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchShifts() {
    return runApiRequest(_repository.listShifts);
  }

  Future<ApiResponse<dynamic>?> createShift(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createShift(body));
  }

  Future<ApiResponse<dynamic>?> updateShift({
    required String shiftId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateShift(shiftId: shiftId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchHolidays({required int year, int? month}) {
    return runApiRequest(
      () => _repository.listHolidays(year: year, month: month),
    );
  }

  Future<ApiResponse<dynamic>?> createHoliday(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createHoliday(body));
  }

  Future<ApiResponse<dynamic>?> updateHoliday({
    required String holidayId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateHoliday(holidayId: holidayId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> deleteHoliday(String holidayId) {
    return runApiRequest(() => _repository.deleteHoliday(holidayId));
  }

  Future<ApiResponse<dynamic>?> fetchLeaves({
    String? employeeId,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) {
    return runApiRequest(
      () => _repository.listLeaves(
        employeeId: employeeId,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createLeave(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createLeave(body));
  }

  Future<ApiResponse<dynamic>?> cancelLeave(String leaveId) {
    return runApiRequest(() => _repository.cancelLeave(leaveId));
  }

  Future<ApiResponse<dynamic>?> leaveDecision({
    required String leaveId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.leaveDecision(leaveId: leaveId, body: body),
    );
  }
}
