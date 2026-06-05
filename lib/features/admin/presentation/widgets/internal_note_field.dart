import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../orders/data/order_model.dart';

class InternalNoteField extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onSaved;

  const InternalNoteField({
    required this.order,
    required this.onSaved,
    super.key,
  });

  @override
  State<InternalNoteField> createState() => _InternalNoteFieldState();
}

class _InternalNoteFieldState extends State<InternalNoteField> {
  late final TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.order.internalNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    setState(() {
      widget.order.internalNote = _noteController.text.trim();
      _isEditing = false;
    });
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Catatan internal pesanan ${widget.order.orderNumber} disimpan'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasNote = widget.order.internalNote != null && widget.order.internalNote!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 18,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Catatan Internal Admin',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (!_isEditing && hasNote)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit_rounded, size: 14),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing || !hasNote) ...[
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tuliskan catatan internal (hanya terlihat oleh admin)...',
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
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasNote)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _noteController.text = widget.order.internalNote ?? '';
                        _isEditing = false;
                      });
                    },
                    child: const Text('Batal'),
                  ),
                ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Catatan'),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkElevated : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: Text(
                widget.order.internalNote!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
