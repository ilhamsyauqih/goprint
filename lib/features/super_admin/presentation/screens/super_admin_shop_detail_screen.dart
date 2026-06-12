import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../../data/super_admin_manager.dart';

class SuperAdminShopDetailScreen extends StatefulWidget {
  final String shopId;

  const SuperAdminShopDetailScreen({required this.shopId, super.key});

  @override
  State<SuperAdminShopDetailScreen> createState() => _SuperAdminShopDetailScreenState();
}

class _SuperAdminShopDetailScreenState extends State<SuperAdminShopDetailScreen> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showSuspendDialog(BuildContext context, SuperAdminManager saManager) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Tangguhkan Toko Mitra', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Masukkan alasan mengapa toko mitra ini ditangguhkan dari platform GoPrint.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Melanggar aturan promosi...',
                    filled: true,
                    fillColor: isDark ? Colors.black26 : Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alasan wajib diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saManager.suspendShop(widget.shopId, _reasonController.text.trim());
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Toko berhasil ditangguhkan!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tangguhkan', style: TextStyle(fontWeight: FontWeight.bold)),
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
        // Find shop in MockShops
        final shopIndex = MockShops.shops.indexWhere((s) => s.id == widget.shopId);
        if (shopIndex == -1) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Detail Toko'),
            body: const Center(child: Text('Toko tidak ditemukan.')),
          );
        }
        final shop = MockShops.shops[shopIndex];

        // Status badges and colors
        Color statusColor = Colors.green.shade600;
        String statusText = 'Aktif';
        if (shop.verificationStatus == 'pending') {
          statusColor = Colors.orange.shade700;
          statusText = 'Menunggu Persetujuan';
        } else if (shop.verificationStatus == 'suspended') {
          statusColor = Colors.red.shade600;
          statusText = 'Ditangguhkan';
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: CustomAppBar(
            title: 'Detail Mitra Toko',
            showBackButton: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/superadmin/shops'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop Profile Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          shop.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  shop.rating.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '•  ${shop.distance}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

                // Penangguhan Detail (jika status suspended)
                if (shop.verificationStatus == 'suspended' && shop.suspensionReason != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50.withValues(alpha: isDark ? 0.1 : 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Penangguhan',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shop.suspensionReason!,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.red.shade300 : Colors.red.shade900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Hubungi & Alamat Detail
                _buildInfoSection(
                  title: 'Informasi Kontak & Lokasi',
                  isDark: isDark,
                  children: [
                    _buildInfoRow(Icons.phone_rounded, 'Nomor HP Toko', shop.phone),
                    _buildInfoRow(Icons.location_on_rounded, 'Alamat Fisik', shop.address),
                  ],
                ),
                const SizedBox(height: 20),

                // Credential Card Admin Toko
                _buildCredentialSection(shop, isDark, theme),
                const SizedBox(height: 20),

                // Legal Documents Simulation
                _buildInfoSection(
                  title: 'Dokumen Legalitas (Simulasi)',
                  isDark: isDark,
                  children: [
                    _buildDocumentTile(
                      icon: Icons.assignment_rounded,
                      title: 'Nomor Induk Berusaha (NIB)',
                      filename: 'NIB_Mitra_${shop.id}_signed.pdf',
                      isDark: isDark,
                    ),
                    _buildDocumentTile(
                      icon: Icons.contact_mail_rounded,
                      title: 'Kartu Tanda Penduduk (KTP) Pemilik',
                      filename: 'KTP_Pemilik_${shop.id}.jpg',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(shop, saManager, context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({required String title, required bool isDark, required List<Widget> children}) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// Credential card: shows generated admin email & password with copy and regenerate
  Widget _buildCredentialSection(Shop shop, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2F4A), const Color(0xFF0D1F35)]
              : [const Color(0xFF0F3460), const Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.key_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kredensial Admin Toko',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Bagikan ke pemilik untuk akses panel admin',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                // Regenerate button
                Tooltip(
                  message: 'Buat ulang password (Simulasi)',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password berhasil di-reset! (Simulasi)'),
                          backgroundColor: Colors.teal,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),

          // Email row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMAIL LOGIN',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.adminEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white60),
                      tooltip: 'Salin email',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shop.adminEmail));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email disalin ke clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Colors.white.withValues(alpha: 0.08)),

          // Password row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASSWORD',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _passwordVisible ? shop.adminPassword : '\u2022' * shop.adminPassword.length,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _passwordVisible ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: _passwordVisible ? 0 : 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: Colors.white60,
                      ),
                      tooltip: _passwordVisible ? 'Sembunyikan' : 'Tampilkan',
                      onPressed: () {
                        setState(() => _passwordVisible = !_passwordVisible);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.white60),
                      tooltip: 'Salin password',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shop.adminPassword));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password disalin ke clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gunakan kredensial ini untuk login sebagai Admin Toko di GoPrint.',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildDocumentTile({
    required IconData icon,
    required String title,
    required String filename,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade400, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(filename, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_rounded, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membuka file "$filename" (Simulasi)'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Shop shop, SuperAdminManager saManager, BuildContext context) {
    final status = shop.verificationStatus;

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showSuspendDialog(context, saManager),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tolak Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                saManager.approveShop(widget.shopId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toko mitra telah berhasil disetujui!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Setujui Toko', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } else if (status == 'approved') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showSuspendDialog(context, saManager),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Tangguhkan Toko Mitra', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      // suspended
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            saManager.approveShop(widget.shopId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Toko mitra berhasil diaktifkan kembali!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Aktifkan Kembali Toko', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }
  }
}
