import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';

// Gunakan ConsumerStatefulWidget agar bisa mengakses Riverpod provider
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Panggil Supabase signUp via authRepositoryProvider
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan masuk dengan akun baru Anda.'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman login setelah berhasil daftar
      context.pop();
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        errorMessage = 'Registrasi Gagal (Rate Limit): Supabase membatasi pengiriman email verifikasi. '
            'Silakan nonaktifkan "Confirm email" di Supabase Dashboard (Authentication -> Providers -> Email -> matikan "Confirm email" lalu klik Save) agar bisa mendaftar tanpa verifikasi email.';
      } else {
        errorMessage = 'Registrasi gagal: $errorMessage';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
