import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_message.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/class_model.dart';
import '../../users/lecturer_controller.dart';
import '../class_controller.dart';

class ClassFormSheet extends ConsumerStatefulWidget {
  final ClassModel? initial;
  const ClassFormSheet({super.key, this.initial});

  bool get isEdit => initial != null;

  @override
  ConsumerState<ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends ConsumerState<ClassFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController subjectCtrl =
      TextEditingController(text: widget.initial?.subject ?? '');
  late final TextEditingController termCtrl =
      TextEditingController(text: widget.initial?.term ?? '');
  int? lecturerId;

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    lecturerId = widget.initial?.lecturerId;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    subjectCtrl.dispose();
    termCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    if (lecturerId == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Hãy chọn giảng viên phụ trách')),
      );
      return;
    }
    setState(() => submitting = true);
    final notifier = ref.read(classActionControllerProvider.notifier);
    final ok = widget.isEdit
        ? await notifier.update(
            id: widget.initial!.id,
            name: nameCtrl.text.trim(),
            subject: subjectCtrl.text.trim(),
            term: termCtrl.text.trim(),
            lecturerId: lecturerId,
          )
        : await notifier.create(
            name: nameCtrl.text.trim(),
            subject: subjectCtrl.text.trim(),
            term: termCtrl.text.trim(),
            lecturerId: lecturerId,
          );
    final state = ref.read(classActionControllerProvider);
    if (!mounted) return;
    setState(() => submitting = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit ? 'Đã cập nhật lớp học' : 'Đã tạo lớp học',
          ),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      final message = state.hasError
          ? extractErrorMessage(state.error!)
          : 'Không thể lưu lớp học.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
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
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEdit ? 'Chỉnh sửa lớp học' : 'Tạo lớp học',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                hint: 'Tên lớp',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập tên lớp'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: subjectCtrl,
                hint: 'Môn học',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập môn học'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: termCtrl,
                hint: 'Học kỳ',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhập học kỳ'
                    : null,
              ),
              const SizedBox(height: 12),
              _LecturerSelector(
                selectedLecturerId: lecturerId,
                onChanged: (value) => setState(() => lecturerId = value),
                enabled: !submitting,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: submitting ? 'Đang lưu...' : 'Lưu',
                onPressed: submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LecturerSelector extends ConsumerWidget {
  final int? selectedLecturerId;
  final ValueChanged<int?> onChanged;
  final bool enabled;

  const _LecturerSelector({
    required this.selectedLecturerId,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lecturersAsync = ref.watch(lecturerListProvider);
    return lecturersAsync.when(
      data: (lecturers) {
        if (lecturers.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giảng viên phụ trách'),
              const SizedBox(height: 8),
              Text(
                'Chưa có giảng viên nào trong hệ thống.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        }
        return DropdownButtonFormField<int?>(
          initialValue: selectedLecturerId,
          onChanged: enabled ? onChanged : null,
          validator: (value) =>
              value == null ? 'Chọn giảng viên phụ trách' : null,
          decoration: const InputDecoration(
            labelText: 'Giảng viên phụ trách',
            hintText: 'Chọn giảng viên phụ trách',
          ),
          items: lecturers
              .map(
                (lecturer) => DropdownMenuItem<int?>(
                  value: lecturer.id,
                  child: Text('${lecturer.name} (${lecturer.email})'),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Không thể tải danh sách giảng viên'),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(lecturerListProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
