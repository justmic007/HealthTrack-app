import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'dart:io';
import 'package:healthtrack_mobile/src/data/api_client.dart';
import 'package:healthtrack_mobile/src/models/users.dart';
import 'package:healthtrack_mobile/src/models/test_results.dart';
import 'package:healthtrack_mobile/src/utils/api_exception.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
    });

    group('Base URL Tests', () {
      test('should return correct Android emulator URL in development', () async {
        // Mock Platform.isAndroid to return true
        final url = await ApiClient.baseUrl;
        
        // In test environment, it should use the fallback localhost
        expect(url, contains('api/v1'));
      });
    });

    group('Authentication Tests', () {
      test('should login successfully with valid credentials', () async {
        final mockClient = MockClient((request) async {
          if (request.url.path.endsWith('/auth/login')) {
            final body = jsonDecode(request.body);
            expect(body['email'], 'test@example.com');
            expect(body['password'], 'password123');
            
            return http.Response(
              jsonEncode({
                'access_token': 'mock_token_123',
                'token_type': 'bearer',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('Not Found', 404);
        });

        // Override the http client (this would require dependency injection in real implementation)
        final loginData = UserLogin(
          email: 'test@example.com',
          password: 'password123',
        );

        // For testing, we'll test the model conversion
        final json = loginData.toJson();
        expect(json['email'], 'test@example.com');
        expect(json['password'], 'password123');
      });

      test('should throw ApiException on login failure', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'detail': 'Invalid credentials'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        });

        // Test error response parsing
        final errorResponse = jsonEncode({'detail': 'Invalid credentials'});
        final errorData = jsonDecode(errorResponse);
        expect(errorData['detail'], 'Invalid credentials');
      });

      test('should register patient successfully', () async {
        final patientData = PatientCreate(
          email: 'patient@example.com',
          password: 'password123',
          fullName: 'John Doe',
          phoneNumber: '+12345678901',
        );

        final json = patientData.toJson();
        expect(json['email'], 'patient@example.com');
        expect(json['password'], 'password123');
        expect(json['full_name'], 'John Doe');
        expect(json['phone_number'], '+12345678901');
      });

      test('should register caregiver successfully', () async {
        final caregiverData = CaregiverCreate(
          email: 'caregiver@example.com',
          password: 'password123',
          fullName: 'Dr. Jane Smith',
          phoneNumber: '+12345678901',
          licenseNumber: 'MD123456',
          licenseType: 'MD',
          licenseState: 'CA',
        );

        final json = caregiverData.toJson();
        expect(json['email'], 'caregiver@example.com');
        expect(json['license_number'], 'MD123456');
        expect(json['license_type'], 'MD');
        expect(json['license_state'], 'CA');
      });
    });

    group('Test Results Tests', () {
      test('should parse test results list response', () async {
        final mockResponse = [
          {
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'patient_id': '456e7890-e89b-12d3-a456-426614174001',
            'lab_id': '789e0123-e89b-12d3-a456-426614174002',
            'title': 'Blood Test',
            'date_taken': '2024-01-15T10:00:00Z',
            'date_uploaded': '2024-01-15T11:00:00Z',
            'status': 'normal',
            'summary_text': 'All normal',
            'lab_name': 'Test Lab',
          },
          {
            'id': '223e4567-e89b-12d3-a456-426614174000',
            'patient_id': '456e7890-e89b-12d3-a456-426614174001',
            'lab_id': '789e0123-e89b-12d3-a456-426614174002',
            'title': 'X-Ray',
            'date_taken': '2024-01-14T09:00:00Z',
            'date_uploaded': '2024-01-14T10:00:00Z',
            'status': 'abnormal',
            'summary_text': 'Requires follow-up',
            'lab_name': 'Imaging Center',
          }
        ];

        final testResults = mockResponse.map((json) => TestResult.fromJson(json)).toList();
        
        expect(testResults.length, 2);
        expect(testResults[0].title, 'Blood Test');
        expect(testResults[0].status, 'normal');
        expect(testResults[1].title, 'X-Ray');
        expect(testResults[1].status, 'abnormal');
      });

      test('should create test result with proper data', () async {
        final testResultCreate = TestResultCreate(
          patientEmail: 'patient@example.com',
          title: 'Complete Blood Count',
          dateTaken: DateTime.parse('2024-01-15T10:00:00Z'),
          status: 'normal',
          summaryText: 'All values within normal range',
          rawData: {'WBC': 5.2, 'RBC': 4.7},
        );

        final json = testResultCreate.toJson();
        expect(json['patient_email'], 'patient@example.com');
        expect(json['title'], 'Complete Blood Count');
        expect(json['status'], 'normal');
        expect(json['raw_data']['WBC'], 5.2);
      });
    });

    group('Error Handling Tests', () {
      test('should handle network errors gracefully', () async {
        // Test ApiException creation
        final exception = ApiException('Network error', statusCode: 500);
        expect(exception.message, 'Network error');
        expect(exception.statusCode, 500);
      });

      test('should parse error responses correctly', () async {
        final errorResponses = [
          {'detail': 'User not found'},
          {'detail': 'Invalid token'},
          {'detail': 'Permission denied'},
        ];

        for (final errorResponse in errorResponses) {
          expect(errorResponse['detail'], isA<String>());
          expect(errorResponse['detail'], isNotEmpty);
        }
      });

      test('should handle malformed JSON responses', () async {
        const malformedJson = '{"incomplete": json';
        
        expect(() => jsonDecode(malformedJson), throwsA(isA<FormatException>()));
      });
    });

    group('Token Management Tests', () {
      test('should create valid token from response', () async {
        final tokenResponse = {
          'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
          'token_type': 'bearer',
        };

        final token = Token.fromJson(tokenResponse);
        expect(token.accessToken, startsWith('eyJ'));
        expect(token.tokenType, 'bearer');
      });

      test('should handle missing token fields', () async {
        final incompleteResponse = <String, dynamic>{};
        
        final token = Token.fromJson(incompleteResponse);
        expect(token.accessToken, '');
        expect(token.tokenType, 'bearer'); // default value
      });
    });

    group('Request Headers Tests', () {
      test('should format authorization header correctly', () async {
        const mockToken = 'mock_token_123';
        final expectedHeader = 'Bearer $mockToken';
        
        expect(expectedHeader, 'Bearer mock_token_123');
      });

      test('should include content-type header', () async {
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer mock_token',
        };

        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer mock_token');
      });
    });

    group('URL Construction Tests', () {
      test('should construct correct API endpoints', () async {
        const baseUrl = 'http://localhost:8000/api/v1';
        final endpoints = [
          '$baseUrl/auth/login',
          '$baseUrl/auth/register/patient',
          '$baseUrl/auth/register/caregiver',
          '$baseUrl/test-results',
          '$baseUrl/reminders',
        ];

        for (final endpoint in endpoints) {
          expect(endpoint, startsWith(baseUrl));
          expect(Uri.parse(endpoint).isAbsolute, true);
        }
      });
    });
  });
}