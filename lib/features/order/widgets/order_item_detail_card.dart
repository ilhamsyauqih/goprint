import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class OrderItemDetailCard extends StatelessWidget {
  final OrderItem item;

  const OrderItemDetailCard({
    super.key,
    required this.item,
  });

  // Rupiah formatting helper
  String _formatRupiah(double value) {
    String money = value.toInt().toString();
    String result = '';
    int count = 0;
    for (int i = money.length - 1; i >= 0; i--) {
      result = money[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  // Detect file extension for icon selection
  IconData _getFileIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_rounded;
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) {
      return Icons.image_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  // Detect file icon background color
  Color _getFileIconBg(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return const Color(0xFFFEE2E2); // Red background
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return const Color(0xFFDBEAFE); // Blue background
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) {
      return const Color(0xFFFEF3C7); // Amber background
    } else {
      return const Color(0xFFF1F5F9); // Grey background
    }
  }

  // Detect file icon color
  Color _getFileIconColor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return const Color(0xFFEF4444); // Red icon
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return const Color(0xFF3B82F6); // Blue icon
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png')) {
      return const Color(0xFFF59E0B); // Amber icon
    } else {
      return const Color(0xFF64748B); // Grey icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Icon Thumbnail
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getFileIconBg(item.fileName),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(item.fileName),
                  color: _getFileIconColor(item.fileName),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              
              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.fileSize} · ${item.pages} hlm · ${item.copies} eksemplar',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Configurations chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: item.configuration.map((config) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  config,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.border,
            ),
          ),
          
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal File',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Text(
                _formatRupiah(item.subtotal),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
