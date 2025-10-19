import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/utils/error_message.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/class_model.dart';
import '../auth/auth_controller.dart';
import 'class_controller.dart';
import 'widgets/class_form_sheet.dart';

class ClassListPage extends ConsumerStatefulWidget {
  const ClassListPage({super.key});

  @override
  ConsumerState<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends ConsumerState<ClassListPage> {
  int? workingClassId;

  Future<void> _openClassForm({ClassModel? initial}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ClassFormSheet(initial: initial),
    );
    if (result == true && mounted) {
      ref.invalidate(classListProvider);
    }
  }

  Future<void> _confirmDelete(ClassModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa lop hoc'),
        content: Text('Ban co chac muon xoa "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xoa'),
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
      messenger.showSnackBar(const SnackBar(content: Text('Da xoa lop hoc')));
      ref.invalidate(classListProvider);
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  Future<void> _importCsv(ClassModel item) async {
    final result = await FilePicker.platform.pickFiles(
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
      messenger.showSnackBar(
        SnackBar(content: Text('Da import sinh vien cho ${item.name}')),
      );
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
        onRefresh: () async {
          ref.invalidate(classListProvider);
          await ref.read(classListProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (isAdmin) _AdminActions(onCreate: () => _openClassForm()),
            if (classes.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: EmptyView(message: 'Chua co lop hoc nao.'),
              )
            else
              ...classes.map((item) {
                final busy = workingClassId == item.id;
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.subject} - ${item.term}'),
                    onTap: () =>
                        context.push('/classes/${item.id}', extra: item),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (busy)
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (!busy && isAdmin)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _openClassForm(initial: item);
                                  break;
                                case 'import':
                                  _importCsv(item);
                                  break;
                                case 'delete':
                                  _confirmDelete(item);
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Chinh sua'),
                              ),
                              PopupMenuItem(
                                value: 'import',
                                child: Text('Import CSV'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Xoa'),
                              ),
                            ],
                          ),
                        if (!busy) const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      loading: () =>
          const LoadingView(message: 'Dang tai danh sach lop hoc...'),
      error: (error, _) => ErrorView(
        message: extractErrorMessage(error),
        onRetry: () => ref.invalidate(classListProvider),
      ),
    );
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
              label: const Text('Them lop hoc'),
            ),
          ),
        ],
      ),
    );
  }
}
