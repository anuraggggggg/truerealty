import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/follow_up_model.dart';
import 'package:truerealtycrm/data/repositories/lead_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class FollowUpsProvider extends ApiProviderBase {
  FollowUpsProvider({LeadRepository? repository})
    : _repository = repository ?? LeadRepository();

  final LeadRepository _repository;

  final List<FollowUpModel> _items = [];
  FollowUpListFilter _filter = FollowUpListFilter.all;
  FollowUpQueueSummary _summary = FollowUpQueueSummary.fromItems(const []);
  bool _hasLoaded = false;

  List<FollowUpModel> get items => List.unmodifiable(_items);
  FollowUpListFilter get filter => _filter;
  FollowUpQueueSummary get summary => _summary;
  bool get hasLoaded => _hasLoaded;

  List<FollowUpModel> get visibleItems {
    final now = DateTime.now();
    switch (_filter) {
      case FollowUpListFilter.all:
        return items;
      case FollowUpListFilter.today:
        return _items.where((item) => item.isDueToday(now)).toList();
      case FollowUpListFilter.overdue:
        return _items.where((item) => item.isOverdue).toList();
      case FollowUpListFilter.upcoming:
        return _items.where((item) {
          if (item.isClosed || item.isOverdue || item.isDueToday(now)) {
            return false;
          }
          return item.scheduledAt != null && item.scheduledAt!.isAfter(now);
        }).toList();
      case FollowUpListFilter.completed:
        return _items.where((item) => item.isClosed).toList();
    }
  }

  int countFor(FollowUpListFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case FollowUpListFilter.all:
        return _items.length;
      case FollowUpListFilter.today:
        return _items.where((item) => item.isDueToday(now)).length;
      case FollowUpListFilter.overdue:
        return _items.where((item) => item.isOverdue).length;
      case FollowUpListFilter.upcoming:
        return _items.where((item) {
          if (item.isClosed || item.isOverdue || item.isDueToday(now)) {
            return false;
          }
          return item.scheduledAt != null && item.scheduledAt!.isAfter(now);
        }).length;
      case FollowUpListFilter.completed:
        return _items.where((item) => item.isClosed).length;
    }
  }

  Map<String, int> get bestTimeSlots {
    final counts = <String, int>{};
    for (final item in _items) {
      final date = item.scheduledAt;
      if (date == null || item.isClosed) continue;
      final hour = date.hour;
      final suffix = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0
          ? 12
          : hour > 12
          ? hour - 12
          : hour;
      final label =
          '${displayHour.toString().padLeft(2, '0')} $suffix';
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map<String, int>.fromEntries(entries.take(4));
  }

  Set<int> get scheduledDaysInCurrentMonth {
    final now = DateTime.now();
    final days = <int>{};
    for (final item in _items) {
      final date = item.scheduledAt;
      if (date == null) continue;
      if (date.year == now.year && date.month == now.month) {
        days.add(date.day);
      }
    }
    return days;
  }

  void setFilter(FollowUpListFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<ApiResponse<dynamic>?> loadFollowUps({int limit = 500}) async {
    final response = await runApiRequest(
      () => _repository.listFollowUps(page: 1, limit: limit),
    );
    if (response != null) {
      final parsed = extractFollowUps(response.data).toList();
      parsed.sort((a, b) {
        final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDate.compareTo(bDate);
      });
      _items
        ..clear()
        ..addAll(parsed);
      _summary = FollowUpQueueSummary.fromItems(_items);
      _hasLoaded = true;
      notifyListeners();
    } else {
      _hasLoaded = true;
      notifyListeners();
    }
    return response;
  }
}
