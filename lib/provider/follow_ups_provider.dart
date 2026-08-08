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
  String _pipelineFilter = 'All';
  FollowUpQueueSummary _summary = FollowUpQueueSummary.fromItems(const []);
  bool _hasLoaded = false;

  List<FollowUpModel> get items => List.unmodifiable(_items);
  FollowUpListFilter get filter => _filter;
  String get pipelineFilter => _pipelineFilter;
  FollowUpQueueSummary get summary => _summary;
  bool get hasLoaded => _hasLoaded;

  List<FollowUpModel> get visibleItems {
    final now = DateTime.now();
    final queueItems = switch (_filter) {
      FollowUpListFilter.all => items,
      FollowUpListFilter.today =>
        _items.where((item) => item.isDueToday(now)).toList(),
      FollowUpListFilter.overdue =>
        _items.where((item) => item.isOverdue).toList(),
      FollowUpListFilter.upcoming => _items.where((item) {
        if (item.isClosed || item.isOverdue || item.isDueToday(now)) {
          return false;
        }
        return item.scheduledAt != null && item.scheduledAt!.isAfter(now);
      }).toList(),
      FollowUpListFilter.completed =>
        _items.where((item) => item.isClosed).toList(),
    };
    return queueItems
        .where((item) => _matchesPipeline(item, _pipelineFilter))
        .toList(growable: false);
  }

  int countForPipeline(String pipeline) =>
      _items.where((item) => _matchesPipeline(item, pipeline)).length;

  bool _matchesPipeline(FollowUpModel item, String pipeline) {
    final selected = pipeline.trim().toLowerCase();
    if (selected == 'all') return true;
    final status = item.leadStatus.trim().toLowerCase();
    final type = item.leadType.trim().toLowerCase();
    final text = '$status $type';
    if (selected == 'hot lead') return type.contains('hot');
    if (selected == 'new lead') return status.contains('new');
    if (selected == 'interested') {
      return status.contains('interested') &&
          !status.contains('not interested');
    }
    if (selected == 'not interested') return status.contains('not interested');
    if (selected == 'site visit schedule') {
      return text.contains('site visit') && text.contains('schedul');
    }
    if (selected == 'site visit done') {
      return text.contains('site visit') &&
          (text.contains('done') || text.contains('complete'));
    }
    if (selected == 're-visit done') {
      return (text.contains('re-visit') ||
              text.contains('revisit') ||
              text.contains('re visit')) &&
          (text.contains('done') || text.contains('complete'));
    }
    if (selected == 'follow up') {
      return text.contains('follow up') || text.contains('follow-up');
    }
    if (selected == 'obm done') return text.contains('obm');
    if (selected == 'booking done') {
      return text.contains('booking') ||
          text.contains('booked') ||
          text.contains('converted');
    }
    return status == selected;
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
      final label = '${displayHour.toString().padLeft(2, '0')} $suffix';
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

  void setPipelineFilter(String filter) {
    if (_pipelineFilter == filter) return;
    _pipelineFilter = filter;
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
