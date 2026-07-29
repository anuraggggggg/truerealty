import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/tasks_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'All';
  List<_TaskData> _tasks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final provider = context.read<TasksProvider>();
    final response = await provider.fetchTasks(limit: 100);
    if (!mounted) return;
    setState(() {
      _tasks = response == null
          ? const []
          : _extractItems(response.data).map(_TaskData.fromApi).toList();
      _error = response == null
          ? provider.error ?? 'Unable to load tasks.'
          : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final visibleTasks = _getRoleTasks(role);

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 80.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlue10,
              blurRadius: 18.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _TasksHeader(onMenuTap: widget.onMenuTap),
            SizedBox(height: 24.h),
            _buildRoleSummary(),
            SizedBox(height: 24.h),
            _TaskFilters(
              selectedFilter: _selectedFilter,
              onChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Text(
                  _selectedFilter == 'All' ? 'All Tasks' : _selectedFilter,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '${visibleTasks.length} total',
                  style: TextStyle(
                    color: AppColors.mutedNavy,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _TaskMessage(message: _error!, onRetry: _loadTasks)
            else if (visibleTasks.isEmpty)
              const _TaskMessage(message: 'No tasks found.')
            else
              ...visibleTasks.map(
                (task) => _TaskCard(
                  icon: task.icon,
                  title: task.title,
                  lead: task.lead,
                  time: task.time,
                  priority: task.priority,
                  color: task.color,
                  bg: task.bg,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_TaskData> _getRoleTasks(UserRole role) {
    List<_TaskData> roleTasks = _tasks;
    if (role == UserRole.telecaller) {
      roleTasks = _tasks
          .where((t) => t.type == 'Calls' || t.type == 'Overdue')
          .toList();
    } else if (role == UserRole.fieldExecutive) {
      roleTasks = _tasks
          .where((t) => t.type == 'Visits' || t.type == 'Meetings')
          .toList();
    }

    if (_selectedFilter == 'All') return roleTasks;
    return roleTasks.where((task) => task.type == _selectedFilter).toList();
  }

  Widget _buildRoleSummary() {
    final done = _tasks.where((task) => task.isDone).length;
    final overdue = _tasks.where((task) => task.type == 'Overdue').length;
    return _TaskSummaryRow(
      total: _tasks.length,
      pending: _tasks.length - done,
      done: done,
      overdue: overdue,
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onMenuTap != null) ...[
          IconButton(
            tooltip: 'Open navigation',
            onPressed: onMenuTap,
            icon: Icon(Icons.menu_rounded, color: AppColors.navy, size: 24.sp),
          ),
          SizedBox(width: 6.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Management',
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Track and manage your daily activities.',
                style: TextStyle(
                  color: const Color(0xFF667085),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 48.h,
          width: 48.w,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Add lead',
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.addLead),
            icon: Icon(Icons.add, color: AppColors.white, size: 24.sp),
          ),
        ),
      ],
    );
  }
}

class _TaskSummaryRow extends StatelessWidget {
  const _TaskSummaryRow({
    required this.total,
    required this.pending,
    required this.done,
    required this.overdue,
  });

  final int total;
  final int pending;
  final int done;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total',
            value: '$total',
            icon: Icons.today_outlined,
            color: AppColors.vividBlue,
            bg: const Color(0xFFEAF2FF),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            value: '$pending',
            icon: Icons.pending_actions_outlined,
            color: AppColors.orange,
            bg: const Color(0xFFFFF4E9),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Done',
            value: '$done',
            icon: Icons.check_circle_outline,
            color: AppColors.green,
            bg: const Color(0xFFEAF8F0),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: _cardDecoration(borderRadius: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32.h,
            width: 32.w,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF475467),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters({required this.selectedFilter, required this.onChanged});

  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            active: selectedFilter == 'All',
            onTap: () => onChanged('All'),
          ),
          _FilterChip(
            label: 'Calls',
            active: selectedFilter == 'Calls',
            onTap: () => onChanged('Calls'),
          ),
          _FilterChip(
            label: 'Visits',
            active: selectedFilter == 'Visits',
            onTap: () => onChanged('Visits'),
          ),
          _FilterChip(
            label: 'Meetings',
            active: selectedFilter == 'Meetings',
            onTap: () => onChanged('Meetings'),
          ),
          _FilterChip(
            label: 'Overdue',
            active: selectedFilter == 'Overdue',
            onTap: () => onChanged('Overdue'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: active ? AppColors.navy : AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: active ? AppColors.navy : const Color(0xFFD0D5DD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.white : const Color(0xFF344054),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskData {
  const _TaskData({
    required this.type,
    required this.icon,
    required this.title,
    required this.lead,
    required this.time,
    required this.priority,
    required this.color,
    required this.bg,
    required this.isDone,
  });

  final String type;
  final IconData icon;
  final String title;
  final String lead;
  final String time;
  final String priority;
  final Color color;
  final Color bg;
  final bool isDone;

  factory _TaskData.fromApi(dynamic value) {
    final map = value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
    String read(List<String> keys, [String fallback = '-']) {
      for (final key in keys) {
        final candidate = map[key];
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          if (candidate is Map) {
            for (final nestedKey in const ['name', 'title', 'fullName']) {
              if (candidate[nestedKey] != null) {
                return candidate[nestedKey].toString();
              }
            }
          }
          return candidate.toString();
        }
      }
      return fallback;
    }

    final rawType = read(const ['type', 'taskType', 'category'], 'Task');
    final status = read(const ['status'], 'Pending');
    final overdue =
        status.toLowerCase().contains('overdue') ||
        read(const ['isOverdue'], 'false').toLowerCase() == 'true';
    final type = overdue ? 'Overdue' : _displayType(rawType);
    final tone = _taskTone(type);
    return _TaskData(
      type: type,
      icon: tone.$1,
      title: read(const ['title', 'taskName', 'subject'], 'Task'),
      lead: read(const [
        'leadName',
        'lead',
        'customerName',
        'projectName',
        'project',
      ]),
      time: read(const ['dueAt', 'dueDate', 'scheduledAt', 'date', 'time']),
      priority: read(const ['priority'], 'Normal'),
      color: tone.$2,
      bg: tone.$3,
      isDone: const [
        'done',
        'completed',
        'closed',
      ].any(status.toLowerCase().contains),
    );
  }
}

List<dynamic> _extractItems(dynamic source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'tasks',
      'items',
      'results',
      'records',
      'rows',
      'data',
    ]) {
      final value = source[key];
      if (value is List) return value;
      final nested = _extractItems(value);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

String _displayType(String raw) {
  final value = raw.toLowerCase();
  if (value.contains('call')) return 'Calls';
  if (value.contains('visit')) return 'Visits';
  if (value.contains('meet')) return 'Meetings';
  return raw;
}

(IconData, Color, Color) _taskTone(String type) {
  switch (type) {
    case 'Calls':
      return (Icons.call_outlined, AppColors.green, const Color(0xFFEAF8F0));
    case 'Visits':
      return (
        Icons.event_available_outlined,
        AppColors.orange,
        const Color(0xFFFFF4E9),
      );
    case 'Meetings':
      return (
        Icons.groups_outlined,
        AppColors.vividBlue,
        const Color(0xFFEAF2FF),
      );
    case 'Overdue':
      return (
        Icons.warning_amber_rounded,
        AppColors.orange,
        const Color(0xFFFFF4E9),
      );
    default:
      return (
        Icons.task_alt_outlined,
        AppColors.purple,
        const Color(0xFFF4EAFE),
      );
  }
}

class _TaskMessage extends StatelessWidget {
  const _TaskMessage({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 40.h),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.icon,
    required this.title,
    required this.lead,
    required this.time,
    required this.priority,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String title;
  final String lead;
  final String time;
  final String priority;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: _cardDecoration(borderRadius: 16.r),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _PriorityBadge(label: priority),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  lead,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF475467),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF667085),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF667085),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isHigh = label == 'High';
    final isMedium = label == 'Medium';
    final color = isHigh
        ? AppColors.orange
        : isMedium
        ? AppColors.vividBlue
        : AppColors.green;
    final bg = isHigh
        ? const Color(0xFFFFF4E9)
        : isMedium
        ? const Color(0xFFEAF2FF)
        : const Color(0xFFEAF8F0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
    border: Border.all(color: const Color(0xFFF1F4F9), width: 1.2),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF061B69).withValues(alpha: 0.05),
        blurRadius: 20.r,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
