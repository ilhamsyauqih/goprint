import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../../data/super_admin_manager.dart';
import '../widgets/super_admin_drawer.dart';

class SuperAdminShopListScreen extends StatefulWidget {
  const SuperAdminShopListScreen({super.key});

  @override
  State<SuperAdminShopListScreen> createState() => _SuperAdminShopListScreenState();
}

class _SuperAdminShopListScreenState extends State<SuperAdminShopListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saManager = SuperAdminManager.instance;

    return ListenableBuilder(
      listenable: saManager,
      builder: (context, _) {
        final allShops = MockShops.shops;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          drawer: const SuperAdminDrawer(currentRoute: '/superadmin/shops'),
          appBar: CustomAppBar(
            title: 'Mitra Toko',
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
              // Search Area
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama toko mitra...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
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
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
              ),

              // Custom tab bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                unselectedLabelColor: Colors.grey,
                indicatorColor: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Persetujuan (Pending)'),
                  Tab(text: 'Mitra Aktif'),
                  Tab(text: 'Ditangguhkan'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildShopList(allShops, 'all', isDark),
                    _buildShopList(allShops, 'pending', isDark),
                    _buildShopList(allShops, 'approved', isDark),
                    _buildShopList(allShops, 'suspended', isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopList(List<Shop> shops, String filterStatus, bool isDark) {
    // 1. Filter status
    List<Shop> filtered = shops;
    if (filterStatus != 'all') {
      filtered = shops.where((s) => s.verificationStatus == filterStatus).toList();
    }

    // 2. Filter query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((s) => s.name.toLowerCase().contains(_searchQuery)).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 12),
            Text(
              'Tidak ada toko mitra yang cocok.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final shop = filtered[index];
        return _buildShopCard(shop, isDark);
      },
    );
  }

  Widget _buildShopCard(Shop shop, bool isDark) {
    Color badgeColor = Colors.green.shade600;
    String statusText = 'Aktif';

    if (shop.verificationStatus == 'pending') {
      badgeColor = Colors.orange.shade700;
      statusText = 'Pending';
    } else if (shop.verificationStatus == 'suspended') {
      badgeColor = Colors.red.shade600;
      statusText = 'Ditangguhkan';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      elevation: 0,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: InkWell(
        onTap: () => context.go('/superadmin/shops/${shop.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(shop.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Text Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  ${shop.distance}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shop.address,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
