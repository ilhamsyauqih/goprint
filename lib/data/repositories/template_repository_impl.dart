// lib/data/repositories/template_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/template_repository.dart';
import '../models/template_model.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final SupabaseClient _client;

  TemplateRepositoryImpl(this._client);

  @override
  Future<List<TemplateModel>> getTemplates({String? category, String? query}) async {
    var builder = _client.from('templates').select();
    if (category != null && category.isNotEmpty) {
      builder = builder.eq('category', category);
    }
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('title', '%$query%');
    }
    final List data = await builder.order('created_at', ascending: false);
    return data.map((json) => TemplateModel.fromJson(json)).toList();
  }

  @override
  Future<TemplateModel> getTemplateById(String id) async {
    final data = await _client.from('templates').select().eq('id', id).single();
    return TemplateModel.fromJson(data);
  }

  @override
  Future<void> incrementDownload(String id) async {
    final template = await getTemplateById(id);
    await _client
        .from('templates')
        .update({'download_count': template.downloadCount + 1})
        .eq('id', id);
  }
}

/// Riverpod provider for TemplateRepository
final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TemplateRepositoryImpl(client);
});
