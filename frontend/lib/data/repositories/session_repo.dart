import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/qr_payload.dart';
import '../../data/models/session_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class SessionRepo {
  late final Dio _dio;

  SessionRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<List<SessionModel>> listByClass(int classId) async {
    return _wrap('listByClass', () async {
      final res = await _dio.get('/classes/$classId/sessions');
      return (res.data as List).map((e) => SessionModel.fromJson(e)).toList();
    });
  }

  Future<void> create({
    required int classId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    await _wrap('create', () async {
      await _dio.post('/classes/$classId/sessions', data: {
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
      });
    });
  }

  Future<void> close(int sessionId) async {
    await _wrap('close', () async {
      await _dio.post('/sessions/$sessionId/close');
    });
  }

  Future<SessionModel> detail(int id) async {
    return _wrap('detail', () async {
      final res = await _dio.get('/sessions/$id');
      final data = res.data is Map<String, dynamic> && res.data['data'] != null
          ? Map<String, dynamic>.from(res.data['data'])
          : Map<String, dynamic>.from(res.data as Map);
      return SessionModel.fromJson(data);
    });
  }

  Future<QrPayload> issueQr(int sessionId) async {
    return _wrap('issueQr', () async {
      final res = await _dio.post('/sessions/$sessionId/qr');
      final raw = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : {'svg': res.data as String};
      return QrPayload.fromJson(
        raw..putIfAbsent('session_id', () => sessionId),
      );
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('SessionRepo.$action', error, stack);
      rethrow;
    }
  }
}
