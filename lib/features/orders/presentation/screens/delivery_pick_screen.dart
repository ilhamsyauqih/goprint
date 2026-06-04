import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';

/// Halaman Langkah 5: Pilih Pickup atau Delivery.
class DeliveryPickScreen extends StatefulWidget {
  const DeliveryPickScreen({super.key});

  @override
  State<DeliveryPickScreen> createState() => _DeliveryPickScreenState();
}

class _DeliveryPickScreenState extends State<DeliveryPickScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Alamat kos mahasiswa ter-mock
  final List<String> _savedAddresses = [
    'Kost Putra Green Garden Room 3A, Jl. Kaliurang KM 5.6, Sleman, DI Yogyakarta',
    'Asrama Mahasiswa Pogung Baru Block C12, Depok, Sleman, DI Yogyakarta',
    'Kost Cantik Pogung Dalangan No. 42B, Depok, Sleman, DI Yogyakarta',
  ];

  int _selectedAddressIndex = 0;
  bool _useCustomAddress = false;

  @override
  void initState() {
    super.initState();
    // Default values
    _orderFlow.deliveryType = 'pickup';
    _orderFlow.deliveryFee = 0;
    _orderFlow.deliveryAddress = null;
    _addressController.text = _savedAddresses[0];
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _onDeliveryTypeChanged(String type) {
    setState(() {
      _orderFlow.deliveryType = type;
      if (type == 'delivery') {
        _orderFlow.deliveryFee = 10000; // Rp 10.000 flat delivery fee
        _updateAddress();
      } else {
        _orderFlow.deliveryFee = 0;
        _orderFlow.deliveryAddress = null;
      }
    });
  }

  void _updateAddress() {
    if (_useCustomAddress) {
      _orderFlow.deliveryAddress = _addressController.text.trim();
    } else {
      _orderFlow.deliveryAddress = _savedAddresses[_selectedAddressIndex];
    }
  }

  void _onNext() {
    if (_orderFlow.deliveryType == 'delivery') {
      if (_useCustomAddress && !_formKey.currentState!.validate()) {
        return;
      }
      _updateAddress();
    }
    context.push('/order/summary');
  }

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shop = _orderFlow.selectedShop;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Metode Pengambilan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Main Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
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
                            'LANGKAH 5 DARI 6',
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
                      'Pilih Cara Pengambilan',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apakah Anda ingin mengambil sendiri dokumen ke toko atau dikirimkan langsung ke alamat Anda?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selector Tipe (Pickup vs Delivery)
                    Row(
                      children: [
                        // Card Pickup
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onDeliveryTypeChanged('pickup'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _orderFlow.deliveryType == 'pickup'
                                    ? (isDark ? AppColors.teal900.withValues(alpha: 0.2) : const Color(0xFFE0F2F1))
                                    : (isDark ? AppColors.darkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orderFlow.deliveryType == 'pickup'
                                      ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.directions_walk_rounded,
                                    color: _orderFlow.deliveryType == 'pickup'
                                        ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                        : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Ambil Sendiri',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _orderFlow.deliveryType == 'pickup'
                                          ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gratis Ongkir',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Card Delivery
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onDeliveryTypeChanged('delivery'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _orderFlow.deliveryType == 'delivery'
                                    ? (isDark ? AppColors.teal900.withValues(alpha: 0.2) : const Color(0xFFE0F2F1))
                                    : (isDark ? AppColors.darkSurface : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orderFlow.deliveryType == 'delivery'
                                      ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_shipping_rounded,
                                    color: _orderFlow.deliveryType == 'delivery'
                                        ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                        : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Kirim ke Alamat',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _orderFlow.deliveryType == 'delivery'
                                          ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ongkir flat Rp 10k',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Area Konfigurasi Dinamis
                    if (_orderFlow.deliveryType == 'pickup') ...[
                      // Detail Toko untuk Pickup
                      Text(
                        'Informasi Toko',
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
                                const Icon(Icons.storefront_rounded, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    shop?.name ?? 'Toko Mitra GoPrint',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    shop?.address ?? 'Jl. Kaliurang KM 5.2, Sleman',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightPrimaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Hari Ini: 08:00 - 21:00 (Buka)',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.successDark : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Silakan kunjungi alamat toko di atas jika status pesanan Anda di aplikasi telah berubah menjadi "Siap Diambil".',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          height: 1.4,
                        ),
                      ),
                    ] else ...[
                      // Detail Alamat Pengantaran
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alamat Pengiriman',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Alamat Custom',
                                style: theme.textTheme.labelMedium,
                              ),
                              Switch(
                                value: _useCustomAddress,
                                activeThumbColor: isDark ? AppColors.teal300 : AppColors.teal700,
                                onChanged: (value) {
                                  setState(() {
                                    _useCustomAddress = value;
                                    if (value) {
                                      _addressController.text = '';
                                    } else {
                                      _addressController.text = _savedAddresses[_selectedAddressIndex];
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (!_useCustomAddress)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _savedAddresses.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == _selectedAddressIndex;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: RadioListTile<int>(
                                activeColor: isDark ? AppColors.teal300 : AppColors.teal700,
                                value: index,
                                // ignore: deprecated_member_use
                                groupValue: _selectedAddressIndex,
                                title: Text(
                                  index == 0 ? 'Domisili Utama (Kost)' : 'Alamat Alternatif $index',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _savedAddresses[index],
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                // ignore: deprecated_member_use
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedAddressIndex = val;
                                      _updateAddress();
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        )
                      else
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
                              Text(
                                'Tulis Alamat Pengiriman Lengkap',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _addressController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Nama Jalan, Gang, Nomor Rumah/Kos, Detail Kamar...',
                                  filled: true,
                                  fillColor: isDark ? AppColors.darkElevated : Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                style: theme.textTheme.bodyMedium,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Alamat pengiriman tidak boleh kosong';
                                  }
                                  return null;
                                },
                                onChanged: (value) => _updateAddress(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
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
                          'Ongkos Kirim',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _orderFlow.deliveryType == 'delivery'
                              ? _formatCurrency(_orderFlow.deliveryFee)
                              : 'Gratis',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onNext,
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
                          'Lanjut ke Ringkasan',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
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
