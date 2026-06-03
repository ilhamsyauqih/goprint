import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Grid 2x3 untuk ikon layanan (Print, Jilid, dll).
class ServiceCategoryGrid extends StatelessWidget {
  const ServiceCategoryGrid({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Print', 'icon': Icons.print_rounded},
    {'name': 'Jilid', 'icon': Icons.menu_book_rounded},
    {'name': 'Laminating', 'icon': Icons.layers_rounded},
    {'name': 'Scan', 'icon': Icons.document_scanner_rounded},
    {'name': 'Fotokopi', 'icon': Icons.file_copy_rounded},
    {'name': 'Template', 'icon': Icons.description_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return _ServiceCategoryItem(
            name: cat['name'],
            icon: cat['icon'],
            onTap: () {
              // TODO: Navigate to shop list filtered by service
            },
          );
        },
      ),
    );
  }
}

class _ServiceCategoryItem extends StatelessWidget {
  const _ServiceCategoryItem({
    required this.name,
    required this.icon,
    this.onTap,
  });

  final String name;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkElevated : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isDark ? AppColors.teal300 : AppColors.teal700,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
