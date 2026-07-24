import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/screen/login_screen.dart';
import 'package:truerealtycrm/screen/leads_screen.dart';
import 'package:truerealtycrm/screen/lead_detail_screen.dart';
import 'package:truerealtycrm/screen/lead_profile_management_screen.dart';
import 'package:truerealtycrm/screen/add_lead_screen.dart';
import 'package:truerealtycrm/screen/add_activity_screen.dart';
import 'package:truerealtycrm/screen/dashboard_screen.dart';
import 'package:truerealtycrm/screen/forgot_password_screen.dart';
import 'package:truerealtycrm/screen/otp_verification_screen.dart';
import 'package:truerealtycrm/screen/assign_leads_screen.dart';
import 'package:truerealtycrm/screen/tasks_screen.dart';
import 'package:truerealtycrm/screen/reports_screen.dart';
import 'package:truerealtycrm/screen/logout_confirmation_screen.dart';
import 'package:truerealtycrm/screen/site_visits_screen.dart';
import 'package:truerealtycrm/screen/telecaller_lead_details_screen.dart';
import 'package:truerealtycrm/screen/follow_up_test_screen.dart';
import 'package:truerealtycrm/screen/my_leads_filter_screen.dart';
import 'package:truerealtycrm/screen/my_follow_ups_screen.dart';
import 'package:truerealtycrm/screen/my_performance_screen.dart';
import 'package:truerealtycrm/screen/employee_directory_screen.dart';
import 'package:truerealtycrm/screen/telecaller_communication_screen.dart';
import 'package:truerealtycrm/screen/notifications_screen.dart';
import 'package:truerealtycrm/screen/personal_settings_screen.dart';

import '../screen/my_leads_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String dashboard = '/dashboard';
  static const String leads = '/leads';
  static const String leadDetail = '/lead-detail';
  static const String leadProfileManagement = '/lead-profile-management';
  static const String addLead = '/add-lead';
  static const String addActivity = '/add-activity';
  static const String assignLeads = '/assign-leads';
  static const String tasks = '/tasks';
  static const String reports = '/reports';
  static const String logoutConfirmation = '/logout-confirmation';
  static const String siteVisits = '/site-visits';
  static const String telecallerDashboard = '/telecaller-dashboard';
  static const String telecallerLeadDetails = '/telecaller-lead-details';
  static const String myleads = '/my-leads';
  static const String myLeadsFilter = '/my-leads-filter';
  static const String followUpTest = '/follow-up-test';
  static const String myFollowUps = '/my-follow-ups';
  static const String myPerformance = '/my-performance';
  static const String employeeDirectory = '/employee-directory';
  static const String telecallerCommunication = '/telecaller-communication';
  static const String notifications = '/notifications';
  static const String personalSettings = '/personal-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case otpVerification:
        return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case leads:
        return MaterialPageRoute(builder: (_) => const LeadListWidget());
      case leadDetail:
        final args = settings.arguments;
        final leadDetailArgs = args is LeadDetailScreenArgs
            ? args
            : const LeadDetailScreenArgs();
        return MaterialPageRoute(
          builder: (_) => _LeadDetailRouteWrapper(
            initialTabIndex: leadDetailArgs.initialTabIndex,
          ),
        );
      case leadProfileManagement:
        final args = settings.arguments;
        final lead = args is LeadModel ? args : null;
        return MaterialPageRoute(
          builder: (_) => LeadProfileManagementScreen(lead: lead),
        );
      case addLead:
        return MaterialPageRoute(builder: (_) => const AddLeadScreen());
      case addActivity:
        return MaterialPageRoute(builder: (_) => const AddActivityScreen());
      case assignLeads:
        return MaterialPageRoute(builder: (_) => const AssignLeadsScreen());
      case tasks:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: SafeArea(child: TasksScreen())),
        );
      case reports:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: SafeArea(child: ReportsScreen())),
        );
      case logoutConfirmation:
        return MaterialPageRoute(
          builder: (_) => const LogoutConfirmationScreen(),
        );
      case siteVisits:
        return MaterialPageRoute(
          builder: (_) => const SiteVisitDetailsScreen(),
        );
      case telecallerDashboard:
        return MaterialPageRoute(
          builder: (_) => const _TelecallerDashboardRouteEntry(),
        );

      case myleads:
        return MaterialPageRoute(builder: (_) => const MyLeadsScreen());

      case myLeadsFilter:
        return MaterialPageRoute(builder: (_) => const MyLeadsFilterScreen());

      case followUpTest:
        return MaterialPageRoute(builder: (_) => const FollowUpTestScreen());

      case myFollowUps:
        return MaterialPageRoute(builder: (_) => const MyFollowUpsScreen());
      case myPerformance:
        return MaterialPageRoute(builder: (_) => const MyPerformanceScreen());
      case employeeDirectory:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: SafeArea(child: EmployeeDirectoryScreen())),
        );

      case telecallerLeadDetails:
        return MaterialPageRoute(
          builder: (_) => const TelecallerLeadDetailsScreen(),
        );
      case telecallerCommunication:
        return MaterialPageRoute(
          builder: (_) => const TelecallerCommunicationScreen(),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case personalSettings:
        return MaterialPageRoute(
          builder: (_) => const PersonalSettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class _LeadDetailRouteWrapper extends StatelessWidget {
  const _LeadDetailRouteWrapper({required this.initialTabIndex});

  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role;
    if (role == UserRole.telecaller) {
      return const TelecallerLeadDetailsScreen();
    }
    return LeadDetailScreen(initialTabIndex: initialTabIndex);
  }
}

class _TelecallerDashboardRouteEntry extends StatelessWidget {
  const _TelecallerDashboardRouteEntry();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final dashboardProvider = context.read<DashboardProvider>();

      if (authProvider.role != UserRole.telecaller) {
        authProvider.setRole(UserRole.telecaller);
      }

      if (dashboardProvider.selectedTab != 0) {
        dashboardProvider.selectTab(0);
      }
    });

    return const DashboardScreen();
  }
}
