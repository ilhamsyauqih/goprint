import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    // Navigate to main layout after successful login
    if (mounted) {
      context.go('/home');
    }
  }

  void _openRegister() {
    context.push('/auth/register');
  }

  void _openForgotPassword() {
    context.push('/auth/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Masuk ke GoPrint',
      subtitle: 'Kelola pesanan print kampusmu dengan cepat dan transparan.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'nama@email.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Minimal 8 karakter',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.password,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _openForgotPassword,
                child: const Text('Lupa password?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Login',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
            AuthSwitchPrompt(
              text: 'Belum punya akun?',
              actionText: 'Daftar',
              onPressed: _isLoading ? null : _openRegister,
            ),
          ],
        ),
      ),
    );
  }
}
