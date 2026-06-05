import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/profile_store.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.pop(
      UserAddress(
        title: _titleController.text.trim(),
        detail: _detailController.text.trim(),
        isDefault: false,
      ),
    );
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
            PrimaryButton(label: 'Simpan Alamat', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
