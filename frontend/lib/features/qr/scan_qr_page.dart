import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});
  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MobileScanner(onDetect: (capture) {
        if (handled) return;
        final raw = capture.barcodes.first.rawValue;
        if (raw != null) {
          handled = true;
          context.push('/capture', extra: raw); // tạm truyền raw json làm token
        }
      }),
      const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Quét QR buổi học',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}
