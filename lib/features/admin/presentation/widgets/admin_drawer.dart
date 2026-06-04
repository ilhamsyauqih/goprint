import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Sidebar navigasi kustom admin (AdminDrawer) dengan 8 item menu.
class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        children: [
          // Header Gradasi dengan identitas toko admin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.headerGradientDark : AppColors.headerGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Surya Gemilang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Daftar Menu Utama Admin (8 Item Menu)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  context,
                  title: 'Dashboard Admin',
                  icon: Icons.dashboard_rounded,
                  route: '/admin/dashboard',
                ),
                _buildMenuItem(
                  context,
                  title: 'Pesanan Masuk',
                  icon: Icons.receipt_long_rounded,
                  route: '/admin/orders',
                ),
                _buildMenuItem(
                  context,
                  title: 'Daftar Layanan',
                  icon: Icons.print_rounded,
                  route: '/admin/services',
                ),
                _buildMenuItem(
                  context,
                  title: 'Profil Toko',
                  icon: Icons.storefront_rounded,
                  route: '/admin/shop-profile',
                ),
                _buildMenuItem(
                  context,
                  title: 'Laporan Keuangan',
                  icon: Icons.bar_chart_rounded,
                  route: '/admin/reports',
                ),
                _buildMenuItem(
                  context,
                  title: 'Ulasan Pelanggan',
                  icon: Icons.rate_review_rounded,
                  route: '/admin/reviews',
                ),
                _buildMenuItem(
                  context,
                  title: 'Pengaturan Sistem',
                  icon: Icons.settings_rounded,
                  route: '/admin/settings',
                ),
                const Divider(height: 24, thickness: 1),
                _buildMenuItem(
                  context,
                  title: 'Beralih ke Mode User',
                  icon: Icons.arrow_back_rounded,
                  route: '/home',
                  isAction: true,
                ),
              ],
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'GoPrint Admin v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    bool isAction = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentRoute == route;

    final activeColor = isDark ? AppColors.teal300 : AppColors.teal700;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withValues(alpha: isDark ? 0.15 : 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -2),
        horizontalTitleGap: 12,
        leading: Icon(
          icon,
          color: isSelected 
              ? activeColor 
              : (isAction 
                  ? Colors.orange.shade800 
                  : (isDark ? AppColors.darkMutedText : Colors.grey.shade600)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Tutup Drawer
          if (isAction) {
            context.go(route);
          } else {
            // Arahkan ke rute jika tidak sedang aktif
            if (!isSelected) {
              if (route == '/admin/dashboard') {
                context.go(route);
              } else {
                // Tampilkan snackbar pemberitahuan fitur mockup
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menu "$title" akan diaktifkan di task berikutnya!'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }
}
