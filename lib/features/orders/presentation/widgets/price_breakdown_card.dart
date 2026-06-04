import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_flow_manager.dart';

/// Komponen: Rincian harga per berkas (Langkah 4).
class PriceBreakdownCard extends StatelessWidget {
  final UploadedFile file;
  final int fileIndex;

  const PriceBreakdownCard({
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
    
    // Perhitungan harga
    final basePrice = file.colorMode == 'Warna' ? 1500 : 500;
    final printCost = basePrice * file.pageCount;
    
    int paperPremium = 0;
    if (file.paperType == 'HVS 80g') {
      paperPremium = 200;
    } else if (file.paperType == 'Art Paper') {
      paperPremium = 1000;
    }
    final paperCost = paperPremium * file.pageCount;
    
    int finishingCost = 0;
    if (file.finishing == 'Jilid Lakban' || file.finishing == 'Jilid Lakban Biasa') {
      finishingCost = 5000;
    } else if (file.finishing == 'Jilid Spiral' || file.finishing == 'Jilid Spiral Kawat') {
      finishingCost = 15000;
    }

    final singleCopyCost = printCost + paperCost + finishingCost;
    final totalCost = singleCopyCost * file.copies;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Berkas
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.teal800.withValues(alpha: 0.3)
                        : const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BERKAS ${fileIndex + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        file.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            
            // Jasa Cetak
            _buildRow(
              context,
              'Jasa Print (${file.colorMode})',
              '${file.pageCount} halaman × ${_formatCurrency(basePrice)}',
              _formatCurrency(printCost),
            ),
            
            // Kertas Premium
            if (paperPremium > 0) ...[
              const SizedBox(height: 8),
              _buildRow(
                context,
                'Kertas (${file.paperType})',
                '${file.pageCount} halaman × ${_formatCurrency(paperPremium)}',
                _formatCurrency(paperCost),
              ),
            ],
            
            // Penjilidan
            if (finishingCost > 0) ...[
              const SizedBox(height: 8),
              _buildRow(
                context,
                'Jilid (${file.finishing})',
                'Biaya penjilidan dokumen',
                _formatCurrency(finishingCost),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Cetak Bolak-balik info (jika diaktifkan)
            if (file.doubleSide) ...[
              _buildRow(
                context,
                'Cetak Bolak-Balik (Duplex)',
                'Diaktifkan',
                'Gratis',
              ),
              const SizedBox(height: 8),
            ],

            // Salinan
            _buildRow(
              context,
              'Jumlah Salinan',
              'Dikali ${file.copies} eksemplar',
              '× ${file.copies}',
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal Berkas',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(totalCost),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String subtitle, String price) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
