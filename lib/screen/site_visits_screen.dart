import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool?> showCreateSiteVisitSheet(
  BuildContext context, {
  LeadModel? initialLead,
  Future<void> Function()? onCreated,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CreateSiteVisitSheet(
      initialLead: initialLead,
      onCreated: onCreated ?? () async {},
    ),
  );
}

class SiteVisitDetailsScreen extends StatefulWidget {
  const SiteVisitDetailsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  static const Color _bg = Color(0xFFF8FAFD);
  static const Color _cardBorder = Color(0xFFDCE6F3);
  static const Color _title = Color(0xFF0F2B57);
  static const Color _orange = Color(0xFFFF7315);

  @override
  State<SiteVisitDetailsScreen> createState() => _SiteVisitDetailsScreenState();
}

class _SiteVisitDetailsScreenState extends State<SiteVisitDetailsScreen> {
  static const Color _bg = SiteVisitDetailsScreen._bg;
  static const Color _cardBorder = SiteVisitDetailsScreen._cardBorder;
  static const Color _title = SiteVisitDetailsScreen._title;
  static const Color _orange = SiteVisitDetailsScreen._orange;

  final TextEditingController _searchController = TextEditingController();
  List<_VisitOption> _executives = const [];
  bool _loadingExecutives = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final provider = context.read<SiteVisitProvider>();
    await Future.wait([
      provider.fetchSiteVisits(limit: 100),
      if (_executives.isEmpty) _loadExecutives(),
    ]);
  }

  Future<void> _loadExecutives() async {
    if (mounted) setState(() => _loadingExecutives = true);
    final response = await context
        .read<SiteVisitProvider>()
        .fetchSiteVisitOptions();
    var options = _namedOptionGroup(response?.data, const [
      'executives',
      'fieldExecutives',
      'employees',
    ]);
    if (options.isEmpty &&
        mounted &&
        context.read<AuthProvider>().canViewModule('employees')) {
      final employeeResponse = await context
          .read<EmployeeProvider>()
          .fetchEmployees(role: 'fieldExecutive', status: 'Active', limit: 100);
      options = _visitOptions(employeeResponse?.data);
    }
    if (!mounted) return;
    setState(() {
      _executives = options;
      _loadingExecutives = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SiteVisitProvider>();
    final visible = provider.visibleVisits;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: RefreshIndicator(
            color: _orange,
            onRefresh: _load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 8.h),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(provider),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => showCreateSiteVisitSheet(
                              context,
                              onCreated: _load,
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _orange,
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: Icon(
                              Icons.add_rounded,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Create Site Visit',
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _buildExecutiveDropdown(provider),
                        SizedBox(height: 12.h),
                        TextField(
                          controller: _searchController,
                          onChanged: provider.setSearchQuery,
                          style: GoogleFonts.inter(fontSize: 13.5.sp),
                          decoration: InputDecoration(
                            hintText:
                                'Search lead, phone, project, executive...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF98A2B3),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF98A2B3),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(color: _cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: const BorderSide(color: _cardBorder),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        if (provider.isLoading && !provider.hasLoaded)
                          const AppListSkeleton(itemCount: 4, itemHeight: 154)
                        else if (provider.error != null &&
                            provider.siteVisits.isEmpty)
                          _ApiErrorCard(
                            message: provider.error!,
                            onRetry: _load,
                          )
                        else ...[
                          _MetricsStrip(provider: provider),
                          SizedBox(height: 14.h),
                          _FilterTabs(provider: provider),
                          SizedBox(height: 12.h),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!(provider.isLoading && !provider.hasLoaded) &&
                    !(provider.error != null &&
                        provider.siteVisits.isEmpty)) ...[
                  if (visible.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 24.h),
                        child: Text(
                          provider.siteVisits.isEmpty
                              ? 'No site visits found for your account. The API returned 0 visits for this role.'
                              : 'No visits match this filter.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 12.h),
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final visit = visible[index];
                          return _SiteVisitMobileCard(visit: visit);
                        },
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(15.w, 4.h, 15.w, 28.h),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _TodayUpcomingCard(visits: provider.todayAndUpcoming),
                          SizedBox(height: 14.h),
                          _OperationsSnapshotCard(provider: provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SiteVisitProvider provider) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Site Visits',
          style: GoogleFonts.inter(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: _title,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Central visit control for scheduled property tours, revisits, virtual visits, and field execution.',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF44474E),
          ),
        ),
      ],
    );
    if (widget.onMenuTap == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: content),
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            color: _title,
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Open navigation',
          visualDensity: VisualDensity.compact,
          onPressed: widget.onMenuTap,
          icon: Icon(Icons.menu_rounded, size: 24.sp, color: _title),
        ),
        Expanded(child: content),
        IconButton(
          tooltip: 'Refresh',
          onPressed: provider.isLoading ? null : _load,
          icon: const Icon(Icons.refresh_rounded),
          color: _title,
        ),
      ],
    );
  }

  Widget _buildExecutiveDropdown(SiteVisitProvider provider) {
    return DropdownButtonFormField<String?>(
      initialValue: provider.selectedExecutiveId,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        suffixIcon: _loadingExecutives
            ? Padding(
                padding: EdgeInsets.all(13.r),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      ),
      hint: const Text('All Executives'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All Executives'),
        ),
        ..._executives.map(
          (executive) => DropdownMenuItem<String?>(
            value: executive.id,
            child: Text(executive.label, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: _loadingExecutives ? null : provider.setSelectedExecutiveId,
    );
  }
}

class _MetricsStrip extends StatelessWidget {
  const _MetricsStrip({required this.provider});

  final SiteVisitProvider provider;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _SiteVisitMetric(
        icon: Icons.event_available_outlined,
        iconColor: const Color(0xFF2563EB),
        iconBg: const Color(0xFFEAF2FF),
        title: 'Total Visits',
        value: '${provider.totalVisits}',
        subtitle: 'All loaded visits',
      ),
      _SiteVisitMetric(
        icon: Icons.access_time_outlined,
        iconColor: const Color(0xFFFF8A26),
        iconBg: const Color(0xFFFFF2E8),
        title: 'Upcoming',
        value: '${provider.upcomingVisits}',
        subtitle: 'Next scheduled',
      ),
      _SiteVisitMetric(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF10B981),
        iconBg: const Color(0xFFE8FBF3),
        title: 'Completed',
        value: '${provider.completedVisits}',
        subtitle: 'Completed tours',
      ),
      _SiteVisitMetric(
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFF04438),
        iconBg: const Color(0xFFFFEFEF),
        title: 'Cancelled',
        value: '${provider.cancelledVisits}',
        subtitle: 'Needs reschedule',
      ),
      _SiteVisitMetric(
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF7C3AED),
        iconBg: const Color(0xFFF3E8FF),
        title: 'Field Executives',
        value: '${provider.fieldExecutiveCount}',
        subtitle: 'Assigned this week',
      ),
    ];

    return SizedBox(
      height: 118.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return SizedBox(
            width: 148.w,
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      color: metric.iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      metric.icon,
                      color: metric.iconColor,
                      size: 16.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    metric.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  Text(
                    metric.value,
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: SiteVisitDetailsScreen._title,
                    ),
                  ),
                  Text(
                    metric.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.provider});

  final SiteVisitProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SiteVisitListFilter.values.map((filter) {
          final selected = provider.filter == filter;
          final count = provider.countFor(filter);
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: InkWell(
              onTap: () => provider.setFilter(filter),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEAF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF2563EB)
                        : SiteVisitDetailsScreen._cardBorder,
                  ),
                ),
                child: Text(
                  '${filter.label} ($count)',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF475467),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SiteVisitMobileCard extends StatelessWidget {
  const _SiteVisitMobileCard({required this.visit});

  final SiteVisitModel visit;

  Future<void> _callLead(BuildContext context) async {
    final digits = visit.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.replaceAll('+', '').length < 7) return;
    await launchUrl(
      Uri(scheme: 'tel', path: digits),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(visit.status);
    final typeColors = _typeColors(visit.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: const Color(0xFFE9EEF8),
                    child: Text(
                      _initials(visit.leadName),
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF173A6D),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.leadName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF173A6D),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: () => _callLead(context),
                          child: Text(
                            visit.formattedPhone,
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Pill(
                        label: visit.status,
                        foreground: statusColors.$1,
                        background: statusColors.$2,
                      ),
                      SizedBox(height: 6.h),
                      _Pill(
                        label: visit.type,
                        foreground: typeColors.$1,
                        background: typeColors.$2,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      label: 'Schedule',
                      title: visit.date,
                      subtitle: visit.durationMinutes == null
                          ? visit.time
                          : '${visit.time} · ${visit.durationMinutes} min',
                      icon: Icons.event_outlined,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _InfoTile(
                      label: 'Reminder',
                      title: visit.reminderAt == null ? 'No reminder' : 'Set',
                      subtitle: visit.reminderLabel,
                      icon: Icons.notifications_none_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE6ECF4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: SizedBox(
                        width: 46.w,
                        height: 46.w,
                        child: visit.projectImageUrl.isEmpty
                            ? ColoredBox(
                                color: const Color(0xFFEAF2FF),
                                child: Icon(
                                  Icons.apartment_rounded,
                                  color: const Color(0xFF2563EB),
                                  size: 22.sp,
                                ),
                              )
                            : Image.network(
                                visit.projectImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => ColoredBox(
                                  color: const Color(0xFFEAF2FF),
                                  child: Icon(
                                    Icons.apartment_rounded,
                                    color: const Color(0xFF2563EB),
                                    size: 22.sp,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.project,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF173A6D),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            visit.unitLabel.isEmpty
                                ? (visit.location.isEmpty
                                      ? 'Location not available'
                                      : visit.location)
                                : visit.unitLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: const Color(0xFFE9EEF8),
                    backgroundImage: visit.executiveImageUrl.isEmpty
                        ? null
                        : NetworkImage(visit.executiveImageUrl),
                    child: visit.executiveImageUrl.isEmpty
                        ? Text(
                            _initials(visit.executiveName),
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF173A6D),
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.executiveName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF173A6D),
                          ),
                        ),
                        Text(
                          visit.executiveRole.isEmpty
                              ? 'Field executive'
                              : visit.executiveRole,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF98A2B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('completed')) {
      return (const Color(0xFF168553), const Color(0xFFE8F8EF));
    }
    if (value.contains('cancel')) {
      return (const Color(0xFFDC2626), const Color(0xFFFFE8E8));
    }
    if (value.contains('confirmed')) {
      return (const Color(0xFFB45309), const Color(0xFFFFF7E8));
    }
    if (value.contains('upcoming')) {
      return (const Color(0xFF2563EB), const Color(0xFFEAF2FF));
    }
    return (const Color(0xFFEA580C), const Color(0xFFFFF1E8));
  }

  (Color, Color) _typeColors(String type) {
    final value = type.toLowerCase();
    if (value.contains('virtual')) {
      return (const Color(0xFF7C3AED), const Color(0xFFF3E8FF));
    }
    if (value.contains('re')) {
      return (const Color(0xFF0F766E), const Color(0xFFE6F7F4));
    }
    return (const Color(0xFF334155), const Color(0xFFF1F5F9));
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE6ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: const Color(0xFF667085)),
              SizedBox(width: 4.w),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF98A2B3),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF173A6D),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayUpcomingCard extends StatelessWidget {
  const _TodayUpcomingCard({required this.visits});

  final List<SiteVisitModel> visits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today & Upcoming',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: SiteVisitDetailsScreen._title,
            ),
          ),
          SizedBox(height: 10.h),
          if (visits.isEmpty)
            Text(
              'No upcoming visits.',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF667085),
              ),
            )
          else
            ...visits.map(
              (visit) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE6ECF4)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        visit.time,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF173A6D),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visit.leadName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF173A6D),
                              ),
                            ),
                            Text(
                              visit.project,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: const Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Pill(
                        label: visit.status,
                        foreground: const Color(0xFF2563EB),
                        background: const Color(0xFFEAF2FF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OperationsSnapshotCard extends StatelessWidget {
  const _OperationsSnapshotCard({required this.provider});

  final SiteVisitProvider provider;

  @override
  Widget build(BuildContext context) {
    final rate = provider.completionRate;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operations Snapshot',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: SiteVisitDetailsScreen._title,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Completion Rate',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF667085),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${rate.toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF168553),
            ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: (rate / 100).clamp(0, 1),
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE8F8EF),
              color: const Color(0xFF168553),
            ),
          ),
        ],
      ),
    );
  }
}

class _SiteVisitMetric {
  const _SiteVisitMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;
}

class _ApiErrorCard extends StatelessWidget {
  const _ApiErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFFB42318),
            ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _CreateSiteVisitSheet extends StatefulWidget {
  const _CreateSiteVisitSheet({required this.onCreated, this.initialLead});

  final Future<void> Function() onCreated;
  final LeadModel? initialLead;

  @override
  State<_CreateSiteVisitSheet> createState() => _CreateSiteVisitSheetState();
}

class _CreateSiteVisitSheetState extends State<_CreateSiteVisitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _meetingPointController = TextEditingController();
  final _specialRequestController = TextEditingController();
  List<_VisitOption> _leads = const [];
  List<_VisitOption> _projects = const [];
  List<_VisitOption> _units = const [];
  List<_VisitOption> _executives = const [];
  List<_VisitOption> _types = const [
    _VisitOption(id: 'SITE_VISIT', label: 'Site Visit'),
    _VisitOption(id: 'REVISIT', label: 'Revisit'),
    _VisitOption(id: 'VIRTUAL_VISIT', label: 'Virtual Visit'),
  ];
  _VisitOption? _lead;
  _VisitOption? _project;
  _VisitOption? _unit;
  _VisitOption? _executive;
  _VisitOption? _type;
  String _transport = 'Own Vehicle';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _duration = 60;
  int _visitors = 1;
  bool _loading = true;
  bool _loadingUnits = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = _types.first;
    final initialLead = widget.initialLead;
    if (initialLead?.id != null) {
      _lead = _VisitOption(
        id: initialLead!.id!,
        label: '${initialLead.name} · ${initialLead.phone}',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final results = await Future.wait([
      context.read<LeadProvider>().fetchLeads(page: 1, limit: 100),
      context.read<ProjectProvider>().fetchProjects(status: 'Active'),
      context.read<EmployeeProvider>().fetchEmployees(
        role: 'all',
        status: 'Active',
        limit: 100,
      ),
      context.read<SiteVisitProvider>().fetchSiteVisitOptions(),
    ]);
    if (!mounted) return;
    final apiTypes = _namedOptionGroup(results[3]?.data, const [
      'visitTypes',
      'types',
    ]);
    final apiLeads = _namedOptionGroup(results[3]?.data, const [
      'leads',
      'leadOptions',
    ]);
    final apiProjects = _namedOptionGroup(results[3]?.data, const [
      'projects',
      'projectOptions',
    ]);
    final apiExecutives = _namedOptionGroup(results[3]?.data, const [
      'fieldExecutives',
      'executives',
      'employees',
    ]);
    final leads = _visitOptions(results[0]?.data, leadOptions: true);
    final projects = _visitOptions(results[1]?.data);
    final executives = _visitOptions(results[2]?.data);
    setState(() {
      _leads = apiLeads.isNotEmpty ? apiLeads : leads;
      _projects = projects.isNotEmpty ? projects : apiProjects;
      _executives = executives.isNotEmpty ? executives : apiExecutives;
      final initialId = widget.initialLead?.id;
      if (initialId != null) {
        final matches = _leads.where((option) => option.id == initialId);
        if (matches.isNotEmpty) {
          _lead = matches.first;
        } else if (_lead != null) {
          _leads = [_lead!, ..._leads];
        }
      }
      if (apiTypes.isNotEmpty) {
        _types = apiTypes;
        _type = apiTypes.first;
      }
      if (_projects.isEmpty || _executives.isEmpty) {
        final missing = [
          if (_projects.isEmpty) 'projects',
          if (_executives.isEmpty) 'executives',
        ].join(' and ');
        _error = 'No active $missing were returned by the CRM.';
      }
      _loading = false;
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null && mounted) setState(() => _time = selected);
  }

  Future<void> _selectProject(_VisitOption? project) async {
    setState(() {
      _project = project;
      _unit = null;
      _units = const [];
      _loadingUnits = project != null;
      _error = null;
    });
    if (project == null) return;
    final response = await context.read<ProjectProvider>().fetchUnits(
      project.id,
    );
    if (!mounted) return;
    setState(() {
      _units = _visitOptions(response?.data);
      _loadingUnits = false;
      if (response == null) {
        _error =
            context.read<ProjectProvider>().error ??
            'Unable to fetch units for ${project.label}.';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final response = await context
        .read<SiteVisitProvider>()
        .createSiteVisitFromApi({
          'leadId': _lead!.id,
          'projectId': _project!.id,
          if (_unit != null) 'unitId': _unit!.id,
          'assignedExecutiveId': _executive!.id,
          'visitType': _type!.label,
          'scheduledAt': scheduledAt.toIso8601String(),
          'durationMinutes': _duration,
          'visitorCount': _visitors,
          'status': 'Scheduled',
          'transportMode': _transport,
          if (_meetingPointController.text.trim().isNotEmpty)
            'meetingPoint': _meetingPointController.text.trim(),
          if (_specialRequestController.text.trim().isNotEmpty)
            'specialRequest': _specialRequestController.text.trim(),
        });
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _saving = false;
        _error =
            context.read<SiteVisitProvider>().error ??
            'Unable to schedule this visit.';
      });
      return;
    }
    Navigator.of(context).pop(true);
    await widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 12.w, 12.h),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: SiteVisitDetailsScreen._orange,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Site Visit',
                          style: GoogleFonts.inter(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF173A6D),
                          ),
                        ),
                        Text(
                          'Schedule from live CRM records',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VisitDropdown(
                              label: 'Lead *',
                              hint: 'Select lead',
                              value: _lead,
                              items: _leads,
                              onChanged: (value) =>
                                  setState(() => _lead = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Project *',
                              hint: 'Select project',
                              value: _project,
                              items: _projects,
                              onChanged: _selectProject,
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              key: ValueKey(
                                'units-${_project?.id ?? 'no-project'}',
                              ),
                              label: 'Unit',
                              required: false,
                              hint: _loadingUnits
                                  ? 'Loading units...'
                                  : _project == null
                                  ? 'Select a project first'
                                  : _units.isEmpty
                                  ? 'No units available'
                                  : 'Select unit',
                              value: _unit,
                              items: _units,
                              onChanged: _project == null || _loadingUnits
                                  ? null
                                  : (value) => setState(() => _unit = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Assigned Executive *',
                              hint: 'Select field executive',
                              value: _executive,
                              items: _executives,
                              onChanged: (value) =>
                                  setState(() => _executive = value),
                            ),
                            SizedBox(height: 14.h),
                            _VisitDropdown(
                              label: 'Visit Type *',
                              hint: 'Select visit type',
                              value: _type,
                              items: _types,
                              onChanged: (value) =>
                                  setState(() => _type = value),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _VisitPicker(
                                    label: 'Visit Date *',
                                    value:
                                        '${_twoDigits(_date.day)}-${_twoDigits(_date.month)}-${_date.year}',
                                    icon: Icons.calendar_month_outlined,
                                    onTap: _selectDate,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _VisitPicker(
                                    label: 'Visit Time *',
                                    value: _time.format(context),
                                    icon: Icons.access_time_outlined,
                                    onTap: _selectTime,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _VisitIntDropdown(
                                    label: 'Duration',
                                    value: _duration,
                                    values: const [30, 45, 60, 90, 120],
                                    suffix: 'minutes',
                                    onChanged: (value) =>
                                        setState(() => _duration = value),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: _VisitIntDropdown(
                                    label: 'Visitors',
                                    value: _visitors,
                                    values: const [1, 2, 3, 4, 5, 6],
                                    suffix: '',
                                    onChanged: (value) =>
                                        setState(() => _visitors = value),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            DropdownButtonFormField<String>(
                              initialValue: _transport,
                              decoration: _visitInputDecoration('Transport'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Own Vehicle',
                                  child: Text('Own Vehicle'),
                                ),
                                DropdownMenuItem(
                                  value: 'Company Vehicle',
                                  child: Text('Company Vehicle'),
                                ),
                                DropdownMenuItem(
                                  value: 'Public Transport',
                                  child: Text('Public Transport'),
                                ),
                                DropdownMenuItem(
                                  value: 'Cab',
                                  child: Text('Cab'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _transport = value ?? 'Own Vehicle',
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _meetingPointController,
                              decoration: _visitInputDecoration(
                                'Meeting point',
                              ),
                            ),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: _specialRequestController,
                              maxLines: 3,
                              decoration: _visitInputDecoration(
                                'Special request or visit notes',
                              ),
                            ),
                            if (_error != null) ...[
                              SizedBox(height: 12.h),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: Color(0xFFD92D20),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                16.h + MediaQuery.viewPaddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFDCE6F3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _loading || _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SiteVisitDetailsScreen._orange,
                        foregroundColor: Colors.white,
                      ),
                      icon: _saving
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.event_available_outlined),
                      label: Text(_saving ? 'Scheduling...' : 'Schedule Visit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Legacy presentation widgets retained for compatibility with older layouts.
// ignore: unused_element
class _SelectedLeadSummaryCard extends StatelessWidget {
  const _SelectedLeadSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'SELECTED LEAD',
                  value: 'Not selected',
                ),
              ),
              Expanded(
                child: _SummaryItem(label: 'PHONE', value: '-'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(label: 'PROJECT', value: 'Not selected'),
              ),
              Expanded(
                child: _SummaryItem(label: 'UNIT', value: '-'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SchedulingTipCard extends StatelessWidget {
  const _SchedulingTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFA64D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: const BoxDecoration(
              color: SiteVisitDetailsScreen._orange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info, size: 12.sp, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduling Tip',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC05621),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Use the searchable lead field instead of typing IDs. IDs are\nstill sent internally to the API.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFC05621),
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

// ignore: unused_element
class _LeadContextCard extends StatelessWidget {
  const _LeadContextCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_2_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Lead Context',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            'Lead *',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          const _SheetInput(
            value: 'Search lead by name, phone, or lead ID',
            trailingIcon: Icons.keyboard_arrow_down,
            muted: true,
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(label: 'Lead Stage', value: '-'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(label: 'Source', value: '-'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _FieldHandoffCard extends StatelessWidget {
  const _FieldHandoffCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 18.sp,
                color: const Color(0xFF2962FF),
              ),
              SizedBox(width: 8.w),
              Text(
                'Field Handoff',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Type *',
                  value: 'Site Visit',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Assigned Executive *',
                  value: 'Search executive',
                  trailingIcon: Icons.keyboard_arrow_down,
                  muted: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Date *',
                  value: 'dd-mm-yyyy',
                  muted: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visit Time *',
                  value: '10:00 AM',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Duration',
                  value: '60 Minutes',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Visitors',
                  value: '2 Visitors',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: const [
              Expanded(
                child: _LabeledInput(
                  label: 'Transport',
                  value: 'Own Vehicle',
                  trailingIcon: Icons.keyboard_arrow_down,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _LabeledInput(
                  label: 'Meeting Point',
                  value: 'Sales Gallery',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Special Request',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF344054),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              'Parking needs, senior citizen assistance,\npreferred sample flat, negotiation context...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SheetFooterBar extends StatelessWidget {
  const _SheetFooterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFDCE6F3))),
      ),
      child: Column(
        children: [
          Text(
            'Required: lead, project, date, time, and executive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF98A2B3),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42.h),
                    side: const BorderSide(color: Color(0xFFB8C5D9)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: SiteVisitDetailsScreen._orange,
                    minimumSize: Size.fromHeight(42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.event_outlined,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Schedule Visit',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF98A2B3),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF344054),
          ),
        ),
        SizedBox(height: 10.h),
        _SheetInput(value: value, muted: muted, trailingIcon: trailingIcon),
      ],
    );
  }
}

class _SheetInput extends StatelessWidget {
  const _SheetInput({
    required this.value,
    this.trailingIcon,
    this.muted = false,
  });

  final String value;
  final IconData? trailingIcon;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SiteVisitDetailsScreen._cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: muted
                    ? const Color(0xFF667085)
                    : const Color(0xFF111827),
              ),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 18.sp, color: const Color(0xFF667085)),
        ],
      ),
    );
  }
}

class _VisitOption {
  const _VisitOption({
    required this.id,
    required this.label,
    this.subtitle = '',
  });

  final String id;
  final String label;
  final String subtitle;
}

class _VisitDropdown extends StatelessWidget {
  const _VisitDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = true,
  });

  final String label;
  final String hint;
  final _VisitOption? value;
  final List<_VisitOption> items;
  final ValueChanged<_VisitOption?>? onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_VisitOption>(
      initialValue: value,
      isExpanded: true,
      decoration: _visitInputDecoration(label),
      hint: Text(hint, overflow: TextOverflow.ellipsis),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.subtitle.isEmpty
                    ? item.label
                    : '${item.label} • ${item.subtitle}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: required && onChanged != null
          ? (selected) => selected == null ? 'Required' : null
          : null,
    );
  }
}

class _VisitPicker extends StatelessWidget {
  const _VisitPicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _visitInputDecoration(label),
        child: Row(
          children: [
            Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
            Icon(icon, size: 18.sp, color: const Color(0xFF667085)),
          ],
        ),
      ),
    );
  }
}

class _VisitIntDropdown extends StatelessWidget {
  const _VisitIntDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: _visitInputDecoration(label),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text('$item${suffix.isEmpty ? '' : ' $suffix'}'),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

InputDecoration _visitInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFDCE6F3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: Color(0xFFDCE6F3)),
    ),
  );
}

List<_VisitOption> _visitOptions(Object? source, {bool leadOptions = false}) {
  final options = <_VisitOption>[];
  final ids = <String>{};
  for (final item in _extractVisitList(source)) {
    if (item is String && item.trim().isNotEmpty) {
      final value = item.trim();
      if (ids.add(value)) {
        options.add(_VisitOption(id: value, label: _prettyOption(value)));
      }
      continue;
    }
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final id = _visitText(map, const [
      'id',
      '_id',
      'employeeId',
      'userId',
      'leadId',
      'projectId',
      'value',
    ]);
    var label = _visitText(map, const [
      'name',
      'fullName',
      'displayName',
      'projectName',
      'unitName',
      'unitNumber',
      'unitNo',
      'number',
      'displayId',
      'title',
      'label',
    ]);
    if (label.isEmpty) {
      label = [
        _visitText(map, const ['firstName']),
        _visitText(map, const ['lastName']),
      ].where((part) => part.isNotEmpty).join(' ');
    }
    if (id.isEmpty || label.isEmpty || !ids.add(id)) continue;
    final subtitle = leadOptions
        ? _visitText(map, const ['displayId', 'phone', 'mobile', 'email'])
        : _visitText(map, const [
            'roleName',
            'designation',
            'location',
            'city',
          ]);
    options.add(_VisitOption(id: id, label: label, subtitle: subtitle));
  }
  options.sort((a, b) => a.label.compareTo(b.label));
  return options;
}

String _prettyOption(String value) {
  final words = value
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .trim()
      .split(RegExp(r'\s+'));
  return words
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

List<_VisitOption> _namedOptionGroup(Object? source, List<String> keys) {
  if (source is Map) {
    for (final key in keys) {
      final value = source[key];
      final parsed = _visitOptions(value);
      if (parsed.isNotEmpty) return parsed;
    }
    for (final value in source.values) {
      final parsed = _namedOptionGroup(value, keys);
      if (parsed.isNotEmpty) return parsed;
    }
  }
  return const [];
}

List<dynamic> _extractVisitList(Object? source) {
  if (source is List) return source;
  if (source is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'rows',
      'records',
      'docs',
      'leads',
      'projects',
      'units',
      'unitOptions',
      'inventory',
      'employees',
      'fieldExecutives',
      'options',
      'values',
    ]) {
      final nested = _extractVisitList(source[key]);
      if (nested.isNotEmpty) return nested;
    }
  }
  return const [];
}

String _visitText(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return '';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return '--';
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}
