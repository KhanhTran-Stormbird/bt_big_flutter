import 'package:go_router/go_router.dart';

import 'core/auth/auth_state.dart';
import 'data/models/attendance_model.dart';
import 'data/models/class_model.dart';
import 'data/models/session_model.dart';
import 'features/attendance/capture_page.dart';
import 'features/attendance/history_page.dart';
import 'features/attendance/result_page.dart';
import 'features/auth/login_page.dart';
import 'features/classes/class_detail_page.dart';
import 'features/dashboard/admin_home_page.dart';
import 'features/dashboard/lecturer_home_page.dart';
import 'features/dashboard/student_home_page.dart';
import 'features/misc/not_found_page.dart';
import 'features/qr/scan_qr_page.dart';
import 'features/sessions/session_detail_page.dart';
import 'features/sessions/session_qr_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: authStateNotifier,
  errorBuilder: (_, state) => NotFoundPage(path: state.uri.toString()),
  redirect: (_, state) {
    final user = authStateNotifier.value;
    final currentPath = state.uri.path;
    final isLoggingIn = currentPath == '/login';
    if (user == null) {
      return isLoggingIn ? null : '/login';
    }

    final home = homePathForUser(user);
    if (isLoggingIn) {
      return home;
    }

    final loc = currentPath;
    final role = user.role.toLowerCase();

    if (role == 'admin') {
      if (loc == '/dashboard/student' || loc == '/dashboard/lecturer') {
        return '/dashboard/admin';
      }
    } else if (role == 'lecturer') {
      if (loc == '/dashboard/student' || loc == '/dashboard/admin') {
        return '/dashboard/lecturer';
      }
    } else {
      if (loc == '/dashboard/admin' || loc == '/dashboard/lecturer') {
        return '/dashboard/student';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/dashboard/student',
      builder: (_, __) => const StudentHomePage(),
    ),
    GoRoute(
      path: '/dashboard/lecturer',
      builder: (_, __) => const LecturerHomePage(),
    ),
    GoRoute(
      path: '/dashboard/admin',
      builder: (_, __) => const AdminHomePage(),
    ),
    GoRoute(
      path: '/classes/:id',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final extra = state.extra;
        final initial = extra is ClassModel ? extra : null;
        return ClassDetailPage(classId: id, initial: initial);
      },
    ),
    GoRoute(
      path: '/sessions/:id',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final extra = state.extra;
        final initial = extra is SessionModel ? extra : null;
        return SessionDetailPage(sessionId: id, initial: initial);
      },
    ),
    GoRoute(
      path: '/sessions/:id/qr',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return SessionQrPage(sessionId: id);
      },
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
      builder: (_, state) {
        AttendanceModel? attendance;
        String? imagePath;
        final extra = state.extra;
        if (extra is Map) {
          final att = extra['attendance'];
          if (att is AttendanceModel) attendance = att;
          final img = extra['imagePath'];
          if (img is String) imagePath = img;
        }
        return ResultPage(
          attendance: attendance,
          imagePath: imagePath,
        );
      },
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryPage(),
    ),
  ],
);
