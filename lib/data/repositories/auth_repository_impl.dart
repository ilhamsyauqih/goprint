// lib/data/repositories/auth_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'user',
    String? shopName,
    String? shopAddress,
    String? gmapsLink,
    String? nibFilePath,
    String? ktpFilePath,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'role': role,
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign up failed: User is null');
    }

    // Jika role seller, buat toko baru di database
    if (role == 'seller' && shopName != null && shopAddress != null) {
      final now = DateTime.now().toIso8601String();
      await _client.from('shops').insert({
        'owner_id': user.id,
        'name': shopName,
        'address': shopAddress,
        'gmaps_link': gmapsLink,
        'nib_file_url': nibFilePath,
        'ktp_file_url': ktpFilePath,
        'lat': 0.0,
        'lng': 0.0,
        'photo_urls': <String>[],
        'operating_hours': <String, dynamic>{},
        'is_open': false,
        'rating': 0.0,
        'created_at': now,
        'updated_at': now,
      });
    }

    return await getCurrentUserById(user.id);
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign in failed: User is null');
    }

    return await getCurrentUserById(user.id);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      return await getCurrentUserById(user.id);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> getCurrentUserById(String uid) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .single();
    return UserModel.fromJson(data);
  }
}

/// Riverpod provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});
