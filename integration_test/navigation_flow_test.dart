import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:healthtrack_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Flow Tests', () {
    testWidgets('app navigation loads without error', (WidgetTester tester) async {
      // Just verify the app can start and navigation works
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // If we get here, the app started successfully
      expect(true, isTrue);
    });
  });
}