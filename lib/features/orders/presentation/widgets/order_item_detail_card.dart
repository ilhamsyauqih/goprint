import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_flow_manager.dart';

/// Kartu rincian berkas cetak (Order Item Detail Card) untuk detail pesanan.
class OrderItemDetailCard extends StatelessWidget {
  final UploadedFile file;

  const OrderItemDetailCard({required this.file, super.key});

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Menghitung subtotal per berkas secara langsung
    final subtotal = OrderFlowManager.instance.getFileSubtotal(file);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header berkas: Icon PDF, nama berkas & detail cetak dasar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFFC62828).withValues(alpha: 0.15) 
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${file.size} · ${file.pageCount} Halaman · ${file.copies} Rangkap',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 16),
          // Ringkasan konfigurasi cetak menggunakan chip mini
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildConfigChip(file.colorMode, Icons.color_lens_rounded, isDark),
              _buildConfigChip('${file.paperSize} (${file.paperType})', Icons.layers_rounded, isDark),
              if (file.doubleSide)
                _buildConfigChip('Bolak-Balik (Duplex)', Icons.library_books_rounded, isDark),
              _buildConfigChip(file.finishing, Icons.bookmark_added_rounded, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Cetak',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(subtotal),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigChip(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.teal300 : AppColors.teal700,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkPrimaryText.withValues(alpha: 0.8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
