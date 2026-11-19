import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rdpms_app/features/home/presentation/pages/home_page.dart';
import 'package:rdpms_app/features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/admin/presentation/pages/admin_page.dart';
import '../../features/alerts/presentation/pages/alert_detail_page.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/asset/presentation/pages/asset_detail_page.dart';
import '../../features/asset/presentation/pages/asset_utilization_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/legal/presentation/pages/legal_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/equipment_room/presentation/pages/equipment_room_page.dart';
import '../../features/performance/presentation/pages/performance_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rdpms_health/presentation/pages/health_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/telemetry/presentation/pages/telemetry_page.dart';
import 'route_names.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: RouteNames.splash,
  routes: [
    // ---------- Auth ----------
    GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashPage()),
    GoRoute(path: RouteNames.login, builder: (_, _) => const LoginPage()),
    GoRoute(path: RouteNames.otp, builder: (_, _) => const OtpPage()),
    GoRoute(path: RouteNames.register, builder: (_, _) => const RegisterPage()),
    GoRoute(path: RouteNames.forgotPassword, builder: (_, _) => const ForgotPasswordPage()),
    GoRoute(
      path: RouteNames.privacyPolicy,
      builder: (_, _) => const LegalPage(document: LegalDocument.privacyPolicy),
    ),
    GoRoute(
      path: RouteNames.terms,
      builder: (_, _) => const LegalPage(document: LegalDocument.terms),
    ),

    // ---------- Bottom navigation (Annex G) ----------
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => HomeShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: RouteNames.dashboard, builder: (_, _) => const DashboardPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: RouteNames.alerts, builder: (_, _) => const AlertsPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: RouteNames.telemetry, builder: (_, _) => const TelemetryPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: RouteNames.health, builder: (_, _) => const HealthPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: RouteNames.equipmentRoom, builder: (_, _) => const EquipmentRoomPage()),
        ]),
      ],
    ),

    // ---------- Details (full screen, above the bottom bar) ----------
    GoRoute(
      path: '/alert-detail/:id',
      parentNavigatorKey: _rootKey,
      builder: (_, state) => AlertDetailPage(alertId: state.pathParameters['id']!),
    ),

    // ---------- "Others" menu (full screen, above the bottom bar) ----------
    GoRoute(path: RouteNames.assetDetail, parentNavigatorKey: _rootKey, builder: (_, _) => const AssetDetailPage()),
    GoRoute(path: RouteNames.assetUtilization, parentNavigatorKey: _rootKey, builder: (_, _) => const AssetUtilizationPage()),
    GoRoute(path: RouteNames.performance, parentNavigatorKey: _rootKey, builder: (_, _) => const PerformancePage()),
    GoRoute(path: RouteNames.admin, parentNavigatorKey: _rootKey, builder: (_, _) => const AdminPage()),
    GoRoute(path: RouteNames.profile, parentNavigatorKey: _rootKey, builder: (_, _) => const ProfilePage()),
    GoRoute(path: RouteNames.editProfile, parentNavigatorKey: _rootKey, builder: (_, _) => const EditProfilePage()),
  ],
);
