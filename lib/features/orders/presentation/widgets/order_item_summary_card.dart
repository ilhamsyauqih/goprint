import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_flow_manager.dart';

/// Komponen: Ringkasan per item berkas (Langkah 6).
class OrderItemSummaryCard extends StatelessWidget {
  final UploadedFile file;
  final int fileIndex;

  const OrderItemSummaryCard({
    super.key,
    required this.file,
    required this.fileIndex,
  });

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Perhitungan subtotal berkas
    final subtotal = OrderFlowManager.instance.getFileSubtotal(file);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final isDocx = file.name.toLowerCase().endsWith('.docx');
              final iconData = isDocx ? Icons.description_rounded : Icons.picture_as_pdf_rounded;
              final iconColor = isDocx
                  ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
                  : (isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F));
              final iconBgColor = isDocx
                  ? (isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50)
                  : (isDark ? const Color(0xFFEF5350).withValues(alpha: 0.15) : const Color(0xFFFFEBEE));

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Konfigurasi ringkas
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildConfigChip(context, '${file.copies}x Salinan'),
                    _buildConfigChip(context, file.colorMode),
                    _buildConfigChip(context, '${file.paperSize} (${file.paperType})'),
                    if (file.doubleSide) _buildConfigChip(context, 'Bolak-Balik'),
                    if (file.finishing != 'Tanpa Jilid') _buildConfigChip(context, file.finishing),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Pages and Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${file.pageCount} Halaman',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      ),
                    ),
                    Text(
                      _formatCurrency(subtotal),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigChip(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkPrimaryText : Colors.grey.shade700,
            ),
      ),
    );
  }
}
