import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  ThemeMode _themeMode = ThemeMode.system;

  String get _themeLabel {
    return switch (_themeMode) {
      ThemeMode.light => 'Light Mode',
      ThemeMode.dark => 'Dark Mode',
      ThemeMode.system => 'Ikuti Sistem',
    };
  }

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'GoPrint',
      applicationVersion: '1.0.0',
      applicationLegalese: 'Print & Administrasi Kampus',
    );
  }

  Future<void> _confirmLogout() async {
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

    if (shouldLogout == true && mounted) {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Pengaturan'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: _orderNotifications,
            onChanged: (value) => setState(() => _orderNotifications = value),
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifikasi Pesanan'),
            subtitle: const Text('Update status print dan pengantaran'),
          ),
          SwitchListTile(
            value: _promoNotifications,
            onChanged: (value) => setState(() => _promoNotifications = value),
            secondary: const Icon(Icons.local_offer_outlined),
            title: const Text('Notifikasi Promo'),
            subtitle: const Text('Info diskon dari mitra fotokopi'),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tema'),
              subtitle: Text(_themeLabel),
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
                selected: {_themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(() => _themeMode = selection.first);
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Tentang Aplikasi'),
              subtitle: const Text('Versi, legal, dan informasi GoPrint'),
              onTap: _showAboutApp,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
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
  }
}
