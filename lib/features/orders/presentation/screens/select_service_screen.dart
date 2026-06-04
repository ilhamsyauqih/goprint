import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../../../shop/presentation/widgets/service_menu_card.dart';
import '../../data/order_flow_manager.dart';

/// Halaman Langkah 1: Pilih Layanan dari Toko.
class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({
    required this.shopId,
    super.key,
  });

  final String shopId;

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  late Shop _shop;
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;

  @override
  void initState() {
    super.initState();
    // Cari toko berdasarkan ID, fallback ke yang pertama
    _shop = MockShops.shops.firstWhere(
      (s) => s.id == widget.shopId,
      orElse: () => MockShops.shops.first,
    );
    // Daftarkan toko ke Sesi Pesanan Aktif
    _orderFlow.selectShop(_shop);
  }

  void _toggleService(ServiceItem service) {
    setState(() {
      _orderFlow.toggleService(service);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedCount = _orderFlow.selectedServices.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pilih Layanan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Informasi Toko Singkat (Header Card) ──────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: AppColors.teal900,
                    child: Image.network(
                      _shop.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.storefront_rounded, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shop.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.warningDark, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _shop.rating.toString(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _shop.distance,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── List Layanan Toko ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _shop.services.length,
              itemBuilder: (context, index) {
                final service = _shop.services[index];
                final isSelected = _orderFlow.selectedServices.any(
                  (s) => s.name == service.name,
                );

                return ServiceMenuCard(
                  service: service,
                  isSelected: isSelected,
                  onTap: () => _toggleService(service),
                );
              },
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
                  // Jumlah layanan terpilih
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Layanan Terpilih',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$selectedCount Layanan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button Lanjut
                  ElevatedButton(
                    onPressed: selectedCount > 0
                        ? () => context.push('/order/upload')
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                      disabledBackgroundColor: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.5)
                          : AppColors.lightBorder,
                      disabledForegroundColor: isDark
                          ? AppColors.darkMutedText.withValues(alpha: 0.5)
                          : AppColors.lightSubtleText,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Lanjut ke Berkas',
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
