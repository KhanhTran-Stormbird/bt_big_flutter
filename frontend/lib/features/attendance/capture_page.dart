import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/error_message.dart';
import '../../core/widgets/error_view.dart';
import '../attendance/attendance_controller.dart';

class CapturePage extends ConsumerStatefulWidget {
  final String? sessionToken;
  const CapturePage({super.key, this.sessionToken});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool initializing = true;
  bool busy = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.sessionToken == null) {
      setState(() {
        error = 'Thiếu session token.';
        initializing = false;
      });
      return;
    }
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        error = 'Cần cấp quyền camera để điểm danh.';
        initializing = false;
      });
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          error = 'Không tìm thấy camera.';
          initializing = false;
        });
        return;
      }
      final cam = cameras.first;
      final ctrl = CameraController(
        cam,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        controller = ctrl;
        initializing = false;
      });
    } catch (e) {
      setState(() {
        error = extractErrorMessage(e);
        initializing = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
      setState(() {
        controller = null;
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        initializing = true;
      });
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final ctrl = controller;
    if (ctrl == null || widget.sessionToken == null) return;
    setState(() => busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ctrl.takePicture();
      final repo = ref.read(attendanceRepoProvider);
      final result = await repo.checkIn(widget.sessionToken!, file);
      if (!mounted) return;
      await context.push(
        '/result',
        extra: {
          'attendance': result,
          'imagePath': file.path,
        },
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        body: ErrorView(
          message: error!,
          onRetry: () {
            setState(() {
              initializing = true;
              error = null;
            });
            _initCamera();
          },
        ),
      );
    }
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Không khởi tạo được camera.')),
      );
    }

    final statusText =
        busy ? 'Hệ thống đang nhận diện...' : 'Nhấn chụp để điểm danh';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1221), Color(0xFF1F3A93)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CameraPreview(controller!)),
            Container(
              width: 280,
              height: 360,
              decoration: BoxDecoration(
                border: Border.all(
                  color: busy ? Colors.greenAccent : Colors.white,
                  width: 4,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              child: Column(
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: busy ? null : _takePicture,
                    child: const Icon(Icons.camera_alt, size: 28),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
