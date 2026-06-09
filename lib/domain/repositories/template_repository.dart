// lib/domain/repositories/template_repository.dart

import '../../data/models/template_model.dart';

abstract class TemplateRepository {
  /// Fetch all templates, optionally filtering by category and name/query
  Future<List<TemplateModel>> getTemplates({String? category, String? query});

  /// Retrieve a specific template by its ID
  Future<TemplateModel> getTemplateById(String id);

  /// Increment the download count of a template by 1
  Future<void> incrementDownload(String id);
}
