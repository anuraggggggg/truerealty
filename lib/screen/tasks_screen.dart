import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'All';

  static const List<_TaskData> _tasks = [
    _TaskData(
      type: 'Calls',
      icon: Icons.call_outlined,
      title: 'Follow-up Call',
      lead: 'Rahul Sharma',
      time: '10:00 AM',
      priority: 'High',
      color: AppColors.green,
      bg: Color(0xFFEAF8F0),
    ),
    _TaskData(
      type: 'Visits',
      icon: Icons.event_available_outlined,
      title: 'Site Visit',
      lead: 'Green Valley Project',
      time: '11:30 AM',
      priority: 'High',
      color: AppColors.orange,
      bg: Color(0xFFFFF4E9),
    ),
    _TaskData(
      type: 'Meetings',
      icon: Icons.groups_outlined,
      title: 'Team Meeting',
      lead: 'Marketing Team',
      time: '02:00 PM',
      priority: 'Medium',
      color: AppColors.vividBlue,
      bg: Color(0xFFEAF2FF),
    ),
    _TaskData(
      type: 'Calls',
      icon: Icons.phone_forwarded_outlined,
      title: 'Follow-up Call',
      lead: 'Priya Mehta',
      time: '04:30 PM',
      priority: 'Medium',
      color: AppColors.purple,
      bg: Color(0xFFF4EAFE),
    ),
    _TaskData(
      type: 'Overdue',
      icon: Icons.warning_amber_rounded,
      title: 'Pending Callback',
      lead: 'Neha Kapoor',
      time: 'Yesterday, 06:00 PM',
      priority: 'High',
      color: AppColors.orange,
      bg: Color(0xFFFFF4E9),
    ),
    _TaskData(
      type: 'Upcoming',
      icon: Icons.mail_outline,
      title: 'Send Proposal',
      lead: 'Amit Singh',
      time: 'Tomorrow, 09:30 AM',
      priority: 'Low',
      color: AppColors.vividBlue,
      bg: Color(0xFFEAF2FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final visibleTasks = _getRoleTasks(role);

    return Container(
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
        children: [
          const _TasksHeader(),
          SizedBox(height: 24.h),
          _buildRoleSummary(role),
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

  Widget _buildRoleSummary(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return const _TaskSummaryRow();
      case UserRole.telecaller:
        return const _TelecallerTaskSummary();
      case UserRole.fieldExecutive:
        return const _FieldExecutiveTaskSummary();
    }
  }
}

class _TelecallerTaskSummary extends StatelessWidget {
  const _TelecallerTaskSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'To Call',
            value: '45',
            icon: Icons.phone_forwarded_outlined,
            color: AppColors.vividBlue,
            bg: const Color(0xFFEAF2FF),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Overdue',
            value: '8',
            icon: Icons.history_toggle_off_outlined,
            color: AppColors.orange,
            bg: const Color(0xFFFFF4E9),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Goals',
            value: '75%',
            icon: Icons.track_changes_outlined,
            color: AppColors.green,
            bg: const Color(0xFFEAF8F0),
          ),
        ),
      ],
    );
  }
}

class _FieldExecutiveTaskSummary extends StatelessWidget {
  const _FieldExecutiveTaskSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Visits',
            value: '6',
            icon: Icons.directions_car_outlined,
            color: AppColors.vividBlue,
            bg: const Color(0xFFEAF2FF),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Meetings',
            value: '3',
            icon: Icons.handshake_outlined,
            color: AppColors.orange,
            bg: const Color(0xFFFFF4E9),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Collections',
            value: 'Rs 12k',
            icon: Icons.payments_outlined,
            color: AppColors.green,
            bg: const Color(0xFFEAF8F0),
          ),
        ),
      ],
    );
  }
}

class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
  const _TaskSummaryRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Today',
            value: '12',
            icon: Icons.today_outlined,
            color: AppColors.vividBlue,
            bg: const Color(0xFFEAF2FF),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            value: '7',
            icon: Icons.pending_actions_outlined,
            color: AppColors.orange,
            bg: const Color(0xFFFFF4E9),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _SummaryCard(
            label: 'Done',
            value: '5',
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
  });

  final String type;
  final IconData icon;
  final String title;
  final String lead;
  final String time;
  final String priority;
  final Color color;
  final Color bg;
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
