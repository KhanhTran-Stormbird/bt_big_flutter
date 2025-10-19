import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/repositories/lecturer_repo.dart';

final lecturerRepoProvider = Provider((ref) => LecturerRepo());

final lecturerListProvider =
    FutureProvider.autoDispose<List<User>>((ref) async {
  final repo = ref.watch(lecturerRepoProvider);
  return repo.list();
});
