import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/report_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class ReportsProvider extends ApiProviderBase {
  ReportsProvider({ReportRepository? repository})
    : _repository = repository ?? ReportRepository();

  final ReportRepository _repository;

  Future<ApiResponse<dynamic>?> fetchDuplicates() {
    return runApiRequest(_repository.listDuplicates);
  }

  Future<ApiResponse<dynamic>?> fetchSourceAnalytics() {
    return runApiRequest(_repository.sourceAnalytics);
  }

  Future<ApiResponse<dynamic>?> fetchConversionAnalytics({
    String? dateFrom,
    String? dateTo,
  }) {
    return runApiRequest(
      () => _repository.conversionAnalytics(dateFrom: dateFrom, dateTo: dateTo),
    );
  }
}
