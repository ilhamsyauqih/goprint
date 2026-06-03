import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark
        ? AppColors.darkMutedText
        : AppColors.lightSubtleText;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profil', showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileHeader(subtitleColor: subtitleColor),
          const SizedBox(height: 20),
          _ProfileInfoTile(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: 'amir@goprint.id',
          ),
          _ProfileInfoTile(
            icon: Icons.phone_android_rounded,
            label: 'Nomor HP',
            value: '0812-3456-7890',
          ),
          _ProfileInfoTile(
            icon: Icons.home_work_outlined,
            label: 'Alamat Utama',
            value: 'Kos Melati, Jl. Kampus No. 12',
          ),
          const SizedBox(height: 16),
          _ProfileMenuTile(
            icon: Icons.edit_rounded,
            title: 'Edit Profil',
            subtitle: 'Nama, nomor HP, dan alamat kos',
            onTap: () => context.push('/profile/edit'),
          ),
          _ProfileMenuTile(
            icon: Icons.location_on_outlined,
            title: 'Alamat Tersimpan',
            subtitle: 'Tambah, hapus, dan pilih alamat default',
            onTap: () => context.push('/profile/addresses'),
          ),
          _ProfileMenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun GoPrint',
            onTap: () => context.push('/profile/change-password'),
          ),
          _ProfileMenuTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Notifikasi, tema, tentang app, logout',
            onTap: () => context.push('/profile/settings'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.subtitleColor});

  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const AvatarPicker(size: 76),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amir Mahendra',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mahasiswa aktif yang siap print tanpa antre.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppColors.teal300 : AppColors.teal700),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightSubtleText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.teal700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
