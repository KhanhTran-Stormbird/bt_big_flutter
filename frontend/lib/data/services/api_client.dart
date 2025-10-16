import 'package:dio/dio.dart';

import '../../core/constants.dart';

Dio buildDio() => Dio(BaseOptions(
      baseUrl: C.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ));
