import 'package:flutter_test/flutter_test.dart';
import 'package:healthtrack_mobile/src/models/users.dart';

void main() {
  group('User Model Tests', () {
    test('should create User from valid JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'user_type': 'patient',
        'phone_number': '+12345678901',
        'is_active': true,
        'created_at': '2024-01-15T10:00:00Z',
        'license_number': 'LIC123',
        'license_type': 'MD',
        'license_state': 'CA',
        'license_verified': true,
      };

      final user = User.fromJson(json);

      expect(user.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.userType, 'patient');
      expect(user.phoneNumber, '+12345678901');
      expect(user.isActive, true);
      expect(user.licenseNumber, 'LIC123');
      expect(user.licenseType, 'MD');
      expect(user.licenseState, 'CA');
      expect(user.licenseVerified, true);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'user_type': 'patient',
        'is_active': true,
        'created_at': '2024-01-15T10:00:00Z',
      };

      final user = User.fromJson(json);

      expect(user.phoneNumber, null);
      expect(user.licenseNumber, null);
      expect(user.licenseType, null);
      expect(user.licenseState, null);
      expect(user.licenseVerified, null);
    });

    test('should use default values for missing required fields', () {
      final json = <String, dynamic>{};

      final user = User.fromJson(json);

      expect(user.id, '');
      expect(user.email, '');
      expect(user.fullName, '');
      expect(user.userType, 'patient');
      expect(user.isActive, true);
    });

    test('should convert User to JSON correctly', () {
      final user = User(
        id: '123e4567-e89b-12d3-a456-426614174000',
        email: 'test@example.com',
        fullName: 'Test User',
        userType: 'patient',
        phoneNumber: '+12345678901',
        isActive: true,
        createdAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123e4567-e89b-12d3-a456-426614174000');
      expect(json['email'], 'test@example.com');
      expect(json['full_name'], 'Test User');
      expect(json['user_type'], 'patient');
      expect(json['phone_number'], '+12345678901');
      expect(json['is_active'], true);
      expect(json['created_at'], '2024-01-15T10:00:00.000Z');
    });
  });

  group('UserCreate Model Tests', () {
    test('should convert UserCreate to JSON with all fields', () {
      final userCreate = UserCreate(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        phoneNumber: '+12345678901',
        licenseNumber: 'LIC123',
        licenseType: 'MD',
        licenseState: 'CA',
      );

      final json = userCreate.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
      expect(json['full_name'], 'Test User');
      expect(json['phone_number'], '+12345678901');
      expect(json['license_number'], 'LIC123');
      expect(json['license_type'], 'MD');
      expect(json['license_state'], 'CA');
    });

    test('should exclude null license fields from JSON', () {
      final userCreate = UserCreate(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
      );

      final json = userCreate.toJson();

      expect(json.containsKey('license_number'), false);
      expect(json.containsKey('license_type'), false);
      expect(json.containsKey('license_state'), false);
    });
  });

  group('Token Model Tests', () {
    test('should create Token from valid JSON', () {
      final json = {
        'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'token_type': 'bearer',
      };

      final token = Token.fromJson(json);

      expect(token.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
      expect(token.tokenType, 'bearer');
    });

    test('should use default values for missing fields', () {
      final json = <String, dynamic>{};

      final token = Token.fromJson(json);

      expect(token.accessToken, '');
      expect(token.tokenType, 'bearer');
    });
  });

  group('UserLogin Model Tests', () {
    test('should convert UserLogin to JSON', () {
      final userLogin = UserLogin(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = userLogin.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });
  });
}