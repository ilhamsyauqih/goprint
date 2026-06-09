import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(profileNotifierProvider.notifier).addAddress(
            label: _titleController.text.trim(),
            fullAddress: _detailController.text.trim(),
            isDefault: false,
          );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan alamat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tambah Alamat'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AuthTextField(
              controller: _titleController,
              label: 'Nama Alamat',
              hintText: 'Kos, kampus, rumah',
              prefixIcon: Icons.bookmark_border_rounded,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _detailController,
              label: 'Detail Alamat',
              hintText: 'Tuliskan alamat lengkap',
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Simpan Alamat',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
