import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/error_message.dart';
import '../../../core/widgets/app_button.dart';
import '../session_controller.dart';

class SessionFormSheet extends ConsumerStatefulWidget {
  final int classId;
  const SessionFormSheet({super.key, required this.classId});

  @override
  ConsumerState<SessionFormSheet> createState() => _SessionFormSheetState();
}

class _SessionFormSheetState extends ConsumerState<SessionFormSheet> {
  late DateTime startsAt;
  late DateTime endsAt;
  bool submitting = false;
  final formatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startsAt = now;
    endsAt = now.add(const Duration(hours: 2));
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startsAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (!startsAt.isBefore(endsAt)) {
        endsAt = startsAt.add(const Duration(hours: 2));
      }
    });
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endsAt,
      firstDate: startsAt,
      lastDate: startsAt.add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endsAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      endsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (!endsAt.isAfter(startsAt)) {
        endsAt = startsAt.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _submit() async {
    setState(() => submitting = true);
    final notifier = ref.read(sessionActionControllerProvider.notifier);
    final ok = await notifier.create(
      classId: widget.classId,
      startsAt: startsAt,
      endsAt: endsAt,
    );
    if (!mounted) return;
    final state = ref.read(sessionActionControllerProvider);
    setState(() => submitting = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Da tao buoi hoc')),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tao buoi hoc',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Thoi gian bat dau'),
              subtitle: Text(formatter.format(startsAt)),
              trailing: const Icon(Icons.calendar_today),
              onTap: submitting ? null : _pickStart,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Thoi gian ket thuc'),
              subtitle: Text(formatter.format(endsAt)),
              trailing: const Icon(Icons.calendar_today),
              onTap: submitting ? null : _pickEnd,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: submitting ? 'Dang luu...' : 'Luu',
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
