import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/mock_templates.dart';
import '../../data/template_store.dart';
import '../widgets/template_card.dart';
import '../widgets/template_category_chip.dart';

/// Halaman daftar template dokumen kampus — I6.
///
/// Menampilkan grid template dengan filter kategori dan pencarian.
/// Masing-masing kartu menampilkan thumbnail, nama, download count, dan rating.
class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    templateStore.addListener(_onStoreUpdate);
    _searchController.addListener(() {
      templateStore.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    templateStore.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templates = templateStore.filteredTemplates;
    final selectedCategory = templateStore.selectedCategory;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Template Dokumen', showBackButton: false),
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ─── Search Bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _SearchBar(
              controller: _searchController,
              isDark: isDark,
            ),
          ),

          // ─── Category Chips ─────────────────────────────────────────
          _CategoryChipRow(
            categories: MockTemplates.categories,
            selectedCategory: selectedCategory,
            isDark: isDark,
            onSelected: templateStore.selectCategory,
          ),

          // ─── Result count ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Text(
                  templates.isEmpty
                      ? 'Template tidak ditemukan'
                      : '${templates.length} template',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkMutedText
                        : AppColors.lightSubtleText,
                  ),
                ),
              ],
            ),
          ),

          // ─── Grid / Empty State ──────────────────────────────────────
          Expanded(
            child: templates.isEmpty
                ? _EmptyState(isDark: isDark)
                : _TemplateGrid(
                    templates: templates,
                    isDark: isDark,
                    onTap: (tpl) => context.push('/templates/${tpl.id}',
                        extra: tpl),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.isDark});

  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
        ),
        decoration: InputDecoration(
          hintText: 'Cari template...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.teal600,
            size: 22,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (ctx, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkMutedText
                      : AppColors.lightSubtleText,
                ),
                onPressed: () => controller.clear(),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow({
    required this.categories,
    required this.selectedCategory,
    required this.isDark,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final bool isDark;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return TemplateCategoryChip(
            label: cat,
            isSelected: cat == selectedCategory,
            onTap: () => onSelected(cat),
          );
        },
      ),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({
    required this.templates,
    required this.isDark,
    required this.onTap,
  });

  final List<TemplateItem> templates;
  final bool isDark;
  final void Function(TemplateItem) onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final tpl = templates[index];
        return TemplateCard(
          key: ValueKey(tpl.id),
          template: tpl,
          onTap: () => onTap(tpl),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustrasi
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkElevated
                    : AppColors.lightSurface,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 56,
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Template tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain atau pilih kategori yang berbeda.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
