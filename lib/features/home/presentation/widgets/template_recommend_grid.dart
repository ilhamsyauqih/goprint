import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../templates/data/mock_templates.dart';

/// Grid rekomendasi template dokumen di Home Screen.
///
/// Menampilkan 4 template terpopuler (sorted by download count).
/// Tap kartu → navigasi ke TemplateDetailScreen.
class TemplateRecommendGrid extends StatelessWidget {
  const TemplateRecommendGrid({super.key});

  /// Ambil 4 template dengan jumlah download tertinggi.
  static List<TemplateItem> get _popularTemplates {
    final sorted = [...MockTemplates.templates]
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return sorted.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templates = _popularTemplates;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final tpl = templates[index];
          return _RecommendCard(
            key: ValueKey(tpl.id),
            template: tpl,
            isDark: isDark,
            onTap: () => context.push('/templates/${tpl.id}', extra: tpl),
          );
        },
      ),
    );
  }
}

// ─── Private card widget ──────────────────────────────────────────────────

class _RecommendCard extends StatelessWidget {
  const _RecommendCard({
    super.key,
    required this.template,
    required this.isDark,
    required this.onTap,
  });

  final TemplateItem template;
  final bool isDark;
  final VoidCallback onTap;

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Surat Izin':
        return Icons.mail_outline_rounded;
      case 'Cover':
        return Icons.menu_book_rounded;
      case 'Daftar Pustaka':
        return Icons.library_books_rounded;
      case 'Proposal':
        return Icons.assignment_rounded;
      case 'Abstrak':
        return Icons.article_rounded;
      case 'Berita Acara':
        return Icons.fact_check_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.teal800, AppColors.darkElevated]
                          : [AppColors.teal200, AppColors.teal400],
                    ),
                  ),
                  child: Icon(
                    _iconForCategory(template.category),
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.category,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: isDark
                                  ? AppColors.teal300
                                  : AppColors.teal700,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: isDark
                                  ? AppColors.darkPrimaryText
                                  : AppColors.lightPrimaryText,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.download_rounded,
                            size: 11,
                            color: isDark
                                ? AppColors.darkMutedText
                                : AppColors.lightSubtleText,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            MockTemplates.formatDownloadCount(
                              template.downloadCount,
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkMutedText
                                      : AppColors.lightSubtleText,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
