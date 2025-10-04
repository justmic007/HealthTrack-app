import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Form Validation Tests', () {
    testWidgets('email validation works', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('email'),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Please enter your email';
                      if (!value!.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState?.validate(),
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Test empty email
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);
      
      // Test invalid email
      await tester.enterText(find.byKey(const Key('email')), 'invalid-email');
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('password validation works', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    key: const Key('password'),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Please enter your password';
                      if (value!.length < 8) return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => formKey.currentState?.validate(),
                    child: const Text('Validate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Test empty password
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(find.text('Please enter your password'), findsOneWidget);
      
      // Test short password
      await tester.enterText(find.byKey(const Key('password')), '123');
      await tester.tap(find.text('Validate'));
      await tester.pump();
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('text input and focus works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('name'),
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  key: const Key('email'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Test text input
      await tester.enterText(find.byKey(const Key('name')), 'John Doe');
      await tester.enterText(find.byKey(const Key('email')), 'john@example.com');
      
      // Verify text was entered
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('dropdown widget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: null,
              hint: const Text('Select Option'),
              items: const [
                DropdownMenuItem(value: 'option1', child: Text('Option 1')),
                DropdownMenuItem(value: 'option2', child: Text('Option 2')),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      );
      
      // Should show hint text and dropdown widget
      expect(find.text('Select Option'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });
  });
}