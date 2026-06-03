import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPassword(String? value) {
    final passwordError = AuthValidators.password(value);
    if (passwordError != null) {
      return passwordError;
    }

    if (value != _newPasswordController.text) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ubah Password'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AuthTextField(
              controller: _oldPasswordController,
              label: 'Password Lama',
              hintText: 'Masukkan password lama',
              prefixIcon: Icons.lock_clock_outlined,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _newPasswordController,
              label: 'Password Baru',
              hintText: 'Minimal 8 karakter',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Konfirmasi Password',
              hintText: 'Ulangi password baru',
              prefixIcon: Icons.verified_user_outlined,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: _confirmPassword,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Simpan Password',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
