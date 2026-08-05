import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/project_model.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return context.read<ProjectProvider>().loadProjects();
  }

  Future<void> _openUrl(String? url) async {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareProject(ProjectModel project) async {
    final buffer = StringBuffer(project.name);
    if (project.location.isNotEmpty) {
      buffer.writeln();
      buffer.write(project.location);
    }
    if (project.priceRange.isNotEmpty) {
      buffer.writeln();
      buffer.write(project.priceRange);
    }
    if (project.hasBrochure) {
      buffer.writeln();
      buffer.write(project.brochureUrl);
    }
    await Share.share(buffer.toString(), subject: project.name);
  }

  Future<void> _shareBrochure(ProjectModel project) async {
    if (!project.hasBrochure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brochure not uploaded for this project.')),
      );
      return;
    }
    await Share.share(
      '${project.name} brochure\n${project.brochureUrl}',
      subject: '${project.name} Brochure',
    );
  }

  void _showProjectDetails(ProjectModel project) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectDetailsSheet(
        project: project,
        onOpenBrochure: () => _openUrl(project.brochureUrl),
        onShare: () => _shareProject(project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final summary = provider.summary;
    final visible = provider.visibleProjects;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        leading: widget.onMenuTap == null
            ? null
            : IconButton(
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
        title: Text(
          'Projects',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navy),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project-owned inventory, lead demand, and visit activity in one operational view.',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Add Project is available from the admin web console.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Project'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeDeep,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _SummaryGrid(summary: summary),
                    SizedBox(height: 14.h),
                    _FilterTabs(provider: provider),
                    SizedBox(height: 12.h),
                    _SearchField(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
            if (provider.isLoading && !provider.hasLoaded)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: const SliverToBoxAdapter(
                  child: AppListSkeleton(itemCount: 3, itemHeight: 280),
                ),
              )
            else if (provider.error != null && provider.projects.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.error!,
                  onRetry: _refresh,
                ),
              )
            else if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  message: provider.projects.isEmpty
                      ? 'No projects found.'
                      : 'No projects match this filter.',
                  onRetry: provider.projects.isEmpty ? _refresh : null,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final project = visible[index];
                    return _ProjectCard(
                      project: project,
                      onTap: () => _showProjectDetails(project),
                      onShare: () => _shareProject(project),
                      onShareBrochure: () => _shareBrochure(project),
                      onOpenBrochure: () => _openUrl(project.brochureUrl),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final ProjectSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricData(
        title: 'Total Projects',
        value: '${summary.totalProjects}',
        subtitle: 'Projects in your CRM',
        icon: Icons.apartment_rounded,
        iconColor: AppColors.blueBright,
        iconBg: const Color(0xFFEAF2FF),
      ),
      _MetricData(
        title: 'Total Units',
        value: '${summary.totalUnits}',
        subtitle: 'Across all projects',
        icon: Icons.home_work_outlined,
        iconColor: AppColors.orangeDeep,
        iconBg: const Color(0xFFFFF1E8),
      ),
      _MetricData(
        title: 'Available Units',
        value: '${summary.availableUnits}',
        subtitle: 'Open for booking',
        icon: Icons.event_available_outlined,
        iconColor: const Color(0xFF168553),
        iconBg: const Color(0xFFE8F8EF),
      ),
      _MetricData(
        title: 'Linked Leads',
        value: '${summary.linkedLeads}',
        subtitle: 'Active demand',
        icon: Icons.people_alt_outlined,
        iconColor: const Color(0xFF7C3AED),
        iconBg: const Color(0xFFF3E8FF),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: crossAxisCount == 4 ? 1.35 : 1.45,
          ),
          itemBuilder: (context, index) => _MetricCard(data: cards[index]),
        );
      },
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9E3EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 18.sp),
          ),
          const Spacer(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.5.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.provider});

  final ProjectProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ProjectFilter.values.map((filter) {
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
                        ? AppColors.blueBright
                        : const Color(0xFFD9E3EF),
                  ),
                ),
                child: Text(
                  '${filter.label} ($count)',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? AppColors.blueBright
                        : AppColors.textSecondary,
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 13.5.sp, color: AppColors.navy),
      decoration: InputDecoration(
        hintText: 'Search projects by name, location, developer...',
        hintStyle: GoogleFonts.inter(
          fontSize: 13.sp,
          color: AppColors.inputHint,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.iconMuted,
          size: 20.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFD9E3EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFD9E3EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.blueBright),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onShare,
    required this.onShareBrochure,
    required this.onOpenBrochure,
  });

  final ProjectModel project;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onShareBrochure;
  final VoidCallback onOpenBrochure;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(project.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFD9E3EF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: project.imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFEAF2FF),
                        child: Icon(
                          Icons.apartment_rounded,
                          size: 42.sp,
                          color: AppColors.blueBright,
                        ),
                      )
                    : Image.network(
                        project.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFFEAF2FF),
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 42.sp,
                            color: AppColors.blueBright,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      project.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onShare,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.ios_share_rounded,
                            size: 18.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColors.$2,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            project.status,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: statusColors.$1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Inventory',
                            value: '${project.totalUnits} units',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _StatBox(
                            label: 'Available',
                            value: '${project.availableUnits} units',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            label: 'Active Leads',
                            value: '${project.activeLeads}',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _StatBox(
                            label: 'Visits',
                            value: '${project.visits}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE6ECF4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 18.sp,
                            color: AppColors.orangeDeep,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Brochure PDF',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  project.hasBrochure
                                      ? (project.brochureFileName ??
                                          'Brochure.pdf')
                                      : 'Not uploaded',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: project.hasBrochure
                                ? onShareBrochure
                                : null,
                            icon: Icon(Icons.share_outlined, size: 14.sp),
                            label: const Text('Share PDF'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blueBright,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              visualDensity: VisualDensity.compact,
                              textStyle: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price Range',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                project.priceRange,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.orangeDeep,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            textStyle: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('View Details →'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _statusColors(String status) {
    final value = status.toLowerCase();
    if (value.contains('ready')) {
      return (const Color(0xFF168553), const Color(0xFFE8F8EF));
    }
    if (value.contains('under') || value.contains('construction')) {
      return (const Color(0xFFD97706), const Color(0xFFFFF7E8));
    }
    if (value.contains('demand')) {
      return (const Color(0xFFDC2626), const Color(0xFFFFE8E8));
    }
    return (AppColors.blueBright, const Color(0xFFEAF2FF));
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE6ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDetailsSheet extends StatelessWidget {
  const _ProjectDetailsSheet({
    required this.project,
    required this.onOpenBrochure,
    required this.onShare,
  });

  final ProjectModel project;
  final VoidCallback onOpenBrochure;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            children: [
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E3EF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              if (project.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(project.imageUrl, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 14.h),
              Text(
                project.name,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                project.location,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (project.developer.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  'Developer: ${project.developer}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              SizedBox(height: 14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _chip(project.status),
                  _chip(project.priceRange),
                  ...project.configurations.map(_chip),
                ],
              ),
              SizedBox(height: 16.h),
              _detailRow('Inventory', '${project.totalUnits} units'),
              _detailRow('Available', '${project.availableUnits} units'),
              _detailRow('Active Leads', '${project.activeLeads}'),
              _detailRow('Visits', '${project.visits}'),
              _detailRow(
                'Brochure',
                project.hasBrochure
                    ? (project.brochureFileName ?? 'Available')
                    : 'Not uploaded',
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Share'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: project.hasBrochure ? onOpenBrochure : null,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Open PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeDeep,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFFFD8C2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 12.h),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
