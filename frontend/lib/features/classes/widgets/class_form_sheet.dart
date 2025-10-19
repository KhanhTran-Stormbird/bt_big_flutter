import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_message.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/class_model.dart';
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

  bool submitting = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    subjectCtrl.dispose();
    termCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => submitting = true);
    final notifier = ref.read(classActionControllerProvider.notifier);
    final ok = widget.isEdit
        ? await notifier.update(
            id: widget.initial!.id,
            name: nameCtrl.text.trim(),
            subject: subjectCtrl.text.trim(),
            term: termCtrl.text.trim(),
          )
        : await notifier.create(
            name: nameCtrl.text.trim(),
            subject: subjectCtrl.text.trim(),
            term: termCtrl.text.trim(),
          );
    final state = ref.read(classActionControllerProvider);
    if (!mounted) return;
    setState(() => submitting = false);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(widget.isEdit ? 'Da cap nhat lop hoc' : 'Da tao lop hoc'),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      final message = state.hasError
          ? extractErrorMessage(state.error!)
          : 'Khong the luu lop hoc.';
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
                widget.isEdit ? 'Chinh sua lop hoc' : 'Tao lop hoc',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                hint: 'Ten lop',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhap ten lop'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: subjectCtrl,
                hint: 'Mon hoc',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhap mon hoc'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: termCtrl,
                hint: 'Hoc ky',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhap hoc ky'
                    : null,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: submitting ? 'Dang luu...' : 'Luu',
                onPressed: submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
