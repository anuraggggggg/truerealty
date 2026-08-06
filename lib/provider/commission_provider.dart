import 'package:truerealtycrm/data/models/commission_model.dart';
import 'package:truerealtycrm/data/repositories/commission_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class CommissionProvider extends ApiProviderBase {
  CommissionProvider({CommissionRepository? repository})
    : _repository = repository ?? CommissionRepository();
  final CommissionRepository _repository;
  CommissionReport? _report;
  String _preset = 'this_month';

  CommissionReport? get report => _report;
  String get preset => _preset;

  Future<void> fetch({String? preset}) async {
    _preset = preset ?? _preset;
    final response = await runApiRequest(
      () => _repository.getMyCommissions(preset: _preset),
    );
    if (response != null) _report = response.data;
  }
}
