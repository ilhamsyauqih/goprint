import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../orders/data/order_model.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/admin_order_card.dart';
import '../../../orders/presentation/providers/order_provider.dart';

class AdminOrderListScreen extends ConsumerStatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  ConsumerState<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends ConsumerState<AdminOrderListScreen> {
  String _searchQuery = '';
  String _sortBy = 'Terbaru'; // 'Terbaru' | 'Terlama' | 'Terbesar' | 'Terkecil'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterAndSortOrders(List<OrderModel> sourceOrders, String tab) {
    // 1. Filter based on Tab
    List<OrderModel> filtered = [];
    if (tab == 'Semua') {
      filtered = List.from(sourceOrders);
    } else if (tab == 'Baru') {
      filtered = sourceOrders.where((o) =>
          o.status == OrderStatus.pending || o.status == OrderStatus.confirmed).toList();
    } else if (tab == 'Diproses') {
      filtered = sourceOrders.where((o) =>
          o.status == OrderStatus.processing || o.status == OrderStatus.ready).toList();
    } else if (tab == 'Selesai/Batal') {
      filtered = sourceOrders.where((o) =>
          o.status == OrderStatus.completed || o.status == OrderStatus.cancelled).toList();
    }

    // 2. Filter based on Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        final orderNoMatch = o.orderNumber.toLowerCase().contains(query);
        final customerMatch = o.customerName.toLowerCase().contains(query);
        final fileNamesMatch = o.uploadedFiles.any(
          (f) => f.name.toLowerCase().contains(query),
        );
        return orderNoMatch || customerMatch || fileNamesMatch;
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'Terbaru') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'Terlama') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortBy == 'Terbesar') {
      filtered.sort((a, b) => b.totalFee.compareTo(a.totalFee));
    } else if (_sortBy == 'Terkecil') {
      filtered.sort((a, b) => a.totalFee.compareTo(b.totalFee));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final adminOrdersAsync = ref.watch(adminOrdersProvider);

    return adminOrdersAsync.when(
      data: (allOrders) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            drawer: const AdminDrawer(currentRoute: '/admin/orders'),
            appBar: CustomAppBar(
              title: 'Pesanan Masuk',
              showBackButton: false,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              bottom: TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
                indicatorColor: isDark ? AppColors.teal300 : AppColors.teal200,
                indicatorWeight: 3.0,
                tabAlignment: TabAlignment.start,
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Baru'),
                  Tab(text: 'Diproses/Ready'),
                  Tab(text: 'Selesai/Batal'),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => ref.refresh(adminOrdersProvider.future),
              child: Column(
                children: [
                  // Search & Sort bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.trim();
                              });
                            },
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Cari nomor, pemesan, dokumen...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: isDark ? AppColors.darkSurface : Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Sort Button
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              _sortBy = value;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Icon(
                              Icons.filter_list_rounded,
                              color: isDark ? AppColors.teal300 : AppColors.teal700,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Urutkan Pesanan',
                          itemBuilder: (context) => [
                            _buildSortMenuItem('Terbaru', 'Tanggal: Terbaru'),
                            _buildSortMenuItem('Terlama', 'Tanggal: Terlama'),
                            _buildSortMenuItem('Terbesar', 'Total: Terbesar'),
                            _buildSortMenuItem('Terkecil', 'Total: Terkecil'),
                          ],
                        ),
                      ],
                    ),
                  ),
      
                  // Tabs Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildTabList(allOrders, 'Semua', theme, isDark),
                        _buildTabList(allOrders, 'Baru', theme, isDark),
                        _buildTabList(allOrders, 'Diproses', theme, isDark),
                        _buildTabList(allOrders, 'Selesai/Batal', theme, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        drawer: const AdminDrawer(currentRoute: '/admin/orders'),
        appBar: const CustomAppBar(title: 'Pesanan Masuk', showBackButton: false),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        drawer: const AdminDrawer(currentRoute: '/admin/orders'),
        appBar: const CustomAppBar(title: 'Pesanan Masuk', showBackButton: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Gagal memuat pesanan: $e', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(adminOrdersProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    final isSelected = _sortBy == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? (isDark ? AppColors.teal300 : AppColors.teal700)
                  : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              color: isDark ? AppColors.teal300 : AppColors.teal700,
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildTabList(List<OrderModel> sourceOrders, String tab, ThemeData theme, bool isDark) {
    final filteredOrders = _filterAndSortOrders(sourceOrders, tab);

    if (filteredOrders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal800.withValues(alpha: 0.15)
                      : AppColors.teal700.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 38,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tidak Ada Pesanan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada pesanan cocok dengan kata pencarian "$_searchQuery".'
                    : 'Belum ada data pesanan masuk untuk kategori ini.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return AdminOrderCard(order: filteredOrders[index]);
      },
    );
  }
}
