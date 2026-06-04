import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../../data/order_flow_manager.dart';
import '../../data/order_model.dart';
import '../widgets/review_photo_uploader.dart';
import '../widgets/star_rating_selector.dart';

/// Layar Tulis Ulasan & Rating (WriteReviewScreen) untuk pesanan yang telah selesai.
class WriteReviewScreen extends StatefulWidget {
  final String orderId;

  const WriteReviewScreen({required this.orderId, super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  final TextEditingController _commentController = TextEditingController();
  
  late OrderModel? _order;
  int _rating = 0;
  List<String> _photos = [];
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadOrder() {
    final id = widget.orderId == 'dummy_active' ? 'GP-1092' : widget.orderId;
    final found = _orderFlow.orders.where((o) => o.orderNumber == id).toList();
    if (found.isNotEmpty) {
      _order = found.first;
    } else {
      _order = null;
    }
  }

  void _submitReview() {
    // Validasi: rating wajib diisi sebelum submit
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating wajib diisi sebelum mengirim ulasan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_order == null) return;

    // Tampilkan loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          elevation: 8,
          shape: CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    // Simulasi pengiriman data ulasan
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog

      // 1. Buat ReviewItem baru
      final newReview = ReviewItem(
        name: _isAnonymous ? 'Pengguna Anonim' : 'Ilham',
        rating: _rating.toDouble(),
        comment: _commentController.text.trim().isEmpty
            ? 'Hasil cetak rapi, jilid sangat kuat, dan pengerjaan cepat.'
            : _commentController.text.trim(),
        date: 'Baru saja',
        avatarUrl: _isAnonymous
            ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100'
            : 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
        reviewPhotos: _photos,
      );

      // 2. Tambahkan ke data review Toko (Shop) bersangkutan
      final shopIndex = MockShops.shops.indexWhere((s) => s.id == _order!.shop.id);
      if (shopIndex != -1) {
        final currentShop = MockShops.shops[shopIndex];
        final updatedReviews = List<ReviewItem>.from(currentShop.reviews)..insert(0, newReview);
        
        // Hitung ulang rating rata-rata toko
        double newAvgRating = currentShop.rating;
        if (currentShop.reviews.isNotEmpty) {
          final totalStars = currentShop.reviews.fold<double>(0.0, (sum, r) => sum + r.rating) + _rating;
          newAvgRating = double.parse((totalStars / (currentShop.reviews.length + 1)).toStringAsFixed(1));
        }

        MockShops.shops[shopIndex] = currentShop.copyWith(
          reviews: updatedReviews,
          rating: newAvgRating,
        );
      }

      // 3. Set order status menjadi reviewed
      setState(() {
        _order!.isReviewed = true;
      });

      // Tampilkan popup sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Ulasan Terkirim!'),
            ],
          ),
          content: const Text('Terima kasih! Ulasan Anda telah terdaftar dan akan ditampilkan di halaman rincian toko mitra.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog sukses
                Navigator.of(context).pop(true); // Kembali ke halaman Detail Pesanan
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_order == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Tulis Ulasan', showBackButton: true),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CustomAppBar(
        title: 'Tulis Ulasan',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card ringkasan Toko dan Pesanan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.shop.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
                              child: const Icon(Icons.storefront_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.shop.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pesanan ${order.orderNumber}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bagian Interaktif StarRatingSelector
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Bagaimana kualitas hasil cetakan?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StarRatingSelector(
                          rating: _rating,
                          onRatingChanged: (val) {
                            setState(() {
                              _rating = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Input Text Ulasan / Komentar
                  Text(
                    'Ulasan Tertulis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 200,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Bagikan pengalaman Anda menggunakan jasa cetak toko ini (opsional)...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bagian ReviewPhotoUploader
                  ReviewPhotoUploader(
                    photos: _photos,
                    onPhotosChanged: (newList) {
                      setState(() {
                        _photos = newList;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Baris Pengaturan Anonimitas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: isDark ? AppColors.teal300 : AppColors.teal700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kirim sebagai Anonim',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Nama Anda akan disamarkan bagi pengguna lain',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isAnonymous,
                          onChanged: (val) {
                            setState(() {
                              _isAnonymous = val;
                            });
                          },
                          activeThumbColor: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Tombol Sticky Kirim Ulasan
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Kirim Ulasan',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
