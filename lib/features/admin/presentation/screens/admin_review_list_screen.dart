import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../widgets/admin_drawer.dart';

class AdminReviewListScreen extends StatefulWidget {
  const AdminReviewListScreen({super.key});

  @override
  State<AdminReviewListScreen> createState() => _AdminReviewListScreenState();
}

class _AdminReviewListScreenState extends State<AdminReviewListScreen> {
  final Shop _shop = MockShops.shops[0]; // Surya Gemilang
  String _selectedFilter = 'Semua'; // 'Semua' | '5' | '4' | '3' | '2' | '1'

  // Controller untuk input balasan ulasan
  final Map<String, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<ReviewItem> _getFilteredReviews() {
    if (_selectedFilter == 'Semua') {
      return _shop.reviews;
    }
    final targetRating = double.parse(_selectedFilter);
    return _shop.reviews.where((r) => r.rating.toInt() == targetRating.toInt()).toList();
  }

  void _submitReply(int index, ReviewItem review, String replyText) {
    if (replyText.trim().isEmpty) return;

    final mainIndex = _shop.reviews.indexOf(review);
    if (mainIndex != -1) {
      setState(() {
        _shop.reviews[mainIndex] = review.copyWith(adminReply: replyText.trim());
      });

      // Hapus controller dari map
      _replyControllers[review.name]?.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balasan ulasan berhasil dikirim!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredReviews = _getFilteredReviews();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: const AdminDrawer(currentRoute: '/admin/reviews'),
      appBar: CustomAppBar(
        title: 'Ulasan Pelanggan',
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('5', label: '⭐ 5'),
                      const SizedBox(width: 8),
                      _buildFilterChip('4', label: '⭐ 4'),
                      const SizedBox(width: 8),
                      _buildFilterChip('3', label: '⭐ 3'),
                      const SizedBox(width: 8),
                      _buildFilterChip('2', label: '⭐ 2'),
                      const SizedBox(width: 8),
                      _buildFilterChip('1', label: '⭐ 1'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menampilkan ${filteredReviews.length} Ulasan',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: filteredReviews.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 72,
                            color: isDark ? AppColors.darkMutedText : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Ulasan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFilter != 'Semua'
                                ? 'Tidak ada ulasan dengan rating bintang $_selectedFilter.'
                                : 'Toko Anda belum memiliki ulasan dari pelanggan.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: filteredReviews.length,
                    itemBuilder: (context, index) {
                      final review = filteredReviews[index];
                      if (!_replyControllers.containsKey(review.name)) {
                        _replyControllers[review.name] = TextEditingController();
                      }
                      return _buildReviewCard(review, isDark, theme, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, {String? label}) {
    final isSelected = _selectedFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label ?? filter,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
          color: isSelected
              ? (isDark ? AppColors.teal900 : Colors.white)
              : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
        ),
      ),
      selected: isSelected,
      selectedColor: isDark ? AppColors.teal300 : AppColors.teal700,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? Colors.transparent 
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
    );
  }

  Widget _buildReviewCard(ReviewItem review, bool isDark, ThemeData theme, int index) {
    final hasPhotos = review.reviewPhotos.isNotEmpty;
    final controller = _replyControllers[review.name]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Stars & Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.avatarUrl.isNotEmpty && review.avatarUrl.startsWith('http')
                    ? NetworkImage(review.avatarUrl)
                    : null,
                backgroundColor: isDark 
                    ? AppColors.teal800.withValues(alpha: 0.25)
                    : AppColors.teal700.withValues(alpha: 0.08),
                child: review.avatarUrl.isEmpty || !review.avatarUrl.startsWith('http')
                    ? Icon(
                        Icons.person_rounded,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (starIdx) {
                        return Icon(
                          starIdx < review.rating.toInt()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment content
          Text(
            review.comment,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),

          // Photos (if any)
          if (hasPhotos) ...[
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.reviewPhotos.length,
                itemBuilder: (context, photoIdx) {
                  final imgUrl = review.reviewPhotos[photoIdx];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: imgUrl.startsWith('http')
                          ? Image.network(imgUrl, fit: BoxFit.cover)
                          : Image.asset(imgUrl, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reply Section (Nested Card)
          if (review.adminReply != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.teal900.withValues(alpha: 0.15)
                    : AppColors.teal700.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Balasan Surya Gemilang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.adminReply!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Add reply input form
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tulis balasan untuk ulasan ini...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkElevated : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _submitReply(index, review, controller.text),
                  icon: const Icon(Icons.send_rounded, size: 12),
                  label: const Text('Kirim Balasan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
