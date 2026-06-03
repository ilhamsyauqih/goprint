import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Grid rekomendasi template dokumen.
class TemplateRecommendGrid extends StatelessWidget {
  const TemplateRecommendGrid({super.key});

  // Dummy template data
  static const List<Map<String, dynamic>> _dummyTemplates = [
    {
      'title': 'Surat Izin Tidak Masuk',
      'category': 'Surat Izin',
      'downloads': '1.2k',
    },
    {
      'title': 'Cover Laporan Praktikum',
      'category': 'Cover',
      'downloads': '3.4k',
    },
    {
      'title': 'Format Daftar Pustaka APA',
      'category': 'Referensi',
      'downloads': '850',
    },
    {
      'title': 'Proposal Kegiatan Mahasiswa',
      'category': 'Proposal',
      'downloads': '2.1k',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        itemCount: _dummyTemplates.length,
        itemBuilder: (context, index) {
          final tpl = _dummyTemplates[index];
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
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkElevated
                              : AppColors.lightSurface,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          size: 40,
                          color: isDark
                              ? AppColors.darkMutedText
                              : AppColors.lightSubtleText,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tpl['category'],
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.teal700,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tpl['title'],
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}
