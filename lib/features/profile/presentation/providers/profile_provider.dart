// lib/features/profile/presentation/providers/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../data/models/user_model.dart';

class ProfileState {
  final UserModel? user;
  final AddressModel? defaultAddress;
  final List<AddressModel> addresses;
  final bool isLoading;
  final String? errorMessage;

  ProfileState({
    this.user,
    this.defaultAddress,
    this.addresses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    AddressModel? defaultAddress,
    List<AddressModel>? addresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;
  final SupabaseClient _client;

  ProfileNotifier(this._ref, this._client) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'User not logged in');
        return;
      }

      // Fetch addresses
      final addressData = await _client
          .from('addresses')
          .select()
          .eq('user_id', user.id);
      
      final addresses = (addressData as List)
          .map((json) => AddressModel.fromJson(json))
          .toList();

      AddressModel? defaultAddress;
      if (addresses.isNotEmpty) {
        final foundDefault = addresses.where((a) => a.isDefault);
        if (foundDefault.isNotEmpty) {
          defaultAddress = foundDefault.first;
        } else {
          defaultAddress = addresses.first;
        }
      }

      state = state.copyWith(
        user: user,
        addresses: addresses,
        defaultAddress: defaultAddress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final user = state.user;
    if (user == null) return;
    
    state = state.copyWith(isLoading: true);
    try {
      await _client
          .from('profiles')
          .update({'name': name, 'phone': phone})
          .eq('id', user.id);

      final updatedUser = user.copyWith(name: name, phone: phone);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> addAddress({required String label, required String fullAddress, required bool isDefault}) async {
    final user = state.user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      if (isDefault) {
        // Unset other default addresses
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', user.id);
      }

      await _client.from('addresses').insert({
        'user_id': user.id,
        'label': label,
        'full_address': fullAddress,
        'is_default': isDefault,
      });

      await loadProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateAddress({
    required String addressId,
    required String label,
    required String fullAddress,
    required bool isDefault,
  }) async {
    final user = state.user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      if (isDefault) {
        // Unset other default addresses
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', user.id);
      }

      await _client.from('addresses').update({
        'label': label,
        'full_address': fullAddress,
        'is_default': isDefault,
      }).eq('id', addressId);

      await loadProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _client.from('addresses').delete().eq('id', addressId);
      await loadProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = state.user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', user.id);

      await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId);

      await loadProfile();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileNotifier(ref, client);
});
