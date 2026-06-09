import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_proof_uploader.dart';
import '../../../../data/services/order_service.dart';
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
  String? _uploadedProofPath;

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  Future<void> _onPay() async {
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

    // Tampilkan Loading Overlay
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

      // 1. Dapatkan atau seed shopId di database
      final shopId = await _getOrSeedShopId();

      // 2. Dapatkan services untuk toko tersebut di database
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

      // 3. Konversi file di order flow ke OrderItemInput
      final List<OrderItemInput> inputs = [];
      for (final file in _orderFlow.uploadedFiles) {
        final isColor = file.colorMode == 'Warna';
        final chosenServiceId = isColor ? colorService['id'] as String : bwService['id'] as String;

        // Jika user menggunakan mock file (bytes == null), kita buat mock bytes agar uploadOrderFile tidak error
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

      // 4. Submit order ke database via OrderService
      final orderId = await ref.read(orderServiceProvider).submitOrder(
        userId: currentUser.id,
        shopId: shopId,
        deliveryType: _orderFlow.deliveryType,
        paymentMethod: _selectedMethod,
        note: _orderFlow.uploadedFiles.map((f) => '${f.name}: ${f.finishing}').join(', '),
        inputs: inputs,
        deliveryFee: _orderFlow.deliveryFee.toDouble(),
      );

      // 5. Jika metode pembayaran manual transfer bank, update payment_proof_url di order
      if (_selectedMethod == 'Transfer' && _uploadedProofPath != null) {
        await client.from('orders').update({
          'payment_proof_url': _uploadedProofPath,
          'payment_status': 'pending', // Menunggu Verifikasi
          'status': 'pending',
        }).eq('id', orderId);
      } else {
        // Otomatis verifikasi untuk QRIS (sesuai flow aplikasi)
        await client.from('orders').update({
          'payment_status': 'verified',
          'status': 'confirmed',
        }).eq('id', orderId);
      }

      // Simpan data metode pembayaran secara lokal
      _orderFlow.paymentMethod = _selectedMethod;
      _orderFlow.paymentProofPath = _uploadedProofPath;
      _orderFlow.orderNumber = 'GP-${orderId.substring(0, 8).toUpperCase()}';
      _orderFlow.saveCurrentOrder();

      ref.invalidate(activeOrderProvider);
      ref.invalidate(userOrdersProvider);

      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading

      // Redirect ke Success Screen
      context.pushReplacement('/order/success');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
