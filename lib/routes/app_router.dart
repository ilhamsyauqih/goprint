import 'package:go_router/go_router.dart';

import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/main/presentation/main_layout.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/templates/presentation/screens/template_list_screen.dart';

/// Konfigurasi routing GoPrint — semua route user & admin.
///
/// Menggunakan [StatefulShellRoute.indexedStack] untuk bottom navigation
/// agar state setiap tab tetap terjaga saat berpindah tab.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // ─── Pre-auth routes ─────────────────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ─── Auth routes ─────────────────────────────────────────────
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ─── Main app — Bottom Navigation (User) ────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 1 — Pesanan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderListScreen(),
            ),
          ],
        ),

        // Tab 2 — Template
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/templates',
              builder: (context, state) => const TemplateListScreen(),
            ),
          ],
        ),

        // Tab 3 — Notifikasi
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),

        // Tab 4 — Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ─── Admin routes ────────────────────────────────────────────
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    // Placeholder routes — akan ditambahkan saat fitur admin diimplementasikan:
    // GoRoute(path: '/admin/orders', ...),
    // GoRoute(path: '/admin/orders/:id', ...),
    // GoRoute(path: '/admin/services', ...),
    // GoRoute(path: '/admin/shop-profile', ...),
    // GoRoute(path: '/admin/reports', ...),
  ],
);
