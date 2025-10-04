import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:healthtrack_mobile/src/screens/home_screen.dart';
import 'package:healthtrack_mobile/src/providers/auth_provider.dart';
import 'package:healthtrack_mobile/src/models/users.dart';
import '../mocks/mock_auth_provider.dart';

void main() {
  group('HomeScreen Simple Widget Tests', () {
    late MockAuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      when(mockAuthProvider.currentUser).thenReturn(
        User(
          id: '1',
          email: 'test@example.com',
          fullName: 'John Doe',
          userType: 'patient',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow async operations to complete

      expect(find.text('HealthTrack - Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('displays search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Search tests or conditions...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays welcome message with user name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('Welcome John Doe!'), findsOneWidget);
    });

    testWidgets('displays health snapshot cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Your Health Snapshot'), findsOneWidget);
      expect(find.text('Active Alerts'), findsOneWidget);
      expect(find.text('Appointments'), findsOneWidget);
    });

    testWidgets('displays test results section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Your Recent Test Results'), findsOneWidget);
      expect(find.text('View All'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays reminders section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Upcoming Reminders'), findsOneWidget);
    });

    testWidgets('shows different content for caregiver users', (WidgetTester tester) async {
      when(mockAuthProvider.currentUser).thenReturn(
        User(
          id: '2',
          email: 'caregiver@example.com',
          fullName: 'Jane Smith',
          userType: 'caregiver',
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Shared Test Results'), findsOneWidget);
    });

    testWidgets('shows reminder FAB for non-lab users', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.add_alarm), findsOneWidget);
    });

    testWidgets('displays notification badge', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('3'), findsAtLeastNWidgets(1)); // Notification count
    });

    testWidgets('shows user initials in avatar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('JD'), findsOneWidget); // John Doe initials
    });

    testWidgets('displays current date', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should display current month and year
      final now = DateTime.now();
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                     'July', 'August', 'September', 'October', 'November', 'December'];
      final expectedDate = '${months[now.month - 1]} ${now.day}, ${now.year}';
      
      expect(find.text(expectedDate), findsOneWidget);
    });
  });
}