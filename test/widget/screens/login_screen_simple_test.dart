import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:healthtrack_mobile/src/screens/login_screen.dart';
import 'package:healthtrack_mobile/src/providers/auth_provider.dart';
import '../mocks/mock_auth_provider.dart';

void main() {
  group('LoginScreen Simple Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.errorMessage).thenReturn(null);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('displays app title and form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('HealthTrack'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays login button and register link', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('email field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Test empty email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('password field validation works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final visibilityToggle = find.byIcon(Icons.visibility);

      // Initially should show visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('shows loading state when authenticating', (WidgetTester tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final loginButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(loginButton.onPressed, isNull); // Button should be disabled
    });

    testWidgets('shows error message when login fails', (WidgetTester tester) async {
      when(mockAuthProvider.errorMessage).thenReturn('Invalid credentials');

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Invalid credentials'), findsOneWidget);
      
      final errorText = tester.widget<Text>(find.text('Invalid credentials'));
      expect(errorText.style?.color, Colors.red);
    });

    testWidgets('form fields have correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('has correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check app title styling
      final titleText = tester.widget<Text>(find.text('HealthTrack'));
      expect(titleText.style?.fontSize, 32);
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.color, Colors.blue);

      // Check form layout
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}