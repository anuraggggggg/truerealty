import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class PayrollRepository {
  PayrollRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> getPayrollSettings() {
    return _apiClient.get('/payroll/settings');
  }

  Future<ApiResponse<dynamic>> updatePayrollSettings(
    Map<String, dynamic> body,
  ) {
    return _apiClient.patch('/payroll/settings', body: body);
  }

  Future<ApiResponse<dynamic>> listPayroll({
    required int month,
    required int year,
    String? status,
  }) {
    return _apiClient.get(
      '/payroll',
      queryParameters: {'month': month, 'year': year, 'status': status},
    );
  }

  Future<ApiResponse<dynamic>> runPayroll(Map<String, dynamic> body) {
    return _apiClient.post('/payroll/run', body: body);
  }

  Future<ApiResponse<dynamic>> finalizePayroll({
    required String payrollId,
    String? note,
  }) {
    return _apiClient.patch(
      '/payroll/$payrollId/finalize',
      body: note == null ? null : {'note': note},
    );
  }

  Future<ApiResponse<dynamic>> markPayrollPaid(String payrollId) {
    return _apiClient.patch('/payroll/$payrollId/pay');
  }

  Future<ApiResponse<dynamic>> listPayslips() {
    return _apiClient.get('/payslips');
  }

  Future<ApiResponse<dynamic>> getPayslip(String payslipId) {
    return _apiClient.get('/payslips/$payslipId');
  }

  Future<ApiResponse<dynamic>> sendTestMail(Map<String, dynamic> body) {
    return _apiClient.post('/mail/test-send', body: body);
  }
}
