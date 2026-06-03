import 'package:flutter_test/flutter_test.dart';

import 'package:goprint/app.dart';
import 'package:goprint/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('GoPrintApp starts with SplashScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoPrintApp());

    expect(find.text('GoPrint'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
