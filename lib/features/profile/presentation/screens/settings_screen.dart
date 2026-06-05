import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/state/app_state_store.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/profile_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _themeLabel(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'Light Mode',
      ThemeMode.dark => 'Dark Mode',
      ThemeMode.system => 'Ikuti Sistem',
    };
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GoPrint',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Print & Administrasi Kampus',
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Kamu akan keluar dari akun GoPrint.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      profileStore.reset();
      appStateStore.reset();
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([profileStore, appStateStore]),
      builder: (context, _) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Pengaturan'),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SwitchListTile(
                value: profileStore.orderNotifications,
                onChanged: profileStore.updateOrderNotifications,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Notifikasi Pesanan'),
                subtitle: const Text('Update status print dan pengantaran'),
              ),
              SwitchListTile(
                value: profileStore.promoNotifications,
                onChanged: profileStore.updatePromoNotifications,
                secondary: const Icon(Icons.local_offer_outlined),
                title: const Text('Notifikasi Promo'),
                subtitle: const Text('Info diskon dari mitra fotokopi'),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Tema'),
                  subtitle: Text(_themeLabel(appStateStore.themeMode)),
                  trailing: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {appStateStore.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      appStateStore.updateThemeMode(selection.first);
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Tentang Aplikasi'),
                  subtitle: const Text('Versi, legal, dan informasi GoPrint'),
                  onTap: () => _showAboutApp(context),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
