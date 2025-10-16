import 'package:dio/dio.dart';

import '../../data/models/class_model.dart';
import '../services/api_client.dart';
import '../services/auth_interceptor.dart';
import '../../core/constants.dart';

//TODO: Cái này mới là mock gọi API thôi, khi nào có API thì làm tử tế
class ClassRepo {
  late final Dio _dio;
  ClassRepo() {
    _dio = buildDio();
    if (!C.devAuthBypass) {
      _dio.interceptors.add(AuthInterceptor(buildDio()));
    }
  }

  Future<List<ClassModel>> list() async {
    final res = await _dio.get('/classes');
    return (res.data as List).map((e) => ClassModel.fromJson(e)).toList();
    // dev: return []; // nếu chưa có API
  }

  Future<ClassModel> detail(int id) async {
    final res = await _dio.get('/classes/$id');
    return ClassModel.fromJson(res.data);
  }
}
