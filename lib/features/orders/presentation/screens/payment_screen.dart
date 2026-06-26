import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/payment_method_selector.dart';
import '../../../../data/services/order_service.dart';
import '../../../../data/services/midtrans_service.dart';
import '../providers/order_provider.dart';

/// Halaman Langkah 6: Konfirmasi & Pembayaran.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
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

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  String _selectedMethod = 'QRIS';
  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  void _startPaymentPolling(String orderId, BuildContext dialogContext) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      final isPaid = await ref.read(midtransServiceProvider).checkTransactionStatus(orderId);
      if (isPaid) {
        timer.cancel();
        _pollingTimer = null;
        
        await _confirmOrderPayment(orderId);

        if (dialogContext.mounted) {
          Navigator.of(dialogContext).pop();
        }
        if (mounted) {
          context.pushReplacement('/order/success');
        }
      }
    });
  }

  Future<void> _confirmOrderPayment(String orderId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('orders').update({
        'payment_status': 'verified',
        'status': 'confirmed',
      }).eq('id', orderId);
      
      _orderFlow.paymentMethod = _selectedMethod;
      _orderFlow.orderNumber = 'GP-${orderId.substring(0, 8).toUpperCase()}';
      _orderFlow.saveCurrentOrder();

      ref.invalidate(activeOrderProvider);
      ref.invalidate(userOrdersProvider);
    } catch (e) {
      debugPrint('Error confirming order payment: $e');
    }
  }

  Future<void> _checkPaymentManually(String orderId, BuildContext dialogContext) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final isPaid = await ref.read(midtransServiceProvider).checkTransactionStatus(orderId);
    
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (isPaid) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      await _confirmOrderPayment(orderId);
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      if (mounted) {
        context.pushReplacement('/order/success');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran belum terdeteksi. Silakan selesaikan pembayaran terlebih dahulu.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _cancelPayment(BuildContext dialogContext) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    Navigator.of(dialogContext).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembayaran dibatalkan. Anda dapat mencobanya kembali dari halaman pembayaran ini.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showWaitingForPaymentDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        _startPaymentPolling(orderId, dialogContext);

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            title: const Row(
              children: [
                Icon(Icons.payment_rounded, color: Colors.teal),
                SizedBox(width: 12),
                Text(
                  'Menunggu Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Silakan selesaikan pembayaran Anda di halaman Midtrans yang telah terbuka.',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Memantau status pembayaran otomatis...',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => _cancelPayment(dialogContext),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => _checkPaymentManually(orderId, dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Saya Sudah Bayar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentInstructions(ThemeData theme, bool isDark) {
    String message = '';
    IconData icon = Icons.payment_rounded;
    
    if (_selectedMethod == 'QRIS') {
      message = 'Kode QRIS dinamis akan dibuat otomatis. Anda dapat membayarnya dengan memindai kode QR menggunakan aplikasi GoPay, OVO, Dana, LinkAja, ShopeePay, atau Mobile Banking Anda.';
      icon = Icons.qr_code_2_rounded;
    } else if (_selectedMethod == 'Transfer') {
      message = 'Anda dapat melakukan pembayaran via Virtual Account (BCA, Mandiri, BRI, BNI, dll.). Nomor VA unik akan dibuat otomatis untuk Anda salin dan bayar melalui ATM atau Mobile Banking.';
      icon = Icons.account_balance_rounded;
    } else {
      message = 'Anda akan diarahkan untuk menyelesaikan pembayaran secara instan menggunakan aplikasi $_selectedMethod melalui gerbang pembayaran aman Midtrans.';
      icon = Icons.flash_on_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal800.withValues(alpha: 0.2)
                      : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Informasi Pembayaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.green.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Pembayaran aman & terenkripsi oleh Midtrans',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onPay() async {
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

    try {
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Silakan masuk terlebih dahulu.');
      }

      final name = currentUser.userMetadata?['name'] as String? ?? 'Customer';
      final email = currentUser.email ?? 'customer@goprint.id';
      final phone = currentUser.userMetadata?['phone'] as String? ?? '081234567890';

      final shopId = await _getOrSeedShopId();

      final servicesData = await client
          .from('services')
          .select()
          .eq('shop_id', shopId)
          .eq('is_active', true);
      
      if (servicesData.isEmpty) {
        throw Exception('Tidak ada layanan aktif di toko ini.');
      }

      final bwService = servicesData.firstWhere(
        (s) => s['name'].toString().toLowerCase().contains('hitam') || s['name'].toString().toLowerCase().contains('bw'),
        orElse: () => servicesData.first,
      );
      final colorService = servicesData.firstWhere(
        (s) => s['name'].toString().toLowerCase().contains('warna') || s['name'].toString().toLowerCase().contains('color'),
        orElse: () => servicesData.first,
      );

      final List<OrderItemInput> inputs = [];
      for (final file in _orderFlow.uploadedFiles) {
        final isColor = file.colorMode == 'Warna';
        final chosenServiceId = isColor ? colorService['id'] as String : bwService['id'] as String;
        final bytes = file.bytes ?? Uint8List.fromList([0, 1, 2, 3]);

        inputs.add(OrderItemInput(
          serviceId: chosenServiceId,
          fileName: file.name,
          pages: file.pageCount,
          copies: file.copies,
          colorMode: isColor ? 'color' : 'bw',
          paperSize: file.paperSize,
          finishing: file.finishing,
          isDoubleSided: file.doubleSide,
          bytes: bytes,
        ));
      }

      final orderId = await ref.read(orderServiceProvider).submitOrder(
        userId: currentUser.id,
        shopId: shopId,
        deliveryType: _orderFlow.deliveryType,
        paymentMethod: _selectedMethod,
        note: _orderFlow.uploadedFiles.map((f) => '${f.name}: ${f.finishing}').join(', '),
        inputs: inputs,
        deliveryFee: _orderFlow.deliveryFee.toDouble(),
      );

      final midtransResult = await ref.read(midtransServiceProvider).createTransaction(
        orderId: orderId,
        grossAmount: _orderFlow.totalFee,
        name: name,
        email: email,
        phone: phone,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (midtransResult['success'] == true) {
        final redirectUrl = midtransResult['redirect_url'] as String;
        
        final uri = Uri.parse(redirectUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Gagal membuka halaman pembayaran Midtrans');
        }

        if (!mounted) return;
        _showWaitingForPaymentDialog(orderId);
      } else {
        throw Exception(midtransResult['error'] ?? 'Gagal membuat transaksi pembayaran');
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesanan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String> _getOrSeedShopId() async {
    final client = Supabase.instance.client;
    final list = await client.from('shops').select('id');
    if (list.isNotEmpty) {
      return list.first['id'] as String;
    }

    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User tidak terautentikasi.');
    }

    // Seed Surya Gemilang
    final shopData = await client.from('shops').insert({
      'owner_id': currentUser.id,
      'name': 'Fotokopi Surya Gemilang',
      'description': 'Menerima jasa print dokumen harian, skripsi, jilid hard/soft cover kilat, laminating.',
      'address': 'Jl. Kaliurang KM 5.2, Sleman, DI Yogyakarta',
      'lat': -7.77,
      'lng': 110.37,
      'is_open': true,
      'rating': 4.8,
    }).select('id').single();

    final newShopId = shopData['id'] as String;

    await client.from('services').insert([
      {
        'shop_id': newShopId,
        'name': 'Print Dokumen A4 (Hitam Putih)',
        'type': 'print',
        'base_price': 500,
        'is_active': true,
        'options': {},
      },
      {
        'shop_id': newShopId,
        'name': 'Print Warna A4 (High Quality)',
        'type': 'print',
        'base_price': 1500,
        'is_active': true,
        'options': {},
      }
    ]);

    return newShopId;
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
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Instruksi Metode Pembayaran menggunakan Midtrans
                  _buildPaymentInstructions(theme, isDark),
                  const SizedBox(height: 16),
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
                            color: isDark ? AppColors.teal900 : Colors.white,
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
