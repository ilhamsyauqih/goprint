import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/docx_helper.dart';
import '../../data/order_flow_manager.dart';

/// Komponen: [PdfPreviewWidget] — preview file PDF/DOCX dalam aplikasi
class PdfPreviewWidget extends StatefulWidget {
  const PdfPreviewWidget({
    required this.file,
    super.key,
  });

  final UploadedFile file;

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  int _currentPage = 1;

  // PDF specific state
  PdfDocument? _pdfDocument;
  bool _loadingPdf = false;
  String? _pdfError;
  final Map<int, Uint8List> _renderedPdfPages = {};
  bool _renderingPage = false;

  // DOCX specific state
  List<String> _docxPages = [];
  bool _loadingDocx = false;
  String? _docxError;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  @override
  void didUpdateWidget(covariant PdfPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file.id != oldWidget.file.id) {
      _currentPage = 1;
      _renderedPdfPages.clear();
      _pdfDocument?.close();
      _pdfDocument = null;
      _initializePreview();
    } else if (widget.file.pageCount < _currentPage) {
      _currentPage = 1;
    }
  }

  @override
  void dispose() {
    _pdfDocument?.close();
    super.dispose();
  }

  void _initializePreview() {
    final name = widget.file.name.toLowerCase();
    if (name.endsWith('.pdf')) {
      _loadPdf();
    } else if (name.endsWith('.docx')) {
      _loadDocx();
    }
  }

  Future<void> _loadPdf() async {
    if (widget.file.bytes == null && widget.file.filePath == null) {
      // Mock PDF - nothing to load, fallback to simulated page
      return;
    }

    setState(() {
      _loadingPdf = true;
      _pdfError = null;
    });

    try {
      if (widget.file.bytes != null) {
        _pdfDocument = await PdfDocument.openData(widget.file.bytes!);
      } else if (widget.file.filePath != null) {
        _pdfDocument = await PdfDocument.openFile(widget.file.filePath!);
      }
      _loadCurrentPdfPage();
    } catch (e) {
      setState(() {
        _pdfError = 'Gagal memuat PDF: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingPdf = false;
        });
      }
    }
  }

  Future<void> _loadCurrentPdfPage() async {
    if (_pdfDocument == null) return;
    if (_renderedPdfPages.containsKey(_currentPage)) return;

    setState(() {
      _renderingPage = true;
    });

    try {
      final page = await _pdfDocument!.getPage(_currentPage);
      final pageImage = await page.render(
        width: page.width * 1.5,
        height: page.height * 1.5,
        format: PdfPageImageFormat.jpeg,
      );
      await page.close();
      if (pageImage != null && mounted) {
        setState(() {
          _renderedPdfPages[_currentPage] = pageImage.bytes;
        });
      }
    } catch (e) {
      // render error
    } finally {
      if (mounted) {
        setState(() {
          _renderingPage = false;
        });
      }
    }
  }

  Future<void> _loadDocx() async {
    if (widget.file.bytes == null && widget.file.filePath == null) {
      // Mock DOCX - nothing to load, fallback to simulated page
      return;
    }

    setState(() {
      _loadingDocx = true;
      _docxError = null;
    });

    try {
      Uint8List? bytes = widget.file.bytes;
      if (bytes == null && widget.file.filePath != null) {
        bytes = await File(widget.file.filePath!).readAsBytes();
      }
      if (bytes != null) {
        final text = DocxHelper.extractText(bytes);
        _docxPages = DocxHelper.paginateText(text, widget.file.pageCount);
      } else {
        throw Exception('Data berkas tidak tersedia.');
      }
    } catch (e) {
      setState(() {
        _docxError = 'Gagal memuat Word: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingDocx = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < widget.file.pageCount) {
      setState(() {
        _currentPage++;
      });
      if (widget.file.name.toLowerCase().endsWith('.pdf')) {
        _loadCurrentPdfPage();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      if (widget.file.name.toLowerCase().endsWith('.pdf')) {
        _loadCurrentPdfPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // ─── Kertas A4 Simulasi ──────────────────────────────────────
        AspectRatio(
          aspectRatio: 1 / 1.414, // Proporsi standar A4 (ISO 216)
          child: Container(
            clipBehavior: Clip.antiAlias, // Clip child inside rounded corners
            decoration: BoxDecoration(
              color: Colors.white, // Kertas selalu putih untuk preview cetak
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildPreviewContent(context, isDark),
          ),
        ),
        const SizedBox(height: 16),

        // ─── Kontrol Navigasi Halaman ─────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol Prev
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? _prevPage : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                disabledBackgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(width: 16),

            // Indikator Halaman
            Text(
              'Halaman $_currentPage dari ${widget.file.pageCount}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),

            // Tombol Next
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < widget.file.pageCount ? _nextPage : null,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                disabledBackgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewContent(BuildContext context, bool isDark) {
    final name = widget.file.name.toLowerCase();
    final isPdf = name.endsWith('.pdf');
    final isDocx = name.endsWith('.docx');
    final isReal = widget.file.bytes != null || widget.file.filePath != null;

    if (!isReal) {
      return _buildMockLayout();
    }

    if (isPdf) {
      if (_loadingPdf) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_pdfError != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _pdfError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      final pageBytes = _renderedPdfPages[_currentPage];
      if (pageBytes == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        children: [
          Image.memory(
            pageBytes,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
          if (_renderingPage)
            const Positioned(
              right: 8,
              top: 8,
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      );
    }

    if (isDocx) {
      if (_loadingDocx) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_docxError != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _docxError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      if (_docxPages.isEmpty || _currentPage - 1 >= _docxPages.length) {
        return const Center(
          child: Text(
            'Halaman Kosong',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header / Doc Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Text(
                  'Hal. $_currentPage dari ${widget.file.pageCount}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, thickness: 0.5, height: 10),
            const SizedBox(height: 12),
            // Text Content
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Text(
                  _docxPages[_currentPage - 1],
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    color: Color(0xFF2C3E50),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildMockLayout();
  }

  Widget _buildMockLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mock Header Dokumen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 8,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Hal. $_currentPage dari ${widget.file.pageCount}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.grey, thickness: 0.8),
          const SizedBox(height: 16),

          // Mock Judul Dokumen (Halaman 1 saja)
          if (_currentPage == 1) ...[
            Container(
              height: 16,
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.teal900,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 10,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Mock Paragraf Teks (Garis-garis abu-abu)
          ...List.generate(_currentPage == 1 ? 5 : 8, (index) {
            final isShort = index % 3 == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 8,
                width: isShort ? 120 : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Mock Gambar/Ilustrasi di tengah dokumen
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade400,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mock Paragraf Teks bawah
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
