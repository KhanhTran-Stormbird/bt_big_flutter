import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/utils/error_message.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../sessions/session_controller.dart';

class SessionQrPage extends ConsumerWidget {
  final int sessionId;
  const SessionQrPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(sessionQrProvider(sessionId));
    return Scaffold(
      appBar: AppBar(
        title: Text('QR buổi #$sessionId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(sessionQrProvider(sessionId)),
          ),
        ],
      ),
      body: qrAsync.when(
        data: (qr) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (qr.svg.isNotEmpty)
                  SvgPicture.string(
                    qr.svg,
                    width: 240,
                    height: 240,
                  )
                else
                  const Text('Không có dữ liệu QR'),
                const SizedBox(height: 16),
                Text('Hiệu lực: ${qr.ttl} phút'),
              ],
            ),
          ),
        ),
        loading: () =>
            const LoadingView(message: 'Đang sinh mã QR cho buổi học...'),
        error: (error, _) => ErrorView(
          message: extractErrorMessage(error),
          onRetry: () => ref.invalidate(sessionQrProvider(sessionId)),
        ),
      ),
    );
  }
}
