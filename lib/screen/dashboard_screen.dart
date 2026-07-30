import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/constant/screen_utils.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/admin_dashboard_view.dart';
import 'package:truerealtycrm/screen/field_executive_dashboard_screen.dart';
import 'package:truerealtycrm/screen/lead_activity_timeline_screen.dart';
import 'package:truerealtycrm/screen/leads_screen.dart';
import 'package:truerealtycrm/screen/my_performance_screen.dart';
import 'package:truerealtycrm/screen/reports_screen.dart';
import 'package:truerealtycrm/screen/site_visits_screen.dart';
import 'package:truerealtycrm/screen/tasks_screen.dart';
import 'package:truerealtycrm/screen/telecaller_dashboard_screen.dart';
import 'package:truerealtycrm/screen/telecaller_documents_screen.dart';

import 'my_leads_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final selectedTab = dashboardProvider.selectedTab;
    final role = context.watch<AuthProvider>().role;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      drawer: const _NavigationDrawer(),
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: selectedTab,
        onTap: context.read<DashboardProvider>().selectTab,
      ),
      body: SafeArea(
        child: _buildBody(context, selectedTab, role, dashboardProvider),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    int selectedTab,
    UserRole role,
    DashboardProvider dashboardProvider,
  ) {
    if (selectedTab == 0) {
      if (role == UserRole.telecaller) {
        return TelecallerDashboardView(
          onMenuTap: _openDrawer,
          bottomSpacing: 32,
        );
      }

      if (role == UserRole.fieldExecutive) {
        return FieldExecutiveDashboardView(
          onMenuTap: _openDrawer,
          bottomSpacing: 32,
        );
      }

      return AdminDashboardView(onMenuTap: _openDrawer);
    }

    if (selectedTab == 1) {
      // return const MyLeadsScreen();
      // Navigator.of(context).pushNamed(AppRouter.myleads);

      return role == UserRole.telecaller
          ? MyLeadsScreen(onMenuTap: _openDrawer)
          // const _TelecallerLeadOverviewScreen()
          : LeadListWidget(isInsideScrollView: true, onMenuTap: _openDrawer);
    }

    if (selectedTab == 2) {
      if (role == UserRole.telecaller) {
        return const MyPerformanceScreen();
      }

      return TasksScreen(onMenuTap: _openDrawer);
    }

    if (selectedTab == 3) {
      if (role == UserRole.telecaller) {
        return SiteVisitDetailsScreen(onMenuTap: _openDrawer);
      }

      if (role == UserRole.fieldExecutive) {
        return SiteVisitDetailsScreen(onMenuTap: _openDrawer);
      }

      return const ReportsScreen();
    }

    if (selectedTab == 4) {
      return const _MoreTab();
    }

    return _PlaceholderTab(title: dashboardProvider.selectedTitle);
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340.h,
      child: Stack(
        children: [
          Positioned.fill(
            top: 108.h,
            child: Image.asset(
              'assets/dashboard_headers.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomRight,
            ),
          ),
          Positioned(
            left: 18.w,
            right: 18.w,
            top: 22.h,
            child: SizedBox(
              height: 48.h,
              child: Row(
                children: [
                  _PlainIconButton(icon: Icons.menu, onTap: onMenuTap),
                  SizedBox(width: 8.w),
                  const Expanded(child: _BrandLogo()),
                  _PlainIconButton(
                    icon: Icons.search,
                    iconSize: 22.sp,
                    onTap: () {},
                  ),
                  SizedBox(width: 10.w),
                  const _NotificationButton(),
                  SizedBox(width: 10.w),
                  Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xff111C38).withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 21.r,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: const AssetImage('assets/app_icon.png'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18.w,
            top: 80.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '',
                  style: GoogleFonts.inter(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                    color: const Color(0xFF002149),
                  ),
                ),
                SizedBox(
                  width: 280.w,
                  child: Text(
                    'Here\'s what\'s happening with your business today.',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: const Color(0xFF475467),
                    ),
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

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 148.w,
        height: 58.h,
        child: Image.asset(
          'assets/app_icon.png',
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _PlainIconButton extends StatelessWidget {
  const _PlainIconButton({
    required this.icon,
    required this.onTap,
    this.iconSize,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: SizedBox(
        height: 34.h,
        width: 28.w,
        child: Icon(icon, color: AppColors.navy, size: iconSize ?? 26.sp),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      width: 26.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.notifications_none,
              color: AppColors.navy,
              size: 24.sp,
            ),
          ),
          Positioned(
            right: -3.w,
            top: 2.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.white, width: 1),
              ),
              child: Text(
                '12',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.18)),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 32.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _AdminDashboardToolbar(),
            SizedBox(height: 16.h),
            const _AdminDashboardMetricGrid(),
            SizedBox(height: 16.h),
            const _AdminRevenueAndCompletedRow(),
            SizedBox(height: 16.h),
            const _AdminLeadsBySourceCard(),
            SizedBox(height: 16.h),
            const _AdminLeadFunnelOverviewCard(),
            SizedBox(height: 16.h),
            const _AdminSiteVisitsOverviewCard(),
            SizedBox(height: 16.h),
            const _AdminSlaHealthCard(),
            SizedBox(height: 16.h),
            const _AdminLiveExecutivesMapCard(),
            SizedBox(height: 16.h),
            const _AdminSystemUsersCard(),
            SizedBox(height: 16.h),
            const _AdminTeamPerformanceCard(),
            SizedBox(height: 16.h),
            const _AdminQuickActionsCard(),
            SizedBox(height: 12.h),
            const _AdminReportsShortcutsCard(),
          ],
        ),
      ),
    );
  }
}

class _TelecallerDashboardHeader extends StatelessWidget {
  const _TelecallerDashboardHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 296.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22.r),
                  bottomRight: Radius.circular(22.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18.w,
            right: 18.w,
            top: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 188.w,
                      height: 56.h,
                      child: Image.asset(
                        'assets/app_tellicaller.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const Spacer(),
                    const _TelecallerHeroNotification(),
                    SizedBox(width: 14.w),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A83B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                Text(
                  _TelecallerDashboardData.greeting,
                  style: TextStyle(
                    fontFamily: 'LiberationSans',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    height: 1.43, // line-height
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _TelecallerDashboardData.agentName,
                        style: TextStyle(
                          fontFamily: 'LiberationSans',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.33, // line-height
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.waving_hand_rounded,
                      size: 22.sp,
                      color: const Color(0xFFFFC857),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  _TelecallerDashboardData.greetingSubtitle,
                  style: TextStyle(
                    fontFamily: 'LiberationSans',
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    height: 1.33, // line-height
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: -162.h,
            child: Container(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE4EBF4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _TelecallerDashboardData.summaryTitle,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 15.sp,
                              color: const Color(0xFF64748B),
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                _TelecallerDashboardData.summaryDate,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: _TelecallerDashboardData.summaryMetrics
                        .map(
                          (metric) => Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: _TelecallerSummaryMetric(
                                icon: metric.icon,
                                imagePath: metric.imagePath,
                                value: metric.value,
                                label: metric.label,
                                iconBg: metric.iconBg,
                                iconColor: metric.iconColor,
                                accent: metric.accent,
                              ),
                            ),
                          ),
                        )
                        .toList(),
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

class _TelecallerDashboardContent extends StatelessWidget {
  const _TelecallerDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, 166.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 104.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('aakanksha'),

            // const _TelecallerQuickActionsSection(),
            // SizedBox(height: 28.h),
            // const _TelecallerLeadPipelinesSection(),
            // SizedBox(height: 28.h),
            // const _TelecallerTodayFollowUpsSection(),
            // SizedBox(height: 64.h),
          ],
        ),
      ),
    );
  }
}

class _CommunicationTabs extends StatelessWidget {
  const _CommunicationTabs();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _TelecallerOverviewSection extends StatelessWidget {
  const _TelecallerOverviewSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _TelecallerDashboardData {
  const _TelecallerDashboardData._();

  static const greeting = 'Good Morning,';
  static const agentName = 'Priya Sharma';
  static const greetingSubtitle = 'Have a productive day ahead!';
  static const summaryTitle = 'Today\'s Summary';
  static const summaryDate = '22 May 2025';

  static const summaryMetrics = [
    _TelecallerSummaryMetricData(
      icon: Icons.groups_rounded,
      imagePath: 'assets/tems_margin.png',
      value: '35',
      label: 'Assigned\nLeads',
      iconBg: Color(0xFFEAF1FF),
      iconColor: Color(0xFF4F73FF),
      accent: Color(0xFF4F73FF),
    ),
    _TelecallerSummaryMetricData(
      icon: Icons.wifi_calling_3_rounded,
      imagePath: 'assets/calling_like_wifi.png',
      value: '22',
      label: 'Calls\nMade',
      iconBg: Color(0xFFEAF8EF),
      iconColor: Color(0xFF1DBA7A),
      accent: Color(0xFF1DBA7A),
    ),
    _TelecallerSummaryMetricData(
      icon: Icons.assignment_turned_in_outlined,
      imagePath: 'assets/calender.png',
      value: '12',
      label: 'Follow\nUps',
      iconBg: Color(0xFFFFF4EA),
      iconColor: Color(0xFFFF8A1D),
      accent: Color(0xFFFF8A1D),
    ),
    _TelecallerSummaryMetricData(
      icon: Icons.apartment_outlined,
      imagePath: 'assets/keyword.png',
      value: '3',
      label: 'Site\nVisits',
      iconBg: Color(0xFFF4EBFF),
      iconColor: Color(0xFF8B5CF6),
      accent: Color(0xFF8B5CF6),
    ),
    _TelecallerSummaryMetricData(
      icon: Icons.show_chart_rounded,
      imagePath: 'assets/graph.png',
      value: '2',
      label: 'Conversions',
      iconBg: Color(0xFFEAFBF7),
      iconColor: Color(0xFF14B8A6),
      accent: Color(0xFF14B8A6),
    ),
  ];

  static const quickActions = [
    _TelecallerQuickActionData(
      icon: Icons.person_rounded,
      imagePath: 'assets/background_admin.png',
      label: 'New Leads',
      bgColor: Color(0xFFFF7A1A),
      routeName: AppRouter.telecallerDashboard,
    ),
    _TelecallerQuickActionData(
      icon: Icons.call_rounded,
      imagePath: 'assets/blue_background_call.png',
      label: 'Follow Ups',
      bgColor: Color(0xFF112C5A),
    ),
    _TelecallerQuickActionData(
      icon: Icons.apartment_outlined,
      imagePath: 'assets/yellow_typing.png',
      label: 'Site Visits',
      bgColor: Color(0xFFFF7A1A),
    ),
    _TelecallerQuickActionData(
      icon: Icons.notifications_rounded,
      imagePath: 'assets/blue_notification.png',
      label: 'Notifications',
      bgColor: Color(0xFF112C5A),
    ),
  ];

  static const pipelineItems = [
    _TelecallerPipelineData(
      label: 'New\nLeads',
      value: '15',
      color: Color(0xFF2563EB),
      backgroundColor: Color(0xFFF2F7FF),
    ),
    _TelecallerPipelineData(
      label: 'Hot\nLeads',
      value: '8',
      color: Color(0xFFFF6B00),
      backgroundColor: Colors.transparent,
    ),
    _TelecallerPipelineData(
      label: 'Interested',
      value: '5',
      color: Color(0xFF10B981),
      backgroundColor: Colors.transparent,
    ),
    _TelecallerPipelineData(
      label: 'Cold\nLeads',
      value: '4',
      color: Color(0xFF8B5CF6),
      backgroundColor: Colors.transparent,
    ),
    _TelecallerPipelineData(
      label: 'Lost',
      value: '3',
      color: Color(0xFFEF4444),
      backgroundColor: Colors.transparent,
    ),
  ];

  static const followUps = [
    _TelecallerFollowUpData(
      name: 'Rahul Mehta',
      project: 'Trueroot Heights',
      status: 'Hot Lead',
      time: '11:00 AM',
      avatarBg: Color(0xFFFFF4EA),
      avatarColor: Color(0xFFFFA94D),
      statusBg: Color(0xFFFFF1E7),
      statusColor: Color(0xFFFF6B00),
    ),
    _TelecallerFollowUpData(
      name: 'Neha Kapoor',
      project: 'Trueroot Urbania',
      status: 'Interested',
      time: '12:30 PM',
      avatarBg: Color(0xFFEAFBF2),
      avatarColor: Color(0xFF22C55E),
      statusBg: Color(0xFFEAFBF2),
      statusColor: Color(0xFF10B981),
    ),
    _TelecallerFollowUpData(
      name: 'Amit Sharma',
      project: 'Trueroot Homes',
      status: 'New Lead',
      time: '03:00 PM',
      avatarBg: Color(0xFFF3E8FF),
      avatarColor: Color(0xFF8B5CF6),
      statusBg: Color(0xFFEAF2FF),
      statusColor: Color(0xFF2563EB),
    ),
    _TelecallerFollowUpData(
      name: 'Sneha Iyer',
      project: 'Trueroot Skyview',
      status: 'Hot Lead',
      time: '04:30 PM',
      avatarBg: Color(0xFFEAF2FF),
      avatarColor: Color(0xFF2563EB),
      statusBg: Color(0xFFFFF1E7),
      statusColor: Color(0xFFFF6B00),
    ),
  ];
}

class _TelecallerSummaryMetricData {
  const _TelecallerSummaryMetricData({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.accent,
    this.imagePath,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color accent;
  final String? imagePath;
}

class _TelecallerQuickActionData {
  const _TelecallerQuickActionData({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.imagePath,
    this.routeName,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final String? imagePath;
  final String? routeName;
}

class _TelecallerPipelineData {
  const _TelecallerPipelineData({
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color backgroundColor;
}

class _TelecallerFollowUpData {
  const _TelecallerFollowUpData({
    required this.name,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;
}

class _TelecallerHeroNotification extends StatelessWidget {
  const _TelecallerHeroNotification();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34.w,
      height: 34.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 19.sp,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: -1.w,
            top: -3.h,
            child: Container(
              width: 18.w,
              height: 18.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.orangeAccent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navy, width: 1),
              ),
              child: Text(
                '3',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelecallerSummaryMetric extends StatelessWidget {
  const _TelecallerSummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.accent,
    this.imagePath,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color accent;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: imagePath != null ? Colors.transparent : iconBg,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: imagePath != null
              ? Center(
                  child: SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: Image.asset(imagePath!, fit: BoxFit.contain),
                  ),
                )
              : Icon(icon, size: 20.sp, color: iconColor),
        ),
        SizedBox(height: 12.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.25,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            height: 1.56,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 18.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
      ],
    );
  }
}

class _TelecallerQuickActionsSection extends StatelessWidget {
  const _TelecallerQuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.33,
                    color: const Color(0xFFF97316),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: AppColors.orangeAccent,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (
              var i = 0;
              i < _TelecallerDashboardData.quickActions.length;
              i++
            ) ...[
              Expanded(
                child: _TelecallerQuickActionTile(
                  icon: _TelecallerDashboardData.quickActions[i].icon,
                  label: _TelecallerDashboardData.quickActions[i].label,
                  bgColor: _TelecallerDashboardData.quickActions[i].bgColor,
                  imagePath: _TelecallerDashboardData.quickActions[i].imagePath,
                  onTap:
                      _TelecallerDashboardData.quickActions[i].routeName != null
                      ? () => Navigator.of(context).pushNamed(
                          _TelecallerDashboardData.quickActions[i].routeName!,
                        )
                      : null,
                ),
              ),
              if (i != _TelecallerDashboardData.quickActions.length - 1)
                SizedBox(width: 12.w),
            ],
          ],
        ),
      ],
    );
  }
}

class _TelecallerQuickActionTile extends StatelessWidget {
  const _TelecallerQuickActionTile({
    required this.icon,
    required this.label,
    required this.bgColor,
    this.imagePath,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final String? imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 124.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFDDE6F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44.w,
              height: 44.w,
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath!,
                        width: 44.w,
                        height: 44.w,
                        fit: BoxFit.contain,
                      )
                    : CircleAvatar(
                        radius: 22.r,
                        backgroundColor: bgColor,
                        child: Icon(icon, size: 20.sp, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 30.h,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelecallerLeadPipelinesSection extends StatelessWidget {
  const _TelecallerLeadPipelinesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Lead Pipelines',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Pipeline',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orangeAccent,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: AppColors.orangeAccent,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFDDE6F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  for (
                    var i = 0;
                    i < _TelecallerDashboardData.pipelineItems.length;
                    i++
                  ) ...[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: _TelecallerDashboardData
                              .pipelineItems[i]
                              .backgroundColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _TelecallerDashboardData.pipelineItems[i].label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                                color: _TelecallerDashboardData
                                    .pipelineItems[i]
                                    .color,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _TelecallerDashboardData.pipelineItems[i].value,
                              style: GoogleFonts.inter(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i != _TelecallerDashboardData.pipelineItems.length - 1)
                      SizedBox(width: 10.w),
                  ],
                ],
              ),
              SizedBox(height: 20.h),
              const _TelecallerPipelineTrack(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TelecallerPipelineTrack extends StatelessWidget {
  const _TelecallerPipelineTrack();

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFFFF6B00),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
    ];

    return SizedBox(
      height: 22.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              for (var i = 0; i < colors.length - 1; i++)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 4.h, color: colors[i]),
                      ),
                      Expanded(
                        child: Container(height: 4.h, color: colors[i + 1]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < colors.length; i++) ...[
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: i == colors.length - 1 ? colors[i] : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[i], width: 3),
                  ),
                  child: i == colors.length - 1
                      ? Icon(
                          Icons.close_rounded,
                          size: 10.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (i != colors.length - 1) const Spacer(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TelecallerTodayFollowUpsSection extends StatelessWidget {
  const _TelecallerTodayFollowUpsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Today\'s Follow Ups',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.33,
                    letterSpacing: 0,
                    color: const Color(0xFFF97316),
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: AppColors.orangeAccent,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFDDE6F0)),
          ),
          child: Column(
            children: [
              for (
                var i = 0;
                i < _TelecallerDashboardData.followUps.length;
                i++
              ) ...[
                _TelecallerFollowUpRow(
                  name: _TelecallerDashboardData.followUps[i].name,
                  project: _TelecallerDashboardData.followUps[i].project,
                  status: _TelecallerDashboardData.followUps[i].status,
                  time: _TelecallerDashboardData.followUps[i].time,
                  avatarBg: _TelecallerDashboardData.followUps[i].avatarBg,
                  avatarColor:
                      _TelecallerDashboardData.followUps[i].avatarColor,
                  statusBg: _TelecallerDashboardData.followUps[i].statusBg,
                  statusColor:
                      _TelecallerDashboardData.followUps[i].statusColor,
                ),
                if (i != _TelecallerDashboardData.followUps.length - 1)
                  Divider(height: 1, color: const Color(0xFFEAEFF5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TelecallerFollowUpRow extends StatelessWidget {
  const _TelecallerFollowUpRow({
    required this.name,
    required this.project,
    required this.status,
    required this.time,
    required this.avatarBg,
    required this.avatarColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String name;
  final String project;
  final String status;
  final String time;
  final Color avatarBg;
  final Color avatarColor;
  final Color statusBg;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: avatarBg,
            child: Icon(Icons.person, size: 18.sp, color: avatarColor),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  project,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(width: 12.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15.sp,
                color: const Color(0xFF94A3B8),
              ),
              SizedBox(width: 4.w),
              Text(
                time,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 48.w,
                height: 48.w,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Image.asset(
                    'assets/whats_app.png',
                    fit: BoxFit.contain,
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

class _TelecallerLeadOverviewScreen extends StatelessWidget {
  const _TelecallerLeadOverviewScreen();

  @override
  Widget build(BuildContext context) {
    final activeTab = context.watch<DashboardProvider>().communicationTab;
    final body = switch (activeTab) {
      0 => const _TelecallerLeadOverviewBody(),
      1 => const LeadActivityTimelineSection(),
      2 => const _CommunicationHistorySection(),
      3 => const _TelecallerNotesSection(),
      4 => const TelecallerDocumentsTabContent(),
      5 => const _TelecallerFollowUpTabContent(),
      _ => const _TelecallerLeadOverviewBody(),
    };

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TelecallerLeadOverviewHeader(),
          SizedBox(height: 132.h),
          const _TelecallerLeadTabs(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelecallerLeadOverviewHeader extends StatelessWidget {
  const _TelecallerLeadOverviewHeader();

  @override
  Widget build(BuildContext context) {
    final activeTab = context.watch<DashboardProvider>().communicationTab;
    final title = switch (activeTab) {
      0 => 'Lead Overview',
      1 => 'Lead Timeline',
      2 => 'Lead Communication',
      3 => 'Note Details',
      4 => 'Lead Documents',
      5 => 'Lead Follow-up',
      _ => 'Lead Overview',
    };

    return SizedBox(
      height: 206.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            right: 16.w,
            top: 60.h,
            child: SizedBox(
              height: 36.h,
              child: Row(
                children: [
                  SizedBox(
                    width: 44.w,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44.w,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: -112.h,
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 18.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: const Color(0xFFFFF3EB),
                    child: Text(
                      'RM',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Rahul Mehta',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E7),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(
                                  color: const Color(0xFFFFC89B),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department_outlined,
                                    size: 14.sp,
                                    color: const Color(0xFFF97316),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Hot Lead',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF97316),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Icon(
                              Icons.call_outlined,
                              size: 15.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '+91 98765 43210',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                            Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Container(height: 1, color: const Color(0xFFE6ECF5)),
                        SizedBox(height: 12.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.apartment_outlined,
                              size: 16.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                'Project: Trueroot Heights',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sell_outlined,
                              size: 16.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                '3 BHK | Rs 75 L - Rs 90 L | Noida Extension',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LEAD ID',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'LD-12568',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 15.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Assigned On',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '22 May 2025',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '10:30 AM',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
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

class _TelecallerLeadTabs extends StatelessWidget {
  const _TelecallerLeadTabs();

  @override
  Widget build(BuildContext context) {
    final activeTab = context.watch<DashboardProvider>().communicationTab;
    final tabs = const [
      (Icons.grid_view_rounded, 'Overview', 0),
      (Icons.timelapse_outlined, 'Timeline', 1),
      (Icons.campaign_outlined, 'Communication', 2),
      (Icons.sticky_note_2_outlined, 'Notes', 3),
      (Icons.folder_outlined, 'Documents', 4),
      (Icons.calendar_month_outlined, 'Follow-up', 5),
    ];

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final active = tab.$3 == activeTab;
            return Padding(
              padding: EdgeInsets.only(right: 22.w),
              child: InkWell(
                onTap: () => context
                    .read<DashboardProvider>()
                    .setCommunicationTab(tab.$3),
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.$1,
                            size: 18.sp,
                            color: active
                                ? const Color(0xFFFF6B00)
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            tab.$2,
                            style: GoogleFonts.inter(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? const Color(0xFFFF6B00)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        width: 88.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFFF6B00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TelecallerLeadOverviewBody extends StatelessWidget {
  const _TelecallerLeadOverviewBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 16.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE8EDF5)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.04),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [_TelecallerLeadSummaryBlock()],
            ),
          ),
          SizedBox(height: 16.h),
          const _TelecallerLeadDetailsCard(),
          SizedBox(height: 16.h),
          const _TelecallerRecentActivityCard(),
        ],
      ),
    );
  }
}

class _TelecallerLeadSummaryBlock extends StatelessWidget {
  const _TelecallerLeadSummaryBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Text(
            'Lead Summary',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF121C2A),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        const Row(
          children: [
            Expanded(
              child: _OverviewMetricTile(
                icon: Icons.person_outline_rounded,
                iconColor: AppColors.vividBlue,
                backgroundColor: Color(0xFFF6F8FC),
                label: 'Lead Source',
                value: 'Website',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _OverviewMetricTile(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.greenStrong,
                backgroundColor: Color(0xFFF6F8FC),
                label: 'Lead Status',
                value: 'Qualified',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Row(
          children: [
            Expanded(
              child: _OverviewMetricTile(
                icon: Icons.flag_outlined,
                iconColor: AppColors.orangeStrong,
                backgroundColor: Color(0xFFFFF6EF),
                label: 'Lead Priority',
                value: 'High',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _OverviewMetricTile(
                icon: Icons.person_pin_circle_outlined,
                iconColor: AppColors.purpleDeep,
                backgroundColor: Color(0xFFF8F1FF),
                label: 'Lead Owner',
                value: 'Amit Verma',
                subtitle: '(Sales Executive)',
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        const _OverviewTimelineTile(
          icon: Icons.event_outlined,
          iconColor: AppColors.vividBlue,
          label: 'First Contact',
          date: '22 May 2025',
          time: '11:15 AM',
        ),
        SizedBox(height: 10.h),
        const _OverviewTimelineTile(
          icon: Icons.history_rounded,
          iconColor: AppColors.vividBlue,
          label: 'Last Contact',
          date: '24 May 2025',
          time: '11:45 AM',
        ),
        SizedBox(height: 10.h),
        const _OverviewTimelineTile(
          icon: Icons.notifications_active_outlined,
          iconColor: AppColors.vividBlue,
          label: 'Next Follow-up',
          date: '24 May 2025',
          time: '11:30 AM',
        ),
      ],
    );
  }
}

class _TelecallerFollowUpTabContent extends StatelessWidget {
  const _TelecallerFollowUpTabContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 22.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Follow-up',
              style: GoogleFonts.inter(
                fontSize: _leadFollowUpFontSize(17).sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _FollowUpField(
                    icon: Icons.calendar_today_outlined,
                    label: 'Follow-up Date',
                    value: '24 May 2025',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FollowUpField(
                    icon: Icons.access_time_rounded,
                    label: 'Follow-up Time',
                    value: '11:30 AM',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _FollowUpField(
                    icon: Icons.call_outlined,
                    label: 'Follow-up Type',
                    value: 'Phone Call',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FollowUpField(
                    icon: Icons.outlined_flag_rounded,
                    label: 'Priority',
                    value: 'High',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _FollowUpField(
              icon: Icons.notifications_none_rounded,
              label: 'Reminder',
              value: '15 Minutes Before',
              fullWidth: true,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFD8E1EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 16.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Remarks / Notes (Optional)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: _leadFollowUpFontSize(14).sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Customer is looking for 3 BHK in Noida\nExtension.\nInterested in visits this weekend.',
                    style: GoogleFonts.inter(
                      fontSize: _leadFollowUpFontSize(16).sp,
                      height: 1.45,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '96/200',
                      style: GoogleFonts.inter(
                        fontSize: _leadFollowUpFontSize(14).sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            Text(
              'Preferred Mode',
              style: GoogleFonts.inter(
                fontSize: _leadFollowUpFontSize(16).sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'How would you like to connect?',
              style: GoogleFonts.inter(
                fontSize: _leadFollowUpFontSize(14).sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4B5563),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _FollowUpModeButton(
                    icon: Icons.call_outlined,
                    label: 'Phone Call',
                    active: true,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FollowUpModeButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'WhatsApp',
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE8EDF5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: -1,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Previous Follow-ups',
                          style: GoogleFonts.inter(
                            fontSize: _leadFollowUpFontSize(16).sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: _leadFollowUpFontSize(15).sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFF6B00),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18.sp,
                        color: const Color(0xFFFF6B00),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  const _PreviousFollowUpItem(
                    dotColor: Color(0xFF10B981),
                    bubbleColor: Color(0xFFE8F8F1),
                    icon: Icons.call,
                    iconColor: Color(0xFF10B981),
                    title: 'First Call',
                    dateTime: '22 May 2025 • 11:15 AM',
                    status: 'Completed',
                    statusColor: Color(0xFF10B981),
                    statusBg: Color(0xFFE8F8F1),
                    note: 'Spoke for 04:32',
                  ),
                  SizedBox(height: 14.h),
                  const _PreviousFollowUpItem(
                    dotColor: Color(0xFFFF6B00),
                    bubbleColor: Color(0xFFFFF1E7),
                    icon: Icons.calendar_today_outlined,
                    iconColor: Color(0xFFFF6B00),
                    title: 'Follow-up Scheduled',
                    dateTime: '23 May 2025 • 11:00 AM',
                    status: 'Upcoming',
                    statusColor: Color(0xFF2563EB),
                    statusBg: Color(0xFFEAF2FF),
                  ),
                  SizedBox(height: 14.h),
                  const _PreviousFollowUpItem(
                    dotColor: Color(0xFF2563EB),
                    bubbleColor: Color(0xFFEAF2FF),
                    icon: Icons.person_add_alt_1_rounded,
                    iconColor: Color(0xFF2563EB),
                    title: 'New Lead Assigned',
                    dateTime: '22 May 2025 •10:30 AM',
                    status: 'Completed',
                    statusColor: Color(0xFF10B981),
                    statusBg: Color(0xFFE8F8F1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: _FollowUpActionButton(
                    label: 'Schedule for Later',
                    icon: Icons.calendar_today_outlined,
                    filled: false,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _FollowUpActionButton(
                    label: 'Schedule Follow-up',
                    icon: Icons.event_note_outlined,
                    filled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const double _leadFollowUpFontScale = 1.1;

double _leadFollowUpFontSize(double size) => size * _leadFollowUpFontScale;

class _FollowUpField extends StatelessWidget {
  const _FollowUpField({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      constraints: BoxConstraints(minHeight: fullWidth ? 58.h : 64.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: _leadFollowUpFontSize(12).sp,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: _leadFollowUpFontSize(14).sp,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.sp,
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }
}

class _FollowUpModeButton extends StatelessWidget {
  const _FollowUpModeButton({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: active ? const Color(0xFFFF6B00) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: active ? const Color(0xFFFF6B00) : const Color(0xFF22C55E),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: _leadFollowUpFontSize(15).sp,
                fontWeight: FontWeight.w500,
                color: active
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFF4B5563),
              ),
            ),
          ),
          if (active) ...[
            SizedBox(width: 6.w),
            Icon(
              Icons.check_circle,
              size: 16.sp,
              color: const Color(0xFFFF6B00),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviousFollowUpItem extends StatelessWidget {
  const _PreviousFollowUpItem({
    required this.dotColor,
    required this.bubbleColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.dateTime,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    this.note,
  });

  final Color dotColor;
  final Color bubbleColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String dateTime;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final normalizedDateTime = dateTime
        .replaceAll('\n', ' ')
        .replaceAll('â€¢', ' ')
        .replaceAll('•', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.h, right: 10.w),
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(color: bubbleColor, shape: BoxShape.circle),
          child: Icon(icon, size: 18.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: _leadFollowUpFontSize(16).sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                normalizedDateTime,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: _leadFollowUpFontSize(11).sp,
                  height: 1.35,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: _leadFollowUpFontSize(14).sp,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
            if (note != null) ...[
              SizedBox(height: 6.h),
              Text(
                note!,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: _leadFollowUpFontSize(14).sp,
                  height: 1.35,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18.sp,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}

class _FollowUpActionButton extends StatelessWidget {
  const _FollowUpActionButton({
    required this.label,
    required this.icon,
    required this.filled,
  });

  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFFF6B00);
    final blue = const Color(0xFF2563EB);
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: filled ? accent : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: filled ? accent : blue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: filled ? Colors.white : blue),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: _leadFollowUpFontSize(15).sp,
                fontWeight: FontWeight.w500,
                color: filled ? Colors.white : blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TelecallerLeadDetailsCard extends StatelessWidget {
  const _TelecallerLeadDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C6D1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // rgba(0,0,0,0.05)
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lead Details',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: const Color(0xFF121C2A),
            ),
          ),
          SizedBox(height: 12.h),
          const _LeadDetailsRow(
            icon: Icons.home_outlined,
            label: 'Interested\nIn',
            value: '3 BHK Apartment',
          ),
          const _LeadDetailsDivider(),
          const _LeadDetailsRow(
            icon: Icons.currency_rupee_rounded,
            label: 'Budget',
            value: 'Rs 75 L - Rs 90 L',
          ),
          const _LeadDetailsDivider(),
          const _LeadDetailsRow(
            icon: Icons.place_outlined,
            label: 'Preferred\nLocation',
            value: 'Noida Extension',
          ),
          const _LeadDetailsDivider(),
          const _LeadDetailsRow(
            icon: Icons.access_time_outlined,
            label: 'Possession\nTimeline',
            value: 'Within 6 Months',
          ),
          const _LeadDetailsDivider(),
          const _LeadDetailsRow(
            icon: Icons.pie_chart_outline_rounded,
            label: 'Purpose',
            value: 'End Use',
          ),
          const _LeadDetailsDivider(),
          const _LeadDetailsRow(
            icon: Icons.subject_outlined,
            label: 'Remarks',
            value:
                'Looking for a 3 BHK in\nNoida Extension. Prefers\ngood connectivity and\nschools nearby.',
            alignTop: true,
          ),
        ],
      ),
    );
  }
}

class _LeadDetailsRow extends StatelessWidget {
  const _LeadDetailsRow({
    required this.icon,
    required this.label,
    required this.value,
    this.alignTop = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: alignTop
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 2.h : 0),
            child: SizedBox(
              width: 20.w,
              child: Icon(icon, size: 18.sp, color: const Color(0xFF4B5563)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400, // normal
                height: 1.43,
                letterSpacing: 0,
                color: const Color(0xFF43474F),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            flex: 7,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
                color: const Color(0xFF121C2A),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: alignTop ? 2.h : 0),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadDetailsDivider extends StatelessWidget {
  const _LeadDetailsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFD8E0EA));
  }
}

class _TelecallerRecentActivityCard extends StatelessWidget {
  const _TelecallerRecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFCCD7E5)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Activity',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: const Color(0xFF121C2A),
                      ),
                    ),
                  ),
                  Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              const _RecentActivityRow(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Color(0xFF10B981),
                iconBackground: Color(0xFFE8FBF4),
                title: 'WhatsApp Message Sent',
                subtitle: 'Hi Rahul, sharing details of 3 BHK\noptions.',
                date: '24 May\n2025',
                time: '11:45 AM',
              ),
              const _RecentActivityConnector(),
              const _RecentActivityRow(
                icon: Icons.call_outlined,
                iconColor: Color(0xFF2563EB),
                iconBackground: Color(0xFFEAF2FF),
                title: 'Outgoing Call',
                subtitle: 'You called Rahul',
                date: '24 May 2025',
                time: '11:15 AM',
              ),
              const _RecentActivityConnector(),
              const _RecentActivityRow(
                icon: Icons.calendar_today_outlined,
                iconColor: Color(0xFFFF6B00),
                iconBackground: Color(0xFFFFF1E8),
                title: 'Follow-up Scheduled',
                subtitle: 'Follow-up with Rahul',
                date: '24 May 2025',
                time: '11:30 AM',
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Row(
          children: const [
            Expanded(
              child: _OverviewActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: Color(0xFF10B981),
                label: 'WhatsApp',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _OverviewActionButton(
                icon: Icons.call_outlined,
                iconColor: Color(0xFF2563EB),
                label: 'Call',
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          children: const [
            Expanded(
              child: _OverviewActionButton(
                icon: Icons.calendar_today_outlined,
                iconColor: Color(0xFFFF6B00),
                label: 'Schedule',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _OverviewActionButton(
                icon: Icons.note_add_outlined,
                iconColor: Color(0xFF6B7280),
                label: 'Add Note',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1.h, right: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400, // normal
                    height: 1.43,
                    color: const Color(0xFF121C2A),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 82.w,
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  time,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: const Color(0xFF43474F),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18.sp,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _RecentActivityConnector extends StatelessWidget {
  const _RecentActivityConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Container(
        width: 1.5,
        height: 20.h,
        color: const Color(0xFFD8E0EA),
      ),
    );
  }
}

class _OverviewActionButton extends StatelessWidget {
  const _OverviewActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFCCD7E5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
              color: const Color(0xFF121C2A),
            ),
          ),

          // style: GoogleFonts.inter(
          //   fontSize: 15.sp,
          //   fontWeight: FontWeight.w600,
          //   color: const Color(0xFF1F2937),
          // ),
          //  ),
        ],
      ),
    );
  }
}

class _OverviewMetricTile extends StatelessWidget {
  const _OverviewMetricTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 14.h, 10.w, 14.h),
      constraints: BoxConstraints(minHeight: 114.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      // decoration: BoxDecoration(
      //   color: backgroundColor,
      //   borderRadius: BorderRadius.circular(12.r),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp, color: iconColor),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400, // normal
              height: 1.5,
              color: const Color(0xFF43474F),
            ),
          ),

          SizedBox(height: 5.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400, // normal
              height: 1.5,
              color: const Color(0xFF121C2A),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 3.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewTimelineTile extends StatelessWidget {
  const _OverviewTimelineTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.date,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6), // fully rounded pill
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, size: 14.sp, color: iconColor),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400, // normal
                    height: 1.5,
                    color: const Color(0xFF43474F),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF6B7280),
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

class _CommunicationHistorySection extends StatelessWidget {
  const _CommunicationHistorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 0),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Communication History',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      height: 1.43, // line-height: 1.43
                      color: Color(0xFF111827),
                    ),
                  ),
                ),

                _CircleIconButton(icon: Icons.search),
                SizedBox(width: 10.w),
                _CircleIconButton(icon: Icons.filter_alt_outlined),
              ],
            ),
            SizedBox(height: 14.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _HistoryChip(label: 'All', active: true),
                  _HistoryChip(label: 'Calls'),
                  _HistoryChip(label: 'WhatsApp'),
                  _HistoryChip(label: 'SMS'),
                  _HistoryChip(label: 'Emails'),
                ],
              ),
            ),
            SizedBox(height: 22.h),
            Center(child: const _TimelineDatePill(label: '24 May 2025')),
            SizedBox(height: 18.h),
            const _WhatsAppTimelineCard(),
            SizedBox(height: 20.h),
            const _OutgoingCallTimelineCard(),
            SizedBox(height: 18.h),
            const Center(child: _TimelineDatePill(label: '22 May 2025')),
            SizedBox(height: 18.h),
            const _IncomingCallTimelineCard(),
            SizedBox(height: 18.h),
            const Center(child: _TimelineDatePill(label: '21 May 2025')),
            SizedBox(height: 18.h),
            const _WhatsAppFollowupTimelineCard(),
            SizedBox(height: 18.h),
            const Center(child: _TimelineDatePill(label: '20 May 2025')),
            SizedBox(height: 18.h),
            const _EmailSentTimelineCard(),
            SizedBox(height: 18.h),
            const Center(child: _TimelineDatePill(label: '19 May 2025')),
            SizedBox(height: 18.h),
            const _SmsSentTimelineCard(),
          ],
        ),
      ),
    );
  }
}

class _TelecallerNotesSection extends StatelessWidget {
  const _TelecallerNotesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE8EDF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
              child: Text(
                'Note Information',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: const Color(0xFF002149),
                ),
              ),
            ),
            Container(height: 1, color: const Color(0xFFF0F4F9)),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _NoteMetaRow(
                    icon: Icons.description_outlined,
                    label: 'Note Title',
                    value: 'Customer Interested in 3 BHK',
                    trailing: _NoteTitleActions(),
                  ),
                  SizedBox(height: 18.h),
                  const _NoteMetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Note Date & Time',
                    value: '22 May 2025 | 11:20 AM',
                  ),
                  SizedBox(height: 18.h),
                  const _NoteMetaRow(
                    icon: Icons.person_outline,
                    label: 'Added By',
                    value: 'Amit Verma',
                    trailingText: ' (Sales Executive)',
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note Content',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400, // normal
                            height: 1.5,
                            color: const Color(0xFF002149),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Spoke with Rahul regarding his requirement.\nHe is looking for a 3 BHK apartment in Noida\nExtension within Rs 75L - Rs 90L budget.\nHe is interested in visiting the site this\nweekend.\nRequested good connectivity to metro and\nnearby schools.\nWill share options and schedule a follow-up.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400, // normal
                            height: 1.63,
                            color: const Color(0xFF43474F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const _NoteAttachmentSection(),
                  SizedBox(height: 18.h),
                  const _NoteActivitySection(),
                  SizedBox(height: 18.h),
                  const _NoteActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineDatePill extends StatelessWidget {
  const _TimelineDatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400, // normal
          height: 1.43,
          color: const Color(0xFF121C2A),
        ),
      ),
    );
  }
}

class _NoteMetaRow extends StatelessWidget {
  const _NoteMetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FB),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400, // normal
                  height: 1.5,
                  color: const Color(0xFF43474F),
                ),
              ),

              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF13264F),
                      ),
                    ),
                    if (trailingText != null)
                      TextSpan(
                        text: trailingText,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 12.w), trailing!],
      ],
    );
  }
}

class _NoteTitleActions extends StatelessWidget {
  const _NoteTitleActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF3),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Text(
            'Internal Note',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF16A34A),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 14.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 4.w),
            Text(
              'Edit Note',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoteAttachmentSection extends StatelessWidget {
  const _NoteAttachmentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (2)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: const Color(0xFF002149),
          ),
        ),

        SizedBox(height: 14.h),
        const _AttachmentCard(
          icon: Icons.picture_as_pdf,
          iconColor: Color(0xFFEF4444),
          iconBg: Color(0xFFFEF2F2),
          title: 'Trueroot_Heights_Brochure.',
          subtitle: 'PDF | 1.2 MB',
        ),
        SizedBox(height: 12.h),
        const _AttachmentCard(
          icon: Icons.image_outlined,
          iconColor: Color(0xFF22C55E),
          iconBg: Color(0xFFF0FDF4),
          title: 'Site_Location_Map.jpg',
          subtitle: 'JPG | 845 KB',
        ),
        SizedBox(height: 12.h),
        _DottedUploadAttachmentBox(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_upload_rounded,
                    color: const Color(0xFF2563EB),
                    size: 34.sp,
                  ),
                  SizedBox(width: 20.w),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Attachment',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: const Color(0xFF002149),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'PDF, JPG, PNG up to 10 MB',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
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
      ],
    );
  }
}

class _DottedUploadAttachmentBox extends StatelessWidget {
  const _DottedUploadAttachmentBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = 8.r;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: DottedLine(
                      lineLength: constraints.maxWidth,
                      dashColor: const Color(0xFFAAC7FF),
                      dashGapLength: 4.w,
                      dashLength: 4.w,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: constraints.maxHeight,
                      dashColor: const Color(0xFFAAC7FF),
                      dashGapLength: 4.h,
                      dashLength: 4.h,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: DottedLine(
                      direction: Axis.vertical,
                      lineLength: constraints.maxHeight,
                      dashColor: const Color(0xFFAAC7FF),
                      dashGapLength: 4.h,
                      dashLength: 4.h,
                      lineThickness: 1,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DottedLine(
                      lineLength: constraints.maxWidth,
                      dashColor: const Color(0xFFAAC7FF),
                      dashGapLength: 4.w,
                      dashLength: 4.w,
                      lineThickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 22.h,
                    ),
                    child: Center(child: child),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF13264F),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _SmallCircleAction(icon: Icons.download_outlined),
          SizedBox(width: 10.w),
          _SmallCircleAction(icon: Icons.remove_red_eye_outlined),
        ],
      ),
    );
  }
}

class _SmallCircleAction extends StatelessWidget {
  const _SmallCircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD7DFEC)),
      ),
      child: Icon(icon, size: 18.sp, color: const Color(0xFF13315C)),
    );
  }
}

class _NoteActivitySection extends StatelessWidget {
  const _NoteActivitySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Note Activity',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: const Color(0xFF002149),
            ),
          ),

          SizedBox(height: 16.h),
          const _NoteActivityItem(
            lineColor: Color(0xFFD7E3F4),
            dotColor: Color(0xFF22C55E),
            icon: Icons.edit,
            iconColor: Color(0xFF16A34A),
            iconBg: Color(0xFFECFDF3),
            title: 'Note Created',
            meta: 'Amit Verma • 22 May 2025 • 11:20 AM',
          ),
          const _NoteActivityItem(
            lineColor: Color(0xFFD7E3F4),
            dotColor: Color(0xFF3B82F6),
            icon: Icons.edit,
            iconColor: Color(0xFF2563EB),
            iconBg: Color(0xFFEFF6FF),
            title: 'Note Updated',
            meta: 'Amit Verma • 22 May 2025 • 11:35 AM',
          ),
          const _NoteActivityItem(
            lineColor: Color(0x00000000),
            dotColor: Color(0xFFCBD5E1),
            icon: Icons.remove_red_eye_outlined,
            iconColor: Color(0xFF64748B),
            iconBg: Color(0xFFF8FAFC),
            title: 'Note Viewed',
            meta: 'Neha Kapoor • 22 May 2025 • 12:05 PM',
          ),
        ],
      ),
    );
  }
}

class _NoteActivityItem extends StatelessWidget {
  const _NoteActivityItem({
    required this.lineColor,
    required this.dotColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.meta,
  });

  final Color lineColor;
  final Color dotColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22.w,
            child: Column(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 4.h),
                Expanded(child: Container(width: 1.5, color: lineColor)),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Icon(icon, size: 16.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 18.h, top: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: const Color(0xFF002149),
                    ),
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    meta,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteActionButtons extends StatelessWidget {
  const _NoteActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              size: 18.sp,
              color: const Color(0xFF2F5BFF),
            ),
            label: Text(
              'Share Note',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: const Color(0xFF002149),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Color(0xFFAAC7FF), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_circle, size: 18.sp, color: AppColors.white),
            label: Text(
              'Add Follow-up',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A10),

              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD7DFEC)),
      ),
      child: Icon(icon, size: 19.sp, color: const Color(0xFF64748B)),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFFF3EA) : AppColors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active ? const Color(0xFFFF6B00) : const Color(0xFFD7DFEC),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.33,
          color: active ? const Color(0xFFFF6B00) : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _WhatsAppTimelineCard extends StatelessWidget {
  const _WhatsAppTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 168.h,
                color: const Color(0xFFD8E2F0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8FAEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat,
                      size: 12.sp,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'WhatsApp Message',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '11:45 AM',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.done, size: 17.sp, color: const Color(0xFF2563EB)),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hi Rahul, this is Amit from Trueroot Realty.\nSharing details of 3 BHK options in Noida\nExtension.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400, // normal
                    height: 1.33,
                    color: const Color(0xFF43474F),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE3E8F1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E7),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Center(
                        child: Text(
                          'PDF',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
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
                            'Trueroot_Heights_Brochure.pdf',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.33,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '1.2 MB',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFD7DFEC)),
                      ),
                      child: Icon(
                        Icons.download_outlined,
                        size: 18.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutgoingCallTimelineCard extends StatelessWidget {
  const _OutgoingCallTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F2FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 130.h,
                color: const Color(0xFFD8E2F0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9F2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_made,
                      size: 12.sp,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Outgoing Call',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '11:15 AM',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'You called Rahul',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.33,
                  color: const Color(0xFF4B5563),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: 4,
                        child: _CallDetailTile(
                          title: 'Duration',
                          value: '04:32 min',
                          accentColor: Color(0xFF2563EB),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: _CallDetailTile(
                          title: 'Disposition',
                          value: 'Interested',
                          accentColor: Color(0xFF2563EB),
                          showDivider: true,
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: _CallDetailTile(
                          title: 'Notes',
                          value: 'Customer\nshowed interest',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncomingCallTimelineCard extends StatelessWidget {
  const _IncomingCallTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2EAFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 112.h,
                color: const Color(0xFFD8E2F0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2EAFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_received,
                      size: 12.sp,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Incoming Call',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '10:40 AM',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '02:18 min',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Rahul called you',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WhatsAppFollowupTimelineCard extends StatelessWidget {
  const _WhatsAppFollowupTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAEE),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 72.h,
                color: const Color(0xFFD8E2F0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8FAEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat,
                      size: 12.sp,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'WhatsApp Message',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '06:20 PM',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.done, size: 17.sp, color: const Color(0xFF2563EB)),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Thanks for the call. Please share the price details\nand site visit schedule.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.38,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailSentTimelineCard extends StatelessWidget {
  const _EmailSentTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3EA),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B00),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 104.h,
                color: const Color(0xFFD8E2F0),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF3EA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 12.sp,
                      color: const Color(0xFFFF6B00),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Email Sent',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '05:30 PM',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      const _DeliveryStatusChip(label: 'Delivered'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Project details and price list sent to\nrahul.mehta@gmail.com',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.38,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmsSentTimelineCard extends StatelessWidget {
  const _SmsSentTimelineCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34.w,
          child: Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F7FB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F7FB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sms_outlined,
                      size: 12.sp,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'SMS Sent',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        height: 1.33, // line-height: 1.33
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '04:10 PM',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      const _DeliveryStatusChip(label: 'Delivered'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Thank you for contacting Trueroot Realty.\nOur expert will connect with you shortly.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 1.38,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryStatusChip extends StatelessWidget {
  const _DeliveryStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF22C55E),
        ),
      ),
    );
  }
}

class _CallDetailTile extends StatelessWidget {
  const _CallDetailTile({
    required this.title,
    required this.value,
    this.accentColor,
    this.showDivider = false,
  });

  final String title;
  final String value;
  final Color? accentColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                left: BorderSide(color: Color(0xFFD8E2F0)),
                right: BorderSide(color: Color(0xFFD8E2F0)),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              height: 1.35,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            softWrap: true,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: accentColor ?? const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _MetricData(
        'Total Leads',
        '1,248',
        '+12.5%',
        Icons.groups,
        AppColors.vividBlue,
        Color(0xFFEAF2FF),
      ),
      _MetricData(
        'Hot Leads',
        '328',
        '+8.3%',
        Icons.local_fire_department,
        AppColors.orange,
        Color(0xFFFFF4E9),
      ),
      _MetricData(
        'Site Visits',
        '96',
        '+15.2%',
        Icons.calendar_today,
        AppColors.green,
        Color(0xFFEAF8F0),
      ),
      _MetricData(
        'Bookings',
        '42',
        '+10.5%',
        Icons.description,
        AppColors.purple,
        Color(0xFFF4EAFE),
      ),
    ];

    return Row(
      children: List.generate(metrics.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == metrics.length - 1 ? 0 : 8.w,
            ),
            child: GestureDetector(
              onTap: () {
                if (metrics[index].label == 'Site Visits') {
                  Navigator.of(context).pushNamed(AppRouter.siteVisits);
                }
              },
              child: _MetricCard(data: metrics[index]),
            ),
          ),
        );
      }),
    );
  }
}

class _AdminDashboardToolbar extends StatelessWidget {
  const _AdminDashboardToolbar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFC4C6D0), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14.sp,
                  color: const Color(0xFF667085),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '01 May 2025 - 31 May 2025',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                      color: Color(0xFF181C23),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.w),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFC4C6D0), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 14.sp,
                color: const Color(0xFF667085),
              ),
              SizedBox(width: 6.w),
              Text(
                'All Filters',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                  color: Color(0xFF181C23),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminDashboardMetricGrid extends StatelessWidget {
  const _AdminDashboardMetricGrid();

  static const List<_AdminDashboardMetricData> _items = [
    _AdminDashboardMetricData(
      title: 'Total\nLeads',
      value: '5',
      icon: Icons.groups_2_outlined,
      iconColor: Color(0xFF344054),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'New\nLeads',
      value: '5',
      icon: Icons.person_add_alt_1_outlined,
      iconColor: Color(0xFF12B76A),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Assigned',
      value: '5',
      icon: Icons.assignment_ind_outlined,
      iconColor: Color(0xFFF97316),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Unassign',
      value: '0',
      icon: Icons.person_off_outlined,
      iconColor: Color(0xFFEF4444),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Follow-\nup',
      value: '2',
      icon: Icons.event_note_outlined,
      iconColor: Color(0xFF344054),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Missed',
      value: '0',
      icon: Icons.event_busy_outlined,
      iconColor: Color(0xFFEF4444),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Scheduled',
      value: '1',
      icon: Icons.calendar_month_outlined,
      iconColor: Color(0xFF4F46E5),
      accentColor: Color(0xFF111827),
    ),
    _AdminDashboardMetricData(
      title: 'Bookings',
      value: '1',
      icon: Icons.verified_user_outlined,
      iconColor: Color(0xFF0F766E),
      accentColor: Color(0xFF111827),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 4; row++) ...[
          Row(
            children: [
              Expanded(child: _AdminDashboardMetricCard(data: _items[row * 2])),
              SizedBox(width: 12.w),
              Expanded(
                child: _AdminDashboardMetricCard(data: _items[row * 2 + 1]),
              ),
            ],
          ),
          if (row != 3) SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _AdminDashboardMetricCard extends StatelessWidget {
  const _AdminDashboardMetricCard({required this.data});

  final _AdminDashboardMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 112.h),
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E3E3), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 15.sp, color: data.iconColor),
          SizedBox(height: 8.h),
          Text(
            data.title,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.33,
              color: const Color(0xFF74777F),
            ),
          ),
          SizedBox(height: 10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                height: 1,
                color: data.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminRevenueAndCompletedRow extends StatelessWidget {
  const _AdminRevenueAndCompletedRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _AdminDashboardMetricCard(
            data: _AdminDashboardMetricData(
              title: 'Revenue Pipeline',
              value: '\u20B9 12,00,000',
              icon: Icons.currency_rupee_outlined,
              iconColor: Color(0xFFF97316),
              accentColor: Color(0xFF111827),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _AdminDashboardMetricCard(
            data: _AdminDashboardMetricData(
              title: 'Completed',
              value: '2',
              icon: Icons.check_circle_outline_rounded,
              iconColor: Color(0xFF12B76A),
              accentColor: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminLeadsBySourceCard extends StatelessWidget {
  const _AdminLeadsBySourceCard();

  static const List<_AdminLeadSourceData> _sources = [
    _AdminLeadSourceData('Referral', '1 (20.0%)', Color(0xFF0F274F)),
    _AdminLeadSourceData('Meta Ads', '1 (20.0%)', Color(0xFF2F80ED)),
    _AdminLeadSourceData('Google Ads', '1 (20.0%)', Color(0xFF84CC16)),
    _AdminLeadSourceData('99Acres', '1 (20.0%)', Color(0xFFFF8A1D)),
    _AdminLeadSourceData('MagicBricks', '1 (20.0%)', Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE3E3E3), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leads by Source',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 2.0,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                'View Report',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 106.w,
                height: 106.w,
                child: const _AdminLeadSourceDonutChart(),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  children: _sources
                      .map(
                        (source) => Padding(
                          padding: EdgeInsets.only(bottom: 9.h),
                          child: Row(
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: source.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  source.label,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.43,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Text(
                                source.value,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminLeadSourceDonutChart extends StatelessWidget {
  const _AdminLeadSourceDonutChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _AdminLeadSourceDonutPainter(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '5',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              'Total Leads',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminLeadSourceDonutPainter extends CustomPainter {
  const _AdminLeadSourceDonutPainter();

  static const List<Color> _colors = [
    Color(0xFFEF4444),
    Color(0xFF2F80ED),
    Color(0xFF84CC16),
    Color(0xFFFF8A1D),
    Color(0xFF0F274F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 16.0;
    final rect = Offset.zero & size;
    final arcRect = Rect.fromCircle(
      center: rect.center,
      radius: (size.shortestSide - strokeWidth) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    const gap = 0.08;
    final sweep =
        ((2 * 3.141592653589793) - (_colors.length * gap)) / _colors.length;
    var start = -1.5707963267948966;

    for (final color in _colors) {
      paint.color = color;
      canvas.drawArc(arcRect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdminDashboardMetricData {
  const _AdminDashboardMetricData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
}

class _AdminLeadSourceData {
  const _AdminLeadSourceData(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

class _AdminLeadFunnelOverviewCard extends StatelessWidget {
  const _AdminLeadFunnelOverviewCard();

  static const List<_AdminLeadSourceData> _stages = [
    _AdminLeadSourceData('Interested', '1 (20.0%)', Color(0xFF0F274F)),
    _AdminLeadSourceData('Booked', '1 (20.0%)', Color(0xFFFF8A1D)),
    _AdminLeadSourceData('New Lead', '1 (20.0%)', Color(0xFF3467E8)),
    _AdminLeadSourceData('Negotiation', '1 (20.0%)', Color(0xFF20B486)),
    _AdminLeadSourceData('Site Visit', '1 (20.0%)', Color(0xFFF04438)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lead Funnel Overview',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 2.0,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F7FF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'View Report',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF356AE6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          SizedBox(
            height: 170.h,
            child: const Center(child: _AdminLeadFunnelGraphic()),
          ),
          SizedBox(height: 16.h),
          for (int i = 0; i < _stages.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _stages[i].label,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Text(
                  _stages[i].value,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF667085),
                  ),
                ),
              ],
            ),
            if (i != _stages.length - 1) SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }
}

class _AdminLeadFunnelGraphic extends StatelessWidget {
  const _AdminLeadFunnelGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190.w,
      height: 165.h,
      child: CustomPaint(painter: const _AdminLeadFunnelPainter()),
    );
  }
}

class _AdminLeadFunnelPainter extends CustomPainter {
  const _AdminLeadFunnelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerX = size.width / 2;

    void drawSegment({
      required double topY,
      required double height,
      required double topWidth,
      required double bottomWidth,
      required Color color,
    }) {
      final path = Path()
        ..moveTo(centerX - topWidth / 2, topY)
        ..lineTo(centerX + topWidth / 2, topY)
        ..lineTo(centerX + bottomWidth / 2, topY + height)
        ..lineTo(centerX - bottomWidth / 2, topY + height)
        ..close();
      paint.color = color;
      canvas.drawPath(path, paint);
    }

    drawSegment(
      topY: 0,
      height: 36,
      topWidth: 130,
      bottomWidth: 92,
      color: const Color(0xFF0F274F),
    );
    drawSegment(
      topY: 40,
      height: 28,
      topWidth: 116,
      bottomWidth: 96,
      color: const Color(0xFFFF7A1A),
    );
    drawSegment(
      topY: 72,
      height: 32,
      topWidth: 100,
      bottomWidth: 84,
      color: const Color(0xFF3467E8),
    );
    drawSegment(
      topY: 108,
      height: 32,
      topWidth: 88,
      bottomWidth: 72,
      color: const Color(0xFF20B486),
    );
    drawSegment(
      topY: 144,
      height: 28,
      topWidth: 72,
      bottomWidth: 58,
      color: const Color(0xFFF04438),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdminSiteVisitsOverviewCard extends StatelessWidget {
  const _AdminSiteVisitsOverviewCard();

  static const List<_AdminSiteVisitMetricData> _metrics = [
    _AdminSiteVisitMetricData(
      title: 'Scheduled',
      value: '1',
      titleColor: Color(0xFF2557FF),
      valueColor: Color(0xFF2557FF),
      backgroundColor: Color(0xFFEAF2FF),
    ),
    _AdminSiteVisitMetricData(
      title: 'Completed',
      value: '2',
      titleColor: Color(0xFF16A34A),
      valueColor: Color(0xFF16A34A),
      backgroundColor: Color(0xFFEAF8EF),
    ),
    _AdminSiteVisitMetricData(
      title: 'Cancelled',
      value: '0',
      titleColor: Color(0xFFF04438),
      valueColor: Color(0xFFF04438),
      backgroundColor: Color(0xFFFDEEEE),
    ),
    _AdminSiteVisitMetricData(
      title: 'No-Show',
      value: '0',
      titleColor: Color(0xFFF97316),
      valueColor: Color(0xFFF97316),
      backgroundColor: Color(0xFFFFF5E9),
    ),
    _AdminSiteVisitMetricData(
      title: 'Conv. Rate',
      value: '100.0%',
      titleColor: Color(0xFF102A56),
      valueColor: Color(0xFF102A56),
      backgroundColor: Color(0xFFEEF2F7),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Visits Overview',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(height: 238.h, child: const _AdminSiteVisitsLineChart()),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(child: _AdminSiteVisitMetricTile(data: _metrics[0])),
              SizedBox(width: 10.w),
              Expanded(child: _AdminSiteVisitMetricTile(data: _metrics[1])),
              SizedBox(width: 10.w),
              Expanded(child: _AdminSiteVisitMetricTile(data: _metrics[2])),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _AdminSiteVisitMetricTile(data: _metrics[3])),
              SizedBox(width: 10.w),
              Expanded(child: _AdminSiteVisitMetricTile(data: _metrics[4])),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminSiteVisitsLineChart extends StatelessWidget {
  const _AdminSiteVisitsLineChart();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: const _AdminSiteVisitsChartPainter()),
        ),
        Positioned(
          left: 34.w,
          right: 8.w,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _AdminChartBottomLabel('22 Jun'),
              _AdminChartBottomLabel('24 Jun'),
              _AdminChartBottomLabel('25 Jun'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminChartBottomLabel extends StatelessWidget {
  const _AdminChartBottomLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

class _AdminSiteVisitsChartPainter extends CustomPainter {
  const _AdminSiteVisitsChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = 18.0;
    final right = size.width - 8.0;
    final top = 18.0;
    final bottom = size.height - 34.0;
    final chartWidth = right - left - 26.0;
    final chartLeft = left + 26.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFE7EDF5)
      ..strokeWidth = 1;

    final axisPainter = TextPainter(textDirection: TextDirection.ltr);
    const yLabels = ['2', '1.5', '1', '0.5', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = top + ((bottom - top) / 4) * i;
      if (i == yLabels.length - 1) {
        canvas.drawLine(Offset(chartLeft, y), Offset(right, y), gridPaint);
      }
      axisPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
      );
      axisPainter.layout();
      axisPainter.paint(canvas, Offset(left, y - 7));
    }

    Offset point(double xFactor, double value) {
      final x = chartLeft + chartWidth * xFactor;
      final y = bottom - ((value / 2.0) * (bottom - top));
      return Offset(x, y);
    }

    final navyPoints = [point(0.0, 0.95), point(0.5, 0.97), point(1.0, 2.0)];
    final orangePoints = [point(0.0, 0.95), point(0.5, 0.95), point(1.0, 0.0)];

    Path smoothPath(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];
        final controlX = (previous.dx + current.dx) / 2;
        path.cubicTo(
          controlX,
          previous.dy,
          controlX,
          current.dy,
          current.dx,
          current.dy,
        );
      }
      return path;
    }

    final navyPaint = Paint()
      ..color = const Color(0xFF102A56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final orangePaint = Paint()
      ..color = const Color(0xFFE85D0C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(smoothPath(navyPoints), navyPaint);
    canvas.drawPath(smoothPath(orangePoints), orangePaint);

    final pointFill = Paint()..color = Colors.white;
    final pointStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in navyPoints.skip(2)) {
      pointStroke.color = const Color(0xFF102A56);
      canvas.drawCircle(p, 3.5, pointFill);
      canvas.drawCircle(p, 3.5, pointStroke);
    }
    for (final p in orangePoints) {
      pointStroke.color = const Color(0xFFE85D0C);
      canvas.drawCircle(p, 3.5, pointFill);
      canvas.drawCircle(p, 3.5, pointStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdminSiteVisitMetricTile extends StatelessWidget {
  const _AdminSiteVisitMetricTile({required this.data});

  final _AdminSiteVisitMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: data.titleColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            data.value,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: data.valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSiteVisitMetricData {
  const _AdminSiteVisitMetricData({
    required this.title,
    required this.value,
    required this.titleColor,
    required this.valueColor,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final Color titleColor;
  final Color valueColor;
  final Color backgroundColor;
}

class _AdminSlaHealthCard extends StatelessWidget {
  const _AdminSlaHealthCard();

  static const List<_AdminSlaHealthTileData> _tiles = [
    _AdminSlaHealthTileData(
      title: 'Breached\nToday',
      subtitle: 'Needs manager\naction',
      value: '27',
      valueColor: Color(0xFFC81E1E),
      titleColor: Color(0xFF2B2F38),
      subtitleColor: Color(0xFF52525B),
      backgroundColor: Color(0xFFFFF3EC),
      borderColor: Color(0xFFFFC8B2),
      badgeText: 'BREACHED',
      badgeTextColor: Color(0xFFC81E1E),
      badgeColor: Color(0xFFFFDED1),
    ),
    _AdminSlaHealthTileData(
      title: 'At Risk',
      subtitle: 'Due in next 60\nmins',
      value: '14',
      valueColor: Color(0xFFF97316),
      titleColor: Color(0xFF2B2F38),
      subtitleColor: Color(0xFF52525B),
      backgroundColor: Color(0xFFFFF7EE),
      borderColor: Color(0xFFFFC58A),
      badgeText: 'DUE SOON',
      badgeTextColor: Color(0xFFF97316),
      badgeColor: Color(0xFFFFE7CC),
    ),
    _AdminSlaHealthTileData(
      title: 'Within SLA',
      subtitle: 'Across active\nlead queue',
      value: '66.2%',
      valueColor: Color(0xFF10B981),
      titleColor: Color(0xFF2B2F38),
      subtitleColor: Color(0xFF52525B),
      backgroundColor: Color(0xFFEEFBF5),
      borderColor: Color(0xFFB8F0D5),
      badgeText: 'ON\nTIME',
      badgeTextColor: Color(0xFF10B981),
      badgeColor: Color(0xFFDDF8EA),
    ),
    _AdminSlaHealthTileData(
      title: 'Avg First Response',
      subtitle: '6m faster than last week',
      value: '18m 42s',
      valueColor: Color(0xFF274690),
      titleColor: Color(0xFF2B2F38),
      subtitleColor: Color(0xFF52525B),
      backgroundColor: Color(0xFFF1F3FF),
      borderColor: Color(0xFFC8D0F0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SLA Health',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 2.0,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                'Open Queue',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2557FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _AdminSlaHealthTile(data: _tiles[0])),
                SizedBox(width: 12.w),
                Expanded(child: _AdminSlaHealthTile(data: _tiles[1])),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _AdminSlaHealthTile(data: _tiles[2])),
                SizedBox(width: 12.w),
                Expanded(child: _AdminSlaHealthTile(data: _tiles[3])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSlaHealthTile extends StatelessWidget {
  const _AdminSlaHealthTile({required this.data});

  final _AdminSlaHealthTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: data.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: data.titleColor,
                  ),
                ),
              ),
              if (data.badgeText != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: data.badgeColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    data.badgeText!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: data.badgeTextColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            data.subtitle,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: data.subtitleColor,
            ),
          ),
          SizedBox(height: 8.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: data.valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSlaHealthTileData {
  const _AdminSlaHealthTileData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.backgroundColor,
    required this.borderColor,
    this.badgeText,
    this.badgeTextColor = Colors.transparent,
    this.badgeColor = Colors.transparent,
  });

  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color backgroundColor;
  final Color borderColor;
  final String? badgeText;
  final Color badgeTextColor;
  final Color badgeColor;
}

class _AdminLiveExecutivesMapCard extends StatelessWidget {
  const _AdminLiveExecutivesMapCard();

  static const List<_AdminExecutiveData> _executives = [
    _AdminExecutiveData(
      initials: 'PS',
      name: 'Priya Singh',
      area: 'Andheri East',
      statusText: 'Showing Green Heights',
      avatarColor: Color(0xFF18386D),
    ),
    _AdminExecutiveData(
      initials: 'AK',
      name: 'Amit Kumar',
      area: 'Bandra Kurla Complex',
      statusText: 'Meeting a new lead',
      avatarColor: Color(0xFFF97316),
    ),
    _AdminExecutiveData(
      initials: 'NV',
      name: 'Neha Verma',
      area: 'Chembur',
      statusText: 'Heading to site visit',
      avatarColor: Color(0xFFE11D48),
    ),
    _AdminExecutiveData(
      initials: 'RS',
      name: 'Ravi Sharma',
      area: 'Ghatkopar',
      statusText: 'Follow-up on location',
      avatarColor: Color(0xFF0E88D3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Executives on Map',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),
          const _AdminLiveMapPreview(),
          SizedBox(height: 14.h),
          for (int i = 0; i < _executives.length; i++) ...[
            _AdminExecutiveTile(data: _executives[i]),
            if (i != _executives.length - 1) SizedBox(height: 12.h),
          ],
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF8A1D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'View Full Map',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF8A1D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLiveMapPreview extends StatelessWidget {
  const _AdminLiveMapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: double.infinity,
        height: 156.h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFBFD3E6), Color(0xFF8FB5D8)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(painter: const _AdminMapPainter()),
            ),
            Positioned(
              left: 14.w,
              top: 14.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'Maps',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2557FF),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 14.sp,
                      color: const Color(0xFF2557FF),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12.w,
              bottom: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live now',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '4 executives',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16.w,
              bottom: 14.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Primary zone',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Mumbai\nCentral',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: Colors.white,
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

class _AdminMapPainter extends CustomPainter {
  const _AdminMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final roadPaintThin = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final waterPaint = Paint()..color = const Color(0xFF6C96C8).withOpacity(.6);
    final overlayPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xCC102A56), Color(0x332557FF)],
      ).createShader(Offset.zero & size);

    final waterPath = Path()
      ..moveTo(0, size.height * .70)
      ..quadraticBezierTo(
        size.width * .25,
        size.height * .45,
        size.width * .45,
        size.height * .65,
      )
      ..quadraticBezierTo(
        size.width * .75,
        size.height * .92,
        size.width,
        size.height * .58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    canvas.drawLine(
      Offset(size.width * .08, size.height * .18),
      Offset(size.width * .92, size.height * .12),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .12, size.height * .45),
      Offset(size.width * .90, size.height * .35),
      roadPaintThin,
    );
    canvas.drawLine(
      Offset(size.width * .18, size.height * .80),
      Offset(size.width * .84, size.height * .58),
      roadPaintThin,
    );
    canvas.drawLine(
      Offset(size.width * .30, size.height * .10),
      Offset(size.width * .56, size.height * .92),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .60, size.height * .08),
      Offset(size.width * .75, size.height * .84),
      roadPaintThin,
    );

    canvas.drawRect(Offset.zero & size, overlayPaint);

    void marker(Offset center, Color color, String label) {
      final fill = Paint()..color = color;
      canvas.drawCircle(center, 7, fill);
      canvas.drawCircle(center, 3, Paint()..color = Colors.white);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + 10));
    }

    marker(
      Offset(size.width * .22, size.height * .70),
      const Color(0xFF2563EB),
      'S',
    );
    marker(
      Offset(size.width * .36, size.height * .46),
      const Color(0xFF84CC16),
      'N',
    );
    marker(
      Offset(size.width * .74, size.height * .62),
      const Color(0xFF1D4ED8),
      'N',
    );
    marker(
      Offset(size.width * .48, size.height * .20),
      const Color(0xFFEF4444),
      'L',
    );
    marker(
      Offset(size.width * .82, size.height * .20),
      const Color(0xFFF59E0B),
      'L',
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdminExecutiveTile extends StatelessWidget {
  const _AdminExecutiveTile({required this.data});

  final _AdminExecutiveData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD8E2EE)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: data.avatarColor,
            child: Text(
              data.initials,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    height: 1.43,
                    letterSpacing: 0,
                    color: const Color(0xFF0F2C59),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  data.area,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    height: 1.43,
                    letterSpacing: 0,
                    color: const Color(0xFF0F2C59),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  data.statusText,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    height: 1.43,
                    letterSpacing: 0,
                    color: const Color(0xFF0F2C59),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF8EA),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'LIVE',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminExecutiveData {
  const _AdminExecutiveData({
    required this.initials,
    required this.name,
    required this.area,
    required this.statusText,
    required this.avatarColor,
  });

  final String initials;
  final String name;
  final String area;
  final String statusText;
  final Color avatarColor;
}

class _AdminSystemUsersCard extends StatelessWidget {
  const _AdminSystemUsersCard();

  static const List<_AdminSystemUserMetricData> _metrics = [
    _AdminSystemUserMetricData(
      title: 'Total\nUsers',
      value: '5',
      color: Color(0xFF2557FF),
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFD6E4FF),
      icon: Icons.person_outline_rounded,
    ),
    _AdminSystemUserMetricData(
      title: 'Inactive\nUsers',
      value: '0',
      color: Color(0xFFF04438),
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFFAD3D0),
      icon: Icons.warning_amber_rounded,
    ),
    _AdminSystemUserMetricData(
      title: 'Active\nUsers',
      value: '5',
      color: Color(0xFF16A34A),
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFD7F0DE),
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Users',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(child: _AdminSystemUserMetricTile(data: _metrics[0])),
              SizedBox(width: 12.w),
              Expanded(child: _AdminSystemUserMetricTile(data: _metrics[1])),
              SizedBox(width: 12.w),
              Expanded(child: _AdminSystemUserMetricTile(data: _metrics[2])),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 42.h,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF18386D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Manage Users',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF18386D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSystemUserMetricTile extends StatelessWidget {
  const _AdminSystemUserMetricTile({required this.data});

  final _AdminSystemUserMetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 124.h),
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: data.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: data.color, width: 1.8),
            ),
            child: Icon(data.icon, size: 19.sp, color: data.color),
          ),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: const Color(0xFF52607A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF102A56),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSystemUserMetricData {
  const _AdminSystemUserMetricData({
    required this.title,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
}

class _AdminTeamPerformanceCard extends StatelessWidget {
  const _AdminTeamPerformanceCard();

  static const List<_AdminTeamMemberData> _members = [
    _AdminTeamMemberData('Sneha Iyer', '0', '0'),
    _AdminTeamMemberData('Ravi Kumar', '0', '0'),
    _AdminTeamMemberData('Khushvinder Kaur', '0', '0'),
    _AdminTeamMemberData('Telecaller Test', '0', '0'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Team Performance',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 2.0,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextSpan(
                  text: ' (This Month)',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const _AdminPerformanceTabStrip(),
          SizedBox(height: 16.h),
          const _AdminPerformanceTableHeader(),
          SizedBox(height: 8.h),
          for (int i = 0; i < _members.length; i++) ...[
            _AdminPerformanceRow(data: _members[i]),
            if (i != _members.length - 1)
              Divider(
                height: 18.h,
                thickness: 1,
                color: const Color(0xFFE5EAF1),
              ),
          ],
          SizedBox(height: 18.h),
          const _AdminPerformanceSummaryStrip(),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF8A1D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                'View All Telecallers',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF8A1D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPerformanceTabStrip extends StatelessWidget {
  const _AdminPerformanceTabStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _AdminPerformanceTab(label: 'Telecallers', isActive: true),
          ),
          SizedBox(width: 8.w),
          const Expanded(
            child: _AdminPerformanceTab(label: 'Field Execs', isActive: false),
          ),
          SizedBox(width: 8.w),
          const Expanded(
            child: _AdminPerformanceTab(label: 'Managers', isActive: false),
          ),
        ],
      ),
    );
  }
}

class _AdminPerformanceTab extends StatelessWidget {
  const _AdminPerformanceTab({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: isActive
            ? const [
                BoxShadow(
                  color: Color(0x0F102A56),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _AdminPerformanceTableHeader extends StatelessWidget {
  const _AdminPerformanceTableHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            'TELECALLER',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'LEADS',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'CALLS DONE',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminPerformanceRow extends StatelessWidget {
  const _AdminPerformanceRow({required this.data});

  final _AdminTeamMemberData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              data.name,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.leads,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              data.callsDone,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPerformanceSummaryStrip extends StatelessWidget {
  const _AdminPerformanceSummaryStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _AdminPerformanceSummaryItem(
              title: 'Avg SLA\nCompliance',
              value: '66.2%',
              valueColor: Color(0xFF10B981),
            ),
          ),
          Container(width: 1, height: 50.h, color: const Color(0xFFD7DFEA)),
          const Expanded(
            child: _AdminPerformanceSummaryItem(
              title: 'Fastest Team',
              value: 'Team Alpha',
              valueColor: Color(0xFF1F2937),
              compactValue: true,
            ),
          ),
          Container(width: 1, height: 50.h, color: const Color(0xFFD7DFEA)),
          const Expanded(
            child: _AdminPerformanceSummaryItem(
              title: 'Needs Attention',
              value: 'Team Delta',
              valueColor: Color(0xFFE11D48),
              compactValue: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPerformanceSummaryItem extends StatelessWidget {
  const _AdminPerformanceSummaryItem({
    required this.title,
    required this.value,
    required this.valueColor,
    this.compactValue = false,
  });

  final String title;
  final String value;
  final Color valueColor;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: const Color(0xFF4B5563),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTeamMemberData {
  const _AdminTeamMemberData(this.name, this.leads, this.callsDone);

  final String name;
  final String leads;
  final String callsDone;
}

class _AdminQuickActionsCard extends StatelessWidget {
  const _AdminQuickActionsCard();

  static const List<_AdminActionChipData> _actions = [
    _AdminActionChipData('Add New Lead', false),
    _AdminActionChipData('Import Leads', true),
    _AdminActionChipData('Assign Leads', false),
    _AdminActionChipData('Create Task', false),
    _AdminActionChipData('Schedule Visit', true),
    _AdminActionChipData('Send Notification', false),
    _AdminActionChipData('View Reports', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _actions
                .map((action) => _AdminActionChip(data: action))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AdminReportsShortcutsCard extends StatelessWidget {
  const _AdminReportsShortcutsCard();

  static const List<String> _reports = [
    'Daily Report',
    'Weekly Report',
    'Monthly Report',
    'Booking Report',
    'Revenue Report',
    'Source Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 16.h),
      decoration: _cardDecoration(borderRadius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports Shortcuts',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _reports
                .map((report) => _AdminReportChip(label: report))
                .toList(),
          ),
          SizedBox(height: 22.h),
          Center(
            child: SizedBox(
              width: 196.w,
              height: 42.h,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF8A1D)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'View All Reports',
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFF8A1D),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionChip extends StatelessWidget {
  const _AdminActionChip({required this.data});

  final _AdminActionChipData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: data.isOrange
            ? const Color(0xFFFF7A1A)
            : const Color(0xFF18386D),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        data.label,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _AdminReportChip extends StatelessWidget {
  const _AdminReportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFD4DDE8)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF18386D),
        ),
      ),
    );
  }
}

class _AdminActionChipData {
  const _AdminActionChipData(this.label, this.isOrange);

  final String label;
  final bool isOrange;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 28.h,
                width: 28.w,
                decoration: BoxDecoration(
                  color: data.bg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(data.icon, color: data.color, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      data.change,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF3F4656),
              fontSize: 60.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            data.value,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadConversionFunnel extends StatelessWidget {
  const _LeadConversionFunnel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      decoration: _cardDecoration(borderRadius: 16.r),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lead Conversion Funnel',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (period) =>
                    context.read<DashboardProvider>().setPeriod(period),
                initialValue: context.read<DashboardProvider>().selectedPeriod,
                itemBuilder: (context) => DashboardProvider.periods
                    .map(
                      (p) => PopupMenuItem(
                        value: p,
                        child: Text(p, style: TextStyle(fontSize: 13.sp)),
                      ),
                    )
                    .toList(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.watch<DashboardProvider>().selectedPeriod,
                        style: TextStyle(
                          color: const Color(0xFF303746),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF303746),
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const _FunnelStep(
            label: 'New Leads',
            value: '1,248',
            widthFactor: 1,
            color: Color(0xFFD7E7FA),
            textColor: AppColors.navy,
          ),
          const _FunnelStep(
            label: 'Contacted',
            value: '856',
            widthFactor: .86,
            color: Color(0xFFFFECD2),
            textColor: Color(0xFFB24B08),
          ),
          const _FunnelStep(
            label: 'Qualified',
            value: '512',
            widthFactor: .73,
            color: Color(0xFFFFF8BE),
            textColor: Color(0xFF8F6400),
          ),
          const _FunnelStep(
            label: 'Site Visit',
            value: '96',
            widthFactor: .59,
            color: Color(0xFFD9F6E3),
            textColor: Color(0xFF08793B),
          ),
          const _FunnelStep(
            label: 'Booked',
            value: '42',
            widthFactor: .50,
            color: Color(0xFFEEDDFA),
            textColor: Color(0xFF721FC2),
            last:
                false, // Changed to false to apply the triangle/trapezoid shape
          ),
        ],
      ),
    );
  }
}

class _FunnelStep extends StatelessWidget {
  const _FunnelStep({
    required this.label,
    required this.value,
    required this.widthFactor,
    required this.color,
    required this.textColor,
    this.last = false,
  });

  final String label;
  final String value;
  final double widthFactor;
  final Color color;
  final Color textColor;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: ClipPath(
        clipper: last ? null : const _FunnelClipper(),
        child: Container(
          height: 80.h,
          margin: EdgeInsets.only(bottom: 4.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: last ? BorderRadius.circular(6.r) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FunnelClipper extends CustomClipper<Path> {
  const _FunnelClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - 14, size.height)
      ..lineTo(14, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RevenueOverview extends StatelessWidget {
  const _RevenueOverview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: _cardDecoration(borderRadius: 12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Revenue Overview',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const _SmallPill(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '\u20B9 1,25,80,000',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 33.sp,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          SizedBox(height: 6.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '+18.6%',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' vs last month',
                  style: TextStyle(
                    color: const Color(0xFF697282),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 132.h,
            child: CustomPaint(
              painter: _RevenueChartPainter(),
              child: Stack(
                children: [
                  Positioned(
                    right: 8.w,
                    top: 26.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '\u20B9 1,25,80,000',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
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

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(.7)
      ..strokeWidth = 1;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    const labels = ['200L', '150L', '100L', '50L'];

    for (var i = 0; i < 4; i++) {
      final y = 10 + i * (size.height - 34) / 4;
      canvas.drawLine(Offset(34, y), Offset(size.width - 4, y), gridPaint);
      labelPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 10),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(0, y - 5));
    }

    final axisPainter = TextPainter(textDirection: TextDirection.ltr);
    final months = ['1 May', '8 May', '15 May', '22 May', '29 May'];
    for (var i = 0; i < months.length; i++) {
      final x = 34 + i * (size.width - 48) / 4;
      axisPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(color: Color(0xFF98A2B3), fontSize: 10),
      );
      axisPainter.layout();
      axisPainter.paint(
        canvas,
        Offset(x - axisPainter.width / 2, size.height - 14),
      );
    }

    final points = [
      Offset(34, size.height - 32),
      Offset(size.width * .28, size.height - 62),
      Offset(size.width * .43, size.height - 58),
      Offset(size.width * .55, size.height - 66),
      Offset(size.width * .70, size.height - 38),
      Offset(size.width * .82, size.height - 56),
      Offset(size.width - 6, size.height - 24),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final point = points[i];
      path.cubicTo(
        prev.dx + 22,
        prev.dy,
        point.dx - 22,
        point.dy,
        point.dx,
        point.dy,
      );
    }

    final linePaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickActionData(
        Icons.person_add_alt_1_outlined,
        'Add Lead',
        AppColors.vividBlue,
        Color(0xFFEAF2FF),
      ),
      _QuickActionData(
        Icons.assignment_ind_outlined,
        'Assign Lead',
        AppColors.orange,
        Color(0xFFFFF4E9),
      ),
      _QuickActionData(
        Icons.event_available_outlined,
        'Schedule Visit',
        AppColors.green,
        Color(0xFFEAF8F0),
      ),
      _QuickActionData(
        Icons.call_outlined,
        'Create Follow-up',
        AppColors.purple,
        Color(0xFFF4EAFE),
      ),
      _QuickActionData(
        Icons.business_outlined,
        'Add Booking',
        AppColors.vividBlue,
        Color(0xFFEAF2FF),
      ),
    ];

    return Column(
      children: [
        _SectionHeader(
          title: 'Quick Actions',
          action: 'View All',
          onTap: () {},
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions.map((action) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: GestureDetector(
                  onTap: () {
                    if (action.label == 'Schedule Visit') {
                      Navigator.of(context).pushNamed(AppRouter.siteVisits);
                    }
                  },
                  child: SizedBox(
                    width: 104.w,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: action.bg,
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TodayActivities extends StatelessWidget {
  const _TodayActivities();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      title: 'Today\'s Activities',
      children: const [
        _ActivityRow(
          icon: Icons.call_outlined,
          title: 'Follow-up Call',
          subtitle: 'Lead: Rahul Sharma',
          time: '10:00 AM',
          color: AppColors.green,
          bg: Color(0xFFEAF8F0),
        ),
        _ActivityRow(
          icon: Icons.event_available_outlined,
          title: 'Site Visit',
          subtitle: 'Project: Green Valley',
          time: '11:30 AM',
          color: AppColors.orange,
          bg: Color(0xFFFFF4E9),
        ),
        _ActivityRow(
          icon: Icons.groups_outlined,
          title: 'Team Meeting',
          subtitle: 'Marketing Team',
          time: '02:00 PM',
          color: AppColors.vividBlue,
          bg: Color(0xFFEAF2FF),
        ),
      ],
    );
  }
}

class _RecentLeads extends StatelessWidget {
  const _RecentLeads();

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      title: 'Recent Leads',
      children: const [
        _LeadRow(
          initials: 'RS',
          name: 'Rahul Sharma',
          subtitle: 'Warm Lead • Noida',
          time: '2m ago',
        ),
        _LeadRow(
          initials: 'PM',
          name: 'Priya Mehta',
          subtitle: 'Hot Lead • Gurgaon',
          time: '15m ago',
          accent: AppColors.orange,
        ),
        _LeadRow(
          initials: 'AS',
          name: 'Amit Singh',
          subtitle: 'Cold Lead • Delhi',
          time: '30m ago',
          accent: AppColors.green,
        ),
      ],
      footer: 'See All Leads',
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      decoration: _cardDecoration(borderRadius: 10.r),
      child: Column(
        children: [
          _SectionHeader(title: title, action: 'View All', onTap: () {}),
          SizedBox(height: 8.h),
          ...children,
          if (footer != null) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 48.h,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  footer!,
                  style: TextStyle(
                    color: AppColors.vividBlue,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              color: AppColors.vividBlue,
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: bg,
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF697282),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 5.w),
          CircleAvatar(radius: 2.r, backgroundColor: color),
        ],
      ),
    );
  }
}

class _LeadRow extends StatelessWidget {
  const _LeadRow({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.time,
    this.accent = AppColors.vividBlue,
  });

  final String initials;
  final String name;
  final String subtitle;
  final String time;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: accent.withOpacity(.12),
            child: Text(
              initials,
              style: TextStyle(
                color: accent,
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF697282),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: const Color(0xFF697282),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFFEAF8F0),
            child: Icon(Icons.call, color: AppColors.green, size: 18.sp),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    return PopupMenuButton<String>(
      onSelected: (period) => provider.setPeriod(period),
      initialValue: provider.selectedPeriod,
      itemBuilder: (context) => DashboardProvider.periods
          .map(
            (p) => PopupMenuItem(
              value: p,
              child: Text(p, style: TextStyle(fontSize: 13.sp)),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.selectedPeriod,
              style: TextStyle(
                color: const Color(0xFF303746),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 3.w),
            Icon(
              Icons.keyboard_arrow_down,
              color: const Color(0xFF303746),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.selectedIndex, required this.onTap});

  static const double _defaultNavIconSize = 22;
  static const double _telecallerNavIconSize = 25;
  static const double _telecallerMyPerformanceIconSize = 28;
  static const double _defaultNavLabelSize = 12.5;
  static const double _telecallerNavLabelSize = 10;

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const items = [
    _BottomNavData(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    _BottomNavData(Icons.groups_outlined, Icons.groups, 'Leads'),
    _BottomNavData(Icons.assignment_outlined, Icons.assignment, 'Tasks'),
    _BottomNavData(Icons.bar_chart_outlined, Icons.bar_chart, 'Reports'),
    _BottomNavData(Icons.more_horiz, Icons.more_horiz, 'More'),
  ];

  List<_BottomNavData> _itemsForRole(UserRole role) {
    if (role == UserRole.telecaller) {
      return const [
        _BottomNavData(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
        _BottomNavData(Icons.groups_outlined, Icons.groups, 'Leads'),
        _BottomNavData(
          Icons.bar_chart_outlined,
          Icons.bar_chart,
          'Performance',
        ),
        _BottomNavData(
          Icons.calendar_today_outlined,
          Icons.calendar_today,
          'Site Visits',
        ),
        _BottomNavData(Icons.more_horiz, Icons.more_horiz, 'More'),
      ];
    }

    if (role == UserRole.fieldExecutive) {
      return const [
        _BottomNavData(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
        _BottomNavData(Icons.groups_outlined, Icons.groups, 'Leads'),
        _BottomNavData(Icons.assignment_outlined, Icons.assignment, 'Tasks'),
        _BottomNavData(
          Icons.calendar_today_outlined,
          Icons.calendar_today,
          'Site Visits',
        ),
        _BottomNavData(Icons.more_horiz, Icons.more_horiz, 'More'),
      ];
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role;
    final navItems = _itemsForRole(role);
    final navLabelSize = role == UserRole.telecaller
        ? _telecallerNavLabelSize.sp
        : _defaultNavLabelSize.sp;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFD5DDE9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A061B69),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1)),
          child: SafeArea(
            top: false,
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              elevation: 0,
              selectedItemColor: AppColors.navy,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: role != UserRole.telecaller,
              showUnselectedLabels: role != UserRole.telecaller,
              selectedFontSize: navLabelSize,
              unselectedFontSize: navLabelSize,
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: navLabelSize,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: navLabelSize,
              ),
              items: navItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Icon(item.icon, size: _iconSizeForItem(role, item)),
                      activeIcon: Icon(
                        item.activeIcon,
                        size: _iconSizeForItem(role, item),
                      ),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  double _iconSizeForItem(UserRole role, _BottomNavData item) {
    if (role == UserRole.telecaller && item.label == 'Performance') {
      return _telecallerMyPerformanceIconSize.sp;
    }

    return role == UserRole.telecaller
        ? _telecallerNavIconSize.sp
        : _defaultNavIconSize.sp;
  }
}

class _BottomNavData {
  const _BottomNavData(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _QuickActionData {
  const _QuickActionData(this.icon, this.label, this.color, this.bg);

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    final canAssignLeads = context.watch<AuthProvider>().canViewModule(
      'employees',
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('More', style: AppStyles.h2),
          SizedBox(height: 16.h),
          if (canAssignLeads) ...[
            _ActionTile(
              icon: Icons.assignment_ind_outlined,
              title: 'Assign Leads',
              subtitle: 'Manage manual and AI lead assignment',
              color: AppColors.vividBlue,
              bg: AppColors.windowBlue,
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRouter.assignLeads),
            ),
            SizedBox(height: 10.h),
          ],
          _ActionTile(
            icon: Icons.calendar_today_outlined,
            title: 'Site Visits',
            subtitle: 'Manage and track site visits',
            color: AppColors.green,
            bg: AppColors.greenBg,
            onTap: () => Navigator.of(context).pushNamed(AppRouter.siteVisits),
          ),
          SizedBox(height: 10.h),
          _ActionTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Leave the current session',
            color: AppColors.orange,
            bg: AppColors.orangeBg,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouter.logoutConfirmation),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: bg,
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.mutedNavy,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.mutedNavy, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(18.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: _cardDecoration(borderRadius: 12.r),
        child: Text(title, style: AppStyles.h2),
      ),
    );
  }
}

class _NavigationDrawer extends StatefulWidget {
  const _NavigationDrawer();

  @override
  State<_NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<_NavigationDrawer> {
  bool _employmentExpanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<EmployeeProvider>();
      if (provider.currentEmployee == null && !provider.isLoading) {
        provider.fetchCurrentEmployee();
      }
    });
  }

  void _openRoute(String route, {Object? arguments}) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }

  String _read(Map<String, dynamic> map, List<String> keys, String fallback) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final employee =
        context.watch<EmployeeProvider>().currentEmployee ??
        auth.session?.user ??
        const <String, dynamic>{};
    final name = _read(employee, const [
      'name',
      'fullName',
      'displayName',
    ], '${auth.roleName} User');
    final designation = _read(employee, const [
      'designation',
      'roleName',
      'departmentName',
      'teamName',
    ], 'Real Estate CRM Ops');
    final image = _read(employee, const [
      'image',
      'imageUrl',
      'profileImage',
      'avatar',
    ], '');

    return Drawer(
      width: 310.w.clamp(280, 340),
      backgroundColor: const Color(0xFF103F75),
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 22.h, 18.w, 14.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 66.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Image.asset(
                      'assets/app_icon.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.white24,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : null,
                        child: image.isEmpty
                            ? Text(
                                name
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .take(2)
                                    .map((part) => part[0])
                                    .join()
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              designation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: const Color(0xFFD3DEEB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                child: Column(
                  children: [
                    _DrawerItem(
                      icon: Icons.grid_view_outlined,
                      label: 'Dashboard',
                      selected: true,
                      onTap: () {
                        context.read<DashboardProvider>().selectTab(0);
                        Navigator.pop(context);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.adjust_rounded,
                      label: 'My Leads',
                      selected: false,
                      onTap: () {
                        context.read<DashboardProvider>().selectTab(1);
                        Navigator.pop(context);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.event_available_outlined,
                      label: 'Site Visits',
                      selected: false,
                      onTap: () {
                        if (auth.role == UserRole.owner) {
                          _openRoute(AppRouter.siteVisits);
                        } else {
                          context.read<DashboardProvider>().selectTab(3);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.schedule_outlined,
                      label: 'Follow-Ups',
                      selected: false,
                      onTap: () => _openRoute(AppRouter.myFollowUps),
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline,
                      label: 'My Employment',
                      selected: false,
                      trailing: AnimatedRotation(
                        turns: _employmentExpanded ? .5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFFD3DEEB),
                        ),
                      ),
                      onTap: () => setState(
                        () => _employmentExpanded = !_employmentExpanded,
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Column(
                        children: [
                          _DrawerSubItem(
                            label: 'My Profile',
                            onTap: () =>
                                _openRoute(AppRouter.profile, arguments: 0),
                          ),
                          _DrawerSubItem(
                            label: 'Attendance',
                            onTap: () =>
                                _openRoute(AppRouter.profile, arguments: 0),
                          ),
                          _DrawerSubItem(
                            label: 'Leave',
                            onTap: () => _openRoute(AppRouter.myLeave),
                          ),
                          _DrawerSubItem(
                            label: 'Payslips',
                            onTap: () => _openRoute(AppRouter.myPayslips),
                          ),
                          _DrawerSubItem(
                            label: 'Holidays',
                            onTap: () => _openRoute(AppRouter.holidays),
                          ),
                        ],
                      ),
                      crossFadeState: _employmentExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 180),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: ListTile(
        minTileHeight: 45.h,
        contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
        onTap: onTap,
        leading: Icon(icon, color: Colors.white, size: 20.sp),
        title: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing,
        selected: selected,
        selectedTileColor: const Color(0xFFFF650D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _DrawerSubItem extends StatelessWidget {
  const _DrawerSubItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(60.w, 10.h, 10.w, 10.h),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFFD3DEEB),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _MetricData {
  const _MetricData(
    this.label,
    this.value,
    this.change,
    this.icon,
    this.color,
    this.bg,
  );

  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final Color bg;
}

BoxDecoration _cardDecoration({double? borderRadius}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
    border: Border.all(color: const Color(0xFFF1F4F9), width: 1.2),
  );
}
