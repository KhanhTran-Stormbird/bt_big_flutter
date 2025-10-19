import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/error_message.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/attendance_model.dart';
import '../classes/class_controller.dart';
import 'attendance_controller.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int? selectedClassId;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classListProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider(selectedClassId));
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(attendanceHistoryProvider(selectedClassId));
        await ref.read(attendanceHistoryProvider(selectedClassId).future);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Text(
            'Lịch sử điểm danh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          classesAsync.when(
            data: (classes) => DropdownButtonFormField<int?>(
              value: selectedClassId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tất cả lớp'),
                ),
                ...classes.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(
                      c.subject.isNotEmpty
                          ? '${c.name} (${c.subject})'
                          : c.name,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedClassId = value);
                ref.invalidate(attendanceHistoryProvider(value));
              },
              decoration: const InputDecoration(
                labelText: 'Lọc theo lớp',
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Không tải được danh sách lớp: ${extractErrorMessage(error)}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (items) => _HistoryList(
              items: items,
              formatter: formatter,
            ),
            loading: () =>
                const LoadingView(message: 'Đang tải lịch sử điểm danh...'),
            error: (error, _) => ErrorView(
              message: extractErrorMessage(error),
              onRetry: () =>
                  ref.invalidate(attendanceHistoryProvider(selectedClassId)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<AttendanceModel> items;
  final DateFormat formatter;
  const _HistoryList({
    required this.items,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyView(message: 'Chưa có lịch sử điểm danh.');
    }
    return Column(
      children: items
          .map(
            (item) => _HistoryTile(
              item: item,
              formatter: formatter,
            ),
          )
          .toList(),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AttendanceModel item;
  final DateFormat formatter;

  const _HistoryTile({
    required this.item,
    required this.formatter,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'absent':
        return const Color(0xFFE11D48);
      case 'late':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.textPrimary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Có mặt';
      case 'absent':
        return 'Vắng';
      case 'late':
        return 'Muộn';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.event_available, color: color),
        ),
        title: Text(
          formatter.format(item.checkedAt),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        subtitle: Text(_subtitleText()),
        trailing: Text(
          _statusLabel(item.status),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _subtitleText() {
    final className = item.className ?? '';
    final subject = item.classSubject ?? '';
    final sessionLabel = 'Buổi #${item.sessionId}';
    if (className.isEmpty) return sessionLabel;
    if (subject.isEmpty) return '$className • $sessionLabel';
    return '$className ($subject) • $sessionLabel';
  }
}
