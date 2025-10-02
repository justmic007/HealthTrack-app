import 'package:flutter/foundation.dart';
import '../models/users.dart';
import '../models/labs.dart';
import '../data/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginData = UserLogin(email: email, password: password);
      await _apiClient.login(loginData);
      
      // Get user data after successful login
      _currentUser = await _apiClient.getCurrentUser();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(String email, String password, String fullName, {String? phoneNumber}) async {
    _setLoading(true);
    _clearError();

    try {
      final userData = UserCreate(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      
      await _apiClient.register(userData);
      
      // Auto-login after registration
      return await login(email, password);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register Patient
  Future<bool> registerPatient(PatientCreate patientData) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiClient.registerPatient(patientData);
      
      // Auto-login after registration
      return await login(patientData.email, patientData.password);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register Caregiver
  Future<bool> registerCaregiver(CaregiverCreate caregiverData) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiClient.registerCaregiver(caregiverData);
      
      // Don't auto-login for caregivers since they need admin approval
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register Lab
  Future<bool> registerLab(LabRegistrationRequest labData) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiClient.registerLab(labData);
      
      // Don't auto-login for labs since they need admin approval
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiClient.logout();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // Check if user is already logged in (on app start)
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      _currentUser = await _apiClient.getCurrentUser();
    } catch (e) {
      // User not authenticated or token expired
      _currentUser = null;
    }
    
    _setLoading(false);
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