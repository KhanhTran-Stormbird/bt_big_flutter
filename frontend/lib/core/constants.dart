import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class C {
  // Smart default for local dev across platforms
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'] ?? '';
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:8080/api/v1';
    // Android emulator cannot reach host localhost
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }

  static bool get devAuthBypass {
    final raw = (dotenv.env['DEV_AUTH_BYPASS'] ?? 'false').toLowerCase().trim();
    return raw == '1' || raw == 'true' || raw == 'yes';
  }

  static const roleStudent = 'student';
  static const roleLecturer = 'lecturer';
  static const roleAdmin = 'admin';
}

enum AttStatus { present, absent, suspect }
