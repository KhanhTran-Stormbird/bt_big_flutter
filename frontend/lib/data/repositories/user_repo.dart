import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class UserRepo {
  UserRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  late final Dio _dio;

  Future<List<User>> list({String? role, String? keyword}) async {
    return _wrap('list', () async {
      final query = <String, dynamic>{};
      if (role != null && role.isNotEmpty) {
        query['role'] = role;
      }
      if (keyword != null && keyword.isNotEmpty) {
        query['q'] = keyword;
      }
      final res = await _dio.get('/users', queryParameters: query);
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

  Future<User> create({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    return _wrap('create', () async {
      final res = await _dio.post('/users', data: {
        'name': name,
        'email': email,
        'role': role,
        'password': password,
      });
      final data = res.data;
      final map = data is Map<String, dynamic> && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return User.fromJson(map);
    });
  }

  Future<User> update({
    required int id,
    String? name,
    String? email,
    String? role,
    String? password,
  }) async {
    return _wrap('update', () async {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (email != null) payload['email'] = email;
      if (role != null) payload['role'] = role;
      if (password != null && password.isNotEmpty) {
        payload['password'] = password;
      }
      final res = await _dio.put('/users/$id', data: payload);
      final data = res.data;
      final map = data is Map<String, dynamic> && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : Map<String, dynamic>.from(data as Map);
      return User.fromJson(map);
    });
  }

  Future<void> delete(int id) async {
    await _wrap('delete', () async {
      await _dio.delete('/users/$id');
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('UserRepo.$action', error, stack);
      rethrow;
    }
  }
}
