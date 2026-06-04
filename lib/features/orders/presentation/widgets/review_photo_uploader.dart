import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Komponen upload foto bukti cetak (ReviewPhotoUploader) untuk formulir ulasan.
class ReviewPhotoUploader extends StatelessWidget {
  final List<String> photos;
  final ValueChanged<List<String>> onPhotosChanged;

  const ReviewPhotoUploader({
    required this.photos,
    required this.onPhotosChanged,
    super.key,
  });

  // Kumpulan URL foto mock Unsplash bertema dokumen/kertas cetakan
  static const List<String> _mockPhotoPool = [
    'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1516962215378-7fa2e137ae93?q=80&w=300&auto=format&fit=crop',
  ];

  void _addMockPhoto() {
    if (photos.length >= 3) return;
    
    // Menambahkan foto mock berikutnya berdasarkan indeks panjang list saat ini
    final nextPhoto = _mockPhotoPool[photos.length];
    final updatedList = List<String>.from(photos)..add(nextPhoto);
    onPhotosChanged(updatedList);
  }

  void _removePhoto(int index) {
    final updatedList = List<String>.from(photos)..removeAt(index);
    onPhotosChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Foto Bukti Hasil Cetak',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${photos.length}/3)',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // List foto-foto yang telah ditambahkan
            ...List.generate(photos.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gambar Thumbnail
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          photos[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
                            child: const Icon(Icons.broken_image_rounded),
                          ),
                        ),
                      ),
                    ),
                    // Tombol Hapus (X) di atas kanan
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            // Tombol Card Tambah Foto (hanya tampil jika kurang dari 3)
            if (photos.length < 3)
              GestureDetector(
                onTap: _addMockPhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.teal800.withValues(alpha: 0.08) 
                        : AppColors.teal700.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        size: 24,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
