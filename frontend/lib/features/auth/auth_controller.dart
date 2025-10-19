import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_state.dart';
import '../../../core/utils/logger.dart';
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
      authStateNotifier.value = u;
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      logNetworkError('AuthController.login', e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepoProvider).logout();
    state = const AsyncData(null);
    authStateNotifier.value = null;
  }

  void loginAsMock({
    required int id,
    required String name,
    required String email,
    required String role,
  }) {
    final user = User(id: id, name: name, email: email, role: role);
    state = AsyncData(user);
    authStateNotifier.value = user;
  }
}
