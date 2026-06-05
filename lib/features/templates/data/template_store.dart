import 'package:flutter/foundation.dart';

import '../data/mock_templates.dart';

/// State store untuk Template — filter kategori & pencarian.
///
/// Menggunakan [ChangeNotifier] agar konsisten dengan store lain di project
/// (AppStateStore, ProfileStore, NotificationStore).
class TemplateStore extends ChangeNotifier {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Daftar template yang sudah difilter berdasarkan kategori & query pencarian.
  List<TemplateItem> get filteredTemplates {
    List<TemplateItem> result = MockTemplates.templates
        .where((t) => t.isActive)
        .toList();

    // Filter kategori
    if (_selectedCategory != 'Semua') {
      result = result.where((t) => t.category == _selectedCategory).toList();
    }

    // Filter pencarian
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.name.toLowerCase().contains(query) ||
            t.category.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void reset() {
    _selectedCategory = 'Semua';
    _searchQuery = '';
    notifyListeners();
  }
}

/// Singleton store untuk template — dibagikan ke seluruh app.
final TemplateStore templateStore = TemplateStore();
