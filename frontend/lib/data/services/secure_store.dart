import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _k = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  static Future<void> saveToken(String t) => _k.write(key: _tokenKey, value: t);
  static Future<String?> token() => _k.read(key: _tokenKey);
  static Future<void> clear() => _k.deleteAll();
}
