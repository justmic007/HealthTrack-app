import 'package:flutter/foundation.dart';
import '../data/api_client.dart';
import '../models/labs.dart';
import '../models/users.dart';
import '../models/analytics.dart';

class AdminProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Lab> _pendingLabs = [];
  List<User> _inactiveUsers = [];
  SystemAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  List<Lab> get pendingLabs => _pendingLabs;
  List<User> get inactiveUsers => _inactiveUsers;
  SystemAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPendingLabs() async {
    _setLoading(true);
    try {
      _pendingLabs = await _apiClient.getPendingLabs();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading pending labs: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllData() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadPendingLabs(),
        loadInactiveUsers(),
        loadAnalytics(),
      ]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInactiveUsers() async {
    _setLoading(true);
    try {
      _inactiveUsers = await _apiClient.getInactiveUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading inactive users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAnalytics() async {
    _setLoading(true);
    try {
      _analytics = await _apiClient.getSystemAnalytics();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading analytics: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> approveLab(String labId) async {
    try {
      await _apiClient.updateLabStatus(labId, 'approved');
      // Remove from pending list
      _pendingLabs.removeWhere((lab) => lab.id == labId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectLab(String labId) async {
    try {
      await _apiClient.updateLabStatus(labId, 'rejected');
      // Remove from pending list
      _pendingLabs.removeWhere((lab) => lab.id == labId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateUser(String userId) async {
    try {
      await _apiClient.updateUserStatus(userId, true);
      // Remove from inactive list
      _inactiveUsers.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser(String userId) async {
    try {
      await _apiClient.updateUserStatus(userId, false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}