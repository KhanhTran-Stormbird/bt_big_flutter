import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../shell/shell_page.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState(); // <-- kiểu đúng
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Đăng nhập',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              AppTextField(controller: email, hint: 'Email'),
              const SizedBox(height: 12),
              AppTextField(controller: pass, hint: 'Mật khẩu', obscure: true),
              const SizedBox(height: 16),
              AppButton(
                text: loading ? 'Đang vào...' : 'Đăng nhập',
                onPressed: loading
                    ? null
                    : () async {
                        // Lấy navigator trước async gap để tránh lint "context across async gaps"
                        final navigator = Navigator.of(context);

                        setState(() => loading = true);
                        final ok = await ref
                            .read(authControllerProvider.notifier)
                            .login(email.text.trim(), pass.text);

                        if (!mounted) return; // guard chuẩn
                        setState(() => loading = false);

                        if (ok) {
                          navigator.pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const ShellPage()),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
