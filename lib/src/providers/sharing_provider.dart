import 'package:flutter/foundation.dart';
import '../models/shares.dart';
import '../models/test_results.dart';
import '../data/api_client.dart';

class SharingProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<TestResult> _sharedResults = [];
  List<Share> _myShares = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<TestResult> get sharedResults => _sharedResults;
  List<Share> get myShares => _myShares;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Share a test result with a caregiver
  Future<Share> shareTestResult(String testResultId, String caregiverEmail) async {
    _clearError();

    try {
      final shareData = ShareCreate(
        testResultId: testResultId,
        caregiverEmail: caregiverEmail,
      );
      
      final share = await _apiClient.shareTestResult(shareData);
      return share;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Load shared results (for caregivers)
  Future<void> loadSharedResults() async {
    print('[DEBUG] SharingProvider: Loading shared results...');
    _setLoading(true);
    _clearError();

    try {
      _sharedResults = await _apiClient.getSharedResults();
      print('[DEBUG] SharingProvider: Loaded ${_sharedResults.length} shared results');
      _setLoading(false);
    } catch (e) {
      print('[DEBUG] SharingProvider: Error loading shared results: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load my shares (for patients)
  Future<void> loadMyShares() async {
    _setLoading(true);
    _clearError();

    try {
      _myShares = await _apiClient.getMyShares();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Revoke a share
  Future<void> revokeShare(String shareId) async {
    _clearError();

    try {
      await _apiClient.revokeShare(shareId);
      // Remove from local list
      _myShares.removeWhere((share) => share.id == shareId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
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