import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/attendance_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class AttendanceRepo {
  late final Dio _dio;
  AttendanceRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<String> scanQr(String qrJson) async {
    return _wrap('scanQr', () async {
      final res =
          await _dio.post('/attendance/scan-qr', data: {'qr_json': qrJson});
      return res.data['session_token'];
    });
  }

  Future<AttendanceModel> checkIn(String sessionToken, XFile image) async {
    return _wrap('checkIn', () async {
      final form = FormData.fromMap({
        'session_token': sessionToken,
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'face.jpg',
        ),
      });
      final res = await _dio.post('/attendance/check-in', data: form);
      return AttendanceModel.fromJson(res.data);
    });
  }

  Future<List<AttendanceModel>> history({int? classId}) async {
    return _wrap('history', () async {
      final query = <String, dynamic>{};
      if (classId != null) query['class_id'] = classId;
      final res = await _dio.get('/attendance/history', queryParameters: query);
      return (res.data as List)
          .map((e) => AttendanceModel.fromJson(e))
          .toList();
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('AttendanceRepo.$action', error, stack);
      rethrow;
    }
  }
}
