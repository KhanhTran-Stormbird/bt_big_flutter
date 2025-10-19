import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/utils/error_message.dart';
import '../../core/utils/report_exporter.dart';
import '../../core/utils/toast.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/class_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/user.dart';
import '../auth/auth_controller.dart';
import '../sessions/session_controller.dart';
import '../sessions/widgets/session_form_sheet.dart';
import 'class_controller.dart';
import 'widgets/class_student_form_sheet.dart';

class ClassDetailPage extends ConsumerWidget {
  final int classId;
  final ClassModel? initial;
  const ClassDetailPage({
    super.key,
    required this.classId,
    this.initial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(classDetailProvider(classId));
    final classData = detailAsync.maybeWhen(
      data: (value) => value,
      orElse: () => initial,
    );
    final authState = ref.watch(authControllerProvider);
    final role = authState.value?.role.toLowerCase();
    final canManageSessions = role == C.roleAdmin || role == C.roleLecturer;

    if (detailAsync.hasError && classData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lớp học')),
        body: ErrorView(
          message: extractErrorMessage(detailAsync.error!),
          onRetry: () => ref.invalidate(classDetailProvider(classId)),
        ),
      );
    }

    if (detailAsync.isLoading && classData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lớp học')),
        body: const LoadingView(message: 'Đang tải thông tin lớp học...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(classData?.name ?? 'Chi tiết lớp học')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(classDetailProvider(classId));
          ref.invalidate(sessionListProvider(classId));
          await Future.wait([
            ref.read(classDetailProvider(classId).future),
            ref.read(sessionListProvider(classId).future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _ClassInfoCard(model: classData, loading: detailAsync.isLoading),
            const SizedBox(height: 16),
            ClassStudentsSection(
              classId: classId,
              students: classData?.students ?? const [],
              loading: detailAsync.isLoading,
              canManage: canManageSessions,
            ),
            const SizedBox(height: 16),
            SessionListSection(
              classId: classId,
              canManage: canManageSessions,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassInfoCard extends StatelessWidget {
  final ClassModel? model;
  final bool loading;
  const _ClassInfoCard({this.model, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading && model == null) {
      return const LoadingView(message: 'Đang tải thông tin lớp học...');
    }
    if (model == null) {
      return const EmptyView(message: 'Không tìm thấy thông tin lớp.');
    }
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              model!.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Môn học: ${model!.subject}'),
            Text('Học kỳ: ${model!.term}'),
            if ((model!.lecturerName ?? '').isNotEmpty)
              Text(
                'Giảng viên: ${model!.lecturerName}'
                '${(model!.lecturerEmail ?? '').isNotEmpty ? ' (${model!.lecturerEmail})' : ''}',
              ),
          ],
        ),
      ),
    );
  }
}

class ClassStudentsSection extends ConsumerWidget {
  final int classId;
  final List<User> students;
  final bool loading;
  final bool canManage;

  const ClassStudentsSection({
    super.key,
    required this.classId,
    required this.students,
    required this.loading,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(classActionControllerProvider);
    final busy = actionState.isLoading;

    Future<void> _openForm({User? initial}) async {
      final result = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ClassStudentFormSheet(
          classId: classId,
          initial: initial,
        ),
      );
      if (result == null || result == 'noop') return;
      final message = switch (result) {
        'added' => 'Đã thêm sinh viên vào lớp',
        'updated' => 'Đã cập nhật sinh viên',
        _ => null,
      };
      if (message != null) showSuccessToast(context, message);
    }

    Future<void> _importCsv() async {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
      if (result == null) return;
      final notifier = ref.read(classActionControllerProvider.notifier);
      final ok = await notifier.importStudents(
        classId: classId,
        result: result,
      );
      final state = ref.read(classActionControllerProvider);
      if (ok) {
        showSuccessToast(context, 'Đã nhập danh sách sinh viên');
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(state.error!))),
        );
      }
    }

    /// ✅ Fix: Dùng '\r\n' để Excel và các app đọc CSV hiểu xuống dòng đúng
    Future<void> _downloadTemplate() async {
      const template =
          'name,email\r\nNguyen Van A,sinhvien1@example.com\r\nTran Thi B,sinhvien2@example.com\r\n';
      try {
        final bytes = Uint8List.fromList(utf8.encode(template));
        final path = await saveReportFile(bytes, 'csv');
        showSuccessToast(
          context,
          path != null
              ? 'Đã lưu mẫu import: $path'
              : 'Đã tải mẫu import CSV',
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(error))),
        );
      }
    }

    Future<void> _removeStudent(User student) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xóa khỏi lớp'),
          content: Text('Bạn có chắc muốn xóa ${student.name} khỏi lớp?'),
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
      if (confirmed != true) return;

      final notifier = ref.read(classActionControllerProvider.notifier);
      final ok = await notifier.removeStudent(
        classId: classId,
        studentId: student.id,
      );
      final state = ref.read(classActionControllerProvider);

      if (ok) {
        showSuccessToast(context, 'Đã xóa sinh viên khỏi lớp');
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractErrorMessage(state.error!))),
        );
      }
    }

    // phần UI (giữ nguyên như cũ)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Sinh viên trong lớp',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (canManage)
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : () => _openForm(),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Thêm'),
                  ),
                  TextButton.icon(
                    onPressed: busy ? null : _importCsv,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Nhập CSV'),
                  ),
                  TextButton.icon(
                    onPressed: busy ? null : _downloadTemplate,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Mẫu CSV'),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (busy) const LinearProgressIndicator(),
        if (loading && students.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (students.isEmpty)
          const EmptyView(message: 'Chưa có sinh viên nào trong lớp.')
        else
          ...students.map((student) {
            final parts = student.name.trim().split(RegExp(r'\s+'));
            final initials =
                parts.isEmpty ? '?' : parts.take(2).map((p) => p[0]).join();
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(initials.toUpperCase()),
                ),
                title: Text(
                  student.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(student.email),
                trailing: canManage
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _openForm(initial: student);
                          if (value == 'delete') _removeStudent(student);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Thay đổi')),
                          PopupMenuItem(value: 'delete', child: Text('Xóa')),
                        ],
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }
}

class SessionListSection extends ConsumerWidget {
  final int classId;
  final bool canManage;
  const SessionListSection({
    super.key,
    required this.classId,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionListProvider(classId));
    return sessionsAsync.when(
      data: (sessions) => _SessionListContent(
        classId: classId,
        sessions: sessions,
        canManage: canManage,
      ),
      loading: () =>
          const LoadingView(message: 'Đang tải danh sách buổi học...'),
      error: (error, _) => ErrorView(
        message: extractErrorMessage(error),
        onRetry: () => ref.invalidate(sessionListProvider(classId)),
      ),
    );
  }
}

class _SessionListContent extends ConsumerWidget {
  final int classId;
  final List<SessionModel> sessions;
  final bool canManage;
  const _SessionListContent({
    required this.classId,
    required this.sessions,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    Future<void> openCreateSession() async {
      final result = await showModalBottomSheet<int?>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SessionFormSheet(classId: classId),
      );
      if (!context.mounted || result == null || result <= 0) return;
      try {
        await ref.refresh(sessionListProvider(classId).future);
      } catch (_) {}
      if (!context.mounted) return;
      showSuccessToast(
        context,
        result == 1 ? 'Đã tạo 1 buổi học' : 'Đã tạo $result buổi học',
      );
      ref.invalidate(classDetailProvider(classId));
    }

    Future<void> closeSession(SessionModel session) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đóng buổi học'),
          content: Text('Bạn có chắc muốn đóng buổi ${session.id}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      final notifier = ref.read(sessionActionControllerProvider.notifier);
      final ok = await notifier.close(
        classId: classId,
        sessionId: session.id,
      );
      if (!context.mounted) return;
      final state = ref.read(sessionActionControllerProvider);
      if (ok) {
        showSuccessToast(context, 'Đã đóng buổi #${session.id}');
      } else if (state.hasError) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text(extractErrorMessage(state.error!))),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Danh sách buổi học',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (canManage)
              TextButton.icon(
                onPressed: openCreateSession,
                icon: const Icon(Icons.add),
                label: const Text('Tạo buổi'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          EmptyView(
            message: 'Chưa có buổi học nào.',
            action: canManage
                ? FilledButton(
                    onPressed: openCreateSession,
                    child: const Text('Tạo buổi đầu tiên'),
                  )
                : null,
          )
        else
          ...sessions.map((s) {
            final statusLabel = _statusLabel(s.status);
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  '${formatter.format(s.startsAt)} - ${formatter.format(s.endsAt)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text('Trạng thái: $statusLabel'),
                onTap: () => context.push('/sessions/${s.id}', extra: s),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code_2),
                      tooltip: 'Mã QR',
                      onPressed: () =>
                          context.push('/sessions/${s.id}/qr', extra: s),
                    ),
                    if (canManage && s.status != 'closed')
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'close') {
                            closeSession(s);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'close',
                            child: Text('Đóng buổi'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Đang diễn ra';
    case 'closed':
      return 'Đã đóng';
    case 'scheduled':
    default:
      return 'Chưa bắt đầu';
  }
}

