import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CapturePage extends StatefulWidget {
  final String? sessionToken;
  const CapturePage({super.key, this.sessionToken});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  CameraController? ctrl;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cams = await availableCameras();
    ctrl = CameraController(cams.first, ResolutionPreset.medium,
        enableAudio: false);
    await ctrl!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ctrl == null || !ctrl!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(children: [
        CameraPreview(ctrl!),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.large(
              onPressed: busy
                  ? null
                  : () async {
                      busy = true;
                      setState(() {});
                      final file = await ctrl!.takePicture();
                      // TODO: call /attendance/check-in bằng attendance_repo
                      if (mounted)
                        context.push('/result', extra: {
                          'status': 'Present',
                          'imagePath': file.path
                        });
                    },
              child: const Icon(Icons.camera_alt),
            ),
          ),
        )
      ]),
    );
  }
}
