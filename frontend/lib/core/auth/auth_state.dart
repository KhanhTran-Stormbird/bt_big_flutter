import 'package:flutter/foundation.dart';

import '../../data/models/user.dart';

final ValueNotifier<User?> authStateNotifier = ValueNotifier<User?>(null);

String homePathForRole(String? role) {
  switch ((role ?? '').toLowerCase()) {
    case 'admin':
      return '/dashboard/admin';
    case 'lecturer':
      return '/dashboard/lecturer';
    default:
      return '/dashboard/student';
  }
}

String homePathForUser(User user) => homePathForRole(user.role);
