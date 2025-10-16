import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repo.dart';

final authRepoProvider = Provider((_) => AuthRepo());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncData(null));

  Future<bool> login(String email, String password) async {
    try {
      state = const AsyncLoading();
      await ref.read(authRepoProvider).login(email, password);
      final u = await ref.read(authRepoProvider).me();
      state = AsyncData(u);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepoProvider).logout();
    state = const AsyncData(null);
  }
}
