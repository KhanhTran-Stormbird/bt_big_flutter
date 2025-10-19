import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_message.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/user.dart';
import '../user_controller.dart';

class UserFormSheet extends ConsumerStatefulWidget {
  final User? initial;
  const UserFormSheet({super.key, this.initial});

  bool get isEdit => initial != null;

  @override
  ConsumerState<UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends ConsumerState<UserFormSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController emailCtrl =
      TextEditingController(text: widget.initial?.email ?? '');
  late final TextEditingController passwordCtrl = TextEditingController();
  late final TextEditingController confirmCtrl = TextEditingController();
  String? selectedRole;

  bool submitting = false;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initial?.role ?? 'student';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => submitting = true);
    final notifier = ref.read(userActionControllerProvider.notifier);

    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final role = selectedRole!;
    final password = passwordCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    if (password.isNotEmpty && password != confirm) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu nhập lại không khớp.')),
      );
      return;
    }

    bool ok;
    if (widget.isEdit) {
      ok = await notifier.update(
        id: widget.initial!.id,
        name: name,
        email: email,
        role: role,
        password: password.isNotEmpty ? password : null,
      );
    } else {
      ok = await notifier.create(
        name: name,
        email: email,
        role: role,
        password: password,
      );
    }

    final state = ref.read(userActionControllerProvider);
    if (!mounted) return;
    setState(() => submitting = false);

    if (ok) {
      Navigator.of(context).pop(widget.isEdit ? 'updated' : 'created');
    } else {
      final message = state.hasError
          ? extractErrorMessage(state.error!)
          : 'Không thể lưu người dùng.';
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
                widget.isEdit ? 'Chỉnh sửa người dùng' : 'Thêm người dùng',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                hint: 'Họ và tên',
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nhập họ tên' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: emailCtrl,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nhập email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'lecturer',
                    child: Text('Giảng viên'),
                  ),
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('Sinh viên'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Quản trị'),
                  ),
                ],
                decoration: const InputDecoration(labelText: 'Vai trò'),
                onChanged: submitting ? null : (value) {
                  setState(() => selectedRole = value);
                },
                validator: (value) => value == null ? 'Chọn vai trò' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: passwordCtrl,
                hint: widget.isEdit ? 'Mật khẩu mới (tuỳ chọn)' : 'Mật khẩu',
                obscure: true,
                validator: (value) {
                  final text = value ?? '';
                  if (widget.isEdit) {
                    if (text.isNotEmpty && text.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  }
                  if (text.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: confirmCtrl,
                hint: widget.isEdit
                    ? 'Nhập lại mật khẩu (nếu thay đổi)'
                    : 'Nhập lại mật khẩu',
                obscure: true,
                validator: (value) {
                  if (widget.isEdit && passwordCtrl.text.isEmpty) {
                    return null;
                  }
                  if ((value ?? '').isEmpty) {
                    return 'Nhập lại mật khẩu';
                  }
                  if (value != passwordCtrl.text) {
                    return 'Mật khẩu nhập lại không khớp';
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
