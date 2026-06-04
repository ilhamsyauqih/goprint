import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_model.dart';

/// Stepper vertikal bergradasi teal dengan titik status pelacakan pesanan.
class OrderTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderTimeline({required this.order, super.key});

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<_TimelineStep> steps = [];
    final baseTime = order.date;

    if (order.status == OrderStatus.cancelled) {
      steps.add(_TimelineStep(
        title: 'Pesanan Dibuat',
        description: 'Pesanan berhasil dikirim ke toko',
        time: _formatTime(baseTime),
        state: _StepState.completed,
      ));
      steps.add(_TimelineStep(
        title: 'Pesanan Dibatalkan',
        description: 'Pesanan telah dibatalkan oleh pengguna/toko',
        time: _formatTime(baseTime.add(const Duration(minutes: 5))),
        state: _StepState.cancelled,
      ));
    } else {
      // Step 1: Dibuat (Selalu Selesai/Aktif)
      steps.add(_TimelineStep(
        title: 'Pesanan Dibuat',
        description: 'Pesanan berhasil dikirim ke toko',
        time: _formatTime(baseTime),
        state: _getState(OrderStatus.pending),
      ));

      // Step 2: Dikonfirmasi
      steps.add(_TimelineStep(
        title: 'Dikonfirmasi',
        description: 'Toko menerima dokumen & pembayaran terverifikasi',
        time: _formatTime(baseTime.add(const Duration(minutes: 5))),
        state: _getState(OrderStatus.confirmed),
      ));

      // Step 3: Diproses
      steps.add(_TimelineStep(
        title: 'Diproses',
        description: 'Dokumen sedang dicetak oleh toko',
        time: _formatTime(baseTime.add(const Duration(minutes: 12))),
        state: _getState(OrderStatus.processing),
      ));

      // Step 4: Siap Diambil / Siap Dikirim
      final isDelivery = order.deliveryType == 'delivery';
      steps.add(_TimelineStep(
        title: isDelivery ? 'Siap Dikirim' : 'Siap Diambil',
        description: isDelivery 
            ? 'Cetak dokumen selesai & menunggu kurir' 
            : 'Silakan ambil cetakan Anda di toko',
        time: _formatTime(baseTime.add(const Duration(minutes: 25))),
        state: _getState(OrderStatus.ready),
      ));

      // Step 5: Selesai
      steps.add(_TimelineStep(
        title: 'Selesai',
        description: 'Pesanan telah diselesaikan oleh pengguna/toko',
        time: _formatTime(baseTime.add(const Duration(minutes: 35))),
        state: _getState(OrderStatus.completed),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Lacak Status Pesanan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              // Garis vertikal bergradasi teal di belakang titik status
              Positioned(
                left: 10, // Menyelaraskan dengan titik dot (lebar 22)
                top: 12,
                bottom: 12,
                child: Container(
                  width: 3.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDark ? AppColors.teal300 : AppColors.teal600,
                        (isDark ? AppColors.teal300 : AppColors.teal600).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              // List baris timeline pelacakan
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isLast = index == steps.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0.0 : 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titik indikator kiri (Dot)
                        SizedBox(
                          width: 23,
                          height: 22,
                          child: Center(
                            child: _buildDot(step.state, isDark),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Konten deskripsi status di kanan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    step.title,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: step.state == _StepState.current || step.state == _StepState.completed
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: step.state == _StepState.future
                                          ? (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText)
                                          : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                                    ),
                                  ),
                                  if (step.state == _StepState.completed || 
                                      step.state == _StepState.current || 
                                      step.state == _StepState.cancelled)
                                    Text(
                                      step.time,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StepState _getState(OrderStatus stepStatus) {
    final currentStatusIndex = order.status.index;
    final stepStatusIndex = stepStatus.index;

    if (currentStatusIndex > stepStatusIndex) {
      return _StepState.completed;
    } else if (currentStatusIndex == stepStatusIndex) {
      return _StepState.current;
    } else {
      return _StepState.future;
    }
  }

  Widget _buildDot(_StepState state, bool isDark) {
    switch (state) {
      case _StepState.completed:
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isDark ? AppColors.teal300 : AppColors.teal600,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 10,
              color: Colors.white,
            ),
          ),
        );
      case _StepState.current:
        final tealColor = isDark ? AppColors.teal300 : AppColors.teal700;
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: tealColor.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: tealColor,
              width: 2.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: tealColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _StepState.cancelled:
        return Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.close_rounded,
              size: 10,
              color: Colors.white,
            ),
          ),
        );
      case _StepState.future:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 2,
            ),
          ),
        );
    }
  }
}

enum _StepState {
  completed,
  current,
  future,
  cancelled,
}

class _TimelineStep {
  final String title;
  final String description;
  final String time;
  final _StepState state;

  _TimelineStep({
    required this.title,
    required this.description,
    required this.time,
    required this.state,
  });
}
