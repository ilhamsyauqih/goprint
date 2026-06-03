import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import '../../../core/theme/app_theme.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _allOrders = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _allOrders = getMockOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter orders based on status for each tab
  List<Order> get _activeOrders {
    final activeStatuses = ['pending', 'confirmed', 'processing', 'ready'];
    return _allOrders
        .where((order) => activeStatuses.contains(order.status.toLowerCase()))
        .where((order) => _matchesSearch(order))
        .toList();
  }

  List<Order> get _completedOrders {
    return _allOrders
        .where((order) => order.status.toLowerCase() == 'completed')
        .where((order) => _matchesSearch(order))
        .toList();
  }

  List<Order> get _cancelledOrders {
    return _allOrders
        .where((order) => order.status.toLowerCase() == 'cancelled')
        .where((order) => _matchesSearch(order))
        .toList();
  }

  bool _matchesSearch(Order order) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return order.orderNumber.toLowerCase().contains(query) ||
        order.shopName.toLowerCase().contains(query) ||
        order.items.any((item) => item.fileName.toLowerCase().contains(query));
  }

  // Function to refresh/reset mock data
  void _resetMockData() {
    setState(() {
      _allOrders = getMockOrders();
      _searchController.clear();
      _searchQuery = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data pesanan telah di-reset ke default.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pesanan Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Reset Mock Data',
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        onPressed: _resetMockData,
                      )
                    ],
                  ),
                ),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari nomor pesanan, toko, dokumen...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.white70, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                ),
                
                // Custom Modern Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.7),
                  tabs: const [
                    Tab(text: 'Aktif'),
                    Tab(text: 'Selesai'),
                    Tab(text: 'Dibatalkan'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(_activeOrders, 'aktif'),
          _buildTabContent(_completedOrders, 'selesai'),
          _buildTabContent(_cancelledOrders, 'dibatalkan'),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<Order> orders, String tabType) {
    if (orders.isEmpty) {
      return _buildEmptyState(tabType);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () async {
            // Navigate to OrderDetailScreen
            final updatedOrder = await Navigator.push<Order>(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );

            // Update local state if changes were made
            if (updatedOrder != null) {
              setState(() {
                final idx = _allOrders.indexWhere((o) => o.id == updatedOrder.id);
                if (idx != -1) {
                  _allOrders[idx] = updatedOrder;
                }
              });
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String tabType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    IconData icon;
    String title;
    String subtitle;

    switch (tabType) {
      case 'aktif':
        icon = Icons.print_disabled_rounded;
        title = 'Belum ada pesanan aktif';
        subtitle = 'Cari toko terdekat dan cetak dokumenmu sekarang juga!';
        break;
      case 'selesai':
        icon = Icons.history_rounded;
        title = 'Belum ada riwayat transaksi';
        subtitle = 'Selesaikan cetakan pertamamu untuk melihat riwayat di sini.';
        break;
      case 'dibatalkan':
        icon = Icons.cancel_presentation_rounded;
        title = 'Tidak ada pesanan dibatalkan';
        subtitle = 'Bagus! Semua transaksi berjalan dengan lancar.';
        break;
      default:
        icon = Icons.hourglass_empty_rounded;
        title = 'Data kosong';
        subtitle = 'Tidak ada pesanan untuk ditampilkan.';
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled Graphic/Icon Container with gradient shadow/background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.surfaceDark 
                    : AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark 
                      ? AppColors.borderDark 
                      : AppColors.primary.withOpacity(0.12),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            
            // Text Details
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            
            // Interactive Helper Button
            if (tabType == 'aktif')
              ElevatedButton.icon(
                onPressed: _resetMockData,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text('Simulasikan Pesanan Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
