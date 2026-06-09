// lib/domain/repositories/auth_repository.dart

import '../../data/models/user_model.dart';

abstract class AuthRepository {
  /// Sign up a new user/admin and automatically create their profile
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'user',
  });

  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user session
  Future<void> signOut();

  /// Send password reset link to user email
  Future<void> resetPassword(String email);

  /// Fetch the current user profile from database
  Future<UserModel?> getCurrentUser();
}
