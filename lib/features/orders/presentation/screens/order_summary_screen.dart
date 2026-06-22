import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/order_item_summary_card.dart';

/// Halaman Langkah 5/6: Ringkasan Pesanan Lengkap Sebelum Submit.
class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final orderFlow = OrderFlowManager.instance;
    final shop = orderFlow.selectedShop;

    // Safety check
    if (orderFlow.uploadedFiles.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Ringkasan Pesanan'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tidak ada berkas yang dikonfigurasi.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Ringkasan Pesanan',
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
                  Text(
                    'Konfirmasi Pesanan',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon periksa kembali pesanan Anda sebelum melanjutkan ke proses pembayaran.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Toko
                  Text(
                    'Toko Pilihan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDark ? AppColors.teal900 : const Color(0xFFE0F2F1),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop?.name ?? 'Toko Mitra',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                shop?.address ?? 'Alamat toko tidak tersedia',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Daftar Dokumen
                  Text(
                    'Berkas Cetak (${orderFlow.uploadedFiles.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: orderFlow.uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final file = orderFlow.uploadedFiles[index];
                      return OrderItemSummaryCard(
                        file: file,
                        fileIndex: index,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Info Pengambilan / Pengiriman
                  Text(
                    'Pengambilan / Pengiriman',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              orderFlow.deliveryType == 'delivery'
                                  ? Icons.local_shipping_rounded
                                  : Icons.directions_walk_rounded,
                              color: isDark ? AppColors.teal300 : AppColors.teal700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              orderFlow.deliveryType == 'delivery'
                                  ? 'Kirim ke Alamat'
                                  : 'Ambil Sendiri (Pickup)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (orderFlow.deliveryType == 'delivery' && orderFlow.deliveryAddress != null) ...[
                          const Divider(height: 20),
                          Text(
                            'Alamat Tujuan:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderFlow.deliveryAddress!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ] else if (orderFlow.deliveryType == 'pickup') ...[
                          const Divider(height: 20),
                          Text(
                            'Alamat Toko:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop?.address ?? 'Jl. Kaliurang KM 5.2',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Rincian Biaya
                  Text(
                    'Rincian Biaya',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal Cetak (${orderFlow.uploadedFiles.length} berkas)',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              _formatCurrency(orderFlow.itemSubtotal),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Biaya Pengantaran',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              orderFlow.deliveryType == 'delivery'
                                  ? _formatCurrency(orderFlow.deliveryFee)
                                  : 'Rp 0',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatCurrency(orderFlow.totalFee),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.teal300 : AppColors.teal700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          'Total Pembayaran',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(orderFlow.totalFee),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      orderFlow.generateOrderNumber();
                      context.push('/order/payment');
                    },
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
                          'Proses Pembayaran',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.teal900 : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.payment_rounded, size: 18),
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
