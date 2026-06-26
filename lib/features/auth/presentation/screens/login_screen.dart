import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../features/shop/data/mock_shops.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';

// Gunakan ConsumerStatefulWidget agar bisa mengakses Riverpod provider
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // ── Cek kredensial admin toko (mock) terlebih dahulu ──────────
      final matchedShop = MockShops.shops.where(
        (s) => s.adminEmail == email && s.adminPassword == password,
      );

      if (matchedShop.isNotEmpty) {
        if (!mounted) return;
        // Login sebagai Admin Toko → redirect ke dashboard admin
        context.go('/admin/dashboard');
        return;
      }

      // ── Cek super admin hard-coded ─────────────────────────────────
      if (email == 'superadmin@goprint.id' && password == 'SuperAdmin@2026') {
        if (!mounted) return;
        context.go('/superadmin/dashboard');
        return;
      }

      // ── Fallback ke Supabase signIn untuk pengguna biasa ──────────
      final authRepo = ref.read(authRepositoryProvider);
      final userModel = await authRepo.signIn(email: email, password: password);

      if (!mounted) return;
      
      // Sinkronisasi data toko dari Supabase setelah login berhasil
      try {
        await MockShops.syncFromSupabase();
      } catch (e) {
        debugPrint('Failed to sync shops on login: $e');
      }

      if (!mounted) return;

      if (userModel.role == 'admin') {
        context.go('/admin/dashboard');
      } else if (userModel.role == 'superadmin') {
        context.go('/superadmin/dashboard');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            const SizedBox(height: 20),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'Minimal 8 karakter',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _openForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Lupa password?',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
