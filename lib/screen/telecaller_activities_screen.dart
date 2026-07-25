import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

class TelecallerActivitiesScreen extends StatefulWidget {
  const TelecallerActivitiesScreen({super.key});

  @override
  State<TelecallerActivitiesScreen> createState() =>
      _TelecallerActivitiesScreenState();
}

class _TelecallerActivitiesScreenState
    extends State<TelecallerActivitiesScreen> {
  bool _loading = true;
  String? _error;
  List<_ActivityItem> _activities = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<DashboardProvider>();
    final response = await provider.fetchTelecallerDashboard();
    if (!mounted) return;
    setState(() {
      _activities = _activityList(
        response?.data,
      ).map(_ActivityItem.fromApi).toList();
      _error = response == null ? provider.error : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'All Activities',
          style: GoogleFonts.inter(
            color: AppColors.navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orangeDeep,
          onRefresh: _load,
          child: _loading
              ? const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: AppListSkeleton(itemCount: 5, itemHeight: 92),
                )
              : _error != null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.orangeDeep,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Try again'),
                    ),
                  ],
                )
              : _activities.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 100),
                    Icon(
                      Icons.history_toggle_off_outlined,
                      size: 44,
                      color: AppColors.iconMuted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No activities available yet.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _activities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _ActivityCard(item: _activities[index]),
                ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item});

  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.orangeBg,
            child: Icon(
              Icons.bolt_outlined,
              size: 20,
              color: AppColors.orangeDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.mutedNavy,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (item.time.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    item.time,
                    style: GoogleFonts.inter(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;

  factory _ActivityItem.fromApi(Object? source) {
    if (source is! Map) {
      return _ActivityItem(
        title: source?.toString() ?? 'Activity',
        subtitle: '',
        time: '',
      );
    }
    final map = Map<String, dynamic>.from(source);
    return _ActivityItem(
      title: _firstText(map, const [
        'title',
        'activity',
        'type',
        'action',
        'event',
      ], fallback: 'Activity'),
      subtitle: _firstText(map, const [
        'description',
        'message',
        'subtitle',
        'leadName',
        'details',
      ]),
      time: _firstText(map, const ['createdAt', 'updatedAt', 'time', 'date']),
    );
  }
}

List<dynamic> _activityList(Object? source, [int depth = 0]) {
  if (source is List) return source;
  if (source is! Map || depth > 5) return const [];
  for (final key in const [
    'recentActivities',
    'activities',
    'activity',
    'timeline',
    'items',
  ]) {
    final value = source[key];
    if (value is List) return value;
  }
  for (final key in const ['data', 'dashboard', 'summary', 'result']) {
    final nested = _activityList(source[key], depth + 1);
    if (nested.isNotEmpty) return nested;
  }
  return const [];
}

String _firstText(
  Map<String, dynamic> map,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}
