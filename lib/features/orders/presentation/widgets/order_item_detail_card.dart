import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
              Builder(
                builder: (context) {
                  final isDocx = file.name.toLowerCase().endsWith('.docx');
                  final iconData = isDocx ? Icons.description_rounded : Icons.picture_as_pdf_rounded;
                  final iconColor = isDocx ? const Color(0xFF1976D2) : const Color(0xFFD32F2F);
                  final iconBgColor = isDark
                      ? (isDocx ? const Color(0xFF1565C0).withValues(alpha: 0.15) : const Color(0xFFC62828).withValues(alpha: 0.15))
                      : (isDocx ? const Color(0xFFE3F2FD) : const Color(0xFFFFEBEE));

                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                  );
                },
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
          if (file.filePath != null && file.filePath!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menyiapkan tautan berkas...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    final client = Supabase.instance.client;
                    String cleanPath = file.filePath!;
                    if (cleanPath.contains('order-files/')) {
                      cleanPath = cleanPath.split('order-files/').last;
                    }
                    
                    final signedUrl = await client.storage
                        .from('order-files')
                        .createSignedUrl(cleanPath, 300); // 5 mins

                    final uri = Uri.parse(signedUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      throw Exception('Tidak dapat membuka tautan berkas.');
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal membuka berkas: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Buka Dokumen Asli',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.teal800.withValues(alpha: 0.3) : const Color(0xFFE0F2F1),
                  foregroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
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
