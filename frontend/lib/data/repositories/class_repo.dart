import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/class_model.dart';
import '../../data/models/user.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class ClassRepo {
  late final Dio _dio;

  ClassRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<List<ClassModel>> list() async {
    return _wrap('list', () async {
      final res = await _dio.get('/classes');
      return (res.data as List).map((e) => ClassModel.fromJson(e)).toList();
    });
  }

  Future<ClassModel> detail(int id) async {
    return _wrap('detail', () async {
      final res = await _dio.get('/classes/$id');
      final data = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};
      return ClassModel.fromJson(data);
    });
  }

  Future<void> create({
    required String name,
    required String subject,
    required String term,
    required int lecturerId,
  }) async {
    await _wrap('create', () async {
      await _dio.post('/classes', data: {
        'name': name,
        'subject': subject,
        'term': term,
        'lecturer_id': lecturerId,
      });
    });
  }

  Future<void> update({
    required int id,
    required String name,
    required String subject,
    required String term,
    int? lecturerId,
  }) async {
    await _wrap('update', () async {
      await _dio.put('/classes/$id', data: {
        'name': name,
        'subject': subject,
        'term': term,
        if (lecturerId != null) 'lecturer_id': lecturerId,
      });
    });
  }

  Future<void> delete(int id) async {
    await _wrap('delete', () async {
      await _dio.delete('/classes/$id');
    });
  }

  Future<void> importStudents({
    required int classId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _wrap('importStudents', () async {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await _dio.post('/classes/$classId/students/import', data: form);
    });
  }

  Future<User> addStudent({
    required int classId,
    String? email,
    int? studentId,
  }) async {
    return _wrap('addStudent', () async {
      if ((email == null || email.isEmpty) && studentId == null) {
        throw ArgumentError('studentId hoặc email là bắt buộc');
      }
      final payload = <String, dynamic>{};
      if (email != null && email.isNotEmpty) payload['email'] = email;
      if (studentId != null) payload['student_id'] = studentId;
      final res =
          await _dio.post('/classes/$classId/students', data: payload);
      final data = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      final studentPayload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : data;
      return User.fromJson(studentPayload);
    });
  }

  Future<void> removeStudent({
    required int classId,
    required int studentId,
  }) async {
    await _wrap('removeStudent', () async {
      await _dio.delete('/classes/$classId/students/$studentId');
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('ClassRepo.$action', error, stack);
      rethrow;
    }
  }
}
