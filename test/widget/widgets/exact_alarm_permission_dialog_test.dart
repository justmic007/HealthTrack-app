import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack_mobile/src/widgets/exact_alarm_permission_dialog.dart';

void main() {
  group('ExactAlarmPermissionDialog Widget Tests', () {
    testWidgets('displays correct title and content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExactAlarmPermissionDialog(),
          ),
        ),
      );

      expect(find.text('Reminder Timing'), findsOneWidget);
      expect(find.text('Your reminder has been created successfully!'), findsOneWidget);
      expect(find.text('However, for the most accurate reminder timing, please enable "Schedule Exact Alarms" permission in your device settings.'), findsOneWidget);
      expect(find.text('Without this permission, reminders may be delayed by a few minutes.'), findsOneWidget);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExactAlarmPermissionDialog(),
          ),
        ),
      );

      expect(find.text('Maybe Later'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('maybe later button closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ExactAlarmPermissionDialog(),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ExactAlarmPermissionDialog), findsOneWidget);

      await tester.tap(find.text('Maybe Later'));
      await tester.pumpAndSettle();

      expect(find.byType(ExactAlarmPermissionDialog), findsNothing);
    });

    testWidgets('open settings button closes dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ExactAlarmPermissionDialog(),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(ExactAlarmPermissionDialog), findsOneWidget);

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(ExactAlarmPermissionDialog), findsNothing);
    });

    testWidgets('has correct widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExactAlarmPermissionDialog(),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('text styling is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExactAlarmPermissionDialog(),
          ),
        ),
      );

      final successText = tester.widget<Text>(
        find.text('Your reminder has been created successfully!')
      );
      expect(successText.style?.fontWeight, FontWeight.bold);

      final warningText = tester.widget<Text>(
        find.text('Without this permission, reminders may be delayed by a few minutes.')
      );
      expect(warningText.style?.fontSize, 12);
      expect(warningText.style?.color, Colors.grey);
    });
  });
}