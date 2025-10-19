import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/qr_payload.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repo.dart';

final sessionRepoProvider = Provider((ref) => SessionRepo());

final sessionListProvider =
    FutureProvider.autoDispose.family<List<SessionModel>, int>(
  (ref, classId) async {
    final repo = ref.watch(sessionRepoProvider);
    return repo.listByClass(classId);
  },
);

final sessionDetailProvider =
    FutureProvider.autoDispose.family<SessionModel, int>(
  (ref, sessionId) async {
    final repo = ref.watch(sessionRepoProvider);
    return repo.detail(sessionId);
  },
);

final sessionQrProvider =
    FutureProvider.autoDispose.family<QrPayload, int>((ref, sessionId) async {
  final repo = ref.watch(sessionRepoProvider);
  return repo.issueQr(sessionId);
});

class SessionActionController extends StateNotifier<AsyncValue<void>> {
  SessionActionController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  SessionRepo get _repo => ref.read(sessionRepoProvider);

  Future<bool> create({
    required int classId,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.create(
        classId: classId,
        startsAt: startsAt,
        endsAt: endsAt,
      );
      ref.invalidate(sessionListProvider(classId));
    });
    return !state.hasError;
  }

  Future<bool> close({
    required int classId,
    required int sessionId,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.close(sessionId);
      ref.invalidate(sessionListProvider(classId));
      ref.invalidate(sessionDetailProvider(sessionId));
    });
    return !state.hasError;
  }
}

final sessionActionControllerProvider = StateNotifierProvider.autoDispose<
    SessionActionController,
    AsyncValue<void>>((ref) => SessionActionController(ref));
