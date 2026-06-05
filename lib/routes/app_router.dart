import 'package:go_router/go_router.dart';

import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/main/presentation/main_layout.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/orders/presentation/screens/delivery_pick_screen.dart';
import '../features/orders/presentation/screens/file_config_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/orders/presentation/screens/order_success_screen.dart';
import '../features/orders/presentation/screens/order_summary_screen.dart';
import '../features/orders/presentation/screens/payment_screen.dart';
import '../features/orders/presentation/screens/price_calculator_screen.dart';
import '../features/orders/presentation/screens/select_service_screen.dart';
import '../features/orders/presentation/screens/upload_file_screen.dart';
import '../features/orders/presentation/screens/write_review_screen.dart';
import '../features/profile/presentation/screens/add_address_screen.dart';
import '../features/profile/presentation/screens/address_list_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/shop/presentation/screens/shop_detail_screen.dart';
import '../features/shop/presentation/screens/shop_list_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/templates/data/mock_templates.dart';
import '../features/templates/presentation/screens/template_detail_screen.dart';
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
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
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

    // ─── Shop routes ─────────────────────────────────────────────
    GoRoute(
      path: '/shops',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return ShopListScreen(preselectedCategory: category);
      },
    ),
    GoRoute(
      path: '/shop/:id',
      builder: (context, state) {
        final shopId = state.pathParameters['id'] ?? '1';
        return ShopDetailScreen(shopId: shopId);
      },
    ),

    // ─── Order Flow routes ───────────────────────────────────────
    GoRoute(
      path: '/order/select-service/:shopId',
      builder: (context, state) {
        final shopId = state.pathParameters['shopId'] ?? '1';
        return SelectServiceScreen(shopId: shopId);
      },
    ),
    GoRoute(
      path: '/order/upload',
      builder: (context, state) => const UploadFileScreen(),
    ),
    GoRoute(
      path: '/order/config',
      builder: (context, state) => const FileConfigScreen(),
    ),
    GoRoute(
      path: '/order/price-calculator',
      builder: (context, state) => const PriceCalculatorScreen(),
    ),
    GoRoute(
      path: '/order/delivery',
      builder: (context, state) => const DeliveryPickScreen(),
    ),
    GoRoute(
      path: '/order/summary',
      builder: (context, state) => const OrderSummaryScreen(),
    ),
    GoRoute(
      path: '/order/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    GoRoute(
      path: '/order/success',
      builder: (context, state) => const OrderSuccessScreen(),
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
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return OrderDetailScreen(orderId: id);
                  },
                ),
                GoRoute(
                  path: 'review/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return WriteReviewScreen(orderId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 2 — Template
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/templates',
              builder: (context, state) => const TemplateListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    // Ambil object TemplateItem yang di-pass via GoRouter `extra`
                    final tpl = state.extra as TemplateItem?;
                    if (tpl != null) {
                      return TemplateDetailScreen(template: tpl);
                    }
                    // Fallback: cari berdasarkan id jika extra kosong
                    final id = state.pathParameters['id'] ?? '';
                    final found = MockTemplates.templates.where(
                      (t) => t.id == id,
                    );
                    if (found.isNotEmpty) {
                      return TemplateDetailScreen(template: found.first);
                    }
                    return const TemplateListScreen();
                  },
                ),
              ],
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
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const AddressListScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (context, state) => const AddAddressScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
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
