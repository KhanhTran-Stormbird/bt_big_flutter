import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/class_model.dart';
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
      return ClassModel.fromJson(res.data);
    });
  }

  Future<void> create({
    required String name,
    required String subject,
    required String term,
  }) async {
    await _wrap('create', () async {
      await _dio.post('/classes', data: {
        'name': name,
        'subject': subject,
        'term': term,
      });
    });
  }

  Future<void> update({
    required int id,
    required String name,
    required String subject,
    required String term,
  }) async {
    await _wrap('update', () async {
      await _dio.put('/classes/$id', data: {
        'name': name,
        'subject': subject,
        'term': term,
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
    required File file,
    required String fileName,
  }) async {
    await _wrap('importStudents', () async {
      final form = FormData.fromMap({
        'csv': await MultipartFile.fromFile(file.path, filename: fileName),
      });
      await _dio.post('/classes/$classId/students/import', data: form);
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
