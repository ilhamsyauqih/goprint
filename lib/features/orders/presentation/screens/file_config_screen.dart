import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/config_option.dart';
import '../widgets/pdf_preview_widget.dart';

/// Halaman Langkah 3: Konfigurasi Cetak per Berkas.
class FileConfigScreen extends StatefulWidget {
  const FileConfigScreen({super.key});

  @override
  State<FileConfigScreen> createState() => _FileConfigScreenState();
}

class _FileConfigScreenState extends State<FileConfigScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  int _activeFileIndex = 0; // Berkas mana yang sedang dikonfigurasi

  // Dropdown options
  final List<String> _colorOptions = ['Hitam Putih', 'Warna'];
  final List<String> _paperSizeOptions = ['A4', 'F4', 'A3'];
  final List<String> _paperTypeOptions = ['HVS 70g', 'HVS 80g', 'Art Paper'];
  final List<String> _finishingOptions = ['Tanpa Jilid', 'Jilid Lakban', 'Jilid Spiral'];

  @override
  void initState() {
    super.initState();
    // Safety check: jika masuk layar ini tanpa file terupload, reset index
    if (_orderFlow.uploadedFiles.isEmpty) {
      _activeFileIndex = 0;
    }
  }

  // Helper untuk membangun Stepper (Jumlah Salinan) yang premium
  Widget _buildCopiesStepper(int currentValue, ValueChanged<int> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Minus
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: currentValue > 1 ? () => onChanged(currentValue - 1) : null,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          // Teks Nilai
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              currentValue.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),

          // Tombol Plus
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () => onChanged(currentValue + 1),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membangun Dropdown Control kustom
  Widget _buildDropdownControl(
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(opt),
            );
          }).toList(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          elevation: 2,
          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Safety fallback
    if (_orderFlow.uploadedFiles.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Pengaturan Cetak'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tidak ada berkas untuk dikonfigurasi.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final activeFile = _orderFlow.uploadedFiles[_activeFileIndex];
    final fileCount = _orderFlow.uploadedFiles.length;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pengaturan Cetak',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // ─── Selector Tab Berkas (Horizontal Scroll) ─────────────────
          if (fileCount > 1)
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: fileCount,
                itemBuilder: (context, index) {
                  final file = _orderFlow.uploadedFiles[index];
                  final isActive = index == _activeFileIndex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isActive,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _activeFileIndex = index);
                        }
                      },
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? (isDark ? Colors.white : AppColors.teal900)
                            : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ─── Main Body (Preview + Form) ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step Indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.teal800.withValues(alpha: 0.3)
                              : const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'LANGKAH 3 DARI 3',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Informasi File Aktif
                  Text(
                    activeFile.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Konfigurasikan spesifikasi kertas, warna, dan jilid untuk berkas ini.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Pratinjau PDF (PdfPreviewWidget) ─────────────────────────
                  PdfPreviewWidget(
                    totalPages: activeFile.pageCount,
                    fileName: activeFile.name,
                  ),
                  const SizedBox(height: 28),

                  // ─── Pengaturan Cetak (Form) ──────────────────────────────────
                  Text(
                    'Spesifikasi Cetak',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 1. Eksemplar (Copies)
                  ConfigOption(
                    label: 'Jumlah Salinan',
                    description: 'Jumlah cetak salinan dokumen',
                    icon: Icons.copy_rounded,
                    control: _buildCopiesStepper(
                      activeFile.copies,
                      (val) => setState(() => activeFile.copies = val),
                    ),
                  ),
                  const Divider(),

                  // 2. Warna vs BW
                  ConfigOption(
                    label: 'Warna Cetak',
                    description: 'Pilih hasil tinta cetakan',
                    icon: Icons.color_lens_outlined,
                    control: _buildDropdownControl(
                      activeFile.colorMode,
                      _colorOptions,
                      (val) {
                        if (val != null) setState(() => activeFile.colorMode = val);
                      },
                    ),
                  ),
                  const Divider(),

                  // 3. Ukuran Kertas
                  ConfigOption(
                    label: 'Ukuran Kertas',
                    description: 'Format ukuran lembar cetak',
                    icon: Icons.settings_system_daydream_outlined,
                    control: _buildDropdownControl(
                      activeFile.paperSize,
                      _paperSizeOptions,
                      (val) {
                        if (val != null) setState(() => activeFile.paperSize = val);
                      },
                    ),
                  ),
                  const Divider(),

                  // 4. Jenis Kertas
                  ConfigOption(
                    label: 'Jenis Kertas',
                    description: 'Tipe ketebalan kertas',
                    icon: Icons.description_outlined,
                    control: _buildDropdownControl(
                      activeFile.paperType,
                      _paperTypeOptions,
                      (val) {
                        if (val != null) setState(() => activeFile.paperType = val);
                      },
                    ),
                  ),
                  const Divider(),

                  // 5. Finishing / Binding
                  ConfigOption(
                    label: 'Finishing / Jilid',
                    description: 'Opsi penjilidan dokumen',
                    icon: Icons.layers_rounded,
                    control: _buildDropdownControl(
                      activeFile.finishing,
                      _finishingOptions,
                      (val) {
                        if (val != null) setState(() => activeFile.finishing = val);
                      },
                    ),
                  ),
                  const Divider(),

                  // 6. Cetak Bolak-Balik (Duplex)
                  ConfigOption(
                    label: 'Cetak Bolak-Balik',
                    description: 'Cetak pada kedua sisi lembar kertas',
                    icon: Icons.layers_clear_outlined,
                    control: Switch(
                      value: activeFile.doubleSide,
                      activeThumbColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      onChanged: (val) => setState(() => activeFile.doubleSide = val),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Sticky Bottom Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileCount > 1
                          ? 'Konfigurasi $fileCount Berkas'
                          : 'Konfigurasi Siap',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/order/price-calculator');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Simpan & Lanjut',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
