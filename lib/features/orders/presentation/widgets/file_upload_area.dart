import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Komponen: [FileUploadArea] — dashed border teal, ikon upload, drag & drop hint
class FileUploadArea extends StatelessWidget {
  const FileUploadArea({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: DashedRectPainter(
          color: isDark ? AppColors.teal300 : AppColors.teal700,
          borderRadius: 16,
          strokeWidth: 1.8,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.teal900.withValues(alpha: 0.05)
                : const Color(0xFFE0F2F1).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Awan Upload
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal800.withValues(alpha: 0.3)
                      : const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload_rounded,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Judul Utama
              Text(
                'Unggah File Dokumen',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),

              // Hint Deskripsi
              Text(
                'Seret & lepas berkas PDF atau DOCX di sini atau ketuk area ini untuk mencari berkas.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Ketentuan File
              Text(
                'Format yang didukung: .pdf, .docx (Maks. 25 MB)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar outline putus-putus (*dashed line*) di sekeliling kontainer
class DashedRectPainter extends CustomPainter {
  DashedRectPainter({
    required this.color,
    required this.borderRadius,
    this.strokeWidth = 1.5,
    this.gap = 5.0,
    this.dashLength = 8.0,
  });

  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}
