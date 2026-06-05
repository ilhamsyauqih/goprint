import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

/// Sidebar navigasi kustom super admin (SuperAdminDrawer) dengan tema warna ungu/indigo premium.
class SuperAdminDrawer extends StatelessWidget {
  final String currentRoute;

  const SuperAdminDrawer({required this.currentRoute, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF311B92), Color(0xFF1A237E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF673AB7), Color(0xFF3F51B5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      child: Column(
        children: [
          // Header Gradasi Ungu Premium
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: BoxDecoration(
              gradient: headerGradient,
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
                      Icons.security_rounded,
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
                        'Rafif Hidayat',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Super Admin Panel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade100,
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
          // Daftar Menu Utama Super Admin
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(
                  context,
                  title: 'Dashboard Global',
                  icon: Icons.analytics_rounded,
                  route: '/superadmin/dashboard',
                ),
                _buildMenuItem(
                  context,
                  title: 'Mitra Toko',
                  icon: Icons.store_mall_directory_rounded,
                  route: '/superadmin/shops',
                ),
                _buildMenuItem(
                  context,
                  title: 'Manajemen User',
                  icon: Icons.people_alt_rounded,
                  route: '/superadmin/users',
                ),
                _buildMenuItem(
                  context,
                  title: 'Penarikan Dana',
                  icon: Icons.account_balance_wallet_rounded,
                  route: '/superadmin/payouts',
                ),
                _buildMenuItem(
                  context,
                  title: 'Pengaturan Sistem',
                  icon: Icons.settings_input_component_rounded,
                  route: '/superadmin/settings',
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
              'GoPrint Platform v1.0.0',
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

    final activeColor = isDark ? Colors.purple.shade300 : Colors.purple.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withValues(alpha: isDark ? 0.2 : 0.08)
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
            if (!isSelected) {
              context.go(route);
            }
          }
        },
      ),
    );
  }
}
