import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack_mobile/src/models/shares.dart';

void main() {
  group('Share Model Tests', () {
    test('should create Share from valid JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
        'patient_id': '789e0123-e89b-12d3-a456-426614174002',
        'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
        'date_shared': '2024-01-15T10:30:00Z',
        'is_active': true,
        'test_result_title': 'Complete Blood Count',
        'caregiver_name': 'Dr. Jane Smith',
        'caregiver_license_type': 'MD',
        'caregiver_license_number': 'MD123456',
        'caregiver_license_verified': true,
      };

      final share = Share.fromJson(json);

      expect(share.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(share.testResultId, '456e7890-e89b-12d3-a456-426614174001');
      expect(share.patientId, '789e0123-e89b-12d3-a456-426614174002');
      expect(share.caregiverId, '999e8888-e89b-12d3-a456-426614174003');
      expect(share.dateShared, DateTime.parse('2024-01-15T10:30:00Z'));
      expect(share.isActive, true);
      expect(share.testResultTitle, 'Complete Blood Count');
      expect(share.caregiverName, 'Dr. Jane Smith');
      expect(share.caregiverLicenseType, 'MD');
      expect(share.caregiverLicenseNumber, 'MD123456');
      expect(share.caregiverLicenseVerified, true);
    });

    test('should handle null optional fields', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
        'patient_id': '789e0123-e89b-12d3-a456-426614174002',
        'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
        'date_shared': '2024-01-15T10:30:00Z',
        'is_active': true,
        'test_result_title': 'Blood Test',
        'caregiver_name': 'John Caregiver',
        'caregiver_license_type': null,
        'caregiver_license_number': null,
        'caregiver_license_verified': null,
      };

      final share = Share.fromJson(json);

      expect(share.caregiverLicenseType, null);
      expect(share.caregiverLicenseNumber, null);
      expect(share.caregiverLicenseVerified, null);
      expect(share.caregiverName, 'John Caregiver');
      expect(share.testResultTitle, 'Blood Test');
    });

    test('should handle different license types', () {
      final licenseTypes = ['MD', 'RN', 'NP', 'PA', 'DO', 'PharmD'];

      for (final licenseType in licenseTypes) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
          'patient_id': '789e0123-e89b-12d3-a456-426614174002',
          'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
          'date_shared': '2024-01-15T10:30:00Z',
          'is_active': true,
          'test_result_title': 'Test Result',
          'caregiver_name': 'Healthcare Provider',
          'caregiver_license_type': licenseType,
          'caregiver_license_number': '${licenseType}123456',
          'caregiver_license_verified': true,
        };

        final share = Share.fromJson(json);
        expect(share.caregiverLicenseType, licenseType);
        expect(share.caregiverLicenseNumber, '${licenseType}123456');
      }
    });

    test('should handle license verification status', () {
      final verificationStatuses = [true, false, null];

      for (final status in verificationStatuses) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
          'patient_id': '789e0123-e89b-12d3-a456-426614174002',
          'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
          'date_shared': '2024-01-15T10:30:00Z',
          'is_active': true,
          'test_result_title': 'Test Result',
          'caregiver_name': 'Healthcare Provider',
          'caregiver_license_type': 'MD',
          'caregiver_license_number': 'MD123456',
          'caregiver_license_verified': status,
        };

        final share = Share.fromJson(json);
        expect(share.caregiverLicenseVerified, status);
      }
    });

    test('should handle active/inactive shares', () {
      final activeStatuses = [true, false];

      for (final isActive in activeStatuses) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
          'patient_id': '789e0123-e89b-12d3-a456-426614174002',
          'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
          'date_shared': '2024-01-15T10:30:00Z',
          'is_active': isActive,
          'test_result_title': 'Test Result',
          'caregiver_name': 'Healthcare Provider',
          'caregiver_license_type': 'MD',
          'caregiver_license_number': 'MD123456',
          'caregiver_license_verified': true,
        };

        final share = Share.fromJson(json);
        expect(share.isActive, isActive);
      }
    });
  });

  group('ShareCreate Model Tests', () {
    test('should convert ShareCreate to JSON', () {
      final shareCreate = ShareCreate(
        testResultId: '456e7890-e89b-12d3-a456-426614174001',
        caregiverEmail: 'doctor@hospital.com',
      );

      final json = shareCreate.toJson();

      expect(json['test_result_id'], '456e7890-e89b-12d3-a456-426614174001');
      expect(json['caregiver_email'], 'doctor@hospital.com');
    });

    test('should validate required fields', () {
      expect(() => ShareCreate(
        testResultId: '456e7890-e89b-12d3-a456-426614174001',
        caregiverEmail: 'doctor@hospital.com',
      ), returnsNormally);
    });

    test('should handle different email formats', () {
      final emailFormats = [
        'doctor@hospital.com',
        'nurse.practitioner@clinic.org',
        'physician+specialist@medical.center.edu',
        'caregiver123@healthcare.net',
      ];

      for (final email in emailFormats) {
        final shareCreate = ShareCreate(
          testResultId: '456e7890-e89b-12d3-a456-426614174001',
          caregiverEmail: email,
        );

        final json = shareCreate.toJson();
        expect(json['caregiver_email'], email);
      }
    });

    test('should handle different test result ID formats', () {
      final testResultIds = [
        '456e7890-e89b-12d3-a456-426614174001',
        'test-result-123',
        'TR_2024_001',
        '12345678-1234-1234-1234-123456789012',
      ];

      for (final testResultId in testResultIds) {
        final shareCreate = ShareCreate(
          testResultId: testResultId,
          caregiverEmail: 'doctor@hospital.com',
        );

        final json = shareCreate.toJson();
        expect(json['test_result_id'], testResultId);
      }
    });
  });

  group('Share Date Parsing Tests', () {
    test('should parse different date formats', () {
      final dateFormats = [
        '2024-01-15T10:30:00Z',
        '2024-01-15T10:30:00.000Z',
        '2024-01-15T10:30:00+00:00',
        '2024-01-15T10:30:00-05:00',
      ];

      for (final dateStr in dateFormats) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
          'patient_id': '789e0123-e89b-12d3-a456-426614174002',
          'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
          'date_shared': dateStr,
          'is_active': true,
          'test_result_title': 'Test Result',
          'caregiver_name': 'Healthcare Provider',
          'caregiver_license_type': 'MD',
          'caregiver_license_number': 'MD123456',
          'caregiver_license_verified': true,
        };

        final share = Share.fromJson(json);
        expect(share.dateShared, isA<DateTime>());
      }
    });

    test('should handle recent and old share dates', () {
      final now = DateTime.now();
      final recentDate = now.subtract(const Duration(hours: 1));
      final oldDate = now.subtract(const Duration(days: 365));

      final dates = [recentDate, oldDate];

      for (final date in dates) {
        final json = {
          'id': '123e4567-e89b-12d3-a456-426614174000',
          'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
          'patient_id': '789e0123-e89b-12d3-a456-426614174002',
          'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
          'date_shared': date.toIso8601String(),
          'is_active': true,
          'test_result_title': 'Test Result',
          'caregiver_name': 'Healthcare Provider',
          'caregiver_license_type': 'MD',
          'caregiver_license_number': 'MD123456',
          'caregiver_license_verified': true,
        };

        final share = Share.fromJson(json);
        expect(share.dateShared.year, date.year);
        expect(share.dateShared.month, date.month);
        expect(share.dateShared.day, date.day);
      }
    });
  });

  group('Share Integration Tests', () {
    test('should handle complete sharing workflow data', () {
      // Simulate a complete sharing workflow
      final shareRequest = ShareCreate(
        testResultId: '456e7890-e89b-12d3-a456-426614174001',
        caregiverEmail: 'cardiologist@heart.clinic',
      );

      final requestJson = shareRequest.toJson();
      expect(requestJson['test_result_id'], '456e7890-e89b-12d3-a456-426614174001');
      expect(requestJson['caregiver_email'], 'cardiologist@heart.clinic');

      // Simulate API response after sharing
      final shareResponse = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
        'patient_id': '789e0123-e89b-12d3-a456-426614174002',
        'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
        'date_shared': '2024-01-15T10:30:00Z',
        'is_active': true,
        'test_result_title': 'Cardiac Stress Test',
        'caregiver_name': 'Dr. Sarah Johnson',
        'caregiver_license_type': 'MD',
        'caregiver_license_number': 'MD789012',
        'caregiver_license_verified': true,
      };

      final share = Share.fromJson(shareResponse);
      expect(share.testResultId, requestJson['test_result_id']);
      expect(share.testResultTitle, 'Cardiac Stress Test');
      expect(share.caregiverName, 'Dr. Sarah Johnson');
      expect(share.isActive, true);
    });

    test('should handle sharing with unverified caregiver', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
        'patient_id': '789e0123-e89b-12d3-a456-426614174002',
        'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
        'date_shared': '2024-01-15T10:30:00Z',
        'is_active': true,
        'test_result_title': 'Blood Test',
        'caregiver_name': 'Unverified Caregiver',
        'caregiver_license_type': 'RN',
        'caregiver_license_number': 'RN456789',
        'caregiver_license_verified': false,
      };

      final share = Share.fromJson(json);
      expect(share.caregiverLicenseVerified, false);
      expect(share.caregiverName, 'Unverified Caregiver');
      expect(share.isActive, true); // Share can still be active even if unverified
    });

    test('should handle revoked shares', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'test_result_id': '456e7890-e89b-12d3-a456-426614174001',
        'patient_id': '789e0123-e89b-12d3-a456-426614174002',
        'caregiver_id': '999e8888-e89b-12d3-a456-426614174003',
        'date_shared': '2024-01-10T10:30:00Z',
        'is_active': false, // Share has been revoked
        'test_result_title': 'X-Ray Results',
        'caregiver_name': 'Dr. Former Access',
        'caregiver_license_type': 'MD',
        'caregiver_license_number': 'MD111222',
        'caregiver_license_verified': true,
      };

      final share = Share.fromJson(json);
      expect(share.isActive, false);
      expect(share.caregiverName, 'Dr. Former Access');
      expect(share.testResultTitle, 'X-Ray Results');
    });
  });
}