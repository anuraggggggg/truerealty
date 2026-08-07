import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:truerealtycrm/provider/upload_provider.dart';
import 'package:truerealtycrm/screen/telecaller_dashboard_screen.dart';
import 'package:truerealtycrm/widget/app_loading.dart';
import 'package:url_launcher/url_launcher.dart';

class FieldExecutiveDashboardView extends StatefulWidget {
  const FieldExecutiveDashboardView({
    super.key,
    this.onMenuTap,
    this.bottomSpacing = 24,
  });

  final VoidCallback? onMenuTap;
  final double bottomSpacing;

  @override
  State<FieldExecutiveDashboardView> createState() =>
      _FieldExecutiveDashboardViewState();
}

class _FieldExecutiveDashboardViewState
    extends State<FieldExecutiveDashboardView> {
  _FieldDashboardData _data = const _FieldDashboardData();
  bool _loading = true;
  bool _loaded = false;
  bool _attendanceActionLoading = false;
  _FieldAttendanceData _attendance = const _FieldAttendanceData();
  _PerformanceRankingData _rankings = const _PerformanceRankingData();
  bool _rankingLoading = true;
  String? _rankingError;
  String _rankingRange = 'monthly';
  String _rankingMode = 'users';
  List<LatLng> _todayVisitRoutePoints = const [];
  List<String> _todayVisitRouteLabels = const [];
  List<LatLng> _activeVisitRoutePoints = const [];
  List<String> _activeVisitRouteLabels = const [];
  List<LatLng> _activeVisitPolylinePoints = const [];
  List<_TodaySiteVisitItem> _todaySiteVisitItems = const [];
  final Map<String, _VisitActionState> _visitActionStates = {};
  final Set<String> _visitActionsLoading = {};
  final GlobalKey _routeMapKey = GlobalKey();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _rankingLoading = true;
      _error = null;
    });
    final employeeProvider = context.read<EmployeeProvider>();
    if (employeeProvider.currentEmployee == null &&
        !employeeProvider.isLoading) {
      unawaited(employeeProvider.fetchCurrentEmployee());
    }
    final provider = context.read<DashboardProvider>();
    final response = await provider.fetchFieldExecutiveDashboard();
    if (!mounted) return;
    if (response == null) {
      setState(() {
        _loading = false;
        _loaded = true;
        _error =
            provider.error ?? 'Unable to load the field executive dashboard.';
      });
      unawaited(_loadTodayAttendance());
      unawaited(_loadRankings());
      unawaited(_loadTodayVisitRoute());
      return;
    }
    final sessionUser = context.read<AuthProvider>().session?.user;
    setState(() {
      _data = _FieldDashboardData.fromApi(response.data, sessionUser);
      _loading = false;
      _loaded = true;
    });
    unawaited(_loadTodayAttendance());
    unawaited(_loadRankings());
    unawaited(_loadTodayVisitRoute());
  }

  Future<void> _loadTodayVisitRoute() async {
    if (mounted) {
      setState(() {
        _todayVisitRoutePoints = const [];
        _todayVisitRouteLabels = const [];
        _todaySiteVisitItems = const [];
      });
    }
    final sessionUser = context.read<AuthProvider>().session?.user;
    final executiveId = _dashboardFirstText([
      sessionUser?['employeeId'],
      sessionUser?['id'],
      sessionUser?['userId'],
    ]);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    final response = await context.read<SiteVisitProvider>().fetchSiteVisits(
      dateFrom: start.toUtc().toIso8601String(),
      dateTo: end.toUtc().toIso8601String(),
      fieldExecutiveId: executiveId.isEmpty ? null : executiveId,
    );
    if (!mounted || response == null) return;

    final visits = context.read<SiteVisitProvider>().siteVisits.toList()
      ..sort((a, b) {
        final aTime = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });
    final projectProvider = context.read<ProjectProvider>();
    final visitItems = <_TodaySiteVisitItem>[];
    final projectCoordinateCache = <String, LatLng?>{};

    for (final visit in visits) {
      final scheduledAt = visit.scheduledAt;
      if (scheduledAt != null && !_isSameDashboardDay(scheduledAt, now)) {
        continue;
      }
      final raw = visit.raw;
      LatLng? point = _dashboardVisitPoint(raw['project'] ?? raw['property']);
      final projectId = _dashboardFirstText([
        raw['projectId'],
        raw['propertyId'],
        _dashboardMap(raw['project'])['id'],
        _dashboardMap(raw['project'])['_id'],
        _dashboardMap(raw['property'])['id'],
        _dashboardMap(raw['property'])['_id'],
      ]);
      if (point == null && projectId.isNotEmpty) {
        if (!projectCoordinateCache.containsKey(projectId)) {
          final projectResponse = await projectProvider.fetchProject(projectId);
          projectCoordinateCache[projectId] = _dashboardVisitPoint(
            projectResponse?.data,
          );
        }
        point = projectCoordinateCache[projectId];
      }
      visitItems.add(_TodaySiteVisitItem.fromVisit(visit, point));
    }
    if (!mounted) return;
    final mappedItems = visitItems
        .where((item) => item.coordinate != null)
        .toList();
    setState(() {
      _todaySiteVisitItems = visitItems;
      for (final item in visitItems) {
        final serverState = item.initialActionState;
        final localState = _visitActionStates[item.id];
        if (localState == null ||
            serverState == _VisitActionState.checkedIn ||
            serverState == _VisitActionState.checkedOut) {
          _visitActionStates[item.id] = serverState;
        }
      }
      _todayVisitRoutePoints = mappedItems
          .map((item) => item.coordinate!)
          .toList();
      _todayVisitRouteLabels = mappedItems
          .map((item) => item.mapLabel)
          .toList();
    });
  }

  Future<void> _showVisitOnMap(_TodaySiteVisitItem item) async {
    if (item.coordinate == null) {
      _showAttendanceMessage(
        'Project coordinates are not available for this visit.',
      );
      return;
    }
    final mapContext = _routeMapKey.currentContext;
    if (mapContext != null) {
      await Scrollable.ensureVisible(
        mapContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }
  }

  Future<void> _startVisit(_TodaySiteVisitItem item) async {
    final destination = item.coordinate;
    if (destination == null) {
      _showAttendanceMessage(
        'Project coordinates are not available for this visit.',
      );
      return;
    }
    if (_visitActionsLoading.contains(item.id)) return;
    setState(() => _visitActionsLoading.add(item.id));
    final current = await _currentVisitPosition();
    if (!mounted) return;
    final currentPoint = current == null
        ? null
        : LatLng(current.latitude, current.longitude);
    final routedPoints = currentPoint == null
        ? const <LatLng>[]
        : await _fetchDrivingRoute(currentPoint, destination);
    if (!mounted) return;
    setState(() {
      _visitActionsLoading.remove(item.id);
      if (current != null) {
        _visitActionStates[item.id] = _VisitActionState.started;
        _activeVisitRoutePoints = [
          LatLng(current.latitude, current.longitude),
          destination,
        ];
        _activeVisitRouteLabels = ['Your location', item.mapLabel];
        _activeVisitPolylinePoints = routedPoints;
      }
    });
    if (current == null) return;
    if (routedPoints.isEmpty) {
      _showAttendanceMessage(
        'Unable to calculate a driving route. Please try again.',
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_showVisitOnMap(item));
    });
  }

  Future<void> _checkInVisit(_TodaySiteVisitItem item) async {
    if (_visitActionsLoading.contains(item.id)) return;
    setState(() => _visitActionsLoading.add(item.id));
    final position = await _currentVisitPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _visitActionsLoading.remove(item.id));
      return;
    }
    final provider = context.read<SiteVisitProvider>();
    final response = await provider.checkIn(
      siteVisitId: item.id,
      body: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      },
    );
    if (!mounted) return;
    setState(() {
      _visitActionsLoading.remove(item.id);
      if (response != null) {
        _visitActionStates[item.id] = _VisitActionState.checkedIn;
      }
    });
    _showVisitResult(
      response != null,
      response != null
          ? 'Site visit checked in.'
          : provider.error ?? 'Unable to check in.',
    );
  }

  Future<void> _checkOutVisit(_TodaySiteVisitItem item) async {
    if (_visitActionsLoading.contains(item.id)) return;
    setState(() => _visitActionsLoading.add(item.id));
    final position = await _currentVisitPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _visitActionsLoading.remove(item.id));
      return;
    }
    final provider = context.read<SiteVisitProvider>();
    final response = await provider.checkOut(
      siteVisitId: item.id,
      body: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      },
    );
    if (!mounted) return;
    setState(() {
      _visitActionsLoading.remove(item.id);
      if (response != null) {
        _visitActionStates[item.id] = _VisitActionState.checkedOut;
        _activeVisitRoutePoints = const [];
        _activeVisitRouteLabels = const [];
        _activeVisitPolylinePoints = const [];
      }
    });
    _showVisitResult(
      response != null,
      response != null
          ? 'Site visit checked out.'
          : provider.error ?? 'Unable to check out.',
    );
  }

  Future<void> _requestCheckOutVisit(_TodaySiteVisitItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete site visit?'),
        content: Text(
          'Check out ${item.leadName} from ${item.project}. '
          'Your current location will be recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Check Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _checkOutVisit(item);
    }
  }

  Future<void> _undoVisitStart(_TodaySiteVisitItem item) async {
    if (_visitActionsLoading.contains(item.id)) return;
    final state = _visitActionStates[item.id] ?? _VisitActionState.notStarted;
    if (state == _VisitActionState.started) {
      setState(() {
        _visitActionStates[item.id] = _VisitActionState.notStarted;
        _activeVisitRoutePoints = const [];
        _activeVisitRouteLabels = const [];
        _activeVisitPolylinePoints = const [];
      });
      _showAttendanceMessage('Visit returned to Start Visit.');
      return;
    }
    setState(() => _visitActionsLoading.add(item.id));
    final provider = context.read<SiteVisitProvider>();
    final response = await provider.updateSiteVisitFromApi(
      siteVisitId: item.id,
      body: {'status': 'Scheduled', 'checkedInAt': null, 'checkedOutAt': null},
    );
    if (!mounted) return;
    setState(() {
      _visitActionsLoading.remove(item.id);
      if (response != null) {
        _visitActionStates[item.id] = _VisitActionState.notStarted;
      }
    });
    _showVisitResult(
      response != null,
      response != null
          ? 'Visit returned to Start Visit.'
          : provider.error ?? 'Unable to undo visit start.',
    );
  }

  void _showVisitResult(bool success, String message) {
    _showAttendanceMessage(message);
    if (success) {
      unawaited(_loadTodayVisitRoute());
      unawaited(_load());
    }
  }

  Future<Position?> _currentVisitPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showAttendanceMessage(
        'Turn on location services to check in at the project.',
      );
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _showAttendanceMessage('Location permission is required to check in.');
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      _showAttendanceMessage(
        'Location permission is permanently denied. Enable it in app settings.',
      );
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      _showAttendanceMessage(
        'Unable to read your current location. Please try again.',
      );
      return null;
    }
  }

  Future<List<LatLng>> _fetchDrivingRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final coordinates =
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$coordinates',
      const {'overview': 'full', 'geometries': 'geojson', 'steps': 'false'},
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['routes'] is! List) return const [];
      final routes = decoded['routes'] as List;
      if (routes.isEmpty || routes.first is! Map) return const [];
      final geometry = (routes.first as Map)['geometry'];
      if (geometry is! Map || geometry['coordinates'] is! List) {
        return const [];
      }
      return (geometry['coordinates'] as List)
          .whereType<List>()
          .where((point) => point.length >= 2)
          .map(
            (point) => LatLng(
              (point[1] as num).toDouble(),
              (point[0] as num).toDouble(),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _loadTodayAttendance() async {
    final response = await context
        .read<AttendanceProvider>()
        .fetchTodayAttendance();
    if (!mounted || response == null) return;
    setState(() {
      _attendance = _FieldAttendanceData.fromApi(response.data);
    });
  }

  Future<void> _loadRankings({String? range, String? mode}) async {
    final nextRange = range ?? _rankingRange;
    final nextMode = mode ?? _rankingMode;
    setState(() {
      _rankingRange = nextRange;
      _rankingMode = nextMode;
      _rankingLoading = true;
      _rankingError = null;
    });
    final response = await context.read<DashboardProvider>().fetchRankings(
      range: nextRange,
      mode: nextMode,
      teamId: 'all',
      userId: 'all',
    );
    if (!mounted) return;
    setState(() {
      _rankingLoading = false;
      if (response == null) {
        _rankingError = 'Unable to load performance rankings.';
      } else {
        _rankings = _PerformanceRankingData.fromApi(response.data);
      }
    });
  }

  Future<void> _punchIn() async {
    if (_attendanceActionLoading || !_attendance.canPunchIn) return;

    final imagePath = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PunchInSelfieDialog(),
    );
    if (imagePath == null || !mounted) return;

    setState(() => _attendanceActionLoading = true);
    final uploadProvider = context.read<UploadProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();
    final uploadResponse = await uploadProvider.uploadImage(imagePath);
    final imageUrl = _fieldUploadedImageUrl(uploadResponse?.data);
    if (imageUrl == null) {
      if (!mounted) return;
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(
        uploadProvider.error ?? 'Unable to upload the punch-in selfie.',
      );
      return;
    }

    final response = await attendanceProvider.punchIn(
      checkInImageUrl: imageUrl,
    );
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(attendanceProvider.error ?? 'Unable to punch in.');
      return;
    }
    final punchedInData = _FieldAttendanceData.fromApi(response.data);
    if (punchedInData.hasPunchedIn) {
      setState(() => _attendance = punchedInData);
    }
    await _refreshAttendance(successMessage: 'Punch in completed.');
  }

  Future<void> _punchOut() async {
    if (_attendanceActionLoading || !_attendance.canPunchOut) return;
    setState(() => _attendanceActionLoading = true);
    final provider = context.read<AttendanceProvider>();
    final response = await provider.punchOut();
    if (!mounted) return;
    if (response == null) {
      setState(() => _attendanceActionLoading = false);
      _showAttendanceMessage(provider.error ?? 'Unable to punch out.');
      return;
    }
    await _refreshAttendance(successMessage: 'Punch out completed.');
  }

  Future<void> _refreshAttendance({String? successMessage}) async {
    final provider = context.read<AttendanceProvider>();
    final response = await provider.fetchTodayAttendance();
    if (!mounted) return;
    setState(() {
      _attendanceActionLoading = false;
      if (response != null) {
        _attendance = _FieldAttendanceData.fromApi(response.data);
      }
    });
    if (response == null) {
      _showAttendanceMessage(
        provider.error ?? 'Unable to refresh attendance status.',
      );
    } else if (successMessage != null) {
      _showAttendanceMessage(successMessage);
    }
  }

  void _showAttendanceMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = _data.employeeName.isEmpty
        ? 'Field Executive'
        : _data.employeeName;
    return RefreshIndicator(
      color: AppColors.orangeDeep,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading) const LinearProgressIndicator(),
            Stack(
              children: [
                SizedBox(
                  height: 300.h,
                  width: double.infinity,
                  child: _FieldDashboardHeader(
                    employeeName: employeeName,
                    onMenuTap: widget.onMenuTap,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 180.h, left: 16.w, right: 16.w),
                  child: Column(
                    children: [
                      _FieldAttendanceCard(
                        data: _attendance,
                        isLoading: _attendanceActionLoading,
                        onPunchIn: _punchIn,
                        onPunchOut: _punchOut,
                      ),
                      SizedBox(height: 14.h),
                      _FieldMetricsPanel(data: _data),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                14.h,
                16.w,
                widget.bottomSpacing.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    _ExecutiveErrorCard(message: _error!, onRetry: _load),
                    SizedBox(height: 14.h),
                  ],
                  if (!_loaded && _loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: AppListSkeleton(itemCount: 3, itemHeight: 116),
                    )
                  else ...[
                    _PerformanceRankingCard(
                      data: _rankings,
                      selectedRange: _rankingRange,
                      selectedMode: _rankingMode,
                      loading: _rankingLoading,
                      error: _rankingError,
                      onRangeChanged: (value) => _loadRankings(range: value),
                      onModeChanged: (value) => _loadRankings(mode: value),
                      onRetry: _loadRankings,
                    ),
                    SizedBox(height: 14.h),
                    _MyDayCard(
                      data: _data,
                      onViewSchedule: () =>
                          context.read<DashboardProvider>().selectTab(3),
                    ),
                    SizedBox(height: 12.h),
                    _UpcomingSiteVisitsCard(
                      visits: _todaySiteVisitItems,
                      onViewSchedule: () =>
                          context.read<DashboardProvider>().selectTab(3),
                      onDirections: _showVisitOnMap,
                      actionStateFor: (item) =>
                          _visitActionStates[item.id] ??
                          item.initialActionState,
                      isActionLoading: (item) =>
                          _visitActionsLoading.contains(item.id),
                      onStartVisit: _startVisit,
                      onCheckIn: _checkInVisit,
                      onCheckOut: _requestCheckOutVisit,
                      onUndoStart: _undoVisitStart,
                    ),
                    SizedBox(height: 12.h),
                    _ExecutiveRouteMapCard(
                      key: _routeMapKey,
                      stops: _activeVisitRouteLabels.isNotEmpty
                          ? _activeVisitRouteLabels
                          : _todayVisitRouteLabels,
                      points: _activeVisitRoutePoints.isNotEmpty
                          ? _activeVisitRoutePoints
                          : _todayVisitRoutePoints,
                      polylinePoints: _activeVisitPolylinePoints,
                      executiveName: _dashboardFirstText([
                        context
                            .watch<EmployeeProvider>()
                            .currentEmployee?['fullName'],
                        context
                            .watch<EmployeeProvider>()
                            .currentEmployee?['name'],
                        _data.employeeName,
                      ]),
                      executiveImageUrl: _employeeProfileImageUrl([
                        context.watch<EmployeeProvider>().currentEmployee,
                        context.watch<AuthProvider>().session?.user,
                        context.watch<AuthProvider>().session?.raw,
                      ]),
                    ),
                    SizedBox(height: 12.h),
                    _DynamicSiteVisitFunnelCard(data: _data),
                    SizedBox(height: 12.h),

                    _CheckInStatusCard(items: _data.checkInStatus),
                    SizedBox(height: 12.h),
                    _ExecutiveAlertCard(items: _data.alerts),
                    SizedBox(height: 12.h),
                    _ExecutiveRecentActivityCard(items: _data.activities),
                    SizedBox(height: 12.h),
                    _TodayStopsCard(items: _data.todayStops),
                    SizedBox(height: 14.h),
                    TelecallerDashboardFeatureSections(
                      totalLeads: _data.assignedLeads,
                      newLeads: _data.visitsPendingStart,
                      todayFollowUps: _data.myDayFollowUpsToday,
                      missedFollowUps: _data.missedVisits,
                      interestedLeads: _data.upcomingVisits,
                      notInterestedLeads: _data.missedVisits,
                      siteVisitScheduledLeads: _data.todaySiteVisits,
                      siteVisitDoneLeads: _data.completedVisits,
                      bookingsDone: _data.bookingsAssisted,
                      todayCallFollowUps: _data.pendingFollowUps,
                      dueNextHour: _data.upcomingVisits,
                      missedSla: _data.missedCheckIns,
                      needsImmediateResponse: _data.pendingCheckIns,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldDashboardHeader extends StatelessWidget {
  const _FieldDashboardHeader({
    required this.employeeName,
    required this.onMenuTap,
  });

  final String employeeName;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26.r),
          bottomRight: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 64.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5EAF2))),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onMenuTap,
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                    width: 38.w,
                    height: 38.h,
                    child: Icon(
                      Icons.menu_rounded,
                      color: AppColors.navy,
                      size: 27.sp,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                SizedBox(
                  width: 112.w,
                  child: Image.asset(
                    'assets/app_icon.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE1E7F0)),
                  ),
                  child: Icon(
                    Icons.engineering_outlined,
                    color: AppColors.navy,
                    size: 21.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Field Executive Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 27.sp,
                    fontWeight: FontWeight.bold,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  "Welcome back, $employeeName. Here's today's overview.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: .9),
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

class _FieldMetricsPanel extends StatelessWidget {
  const _FieldMetricsPanel({required this.data});

  final _FieldDashboardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: _ExecutiveMetrics(data: data),
    );
  }
}

class _FieldAttendanceCard extends StatelessWidget {
  const _FieldAttendanceCard({
    required this.data,
    required this.isLoading,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  final _FieldAttendanceData data;
  final bool isLoading;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTENDANCE',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Today’s punch',
                      style: GoogleFonts.inter(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF123B7A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Color(0xFF123B7A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (data.hasPunchedIn) ...[
            _PunchInCompletedCard(data: data),
            SizedBox(height: 12.h),
          ],
          _AttendanceInfoBox(
            label: 'CURRENT STATUS',
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
              decoration: BoxDecoration(
                border: Border.all(color: data.statusColor),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: data.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      data.status,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _AttendanceInfoBox(
            label: 'SHIFT',
            child: Text(
              data.shiftLabel,
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF123B7A),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _AttendanceInfoBox(
            label: 'PUNCH LOG',
            child: Text(
              'In ${data.checkInLabel}  Out ${data.checkOutLabel}',
              style: GoogleFonts.inter(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF123B7A),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          if (!data.hasPunchedIn) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading || !data.canPunchIn ? null : onPunchIn,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(46.h),
                  elevation: 0,
                  backgroundColor: AppColors.orangeDeep,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ),
                icon: isLoading
                    ? SizedBox(
                        width: 17.w,
                        height: 17.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded),
                label: const Text('Punch In'),
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (data.hasPunchedIn && !data.hasPunchedOut)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading || !data.canPunchOut ? null : onPunchOut,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(46.h),
                  foregroundColor: const Color(0xFF123B7A),
                  side: const BorderSide(color: Color(0xFF123B7A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                ),
                icon: isLoading
                    ? SizedBox(
                        width: 17.w,
                        height: 17.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF123B7A),
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
                label: const Text('Punch Out'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PunchInCompletedCard extends StatelessWidget {
  const _PunchInCompletedCard({required this.data});

  final _FieldAttendanceData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s punch-in is done',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF087A50),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      data.hasPunchedOut
                          ? 'Your attendance for today is complete.'
                          : 'You are checked in and ready for field work.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: const Color(0xFF356859),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _PunchDetail(
                icon: Icons.login_rounded,
                label: 'Punched in',
                value: data.checkInLabel,
              ),
              _PunchDetail(
                icon: Icons.schedule_outlined,
                label: 'Shift',
                value: data.shiftLabel,
              ),
              _PunchDetail(
                icon: data.hasPunchedOut
                    ? Icons.logout_rounded
                    : Icons.verified_user_outlined,
                label: data.hasPunchedOut ? 'Punched out' : 'Status',
                value: data.hasPunchedOut ? data.checkOutLabel : data.status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PunchDetail extends StatelessWidget {
  const _PunchDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 118.w, maxWidth: 220.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17.sp, color: const Color(0xFF087A50)),
          SizedBox(width: 7.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF568071),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF145C43),
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

class _AttendanceInfoBox extends StatelessWidget {
  const _AttendanceInfoBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(11.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
              color: const Color(0xFF29313D),
            ),
          ),
          SizedBox(height: 7.h),
          child,
        ],
      ),
    );
  }
}

class _FieldAttendanceData {
  const _FieldAttendanceData({
    this.status = 'Not Checked In',
    this.shiftLabel = 'No shift assigned',
    this.checkInAt,
    this.checkOutAt,
    this.canPunchIn = false,
    this.canPunchOut = false,
  });

  factory _FieldAttendanceData.fromApi(Object? source) {
    var root = source is Map
        ? Map<String, dynamic>.from(source)
        : <String, dynamic>{};
    if (root['data'] is Map) {
      root = Map<String, dynamic>.from(root['data'] as Map);
    }
    final record = root['record'] is Map
        ? Map<String, dynamic>.from(root['record'] as Map)
        : root['attendance'] is Map
        ? Map<String, dynamic>.from(root['attendance'] as Map)
        : const <String, dynamic>{};
    final shiftSource = root['shift'] ?? record['shift'];
    final shift = shiftSource is Map
        ? Map<String, dynamic>.from(shiftSource)
        : const <String, dynamic>{};
    final checkIn = _fieldAttendanceDate(
      root['checkInAt'] ?? record['checkInAt'],
    );
    final checkOut = _fieldAttendanceDate(
      root['checkOutAt'] ?? record['checkOutAt'],
    );
    final status = _dashboardFirstText([
      root['status'],
      record['status'],
      checkIn == null ? 'Not Checked In' : 'Checked In',
    ]);
    final schedule = _dashboardFirstText([
      shift['scheduleLabel'],
      _fieldShiftSchedule(shift),
    ]);
    final shiftLabel = [
      _dashboardText(shift['name']),
      schedule,
    ].where((value) => value.isNotEmpty).join('  ');
    return _FieldAttendanceData(
      status: status,
      shiftLabel: shiftLabel.isEmpty ? 'No shift assigned' : shiftLabel,
      checkInAt: checkIn,
      checkOutAt: checkOut,
      canPunchIn: root['canPunchIn'] is bool
          ? root['canPunchIn'] as bool
          : checkIn == null,
      canPunchOut: root['canPunchOut'] is bool
          ? root['canPunchOut'] as bool
          : checkIn != null && checkOut == null,
    );
  }

  final String status;
  final String shiftLabel;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool canPunchIn;
  final bool canPunchOut;

  String get checkInLabel => _fieldPunchTime(checkInAt);
  String get checkOutLabel => _fieldPunchTime(checkOutAt);
  bool get hasPunchedIn => checkInAt != null;
  bool get hasPunchedOut => checkOutAt != null;

  Color get statusColor {
    final value = status.toLowerCase();
    if (value.contains('not checked') || value.contains('absent')) {
      return const Color(0xFFFF6B00);
    }
    if (value.contains('late') || value.contains('half')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF10B981);
  }
}

DateTime? _fieldAttendanceDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String _fieldPunchTime(DateTime? value) {
  if (value == null) return '--';
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '${hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')} '
      '${value.hour < 12 ? 'AM' : 'PM'}';
}

String _fieldShiftSchedule(Map<String, dynamic> shift) {
  final start = _fieldMinutesLabel(shift['startTimeMinutes']);
  final end = _fieldMinutesLabel(shift['endTimeMinutes']);
  return start.isEmpty || end.isEmpty ? '' : '($start - $end)';
}

String _fieldMinutesLabel(Object? value) {
  final minutes = value is num ? value.toInt() : int.tryParse('$value');
  if (minutes == null) return '';
  final hour24 = minutes ~/ 60;
  final minute = minutes % 60;
  final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')} '
      '${hour24 < 12 ? 'am' : 'pm'}';
}

String? _fieldUploadedImageUrl(Object? source) {
  if (source is! Map) return null;
  final map = Map<String, dynamic>.from(source);
  for (final key in const ['url', 'fileUrl', 'imageUrl', 'path', 'location']) {
    final value = map[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  for (final key in const ['data', 'file', 'image', 'upload']) {
    final nested = _fieldUploadedImageUrl(map[key]);
    if (nested != null) return nested;
  }
  return null;
}

class _ExecutiveMetricCard extends StatelessWidget {
  const _ExecutiveMetricCard({required this.data});

  final _ExecutiveMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 118.h),
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 12.h),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 24.sp, color: data.iconColor),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 34.h),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                data.title.toUpperCase(),
                maxLines: 2,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: -.15,
                  color: const Color(0xFF2D2C2C),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveMetrics extends StatelessWidget {
  const _ExecutiveMetrics({required this.data});

  final _FieldDashboardData data;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _ExecutiveMetricData(
        title: 'Assigned\nLeads',
        value: '${data.assignedLeads}',
        icon: Icons.groups_2_outlined,
        iconColor: const Color(0xFF0F2F66),
      ),
      _ExecutiveMetricData(
        title: 'Today\'s\nSite Visits',
        value: '${data.todaySiteVisits}',
        icon: Icons.location_on_outlined,
        iconColor: const Color(0xFF06B6D4),
      ),
      _ExecutiveMetricData(
        title: 'Upcoming\nVisits',
        value: '${data.upcomingVisits}',
        icon: Icons.schedule_outlined,
        iconColor: const Color(0xFFA855F7),
      ),
      _ExecutiveMetricData(
        title: 'Completed\nVisits',
        value: '${data.completedVisits}',
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF22C55E),
      ),
      _ExecutiveMetricData(
        title: 'Missed\nVisits',
        value: '${data.missedVisits}',
        icon: Icons.event_busy_outlined,
        iconColor: const Color(0xFFEF4444),
      ),
      _ExecutiveMetricData(
        title: 'Pending Follow-ups',
        value: '${data.pendingFollowUps}',
        icon: Icons.assignment_late_outlined,
        iconColor: const Color(0xFFF97316),
      ),
      _ExecutiveMetricData(
        title: 'Bookings Assisted',
        value: '${data.bookingsAssisted}',
        icon: Icons.handshake_outlined,
        iconColor: const Color(0xFF2563EB),
      ),
      _ExecutiveMetricData(
        title: 'Visits Pending\nStart',
        value: '${data.visitsPendingStart}',
        icon: Icons.assignment_turned_in_outlined,
        iconColor: const Color(0xFFF97316),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 140.h,
      ),
      itemBuilder: (_, index) => _ExecutiveMetricCard(data: metrics[index]),
    );
  }
}

class _PerformanceRankingCard extends StatelessWidget {
  const _PerformanceRankingCard({
    required this.data,
    required this.selectedRange,
    required this.selectedMode,
    required this.loading,
    required this.error,
    required this.onRangeChanged,
    required this.onModeChanged,
    required this.onRetry,
  });

  final _PerformanceRankingData data;
  final String selectedRange;
  final String selectedMode;
  final bool loading;
  final String? error;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onRetry;

  static const _ranges = {
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'yearly': 'Yearly',
  };

  @override
  Widget build(BuildContext context) {
    final rows = selectedMode == 'teams'
        ? data.teamRankings
        : data.userRankings;
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E8),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 21.sp,
                  color: AppColors.orangeDeep,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Performance ranking',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10213D),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'User-wise and team-wise leaderboard from lead status points.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        height: 1.35,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            initialValue: selectedRange,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 11.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFD5DCE7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: Color(0xFFD5DCE7)),
              ),
            ),
            items: _ranges.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF24324A),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: loading
                ? null
                : (value) {
                    if (value != null && value != selectedRange) {
                      onRangeChanged(value);
                    }
                  },
          ),
          SizedBox(height: 11.h),
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RankingModeButton(
                    label: 'Users',
                    selected: selectedMode == 'users',
                    onTap: loading ? null : () => onModeChanged('users'),
                  ),
                ),
                Expanded(
                  child: _RankingModeButton(
                    label: 'Teams',
                    selected: selectedMode == 'teams',
                    onTap: loading ? null : () => onModeChanged('teams'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          if (loading)
            const AppListSkeleton(itemCount: 4, itemHeight: 72, gap: 10)
          else if (error != null)
            _RankingError(message: error!, onRetry: onRetry)
          else ...[
            Row(
              children: [
                Expanded(
                  child: _RankingSummaryTile(
                    label: 'Team rank',
                    value: '#${data.currentTeamRank}',
                    points: data.currentTeamPoints,
                    icon: Icons.group_outlined,
                    iconColor: const Color(0xFF356DFF),
                    iconBackground: const Color(0xFFEAF1FF),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _RankingSummaryTile(
                    label: 'Range total',
                    value: '${data.totalScore}',
                    points: data.totalScore,
                    icon: Icons.emoji_events_outlined,
                    iconColor: const Color(0xFF9333EA),
                    iconBackground: const Color(0xFFF5ECFF),
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.h),
            _RankingSummaryTile(
              label: 'Your rank in team field executives',
              value: '#${data.currentUserRank}',
              points: data.currentUserPoints,
              icon: Icons.emoji_events_outlined,
              iconColor: AppColors.orangeDeep,
              iconBackground: const Color(0xFFFFF1E8),
            ),
            SizedBox(height: 16.h),
            if (rows.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: Text(
                    selectedMode == 'teams'
                        ? 'No team rankings available.'
                        : 'No user rankings available.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              )
            else
              ...rows.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _RankingPersonRow(
                    item: item,
                    highlighted:
                        item.userId == data.currentUserId ||
                        (selectedMode == 'users' &&
                            item.rank == data.currentUserRank),
                  ),
                ),
              ),
            Text(
              selectedMode == 'teams'
                  ? 'Rankings compare teams using lead status points for the selected range.'
                  : 'Rankings compare active field executives in your assigned team.',
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                height: 1.4,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RankingModeButton extends StatelessWidget {
  const _RankingModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(7.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9.h),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF25324A),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankingSummaryTile extends StatelessWidget {
  const _RankingSummaryTile({
    required this.label,
    required this.value,
    required this.points,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String label;
  final String value;
  final int points;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 112.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD8DEE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: const Color(0xFF303746),
                  ),
                ),
              ),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18.sp, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF103566),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$points points',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingPersonRow extends StatelessWidget {
  const _RankingPersonRow({required this.item, required this.highlighted});

  final _RankingEntry item;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFFCFA) : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFFFD7C1)
              : const Color(0xFFD8DEE9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.rank == 1
                  ? const Color(0xFFFFEDE3)
                  : const Color(0xFFF0F3F8),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${item.rank}',
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF344054),
              ),
            ),
          ),
          SizedBox(width: 7.w),
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFF0D172D),
            backgroundImage: item.imageUrl.isEmpty
                ? null
                : NetworkImage(item.imageUrl),
            child: item.imageUrl.isEmpty
                ? Text(
                    item.initials,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10213D),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp,
                    height: 1.35,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.points}',
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10213D),
                ),
              ),
              Text(
                'points',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RankingError extends StatelessWidget {
  const _RankingError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFFB42318),
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _UpcomingSiteVisitsCard extends StatelessWidget {
  const _UpcomingSiteVisitsCard({
    required this.visits,
    required this.onViewSchedule,
    required this.onDirections,
    required this.actionStateFor,
    required this.isActionLoading,
    required this.onStartVisit,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onUndoStart,
  });

  final List<_TodaySiteVisitItem> visits;
  final VoidCallback onViewSchedule;
  final ValueChanged<_TodaySiteVisitItem> onDirections;
  final _VisitActionState Function(_TodaySiteVisitItem) actionStateFor;
  final bool Function(_TodaySiteVisitItem) isActionLoading;
  final ValueChanged<_TodaySiteVisitItem> onStartVisit;
  final ValueChanged<_TodaySiteVisitItem> onCheckIn;
  final ValueChanged<_TodaySiteVisitItem> onCheckOut;
  final ValueChanged<_TodaySiteVisitItem> onUndoStart;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s Upcoming Site Visits',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B2A50),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onViewSchedule,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 36.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  side: const BorderSide(color: Color(0xFFD6DEE9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'View Full Schedule',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B2A50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (visits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0xFFF0F1FF),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Text(
                      'No site visits scheduled for today',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (var index = 0; index < visits.take(4).length; index++) ...[
              _UpcomingSiteVisitTile(
                item: visits[index],
                onViewSchedule: onViewSchedule,
                onDirections: () => onDirections(visits[index]),
                actionState: actionStateFor(visits[index]),
                actionLoading: isActionLoading(visits[index]),
                onStartVisit: () => onStartVisit(visits[index]),
                onCheckIn: () => onCheckIn(visits[index]),
                onCheckOut: () => onCheckOut(visits[index]),
                onUndoStart: () => onUndoStart(visits[index]),
              ),
              if (index != visits.take(4).length - 1) SizedBox(height: 10.h),
            ],
        ],
      ),
    );
  }
}

class _UpcomingSiteVisitTile extends StatelessWidget {
  const _UpcomingSiteVisitTile({
    required this.item,
    required this.onViewSchedule,
    required this.onDirections,
    required this.actionState,
    required this.actionLoading,
    required this.onStartVisit,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onUndoStart,
  });

  final _TodaySiteVisitItem item;
  final VoidCallback onViewSchedule;
  final VoidCallback onDirections;
  final _VisitActionState actionState;
  final bool actionLoading;
  final VoidCallback onStartVisit;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onUndoStart;

  @override
  Widget build(BuildContext context) {
    final canNavigate = item.coordinate != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3ED)),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _VisitField(label: 'Time', value: item.time),
                ),
                SizedBox(width: 10.w),
                _VisitStatusChip(status: item.status),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _VisitField(
                        label: 'Lead / Customer',
                        value: item.leadName,
                        subValue: item.phone,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 5,
                      child: _VisitField(label: 'Project', value: item.project),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _VisitField(
                        label: 'Location',
                        value: item.location,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _VisitField(
                        label: 'Meeting Point',
                        value: item.meetingPoint,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _SmallVisitActionButton(
                      icon: Icons.calendar_month_outlined,
                      onTap: onViewSchedule,
                    ),
                    SizedBox(width: 8.w),
                    _SmallVisitActionButton(
                      icon: Icons.phone_outlined,
                      onTap: item.phone.trim().isEmpty
                          ? null
                          : () => unawaited(
                              launchUrl(
                                Uri(scheme: 'tel', path: item.phone.trim()),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                    ),
                    SizedBox(width: 8.w),
                    _SmallVisitActionButton(
                      icon: Icons.near_me_outlined,
                      onTap: canNavigate ? onDirections : null,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: actionLoading
                            ? null
                            : actionState == _VisitActionState.notStarted
                            ? onStartVisit
                            : actionState == _VisitActionState.started
                            ? onCheckIn
                            : actionState == _VisitActionState.checkedIn
                            ? onCheckOut
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(42.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          elevation: 0,
                          backgroundColor:
                              actionState == _VisitActionState.checkedIn
                              ? AppColors.navy
                              : AppColors.orangeDeep,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              actionState == _VisitActionState.checkedOut
                              ? AppColors.greenDeep
                              : const Color(0xFFE5E7EB),
                          disabledForegroundColor:
                              actionState == _VisitActionState.checkedOut
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: actionLoading
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                actionState == _VisitActionState.notStarted
                                    ? Icons.play_arrow_rounded
                                    : actionState == _VisitActionState.started
                                    ? Icons.location_on_outlined
                                    : actionState == _VisitActionState.checkedIn
                                    ? Icons.logout_rounded
                                    : Icons.check_circle_outline,
                              ),
                        label: Text(
                          actionState == _VisitActionState.notStarted
                              ? 'Start Visit'
                              : actionState == _VisitActionState.started
                              ? 'Check In'
                              : actionState == _VisitActionState.checkedIn
                              ? 'Check Out'
                              : 'Completed',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (actionState == _VisitActionState.started) ...[
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Route active. Check in when you reach the site.',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            height: 1.25,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      OutlinedButton(
                        onPressed: actionLoading ? null : onUndoStart,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 36.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 5.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Undo',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (actionState == _VisitActionState.checkedIn) ...[
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Checked in. Tap Check Out when the visit is complete.',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
                if (actionState == _VisitActionState.checkedOut) ...[
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Visit completed and checked out.',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenDeep,
                      ),
                    ),
                  ),
                ],
                if (!canNavigate) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Project coordinates are missing for directions.',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      color: const Color(0xFFB42318),
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

class _VisitField extends StatelessWidget {
  const _VisitField({required this.label, required this.value, this.subValue});

  final String label;
  final String value;
  final String? subValue;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? '-' : value.trim();
    final safeSubValue = subValue?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          safeValue,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0B2A50),
          ),
        ),
        if (safeSubValue.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            safeSubValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF7C8AA1),
            ),
          ),
        ],
      ],
    );
  }
}

class _VisitStatusChip extends StatelessWidget {
  const _VisitStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 130.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          status.trim().isEmpty ? 'Scheduled' : status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF155EEF),
          ),
        ),
      ),
    );
  }
}

class _SmallVisitActionButton extends StatelessWidget {
  const _SmallVisitActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: onTap == null
                  ? const Color(0xFFE5E7EB)
                  : const Color(0xFFD7E0EB),
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: onTap == null
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _MyDayCard extends StatelessWidget {
  const _MyDayCard({required this.data, required this.onViewSchedule});

  final _FieldDashboardData data;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Today’s visits:', data.myDayTodaysVisits),
      ('Follow-ups today:', data.myDayFollowUpsToday),
      ('Visits pending start:', data.myDayCheckInsPending),
      ('Completed visits:', data.myDayCompletedVisits),
    ];
    return _ExecutiveSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: Color(0xFFF97316)),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'My Day',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          for (final row in rows)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Text(
                    '${row.$2}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Next visit:',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  data.myDayNextVisit.isEmpty ? '-' : data.myDayNextVisit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewSchedule,
              child: const Text('View My Schedule'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExecutiveRouteMapCard extends StatefulWidget {
  const _ExecutiveRouteMapCard({
    super.key,
    required this.stops,
    required this.points,
    required this.polylinePoints,
    required this.executiveName,
    required this.executiveImageUrl,
  });

  final List<String> stops;
  final List<LatLng> points;
  final List<LatLng> polylinePoints;
  final String executiveName;
  final String executiveImageUrl;

  @override
  State<_ExecutiveRouteMapCard> createState() => _ExecutiveRouteMapCardState();
}

class _ExecutiveRouteMapCardState extends State<_ExecutiveRouteMapCard> {
  BitmapDescriptor? _executiveMarker;

  bool get _hasActiveExecutiveMarker =>
      widget.points.isNotEmpty &&
      widget.stops.isNotEmpty &&
      widget.stops.first == 'Your location';

  @override
  void initState() {
    super.initState();
    unawaited(_loadExecutiveMarker());
  }

  @override
  void didUpdateWidget(covariant _ExecutiveRouteMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.executiveImageUrl != widget.executiveImageUrl ||
        oldWidget.executiveName != widget.executiveName ||
        _firstRouteStop(oldWidget.stops) != _firstRouteStop(widget.stops)) {
      unawaited(_loadExecutiveMarker());
    }
  }

  Future<void> _loadExecutiveMarker() async {
    if (!_hasActiveExecutiveMarker) {
      if (mounted) setState(() => _executiveMarker = null);
      return;
    }
    final marker = await _fieldExecutiveMarker(
      name: widget.executiveName,
      imageUrl: widget.executiveImageUrl,
    );
    if (mounted) setState(() => _executiveMarker = marker);
  }

  @override
  Widget build(BuildContext context) {
    const fallbackCenter = LatLng(19.0760, 72.8777);
    final hasRoute = widget.points.isNotEmpty;
    final center = hasRoute ? widget.points.first : fallbackCenter;
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s Route on Google Maps',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  hasRoute
                      ? widget.stops.isNotEmpty &&
                                widget.stops.first == 'Your location'
                            ? 'Active route'
                            : '${widget.points.length} visit${widget.points.length == 1 ? '' : 's'}'
                      : 'No mapped visits',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: AppColors.orangeDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              height: 360.h,
              width: double.infinity,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (controller) {
                      if (widget.points.length < 2) return;
                      Future<void>.delayed(
                        const Duration(milliseconds: 300),
                        () => controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                            _dashboardLatLngBounds(widget.points),
                            54,
                          ),
                        ),
                      );
                    },
                    initialCameraPosition: CameraPosition(
                      target: center,
                      zoom: hasRoute ? 14 : 11,
                    ),
                    markers: {
                      for (var index = 0; index < widget.points.length; index++)
                        Marker(
                          markerId: MarkerId('route-stop-$index'),
                          position: widget.points[index],
                          infoWindow: InfoWindow(
                            title: index < widget.stops.length
                                ? widget.stops[index]
                                : 'Stop ${index + 1}',
                          ),
                          icon:
                              index == 0 &&
                                  _hasActiveExecutiveMarker &&
                                  _executiveMarker != null
                              ? _executiveMarker!
                              : BitmapDescriptor.defaultMarkerWithHue(
                                  index == 0
                                      ? BitmapDescriptor.hueOrange
                                      : BitmapDescriptor.hueRed,
                                ),
                        ),
                    },
                    polylines: {
                      if (widget.polylinePoints.length > 1)
                        Polyline(
                          polylineId: const PolylineId('today-route'),
                          points: widget.polylinePoints,
                          color: AppColors.orangeDeep,
                          width: 5,
                          jointType: JointType.round,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                        ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                    mapToolbarEnabled: false,
                  ),
                  if (!hasRoute)
                    Positioned(
                      left: 10.w,
                      right: 10.w,
                      bottom: 10.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .94),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 8),
                          ],
                        ),
                        child: Text(
                          'Today’s assigned site visits will appear here when project latitude and longitude are available.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _firstRouteStop(List<String> stops) =>
    stops.isEmpty ? null : stops.first;

Future<BitmapDescriptor> _fieldExecutiveMarker({
  required String name,
  required String imageUrl,
}) async {
  const canvasSize = 88;
  const avatarCenter = Offset(44, 39);
  const avatarRadius = 29.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  canvas.drawCircle(
    avatarCenter.translate(0, 3),
    avatarRadius + 4,
    Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );

  final pinPath = Path()
    ..moveTo(33, 61)
    ..lineTo(44, 84)
    ..lineTo(55, 61)
    ..close();
  canvas.drawPath(pinPath, Paint()..color = const Color(0xFFFFFFFF));
  canvas.drawPath(
    Path()
      ..moveTo(37, 60)
      ..lineTo(44, 78)
      ..lineTo(51, 60)
      ..close(),
    Paint()..color = const Color(0xFF12376A),
  );
  canvas.drawCircle(
    avatarCenter,
    avatarRadius + 4,
    Paint()..color = const Color(0xFFFFFFFF),
  );

  var drewProfileImage = false;
  final uri = Uri.tryParse(imageUrl.trim());
  if (uri != null && uri.hasScheme) {
    try {
      final response = await http.get(uri);
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.bodyBytes.isNotEmpty) {
        final codec = await ui.instantiateImageCodec(
          response.bodyBytes,
          targetWidth: 72,
          targetHeight: 72,
        );
        final frame = await codec.getNextFrame();
        canvas.save();
        canvas.clipPath(
          Path()..addOval(
            Rect.fromCircle(center: avatarCenter, radius: avatarRadius),
          ),
        );
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: avatarCenter, radius: avatarRadius),
          image: frame.image,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        );
        canvas.restore();
        drewProfileImage = true;
      }
    } catch (_) {
      // The letter avatar below is the intentional fallback for bad image URLs.
    }
  }

  if (!drewProfileImage) {
    canvas.drawCircle(
      avatarCenter,
      avatarRadius,
      Paint()..color = const Color(0xFF12376A),
    );
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final initials = words.isEmpty
        ? 'FE'
        : words
              .take(2)
              .map((word) => word.substring(0, 1).toUpperCase())
              .join();
    final painter = TextPainter(
      text: TextSpan(
        text: initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      avatarCenter - Offset(painter.width / 2, painter.height / 2),
    );
  }

  canvas.drawCircle(
    avatarCenter,
    avatarRadius,
    Paint()
      ..color = const Color(0xFF12376A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5,
  );

  final image = await recorder.endRecording().toImage(canvasSize, canvasSize);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return BitmapDescriptor.defaultMarker;
  return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
}

class _DynamicSiteVisitFunnelCard extends StatelessWidget {
  const _DynamicSiteVisitFunnelCard({required this.data});

  final _FieldDashboardData data;

  @override
  Widget build(BuildContext context) {
    final rows = data.funnel.isEmpty
        ? [
            _VisitFunnelData('Scheduled', data.todaySiteVisits),
            _VisitFunnelData('Checked In', data.checkedIn),
            _VisitFunnelData('Visit Completed', data.completedVisits),
          ]
        : data.funnel;
    final maximum = rows
        .map((item) => item.value)
        .fold<int>(1, (value, item) => item > value ? item : value);
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Visit Funnel Overview',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 16.h),
          for (var index = 0; index < rows.length; index++) ...[
            Text(
              '${rows[index].label} (${rows[index].value})',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 7.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(99.r),
              child: LinearProgressIndicator(
                value: rows[index].value / maximum,
                minHeight: 7.h,
                backgroundColor: const Color(0xFFE9EAFE),
                color: index == rows.length - 1
                    ? AppColors.orangeDeep
                    : const Color(0xFFB9C5F5),
              ),
            ),
            if (index != rows.length - 1) SizedBox(height: 13.h),
          ],
        ],
      ),
    );
  }
}

class _ExecutiveMetricData {
  const _ExecutiveMetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
}

class _ExecutiveSectionCard extends StatelessWidget {
  const _ExecutiveSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD9E2EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CheckInStatusCard extends StatelessWidget {
  const _CheckInStatusCard({required this.items});

  final List<_StatusMetric> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in Status',
            style: GoogleFonts.inter(
              fontSize: 21.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          if (items.length >= 4) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CheckInMetricTile(item: items[0])),
                SizedBox(width: 20.w),
                Expanded(child: _CheckInMetricTile(item: items[1])),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CheckInMetricTile(item: items[2])),
                SizedBox(width: 20.w),
                Expanded(child: _CheckInMetricTile(item: items[3])),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExecutiveAlertCard extends StatelessWidget {
  const _ExecutiveAlertCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 19.sp,
                color: const Color(0xFFF97316),
              ),
              SizedBox(width: 8.w),
              Text(
                'Alerts & Notifications',
                style: GoogleFonts.inter(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No alerts or notifications.')
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFF6D7BD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    Text(
                      items[i],
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBF5A2A),
                      ),
                    ),
                    if (i != items.length - 1) SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExecutiveRecentActivityCard extends StatelessWidget {
  const _ExecutiveRecentActivityCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No recent activity.')
          else
            for (int i = 0; i < items.length; i++) ...[
              _ExecutiveActivityRow(text: items[i]),
              if (i != items.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Divider(height: 1, color: const Color(0xFFE5E7EB)),
                ),
            ],
        ],
      ),
    );
  }
}

class _TodayStopsCard extends StatelessWidget {
  const _TodayStopsCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ExecutiveSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Stops',
            style: GoogleFonts.inter(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isEmpty)
            const _ExecutiveEmptyText('No route stops today.')
          else
            for (var i = 0; i < items.length; i++) ...[
              _ExecutiveActivityRow(text: items[i]),
              if (i != items.length - 1) SizedBox(height: 12.h),
            ],
        ],
      ),
    );
  }
}

class _CheckInMetricTile extends StatelessWidget {
  const _CheckInMetricTile({required this.item});

  final _StatusMetric item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          item.value,
          style: GoogleFonts.inter(
            fontSize: 30.sp,
            fontWeight: FontWeight.w700,
            color: item.valueColor,
          ),
        ),
      ],
    );
  }
}

class _ExecutiveActivityRow extends StatelessWidget {
  const _ExecutiveActivityRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          margin: EdgeInsets.only(top: 2.h),
          decoration: const BoxDecoration(
            color: Color(0xFFE9F9EE),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 15.sp, color: const Color(0xFF22C55E)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusMetric {
  const _StatusMetric(this.label, this.value, this.valueColor);

  final String label;
  final String value;
  final Color valueColor;
}

class _ExecutiveEmptyText extends StatelessWidget {
  const _ExecutiveEmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF667085),
      ),
    );
  }
}

class _ExecutiveErrorCard extends StatelessWidget {
  const _ExecutiveErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFDA4AF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFBE123C)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9F1239),
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _PerformanceRankingData {
  const _PerformanceRankingData({
    this.currentUserRank = 0,
    this.currentTeamRank = 0,
    this.currentUserPoints = 0,
    this.currentTeamPoints = 0,
    this.totalScore = 0,
    this.currentUserId = '',
    this.userRankings = const [],
    this.teamRankings = const [],
  });

  factory _PerformanceRankingData.fromApi(Object? source) {
    final root = _dashboardMap(source);
    final summary = _dashboardMap(root['summary']);
    final topUser = _dashboardMap(summary['topUser']);
    return _PerformanceRankingData(
      currentUserRank: _dashboardInt(summary, const ['currentUserRank']),
      currentTeamRank: _dashboardInt(summary, const ['currentTeamRank']),
      currentUserPoints: _dashboardInt(summary, const ['currentUserPoints']),
      currentTeamPoints: _dashboardInt(summary, const ['currentTeamPoints']),
      totalScore: _dashboardInt(summary, const ['totalScore']),
      currentUserId: _dashboardText(topUser['userId']),
      userRankings: _RankingEntry.listFrom(root['userRankings']),
      teamRankings: _RankingEntry.listFrom(
        root['teamRankings'],
        teamEntries: true,
      ),
    );
  }

  final int currentUserRank;
  final int currentTeamRank;
  final int currentUserPoints;
  final int currentTeamPoints;
  final int totalScore;
  final String currentUserId;
  final List<_RankingEntry> userRankings;
  final List<_RankingEntry> teamRankings;
}

class _RankingEntry {
  const _RankingEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.points,
    required this.statusText,
  });

  factory _RankingEntry.fromMap(
    Map<String, dynamic> map, {
    bool teamEntry = false,
  }) {
    final statusBreakdown = map['statusBreakdown'];
    final hasStatusPoints =
        statusBreakdown is List && statusBreakdown.isNotEmpty;
    final designation = _dashboardFirstText([
      map['designation'],
      map['role'],
      teamEntry ? 'Team' : 'Field Executive',
    ]);
    final teamName = _dashboardFirstText([
      map['teamName'],
      teamEntry ? map['leaderName'] : null,
    ]);
    final memberCount = _dashboardInt(map, const ['memberCount']);
    return _RankingEntry(
      rank: _dashboardInt(map, const ['rank']),
      userId: _dashboardFirstText([map['userId'], map['teamId']]),
      name: _dashboardFirstText([
        teamEntry ? map['teamName'] : map['name'],
        'Unknown',
      ]),
      subtitle: teamEntry
          ? [
              memberCount > 0 ? '$memberCount members' : '',
              _dashboardText(map['leaderName']).isNotEmpty
                  ? 'Lead: ${_dashboardText(map['leaderName'])}'
                  : '',
            ].where((value) => value.isNotEmpty).join(' / ')
          : [
              designation,
              teamName,
            ].where((value) => value.isNotEmpty).join(' / '),
      imageUrl: _dashboardText(map['image']),
      points: _dashboardInt(map, const ['points']),
      statusText: hasStatusPoints
          ? '${statusBreakdown.length} scoring statuses'
          : 'No status points yet',
    );
  }

  static List<_RankingEntry> listFrom(
    Object? source, {
    bool teamEntries = false,
  }) {
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map(
          (item) => _RankingEntry.fromMap(
            Map<String, dynamic>.from(item),
            teamEntry: teamEntries,
          ),
        )
        .toList();
  }

  final int rank;
  final String userId;
  final String name;
  final String subtitle;
  final String imageUrl;
  final int points;
  final String statusText;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final length = parts.first.length.clamp(1, 2);
      return parts.first.substring(0, length).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _TodaySiteVisitItem {
  const _TodaySiteVisitItem({
    required this.id,
    required this.time,
    required this.leadName,
    required this.phone,
    required this.project,
    required this.location,
    required this.meetingPoint,
    required this.status,
    required this.mapLabel,
    required this.checkedInAt,
    required this.checkedOutAt,
    this.coordinate,
  });

  factory _TodaySiteVisitItem.fromVisit(SiteVisitModel visit, LatLng? point) {
    final raw = visit.raw;
    final project = _dashboardMap(raw['project'] ?? raw['property']);
    final lead = _dashboardMap(raw['lead']);
    final tracking = _dashboardMap(
      raw['tracking'] ?? raw['visitTracking'] ?? raw['attendance'],
    );
    final displayId = _dashboardText(raw['displayId']);
    final leadName = _dashboardFirstText([
      visit.leadName,
      lead['name'],
      lead['fullName'],
      displayId,
      'Unknown lead',
    ]);
    final projectName = _dashboardFirstText([
      visit.project,
      project['name'],
      project['projectName'],
      'Project not available',
    ]);
    final time = visit.scheduledAt == null ? 'Time not set' : visit.time;
    final location = _dashboardFirstText([
      visit.location,
      project['location'],
      project['address'],
      project['city'],
      raw['location'],
    ]);
    final meetingPoint = _dashboardFirstText([
      raw['meetingPoint'],
      raw['meetingLocation'],
      'Sales Gallery',
    ]);
    return _TodaySiteVisitItem(
      id: visit.id,
      time: time,
      leadName: leadName,
      phone: _dashboardFirstText([visit.phone, lead['phone'], lead['mobile']]),
      project: projectName,
      location: location,
      meetingPoint: meetingPoint,
      status: visit.status.isEmpty ? 'Scheduled' : visit.status,
      coordinate: point,
      mapLabel: [
        time,
        leadName,
        projectName,
      ].where((part) => part.trim().isNotEmpty).join(' • '),
      checkedInAt: _dashboardFirstDate([
        raw['checkedInAt'],
        raw['checkInAt'],
        raw['checkInTime'],
        raw['actualCheckInAt'],
        tracking['checkedInAt'],
        tracking['checkInAt'],
      ]),
      checkedOutAt: _dashboardFirstDate([
        raw['checkedOutAt'],
        raw['checkOutAt'],
        raw['checkOutTime'],
        raw['actualCheckOutAt'],
        tracking['checkedOutAt'],
        tracking['checkOutAt'],
      ]),
    );
  }

  final String id;
  final String time;
  final String leadName;
  final String phone;
  final String project;
  final String location;
  final String meetingPoint;
  final String status;
  final String mapLabel;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final LatLng? coordinate;

  _VisitActionState get initialActionState {
    if (checkedOutAt != null ||
        status.toLowerCase().contains('completed') ||
        status.toLowerCase().contains('checked out')) {
      return _VisitActionState.checkedOut;
    }
    if (checkedInAt != null || status.toLowerCase().contains('checked in')) {
      return _VisitActionState.checkedIn;
    }
    return _VisitActionState.notStarted;
  }
}

enum _VisitActionState { notStarted, started, checkedIn, checkedOut }

DateTime? _dashboardDate(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

DateTime? _dashboardFirstDate(Iterable<Object?> values) {
  for (final value in values) {
    final date = _dashboardDate(value);
    if (date != null) return date;
  }
  return null;
}

class _VisitFunnelData {
  const _VisitFunnelData(this.label, this.value);

  final String label;
  final int value;
}

class _FieldDashboardData {
  const _FieldDashboardData({
    this.employeeName = '',
    this.assignedLeads = 0,
    this.todaySiteVisits = 0,
    this.upcomingVisits = 0,
    this.completedVisits = 0,
    this.missedVisits = 0,
    this.pendingFollowUps = 0,
    this.bookingsAssisted = 0,
    this.visitsPendingStart = 0,
    this.checkedIn = 0,
    this.pendingCheckIns = 0,
    this.checkedOut = 0,
    this.missedCheckIns = 0,
    this.alerts = const [],
    this.activities = const [],
    this.todayStops = const [],
    this.routePoints = const [],
    this.myDayTodaysVisits = 0,
    this.myDayFollowUpsToday = 0,
    this.myDayCheckInsPending = 0,
    this.myDayCompletedVisits = 0,
    this.myDayNextVisit = '',
    this.funnel = const [],
  });

  final String employeeName;
  final int assignedLeads;
  final int todaySiteVisits;
  final int upcomingVisits;
  final int completedVisits;
  final int missedVisits;
  final int pendingFollowUps;
  final int bookingsAssisted;
  final int visitsPendingStart;
  final int checkedIn;
  final int pendingCheckIns;
  final int checkedOut;
  final int missedCheckIns;
  final List<String> alerts;
  final List<String> activities;
  final List<String> todayStops;
  final List<LatLng> routePoints;
  final int myDayTodaysVisits;
  final int myDayFollowUpsToday;
  final int myDayCheckInsPending;
  final int myDayCompletedVisits;
  final String myDayNextVisit;
  final List<_VisitFunnelData> funnel;

  List<_StatusMetric> get checkInStatus => [
    _StatusMetric('Checked in', '$checkedIn', const Color(0xFF22C55E)),
    _StatusMetric('Pending', '$pendingCheckIns', const Color(0xFFF97316)),
    _StatusMetric('Checked out', '$checkedOut', const Color(0xFF2563EB)),
    _StatusMetric('Missed', '$missedCheckIns', const Color(0xFFEF4444)),
  ];

  factory _FieldDashboardData.fromApi(
    Object? source,
    Map<String, dynamic>? sessionUser,
  ) {
    final root = _dashboardMap(source);
    final user = _dashboardMap(
      _dashboardValue(root, const [
        'employee',
        'fieldExecutive',
        'executive',
        'user',
        'profile',
      ]),
    );
    final session = sessionUser ?? const <String, dynamic>{};
    final kpis = _dashboardMap(root['kpis']);
    final myDay = _dashboardMap(root['myDay']);
    final checkInStatus = _dashboardMap(root['checkInStatus']);
    final firstName = _dashboardText(user['firstName'] ?? session['firstName']);
    final lastName = _dashboardText(user['lastName'] ?? session['lastName']);
    final combinedName = '$firstName $lastName'.trim();
    final alerts = _dashboardTextList(
      root['followUps'] ??
          _dashboardValue(root, const [
            'alerts',
            'notifications',
            'pendingAlerts',
          ]),
    );
    final activities = _dashboardTextList(
      _dashboardValue(root, const [
        'recentActivities',
        'recentActivity',
        'activities',
        'activity',
      ]),
    );
    final stops = _dashboardTextList(
      _dashboardValue(root, const [
        'todayStops',
        'todaySchedule',
        'routeStops',
        'stops',
        'todayVisits',
        'visitsToday',
      ]),
      stop: true,
    );
    final routePoints = _dashboardRoutePoints(
      _dashboardValue(root, const [
        'todayStops',
        'todaySchedule',
        'routeStops',
        'stops',
        'todayVisits',
        'visitsToday',
        'route',
      ]),
    );
    final funnel = _dashboardFunnel(root['funnel']);

    return _FieldDashboardData(
      employeeName: _dashboardFirstText([
        user['name'],
        user['fullName'],
        combinedName,
        session['name'],
        session['fullName'],
      ]),
      assignedLeads: _dashboardInt(kpis, const [
        'assignedLeads',
        'assignedLeadCount',
        'totalAssignedLeads',
      ]),
      todaySiteVisits: _dashboardInt(kpis, const [
        'todaySiteVisits',
        'todaysSiteVisits',
        'todaysVisits',
        'visitsToday',
      ]),
      upcomingVisits: _dashboardInt(kpis, const [
        'upcomingVisits',
        'upcomingSiteVisits',
      ]),
      completedVisits: _dashboardInt(kpis, const [
        'completedVisits',
        'completedSiteVisits',
      ]),
      missedVisits: _dashboardInt(kpis, const [
        'missedVisits',
        'missedSiteVisits',
      ]),
      pendingFollowUps: _dashboardInt(kpis, const [
        'pendingFollowUps',
        'pendingFollowups',
        'followUpsPending',
      ]),
      bookingsAssisted: _dashboardInt(kpis, const [
        'bookingsAssisted',
        'assistedBookings',
        'bookingCount',
      ]),
      visitsPendingStart: _dashboardInt(kpis, const [
        'visitsPendingStart',
        'pendingStartVisits',
        'notStartedVisits',
        'checkInsPending',
      ]),
      checkedIn: _dashboardInt(checkInStatus, const [
        'checkedIn',
        'checkedInCount',
        'checkIns',
      ]),
      pendingCheckIns: _dashboardInt(checkInStatus, const [
        'pendingCheckIns',
        'pendingCheckIn',
        'checkInPending',
        'pending',
      ]),
      checkedOut: _dashboardInt(checkInStatus, const [
        'checkedOut',
        'checkedOutCount',
        'checkOuts',
      ]),
      missedCheckIns: _dashboardInt(checkInStatus, const [
        'missedCheckIns',
        'missedCheckIn',
        'checkInMissed',
      ]),
      alerts: alerts,
      activities: activities,
      todayStops: stops,
      routePoints: routePoints,
      myDayTodaysVisits: _dashboardInt(myDay, const ['todaysVisits']),
      myDayFollowUpsToday: _dashboardInt(myDay, const ['followUpsToday']),
      myDayCheckInsPending: _dashboardInt(myDay, const ['checkInsPending']),
      myDayCompletedVisits: _dashboardInt(myDay, const ['completedVisits']),
      myDayNextVisit: _dashboardText(myDay['nextVisit']),
      funnel: funnel,
    );
  }
}

Map<String, dynamic> _dashboardMap(Object? value) {
  if (value is! Map) return const {};
  final map = Map<String, dynamic>.from(value);
  final data = map['data'];
  if (data is Map) return _dashboardMap(data);
  return map;
}

Object? _dashboardValue(
  Map<String, dynamic> root,
  List<String> keys, [
  int depth = 0,
]) {
  for (final key in keys) {
    if (root.containsKey(key) && root[key] != null) return root[key];
  }
  if (depth >= 3) return null;
  for (final value in root.values) {
    if (value is Map) {
      final found = _dashboardValue(
        Map<String, dynamic>.from(value),
        keys,
        depth + 1,
      );
      if (found != null) return found;
    }
  }
  return null;
}

int _dashboardInt(Map<String, dynamic> root, List<String> keys) {
  final value = _dashboardValue(root, keys);
  if (value is num) return value.toInt();
  if (value is List) return value.length;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _dashboardText(Object? value) => value?.toString().trim() ?? '';

String _dashboardFirstText(Iterable<Object?> values) {
  for (final value in values) {
    final text = _dashboardText(value);
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

String _employeeProfileImageUrl(Iterable<Object?> sources) {
  for (final source in sources) {
    final image = _findEmployeeProfileImage(source);
    if (image.isEmpty) continue;
    final uri = Uri.tryParse(image);
    if (uri != null && uri.hasScheme) return image;
    if (image.startsWith('/')) return 'https://crmtrueroot.com$image';
    return 'https://crmtrueroot.com/$image';
  }
  return '';
}

String _findEmployeeProfileImage(Object? value, [int depth = 0]) {
  if (value == null || depth > 4) return '';
  if (value is String) {
    final text = value.trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }
  if (value is! Map) return '';

  final map = Map<String, dynamic>.from(value);
  const imageKeys = [
    'image',
    'imageUrl',
    'profileImage',
    'profileImageUrl',
    'profilePicture',
    'avatar',
    'avatarUrl',
    'photo',
    'photoUrl',
  ];
  for (final key in imageKeys) {
    final image = _findEmployeeProfileImage(map[key], depth + 1);
    if (image.isNotEmpty) return image;
  }
  const nestedKeys = ['employee', 'user', 'profile', 'data'];
  for (final key in nestedKeys) {
    final image = _findEmployeeProfileImage(map[key], depth + 1);
    if (image.isNotEmpty) return image;
  }
  return '';
}

List<String> _dashboardTextList(Object? value, {bool stop = false}) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    value =
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['data'] ??
        map['visits'] ??
        map['stops'];
  }
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is! Map) return _dashboardText(item);
        final map = Map<String, dynamic>.from(item);
        if (stop) {
          final lead = _dashboardMap(map['lead']);
          final project = _dashboardMap(map['project'] ?? map['property']);
          final name = _dashboardFirstText([
            map['title'],
            map['name'],
            map['leadName'],
            lead['name'],
            lead['fullName'],
          ]);
          final destination = _dashboardFirstText([
            map['projectName'],
            project['name'],
            map['location'],
            project['location'],
          ]);
          final time = _dashboardFirstText([
            map['time'],
            map['scheduledAt'],
            map['visitDateTime'],
          ]);
          return [
            name,
            destination,
            time,
          ].where((part) => part.isNotEmpty).join(' • ');
        }
        final nextAction = _dashboardText(map['nextAction']);
        if (nextAction.isNotEmpty) {
          return [
            _dashboardText(map['leadName']),
            nextAction,
          ].where((part) => part.isNotEmpty).join(' • ');
        }
        final title = _dashboardText(map['title']);
        final description = _dashboardText(map['description']);
        if (title.isNotEmpty || description.isNotEmpty) {
          return [
            title,
            description,
          ].where((part) => part.isNotEmpty).join(' — ');
        }
        return _dashboardFirstText([
          map['message'],
          map['activity'],
          map['text'],
          map['name'],
        ]);
      })
      .where((text) => text.isNotEmpty)
      .toList();
}

List<_VisitFunnelData> _dashboardFunnel(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return _VisitFunnelData(
          _dashboardText(map['label']),
          _dashboardInt(map, const ['value', 'count']),
        );
      })
      .where((item) => item.label.isNotEmpty)
      .toList();
}

List<LatLng> _dashboardRoutePoints(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    value =
        map['items'] ??
        map['results'] ??
        map['rows'] ??
        map['data'] ??
        map['visits'] ??
        map['stops'] ??
        map['route'];
  }
  if (value is! List) return const [];
  final points = <LatLng>[];
  for (final item in value) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final location = map['location'] is Map
        ? Map<String, dynamic>.from(map['location'] as Map)
        : map['coordinates'] is Map
        ? Map<String, dynamic>.from(map['coordinates'] as Map)
        : map['project'] is Map
        ? Map<String, dynamic>.from(map['project'] as Map)
        : const <String, dynamic>{};
    final latitude = _dashboardCoordinate(
      map['latitude'] ?? map['lat'] ?? location['latitude'] ?? location['lat'],
    );
    final longitude = _dashboardCoordinate(
      map['longitude'] ??
          map['lng'] ??
          map['lon'] ??
          location['longitude'] ??
          location['lng'] ??
          location['lon'],
    );
    if (latitude != null && longitude != null) {
      points.add(LatLng(latitude, longitude));
    }
  }
  return points;
}

LatLng? _dashboardVisitPoint(Object? value) {
  final map = _dashboardMap(value);
  if (map.isEmpty) return null;
  final candidates = <Map<String, dynamic>>[
    map,
    _dashboardMap(map['location']),
    _dashboardMap(map['coordinates']),
    _dashboardMap(map['geo']),
    _dashboardMap(map['position']),
    _dashboardMap(map['project']),
    _dashboardMap(map['property']),
    _dashboardMap(_dashboardMap(map['project'])['location']),
    _dashboardMap(_dashboardMap(map['property'])['location']),
    _dashboardMap(_dashboardMap(map['project'])['coordinates']),
    _dashboardMap(_dashboardMap(map['property'])['coordinates']),
  ];
  for (final candidate in candidates) {
    if (candidate.isEmpty) continue;
    final latitude = _dashboardCoordinate(
      candidate['latitude'] ??
          candidate['lat'] ??
          candidate['projectLatitude'] ??
          candidate['propertyLatitude'],
    );
    final longitude = _dashboardCoordinate(
      candidate['longitude'] ??
          candidate['lng'] ??
          candidate['lon'] ??
          candidate['long'] ??
          candidate['projectLongitude'] ??
          candidate['propertyLongitude'],
    );
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
  }
  return null;
}

bool _isSameDashboardDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

double? _dashboardCoordinate(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

LatLngBounds _dashboardLatLngBounds(List<LatLng> points) {
  var south = points.first.latitude;
  var north = points.first.latitude;
  var west = points.first.longitude;
  var east = points.first.longitude;
  for (final point in points.skip(1)) {
    if (point.latitude < south) south = point.latitude;
    if (point.latitude > north) north = point.latitude;
    if (point.longitude < west) west = point.longitude;
    if (point.longitude > east) east = point.longitude;
  }
  return LatLngBounds(
    southwest: LatLng(south, west),
    northeast: LatLng(north, east),
  );
}
