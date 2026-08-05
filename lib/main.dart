import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truerealtycrm/constant/colors_screen.dart';
import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/provider/dashboard_provider.dart';
import 'package:truerealtycrm/provider/access_control_provider.dart';
import 'package:truerealtycrm/provider/attendance_provider.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';
import 'package:truerealtycrm/provider/auto_assignment_provider.dart';
import 'package:truerealtycrm/provider/contact_lead_provider.dart';
import 'package:truerealtycrm/provider/employee_provider.dart';
import 'package:truerealtycrm/provider/follow_ups_provider.dart';
import 'package:truerealtycrm/provider/integration_provider.dart';
import 'package:truerealtycrm/provider/lead_master_provider.dart';
import 'package:truerealtycrm/provider/leads_provider.dart';
import 'package:truerealtycrm/provider/notification_provider.dart';
import 'package:truerealtycrm/provider/payroll_provider.dart';
import 'package:truerealtycrm/provider/project_provider.dart';
import 'package:truerealtycrm/provider/tasks_provider.dart';
import 'package:truerealtycrm/provider/reports_provider.dart';
import 'package:truerealtycrm/provider/site_visits_provider.dart';
import 'package:truerealtycrm/provider/system_provider.dart';
import 'package:truerealtycrm/provider/upload_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truerealtycrm/router/app_router.dart';
import 'package:truerealtycrm/screen/dashboard_screen.dart';
import 'package:truerealtycrm/screen/login_screen.dart';
import 'package:truerealtycrm/widget/app_loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SystemProvider()),
        ChangeNotifierProvider(create: (_) => AccessControlProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => PayrollProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => FollowUpsProvider()),
        ChangeNotifierProvider(create: (_) => ContactLeadProvider()),
        ChangeNotifierProvider(create: (_) => LeadMasterProvider()),
        ChangeNotifierProvider(create: (_) => AutoAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => IntegrationProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SiteVisitProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final baseIconSize = 22.sp;
          final textTheme = GoogleFonts.interTextTheme().copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 48.sp,
              height: 1.12,
              fontWeight: FontWeight.w700,
            ),
            displayMedium: GoogleFonts.inter(
              fontSize: 40.sp,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
            displaySmall: GoogleFonts.inter(
              fontSize: 34.sp,
              height: 1.18,
              fontWeight: FontWeight.w700,
            ),
            headlineLarge: GoogleFonts.inter(
              fontSize: 30.sp,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 26.sp,
              height: 1.22,
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: GoogleFonts.inter(
              fontSize: 22.sp,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: 21.sp,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: 18.sp,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
            titleSmall: GoogleFonts.inter(
              fontSize: 16.sp,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(fontSize: 17.sp, height: 1.5),
            bodyMedium: GoogleFonts.inter(fontSize: 16.sp, height: 1.45),
            bodySmall: GoogleFonts.inter(fontSize: 14.sp, height: 1.4),
            labelLarge: GoogleFonts.inter(
              fontSize: 16.sp,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
            labelMedium: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
            labelSmall: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TrueRoot',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
              textTheme: textTheme,
              primaryTextTheme: textTheme,
              iconTheme: IconThemeData(size: baseIconSize),
              primaryIconTheme: IconThemeData(size: baseIconSize),
              appBarTheme: AppBarTheme(
                iconTheme: IconThemeData(size: baseIconSize),
                actionsIconTheme: IconThemeData(size: baseIconSize),
                titleTextStyle: textTheme.titleLarge?.copyWith(
                  color: AppColors.navy,
                ),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: IconButton.styleFrom(iconSize: baseIconSize),
              ),
              inputDecorationTheme: InputDecorationTheme(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 17.h,
                ),
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF747781),
                ),
                helperStyle: textTheme.bodySmall,
                errorStyle: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB3261E),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: textTheme.labelLarge,
                  minimumSize: Size(48.w, 48.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  textStyle: textTheme.labelLarge,
                  minimumSize: Size(48.w, 50.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 13.h,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  textStyle: textTheme.labelLarge,
                  minimumSize: Size(48.w, 48.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
              chipTheme: ChipThemeData(
                labelStyle: textTheme.labelMedium,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedLabelStyle: textTheme.labelMedium,
                unselectedLabelStyle: textTheme.labelMedium,
                selectedIconTheme: IconThemeData(size: baseIconSize),
                unselectedIconTheme: IconThemeData(size: baseIconSize - 1),
              ),
              useMaterial3: true,
            ),
            builder: (context, app) {
              final mediaQuery = MediaQuery.of(context);
              final systemScale = mediaQuery.textScaler.scale(1);
              final comfortableScale = (systemScale * 1.1).clamp(1.1, 1.6);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(comfortableScale),
                ),
                child: app ?? const SizedBox.shrink(),
              );
            },
            onGenerateRoute: AppRouter.generateRoute,
            home: const _SessionGate(),
          );
        },
      ),
    );
  }
}

class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  Future<void>? _loadSession;
  bool _listeningForSessionExpiry = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSession ??= context.read<AuthProvider>().loadSavedSession();
    if (!_listeningForSessionExpiry) {
      ApiClient.sessionExpiredNotifier.addListener(_handleSessionExpired);
      _listeningForSessionExpiry = true;
    }
  }

  Future<void> _handleSessionExpired() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      await authProvider.clearSession();
    }
  }

  @override
  void dispose() {
    if (_listeningForSessionExpiry) {
      ApiClient.sessionExpiredNotifier.removeListener(_handleSessionExpired);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: AppPageLoader(message: 'Restoring your session'),
          );
        }
        return context.watch<AuthProvider>().isAuthenticated
            ? const DashboardScreen()
            : const LoginScreen();
      },
    );
  }
}
