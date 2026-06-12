import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Helper class for parsing DOCX files.
class DocxHelper {
  /// Extracts the page count from docProps/app.xml inside the DOCX ZIP archive.
  /// Falls back to character-based estimation if page count metadata is missing.
  static int getPageCount(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final appXmlFile = archive.findFile('docProps/app.xml');
      if (appXmlFile != null) {
        final content = String.fromCharCodes(appXmlFile.content as List<int>);
        final pagesRegExp = RegExp(r'<Pages>(\d+)</Pages>');
        final match = pagesRegExp.firstMatch(content);
        if (match != null) {
          final count = int.tryParse(match.group(1) ?? '');
          if (count != null && count > 0) return count;
        }
      }

      // Fallback: estimate page count from extracted text
      final text = extractText(bytes);
      if (text.isEmpty) return 1;
      
      // Estimate 1 page per 1500 characters
      final estimated = (text.length / 1500).ceil();
      return estimated > 0 ? estimated : 1;
    } catch (_) {
      return 1;
    }
  }

  /// Extracts text from word/document.xml inside the DOCX archive.
  /// Decodes standard XML entities and preserves paragraph splits.
  static String extractText(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentXmlFile = archive.findFile('word/document.xml');
      if (documentXmlFile == null) return '';

      final xmlContent = String.fromCharCodes(documentXmlFile.content as List<int>);

      // Patterns for paragraphs, text elements, and page breaks
      final paragraphRegExp = RegExp(r'<w:p\b[^>]*>(.*?)</w:p>', dotAll: true);
      final textRegExp = RegExp(r'<w:t\b[^>]*>(.*?)</w:t>', dotAll: true);
      final pageBreakRegExp = RegExp(r'<(w:br\s+w:type="page"|w:lastRenderedPageBreak)\b[^>]*>');

      final paragraphs = paragraphRegExp.allMatches(xmlContent);
      final buffer = StringBuffer();

      for (final pMatch in paragraphs) {
        final pContent = pMatch.group(1) ?? '';
        final hasPageBreak = pageBreakRegExp.hasMatch(pContent);

        final tMatches = textRegExp.allMatches(pContent);
        final pText = tMatches.map((m) => m.group(1) ?? '').join('');

        if (pText.isNotEmpty) {
          buffer.writeln(_decodeXml(pText));
        } else if (hasPageBreak) {
          buffer.writeln('[PAGE_BREAK]');
          continue;
        }

        if (hasPageBreak) {
          buffer.writeln('[PAGE_BREAK]');
        }
      }

      return buffer.toString();
    } catch (e) {
      return 'Gagal membaca isi berkas DOCX: $e';
    }
  }

  /// Helper to decode XML entities
  static String _decodeXml(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  /// Paginate DOCX text into exactly `targetPageCount` pages.
  static List<String> paginateText(String text, int targetPageCount) {
    if (text.isEmpty) {
      return List.filled(targetPageCount, '');
    }

    // First, try splitting by the explicit [PAGE_BREAK] marker if it exists
    if (text.contains('[PAGE_BREAK]')) {
      final parts = text.split('[PAGE_BREAK]').map((p) => p.trim()).toList();
      // If we have exactly the right amount or more, we can use it (trimming/merging if necessary)
      if (parts.length == targetPageCount) {
        return parts;
      }
    }

    // Clean text of the temporary marker if count didn't match
    final cleanText = text.replaceAll('[PAGE_BREAK]\n', '').replaceAll('[PAGE_BREAK]', '');
    final lines = cleanText.split('\n');

    if (targetPageCount <= 1) {
      return [cleanText];
    }

    // Split based on character count per page
    final totalChars = cleanText.length;
    int charsPerPage = totalChars ~/ targetPageCount;
    if (charsPerPage < 200) charsPerPage = 200;

    final List<String> pages = [];
    final StringBuffer currentPageText = StringBuffer();
    int currentLength = 0;

    for (final line in lines) {
      currentPageText.writeln(line);
      currentLength += line.length + 1;

      if (currentLength >= charsPerPage && pages.length < targetPageCount - 1) {
        pages.add(currentPageText.toString().trim());
        currentPageText.clear();
        currentLength = 0;
      }
    }

    if (currentPageText.isNotEmpty || pages.length < targetPageCount) {
      pages.add(currentPageText.toString().trim());
    }

    // Pad if we have fewer pages
    while (pages.length < targetPageCount) {
      pages.add('');
    }

    // Merge if we have more pages (should be rare)
    while (pages.length > targetPageCount) {
      final last = pages.removeLast();
      if (pages.isNotEmpty) {
        pages[pages.length - 1] = '${pages[pages.length - 1]}\n$last';
      }
    }

    return pages;
  }
}
