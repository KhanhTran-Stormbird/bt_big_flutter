import 'package:dio/dio.dart';

import '../../data/models/session_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';
import '../../core/constants.dart';

//TODO: Cái này mới là mock gọi API thôi, khi nào có API thì làm tử tế
class SessionRepo {
  late final Dio _dio;
  SessionRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<List<SessionModel>> listByClass(int classId) async {
    final res = await _dio.get('/classes/$classId/sessions');
    return (res.data as List).map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<String> getQrSvg(int sessionId) async {
    final res = await _dio.post('/sessions/$sessionId/qr');
    return res.data is String
        ? res.data as String
        : (res.data['svg'] as String);
  }
}
