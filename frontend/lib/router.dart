// lib/router.dart
import 'package:go_router/go_router.dart';

import 'features/attendance/capture_page.dart';
import 'features/attendance/history_page.dart';
import 'features/attendance/result_page.dart';
import 'features/auth/login_page.dart';
import 'features/qr/scan_qr_page.dart';
import 'features/shell/shell_page.dart';
import 'features/dashboard/admin_dashboard_page.dart';
import 'features/dashboard/lecturer_dashboard_page.dart';
// Student dashboard is the first tab inside ShellPage.

final appRouter = GoRouter(
  // initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const ShellPage(),
    ),
    GoRoute(
      path: '/dashboard/student',
      builder: (_, __) => const ShellPage(),
    ),
    GoRoute(
      path: '/dashboard/lecturer',
      builder: (_, __) => const LecturerDashboardPage(),
    ),
    GoRoute(
      path: '/dashboard/admin',
      builder: (_, __) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/scan-qr',
      builder: (_, __) => const ScanQrPage(),
    ),
    GoRoute(
      path: '/capture',
      builder: (_, state) => CapturePage(
        sessionToken: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/result',
      builder: (_, state) => ResultPage(
        result: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryPage(),
    ),
  ],
);
