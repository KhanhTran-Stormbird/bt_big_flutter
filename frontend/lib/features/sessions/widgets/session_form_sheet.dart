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
  late DateTime baseDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  final Set<int> selectedWeekdays = {};
  int repeatWeeks = 1;
  bool submitting = false;
  final previewFormatter = DateFormat('dd/MM/yyyy HH:mm');
  final List<int> weekOptions = List<int>.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    baseDate = DateTime(now.year, now.month, now.day);
    startTime = TimeOfDay(hour: now.hour, minute: (now.minute ~/ 5) * 5);
    endTime = TimeOfDay(
      hour: (now.hour + 2) % 24,
      minute: startTime.minute,
    );
    selectedWeekdays.add(baseDate.weekday);
  }

  Future<void> _pickBaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: baseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      baseDate = DateTime(picked.year, picked.month, picked.day);
      if (!selectedWeekdays.contains(picked.weekday)) {
        selectedWeekdays
          ..clear()
          ..add(picked.weekday);
      }
    });
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (time == null || !mounted) return;
    setState(() {
      startTime = time;
      if (!_isEndAfterStart()) {
        endTime = TimeOfDay(
          hour: (time.hour + 2) % 24,
          minute: time.minute,
        );
      }
    });
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (time == null || !mounted) return;
    setState(() {
      endTime = time;
      if (!_isEndAfterStart()) {
        endTime = TimeOfDay(
          hour: (startTime.hour + 1) % 24,
          minute: startTime.minute,
        );
      }
    });
  }

  bool _isEndAfterStart() {
    final start = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    var end = DateTime(2000, 1, 1, endTime.hour, endTime.minute);
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    return end.isAfter(start);
  }

  DateTime _combine(DateTime date, TimeOfDay time) => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  DateTime _firstOccurrence(DateTime base, int weekday) {
    final diff = (weekday - base.weekday + 7) % 7;
    return base.add(Duration(days: diff));
  }

  List<({DateTime start, DateTime end})> _buildSlots() {
    if (selectedWeekdays.isEmpty) return [];
    final slots = <({DateTime start, DateTime end})>[];
    for (final weekday in selectedWeekdays.toList()..sort()) {
      final firstDate = _firstOccurrence(baseDate, weekday);
      for (var week = 0; week < repeatWeeks; week++) {
        final date = firstDate.add(Duration(days: week * 7));
        var start = _combine(date, startTime);
        var end = _combine(date, endTime);
        if (!end.isAfter(start)) {
          end = end.add(const Duration(days: 1));
        }
        slots.add((start: start, end: end));
      }
    }
    slots.sort((a, b) => a.start.compareTo(b.start));
    return slots;
  }

  String _weekdayLabel(int weekday) {
    const labels = {
      1: 'T2',
      2: 'T3',
      3: 'T4',
      4: 'T5',
      5: 'T6',
      6: 'T7',
      7: 'CN',
    };
    return labels[weekday] ?? 'T?';
  }

  String _weekdayFullLabel(int weekday) {
    const full = {
      1: 'Thứ Hai',
      2: 'Thứ Ba',
      3: 'Thứ Tư',
      4: 'Thứ Năm',
      5: 'Thứ Sáu',
      6: 'Thứ Bảy',
      7: 'Chủ Nhật',
    };
    return full[weekday] ?? '';
  }

  Future<void> _submit() async {
    final slots = _buildSlots();
    final messenger = ScaffoldMessenger.of(context);
    if (selectedWeekdays.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Chọn ít nhất một ngày trong tuần.')),
      );
      return;
    }
    if (slots.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Không có buổi học nào được tạo.')),
      );
      return;
    }

    setState(() => submitting = true);
    final notifier = ref.read(sessionActionControllerProvider.notifier);
    final ok = await notifier.create(
      classId: widget.classId,
      slots: slots,
    );
    if (!mounted) return;
    final state = ref.read(sessionActionControllerProvider);
    setState(() => submitting = false);

    if (ok) {
      Navigator.of(context).pop(slots.length);
    } else if (state.hasError) {
      messenger.showSnackBar(
        SnackBar(content: Text(extractErrorMessage(state.error!))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsPreview = _buildSlots();
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
              'Lên lịch buổi học',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tuần bắt đầu'),
              subtitle: Text(
                '${_weekdayFullLabel(baseDate.weekday)}, '
                '${DateFormat('dd/MM/yyyy').format(baseDate)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: submitting ? null : _pickBaseDate,
            ),
            const SizedBox(height: 12),
            Text(
              'Chọn ngày trong tuần',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final selected = selectedWeekdays.contains(weekday);
                return ChoiceChip(
                  label: Text(_weekdayLabel(weekday)),
                  selected: selected,
                  onSelected: submitting
                      ? null
                      : (value) {
                          setState(() {
                            if (value) {
                              selectedWeekdays.add(weekday);
                            } else {
                              selectedWeekdays.remove(weekday);
                            }
                          });
                        },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Giờ bắt đầu'),
                    subtitle: Text(startTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: submitting ? null : _pickStartTime,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Giờ kết thúc'),
                    subtitle: Text(endTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: submitting ? null : _pickEndTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Lặp lại trong'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: repeatWeeks,
                  underline: const SizedBox.shrink(),
                  items: weekOptions
                      .map(
                        (w) => DropdownMenuItem(
                          value: w,
                          child: Text('$w tuần'),
                        ),
                      )
                      .toList(),
                  onChanged: submitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => repeatWeeks = value);
                          }
                        },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Số buổi sẽ tạo: ${slotsPreview.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (slotsPreview.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buổi sắp tạo:'
                    '${slotsPreview.length > 5 ? ' (hiển thị 5 buổi đầu)' : ''}',
                  ),
                  const SizedBox(height: 8),
                  ...slotsPreview.take(5).map(
                        (slot) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_available),
                          title: Text(
                            '${previewFormatter.format(slot.start)} - ${previewFormatter.format(slot.end)}',
                          ),
                        ),
                      ),
                ],
              ),
            const SizedBox(height: 24),
            AppButton(
              text: submitting
                  ? 'Đang tạo ${slotsPreview.length} buổi...'
                  : 'Tạo buổi học',
              onPressed: submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
