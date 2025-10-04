import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Interface Tests', () {
    testWidgets('material design components work', (WidgetTester tester) async {
      // Test basic Material Design components
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Column(
              children: [
                Text('Hello World'),
                ElevatedButton(onPressed: null, child: Text('Button')),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('layout widgets function correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Layout Test'),
                    const SizedBox(height: 16),
                    Container(height: 50, color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('icons and cards display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Person'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: const Text('Medical'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('loading indicators work', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Disabled Button'),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('text widgets display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Subtitle', style: TextStyle(fontSize: 16)),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Input Field'),
                ),
              ],
            ),
          ),
        ),
      );
      
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      expect(find.text('Input Field'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('form validation displays errors', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) => value?.isEmpty == true ? 'Required field' : null,
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
      
      await tester.tap(find.text('Validate'));
      await tester.pump();
      
      expect(find.text('Required field'), findsOneWidget);
    });
  });
}