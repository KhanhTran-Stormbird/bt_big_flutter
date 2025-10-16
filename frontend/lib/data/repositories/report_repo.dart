import 'package:dio/dio.dart';

import '../../data/models/report_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';

//TODO: Cái này mới là mock gọi API thôi, khi nào có API thì làm tử tế
class ReportRepo {
  late final Dio _dio;
  ReportRepo() {
    _dio = buildDio()..interceptors.add(AuthInterceptor(buildDio()));
  }

  Future<ReportSummary> summary({int? classId}) async {
    final res = await _dio
        .get('/reports/attendance', queryParameters: {'class_id': classId});
    return ReportSummary.fromJson(res.data);
  }
}
