import 'package:dio/dio.dart';

import 'secure_store.dart';

class AuthInterceptor extends Interceptor {
  final Dio authDio;
  AuthInterceptor(this.authDio);

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final t = await SecureStore.token();
    if (t != null) o.headers['Authorization'] = 'Bearer $t';
    h.next(o);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler h) async {
    final sc = err.response?.statusCode ?? 0;
    final isRefresh = err.requestOptions.path.contains('/auth/refresh');
    if (sc == 401 && !isRefresh) {
      try {
        final res = await authDio.post('/auth/refresh');
        final nt = res.data['access_token'] as String?;
        if (nt != null) {
          await SecureStore.saveToken(nt);
          err.requestOptions.headers['Authorization'] = 'Bearer $nt';
          final retry = await authDio.fetch(err.requestOptions);
          return h.resolve(retry);
        }
      } catch (_) {}
    }
    h.next(err);
  }
}
