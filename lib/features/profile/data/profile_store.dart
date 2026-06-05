import 'package:flutter/material.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.primaryAddress,
    required this.avatarIcon,
  });

  final String name;
  final String email;
  final String phone;
  final String primaryAddress;
  final IconData avatarIcon;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? primaryAddress,
    IconData? avatarIcon,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      primaryAddress: primaryAddress ?? this.primaryAddress,
      avatarIcon: avatarIcon ?? this.avatarIcon,
    );
  }
}

class UserAddress {
  const UserAddress({
    required this.title,
    required this.detail,
    required this.isDefault,
  });

  final String title;
  final String detail;
  final bool isDefault;

  UserAddress copyWith({bool? isDefault}) {
    return UserAddress(
      title: title,
      detail: detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class ProfileStore extends ChangeNotifier {
  UserProfile _profile = _initialProfile;
  List<UserAddress> _addresses = List<UserAddress>.of(_initialAddresses);
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  DateTime? _lastPasswordChangedAt;

  UserProfile get profile => _profile;
  List<UserAddress> get addresses => List<UserAddress>.unmodifiable(_addresses);
  bool get orderNotifications => _orderNotifications;
  bool get promoNotifications => _promoNotifications;
  DateTime? get lastPasswordChangedAt => _lastPasswordChangedAt;

  void updateProfile({
    required String name,
    required String phone,
    required String primaryAddress,
  }) {
    _profile = _profile.copyWith(
      name: name,
      phone: phone,
      primaryAddress: primaryAddress,
    );

    if (_addresses.isEmpty) {
      _addresses = [
        UserAddress(
          title: 'Alamat Utama',
          detail: primaryAddress,
          isDefault: true,
        ),
      ];
    } else {
      final defaultIndex = _addresses.indexWhere(
        (address) => address.isDefault,
      );
      final targetIndex = defaultIndex == -1 ? 0 : defaultIndex;
      _addresses[targetIndex] = UserAddress(
        title: _addresses[targetIndex].title,
        detail: primaryAddress,
        isDefault: true,
      );
    }

    notifyListeners();
  }

  void updateAvatar(IconData avatarIcon) {
    _profile = _profile.copyWith(avatarIcon: avatarIcon);
    notifyListeners();
  }

  void addAddress(UserAddress address) {
    _addresses = [..._addresses, address];
    notifyListeners();
  }

  void setDefaultAddress(int selectedIndex) {
    _addresses = [
      for (var i = 0; i < _addresses.length; i++)
        _addresses[i].copyWith(isDefault: i == selectedIndex),
    ];

    _profile = _profile.copyWith(
      primaryAddress: _addresses[selectedIndex].detail,
    );
    notifyListeners();
  }

  void deleteAddress(int index) {
    final wasDefault = _addresses[index].isDefault;
    _addresses = [..._addresses]..removeAt(index);

    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
      _profile = _profile.copyWith(primaryAddress: _addresses[0].detail);
    }

    if (_addresses.isEmpty) {
      _profile = _profile.copyWith(primaryAddress: '-');
    }

    notifyListeners();
  }

  void updateOrderNotifications(bool value) {
    _orderNotifications = value;
    notifyListeners();
  }

  void updatePromoNotifications(bool value) {
    _promoNotifications = value;
    notifyListeners();
  }

  void changePassword() {
    _lastPasswordChangedAt = DateTime.now();
    notifyListeners();
  }

  void reset() {
    _profile = _initialProfile;
    _addresses = List<UserAddress>.of(_initialAddresses);
    _orderNotifications = true;
    _promoNotifications = false;
    _lastPasswordChangedAt = null;
    notifyListeners();
  }
}

const UserProfile _initialProfile = UserProfile(
  name: 'Amir Mahendra',
  email: 'amir@goprint.id',
  phone: '0812-3456-7890',
  primaryAddress: 'Kos Melati, Jl. Kampus No. 12',
  avatarIcon: Icons.person_rounded,
);

const List<UserAddress> _initialAddresses = [
  UserAddress(
    title: 'Kos Melati',
    detail: 'Jl. Kampus No. 12, dekat gerbang utara',
    isDefault: true,
  ),
  UserAddress(
    title: 'Gedung Perpustakaan',
    detail: 'Lobi utama, sebelah layanan akademik',
    isDefault: false,
  ),
];

final ProfileStore profileStore = ProfileStore();
