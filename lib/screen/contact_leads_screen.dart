import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';

class ContactLeadsScreen extends StatefulWidget {
  const ContactLeadsScreen({super.key});

  @override
  State<ContactLeadsScreen> createState() => _ContactLeadsScreenState();
}

class _ContactLeadsScreenState extends State<ContactLeadsScreen> {
  static const _pageBackground = Color(0xFFF4F7FB);
  static const _borderColor = Color(0xFFDDE6F2);
  static const _mutedText = Color(0xFF5F728E);

  final _searchController = TextEditingController();
  DateTime _dateFrom = DateTime(2026, 7, 31);
  DateTime _dateTo = DateTime(2026, 8, 7);
  String _role = 'all';
  String _teamId = 'all';
  String _userId = 'all';
  String _activityType = 'all';
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _data = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPerformance());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPerformance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final provider = context.read<DashboardProvider>();
    final response = await provider.fetchAdminPerformance(
      dateFrom: _dateKey(_dateFrom),
      dateTo: _dateKey(_dateTo),
      role: _role,
      teamId: _teamId,
      userId: _userId,
      activityType: _activityType,
      search: _searchController.text.trim(),
      page: 1,
      limit: 20,
    );

    if (!mounted) return;
    setState(() {
      _data = response?.data is Map
          ? Map<String, dynamic>.from(response!.data as Map)
          : const {};
      _error = response == null
          ? provider.error ?? 'Unable to load contact lead performance.'
          : null;
      _isLoading = false;
    });
  }

  Map<String, dynamic> get _summary => _map(_data['summary']);
  Map<String, dynamic> get _filters => _map(_data['filters']);
  List<dynamic> get _users => _list(_data['users']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPerformance,
          color: AppColors.orangeStrong,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(23, 6, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildFilters(),
                if (_isLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _ErrorPanel(message: _error!, onRetry: _loadPerformance),
                ],
                const SizedBox(height: 20),
                _buildSummaryCards(),
                const SizedBox(height: 20),
                _buildPerformanceTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: _borderColor),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Leads',
                style: _textStyle(22, FontWeight.w800, AppColors.navy),
              ),
              const SizedBox(height: 2),
              Text(
                'Activity totals and user performance in the selected range.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _textStyle(13, FontWeight.w500, _mutedText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final roles = _list(_filters['roles']).map((e) => e.toString()).toList();
    final teams = _list(_filters['teams']);
    final employees = _list(_filters['employees']);
    final activities = _list(
      _filters['activityTypes'],
    ).map((e) => e.toString()).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(radius: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 900;
          final itemWidth = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - 48) / 4;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DateFilter(
                width: itemWidth,
                value: _dateFrom,
                onChanged: (value) {
                  setState(() => _dateFrom = value);
                  _loadPerformance();
                },
              ),
              _DateFilter(
                width: itemWidth,
                value: _dateTo,
                onChanged: (value) {
                  setState(() => _dateTo = value);
                  _loadPerformance();
                },
              ),
              _SelectFilter(
                width: itemWidth,
                value: _role,
                options: [
                  const _SelectOption('all', 'All roles'),
                  ...roles.map((role) => _SelectOption(role, _titleCase(role))),
                ],
                onChanged: (value) {
                  setState(() => _role = value);
                  _loadPerformance();
                },
              ),
              _SelectFilter(
                width: itemWidth,
                value: _teamId,
                options: [
                  const _SelectOption('all', 'All teams'),
                  ...teams.map(
                    (team) => _SelectOption(
                      _text(team, 'id'),
                      _text(team, 'name', fallback: 'Unnamed team'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _teamId = value);
                  _loadPerformance();
                },
              ),
              _SelectFilter(
                width: itemWidth,
                value: _userId,
                options: [
                  const _SelectOption('all', 'All employees'),
                  ...employees.map(
                    (employee) => _SelectOption(
                      _text(employee, 'id'),
                      _text(employee, 'name', fallback: 'Unnamed employee'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _userId = value);
                  _loadPerformance();
                },
              ),
              _SelectFilter(
                width: itemWidth,
                value: _activityType,
                options: [
                  const _SelectOption('all', 'All activity'),
                  ...activities.map(
                    (activity) => _SelectOption(activity, _titleCase(activity)),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _activityType = value);
                  _loadPerformance();
                },
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : itemWidth,
                height: 40,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _loadPerformance(),
                  style: _textStyle(13, FontWeight.w600, AppColors.navy),
                  decoration: _inputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadPerformance();
                            },
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      _SummaryItem(
        'Total calls',
        _int(_summary['totalCalls']),
        'Call logs in range',
        Icons.phone_in_talk_outlined,
        const Color(0xFF2563EB),
      ),
      _SummaryItem(
        'Connected calls',
        _int(_summary['connectedCalls']),
        'Successful conversations',
        Icons.check_circle_outline_rounded,
        const Color(0xFF059669),
      ),
      _SummaryItem(
        'Follow-ups done',
        _int(_summary['followUpsCompleted']),
        'Completed follow-ups',
        Icons.calendar_month_outlined,
        const Color(0xFFF97316),
      ),
      _SummaryItem(
        'Site visits done',
        _int(_summary['siteVisitsDone']),
        'Completed visits',
        Icons.groups_2_outlined,
        const Color(0xFF0F766E),
      ),
      _SummaryItem(
        'Remarks added',
        _int(_summary['remarksAdded']),
        'Lead remarks captured',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFF7C3AED),
      ),
      _SummaryItem(
        'Score earned',
        _int(_summary['scoreEarned']),
        'From lead status changes',
        Icons.trending_up_rounded,
        const Color(0xFF16A34A),
      ),
      _SummaryItem(
        'Tasks completed',
        _int(_summary['tasksCompleted']),
        'Employee tasks closed',
        Icons.task_alt_rounded,
        const Color(0xFF334155),
      ),
      _SummaryItem(
        'Bookings done',
        _int(_summary['bookingsDone']),
        'Closed bookings',
        Icons.emoji_events_outlined,
        const Color(0xFFEA580C),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 8
            : constraints.maxWidth >= 850
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 14,
          children: cards
              .map((card) => SizedBox(width: width, child: _MetricCard(card)))
              .toList(),
        );
      },
    );
  }

  Widget _buildPerformanceTable() {
    return Container(
      width: double.infinity,
      decoration: _panelDecoration(radius: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User performance',
                  style: _textStyle(18, FontWeight.w800, AppColors.navy),
                ),
                const SizedBox(height: 2),
                Text(
                  'Activity totals for each employee in the selected range.',
                  style: _textStyle(13, FontWeight.w500, _mutedText),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _borderColor),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              headingTextStyle: _textStyle(12, FontWeight.w800, AppColors.navy),
              dataTextStyle: _textStyle(12, FontWeight.w700, AppColors.navy),
              columnSpacing: 28,
              horizontalMargin: 16,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 82,
              columns: const [
                DataColumn(label: Text('Rank')),
                DataColumn(label: Text('Employee')),
                DataColumn(label: Text('Leads')),
                DataColumn(label: Text('Score earned')),
                DataColumn(label: Text('Calls')),
                DataColumn(label: Text('Follow-ups')),
                DataColumn(label: Text('Visits')),
                DataColumn(label: Text('Remarks')),
                DataColumn(label: Text('Tasks')),
                DataColumn(label: Text('Bookings')),
                DataColumn(label: Text('Latest activity')),
              ],
              rows: _users.map((user) => _buildUserRow(user)).toList(),
            ),
          ),
          if (_users.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                'No user performance found for this range.',
                style: _textStyle(13, FontWeight.w600, _mutedText),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(dynamic rawUser) {
    final user = _map(rawUser);
    final score = _int(user['scoreEarned']);
    return DataRow(
      cells: [
        DataCell(Text('#${_int(user['scoreRank'])}')),
        DataCell(_EmployeeCell(user: user)),
        DataCell(
          Text(
            '${_int(user['leadsAssigned'])} assigned - '
            '${_int(user['leadsCreated'])} created',
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$score',
                style: _textStyle(
                  12,
                  FontWeight.w800,
                  score > 0 ? const Color(0xFF16803E) : AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 180,
                child: Text(
                  _scoreBreakdown(user),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _textStyle(11, FontWeight.w500, _mutedText),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '${_int(user['calls'])} total - '
            '${_int(user['connectedCalls'])} connected',
          ),
        ),
        DataCell(
          Text(
            '${_int(user['followUpsCompleted'])} done - '
            '${_int(user['overdueFollowUps'])} overdue',
          ),
        ),
        DataCell(
          Text(
            '${_int(user['siteVisitsCompleted'])} done - '
            '${_int(user['siteVisitsScheduled'])} scheduled',
          ),
        ),
        DataCell(Text('${_int(user['remarksAdded'])}')),
        DataCell(Text('${_int(user['tasksCompleted'])}')),
        DataCell(Text('${_int(user['bookingsDone'])}')),
        DataCell(Text(_activityDate(user['latestActivityAt']))),
      ],
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) onPicked(picked);
  }

  static BoxDecoration _panelDecoration({required double radius}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _borderColor),
    );
  }

  static InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, size: 20, color: _mutedText),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF94A3B8)),
      ),
    );
  }

  static TextStyle _textStyle(double size, FontWeight weight, Color color) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }

  static Map<String, dynamic> _map(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  static List<dynamic> _list(Object? value) {
    return value is List ? value : const [];
  }

  static int _int(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _text(Object? source, String key, {String fallback = ''}) {
    final map = _map(source);
    final value = map[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static String _displayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _activityDate(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'No activity';
    final local = parsed.toLocal();
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final marker = local.hour >= 12 ? 'pm' : 'am';
    return '${_displayDateWords(local)} : $hour:$minute $marker';
  }

  static String _displayDateWords(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  static String _scoreBreakdown(Map<String, dynamic> user) {
    final breakdown = _list(user['scoreBreakdown']);
    if (breakdown.isEmpty) return 'No scored status changes';
    return breakdown
        .map((item) {
          final map = _map(item);
          return '${_text(map, 'statusName')}: ${_int(map['points'])}';
        })
        .join(' / ');
  }

  static String _titleCase(String value) {
    final words = value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty);
    return words
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.width,
    required this.value,
    required this.onChanged,
  });

  final double width;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_ContactLeadsScreenState>();
    return SizedBox(
      width: width,
      height: 40,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => state?._pickDate(initial: value, onPicked: onChanged),
        child: InputDecorator(
          decoration: _ContactLeadsScreenState._inputDecoration(
            hintText: '',
            prefixIcon: Icons.calendar_month_outlined,
            suffixIcon: const Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: Colors.black87,
            ),
          ),
          child: Text(
            _ContactLeadsScreenState._displayDate(value),
            style: _ContactLeadsScreenState._textStyle(
              13,
              FontWeight.w600,
              AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectFilter extends StatelessWidget {
  const _SelectFilter({
    required this.width,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final double width;
  final String value;
  final List<_SelectOption> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeOptions = options.where((item) => item.value.isNotEmpty).toList();
    final safeValue = safeOptions.any((item) => item.value == value)
        ? value
        : safeOptions.first.value;
    return SizedBox(
      width: width,
      height: 40,
      child: DropdownButtonFormField<String>(
        initialValue: safeValue,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _ContactLeadsScreenState._mutedText,
        ),
        decoration: _ContactLeadsScreenState._inputDecoration(hintText: ''),
        style: _ContactLeadsScreenState._textStyle(
          13,
          FontWeight.w600,
          AppColors.navy,
        ),
        items: safeOptions
            .map(
              (option) => DropdownMenuItem<String>(
                value: option.value,
                child: Text(option.label, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.item);

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: _ContactLeadsScreenState._panelDecoration(radius: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 21, color: item.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _ContactLeadsScreenState._textStyle(
                    12,
                    FontWeight.w800,
                    _ContactLeadsScreenState._mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.value}',
                  style: _ContactLeadsScreenState._textStyle(
                    23,
                    FontWeight.w800,
                    AppColors.navy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _ContactLeadsScreenState._textStyle(
                    12,
                    FontWeight.w500,
                    _ContactLeadsScreenState._mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCell extends StatelessWidget {
  const _EmployeeCell({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final name = _ContactLeadsScreenState._text(
      user,
      'name',
      fallback: 'Unknown',
    );
    final image = _ContactLeadsScreenState._text(user, 'image');
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.navy,
          backgroundImage: image.isEmpty ? null : NetworkImage(image),
          child: image.isEmpty
              ? Text(
                  initials,
                  style: _ContactLeadsScreenState._textStyle(
                    12,
                    FontWeight.w800,
                    Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 240,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _ContactLeadsScreenState._textStyle(
                  12,
                  FontWeight.w800,
                  AppColors.navy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_ContactLeadsScreenState._text(user, 'designation')} - '
                '${_ContactLeadsScreenState._text(user, 'teamName')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _ContactLeadsScreenState._textStyle(
                  12,
                  FontWeight.w500,
                  _ContactLeadsScreenState._mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB91C1C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: _ContactLeadsScreenState._textStyle(
                13,
                FontWeight.w600,
                const Color(0xFF991B1B),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem(
    this.label,
    this.value,
    this.caption,
    this.icon,
    this.color,
  );

  final String label;
  final int value;
  final String caption;
  final IconData icon;
  final Color color;
}

class _SelectOption {
  const _SelectOption(this.value, this.label);

  final String value;
  final String label;
}
