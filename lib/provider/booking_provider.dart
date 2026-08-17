import 'package:truerealtycrm/data/models/booking_model.dart';
import 'package:truerealtycrm/data/repositories/booking_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class BookingProvider extends ApiProviderBase {
  BookingProvider({BookingRepository? repository})
    : _repository = repository ?? BookingRepository();
  final BookingRepository _repository;

  List<BookingModel> bookings = const [];
  BookingStats stats = const BookingStats();
  int bookingPage = 1;
  int bookingTotal = 0;
  List<FinanceRow> financeRows = const [];
  FinanceSummary financeSummary = const FinanceSummary();
  int financePage = 1;
  int financeTotal = 0;

  Future<void> fetchBookings({int page = 1, int limit = 10}) async {
    final response = await runApiRequest(
      () => _repository.listBookings(page: page, limit: limit),
    );
    if (response == null) return;
    final body = _map(response.data);
    bookings = _list(body['data']).map(BookingModel.fromJson).toList();
    final meta = _map(body['meta']);
    stats = BookingStats.fromJson(_map(meta['stats']));
    bookingPage = _int(meta['page'], page);
    bookingTotal = _int(meta['total'], bookings.length);
    notifyListeners();
  }

  Future<void> fetchFinance({
    String preset = 'this_month',
    String scope = 'booking',
    String search = '',
    String projectId = 'all',
    String executiveId = 'all',
    String status = 'all',
    String teamId = 'all',
    String paymentStatus = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await runApiRequest(
      () => _repository.financeReport(
        preset: preset,
        scope: scope,
        search: search,
        projectId: projectId,
        executiveId: executiveId,
        status: status,
        teamId: teamId,
        paymentStatus: paymentStatus,
        page: page,
        limit: limit,
      ),
    );
    if (response == null) return;
    final body = _map(response.data);
    financeSummary = FinanceSummary.fromJson(_map(body['summary']));
    financeRows = _list(body['rows']).map((e) => FinanceRow(raw: e)).toList();
    final meta = _map(body['meta']);
    financePage = _int(meta['page'], page);
    financeTotal = _int(meta['totalRows'], financeRows.length);
    notifyListeners();
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];
int _int(Object? value, int fallback) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
