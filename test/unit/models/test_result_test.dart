import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack_mobile/src/models/test_results.dart';

void main() {
  group('TestResult Model Tests', () {
    test('should create TestResult from valid JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'patient_id': '456e7890-e89b-12d3-a456-426614174001',
        'lab_id': '789e0123-e89b-12d3-a456-426614174002',
        'title': 'Complete Blood Count',
        'date_taken': '2024-01-15T10:00:00Z',
        'date_uploaded': '2024-01-15T11:00:00Z',
        'file_url': 'https://example.com/file.pdf',
        'status': 'normal',
        'summary_text': 'All values within normal range',
        'raw_data': {'WBC': 5.2, 'RBC': 4.7, 'Hemoglobin': 14.5},
        'lab_name': 'Test Lab',
        'patient_name': 'John Doe',
        'patient_email': 'john@example.com',
        'test_type': 'blood',
        'wellness_score': 85,
        'additional_notes': 'Follow up in 6 months',
        'uploaded_by': '999e8888-e89b-12d3-a456-426614174003',
        'uploader_name': 'Lab Tech',
      };

      final testResult = TestResult.fromJson(json);

      expect(testResult.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(testResult.patientId, '456e7890-e89b-12d3-a456-426614174001');
      expect(testResult.labId, '789e0123-e89b-12d3-a456-426614174002');
      expect(testResult.title, 'Complete Blood Count');
      expect(testResult.dateTaken, DateTime.parse('2024-01-15T10:00:00Z'));
      expect(testResult.dateUploaded, DateTime.parse('2024-01-15T11:00:00Z'));
      expect(testResult.fileUrl, 'https://example.com/file.pdf');
      expect(testResult.status, 'normal');
      expect(testResult.summaryText, 'All values within normal range');
      expect(testResult.rawData, {'WBC': 5.2, 'RBC': 4.7, 'Hemoglobin': 14.5});
      expect(testResult.labName, 'Test Lab');
      expect(testResult.patientName, 'John Doe');
      expect(testResult.patientEmail, 'john@example.com');
      expect(testResult.testType, 'blood');
      expect(testResult.wellnessScore, 85);
      expect(testResult.additionalNotes, 'Follow up in 6 months');
      expect(testResult.uploadedBy, '999e8888-e89b-12d3-a456-426614174003');
      expect(testResult.uploaderName, 'Lab Tech');
    });

    test('should handle null optional fields', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'patient_id': '456e7890-e89b-12d3-a456-426614174001',
        'lab_id': '789e0123-e89b-12d3-a456-426614174002',
        'title': 'Blood Test',
        'date_taken': '2024-01-15T10:00:00Z',
        'date_uploaded': '2024-01-15T11:00:00Z',
        'status': 'normal',
      };

      final testResult = TestResult.fromJson(json);

      expect(testResult.fileUrl, null);
      expect(testResult.summaryText, null);
      expect(testResult.rawData, null);
      expect(testResult.labName, null);
      expect(testResult.patientName, null);
      expect(testResult.patientEmail, null);
      expect(testResult.testType, null);
      expect(testResult.wellnessScore, null);
      expect(testResult.additionalNotes, null);
      expect(testResult.uploadedBy, null);
      expect(testResult.uploaderName, null);
    });

    test('should parse complex raw_data JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'patient_id': '456e7890-e89b-12d3-a456-426614174001',
        'lab_id': '789e0123-e89b-12d3-a456-426614174002',
        'title': 'Comprehensive Metabolic Panel',
        'date_taken': '2024-01-15T10:00:00Z',
        'date_uploaded': '2024-01-15T11:00:00Z',
        'status': 'abnormal',
        'raw_data': {
          'glucose': 110,
          'bun': 15,
          'creatinine': 1.0,
          'sodium': 140,
          'potassium': 4.0,
          'chloride': 102,
          'co2': 24,
          'ranges': {
            'glucose': '70-100 mg/dL',
            'bun': '7-20 mg/dL'
          }
        },
      };

      final testResult = TestResult.fromJson(json);

      expect(testResult.rawData!['glucose'], 110);
      expect(testResult.rawData!['ranges']['glucose'], '70-100 mg/dL');
      expect(testResult.status, 'abnormal');
    });
  });

  group('TestResultCreate Model Tests', () {
    test('should convert TestResultCreate to JSON', () {
      final testResultCreate = TestResultCreate(
        patientEmail: 'patient@example.com',
        title: 'Blood Test',
        dateTaken: DateTime.parse('2024-01-15T10:00:00Z'),
        status: 'normal',
        summaryText: 'All normal values',
        rawData: {'glucose': 95, 'cholesterol': 180},
      );

      final json = testResultCreate.toJson();

      expect(json['patient_email'], 'patient@example.com');
      expect(json['title'], 'Blood Test');
      expect(json['date_taken'], '2024-01-15T10:00:00.000Z');
      expect(json['status'], 'normal');
      expect(json['summary_text'], 'All normal values');
      expect(json['raw_data'], {'glucose': 95, 'cholesterol': 180});
    });

    test('should handle null raw_data', () {
      final testResultCreate = TestResultCreate(
        patientEmail: 'patient@example.com',
        title: 'Basic Test',
        dateTaken: DateTime.parse('2024-01-15T10:00:00Z'),
        status: 'normal',
        summaryText: 'Basic summary',
      );

      final json = testResultCreate.toJson();

      expect(json['raw_data'], null);
      expect(json.containsKey('raw_data'), true);
    });

    test('should validate required fields', () {
      expect(() => TestResultCreate(
        patientEmail: '',
        title: 'Test',
        dateTaken: DateTime.now(),
        status: 'normal',
        summaryText: 'Summary',
      ), returnsNormally);
    });
  });

  group('TestResult Status Tests', () {
    test('should handle different status values', () {
      final statuses = ['normal', 'abnormal', 'borderline', 'pending'];
      
      for (final status in statuses) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'patient_id': '456e7890-e89b-12d3-a456-426614174001',
          'lab_id': '789e0123-e89b-12d3-a456-426614174002',
          'title': 'Test',
          'date_taken': '2024-01-15T10:00:00Z',
          'date_uploaded': '2024-01-15T11:00:00Z',
          'status': status,
        };

        final testResult = TestResult.fromJson(json);
        expect(testResult.status, status);
      }
    });
  });

  group('TestResult Date Parsing Tests', () {
    test('should parse different date formats', () {
      final dateFormats = [
        '2024-01-15T10:00:00Z',
        '2024-01-15T10:00:00.000Z',
        '2024-01-15T10:00:00+00:00',
      ];

      for (final dateStr in dateFormats) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'patient_id': '456e7890-e89b-12d3-a456-426614174001',
          'lab_id': '789e0123-e89b-12d3-a456-426614174002',
          'title': 'Test',
          'date_taken': dateStr,
          'date_uploaded': dateStr,
          'status': 'normal',
        };

        final testResult = TestResult.fromJson(json);
        expect(testResult.dateTaken, isA<DateTime>());
        expect(testResult.dateUploaded, isA<DateTime>());
      }
    });
  });
}