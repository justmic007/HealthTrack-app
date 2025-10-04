import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack_mobile/src/models/reminders.dart';

void main() {
  group('Reminder Model Tests', () {
    test('should create Reminder from valid JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'user_id': '456e7890-e89b-12d3-a456-426614174001',
        'test_result_id': '789e0123-e89b-12d3-a456-426614174002',
        'reminder_type': 'medication',
        'title': 'Take Blood Pressure Medication',
        'description': 'Take 1 tablet of Lisinopril 10mg',
        'due_datetime': '2024-01-15T08:00:00Z',
        'recurrence_type': 'daily',
        'recurrence_data': {'interval': 1, 'time': '08:00'},
        'is_completed': false,
        'is_active': true,
        'created_at': '2024-01-10T10:00:00Z',
        'updated_at': '2024-01-10T10:00:00Z',
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(reminder.userId, '456e7890-e89b-12d3-a456-426614174001');
      expect(reminder.testResultId, '789e0123-e89b-12d3-a456-426614174002');
      expect(reminder.reminderType, 'medication');
      expect(reminder.title, 'Take Blood Pressure Medication');
      expect(reminder.description, 'Take 1 tablet of Lisinopril 10mg');
      expect(reminder.dueDateTime, DateTime.parse('2024-01-15T08:00:00Z'));
      expect(reminder.recurrenceType, 'daily');
      expect(reminder.recurrenceData, {'interval': 1, 'time': '08:00'});
      expect(reminder.isCompleted, false);
      expect(reminder.isActive, true);
      expect(reminder.createdAt, DateTime.parse('2024-01-10T10:00:00Z'));
      expect(reminder.updatedAt, DateTime.parse('2024-01-10T10:00:00Z'));
    });

    test('should handle null optional fields', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'user_id': '456e7890-e89b-12d3-a456-426614174001',
        'test_result_id': null,
        'reminder_type': 'appointment',
        'title': 'Doctor Appointment',
        'description': null,
        'due_datetime': '2024-01-20T14:00:00Z',
        'recurrence_type': 'none',
        'recurrence_data': null,
        'is_completed': false,
        'is_active': true,
        'created_at': '2024-01-10T10:00:00Z',
        'updated_at': '2024-01-10T10:00:00Z',
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.testResultId, null);
      expect(reminder.description, null);
      expect(reminder.recurrenceData, null);
      expect(reminder.reminderType, 'appointment');
      expect(reminder.recurrenceType, 'none');
    });

    test('should parse complex recurrence data', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'user_id': '456e7890-e89b-12d3-a456-426614174001',
        'test_result_id': null,
        'reminder_type': 'medication',
        'title': 'Weekly Medication',
        'description': 'Take weekly injection',
        'due_datetime': '2024-01-15T09:00:00Z',
        'recurrence_type': 'weekly',
        'recurrence_data': {
          'interval': 1,
          'days_of_week': [1, 3, 5], // Monday, Wednesday, Friday
          'time': '09:00',
          'end_date': '2024-12-31'
        },
        'is_completed': false,
        'is_active': true,
        'created_at': '2024-01-10T10:00:00Z',
        'updated_at': '2024-01-10T10:00:00Z',
      };

      final reminder = Reminder.fromJson(json);

      expect(reminder.recurrenceData!['interval'], 1);
      expect(reminder.recurrenceData!['days_of_week'], [1, 3, 5]);
      expect(reminder.recurrenceData!['time'], '09:00');
      expect(reminder.recurrenceData!['end_date'], '2024-12-31');
    });
  });

  group('ReminderCreate Model Tests', () {
    test('should convert ReminderCreate to JSON with all fields', () {
      final reminderCreate = ReminderCreate(
        testResultId: '789e0123-e89b-12d3-a456-426614174002',
        reminderType: 'medication',
        title: 'Morning Medication',
        description: 'Take diabetes medication',
        dueDateTime: DateTime.parse('2024-01-15T08:00:00Z'),
        recurrenceType: 'daily',
        recurrenceData: {'interval': 1, 'time': '08:00'},
      );

      final json = reminderCreate.toJson();

      expect(json['test_result_id'], '789e0123-e89b-12d3-a456-426614174002');
      expect(json['reminder_type'], 'medication');
      expect(json['title'], 'Morning Medication');
      expect(json['description'], 'Take diabetes medication');
      expect(json['due_datetime'], '2024-01-15T08:00:00.000Z');
      expect(json['recurrence_type'], 'daily');
      expect(json['recurrence_data'], {'interval': 1, 'time': '08:00'});
    });

    test('should handle null optional fields', () {
      final reminderCreate = ReminderCreate(
        reminderType: 'appointment',
        title: 'Doctor Visit',
        dueDateTime: DateTime.parse('2024-01-20T14:00:00Z'),
        recurrenceType: 'none',
      );

      final json = reminderCreate.toJson();

      expect(json['test_result_id'], null);
      expect(json['description'], null);
      expect(json['recurrence_data'], null);
      expect(json['reminder_type'], 'appointment');
      expect(json['title'], 'Doctor Visit');
      expect(json['recurrence_type'], 'none');
    });

    test('should format datetime correctly for API', () {
      final dueDateTime = DateTime.utc(2024, 1, 15, 8, 30, 0);
      final reminderCreate = ReminderCreate(
        reminderType: 'medication',
        title: 'Test Reminder',
        dueDateTime: dueDateTime,
        recurrenceType: 'daily',
      );

      final json = reminderCreate.toJson();
      final formattedDate = json['due_datetime'] as String;

      expect(formattedDate, contains('2024-01-15'));
      expect(formattedDate, contains('T'));
      expect(formattedDate, contains('08:30:00'));
    });
  });

  group('ReminderUpdate Model Tests', () {
    test('should convert ReminderUpdate to JSON with all fields', () {
      final reminderUpdate = ReminderUpdate(
        title: 'Updated Reminder Title',
        description: 'Updated description',
        dueDateTime: DateTime.parse('2024-01-16T09:00:00Z'),
        recurrenceType: 'weekly',
        recurrenceData: {'interval': 2, 'days_of_week': [1, 4]},
      );

      final json = reminderUpdate.toJson();

      expect(json['title'], 'Updated Reminder Title');
      expect(json['description'], 'Updated description');
      expect(json['due_datetime'], '2024-01-16T09:00:00.000Z');
      expect(json['recurrence_type'], 'weekly');
      expect(json['recurrence_data'], {'interval': 2, 'days_of_week': [1, 4]});
    });

    test('should only include non-null fields in JSON', () {
      final reminderUpdate = ReminderUpdate(
        title: 'New Title',
        recurrenceType: 'monthly',
      );

      final json = reminderUpdate.toJson();

      expect(json.containsKey('title'), true);
      expect(json.containsKey('recurrence_type'), true);
      expect(json.containsKey('description'), false);
      expect(json.containsKey('due_datetime'), false);
      expect(json.containsKey('recurrence_data'), false);
      expect(json['title'], 'New Title');
      expect(json['recurrence_type'], 'monthly');
    });

    test('should handle empty update (no fields)', () {
      final reminderUpdate = ReminderUpdate();

      final json = reminderUpdate.toJson();

      expect(json.isEmpty, true);
    });

    test('should handle partial updates correctly', () {
      final reminderUpdate = ReminderUpdate(
        description: 'Only updating description',
      );

      final json = reminderUpdate.toJson();

      expect(json.length, 1);
      expect(json['description'], 'Only updating description');
    });
  });

  group('Reminder Types and Recurrence Tests', () {
    test('should handle different reminder types', () {
      final reminderTypes = ['medication', 'appointment', 'test', 'follow_up'];

      for (final type in reminderTypes) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '456e7890-e89b-12d3-a456-426614174001',
          'test_result_id': null,
          'reminder_type': type,
          'title': 'Test Reminder',
          'description': null,
          'due_datetime': '2024-01-15T08:00:00Z',
          'recurrence_type': 'none',
          'recurrence_data': null,
          'is_completed': false,
          'is_active': true,
          'created_at': '2024-01-10T10:00:00Z',
          'updated_at': '2024-01-10T10:00:00Z',
        };

        final reminder = Reminder.fromJson(json);
        expect(reminder.reminderType, type);
      }
    });

    test('should handle different recurrence types', () {
      final recurrenceTypes = ['none', 'daily', 'weekly', 'monthly'];

      for (final type in recurrenceTypes) {
        final reminderCreate = ReminderCreate(
          reminderType: 'medication',
          title: 'Test Reminder',
          dueDateTime: DateTime.now(),
          recurrenceType: type,
        );

        final json = reminderCreate.toJson();
        expect(json['recurrence_type'], type);
      }
    });

    test('should handle boolean flags correctly', () {
      final testCases = [
        {'is_completed': true, 'is_active': true},
        {'is_completed': false, 'is_active': true},
        {'is_completed': true, 'is_active': false},
        {'is_completed': false, 'is_active': false},
      ];

      for (final testCase in testCases) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '456e7890-e89b-12d3-a456-426614174001',
          'test_result_id': null,
          'reminder_type': 'medication',
          'title': 'Test Reminder',
          'description': null,
          'due_datetime': '2024-01-15T08:00:00Z',
          'recurrence_type': 'none',
          'recurrence_data': null,
          'is_completed': testCase['is_completed'],
          'is_active': testCase['is_active'],
          'created_at': '2024-01-10T10:00:00Z',
          'updated_at': '2024-01-10T10:00:00Z',
        };

        final reminder = Reminder.fromJson(json);
        expect(reminder.isCompleted, testCase['is_completed']);
        expect(reminder.isActive, testCase['is_active']);
      }
    });
  });

  group('Reminder Date Parsing Tests', () {
    test('should parse different datetime formats', () {
      final dateFormats = [
        '2024-01-15T08:00:00Z',
        '2024-01-15T08:00:00.000Z',
        '2024-01-15T08:00:00+00:00',
      ];

      for (final dateStr in dateFormats) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'user_id': '456e7890-e89b-12d3-a456-426614174001',
          'test_result_id': null,
          'reminder_type': 'medication',
          'title': 'Test Reminder',
          'description': null,
          'due_datetime': dateStr,
          'recurrence_type': 'none',
          'recurrence_data': null,
          'is_completed': false,
          'is_active': true,
          'created_at': dateStr,
          'updated_at': dateStr,
        };

        final reminder = Reminder.fromJson(json);
        expect(reminder.dueDateTime, isA<DateTime>());
        expect(reminder.createdAt, isA<DateTime>());
        expect(reminder.updatedAt, isA<DateTime>());
      }
    });
  });
}