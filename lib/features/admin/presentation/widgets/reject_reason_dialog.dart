import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RejectReasonDialog extends StatefulWidget {
  final String orderNumber;
  final ValueChanged<String> onSubmitted;

  const RejectReasonDialog({
    required this.orderNumber,
    required this.onSubmitted,
    super.key,
  });

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  final List<String> _quickReasons = [
    'Bukti transfer tidak valid/kosong',
    'Berkas rusak/tidak bisa dibuka',
    'Konfigurasi cetak tidak sesuai',
    'Toko sedang tutup/penuh',
    'Pilihan jasa pengiriman tidak didukung',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Tolak Pesanan ${widget.orderNumber}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alasan penolakan pesanan ini:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              const SizedBox(height: 12),

              // Quick presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickReasons.map((reason) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _reasonController.text = reason;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _reasonController.text == reason
                            ? (isDark ? AppColors.teal300.withValues(alpha: 0.2) : AppColors.teal700.withValues(alpha: 0.1))
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _reasonController.text == reason
                              ? (isDark ? AppColors.teal300 : AppColors.teal700)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _reasonController.text == reason
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _reasonController.text == reason
                              ? (isDark ? AppColors.teal300 : AppColors.teal700)
                              : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Text Field Input
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan penolakan secara detail...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkElevated : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alasan penolakan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              widget.onSubmitted(_reasonController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('Tolak Pesanan'),
        ),
      ],
    );
  }
}
