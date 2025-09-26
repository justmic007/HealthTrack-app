import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/users.dart';
import '../models/test_results.dart';
import '../models/reminders.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  String? _token;

  // Auth endpoints
  Future<Token> login(UserLogin loginData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData.toJson()),
    );

    if (response.statusCode == 200) {
      final token = Token.fromJson(jsonDecode(response.body));
      _token = token.accessToken;
      await _saveToken(token.accessToken);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<User> register(UserCreate userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  // Test Results endpoints
  Future<List<TestResult>> getTestResults() async {
    final response = await http.get(
      Uri.parse('$baseUrl/test-results'),
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
    final response = await http.get(
      Uri.parse('$baseUrl/test-results/$id'),
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
    final response = await http.get(
      Uri.parse('$baseUrl/reminders?include_completed=$includeCompleted'),
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
    final response = await http.post(
      Uri.parse('$baseUrl/reminders'),
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
    final response = await http.put(
      Uri.parse('$baseUrl/reminders/$id'),
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
    final response = await http.delete(
      Uri.parse('$baseUrl/reminders/$id'),
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