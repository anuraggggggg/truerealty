import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/models/project_model.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, this.onMenuTap, this.initialProjectId});

  final VoidCallback? onMenuTap;
  final String? initialProjectId;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<ProjectProvider>();
      await provider.loadProjects();
      if (!mounted) return;
      final projectId = widget.initialProjectId?.trim() ?? '';
      if (projectId.isEmpty) return;
      for (final project in provider.projects) {
        if (project.id == projectId) {
          _showProjectDetails(project);
          break;
        }
      }
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
        const SnackBar(
          content: Text('Brochure not uploaded for this project.'),
        ),
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

  Future<void> _showCreateProject() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateProjectSheet(),
    );
    if (created == true && mounted) {
      await _refresh();
    }
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
                        onPressed: _showCreateProject,
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

class _CreateProjectSheet extends StatefulWidget {
  const _CreateProjectSheet();

  @override
  State<_CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<_CreateProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _developerController = TextEditingController();
  final _possessionController = TextEditingController();
  final _reraController = TextEditingController();
  final _configurationsController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _highlightsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _salesOwnerController = TextEditingController();
  final _radiusController = TextEditingController(text: '150');
  static const _defaultMapCenter = LatLng(19.0760, 72.8777);
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  bool _locating = false;
  String _priceMinUnit = 'Cr';
  String _priceMaxUnit = 'Cr';
  String _status = 'Active';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _developerController.dispose();
    _possessionController.dispose();
    _reraController.dispose();
    _configurationsController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _amenitiesController.dispose();
    _highlightsController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _salesOwnerController.dispose();
    _mapController?.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  List<String> _listValue(TextEditingController controller) => controller.text
      .split(RegExp(r'[,\n]'))
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  num? _priceValue(TextEditingController controller, String unit) {
    final value = double.tryParse(controller.text.trim());
    if (value == null) return null;
    return value * (unit == 'Cr' ? 10000000 : 100000);
  }

  bool _alreadyExists() {
    String normalize(String value) =>
        value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final name = normalize(_nameController.text);
    final location = normalize(_locationController.text);
    return context.read<ProjectProvider>().projects.any(
      (project) =>
          normalize(project.name) == name &&
          normalize(project.location) == location,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    final minimumPrice = _priceValue(_priceMinController, _priceMinUnit);
    final maximumPrice = _priceValue(_priceMaxController, _priceMaxUnit);
    if (minimumPrice == null ||
        maximumPrice == null ||
        maximumPrice < minimumPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum price must be greater than minimum price.'),
        ),
      );
      return;
    }
    if (_alreadyExists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A project with this name and location already exists.',
          ),
        ),
      );
      return;
    }
    setState(() => _submitting = true);

    final body = <String, dynamic>{
      'name': _nameController.text.trim(),
      'location': _locationController.text.trim(),
      'developer': _developerController.text.trim(),
      'status': _status,
      'possession': _possessionController.text.trim(),
      'priceMin': _priceMinController.text.trim(),
      'priceMinUnit': _priceMinUnit,
      'priceMax': _priceMaxController.text.trim(),
      'priceMaxUnit': _priceMaxUnit,
      'configurations': _listValue(_configurationsController),
      'amenities': _listValue(_amenitiesController),
      'highlights': _listValue(_highlightsController),
      'description': _descriptionController.text.trim(),
      'reraNumber': _reraController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'imageGallery': <String>[],
      'brochures': <dynamic>[],
      'geofenceRadiusM': _radiusController.text.trim(),
    };
    if (_salesOwnerController.text.trim().isNotEmpty) {
      body['salesOwnerId'] = _salesOwnerController.text.trim();
    }
    if (_selectedPosition != null) {
      body['latitude'] = _selectedPosition!.latitude;
      body['longitude'] = _selectedPosition!.longitude;
    }

    final projectProvider = context.read<ProjectProvider>();
    final response = await projectProvider.createProject(body);

    if (!mounted) return;
    setState(() => _submitting = false);
    if (response?.isSuccess == true) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response?.message ??
              projectProvider.error ??
              'Unable to add project.',
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Please enable location services.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is required to use your position.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selectedPosition = point);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 17),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.96,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add Project',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _nameController,
                    label: 'Project name',
                    hint: 'Enter project name',
                    required: true,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'Enter project location',
                    required: true,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _developerController,
                    label: 'Developer',
                    hint: 'Enter developer name',
                    required: true,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _possessionController,
                    label: 'Possession',
                    hint: 'Ready by Aug 2026',
                    required: true,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _reraController,
                    label: 'RERA number',
                    hint: 'Enter RERA number',
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _configurationsController,
                    label: 'Configurations',
                    hint: '2 BHK, 3 BHK',
                    required: true,
                  ),
                  SizedBox(height: 14.h),
                  _priceField(
                    controller: _priceMinController,
                    label: 'Minimum price',
                    hint: '2.5',
                    unit: _priceMinUnit,
                    onUnitChanged: (value) =>
                        setState(() => _priceMinUnit = value!),
                  ),
                  SizedBox(height: 14.h),
                  _priceField(
                    controller: _priceMaxController,
                    label: 'Maximum price',
                    hint: '3.5',
                    unit: _priceMaxUnit,
                    onUnitChanged: (value) =>
                        setState(() => _priceMaxUnit = value!),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: _inputDecoration('Status', null),
                    items: const ['Active', 'Upcoming', 'Completed', 'Inactive']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _amenitiesController,
                    label: 'Amenities',
                    hint: 'Pool, Gym, Clubhouse',
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _highlightsController,
                    label: 'Project highlights',
                    hint: 'Separate highlights with commas or new lines',
                    maxLines: 3,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Short project positioning note',
                    maxLines: 4,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _imageUrlController,
                    label: 'Project image URL',
                    hint: 'https://...',
                    keyboardType: TextInputType.url,
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _salesOwnerController,
                    label: 'Sales owner ID',
                    hint: 'Optional employee ID',
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Visit geofence (optional)',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 260.h.clamp(220.0, 300.0),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _defaultMapCenter,
                        zoom: 12,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      onTap: (point) =>
                          setState(() => _selectedPosition = point),
                      markers: _selectedPosition == null
                          ? const <Marker>{}
                          : {
                              Marker(
                                markerId: const MarkerId('project_location'),
                                position: _selectedPosition!,
                              ),
                            },
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _locating ? null : _useCurrentLocation,
                      icon: _locating
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: Text(
                        _selectedPosition == null
                            ? 'Use current location or tap the map'
                            : 'Location pinned',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _projectField(
                    controller: _radiusController,
                    label: 'Geofence radius (m)',
                    hint: '150',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeDeep,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: _submitting
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Add Project',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _projectField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, hint),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? '$label is required'
                : null
          : null,
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  Widget _unitDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 88,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: _inputDecoration('Unit', null),
        items: const ['Cr', 'L']
            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String unit,
    required ValueChanged<String?> onUnitChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final valueField = _projectField(
          controller: controller,
          label: label,
          hint: hint,
          required: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        );
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              valueField,
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: _unitDropdown(value: unit, onChanged: onUnitChanged),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: valueField),
            SizedBox(width: 8.w),
            _unitDropdown(value: unit, onChanged: onUnitChanged),
          ],
        );
      },
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
  const _SearchField({required this.controller, required this.onChanged});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
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
