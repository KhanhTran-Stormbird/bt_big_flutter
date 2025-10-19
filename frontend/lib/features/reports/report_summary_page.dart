import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/error_message.dart';
import '../../core/utils/toast.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/report_model.dart';
import '../classes/class_controller.dart';
import 'report_controller.dart';

class ReportSummaryPage extends ConsumerStatefulWidget {
  const ReportSummaryPage({super.key});

  @override
  ConsumerState<ReportSummaryPage> createState() => _ReportSummaryPageState();
}

class _ReportSummaryPageState extends ConsumerState<ReportSummaryPage> {
  int? selectedClassId;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classListProvider);
    final summaryAsync = ref.watch(reportSummaryProvider(selectedClassId));
    final exportState = ref.watch(reportActionControllerProvider);

    Future<void> export(String format) async {
      final messenger = ScaffoldMessenger.of(context);
      final notifier = ref.read(reportActionControllerProvider.notifier);
      final path = await notifier.export(
        format: format,
        classId: selectedClassId,
      );
      if (!mounted) return;
      final state = ref.read(reportActionControllerProvider);
      if (state.hasError) {
        messenger.showSnackBar(
          SnackBar(content: Text(extractErrorMessage(state.error!))),
        );
      } else if (path != null) {
        showSuccessToast(
          context,
          'Đã xuất báo cáo: $path',
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Báo cáo điểm danh',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        classesAsync.when(
          data: (classes) => DropdownButtonFormField<int?>(
            value: selectedClassId,
            decoration: const InputDecoration(labelText: 'Lọc theo lớp'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả lớp'),
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
              ref.invalidate(reportSummaryProvider(value));
            },
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Không tải được lớp: ${extractErrorMessage(error)}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 16),
        summaryAsync.when(
          data: (summary) => _SummaryCard(summary),
          loading: () =>
              const LoadingView(message: 'Đang tải báo cáo tổng hợp...'),
          error: (error, _) => ErrorView(
            message: extractErrorMessage(error),
            onRetry: () =>
                ref.invalidate(reportSummaryProvider(selectedClassId)),
          ),
        ),
        const SizedBox(height: 24),
        if (exportState.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => export('xlsx'),
                  icon: const Icon(Icons.table_view),
                  label: const Text('Xuất Excel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => export('pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Xuất PDF'),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ReportSummary summary;
  const _SummaryCard(this.summary);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MetricBox(
              label: 'Buổi học',
              value: summary.totalSessions.toString(),
            ),
            _MetricBox(
              label: 'Có mặt',
              value: summary.totalPresent.toString(),
            ),
            _MetricBox(
              label: 'Vắng',
              value: summary.totalAbsent.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
