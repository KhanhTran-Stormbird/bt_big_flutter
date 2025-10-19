import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/utils/error_message.dart';
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
    } catch (error) {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Quét mã QR'),
        centerTitle: true,
      ),
      body: Stack(
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
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: scanning ? Colors.greenAccent : Colors.white,
                  width: 4,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: scanning ? null : () {},
                child: const Text('Chọn hình QR có sẵn'),
              ),
            ),
          ),
          if (scanning)
            const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
