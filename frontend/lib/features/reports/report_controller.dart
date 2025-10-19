import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/report_model.dart';
import '../../data/repositories/report_repo.dart';
import '../../core/utils/report_exporter.dart';

final reportRepoProvider = Provider((ref) => ReportRepo());

final reportSummaryProvider =
    FutureProvider.autoDispose.family<ReportSummary, int?>(
  (ref, classId) async {
    final repo = ref.watch(reportRepoProvider);
    return repo.summary(classId: classId);
  },
);

class ReportActionController extends StateNotifier<AsyncValue<void>> {
  ReportActionController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  ReportRepo get _repo => ref.read(reportRepoProvider);

  Future<String?> export({
    required String format,
    int? classId,
  }) async {
    state = const AsyncLoading<void>();
    String? path;
    state = await AsyncValue.guard(() async {
      final bytes = await _repo.export(format: format, classId: classId);
      path = await saveReportFile(bytes, format);
    });
    return path;
  }
}

final reportActionControllerProvider =
    StateNotifierProvider<ReportActionController, AsyncValue<void>>(
  (ref) => ReportActionController(ref),
);
