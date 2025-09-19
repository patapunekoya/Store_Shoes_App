import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
      email.text.trim(),
      pass.text,
    );
  }

  String? _emailValidator(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Nhập email';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);
    if (!ok) return 'Email không hợp lệ';
    return null;
  }

  String? _passValidator(String? v) {
    if ((v ?? '').isEmpty) return 'Nhập mật khẩu';
    if ((v ?? '').length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    // Điều hướng khi đăng nhập thành công
    ref.listen(authProvider, (_, next) {
      if (next.user != null) {
        final role = next.user!.role.toLowerCase();
        if (role == 'admin' || role == 'staff') {
          Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/products', (_) => false);
        }
      }
    });

    // Chuẩn hóa lỗi hiển thị
    String? errorText;
    if (state.error != null) {
      final e = state.error!.toLowerCase();
      if (e.contains('401') || e.contains('unauthorized') || e.contains('invalid') || e.contains('sai')) {
        errorText = 'Sai email hoặc mật khẩu';
      } else {
        errorText = state.error!;
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.08),
              Theme.of(context).colorScheme.secondary.withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / tiêu đề
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.store, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Text('Sneaker Shop', style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Đăng nhập tài khoản', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: _emailValidator,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: pass,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: _passValidator,
                        onFieldSubmitted: (_) => _submit(),
                      ),

                      // Lỗi
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(errorText, style: const TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: state.loading ? null : _submit,
                          child: state.loading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Đăng nhập'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: state.loading
                            ? null
                            : () => ref.read(authProvider.notifier).register(
                          email.text.trim(),
                          pass.text,
                          fullName: 'User',
                        ),
                        icon: const Icon(Icons.person_add_alt),
                        label: const Text('Đăng ký nhanh'),
                      ),

                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng quên mật khẩu sẽ bổ sung sau')),
                          );
                        },
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
