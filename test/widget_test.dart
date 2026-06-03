import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goprint/app.dart';
import 'package:goprint/features/profile/presentation/screens/add_address_screen.dart';
import 'package:goprint/features/profile/presentation/screens/change_password_screen.dart';
import 'package:goprint/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:goprint/features/profile/presentation/screens/profile_screen.dart';
import 'package:goprint/features/profile/presentation/screens/settings_screen.dart';
import 'package:goprint/features/splash/presentation/screens/splash_screen.dart';

void main() {
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

  testWidgets('AddAddressScreen validates address fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddAddressScreen()));

    await tester.tap(find.text('Simpan Alamat'));
    await tester.pump();

    expect(find.text('Field ini wajib diisi'), findsNWidgets(2));
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
}
