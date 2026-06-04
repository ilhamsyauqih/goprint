import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Komponen: [PdfPreviewWidget] — preview file PDF dalam aplikasi
class PdfPreviewWidget extends StatefulWidget {
  const PdfPreviewWidget({
    required this.totalPages,
    required this.fileName,
    super.key,
  });

  final int totalPages;
  final String fileName;

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  int _currentPage = 1;

  void _nextPage() {
    if (_currentPage < widget.totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  @override
  void didUpdateWidget(covariant PdfPreviewWidget oldDelegate) {
    super.didUpdateWidget(oldDelegate);
    // Reset halaman jika totalPages berubah
    if (widget.totalPages < _currentPage) {
      _currentPage = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ─── Kertas A4 Simulasi ──────────────────────────────────────
        AspectRatio(
          aspectRatio: 1 / 1.414, // Proporsi standar A4 (ISO 216)
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Kertas selalu putih untuk preview cetak
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock Header Dokumen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 8,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Hal. $_currentPage dari ${widget.totalPages}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Divider(color: Colors.grey, thickness: 0.8),
                  const SizedBox(height: 16),

                  // Mock Judul Dokumen (Halaman 1 saja)
                  if (_currentPage == 1) ...[
                    Container(
                      height: 16,
                      width: 160,
                      decoration: BoxDecoration(
                        color: AppColors.teal900,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Mock Paragraf Teks (Garis-garis abu-abu)
                  ...List.generate(_currentPage == 1 ? 5 : 8, (index) {
                    final isShort = index % 3 == 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 8,
                        width: isShort ? 120 : double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Mock Gambar/Ilustrasi di tengah dokumen
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mock Paragraf Teks bawah
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ─── Kontrol Navigasi Halaman ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol Prev
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? _prevPage : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                disabledBackgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(width: 16),

            // Indikator Halaman
            Text(
              'Halaman $_currentPage dari ${widget.totalPages}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),

            // Tombol Next
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < widget.totalPages ? _nextPage : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                disabledBackgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
