import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class LecturerRepo {
  LecturerRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  late final Dio _dio;

  Future<List<User>> list() async {
    return _wrap('list', () async {
      final res = await _dio.get('/users', queryParameters: {
        'role': C.roleLecturer,
      });
      final data = res.data;
      List<dynamic> items = const [];
      if (data is Map<String, dynamic> && data['data'] is List) {
        items = List<dynamic>.from(data['data'] as List);
      } else if (data is List) {
        items = List<dynamic>.from(data);
      }
      return items
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('LecturerRepo.$action', error, stack);
      rethrow;
    }
  }
}
