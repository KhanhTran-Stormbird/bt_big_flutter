import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/attendance_model.dart';

class ResultPage extends StatelessWidget {
  final AttendanceModel? attendance;
  final String? imagePath;

  const ResultPage({super.key, this.attendance, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final att = attendance;
    final isSuccess = att?.status.toLowerCase() == 'present';
    final statusColor = isSuccess ? const Color(0xFF16A34A) : Colors.orange;
    final statusText =
        isSuccess ? 'Điểm danh thành công' : 'Kiểm tra lại điểm danh';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả điểm danh'),
        backgroundColor: const Color(0xFF1F3A93),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagePath != null && File(imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath!),
                  height: 260,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        child: Icon(
                          isSuccess ? Icons.check : Icons.error_outline,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          statusText,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (att != null) ...[
                    _InfoRow(
                      label: 'Buổi học',
                      value: '#${att.sessionId}',
                    ),
                    _InfoRow(
                      label: 'Thời gian',
                      value: _formatTime(att),
                    ),
                    _InfoRow(
                      label: 'Trạng thái',
                      value: att.status.toUpperCase(),
                    ),
                    if (att.distance != null)
                      _InfoRow(
                        label: 'Khoảng cách',
                        value: att.distance!.toStringAsFixed(3),
                      ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(AttendanceModel model) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return fmt.format(model.checkedAt);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
