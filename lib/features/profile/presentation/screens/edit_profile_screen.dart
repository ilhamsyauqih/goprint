import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileNotifierProvider);
    _nameController = TextEditingController(text: profile.user?.name ?? '');
    _phoneController = TextEditingController(text: profile.user?.phone ?? '');
    _addressController = TextEditingController(text: profile.defaultAddress?.fullAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final notifier = ref.read(profileNotifierProvider.notifier);
      final profileState = ref.read(profileNotifierProvider);
      
      // Update name & phone in public.profiles
      await notifier.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final addressText = _addressController.text.trim();
      
      // Update default address if exists, otherwise create it
      if (profileState.defaultAddress != null && profileState.defaultAddress!.id.isNotEmpty) {
        await notifier.updateAddress(
          addressId: profileState.defaultAddress!.id,
          label: profileState.defaultAddress!.label,
          fullAddress: addressText,
          isDefault: true,
        );
      } else {
        await notifier.addAddress(
          label: 'Utama',
          fullAddress: addressText,
          isDefault: true,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui profil: ${e.toString()}'),
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
      appBar: const CustomAppBar(title: 'Edit Profil'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(child: AvatarPicker()),
            const SizedBox(height: 28),
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
              controller: _phoneController,
              label: 'Nomor HP',
              hintText: '08xxxxxxxxxx',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _addressController,
              label: 'Alamat Kos',
              hintText: 'Alamat pengantaran utama',
              prefixIcon: Icons.home_work_outlined,
              textInputAction: TextInputAction.done,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Simpan Profil',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
