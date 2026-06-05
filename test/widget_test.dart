import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goprint/app.dart';
import 'package:goprint/core/state/app_state_store.dart';
import 'package:goprint/features/notifications/data/notification_store.dart';
import 'package:goprint/features/notifications/presentation/screens/notification_screen.dart';
import 'package:goprint/features/profile/data/profile_store.dart';
import 'package:goprint/features/profile/presentation/screens/add_address_screen.dart';
import 'package:goprint/features/profile/presentation/screens/address_list_screen.dart';
import 'package:goprint/features/profile/presentation/screens/change_password_screen.dart';
import 'package:goprint/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:goprint/features/profile/presentation/screens/profile_screen.dart';
import 'package:goprint/features/profile/presentation/screens/settings_screen.dart';
import 'package:goprint/features/splash/presentation/screens/splash_screen.dart';
import 'package:goprint/shared/widgets/custom_bottom_nav_bar.dart';

void main() {
  setUp(() {
    notificationStore.reset();
    profileStore.reset();
    appStateStore.reset();
  });

  testWidgets('GoPrintApp starts with SplashScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoPrintApp());

    expect(find.text('GoPrint'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('ProfileScreen shows user identity and profile menus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.text('Amir Mahendra'), findsOneWidget);
    expect(find.text('amir@goprint.id'), findsOneWidget);
    expect(find.text('0812-3456-7890'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Alamat Tersimpan'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Ubah Password'),
      180,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Ubah Password'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pengaturan'),
      180,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('EditProfileScreen validates required profile fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.enterText(find.byType(TextFormField).at(2), '');
    await tester.ensureVisible(find.text('Simpan Profil'));
    await tester.tap(find.text('Simpan Profil'));
    await tester.pump();

    expect(find.text('Field ini wajib diisi'), findsNWidgets(3));
  });

  testWidgets('EditProfileScreen updates ProfileScreen data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfileScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi Santoso');
    await tester.enterText(find.byType(TextFormField).at(1), '089999111222');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Kontrakan Mawar Blok B',
    );
    await tester.ensureVisible(find.text('Simpan Profil'));
    await tester.tap(find.text('Simpan Profil'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('089999111222'), findsOneWidget);
    expect(find.text('Kontrakan Mawar Blok B'), findsOneWidget);
  });

  testWidgets('AddAddressScreen validates address fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddAddressScreen()));

    await tester.tap(find.text('Simpan Alamat'));
    await tester.pump();

    expect(find.text('Field ini wajib diisi'), findsNWidgets(2));
  });

  testWidgets('AddressListScreen can change default address', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddressListScreen()));

    await tester.tap(find.byType(PopupMenuButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jadikan Default').last);
    await tester.pumpAndSettle();

    expect(
      profileStore.profile.primaryAddress,
      'Lobi utama, sebelah layanan akademik',
    );
  });

  testWidgets('ChangePasswordScreen validates confirmation password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'password123');
    await tester.enterText(find.byType(TextFormField).at(1), 'password456');
    await tester.enterText(find.byType(TextFormField).at(2), 'password789');
    await tester.ensureVisible(find.text('Simpan Password'));
    await tester.tap(find.text('Simpan Password'));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak sama'), findsOneWidget);
  });

  testWidgets('SettingsScreen exposes notification and theme controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    expect(find.text('Notifikasi Pesanan'), findsOneWidget);
    expect(find.text('Notifikasi Promo'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('SettingsScreen updates notification and theme state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    await tester.tap(find.byType(SwitchListTile).at(0));
    await tester.pump();
    expect(profileStore.orderNotifications, isFalse);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined).last);
    await tester.pump();
    expect(appStateStore.themeMode, ThemeMode.dark);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets(
    'NotificationScreen lists unread notifications and marks all read',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationScreen()));

      expect(find.text('2 notifikasi belum dibaca'), findsOneWidget);
      expect(find.text('Pesanan siap diantar'), findsOneWidget);
      expect(find.text('Pembayaran terverifikasi'), findsOneWidget);

      await tester.tap(find.text('Tandai Semua Dibaca'));
      await tester.pump();

      expect(find.text('Semua notifikasi sudah dibaca'), findsOneWidget);
      expect(find.text('Tandai Semua Dibaca'), findsNothing);
    },
  );

  testWidgets('NotificationScreen shows empty state', (
    WidgetTester tester,
  ) async {
    notificationStore.clear();

    await tester.pumpWidget(const MaterialApp(home: NotificationScreen()));

    expect(find.text('Belum ada notifikasi'), findsOneWidget);
    expect(
      find.text('Update pesanan, pembayaran, dan promo akan muncul di sini.'),
      findsOneWidget,
    );
  });

  testWidgets('CustomBottomNavBar shows unread notification badge', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);

    notificationStore.markAllAsRead();
    await tester.pump();

    expect(find.text('2'), findsNothing);
  });
}
