import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';
import '../widgets/super_admin_drawer.dart';

class SuperAdminPayoutListScreen extends StatefulWidget {
  const SuperAdminPayoutListScreen({super.key});

  @override
  State<SuperAdminPayoutListScreen> createState() => _SuperAdminPayoutListScreenState();
}

class _SuperAdminPayoutListScreenState extends State<SuperAdminPayoutListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final saManager = SuperAdminManager.instance;

    return ListenableBuilder(
      listenable: saManager,
      builder: (context, _) {
        final allPayouts = saManager.payouts;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          drawer: const SuperAdminDrawer(currentRoute: '/superadmin/payouts'),
          appBar: CustomAppBar(
            title: 'Penarikan Dana (Payout)',
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
              // Search Input
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

              // Filter Tabs
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
                  Tab(text: 'Menunggu (Pending)'),
                  Tab(text: 'Diproses'),
                  Tab(text: 'Sukses'),
                  Tab(text: 'Ditolak'),
                ],
              ),

              // Tab View List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPayoutList(allPayouts, 'all', isDark),
                    _buildPayoutList(allPayouts, 'pending', isDark),
                    _buildPayoutList(allPayouts, 'processing', isDark),
                    _buildPayoutList(allPayouts, 'success', isDark),
                    _buildPayoutList(allPayouts, 'rejected', isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayoutList(List<PayoutRequest> payouts, String filterStatus, bool isDark) {
    // 1. Filter status
    List<PayoutRequest> filtered = payouts;
    if (filterStatus != 'all') {
      filtered = payouts.where((p) => p.status == filterStatus).toList();
    }

    // 2. Filter search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.shopName.toLowerCase().contains(_searchQuery)).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 12),
            Text(
              'Tidak ada pengajuan penarikan dana.',
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
        final payout = filtered[index];
        return _buildPayoutCard(payout, isDark);
      },
    );
  }

  Widget _buildPayoutCard(PayoutRequest payout, bool isDark) {
    Color statusColor = Colors.grey;
    String statusText = payout.status.toUpperCase();

    if (payout.status == 'pending') {
      statusColor = Colors.orange.shade700;
      statusText = 'MENUNGGU';
    } else if (payout.status == 'processing') {
      statusColor = Colors.blue.shade600;
      statusText = 'DIPROSES';
    } else if (payout.status == 'success') {
      statusColor = Colors.green.shade600;
      statusText = 'SUKSES';
    } else if (payout.status == 'rejected') {
      statusColor = Colors.red.shade600;
      statusText = 'DITOLAK';
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
        onTap: () => context.go('/superadmin/payouts/${payout.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payout.id,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                payout.shopName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payout.bankName} - ${payout.accountNumber}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Diajukan: ${payout.requestDate}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(payout.amount),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
