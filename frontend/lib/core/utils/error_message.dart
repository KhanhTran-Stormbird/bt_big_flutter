import 'package:dio/dio.dart';

String extractErrorMessage(Object error, {String fallback = 'Đã xảy ra lỗi'}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'] ?? data['error'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
  }
  final text = error.toString();
  if (text.isNotEmpty) return text;
  return fallback;
}
