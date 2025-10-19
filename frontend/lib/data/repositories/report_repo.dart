import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/report_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

class ReportRepo {
  late final Dio _dio;

  ReportRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<ReportSummary> summary({int? classId}) async {
    return _wrap('summary', () async {
      final query = <String, dynamic>{};
      if (classId != null) query['class_id'] = classId;
      final res =
          await _dio.get('/reports/attendance', queryParameters: query);
      return ReportSummary.fromJson(res.data);
    });
  }

  Future<Uint8List> export({
    required String format,
    int? classId,
  }) async {
    return _wrap('export', () async {
      final query = <String, dynamic>{};
      if (classId != null) query['class_id'] = classId;
      final res = await _dio.get(
        '/reports/attendance/$format',
        queryParameters: query,
        options: Options(responseType: ResponseType.bytes),
      );

      if (res.data is Uint8List) {
        return res.data as Uint8List;
      }
      if (res.data is List<int>) {
        return Uint8List.fromList(res.data as List<int>);
      }
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Invalid export response',
      );
    });
  }

  Future<T> _wrap<T>(String action, Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (error, stack) {
      logNetworkError('ReportRepo.$action', error, stack);
      rethrow;
    }
  }
}
