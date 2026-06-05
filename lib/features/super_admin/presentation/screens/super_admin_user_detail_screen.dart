import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';

class SuperAdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const SuperAdminUserDetailScreen({required this.userId, super.key});

  @override
  State<SuperAdminUserDetailScreen> createState() => _SuperAdminUserDetailScreenState();
}

class _SuperAdminUserDetailScreenState extends State<SuperAdminUserDetailScreen> {
  void _showRoleSelectorDialog(BuildContext context, SuperAdminUser user, SuperAdminManager saManager) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              title: const Text('Ubah Role Akses', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Customer', 'Admin Toko', 'Super Admin'].map((role) {
                  return RadioListTile<String>(
                    title: Text(role, style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: role,
                    groupValue: selectedRole,
                    activeColor: Colors.purple.shade600,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRole = val;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    saManager.updateUserRole(user.id, selectedRole);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Role berhasil diubah menjadi "$selectedRole"!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleUserStatus(BuildContext context, SuperAdminUser user, SuperAdminManager saManager) {
    final newStatus = user.status == 'Active' ? 'Banned' : 'Active';
    final isBanning = newStatus == 'Banned';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: Text(
            isBanning ? 'Blokir Pengguna' : 'Aktifkan Kembali Pengguna',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isBanning
                ? 'Apakah Anda yakin ingin memblokir akun ${user.name}? Pengguna tidak akan bisa masuk ke aplikasi.'
                : 'Apakah Anda yakin ingin mengaktifkan kembali akun ${user.name}?',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                saManager.updateUserStatus(user.id, newStatus);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBanning
                          ? 'Akun pengguna berhasil diblokir!'
                          : 'Akun pengguna berhasil diaktifkan kembali!',
                    ),
                    backgroundColor: isBanning ? Colors.red : Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isBanning ? Colors.red.shade600 : Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isBanning ? 'Blokir' : 'Aktifkan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saManager = SuperAdminManager.instance;

    return ListenableBuilder(
      listenable: saManager,
      builder: (context, _) {
        final userIndex = saManager.users.indexWhere((u) => u.id == widget.userId);
        if (userIndex == -1) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Detail User'),
            body: const Center(child: Text('Pengguna tidak ditemukan.')),
          );
        }
        final user = saManager.users[userIndex];
        final isBanned = user.status == 'Banned';
        final roleColor = user.role == 'Super Admin'
            ? Colors.purple.shade600
            : (user.role == 'Admin Toko' ? Colors.teal.shade600 : Colors.blue.shade600);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: CustomAppBar(
            title: 'Profil Pengguna',
            showBackButton: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/superadmin/users'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: roleColor.withValues(alpha: 0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: roleColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user.role,
                                    style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isBanned ? Colors.red : Colors.green).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: (isBanned ? Colors.red : Colors.green).withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    user.status,
                                    style: TextStyle(
                                      color: isBanned ? Colors.red.shade800 : Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Account Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Akun',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.mail_outline_rounded, 'Alamat Email', user.email),
                      _buildDetailRow(Icons.phone_android_rounded, 'Nomor Handphone', user.phone),
                      _buildDetailRow(Icons.calendar_month_rounded, 'Tanggal Registrasi', user.registeredDate),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showRoleSelectorDialog(context, user, saManager),
                        icon: const Icon(Icons.manage_accounts_rounded),
                        label: const Text('Ubah Role Akses', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleUserStatus(context, user, saManager),
                        icon: Icon(isBanned ? Icons.lock_open_rounded : Icons.block_rounded),
                        label: Text(
                          isBanned ? 'Aktifkan Kembali Akun' : 'Blokir Sementara Akun',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isBanned ? Colors.green.shade700 : Colors.red.shade700,
                          side: BorderSide(color: isBanned ? Colors.green.shade600 : Colors.red.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
