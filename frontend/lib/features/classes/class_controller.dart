import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';
import '../../data/models/class_model.dart';
import '../../data/repositories/class_repo.dart';

final classRepoProvider = Provider((ref) => ClassRepo());

final classListProvider =
    FutureProvider.autoDispose<List<ClassModel>>((ref) async {
  final repo = ref.watch(classRepoProvider);
  return repo.list();
});

final classDetailProvider =
    FutureProvider.autoDispose.family<ClassModel, int>((ref, id) async {
  final repo = ref.watch(classRepoProvider);
  return repo.detail(id);
});

class ClassActionController extends StateNotifier<AsyncValue<void>> {
  ClassActionController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  ClassRepo get _repo => ref.read(classRepoProvider);

  Future<bool> create({
    required String name,
    required String subject,
    required String term,
    int? lecturerId,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.create(
        name: name,
        subject: subject,
        term: term,
        lecturerId: lecturerId,
      );
    });
    return !state.hasError;
  }

  Future<bool> update({
    required int id,
    required String name,
    required String subject,
    required String term,
    int? lecturerId,
  }) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.update(
        id: id,
        name: name,
        subject: subject,
        term: term,
        lecturerId: lecturerId,
      );
    });
    return !state.hasError;
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _repo.delete(id));
    return !state.hasError;
  }

  Future<bool> importStudents({
    required int classId,
    required FilePickerResult result,
  }) async {
    final file = result.files.first;
    if (file.path == null) {
      final error = Exception('Khong the doc tep da chon');
      final stack = StackTrace.current;
      logAppError('ClassActionController.importStudents', error, stack);
      state = AsyncError(error, stack);
      return false;
    }
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      await _repo.importStudents(
        classId: classId,
        file: File(file.path!),
        fileName: file.name,
      );
    });
    return !state.hasError;
  }
}

final classActionControllerProvider =
    StateNotifierProvider.autoDispose<ClassActionController, AsyncValue<void>>(
  (ref) => ClassActionController(ref),
);
