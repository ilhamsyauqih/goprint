import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/profile_provider.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  void _addAddress(BuildContext context) {
    context.push('/profile/addresses/add');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final addresses = profileState.addresses;
    final notifier = ref.read(profileNotifierProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alamat Tersimpan',
        actions: [
          IconButton(
            tooltip: 'Tambah alamat',
            onPressed: () => _addAddress(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
      body: profileState.isLoading && addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? const _EmptyAddressState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
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
                          address.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(address.fullAddress),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'default') {
                              notifier.setDefaultAddress(address.id);
                            } else if (value == 'delete') {
                              notifier.deleteAddress(address.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'default',
                              child: Text('Jadikan Default'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addAddress(context),
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text('Tambah'),
          ),
        );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada alamat tersimpan',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan alamat kos, kampus, atau titik temu favorit.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkMutedText
                    : AppColors.lightSubtleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
