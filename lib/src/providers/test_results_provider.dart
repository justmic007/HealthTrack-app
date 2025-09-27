import 'package:flutter/foundation.dart';
import '../models/test_results.dart';
import '../data/api_client.dart';

class TestResultsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<TestResult> _testResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TestResult> get testResults => _testResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all test results
  Future<void> loadTestResults() async {
    _setLoading(true);
    _clearError();

    try {
      _testResults = await _apiClient.getTestResults();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Get single test result
  Future<TestResult?> getTestResult(String id) async {
    try {
      return await _apiClient.getTestResult(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Refresh test results
  Future<void> refreshTestResults() async {
    await loadTestResults();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}