import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Komponen: Area Upload Bukti Transfer (Langkah 6).
class PaymentProofUploader extends StatefulWidget {
  final String? uploadedPath;
  final ValueChanged<String?> onProofChanged;

  const PaymentProofUploader({
    super.key,
    required this.uploadedPath,
    required this.onProofChanged,
  });

  @override
  State<PaymentProofUploader> createState() => _PaymentProofUploaderState();
}

class _PaymentProofUploaderState extends State<PaymentProofUploader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadProof() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        final pickedFile = result.files.single;
        final bytes = pickedFile.bytes;
        if (bytes == null) {
          throw Exception('Gagal membaca data berkas.');
        }

        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          throw Exception('Pengguna tidak masuk.');
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final cleanFileName = pickedFile.name.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
        final path = '${currentUser.id}/${timestamp}_$cleanFileName';

        await Supabase.instance.client.storage
            .from('payment-proofs')
            .uploadBinary(path, bytes);

        setState(() {
          _isUploading = false;
        });

        widget.onProofChanged(path);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bukti transfer berhasil diunggah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah bukti: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeProof() {
    widget.onProofChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unggah Bukti Transfer',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Wajib mengunggah bukti jika memilih metode manual Transfer Bank agar admin dapat memverifikasi.',
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        if (widget.uploadedPath == null)
          // Tampilan Belum Upload / Sedang Upload
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadProof,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                  child: Center(
                    child: _isUploading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: isDark ? AppColors.teal300 : AppColors.teal700,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Mengunggah bukti...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_rounded,
                                size: 36,
                                color: isDark ? AppColors.teal300 : AppColors.teal700,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk Upload Bukti Bayar',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Mendukung format PNG, JPG (Maks. 5MB)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          )
        else
          // Tampilan Sukses Upload
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.successDark : AppColors.success,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.successDark.withValues(alpha: 0.2)
                        : const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: isDark ? AppColors.successDark : AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bukti Pembayaran Terunggah',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.uploadedPath!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeProof,
                  icon: const Icon(Icons.cancel_rounded),
                  color: isDark ? AppColors.errorDark : AppColors.error,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Painter kustom untuk menggambar dashed border
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    // Top border
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }

    // Right border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    // Bottom border
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }

    // Left border
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
