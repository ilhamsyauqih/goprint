import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrasi berhasil diproses')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Buat Akun',
      subtitle: 'Daftar untuk upload file, cek harga, dan pesan pengantaran.',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hintText: 'Nama kamu',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 18),
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
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _phoneController,
              label: 'Nomor HP',
              hintText: '08xxxxxxxxxx',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Register',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),
            AuthSwitchPrompt(
              text: 'Sudah punya akun?',
              actionText: 'Login',
              onPressed: _isLoading ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
