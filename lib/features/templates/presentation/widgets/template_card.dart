import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_templates.dart';

/// Kartu template dokumen untuk grid view.
///
/// Menampilkan thumbnail, nama template, kategori, jumlah download, dan rating.
class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  final TemplateItem template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Thumbnail ──────────────────────────────────────
              Expanded(
                flex: 5,
                child: _TemplateThumbnail(
                  thumbnailUrl: template.thumbnailUrl,
                  category: template.category,
                  isDark: isDark,
                ),
              ),

              // ─── Info ───────────────────────────────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori badge
                      _CategoryBadge(
                        category: template.category,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      // Nama template
                      Expanded(
                        child: Text(
                          template.name,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                color: isDark
                                    ? AppColors.darkPrimaryText
                                    : AppColors.lightPrimaryText,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Download & Rating row
                      _StatsRow(template: template, isDark: isDark),
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

// ─── Sub-widgets (private) ─────────────────────────────────────────────────

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({
    required this.thumbnailUrl,
    required this.category,
    required this.isDark,
  });

  final String thumbnailUrl;
  final String category;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background teal gradient sebagai fallback
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.teal800, AppColors.darkElevated]
                  : [AppColors.teal200, AppColors.teal400],
            ),
          ),
          child: Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, e, st) => _FallbackThumbnail(
              category: category,
              isDark: isDark,
            ),
            loadingBuilder: (ctx, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _FallbackThumbnail(
                category: category,
                isDark: isDark,
              );
            },
          ),
        ),
        // Gradient overlay bawah
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackThumbnail extends StatelessWidget {
  const _FallbackThumbnail({
    required this.category,
    required this.isDark,
  });

  final String category;
  final bool isDark;

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.teal800, AppColors.darkElevated]
              : [AppColors.teal200, AppColors.teal400],
        ),
      ),
      child: Center(
        child: Icon(
          _iconForCategory(category),
          size: 40,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category, required this.isDark});

  final String category;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.teal700.withValues(alpha: 0.3)
            : AppColors.teal200.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDark ? AppColors.teal300 : AppColors.teal700,
          fontWeight: FontWeight.w700,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.template, required this.isDark});

  final TemplateItem template;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final subtleColor = isDark ? AppColors.darkMutedText : AppColors.lightSubtleText;
    return Row(
      children: [
        // Download count
        Icon(Icons.download_rounded, size: 11, color: subtleColor),
        const SizedBox(width: 2),
        Text(
          MockTemplates.formatDownloadCount(template.downloadCount),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: subtleColor,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 8),
        // Rating
        Icon(Icons.star_rounded, size: 11, color: Colors.amber.shade600),
        const SizedBox(width: 2),
        Text(
          template.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: subtleColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
