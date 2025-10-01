import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users.dart';
import '../models/test_results.dart';
import '../models/reminders.dart';
import '../utils/network_utils.dart';
import '../utils/api_exception.dart';

class ApiClient {
  // Environment-based configuration
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');
  static String? _cachedBaseUrl;
  
  static Future<String> get baseUrl async {
    if (_isProduction) {
      // Production API URL - replace with your actual domain
      return 'https://api.healthtrack.com/api/v1';
    } else {
      // Cache the URL to avoid repeated network calls
      if (_cachedBaseUrl != null) return _cachedBaseUrl!;
      
      // Development URLs
      if (Platform.isAndroid) {
        _cachedBaseUrl = 'http://10.0.2.2:8000/api/v1';  // Android emulator
      } else if (Platform.isIOS) {
        // Dynamically get local IP for iOS simulator
        final localIP = await NetworkUtils.getLocalIP();
        _cachedBaseUrl = 'http://$localIP:8000/api/v1';
      } else {
        _cachedBaseUrl = 'http://localhost:8000/api/v1';  // Fallback
      }
      
      return _cachedBaseUrl!;
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

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}