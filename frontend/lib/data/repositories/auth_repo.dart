// lib/data/repositories/auth_repo.dart
// Mock trước một tài khoản sinh viên. Khi có API thật, đặt useMock=false.

import 'package:dio/dio.dart';

import '../models/user.dart'; // <- sửa path đúng
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';
import '../services/secure_store.dart';

class AuthRepo {
  // BẬT/TẮT MOCK Ở ĐÂY
  static const bool useMock = true;

  late final Dio _dio;
  AuthRepo() {
    final base = buildDio();
    final authDio = buildDio();
    authDio.interceptors.add(AuthInterceptor(authDio));
    base.interceptors.add(AuthInterceptor(authDio));
    _dio = base;
  }

  Future<void> login(String email, String password) async {
    if (useMock) {
      // Kiểm tra đúng tài khoản mock
      if (email.trim().toLowerCase() == 'student1@tlu.edu.vn' &&
          password == '12345678') {
        await SecureStore.saveToken('mock-access-token-student-1');
        return;
      }
      // Sai thông tin mock -> ném lỗi như API
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {'message': 'invalid credentials (mock)'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    // ====== API THẬT ======
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await SecureStore.saveToken(res.data['access_token']);
  }

  Future<User> me() async {
    if (useMock) {
      return User(
        id: 1,
        name: 'Student One',
        email: 'student1@tlu.edu.vn',
        role: 'student',
      );
    }

    // ====== API THẬT ======
    final res = await _dio.get('/me');
    return User.fromJson(res.data);
  }

  Future<void> logout() async {
    if (useMock) {
      await SecureStore.clear();
      return;
    }

    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await SecureStore.clear();
  }
}
