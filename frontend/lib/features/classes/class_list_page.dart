import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/error_message.dart';
import '../../core/utils/toast.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/class_model.dart';
import '../auth/auth_controller.dart';
import 'class_controller.dart';
import 'widgets/class_form_sheet.dart';
import '../sessions/widgets/session_form_sheet.dart';

class ClassListPage extends ConsumerStatefulWidget {
  const ClassListPage({super.key});

  @override
  ConsumerState<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends ConsumerState<ClassListPage> {
  int? workingClassId;

  Future<void> _openClassForm({ClassModel? initial}) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ClassFormSheet(initial: initial),
    );
    if (!mounted) return;
    if (result == null) return;

    await _refreshClasses();

    if (!mounted) return;
    switch (result) {
      case 'created':
        showSuccessToast(context, 'Đã tạo lớp học');
        break;
      case 'updated':
        showSuccessToast(context, 'Đã cập nhật lớp học');
        break;
    }
  }

  Future<void> _createSession(ClassModel item) async {
    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SessionFormSheet(classId: item.id),
    );
    if (!mounted) return;
    if (result != null && result > 0) {
      await _refreshClasses();
      showSuccessToast(
        context,
        result == 1
            ? 'Đã tạo 1 buổi học'
            : 'Đã tạo $result buổi học',
      );
      ref.invalidate(classDetailProvider(item.id));
    }
  }

  Future<void> _confirmDelete(ClassModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa lớp học'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => workingClassId = item.id);
    final notifier = ref.read(classActionControllerProvider.notifier);
    final ok = await notifier.delete(item.id);
    final state = ref.read(classActionControllerProvider);
    if (!mounted) return;
    setState(() => workingClassId = null);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      await _refreshClasses();
      if (mounted) {
        showSuccessToast(context, 'Đã xóa lớp học');
      }
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  Future<void> _importCsv(ClassModel item) async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
    if (result == null || !mounted) return;
    setState(() => workingClassId = item.id);
    final notifier = ref.read(classActionControllerProvider.notifier);
    final ok = await notifier.importStudents(
      classId: item.id,
      result: result,
    );
    final state = ref.read(classActionControllerProvider);
    if (!mounted) return;
    setState(() => workingClassId = null);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      await _refreshClasses();
      if (mounted) {
        showSuccessToast(
          context,
          'Đã nhập danh sách sinh viên cho ${item.name}',
        );
      }
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classListProvider);
    final authState = ref.watch(authControllerProvider);
    final role = authState.value?.role.toLowerCase();
    final isAdmin = role == C.roleAdmin;

    return classesAsync.when(
      data: (classes) => RefreshIndicator(
        onRefresh: _refreshClasses,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (isAdmin) _AdminActions(onCreate: () => _openClassForm()),
            if (classes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: EmptyView(message: 'Chưa có lớp học nào.'),
              )
            else
              ...classes.map((item) {
                final busy = workingClassId == item.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () =>
                        context.push('/classes/${item.id}', extra: item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: const Icon(Icons.menu_book,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.subject} • ${item.term}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                                if ((item.lecturerName ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Giảng viên: ${item.lecturerName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textPrimary
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (busy)
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (isAdmin)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _openClassForm(initial: item);
                                    break;
                                  case 'import':
                                    _importCsv(item);
                                    break;
                                  case 'session':
                                    _createSession(item);
                                    break;
                                  case 'delete':
                                    _confirmDelete(item);
                                    break;
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Chỉnh sửa'),
                                ),
                                PopupMenuItem(
                                  value: 'import',
                                  child: Text('Nhập CSV'),
                                ),
                                PopupMenuItem(
                                  value: 'session',
                                  child: Text('Tạo lịch học'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            )
                          else
                            const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      loading: () =>
          const LoadingView(message: 'Đang tải danh sách lớp học...'),
      error: (error, _) => ErrorView(
        message: extractErrorMessage(error),
        onRetry: () => ref.invalidate(classListProvider),
      ),
    );
  }

  Future<void> _refreshClasses() async {
    try {
      await ref.refresh(classListProvider.future);
    } catch (_) {
      // Let the UI provider surface the error via ErrorView.
    }
  }
}

class _AdminActions extends StatelessWidget {
  final VoidCallback onCreate;
  const _AdminActions({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Thêm lớp học'),
            ),
          ),
        ],
      ),
    );
  }
}

