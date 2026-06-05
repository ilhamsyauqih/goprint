import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SetEstimateDialog extends StatefulWidget {
  final String orderNumber;
  final ValueChanged<String> onSubmitted;

  const SetEstimateDialog({
    required this.orderNumber,
    required this.onSubmitted,
    super.key,
  });

  @override
  State<SetEstimateDialog> createState() => _SetEstimateDialogState();
}

class _SetEstimateDialogState extends State<SetEstimateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _estimateController = TextEditingController();

  final List<String> _quickEstimates = [
    '15 Menit',
    '30 Menit',
    '1 Jam',
    '2 Jam',
    '4 Jam',
    'Besok Hari',
  ];

  @override
  void dispose() {
    _estimateController.dispose();
    super.dispose();
  }

  // Override dispose without calling super twice (fixed above)
  @override
  void initState() {
    super.initState();
    // Default to first quick estimate
    _estimateController.text = _quickEstimates[1]; // "30 Menit"
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Set Estimasi Pesanan ${widget.orderNumber}',
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
                'Tentukan estimasi waktu pengerjaan cetak:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              const SizedBox(height: 12),

              // Quick preset times
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickEstimates.map((estimate) {
                  final isSelected = _estimateController.text == estimate;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _estimateController.text = estimate;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.teal300.withValues(alpha: 0.2) : AppColors.teal700.withValues(alpha: 0.1))
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppColors.teal300 : AppColors.teal700)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        estimate,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? AppColors.teal300 : AppColors.teal700)
                              : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Custom Input
              Text(
                'Atau tulis estimasi kustom:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _estimateController,
                decoration: InputDecoration(
                  hintText: 'Misal: 3 Hari, Selesai sore ini...',
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => _estimateController.clear(),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Estimasi waktu pengerjaan tidak boleh kosong';
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
              widget.onSubmitted(_estimateController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
            foregroundColor: isDark ? AppColors.teal900 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text('Proses Pesanan'),
        ),
      ],
    );
  }
}
