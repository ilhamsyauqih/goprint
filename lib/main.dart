import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const GoPrintApp());
}

class GoPrintApp extends StatelessWidget {
  const GoPrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoPrint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal700,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const teal200 = Color(0xFF80CBC4);
  static const teal400 = Color(0xFF26A69A);
  static const teal600 = Color(0xFF00897B);
  static const teal700 = Color(0xFF00796B);
  static const teal900 = Color(0xFF004D40);
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightCard = Color(0xFFFFFFFF);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey900 = Color(0xFF212121);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _openOnboarding);
  }

  void _openOnboarding() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.25,
            colors: [AppColors.teal400, AppColors.teal600, AppColors.teal900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.print_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'GoPrint',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    'Print & Administrasi Kampus',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Lottie.asset(
                    'assets/lottie/splash_print.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Upload file dari mana saja',
      description:
          'Kirim dokumen tugas, laporan, atau materi kuliah langsung dari ponsel.',
      illustration: UploadFileIllustration(),
    ),
    OnboardingSlideData(
      title: 'Harga transparan otomatis',
      description:
          'Atur jumlah halaman, warna, kertas, dan finishing. Estimasi muncul seketika.',
      illustration: PriceCalculationIllustration(),
    ),
    OnboardingSlideData(
      title: 'Antar ke lokasi pilihanmu',
      description:
          'Pesanan siap dikirim ke kos, kelas, atau titik temu kampus yang kamu pilih.',
      illustration: DeliveryIllustration(),
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skip() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_isLastPage) {
      _start();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GetStartedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLastPage ? null : _skip,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingSlide(data: _slides[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              DotIndicator(length: _slides.length, activeIndex: _currentPage),
              const SizedBox(height: 28),
              GradientButton(
                label: _isLastPage ? 'Mulai Sekarang' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;
  final Widget illustration;
}

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({required this.data, super.key});

  final OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight < 560 ? 220 : 280,
                  child: Center(child: data.illustration),
                ),
                const SizedBox(height: 32),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey500,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    required this.length,
    required this.activeIndex,
    super.key,
  });

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal700 : AppColors.teal200,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.teal600, AppColors.teal900],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal700.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

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

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.print_rounded,
                  size: 72,
                  color: AppColors.teal700,
                ),
                const SizedBox(height: 20),
                Text(
                  'Siap mulai dengan GoPrint',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Halaman berikutnya akan terhubung ke autentikasi pada task A2.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
