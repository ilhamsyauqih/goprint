import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/file_card.dart';
import '../widgets/file_upload_area.dart';

/// Halaman Langkah 2: Unggah Berkas PDF.
class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;

  // Daftar berkas tiruan untuk disimulasikan saat di-tap
  final List<Map<String, dynamic>> _mockFilesToUpload = [
    {
      'name': 'Tugas_Akhir_Bab_1-3_Final.pdf',
      'size': '1.8 MB',
      'pages': 14,
    },
    {
      'name': 'Laporan_Magang_PrimaPrint.pdf',
      'size': '4.5 MB',
      'pages': 36,
    },
    {
      'name': 'CV_Ilham_Syauqi_2026.pdf',
      'size': '720 KB',
      'pages': 2,
    },
    {
      'name': 'Lampiran_Dokumen_Persetujuan.pdf',
      'size': '2.1 MB',
      'pages': 8,
    },
  ];

  int _uploadIndex = 0;

  void _simulateUpload() {
    if (_uploadIndex < _mockFilesToUpload.length) {
      final fileData = _mockFilesToUpload[_uploadIndex];
      setState(() {
        _orderFlow.addMockFile(
          fileData['name'],
          fileData['size'],
          fileData['pages'],
        );
        _uploadIndex++;
      });

      // Tampilkan feedback snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berkas "${fileData['name']}" berhasil diunggah!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Jika list tiruan habis, tambahkan berkas standar
      final mockName = 'Dokumen_Tambahan_${DateTime.now().millisecondsSinceEpoch % 100}.pdf';
      setState(() {
        _orderFlow.addMockFile(mockName, '1.1 MB', 5);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berkas "$mockName" berhasil diunggah!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeFile(String id, String fileName) {
    setState(() {
      _orderFlow.removeFile(id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berkas "$fileName" berhasil dihapus'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileCount = _orderFlow.uploadedFiles.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Unggah Berkas',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Main Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                          'LANGKAH 2 DARI 3',
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
                    'Unggah Dokumen PDF',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Silakan unggah dokumen yang ingin dicetak. Anda dapat mengunggah beberapa dokumen sekaligus.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Area Unggah File
                  FileUploadArea(onTap: _simulateUpload),
                  const SizedBox(height: 28),

                  // Header List File
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Berkas Terunggah ($fileCount)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (fileCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _orderFlow.uploadedFiles.clear();
                              _uploadIndex = 0;
                            });
                          },
                          child: const Text('Hapus Semua'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // List File Terunggah
                  if (fileCount == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.note_add_rounded,
                              size: 48,
                              color: isDark
                                  ? AppColors.darkMutedText.withValues(alpha: 0.3)
                                  : AppColors.lightSubtleText.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada dokumen yang diunggah',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _orderFlow.uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = _orderFlow.uploadedFiles[index];
                        return FileCard(
                          file: file,
                          onDelete: () => _removeFile(file.id, file.name),
                        );
                      },
                    ),
                ],
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
                          'Total Dokumen',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$fileCount Berkas',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: fileCount > 0
                        ? () => context.push('/order/config')
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
                          'Lanjut ke Pengaturan',
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
