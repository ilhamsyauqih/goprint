import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Ilustrasi kustom untuk onboarding slides — dibangun dari widget Flutter.

// ─── Slide 1 — Upload File ─────────────────────────────────────────

class UploadFileIllustration extends StatelessWidget {
  const UploadFileIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IllustrationCanvas(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 28, child: _DocumentShape(width: 128, height: 154)),
          Positioned(
            bottom: 34,
            child: _RoundIconBadge(icon: Icons.cloud_upload_rounded),
          ),
        ],
      ),
    );
  }
}

// ─── Slide 2 — Kalkulasi Harga ─────────────────────────────────────

class PriceCalculationIllustration extends StatelessWidget {
  const PriceCalculationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IllustrationCanvas(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 26, child: _CalculatorShape()),
          Positioned(right: 34, bottom: 42, child: _PriceTag()),
        ],
      ),
    );
  }
}

// ─── Slide 3 — Pengantaran ─────────────────────────────────────────

class DeliveryIllustration extends StatelessWidget {
  const DeliveryIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IllustrationCanvas(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 38, child: _DeliveryBox()),
          Positioned(
            bottom: 36,
            child: _RoundIconBadge(icon: Icons.delivery_dining_rounded),
          ),
        ],
      ),
    );
  }
}

// ─── Internal building-block widgets ───────────────────────────────

class _IllustrationCanvas extends StatelessWidget {
  const _IllustrationCanvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      height: 256,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2F1), Color(0xFFFFFFFF)],
        ),
      ),
      child: child,
    );
  }
}

class _DocumentShape extends StatelessWidget {
  const _DocumentShape({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F00796B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.teal700,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 18),
          const _DocumentLine(width: 82),
          const SizedBox(height: 10),
          const _DocumentLine(width: 68),
          const SizedBox(height: 10),
          const _DocumentLine(width: 92),
          const Spacer(),
          const Icon(Icons.description_rounded, color: AppColors.teal600),
        ],
      ),
    );
  }
}

class _DocumentLine extends StatelessWidget {
  const _DocumentLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _RoundIconBadge extends StatelessWidget {
  const _RoundIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: AppColors.teal700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.teal700.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 42),
    );
  }
}

class _CalculatorShape extends StatelessWidget {
  const _CalculatorShape();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      height: 164,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F00796B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 34,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '12K',
              style: TextStyle(
                color: AppColors.teal900,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                9,
                (index) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: index == 8
                        ? AppColors.teal700
                        : const Color(0xFFF1F5F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.teal700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Rp',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _DeliveryBox extends StatelessWidget {
  const _DeliveryBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 144,
      height: 128,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F00796B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 44,
            child: Divider(color: Color(0xFFFFCC80), thickness: 4),
          ),
          Positioned(
            left: 58,
            top: 0,
            bottom: 0,
            child: VerticalDivider(color: Color(0xFFFFCC80), thickness: 4),
          ),
          Center(
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColors.teal700,
              size: 46,
            ),
          ),
        ],
      ),
    );
  }
}
