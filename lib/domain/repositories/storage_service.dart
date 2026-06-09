// lib/domain/repositories/storage_service.dart

import 'dart:io';
import 'dart:typed_data';

abstract class StorageService {
  /// Upload a document or image to the private 'order-files' bucket
  Future<String> uploadOrderFile({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  });

  /// Upload payment proof image to the private 'payment-proofs' bucket
  Future<String> uploadPaymentProof({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  });

  /// Upload photo profile to the public 'avatars' bucket
  Future<String> uploadAvatar({
    required String userId,
    required String fileName,
    File? file,
    Uint8List? bytes,
  });

  /// Generate a temporary public URL for private files
  Future<String> getSignedUrl(
    String bucket,
    String path, {
    int expiresInSeconds = 3600,
  });
}
