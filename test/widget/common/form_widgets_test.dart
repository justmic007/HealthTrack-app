import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Common Form Widget Tests', () {
    
    group('TextFormField Tests', () {
      testWidgets('displays label and hint text correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('validation works correctly', (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
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

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.text('This field is required'), findsOneWidget);
      });

      testWidgets('obscure text works for password fields', (WidgetTester tester) async {
        bool obscureText = true;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => TextFormField(
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureText = !obscureText),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.visibility), findsOneWidget);

        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });
    });

    group('ElevatedButton Tests', () {
      testWidgets('displays text and handles tap', (WidgetTester tester) async {
        bool buttonPressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () => buttonPressed = true,
                child: const Text('Submit'),
              ),
            ),
          ),
        );

        expect(find.text('Submit'), findsOneWidget);
        
        await tester.tap(find.byType(ElevatedButton));
        expect(buttonPressed, true);
      });

      testWidgets('shows loading state correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: null, // Disabled state
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('Card Widget Tests', () {
      testWidgets('displays content correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Card Title'),
                      const SizedBox(height: 8),
                      const Text('Card content goes here'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Card Title'), findsOneWidget);
        expect(find.text('Card content goes here'), findsOneWidget);
      });

      testWidgets('handles tap events with InkWell', (WidgetTester tester) async {
        bool cardTapped = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: InkWell(
                  onTap: () => cardTapped = true,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tappable Card'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tappable Card'));
        expect(cardTapped, true);
      });
    });

    group('ListTile Tests', () {
      testWidgets('displays title, subtitle, and icons', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('John Doe'),
                subtitle: const Text('Software Developer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Software Developer'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('handles tap events', (WidgetTester tester) async {
        bool tileTapped = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListTile(
                title: const Text('Tappable Tile'),
                onTap: () => tileTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        expect(tileTapped, true);
      });
    });

    group('FloatingActionButton Tests', () {
      testWidgets('displays icon and handles tap', (WidgetTester tester) async {
        bool fabPressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(),
              floatingActionButton: FloatingActionButton(
                onPressed: () => fabPressed = true,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        
        await tester.tap(find.byType(FloatingActionButton));
        expect(fabPressed, true);
      });

      testWidgets('extended FAB displays label and icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
              ),
            ),
          ),
        );

        expect(find.text('Upload'), findsOneWidget);
        expect(find.byIcon(Icons.upload), findsOneWidget);
      });
    });
  });
}