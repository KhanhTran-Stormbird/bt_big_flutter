import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/attendance_model.dart';

class ResultPage extends StatelessWidget {
  final AttendanceModel? attendance;
  final String? imagePath;

  const ResultPage({
    super.key,
    this.attendance,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final status = attendance?.status.toLowerCase() ?? 'unknown';
    final isPresent = status == 'present';
    final isSuspect = status == 'suspect';
    final color =
        isPresent ? Colors.green : (isSuspect ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(title: const Text('Ket qua diem danh')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPresent
                  ? Icons.check_circle
                  : (isSuspect ? Icons.error_outline : Icons.cancel),
              size: 96,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              'Trang thai: ${attendance?.status ?? 'unknown'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (attendance?.distance != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Do tuong tu khuon mat: ${attendance!.distance!.toStringAsFixed(3)}',
                ),
              ),
            if (imagePath != null && File(imagePath!).existsSync())
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath!),
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dong'),
            ),
          ],
        ),
      ),
    );
  }
}
