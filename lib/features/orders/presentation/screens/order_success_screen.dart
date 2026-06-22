import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/order_flow_manager.dart';

/// Halaman Sukses Pemesanan (Langkah Akhir).
class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with SingleTickerProviderStateMixin {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _savedOrderNumber = '';

  @override
  void initState() {
    super.initState();
    // Ambil nomor pesanan sebelum di-clear
    _savedOrderNumber = _orderFlow.orderNumber ?? 'DOC-20260604-0001';

    // Inisialisasi animasi scale fallback
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goToHome() {
    _orderFlow.clear();
    context.go('/home');
  }

  void _goToOrders() {
    _orderFlow.clear();
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animasi Lottie Printer / Sukses
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/lottie/splash_print.json',
                    fit: BoxFit.contain,
                    // Tambahkan fallback jika error memuat
                    errorBuilder: (context, error, stackTrace) {
                      return ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.successDark.withValues(alpha: 0.2)
                                : const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: isDark ? AppColors.successDark : AppColors.success,
                            size: 80,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Headline Sukses
              Text(
                'Pesanan Berhasil Dikirim!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Deskripsi
              Text(
                'Terima kasih! Pesanan Anda telah diterima oleh toko dan sedang menunggu konfirmasi pembayaran serta dokumen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Card Nomor Pesanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'NOMOR PESANAN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _savedOrderNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark ? AppColors.warningDark : AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Menunggu Verifikasi Toko',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.warningDark : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tombol Aksi
              Column(
                children: [
                  // Tombol Lihat Detail Pesanan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToOrders,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                        foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Lihat Detail Pesanan',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? AppColors.teal900 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol Kembali ke Beranda
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _goToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                        side: BorderSide(
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kembali ke Beranda',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
