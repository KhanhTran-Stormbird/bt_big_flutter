import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/utils/error_message.dart';
import '../../core/utils/toast.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/session_model.dart';
import '../auth/auth_controller.dart';
import 'session_controller.dart';

class SessionDetailPage extends ConsumerWidget {
  final int sessionId;
  final SessionModel? initial;
  const SessionDetailPage({
    super.key,
    required this.sessionId,
    this.initial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));
    final session = sessionAsync.maybeWhen(
      data: (value) => value,
      orElse: () => initial,
    );
    final authState = ref.watch(authControllerProvider);
    final role = authState.value?.role.toLowerCase();
    final canManage = role == C.roleAdmin || role == C.roleLecturer;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    if (sessionAsync.hasError && session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết buổi học')),
        body: ErrorView(
          message: extractErrorMessage(sessionAsync.error!),
          onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
        ),
      );
    }
    if (sessionAsync.isLoading && session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết buổi học')),
        body: const LoadingView(message: 'Đang tải thông tin buổi học...'),
      );
    }
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết buổi học')),
        body: const ErrorView(message: 'Không tìm thấy thông tin buổi học...'),
      );
    }

    Future<void> closeSession() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đóng buổi học'),
          content: const Text('Bạn có chắc muốn đóng buổi học này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Huỷ'),
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
        classId: session.classId,
        sessionId: sessionId,
      );
      if (!context.mounted) return;
      final state = ref.read(sessionActionControllerProvider);
        final messenger = ScaffoldMessenger.of(context);
        if (ok) {
          showSuccessToast(context, 'Đã đóng buổi học');
        } else if (state.hasError) {
        messenger.showSnackBar(
          SnackBar(content: Text(extractErrorMessage(state.error!))),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Buoi #${session.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin buổi học',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text('Lớp: ${session.classId}'),
                  Text('Bắt đầu: ${formatter.format(session.startsAt)}'),
                  Text('Kết thúc: ${formatter.format(session.endsAt)}'),
                  Text('Trạng thái: ${_statusLabel(session.status)}'),
                  if (session.qrTtl != null)
                    Text('Hiệu lực của QR: ${session.qrTtl} phút'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.push('/sessions/$sessionId/qr', extra: session),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Xem mã QR'),
          ),
          const SizedBox(height: 12),
          if (canManage && session.status != 'closed')
            OutlinedButton.icon(
              onPressed: closeSession,
              icon: const Icon(Icons.lock),
              label: const Text('Đóng buổi'),
            ),
        ],
      ),
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
