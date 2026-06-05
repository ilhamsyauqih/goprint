import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../widgets/admin_drawer.dart';

class AdminServiceListScreen extends StatefulWidget {
  const AdminServiceListScreen({super.key});

  @override
  State<AdminServiceListScreen> createState() => _AdminServiceListScreenState();
}

class _AdminServiceListScreenState extends State<AdminServiceListScreen> {
  final Shop _shop = MockShops.shops[0]; // Surya Gemilang
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    return 'Rp ${value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  List<ServiceItem> _getFilteredServices() {
    if (_searchQuery.isEmpty) {
      return _shop.services;
    }
    return _shop.services
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _toggleServiceStatus(int index, bool value) {
    final filtered = _getFilteredServices();
    final service = filtered[index];
    final mainIndex = _shop.services.indexOf(service);

    if (mainIndex != -1) {
      setState(() {
        _shop.services[mainIndex] = service.copyWith(isActive: value);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Layanan "${service.name}" diaktifkan'
                : 'Layanan "${service.name}" dinonaktifkan',
          ),
          backgroundColor: value ? AppColors.success : Colors.grey.shade800,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _deleteService(ServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text('Apakah Anda yakin ingin menghapus layanan "${service.name}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _shop.services.removeWhere((s) => s.name == service.name);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Layanan "${service.name}" telah dihapus'),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filteredServices = _getFilteredServices();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: const AdminDrawer(currentRoute: '/admin/services'),
      appBar: CustomAppBar(
        title: 'Kelola Layanan',
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/services/manage').then((_) => setState(() {}));
        },
        backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
        foregroundColor: isDark ? AppColors.teal900 : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Layanan',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
      body: Column(
        children: [
          // Search & Info Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari layanan...',
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
                const SizedBox(height: 8),
                Text(
                  'Total Layanan: ${_shop.services.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.print_disabled_rounded,
                            size: 72,
                            color: isDark ? AppColors.darkMutedText : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Layanan Tidak Ditemukan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Tidak ada layanan cetak yang cocok dengan kata kunci "$_searchQuery".'
                                : 'Belum ada layanan cetak terdaftar.',
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
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Opacity(
                            opacity: service.isActive ? 1.0 : 0.65,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Category Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isDark ? AppColors.teal300 : AppColors.teal700)
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          service.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                                          ),
                                        ),
                                      ),
                                      // Switch Active Status
                                      Row(
                                        children: [
                                          Text(
                                            service.isActive ? 'Aktif' : 'Nonaktif',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: service.isActive
                                                  ? (isDark ? AppColors.successDark : AppColors.success)
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Switch(
                                            value: service.isActive,
                                            onChanged: (val) => _toggleServiceStatus(index, val),
                                            activeThumbColor: isDark ? AppColors.teal300 : AppColors.teal700,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    service.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: isDark ? AppColors.darkMutedText : Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        service.estimateTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.darkMutedText : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, thickness: 1),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mulai Dari',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatCurrency(service.priceStartingFrom),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? AppColors.teal300 : AppColors.teal700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded, size: 20),
                                            color: Colors.blue.shade600,
                                            onPressed: () {
                                              context.push('/admin/services/manage', extra: service).then((_) => setState(() {}));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                            color: AppColors.error,
                                            onPressed: () => _deleteService(service),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
