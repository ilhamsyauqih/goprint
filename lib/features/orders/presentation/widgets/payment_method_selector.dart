import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Komponen: Pemilih Metode Pembayaran.
class PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  // Daftar Metode Pembayaran beserta Kategori dan Icon
  final List<Map<String, dynamic>> _methods = const [
    {
      'id': 'QRIS',
      'name': 'QRIS (Gopay, OVO, Dana, LinkAja)',
      'icon': Icons.qr_code_2_rounded,
      'category': 'E-Wallet / Instant',
      'isInstant': true,
    },
    {
      'id': 'GoPay',
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet_rounded,
      'category': 'E-Wallet / Instant',
      'isInstant': true,
    },
    {
      'id': 'Dana',
      'name': 'Dana',
      'icon': Icons.phone_android_rounded,
      'category': 'E-Wallet / Instant',
      'isInstant': true,
    },
    {
      'id': 'OVO',
      'name': 'OVO',
      'icon': Icons.wallet_rounded,
      'category': 'E-Wallet / Instant',
      'isInstant': true,
    },
    {
      'id': 'Transfer',
      'name': 'Transfer Bank (Verifikasi Manual)',
      'icon': Icons.account_balance_rounded,
      'category': 'Transfer Bank',
      'isInstant': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metode Pembayaran',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _methods.length,
          itemBuilder: (context, index) {
            final method = _methods[index];
            final isSelected = selectedMethod == method['id'];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.teal300 : AppColors.teal700)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                onTap: () => onMethodSelected(method['id'] as String),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.teal900.withValues(alpha: 0.4) : const Color(0xFFE0F2F1))
                        : (isDark ? AppColors.darkElevated : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    method['icon'] as IconData,
                    color: isSelected
                        ? (isDark ? AppColors.teal300 : AppColors.teal700)
                        : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                    size: 24,
                  ),
                ),
                title: Text(
                  method['name'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  method['category'] as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
                trailing: Radio<String>(
                  activeColor: isDark ? AppColors.teal300 : AppColors.teal700,
                  value: method['id'] as String,
                  // ignore: deprecated_member_use
                  groupValue: selectedMethod,
                  // ignore: deprecated_member_use
                  onChanged: (val) {
                    if (val != null) {
                      onMethodSelected(val);
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
