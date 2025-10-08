import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users.dart';
import '../models/test_results.dart';
import '../models/reminders.dart';
import '../models/labs.dart';
import '../models/analytics.dart';
import '../models/shares.dart';
import '../utils/network_utils.dart';
import '../utils/api_exception.dart';

class ApiClient {
  // Environment-based configuration
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');
  static String? _cachedBaseUrl;
  static const String _productionUrl = 'https://healthtrack-api.onrender.com/api/v1';
  
  static Future<String> get baseUrl async {
    if (_isProduction) {
      return _productionUrl;
    } else {
      // Cache the URL to avoid repeated network calls
      if (_cachedBaseUrl != null) return _cachedBaseUrl!;
      
      // Try local development first, fallback to production
      String localUrl;
      if (Platform.isAndroid) {
        localUrl = 'http://10.0.2.2:8000/api/v1';
      } else if (Platform.isIOS) {
        final localIP = await NetworkUtils.getLocalIP();
        localUrl = 'http://$localIP:8000/api/v1';
      } else {
        localUrl = 'http://localhost:8000/api/v1';
      }
      
      // Test if local API is available
      if (await _isApiAvailable(localUrl)) {
        print('✅ Using local development API: $localUrl');
        _cachedBaseUrl = localUrl;
      } else {
        print('⚠️ Local API unavailable, falling back to production: $_productionUrl');
        _cachedBaseUrl = _productionUrl;
      }
      
      return _cachedBaseUrl!;
    }
  }
  
  static Future<bool> _isApiAvailable(String baseUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  String? _token;

  // Auth endpoints
  Future<Token> login(UserLogin loginData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        print('Login response: $responseData'); // Debug log
        final token = Token.fromJson(responseData);
        _token = token.accessToken;
        await _saveToken(token.accessToken);
        return token;
      } catch (e) {
        print('Error parsing login response: $e');
        print('Response body: ${response.body}');
        throw Exception('Failed to parse login response: $e');
      }
    } else {
      // Extract user-friendly error message
      String errorMessage = 'Login failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {
        // If JSON parsing fails, use default message
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> register(UserCreate userData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Extract user-friendly error message
      String errorMessage = 'Registration failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {
        // If JSON parsing fails, use default message
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> registerPatient(PatientCreate patientData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/register/patient'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(patientData.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Patient registration failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> registerCaregiver(CaregiverCreate caregiverData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/register/caregiver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(caregiverData.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Caregiver registration failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> getCurrentUser() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/auth/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        print('User response: $responseData'); // Debug log
        return User.fromJson(responseData);
      } catch (e) {
        print('Error parsing user response: $e');
        print('Response body: ${response.body}');
        throw Exception('Failed to parse user response: $e');
      }
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  // Test Results endpoints
  Future<List<TestResult>> getTestResults() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/test-results'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TestResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get test results: ${response.body}');
    }
  }

  Future<TestResult> getTestResult(String id) async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/test-results/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return TestResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get test result: ${response.body}');
    }
  }

  // Reminders endpoints
  Future<List<Reminder>> getReminders({bool includeCompleted = false}) async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/reminders?include_completed=$includeCompleted'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get reminders: ${response.body}');
    }
  }

  Future<Reminder> createReminder(ReminderCreate reminderData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/reminders'),
      headers: await _getHeaders(),
      body: jsonEncode(reminderData.toJson()),
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  Future<Reminder> updateReminder(String id, ReminderUpdate updateData) async {
    final url = await baseUrl;
    final response = await http.put(
      Uri.parse('$url/reminders/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(updateData.toJson()),
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  Future<void> deleteReminder(String id) async {
    final url = await baseUrl;
    final response = await http.delete(
      Uri.parse('$url/reminders/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }

  Future<Reminder> markReminderCompleted(String id) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/reminders/$id/complete'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to mark reminder as completed: ${response.body}');
    }
  }

  // Admin endpoints
  Future<List<Lab>> getPendingLabs() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/auth/admin/labs/pending'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lab.fromJson(json)).toList();
    } else {
      String errorMessage = 'Failed to get pending labs';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<Lab> updateLabStatus(String labId, String status) async {
    final url = await baseUrl;
    final response = await http.put(
      Uri.parse('$url/auth/admin/labs/$labId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return Lab.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to update lab status';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<List<User>> getInactiveUsers() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/auth/admin/users/inactive'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      String errorMessage = 'Failed to get inactive users';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> updateUserStatus(String userId, bool isActive) async {
    final url = await baseUrl;
    final response = await http.put(
      Uri.parse('$url/auth/admin/users/$userId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'is_active': isActive}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to update user status';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<User> verifyCaregiverLicense(String userId) async {
    final url = await baseUrl;
    final response = await http.put(
      Uri.parse('$url/auth/admin/caregivers/$userId/verify-license'),
      headers: await _getHeaders(),
      body: jsonEncode({'license_verified': true}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to verify caregiver license';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<Map<String, dynamic>> registerLab(LabRegistrationRequest labData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/register/lab'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(labData.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'Lab registration failed';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<SystemAnalytics> getSystemAnalytics() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/auth/admin/analytics'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return SystemAnalytics.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to get system analytics';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  // Test Results upload endpoint
  Future<TestResult> uploadTestResult(TestResultCreate testData, {File? file}) async {
    final url = await baseUrl;
    
    if (file != null) {
      // Multipart request for file upload
      final request = http.MultipartRequest('POST', Uri.parse('$url/test-results'));
      
      // Add headers
      final token = _token ?? await _getStoredToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add form fields
      request.fields['patient_email'] = testData.patientEmail;
      request.fields['title'] = testData.title;
      request.fields['date_taken'] = testData.dateTaken.toUtc().toIso8601String();
      request.fields['status'] = testData.status;
      request.fields['summary_text'] = testData.summaryText;
      
      // Debug logging
      print('Sending multipart request with fields:');
      print('patient_email: ${testData.patientEmail}');
      print('title: ${testData.title}');
      print('date_taken: ${testData.dateTaken.toUtc().toIso8601String()}');
      print('status: ${testData.status}');
      print('summary_text: ${testData.summaryText}');
      print('file: ${file.path}');
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TestResult.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = 'Upload failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (e) {}
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } else {
      // Regular JSON request without file
      final response = await http.post(
        Uri.parse('$url/test-results'),
        headers: await _getHeaders(),
        body: jsonEncode(testData.toJson()),
      );

      if (response.statusCode == 201) {
        return TestResult.fromJson(jsonDecode(response.body));
      } else {
        String errorMessage = 'Upload failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'];
          }
        } catch (e) {}
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    }
  }

  // Helper methods
  Future<Map<String, String>> _getHeaders() async {
    final token = _token ?? await _getStoredToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Sharing methods
  Future<Share> shareTestResult(ShareCreate shareData) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/sharing'),
      headers: await _getHeaders(),
      body: jsonEncode(shareData.toJson()),
    );

    if (response.statusCode == 200) {
      return Share.fromJson(jsonDecode(response.body));
    } else {
      String errorMessage = 'Failed to share test result';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<List<TestResult>> getSharedResults() async {
    final url = await baseUrl;
    print('[DEBUG] Getting shared results from: $url/sharing/shared-with-me');
    
    final response = await http.get(
      Uri.parse('$url/sharing/shared-with-me'),
      headers: await _getHeaders(),
    );

    print('[DEBUG] Shared results response status: ${response.statusCode}');
    print('[DEBUG] Shared results response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('[DEBUG] Found ${data.length} shared results');
      return data.map((json) => TestResult.fromJson(json)).toList();
    } else {
      String errorMessage = 'Failed to get shared results';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<List<Share>> getMyShares() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/sharing/my-shares'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Share.fromJson(json)).toList();
    } else {
      String errorMessage = 'Failed to get sharing history';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<void> revokeShare(String shareId) async {
    final url = await baseUrl;
    final response = await http.delete(
      Uri.parse('$url/sharing/$shareId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      String errorMessage = 'Failed to revoke share';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] != null) {
          errorMessage = errorData['detail'];
        }
      } catch (e) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}