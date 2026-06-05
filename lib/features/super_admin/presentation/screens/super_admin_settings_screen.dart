import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';
import '../widgets/super_admin_drawer.dart';

class SuperAdminSettingsScreen extends StatefulWidget {
  const SuperAdminSettingsScreen({super.key});

  @override
  State<SuperAdminSettingsScreen> createState() => _SuperAdminSettingsScreenState();
}

class _SuperAdminSettingsScreenState extends State<SuperAdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feeController;
  late TextEditingController _messageController;
  late bool _isMaintenance;

  @override
  void initState() {
    super.initState();
    final config = SuperAdminManager.instance.config;
    _feeController = TextEditingController(text: config.platformFee.toString());
    _messageController = TextEditingController(text: config.maintenanceMessage);
    _isMaintenance = config.isMaintenance;
  }

  @override
  void dispose() {
    _feeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final double fee = double.parse(_feeController.text.trim());
      SuperAdminManager.instance.updateSystemConfig(
        platformFee: fee,
        isMaintenance: _isMaintenance,
        maintenanceMessage: _messageController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfigurasi sistem berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: const SuperAdminDrawer(currentRoute: '/superadmin/settings'),
      appBar: CustomAppBar(
        title: 'Pengaturan Sistem',
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfigurasi Global Platform',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Atur biaya transaksi dan status operasional sistem secara real-time.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              const SizedBox(height: 20),

              // Platform Fee Config Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.percent_rounded, color: Colors.purple, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Komisi & Biaya Platform',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Atur besaran potongan komisi (%) dari setiap pesanan cetak yang diselesaikan oleh mitra toko.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _feeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Persentase Fee Platform (%)',
                        hintText: 'Contoh: 10.0',
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixText: '%',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Persentase wajib diisi';
                        }
                        final double? fee = double.tryParse(value.trim());
                        if (fee == null || fee < 0 || fee > 100) {
                          return 'Masukkan persentase yang valid (0 - 100)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Maintenance Mode Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.build_rounded, color: Colors.orange, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Mode Pemeliharaan (Maintenance)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isMaintenance,
                          activeThumbColor: Colors.purple.shade600,
                          onChanged: (val) {
                            setState(() {
                              _isMaintenance = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aktifkan opsi ini untuk membatasi akses aplikasi bagi pengguna umum saat pemeliharaan server sedang berlangsung.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (_isMaintenance) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Pesan Banner Maintenance',
                          hintText: 'Masukkan pengumuman pemeliharaan...',
                          filled: true,
                          fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) {
                          if (_isMaintenance && (value == null || value.trim().isEmpty)) {
                            return 'Pesan wajib diisi saat mode maintenance aktif';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Konfigurasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
