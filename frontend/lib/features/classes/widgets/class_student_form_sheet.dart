import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_message.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/user.dart';
import '../class_controller.dart';

class ClassStudentFormSheet extends ConsumerStatefulWidget {
  final int classId;
  final User? initial;

  const ClassStudentFormSheet({
    super.key,
    required this.classId,
    this.initial,
  });

  bool get isEdit => initial != null;

  @override
  ConsumerState<ClassStudentFormSheet> createState() =>
      _ClassStudentFormSheetState();
}

class _ClassStudentFormSheetState
    extends ConsumerState<ClassStudentFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController emailCtrl =
      TextEditingController(text: widget.initial?.email ?? '');
  bool submitting = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final email = emailCtrl.text.trim();

    if (widget.isEdit && email == (widget.initial?.email ?? '')) {
      Navigator.of(context).pop('noop');
      return;
    }

    setState(() => submitting = true);
    final notifier = ref.read(classActionControllerProvider.notifier);
    bool ok;
    if (widget.isEdit) {
      ok = await notifier.updateStudent(
        classId: widget.classId,
        studentId: widget.initial!.id,
        newEmail: email,
      );
    } else {
      ok = await notifier.addStudent(
        classId: widget.classId,
        email: email,
      );
    }
    final state = ref.read(classActionControllerProvider);
    if (!mounted) return;
    setState(() => submitting = false);

    if (ok) {
      Navigator.of(context)
          .pop(widget.isEdit ? 'updated' : 'added');
    } else {
      final message = state.hasError
          ? extractErrorMessage(state.error!)
          : 'Không thể lưu sinh viên.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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
                widget.isEdit
                    ? 'Cập nhật sinh viên'
                    : 'Thêm sinh viên vào lớp',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailCtrl,
                hint: 'Email sinh viên',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Nhập email';
                  final emailRegex =
                      RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(text)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
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
