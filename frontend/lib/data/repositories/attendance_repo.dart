import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

import '../../data/models/attendance_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';
import '../../core/constants.dart';

class AttendanceRepo {
  late final Dio _dio;
  AttendanceRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<String> scanQr(String qrJson) async {
    final res =
        await _dio.post('/attendance/scan-qr', data: {'qr_json': qrJson});
    return res.data['session_token'];
  }

  Future<AttendanceModel> checkIn(String sessionToken, XFile image) async {
    final form = FormData.fromMap({
      'session_token': sessionToken,
      'image': await MultipartFile.fromFile(image.path, filename: 'face.jpg'),
    });
    final res = await _dio.post('/attendance/check-in', data: form);
    return AttendanceModel.fromJson(res.data);
  }

  Future<List<AttendanceModel>> history({int? classId}) async {
    final res = await _dio
        .get('/attendance/history', queryParameters: {'class_id': classId});
    return (res.data as List).map((e) => AttendanceModel.fromJson(e)).toList();
  }
}
