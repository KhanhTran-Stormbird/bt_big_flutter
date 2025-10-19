import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/report_model.dart';
import '../../data/repositories/report_repo.dart';

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
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.$format';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      path = file.path;
    });
    if (!state.hasError && path != null) {
      await OpenFilex.open(path!);
    }
    return path;
  }
}

final reportActionControllerProvider =
    StateNotifierProvider.autoDispose<ReportActionController, AsyncValue<void>>(
  (ref) => ReportActionController(ref),
);
