import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/mock_shops.dart';

/// Komponen: [ServiceMenuCard] — kartu layanan (nama, harga mulai dari, estimasi waktu)
class ServiceMenuCard extends StatelessWidget {
  const ServiceMenuCard({
    required this.service,
    this.onTap,
    super.key,
  });

  final ServiceItem service;
  final VoidCallback? onTap;

  // Helper untuk format rupiah sederhana
  String _formatRupiah(double val) {
    final formatStr = val.toStringAsFixed(0);
    final regExp = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return 'Rp ${formatStr.replaceAllMapped(regExp, (Match m) => '${m[1]}.')}';
  }

  // Dapatkan ikon penanda berdasarkan kategori layanan
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'print':
        return Icons.print_rounded;
      case 'jilid':
        return Icons.menu_book_rounded;
      case 'laminating':
        return Icons.layers_rounded;
      case 'scan':
        return Icons.document_scanner_rounded;
      case 'fotokopi':
        return Icons.file_copy_rounded;
      case 'template':
        return Icons.description_rounded;
      default:
        return Icons.extension_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─── Ikon Kategori ──────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.teal800.withValues(alpha: 0.2)
                    : const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(service.category),
                color: isDark ? AppColors.teal300 : AppColors.teal700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // ─── Deskripsi Layanan ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mulai ${_formatRupiah(service.priceStartingFrom)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightSubtleText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.estimateTime,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.lightSubtleText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ─── Tombol Aksi "Pilih" ─────────────────────────────────────
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Pilih',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.teal900 : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
