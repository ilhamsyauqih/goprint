import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';

class SuperAdminPayoutDetailScreen extends StatefulWidget {
  final String payoutId;

  const SuperAdminPayoutDetailScreen({required this.payoutId, super.key});

  @override
  State<SuperAdminPayoutDetailScreen> createState() => _SuperAdminPayoutDetailScreenState();
}

class _SuperAdminPayoutDetailScreenState extends State<SuperAdminPayoutDetailScreen> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  void _showRejectDialog(BuildContext context, SuperAdminManager saManager) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          title: const Text('Tolak Pengajuan Payout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Masukkan alasan penolakan penarikan dana ini. Alasan akan dikirimkan kepada mitra toko.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Nomor rekening tidak valid...',
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
                  saManager.rejectPayout(widget.payoutId, _reasonController.text.trim());
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengajuan penarikan dana berhasil ditolak.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _simulateApprove(BuildContext context, SuperAdminManager saManager) {
    // Simulasi upload bukti transfer sukses
    const mockTransferProof = 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600';
    saManager.approvePayout(widget.payoutId, mockTransferProof);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Penarikan dana berhasil disetujui (Bukti transfer diunggah)!'),
        backgroundColor: Colors.green,
      ),
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
        final payoutIndex = saManager.payouts.indexWhere((p) => p.id == widget.payoutId);
        if (payoutIndex == -1) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Detail Payout'),
            body: const Center(child: Text('Pengajuan tidak ditemukan.')),
          );
        }
        final payout = saManager.payouts[payoutIndex];

        Color statusColor = Colors.grey;
        String statusText = payout.status.toUpperCase();
        if (payout.status == 'pending') {
          statusColor = Colors.orange.shade700;
          statusText = 'MENUNGGU VERIFIKASI';
        } else if (payout.status == 'processing') {
          statusColor = Colors.blue.shade600;
          statusText = 'DIPROSES';
        } else if (payout.status == 'success') {
          statusColor = Colors.green.shade600;
          statusText = 'SUKSES DITRANSFER';
        } else if (payout.status == 'rejected') {
          statusColor = Colors.red.shade600;
          statusText = 'DITOLAK';
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: CustomAppBar(
            title: 'Verifikasi Penarikan',
            showBackButton: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go('/superadmin/payouts'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payout status header card
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
                          Text(
                            payout.id,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _formatCurrency(payout.amount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diajukan pada: ${payout.requestDate}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rejection info if rejected
                if (payout.status == 'rejected' && payout.rejectReason != null) ...[
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
                            Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Alasan Penolakan Payout',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          payout.rejectReason!,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.red.shade300 : Colors.red.shade900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Shop & Account Details
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
                        'Informasi Penerima & Rekening',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.storefront_rounded, 'Toko Mitra', payout.shopName),
                      _buildDetailRow(Icons.account_balance_rounded, 'Bank Penerima', payout.bankName),
                      _buildDetailRow(Icons.credit_card_rounded, 'Nomor Rekening', payout.accountNumber),
                      _buildDetailRow(Icons.person_outline_rounded, 'Pemilik Rekening', payout.accountHolderName),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Transfer proof area if successful
                if (payout.status == 'success' && payout.transferProof != null) ...[
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
                          'Bukti Transfer Bank',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            payout.transferProof!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Action buttons if pending or processing
                if (payout.status == 'pending' || payout.status == 'processing') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showRejectDialog(context, saManager),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Tolak Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _simulateApprove(context, saManager),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Approve & Kirim', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
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
