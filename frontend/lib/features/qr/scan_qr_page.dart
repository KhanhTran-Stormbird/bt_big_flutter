import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/utils/error_message.dart';
import '../../core/utils/logger.dart';
import '../attendance/attendance_controller.dart';

class ScanQrPage extends ConsumerStatefulWidget {
  const ScanQrPage({super.key});

  @override
  ConsumerState<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends ConsumerState<ScanQrPage> {
  bool handled = false;
  bool scanning = false;

  Future<void> _handleScan(String raw) async {
    setState(() {
      handled = true;
      scanning = true;
    });
    final repo = ref.read(attendanceRepoProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final token = await repo.scanQr(raw);
      if (!mounted) return;
      await context.push('/capture', extra: token);
    } catch (error, stack) {
      logNetworkError('ScanQrPage._handleScan', error, stack);
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() {
          scanning = false;
          handled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            if (handled) return;
            final barcode = capture.barcodes.firstWhere(
              (b) => b.rawValue != null,
              orElse: () => capture.barcodes.first,
            );
            final raw = barcode.rawValue;
            if (raw != null) {
              _handleScan(raw);
            }
          },
        ),
        const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Quet ma QR cua buoi hoc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (scanning)
          Container(
            color: Colors.black54,
            child: const Center(
              child: SizedBox(
                height: 64,
                width: 64,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
