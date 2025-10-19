import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repo.dart';

final attendanceRepoProvider = Provider((ref) => AttendanceRepo());

final attendanceHistoryProvider =
    FutureProvider.autoDispose.family<List<AttendanceModel>, int?>(
  (ref, classId) async {
    final repo = ref.watch(attendanceRepoProvider);
    return repo.history(classId: classId);
  },
);
