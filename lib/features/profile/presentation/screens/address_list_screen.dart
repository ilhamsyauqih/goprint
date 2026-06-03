import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

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

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final List<UserAddress> _addresses = [
    const UserAddress(
      title: 'Kos Melati',
      detail: 'Jl. Kampus No. 12, dekat gerbang utara',
      isDefault: true,
    ),
    const UserAddress(
      title: 'Gedung Perpustakaan',
      detail: 'Lobi utama, sebelah layanan akademik',
      isDefault: false,
    ),
  ];

  Future<void> _addAddress() async {
    final result = await context.push<UserAddress>('/profile/addresses/add');
    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _addresses.add(result);
    });
  }

  void _setDefault(int selectedIndex) {
    setState(() {
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: i == selectedIndex);
      }
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      final wasDefault = _addresses[index].isDefault;
      _addresses.removeAt(index);
      if (wasDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alamat Tersimpan',
        actions: [
          IconButton(
            tooltip: 'Tambah alamat',
            onPressed: _addAddress,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                address.isDefault
                    ? Icons.check_circle_rounded
                    : Icons.location_on_outlined,
                color: address.isDefault
                    ? AppColors.success
                    : AppColors.teal700,
              ),
              title: Text(
                address.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(address.detail),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'default') {
                    _setDefault(index);
                  } else if (value == 'delete') {
                    _deleteAddress(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'default',
                    child: Text('Jadikan Default'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Tambah'),
      ),
    );
  }
}
