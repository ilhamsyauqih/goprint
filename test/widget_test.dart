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
import 'package:goprint/features/templates/data/mock_templates.dart';
import 'package:goprint/features/templates/data/template_store.dart';
import 'package:goprint/features/templates/presentation/screens/template_detail_screen.dart';
import 'package:goprint/features/templates/presentation/screens/template_list_screen.dart';
import 'package:goprint/features/templates/presentation/widgets/template_category_chip.dart';
import 'package:goprint/shared/widgets/custom_bottom_nav_bar.dart';

void main() {
  setUp(() {
    notificationStore.reset();
    profileStore.reset();
    appStateStore.reset();
    templateStore.reset();
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

  // ─── I6 · Template Dokumen ───────────────────────────────────────────

  testWidgets('TemplateListScreen menampilkan search bar dan category chips', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TemplateListScreen()));
    await tester.pump();

    // Search bar harus ada
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cari template...'), findsOneWidget);

    // Chip "Semua" harus ada dan terpilih secara default
    expect(find.byType(TemplateCategoryChip), findsWidgets);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Surat Izin'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);
  });

  testWidgets('TemplateListScreen filter kategori mengubah daftar template', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TemplateListScreen()));
    await tester.pump();

    // Pilih kategori "Cover"
    await tester.tap(find.text('Cover'));
    await tester.pump();

    expect(templateStore.selectedCategory, equals('Cover'));
    final coverTemplates = templateStore.filteredTemplates;
    for (final tpl in coverTemplates) {
      expect(tpl.category, equals('Cover'));
    }
  });

  testWidgets(
    'TemplateListScreen menampilkan empty state saat pencarian tidak ditemukan',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TemplateListScreen()));
      await tester.pump();

      // Ketik query yang tidak ada hasilnya
      await tester.enterText(
        find.byType(TextField),
        'xyzabcnotexist',
      );
      await tester.pump();

      expect(find.text('Template tidak ditemukan'), findsAtLeast(1));
      expect(
        find.text(
          'Coba kata kunci lain atau pilih kategori yang berbeda.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'TemplateListScreen pencarian memfilter template berdasarkan nama',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TemplateListScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Skripsi');
      await tester.pump();

      final results = templateStore.filteredTemplates;
      expect(results, isNotEmpty);
      for (final tpl in results) {
        final matchesName = tpl.name.toLowerCase().contains('skripsi');
        final matchesDesc = tpl.description.toLowerCase().contains('skripsi');
        expect(matchesName || matchesDesc, isTrue);
      }
    },
  );

  testWidgets('TemplateStore reset mengembalikan kategori ke Semua', (
    WidgetTester tester,
  ) async {
    templateStore.selectCategory('Proposal');
    expect(templateStore.selectedCategory, equals('Proposal'));

    templateStore.reset();
    expect(templateStore.selectedCategory, equals('Semua'));
    expect(templateStore.searchQuery, isEmpty);
  });

  testWidgets('TemplateDetailScreen menampilkan nama dan tombol download', (
    WidgetTester tester,
  ) async {
    const tpl = TemplateItem(
      id: 'test-001',
      name: 'Cover Skripsi / Tugas Akhir',
      category: 'Cover',
      description: 'Template cover skripsi sesuai standar tata naskah akademik.',
      fileUrl: 'https://example.com/file.docx',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      downloadCount: 5102,
      rating: 4.8,
      createdAt: '2026-01-03',
    );

    await tester.pumpWidget(
      const MaterialApp(home: TemplateDetailScreen(template: tpl)),
    );
    await tester.pump();

    // Nama template tampil
    expect(find.text('Cover Skripsi / Tugas Akhir'), findsAtLeast(1));

    // Tombol download DOCX & PDF
    expect(find.text('Download DOCX'), findsOneWidget);
    expect(find.text('Download PDF'), findsOneWidget);

    // Deskripsi
    expect(
      find.text('Template cover skripsi sesuai standar tata naskah akademik.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'TemplateDetailScreen tap Download PDF menampilkan snackbar sukses',
    (WidgetTester tester) async {
      const tpl = TemplateItem(
        id: 'test-002',
        name: 'Surat Izin Tidak Masuk',
        category: 'Surat Izin',
        description: 'Template surat izin resmi.',
        fileUrl: 'https://example.com/file.docx',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        downloadCount: 1200,
        rating: 4.5,
        createdAt: '2026-01-10',
      );

      await tester.pumpWidget(
        const MaterialApp(home: TemplateDetailScreen(template: tpl)),
      );
      await tester.pump();

      // Tap tombol Download PDF
      await tester.tap(find.text('Download PDF'));
      // Tunggu simulasi unduhan (2 detik)
      await tester.pump(const Duration(milliseconds: 100));
      // Loading indicator harus muncul (PDF button)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesai
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(
        find.text('Template berhasil diunduh (PDF)'),
        findsOneWidget,
      );
    },
  );

  testWidgets('MockTemplates.formatDownloadCount format dengan benar', (
    WidgetTester tester,
  ) async {
    expect(MockTemplates.formatDownloadCount(500), equals('500'));
    expect(MockTemplates.formatDownloadCount(1000), equals('1k'));
    expect(MockTemplates.formatDownloadCount(1200), equals('1.2k'));
    expect(MockTemplates.formatDownloadCount(5102), equals('5.1k'));
  });
}
