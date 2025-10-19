import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/repositories/user_repo.dart';

final userRepoProvider = Provider((ref) => UserRepo());

class UserQuery {
  final String? role;
  final String? keyword;

  const UserQuery({this.role, this.keyword});

  UserQuery copyWith({
    String? role,
    bool setRole = false,
    String? keyword,
    bool setKeyword = false,
  }) =>
      UserQuery(
        role: setRole ? role : (role ?? this.role),
        keyword: setKeyword ? keyword : (keyword ?? this.keyword),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserQuery &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          keyword == other.keyword;

  @override
  int get hashCode => Object.hash(role, keyword);
}

final userListProvider =
    FutureProvider.autoDispose.family<List<User>, UserQuery>((ref, query) {
  final repo = ref.watch(userRepoProvider);
  return repo.list(role: query.role, keyword: query.keyword);
});

class UserActionController extends StateNotifier<AsyncValue<void>> {
  UserActionController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  UserRepo get _repo => ref.read(userRepoProvider);

  Future<bool> create({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.create(
        name: name,
        email: email,
        role: role,
        password: password,
      );
    });
    return !state.hasError;
  }

  Future<bool> update({
    required int id,
    String? name,
    String? email,
    String? role,
    String? password,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.update(
        id: id,
        name: name,
        email: email,
        role: role,
        password: password,
      );
    });
    return !state.hasError;
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _repo.delete(id));
    return !state.hasError;
  }
}

final userActionControllerProvider =
    StateNotifierProvider<UserActionController, AsyncValue<void>>(
  (ref) => UserActionController(ref),
);
