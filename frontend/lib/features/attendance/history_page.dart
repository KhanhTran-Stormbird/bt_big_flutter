import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
            'Lich su diem danh',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          classesAsync.when(
            data: (classes) => DropdownButtonFormField<int?>(
              value: selectedClassId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tat ca lop'),
                ),
                ...classes.map(
                  (c) => DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => selectedClassId = value);
                ref.invalidate(attendanceHistoryProvider(value));
              },
              decoration: const InputDecoration(
                labelText: 'Loc theo lop',
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Khong tai duoc danh sach lop: ${extractErrorMessage(error)}',
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
                const LoadingView(message: 'Dang tai lich su diem danh...'),
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
  const _HistoryList({required this.items, required this.formatter});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyView(message: 'Chua co lich su diem danh.');
    }
    return Column(
      children: items
          .map(
            (item) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Session #${item.sessionId}'),
                subtitle: Text(
                  '${item.status.toUpperCase()} - ${formatter.format(item.checkedAt)}',
                ),
                trailing: item.distance != null
                    ? Text('d=${item.distance!.toStringAsFixed(2)}')
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
