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
        appBar: AppBar(title: const Text('Chi tiet buoi hoc')),
        body: ErrorView(
          message: extractErrorMessage(sessionAsync.error!),
          onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
        ),
      );
    }
    if (sessionAsync.isLoading && session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiet buoi hoc')),
        body: const LoadingView(message: 'Dang tai thong tin buoi hoc...'),
      );
    }
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiet buoi hoc')),
        body: const ErrorView(message: 'Khong tim thay thong tin buoi hoc.'),
      );
    }

    Future<void> closeSession() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Dong buoi hoc'),
          content: const Text('Ban co chac muon dong buoi nay?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Huy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Dong'),
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
                    'Thong tin buoi hoc',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text('Lop: ${session.classId}'),
                  Text('Bat dau: ${formatter.format(session.startsAt)}'),
                  Text('Ket thuc: ${formatter.format(session.endsAt)}'),
                  Text('Trang thai: ${_statusLabel(session.status)}'),
                  if (session.qrTtl != null)
                    Text('QR TTL: ${session.qrTtl} phut'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.push('/sessions/$sessionId/qr', extra: session),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Xem ma QR'),
          ),
          const SizedBox(height: 12),
          if (canManage && session.status != 'closed')
            OutlinedButton.icon(
              onPressed: closeSession,
              icon: const Icon(Icons.lock),
              label: const Text('Dong buoi'),
            ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'open':
      return 'Dang dien ra';
    case 'closed':
      return 'Da dong';
    case 'scheduled':
    default:
      return 'Chua bat dau';
  }
}
