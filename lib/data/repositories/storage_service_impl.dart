// lib/data/repositories/storage_service_impl.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/storage_service.dart';

class StorageServiceImpl implements StorageService {
  final SupabaseClient _client;

  StorageServiceImpl(this._client);

  Future<String> _upload({
    required String bucket,
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    // Unique timestamp prefix to prevent file name collisions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');
    final path = '$userId/${timestamp}_$cleanFileName';

    if (file != null) {
      await _client.storage.from(bucket).upload(path, file);
    } else if (bytes != null) {
      await _client.storage.from(bucket).uploadBinary(path, bytes);
    } else {
      throw ArgumentError('Either file or bytes must be provided for upload');
    }

    return path;
  }

  @override
  Future<String> uploadOrderFile({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    return await _upload(
      bucket: 'order-files',
      userId: userId,
      fileName: fileName,
      file: file,
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadPaymentProof({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    return await _upload(
      bucket: 'payment-proofs',
      userId: userId,
      fileName: fileName,
      file: file,
      bytes: bytes,
    );
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    final path = await _upload(
      bucket: 'avatars',
      userId: userId,
      fileName: fileName,
      file: file,
      bytes: bytes,
    );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  @override
  Future<String> getSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
  }) async {
    return await _client.storage
        .from(bucket)
        .createSignedUrl(path, expiresInSeconds);
  }
}

/// Riverpod provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StorageServiceImpl(client);
});
