import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';
import '../widgets/super_admin_drawer.dart';

class SuperAdminUserListScreen extends StatefulWidget {
  const SuperAdminUserListScreen({super.key});

  @override
  State<SuperAdminUserListScreen> createState() => _SuperAdminUserListScreenState();
}

class _SuperAdminUserListScreenState extends State<SuperAdminUserListScreen> with SingleTickerProviderStateMixin {
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
        final allUsers = saManager.users;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          drawer: const SuperAdminDrawer(currentRoute: '/superadmin/users'),
          appBar: CustomAppBar(
            title: 'Manajemen User',
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
                    hintText: 'Cari nama atau email pengguna...',
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
                  Tab(text: 'Customer'),
                  Tab(text: 'Admin Toko'),
                  Tab(text: 'Super Admin'),
                ],
              ),

              // Tab View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(allUsers, 'All', isDark),
                    _buildUserList(allUsers, 'Customer', isDark),
                    _buildUserList(allUsers, 'Admin Toko', isDark),
                    _buildUserList(allUsers, 'Super Admin', isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(List<SuperAdminUser> users, String filterRole, bool isDark) {
    // 1. Filter role
    List<SuperAdminUser> filtered = users;
    if (filterRole != 'All') {
      filtered = users.where((u) => u.role == filterRole).toList();
    }

    // 2. Filter search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((u) =>
              u.name.toLowerCase().contains(_searchQuery) ||
              u.email.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 12),
            Text(
              'Tidak ada pengguna ditemukan.',
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
        final user = filtered[index];
        return _buildUserCard(user, isDark);
      },
    );
  }

  Widget _buildUserCard(SuperAdminUser user, bool isDark) {
    final isBanned = user.status == 'Banned';
    final roleColor = user.role == 'Super Admin'
        ? Colors.purple.shade600
        : (user.role == 'Admin Toko' ? Colors.teal.shade600 : Colors.blue.shade600);

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => context.go('/superadmin/users/${user.id}'),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.1),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isBanned)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  'Banned',
                  style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w800, fontSize: 9),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                user.role,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 9),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
