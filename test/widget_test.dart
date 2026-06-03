import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:goprint/main.dart';

void main() {
  testWidgets('shows splash then opens onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoPrintApp());

    expect(find.text('GoPrint'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Upload file dari mana saja'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('onboarding reaches final slide and starts app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Harga transparan otomatis'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Antar ke lokasi pilihanmu'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();
    expect(find.byType(GetStartedScreen), findsOneWidget);
  });
}
