import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
      const SnackBar(content: Text('Link reset password sudah dikirim')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset Password',
      subtitle: 'Masukkan email akunmu untuk menerima link reset password.',
      showBackButton: true,
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
              textInputAction: TextInputAction.done,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Kirim Reset Link',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
