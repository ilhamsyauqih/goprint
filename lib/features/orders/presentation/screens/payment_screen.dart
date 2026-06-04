import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_proof_uploader.dart';

/// Halaman Langkah 6: Konfirmasi & Pembayaran.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? textColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  String _selectedMethod = 'QRIS';
  String? _uploadedProofPath;

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  void _onPay() {
    // Validasi: Jika Transfer Bank, wajib upload bukti transfer
    if (_selectedMethod == 'Transfer' && _uploadedProofPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah bukti transfer terlebih dahulu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Simpan data metode pembayaran
    _orderFlow.paymentMethod = _selectedMethod;
    _orderFlow.paymentProofPath = _uploadedProofPath;

    // Tampilkan Loading Overlay tiruan sebelum sukses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: Card(
            elevation: 8,
            shape: CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    // Redirect setelah 1.5 detik ke Success Screen
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading
        context.pushReplacement('/order/success');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pembayaran',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Main Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.teal800.withValues(alpha: 0.3)
                              : const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LANGKAH 6 DARI 6',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selesaikan Pembayaran',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih metode pembayaran dan ikuti instruksi yang tertera di bawah ini.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Total Pembayaran Ringkas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.headerGradientDark : AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL HARGA',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.teal.shade100,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(_orderFlow.totalFee),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const Divider(color: Colors.white30, height: 24),
                        _PriceRow(
                          label: 'Nomor Pesanan:',
                          value: _orderFlow.orderNumber ?? '-',
                          textColor: Colors.teal.shade100,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selector Metode
                  PaymentMethodSelector(
                    selectedMethod: _selectedMethod,
                    onMethodSelected: (method) {
                      setState(() {
                        _selectedMethod = method;
                        // Reset upload proof jika metode berubah
                        if (method != 'Transfer') {
                          _uploadedProofPath = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Instruksi Khusus Metode
                  if (_selectedMethod == 'QRIS') ...[
                    // Tampilkan QRIS Dummy
                    Text(
                      'Scan Kode QRIS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Judul QRIS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Q R I S',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  color: Colors.red,
                                  child: const Text(
                                    'Nnasional',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // QR Image Mock
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Menggambar Grid QR Code Mockup
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 150,
                                    color: Colors.grey.shade900,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.teal700,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'GoPrint - ${_orderFlow.selectedShop?.name ?? "Mitra"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NMID: ID102030405060',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_selectedMethod == 'Transfer') ...[
                    // Tampilkan Info Rekening Bank
                    Text(
                      'Rekening Transfer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade800,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'MANDIRI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Bank Mandiri Kantor Cabang UGM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nomor Rekening',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '137-00-1234567-8',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nomor rekening berhasil disalin!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Salin'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama Penerima',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'FOTOKOPI SURYA GEMILANG',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Area Uploader
                    PaymentProofUploader(
                      uploadedPath: _uploadedProofPath,
                      onProofChanged: (path) {
                        setState(() {
                          _uploadedProofPath = path;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    // E-Wallet Instant Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.teal800.withValues(alpha: 0.1)
                            : const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.teal900 : Colors.teal.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Anda akan dialihkan ke aplikasi $_selectedMethod setelah menekan tombol "Bayar Sekarang".',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // ─── Sticky Bottom Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Jumlah Tagihan',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(_orderFlow.totalFee),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Bayar Sekarang',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
