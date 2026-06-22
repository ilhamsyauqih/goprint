import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goprint/features/auth/presentation/screens/login_screen.dart';
import 'package:goprint/features/super_admin/presentation/screens/super_admin_shop_detail_screen.dart';
import 'package:goprint/features/shop/data/mock_shops.dart';
import 'package:goprint/domain/repositories/auth_repository.dart';
import 'package:goprint/data/repositories/auth_repository_impl.dart';
import 'package:goprint/data/models/user_model.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) return 200;
    if (invocation.memberName == #contentLength) return transparentImage.length;
    if (invocation.memberName == #compressionState) {
      return HttpClientResponseCompressionState.notCompressed;
    }
    if (invocation.memberName == #headers) return MockHttpHeaders();
    if (invocation.memberName == #isRedirect) return false;
    if (invocation.memberName == #redirects) return <RedirectInfo>[];
    return null;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final List<int> transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class FakeAuthRepository implements AuthRepository {
  bool signInCalled = false;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    signInCalled = true;
    lastEmail = email;
    lastPassword = password;
    return UserModel(
      id: 'mock-user-id',
      name: 'Mock User',
      phone: '0812345678',
      role: 'user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'user',
    String? shopName,
    String? shopAddress,
    String? gmapsLink,
    String? nibFilePath,
    String? ktpFilePath,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeAuthRepository fakeAuthRepository;

  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
  });

  Widget createLoginTestWidget(GoRouter router) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuthRepository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('Shop Admin credentials route to /admin/dashboard', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const Scaffold(body: Text('Admin Dashboard Page')),
        ),
      ],
    );

    await tester.pumpWidget(createLoginTestWidget(router));
    await tester.pumpAndSettle();

    // Enter Shop 1 credentials
    await tester.enterText(find.byType(TextField).at(0), 'admin.suryagemilang@goprint.id');
    await tester.enterText(find.byType(TextField).at(1), 'SuryaGP@2026');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify redirection
    expect(find.text('Admin Dashboard Page'), findsOneWidget);
    expect(fakeAuthRepository.signInCalled, isFalse); // Should route mock shop credentials without calling supabase
  });

  testWidgets('Super Admin credentials route to /superadmin/dashboard', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/superadmin/dashboard',
          builder: (context, state) => const Scaffold(body: Text('Super Admin Dashboard Page')),
        ),
      ],
    );

    await tester.pumpWidget(createLoginTestWidget(router));
    await tester.pumpAndSettle();

    // Enter Super Admin credentials
    await tester.enterText(find.byType(TextField).at(0), 'superadmin@goprint.id');
    await tester.enterText(find.byType(TextField).at(1), 'SuperAdmin@2026');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify redirection
    expect(find.text('Super Admin Dashboard Page'), findsOneWidget);
    expect(fakeAuthRepository.signInCalled, isFalse); // Should route mock super admin credentials without calling supabase
  });

  testWidgets('General user credentials call AuthRepository.signIn and go to /home', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home Page')),
        ),
      ],
    );

    await tester.pumpWidget(createLoginTestWidget(router));
    await tester.pumpAndSettle();

    // Enter normal credentials
    await tester.enterText(find.byType(TextField).at(0), 'user@goprint.id');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify authentication is triggered
    expect(fakeAuthRepository.signInCalled, isTrue);
    expect(fakeAuthRepository.lastEmail, 'user@goprint.id');
    expect(fakeAuthRepository.lastPassword, 'password123');
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('SuperAdminShopDetailScreen displays shop admin credentials card', (WidgetTester tester) async {
    // We can test SuperAdminShopDetailScreen directly
    await tester.pumpWidget(
      const MaterialApp(
        home: SuperAdminShopDetailScreen(shopId: '1'),
      ),
    );
    await tester.pumpAndSettle();

    // Check credentials card is present
    expect(find.text('Kredensial Admin Toko'), findsOneWidget);
    expect(find.text('admin.suryagemilang@goprint.id'), findsOneWidget);
    expect(find.byIcon(Icons.key_rounded), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsAtLeast(1));
    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
  });
}
