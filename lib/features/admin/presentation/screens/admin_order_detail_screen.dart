import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../orders/data/order_flow_manager.dart';
import '../../../orders/data/order_model.dart';
import '../../../orders/presentation/widgets/order_item_detail_card.dart';
import '../../../orders/presentation/widgets/payment_info_section.dart';
import '../widgets/customer_info_section.dart';
import '../widgets/payment_verification_section.dart';
import '../widgets/admin_action_buttons.dart';
import '../widgets/internal_note_field.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({required this.orderId, super.key});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  late OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    final found = _orderFlow.orders.where((o) => o.orderNumber == widget.orderId).toList();
    if (found.isNotEmpty) {
      _order = found.first;
    } else {
      _order = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_order == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Detail Pesanan', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Pesanan Tidak Ditemukan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Nomor pesanan "${widget.orderId}" tidak valid.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'Kelola ${order.orderNumber}',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information Section
                  CustomerInfoSection(order: order),
                  const SizedBox(height: 20),

                  // Estimate completion time banner (if exists and processing/ready)
                  if (order.estimatedCompletionTime != null && 
                      (order.status == OrderStatus.processing || order.status == OrderStatus.ready)) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppColors.teal900.withValues(alpha: 0.2) 
                            : AppColors.teal700.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Estimasi Pengerjaan: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            order.estimatedCompletionTime!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Payment Verification Section (Approve / Reject verification)
                  PaymentVerificationSection(
                    order: order,
                    onUpdate: () => setState(() {}),
                  ),

                  // Internal Notes Field Section
                  InternalNoteField(
                    order: order,
                    onSaved: () => setState(() {}),
                  ),

                  // Document List Section
                  Text(
                    'Dokumen Cetak (${order.uploadedFiles.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.uploadedFiles.map((file) => OrderItemDetailCard(file: file)),
                  const SizedBox(height: 20),

                  // Pricing Details Section
                  PaymentInfoSection(order: order),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Sticky Bottom Section for Actions
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: AdminActionButtons(
                order: order,
                onUpdate: () {
                  setState(() {
                    _loadOrder(); // Reload the state
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
