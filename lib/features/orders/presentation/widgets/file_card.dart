import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/order_flow_manager.dart';

/// Komponen: [FileCard] — tampil nama file, ukuran, jumlah halaman, tombol hapus
class FileCard extends StatelessWidget {
  const FileCard({
    required this.file,
    this.onDelete,
    super.key,
  });

  final UploadedFile file;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
          children: [
            // ─── Ikon Berkas (Dynamic Icon based on file type) ──────────────────────────────
            Builder(
              builder: (context) {
                final isDocx = file.name.toLowerCase().endsWith('.docx');
                final iconData = isDocx ? Icons.description_rounded : Icons.picture_as_pdf_rounded;
                final iconColor = isDocx
                    ? (isDark ? Colors.blue.shade300 : Colors.blue.shade700)
                    : (isDark ? AppColors.errorDark : AppColors.error);
                final iconBgColor = isDocx
                    ? (isDark ? Colors.blue.shade900.withValues(alpha: 0.2) : Colors.blue.shade50)
                    : (isDark ? const Color(0xFFEF5350).withValues(alpha: 0.15) : const Color(0xFFFFEBEE));

                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 26,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // ─── Detail Berkas ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama File
                  Text(
                    file.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Metadata: Ukuran & Jumlah Halaman
                  Row(
                    children: [
                      Text(
                        file.size,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.lightSubtleText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${file.pageCount} halaman',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.lightSubtleText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Tombol Hapus (Jika Ada) ──────────────────────────────
            if (onDelete != null) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: isDark ? AppColors.errorDark : AppColors.error,
                  size: 22,
                ),
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.errorDark.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
