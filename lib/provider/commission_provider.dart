import 'package:truerealtycrm/data/models/commission_model.dart';
import 'package:truerealtycrm/data/repositories/commission_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class CommissionProvider extends ApiProviderBase {
  CommissionProvider({CommissionRepository? repository})
    : _repository = repository ?? CommissionRepository();
  final CommissionRepository _repository;
  CommissionReport? _report;
  String _preset = 'this_month';
  String? _dateFrom;
  String? _dateTo;

  CommissionReport? get report => _report;
  String get preset => _preset;
  String? get dateFrom => _dateFrom;
  String? get dateTo => _dateTo;

  Future<void> fetch({String? preset, String? dateFrom, String? dateTo}) async {
    _preset = preset ?? _preset;
    if (preset != null) {
      _dateFrom = dateFrom;
      _dateTo = dateTo;
    }
    final response = await runApiRequest(
      () => _repository.getMyCommissions(
        preset: _preset,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ),
    );
    if (response != null) _report = response.data;
  }
}
