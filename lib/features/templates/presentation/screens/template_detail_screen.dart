import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_templates.dart';

/// Halaman detail template dokumen — I6.
///
/// Menampilkan preview besar (thumbnail), deskripsi lengkap, rating, jumlah
/// download, dan tombol Download DOCX / PDF.
class TemplateDetailScreen extends StatefulWidget {
  const TemplateDetailScreen({super.key, required this.template});

  final TemplateItem template;

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  bool _isDownloadingDocx = false;
  bool _isDownloadingPdf = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _handleDownload(String format) async {
    if (format == 'DOCX') {
      setState(() => _isDownloadingDocx = true);
    } else {
      setState(() => _isDownloadingPdf = true);
    }

    try {
      // Dapatkan URL dari model (contoh simulasi)
      String urlString = widget.template.fileUrl;
      // Jika butuh format PDF, kita asumsikan mengubah ekstensinya
      if (format == 'PDF' && urlString.endsWith('.docx')) {
        urlString = urlString.replaceAll('.docx', '.pdf');
      }

      // Untuk memastikan kita mendownload "file real" sebagai contoh, 
      // kita ganti url dummy example.com dengan url file sungguhan
      if (urlString.contains('example.com')) {
        if (format == 'PDF') {
          urlString = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
        } else {
          urlString = 'https://filesamples.com/samples/document/docx/sample1.docx';
        }
      }

      final uri = Uri.parse(urlString);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template berhasil diunduh ($format)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'Tidak dapat membuka tautan.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh template: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingDocx = false;
          _isDownloadingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tpl = widget.template;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ─── Hero App Bar dengan Thumbnail ───────────────────────────
          _TemplateHeroAppBar(template: tpl, isDark: isDark),

          // ─── Konten ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori badge
                  _CategoryBadge(category: tpl.category, isDark: isDark),
                  const SizedBox(height: 10),

                  // Nama template
                  Text(
                    tpl.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats row (download & rating)
                  _StatsRow(template: tpl, isDark: isDark),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    height: 1,
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi
                  Text(
                    'Tentang Template',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tpl.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.darkMutedText
                          : AppColors.lightSubtleText,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Format yang tersedia
                  Text(
                    'Format Tersedia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FormatChip(label: 'DOCX', icon: Icons.description_rounded, isDark: isDark),
                      const SizedBox(width: 10),
                      _FormatChip(label: 'PDF', icon: Icons.picture_as_pdf_rounded, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 100), // Ruang untuk tombol download di bawah
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom Bar Download ────────────────────────────────────────
      bottomNavigationBar: ScaleTransition(
        scale: _fabScale,
        child: _DownloadBottomBar(
          isDark: isDark,
          isDownloadingDocx: _isDownloadingDocx,
          isDownloadingPdf: _isDownloadingPdf,
          onDownloadDocx: () => _handleDownload('DOCX'),
          onDownloadPdf: () => _handleDownload('PDF'),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────

class _TemplateHeroAppBar extends StatelessWidget {
  const _TemplateHeroAppBar({required this.template, required this.isDark});

  final TemplateItem template;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.teal700,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroThumbnail(template: template, isDark: isDark),
        title: Text(
          template.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
      ),
    );
  }
}

class _HeroThumbnail extends StatelessWidget {
  const _HeroThumbnail({required this.template, required this.isDark});

  final TemplateItem template;
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // Thumbnail image dengan fallback gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.teal800, AppColors.darkBackground]
                  : [AppColors.teal600, AppColors.teal900],
            ),
          ),
          child: Image.network(
            template.thumbnailUrl,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.15),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (ctx, e, st) => Center(
              child: Icon(
                _iconForCategory(template.category),
                size: 80,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return Center(
                child: Icon(
                  _iconForCategory(template.category),
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ),
        // Gradient overlay bawah agar title terbaca
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.teal700.withValues(alpha: 0.3)
            : AppColors.teal200.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.teal700 : AppColors.teal300,
          width: 1,
        ),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.teal300 : AppColors.teal700,
          fontWeight: FontWeight.w700,
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
    return Row(
      children: [
        _StatItem(
          icon: Icons.download_rounded,
          value: MockTemplates.formatDownloadCount(template.downloadCount),
          label: 'Diunduh',
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        _StatItem(
          icon: Icons.star_rounded,
          value: template.rating.toStringAsFixed(1),
          label: 'Rating',
          isDark: isDark,
          iconColor: Colors.amber.shade600,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isDark;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.teal600,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.teal600),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadBottomBar extends StatelessWidget {
  const _DownloadBottomBar({
    required this.isDark,
    required this.isDownloadingDocx,
    required this.isDownloadingPdf,
    required this.onDownloadDocx,
    required this.onDownloadPdf,
  });

  final bool isDark;
  final bool isDownloadingDocx;
  final bool isDownloadingPdf;
  final VoidCallback onDownloadDocx;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Download DOCX
          Expanded(
            child: _DownloadButton(
              label: 'Download DOCX',
              icon: Icons.description_rounded,
              isLoading: isDownloadingDocx,
              onTap: onDownloadDocx,
              style: _ButtonStyle.outline,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Download PDF
          Expanded(
            child: _DownloadButton(
              label: 'Download PDF',
              icon: Icons.picture_as_pdf_rounded,
              isLoading: isDownloadingPdf,
              onTap: onDownloadPdf,
              style: _ButtonStyle.gradient,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ButtonStyle { gradient, outline }

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
    required this.style,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  final _ButtonStyle style;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isGradient = style == _ButtonStyle.gradient;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 50,
        decoration: BoxDecoration(
          gradient: isGradient && !isLoading ? AppColors.primaryButtonGradient : null,
          color: isGradient
              ? (isLoading ? AppColors.teal600.withValues(alpha: 0.5) : null)
              : (isDark ? AppColors.darkElevated : AppColors.lightCard),
          borderRadius: BorderRadius.circular(12),
          border: isGradient
              ? null
              : Border.all(
                  color: isLoading
                      ? AppColors.teal600.withValues(alpha: 0.3)
                      : AppColors.teal600,
                  width: 1.5,
                ),
          boxShadow: isGradient && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.teal700.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isGradient ? Colors.white : AppColors.teal600,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isGradient
                          ? Colors.white
                          : AppColors.teal600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isGradient ? Colors.white : AppColors.teal600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
