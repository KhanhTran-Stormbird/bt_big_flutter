import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void logNetworkError(String contextLabel, Object error, [StackTrace? stack]) {
  final buffer = StringBuffer('[API][$contextLabel] ');
  if (error is DioException) {
    final req = error.requestOptions;
    buffer.write('${req.method} ${req.uri} ');
    if (error.message?.isNotEmpty ?? false) {
      buffer.write('- ${error.message} ');
    }
    if (error.response != null) {
      buffer.write('-> ${error.response!.statusCode}');
    }
    debugPrint(buffer.toString());
    final data = error.response?.data;
    if (data != null) {
      debugPrint('[API][$contextLabel] response: $data');
    }
  } else {
    buffer.write(error.toString());
    debugPrint(buffer.toString());
  }
  if (stack != null) {
    debugPrint('[API][$contextLabel] stacktrace: $stack');
  }
}

void logAppError(String contextLabel, Object error, [StackTrace? stack]) {
  debugPrint('[APP][$contextLabel] $error');
  if (stack != null) {
    debugPrint('[APP][$contextLabel] stacktrace: $stack');
  }
}
