import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import 'auth_controller.dart';

// ignore: unused_element
const _iconKeepAlive = <IconData>[
  Icons.badge_outlined,
  Icons.mail_outline,
  Icons.account_circle_outlined,
  Icons.visibility_outlined,
  Icons.visibility_off_outlined,
  Icons.lock_outline,
  Icons.verified_user_outlined,
  Icons.school_outlined,
  Icons.person_outline,
];

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  MockRole selectedRole = MockRole.student;
  bool loading = false;
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F3A93), Color(0xFF2A6FF0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo_tlu.png', height: 96),
                  const SizedBox(height: 16),
                  Text(
                    'Trường Đại học Thủy Lợi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back! 👋',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _RoleSelector(
                            selected: selectedRole,
                            onChanged: (role) => setState(() {
                              selectedRole = role;
                              email.clear();
                              pass.clear();
                            }),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            selectedRole.inputLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: email,
                            decoration: InputDecoration(
                              hintText: selectedRole.inputHint,
                              prefixIcon: Icon(
                                selectedRole.inputIcon,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Mật khẩu',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: pass,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              hintText: 'Nhập mật khẩu',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(() {
                                  obscure = !obscure;
                                }),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          AppButton(
                            text: loading ? 'Đang vào...' : 'Đăng nhập',
                            onPressed: loading
                                ? null
                                : () async {
                                    setState(() => loading = true);
                                    final notifier = ref
                                        .read(authControllerProvider.notifier);

                                    if (email.text.isEmpty ||
                                        pass.text.isEmpty) {
                                      notifier.loginAsMock(
                                        id: selectedRole.mockId,
                                        name: selectedRole.mockName,
                                        email: selectedRole.mockEmail,
                                        role: selectedRole.roleValue,
                                      );
                                      if (mounted) {
                                        setState(() => loading = false);
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đăng nhập nhanh với tài khoản ${selectedRole.label.toLowerCase()}',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    final ok = await notifier.login(
                                      email.text.trim(),
                                      pass.text,
                                    );

                                    if (!mounted) return;
                                    setState(() => loading = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? 'Đăng nhập thành công'
                                              : 'Đăng nhập thất bại. Vui lòng kiểm tra lại.',
                                        ),
                                      ),
                                    );
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF6A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum MockRole { student, lecturer, admin }

extension MockRoleExt on MockRole {
  String get label {
    switch (this) {
      case MockRole.admin:
        return 'Quản trị viên';
      case MockRole.lecturer:
        return 'Giảng viên';
      case MockRole.student:
        return 'Sinh viên';
    }
  }

  IconData get icon {
    switch (this) {
      case MockRole.admin:
        return Icons.verified_user_outlined;
      case MockRole.lecturer:
        return Icons.school_outlined;
      case MockRole.student:
        return Icons.person_outline;
    }
  }

  String get inputLabel {
    switch (this) {
      case MockRole.admin:
        return 'Tài khoản quản trị';
      case MockRole.lecturer:
        return 'Email giảng viên';
      case MockRole.student:
        return 'Mã sinh viên';
    }
  }

  String get inputHint {
    switch (this) {
      case MockRole.admin:
        return 'Nhập email quản trị';
      case MockRole.lecturer:
        return 'Nhập email giảng viên';
      case MockRole.student:
        return 'Nhập mã sinh viên';
    }
  }

  IconData get inputIcon {
    switch (this) {
      case MockRole.admin:
        return Icons.badge_outlined;
      case MockRole.lecturer:
        return Icons.mail_outline;
      case MockRole.student:
        return Icons.account_circle_outlined;
    }
  }

  int get mockId {
    switch (this) {
      case MockRole.admin:
        return 3;
      case MockRole.lecturer:
        return 2;
      case MockRole.student:
        return 1;
    }
  }

  String get mockName {
    switch (this) {
      case MockRole.admin:
        return 'Admin Demo';
      case MockRole.lecturer:
        return 'Lecturer Demo';
      case MockRole.student:
        return 'Student Demo';
    }
  }

  String get mockEmail {
    switch (this) {
      case MockRole.admin:
        return 'admin1@tlu.edu.vn';
      case MockRole.lecturer:
        return 'lecturer1@tlu.edu.vn';
      case MockRole.student:
        return 'student1@tlu.edu.vn';
    }
  }

  String get roleValue {
    switch (this) {
      case MockRole.admin:
        return 'admin';
      case MockRole.lecturer:
        return 'lecturer';
      case MockRole.student:
        return 'student';
    }
  }
}

class _RoleSelector extends StatelessWidget {
  final MockRole selected;
  final ValueChanged<MockRole> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: MockRole.values.map((role) {
            final isSelected = role == selected;
            return GestureDetector(
              onTap: () => onChanged(role),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role.icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      role.label,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
