import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../data/repositories/storage_service_impl.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_switch_prompt.dart';
import '../widgets/auth_text_field.dart';

/// Enum untuk role pendaftaran
enum RegisterRole { buyer, seller }

// Gunakan ConsumerStatefulWidget agar bisa mengakses Riverpod provider
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Seller-specific controllers
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _gmapsLinkController = TextEditingController();

  bool _isLoading = false;
  RegisterRole _selectedRole = RegisterRole.buyer;

  // File picker state
  PlatformFile? _nibFile;
  PlatformFile? _ktpFile;

  // Animation controller for seller fields
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _gmapsLinkController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onRoleChanged(RegisterRole role) {
    setState(() => _selectedRole = role);
    if (role == RegisterRole.seller) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  Future<void> _pickFile({required bool isNib}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (isNib) {
          _nibFile = result.files.first;
        } else {
          _ktpFile = result.files.first;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi tambahan untuk seller
    if (_selectedRole == RegisterRole.seller) {
      if (_nibFile == null) {
        _showError('File Nomor Induk Berusaha (NIB) wajib dilampirkan');
        return;
      }
      if (_ktpFile == null) {
        _showError('File KTP wajib dilampirkan');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final role = _selectedRole == RegisterRole.seller ? 'seller' : 'user';

      String? nibPath;
      String? ktpPath;

      // Upload seller documents jika role seller
      if (_selectedRole == RegisterRole.seller) {
        final storageService = ref.read(storageServiceProvider);

        // Upload NIB
        if (_nibFile != null) {
          final nibFileObj = (!kIsWeb && _nibFile!.path != null) ? File(_nibFile!.path!) : null;
          nibPath = await storageService.uploadSellerDocument(
            userId: _emailController.text.trim(),
            fileName: 'nib_${_nibFile!.name}',
            file: nibFileObj,
            bytes: nibFileObj == null ? _nibFile!.bytes : null,
          );
        }

        // Upload KTP
        if (_ktpFile != null) {
          final ktpFileObj = (!kIsWeb && _ktpFile!.path != null) ? File(_ktpFile!.path!) : null;
          ktpPath = await storageService.uploadSellerDocument(
            userId: _emailController.text.trim(),
            fileName: 'ktp_${_ktpFile!.name}',
            file: ktpFileObj,
            bytes: ktpFileObj == null ? _ktpFile!.bytes : null,
          );
        }
      }

      await authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: role,
        shopName: _selectedRole == RegisterRole.seller
            ? _shopNameController.text.trim()
            : null,
        shopAddress: _selectedRole == RegisterRole.seller
            ? _shopAddressController.text.trim()
            : null,
        gmapsLink: _selectedRole == RegisterRole.seller
            ? _gmapsLinkController.text.trim()
            : null,
        nibFilePath: nibPath,
        ktpFilePath: ktpPath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedRole == RegisterRole.seller
                ? 'Registrasi seller berhasil! Toko Anda akan segera diverifikasi.'
                : 'Registrasi berhasil! Silakan masuk dengan akun baru Anda.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman login setelah berhasil daftar
      context.pop();
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('over_email_send_rate_limit')) {
        errorMessage =
            'Registrasi Gagal (Rate Limit): Supabase membatasi pengiriman email verifikasi. '
            'Silakan nonaktifkan "Confirm email" di Supabase Dashboard (Authentication -> Providers -> Email -> matikan "Confirm email" lalu klik Save) agar bisa mendaftar tanpa verifikasi email.';
      } else {
        errorMessage = 'Registrasi gagal: $errorMessage';
      }

      _showError(errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSeller = _selectedRole == RegisterRole.seller;

    return AuthScaffold(
      title: 'Buat Akun',
      subtitle: isSeller
          ? 'Daftar sebagai seller untuk membuka toko dan menerima pesanan.'
          : 'Daftar untuk upload file, cek harga, dan pesan pengantaran.',
      showBackButton: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Role Toggle ─────────────────────────────────────
            _buildRoleToggle(),
            const SizedBox(height: 24),

            // ─── Common Fields ───────────────────────────────────
            AuthTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              hintText: 'Nama kamu',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 20),
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
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: _phoneController,
              label: 'Nomor HP',
              hintText: '08xxxxxxxxxx',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: isSeller ? TextInputAction.next : TextInputAction.done,
              validator: AuthValidators.requiredField,
            ),

            // ─── Seller Fields (Animated) ────────────────────────
            SizeTransition(
              sizeFactor: _fadeAnimation,
              alignment: Alignment.topCenter,
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSellerFields(),
                ),
              ),
            ),

            const SizedBox(height: 28),
            PrimaryButton(
              label: isSeller ? 'Daftar sebagai Seller' : 'Register',
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

  /// Toggle Pembeli / Penjual
  Widget _buildRoleToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRoleOption(
            role: RegisterRole.buyer,
            icon: Icons.person_rounded,
            label: 'Pembeli',
          ),
          const SizedBox(width: 4),
          _buildRoleOption(
            role: RegisterRole.seller,
            icon: Icons.storefront_rounded,
            label: 'Penjual (Seller)',
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required RegisterRole role,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryButtonGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.teal700.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.lightSubtleText,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.lightSubtleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seller-specific fields
  Widget _buildSellerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),

        // Divider dengan label
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.teal200, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Informasi Toko',
                style: TextStyle(
                  color: AppColors.teal700,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.teal200, thickness: 1)),
          ],
        ),
        const SizedBox(height: 18),

        // Nama Toko
        AuthTextField(
          controller: _shopNameController,
          label: 'Nama Toko',
          hintText: 'Contoh: Fotokopi Jaya',
          prefixIcon: Icons.storefront_rounded,
          textInputAction: TextInputAction.next,
          validator: _selectedRole == RegisterRole.seller
              ? AuthValidators.requiredField
              : null,
        ),
        const SizedBox(height: 18),

        // Alamat Lengkap Toko
        AuthTextField(
          controller: _shopAddressController,
          label: 'Alamat Lengkap Toko',
          hintText: 'Jl. Contoh No. 123, Kota',
          prefixIcon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
          validator: _selectedRole == RegisterRole.seller
              ? AuthValidators.requiredField
              : null,
        ),
        const SizedBox(height: 18),

        // Link Google Maps
        AuthTextField(
          controller: _gmapsLinkController,
          label: 'Link Google Maps',
          hintText: 'https://maps.google.com/...',
          prefixIcon: Icons.map_outlined,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          validator: _selectedRole == RegisterRole.seller
              ? _validateGmapsLink
              : null,
        ),
        const SizedBox(height: 18),

        // Upload NIB
        _buildFilePickerField(
          label: 'Nomor Induk Berusaha (NIB)',
          file: _nibFile,
          icon: Icons.description_outlined,
          onTap: () => _pickFile(isNib: true),
          onClear: () => setState(() => _nibFile = null),
        ),
        const SizedBox(height: 18),

        // Upload KTP
        _buildFilePickerField(
          label: 'Upload KTP',
          file: _ktpFile,
          icon: Icons.badge_outlined,
          onTap: () => _pickFile(isNib: false),
          onClear: () => setState(() => _ktpFile = null),
        ),
      ],
    );
  }

  /// Validator untuk link Google Maps
  String? _validateGmapsLink(String? value) {
    final requiredError = AuthValidators.requiredField(value);
    if (requiredError != null) return requiredError;

    final trimmed = value!.trim().toLowerCase();
    if (!trimmed.contains('google') && !trimmed.contains('maps') && !trimmed.contains('goo.gl')) {
      return 'Masukkan link Google Maps yang valid';
    }
    return null;
  }

  /// File picker field widget
  Widget _buildFilePickerField({
    required String label,
    required PlatformFile? file,
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final hasFile = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.lightPrimaryText.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.teal200.withValues(alpha: 0.15)
                  : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile ? AppColors.teal400 : AppColors.lightBorder,
                width: hasFile ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? AppColors.teal600.withValues(alpha: 0.12)
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_rounded : icon,
                    size: 22,
                    color: hasFile ? AppColors.teal600 : AppColors.lightSubtleText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? file.name : 'Pilih file (PDF, JPG, PNG)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                          color: hasFile
                              ? AppColors.teal800
                              : AppColors.lightSubtleText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasFile) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatFileSize(file.size),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.lightSubtleText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasFile)
                  GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.lightSubtleText,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.upload_file_rounded,
                    size: 22,
                    color: AppColors.teal600,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Format file size to human readable string
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
