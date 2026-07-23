import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/payroll_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class PayrollProvider extends ApiProviderBase {
  PayrollProvider({PayrollRepository? repository})
    : _repository = repository ?? PayrollRepository();

  final PayrollRepository _repository;

  Future<ApiResponse<dynamic>?> fetchPayrollSettings() {
    return runApiRequest(_repository.getPayrollSettings);
  }

  Future<ApiResponse<dynamic>?> updatePayrollSettings(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.updatePayrollSettings(body));
  }

  Future<ApiResponse<dynamic>?> fetchPayroll({
    required int month,
    required int year,
    String? status,
  }) {
    return runApiRequest(
      () => _repository.listPayroll(month: month, year: year, status: status),
    );
  }

  Future<ApiResponse<dynamic>?> runPayroll(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.runPayroll(body));
  }

  Future<ApiResponse<dynamic>?> finalizePayroll({
    required String payrollId,
    String? note,
  }) {
    return runApiRequest(
      () => _repository.finalizePayroll(payrollId: payrollId, note: note),
    );
  }

  Future<ApiResponse<dynamic>?> markPayrollPaid(String payrollId) {
    return runApiRequest(() => _repository.markPayrollPaid(payrollId));
  }

  Future<ApiResponse<dynamic>?> fetchPayslips() {
    return runApiRequest(_repository.listPayslips);
  }

  Future<ApiResponse<dynamic>?> fetchPayslip(String payslipId) {
    return runApiRequest(() => _repository.getPayslip(payslipId));
  }

  Future<ApiResponse<dynamic>?> sendTestMail(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.sendTestMail(body));
  }
}
