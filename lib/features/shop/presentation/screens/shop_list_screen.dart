import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/mock_shops.dart';

/// Layar untuk menampilkan daftar toko mitra beserta pencarian & filter.
class ShopListScreen extends StatefulWidget {
  const ShopListScreen({
    this.preselectedCategory,
    super.key,
  });

  final String? preselectedCategory;

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  String? _selectedCategory;
  double? _selectedRating;
  double? _selectedDistance;

  @override
  void initState() {
    super.initState();
    // Inisialisasi kategori awal dari query parameter/home screen click
    if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Melakukan filter list toko berdasarkan kriteria pencarian & filter
  List<Shop> get _filteredShops {
    return MockShops.shops.where((shop) {
      // 1. Filter Pencarian Nama Toko
      if (_searchQuery.isNotEmpty &&
          !shop.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 2. Filter Kategori Layanan
      if (_selectedCategory != null) {
        final hasCategory = shop.services.any(
          (s) => s.category.toLowerCase() == _selectedCategory!.toLowerCase(),
        );
        if (!hasCategory) return false;
      }

      // 3. Filter Rating
      if (_selectedRating != null && shop.rating < _selectedRating!) {
        return false;
      }

      // 4. Filter Jarak
      if (_selectedDistance != null) {
        final cleanDistStr = shop.distance.replaceAll(RegExp(r'[^0-9.]'), '');
        final distVal = double.tryParse(cleanDistStr) ?? 0.0;
        if (distVal > _selectedDistance!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _selectedRating = null;
      _selectedDistance = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shops = _filteredShops;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pilih Toko',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Pencarian (Search Input) ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama toko...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ─── Filter Bar (Horizontal Scroll) ──────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Reset Filters Button (tampil jika ada filter aktif)
                if (_selectedCategory != null ||
                    _selectedRating != null ||
                    _selectedDistance != null ||
                    _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      onPressed: _clearFilters,
                      backgroundColor: isDark
                          ? AppColors.errorDark.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: isDark ? AppColors.errorDark : AppColors.error,
                        width: 1,
                      ),
                      label: Row(
                        children: [
                          Icon(
                            Icons.tune_outlined,
                            size: 14,
                            color: isDark ? AppColors.errorDark : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Bersihkan',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? AppColors.errorDark : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 1. Filter Kategori/Layanan
                _buildFilterDropdown<String>(
                  value: _selectedCategory,
                  hint: 'Layanan',
                  items: const ['Print', 'Jilid', 'Laminating', 'Scan', 'Fotokopi'],
                  onSelected: (val) => setState(() => _selectedCategory = val),
                  isSelected: _selectedCategory != null,
                ),
                const SizedBox(width: 8),

                // 2. Filter Rating
                _buildFilterDropdown<double>(
                  value: _selectedRating,
                  hint: 'Rating',
                  items: const [4.0, 4.5],
                  itemLabels: {4.0: '⭐ 4.0+', 4.5: '⭐ 4.5+'},
                  onSelected: (val) => setState(() => _selectedRating = val),
                  isSelected: _selectedRating != null,
                ),
                const SizedBox(width: 8),

                // 3. Filter Jarak
                _buildFilterDropdown<double>(
                  value: _selectedDistance,
                  hint: 'Jarak',
                  items: const [1.0, 2.0, 5.0],
                  itemLabels: {1.0: '< 1 km', 2.0: '< 2 km', 5.0: '< 5 km'},
                  onSelected: (val) => setState(() => _selectedDistance = val),
                  isSelected: _selectedDistance != null,
                ),
              ],
            ),
          ),

          // ─── Daftar Toko / Hasil Filter ─────────────────────────────
          Expanded(
            child: shops.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return _ShopListCard(
                        shop: shop,
                        onTap: () => context.push('/shop/${shop.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Dropdown Filter Kustom berbentuk Chip
  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onSelected,
    required bool isSelected,
    Map<T, String>? itemLabels,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: (val) {
        if (value == val) {
          onSelected(null); // Deselect jika diklik nilai yang sama
        } else {
          onSelected(val);
        }
      },
      itemBuilder: (context) {
        return items.map((item) {
          final label = itemLabels != null ? itemLabels[item]! : item.toString();
          final isCurrent = item == value;
          return PopupMenuItem<T>(
            value: item,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (isCurrent)
                  Icon(
                    Icons.check_rounded,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.teal800.withValues(alpha: 0.3)
                  : const Color(0xFFE0F2F1))
              : (isDark ? AppColors.darkSurface : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.teal300 : AppColors.teal700)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value != null
                  ? (itemLabels != null ? itemLabels[value]! : value.toString())
                  : hint,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.teal300 : AppColors.teal700)
                    : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isSelected
                  ? (isDark ? AppColors.teal300 : AppColors.teal700)
                  : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan halaman kosong (Empty State)
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 64,
                color: isDark
                    ? AppColors.darkMutedText.withValues(alpha: 0.4)
                    : AppColors.lightSubtleText.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Toko Tidak Ditemukan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba sesuaikan pencarian atau bersihkan filter untuk melihat semua toko mitra kami.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
              child: const Text('Reset Semua Filter'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private Component: [_ShopListCard] — Kartu toko format vertikal untuk halaman list
class _ShopListCard extends StatelessWidget {
  const _ShopListCard({
    required this.shop,
    required this.onTap,
  });

  final Shop shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Kumpulkan kategori layanan unik untuk ditampilkan sebagai chip kecil
    final categories = shop.services.map((s) => s.category).toSet().toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar Toko
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: AppColors.teal900,
                    child: Image.network(
                      shop.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.storefront_rounded,
                            color: Colors.white60,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Info Detail Toko
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + Jarak + Rating
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: shop.isOpen
                                  ? (isDark ? AppColors.successDark.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.1))
                                  : (isDark ? AppColors.errorDark.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              shop.isOpen ? 'Buka' : 'Tutup',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: shop.isOpen
                                    ? (isDark ? AppColors.successDark : AppColors.success)
                                    : (isDark ? AppColors.errorDark : AppColors.error),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningDark,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            shop.rating.toString(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            shop.distance,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Nama Toko
                      Text(
                        shop.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Alamat Ringkas
                      Text(
                        shop.address,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Kategori Layanan Tags
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: categories.take(3).map((cat) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.teal800.withValues(alpha: 0.2)
                                  : const Color(0xFFE0F2F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cat,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark ? AppColors.teal300 : AppColors.teal700,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
