import 'package:flutter/foundation.dart';
import '../models/reminders.dart';
import '../data/api_client.dart';
import '../services/platform_notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get upcoming reminders (not completed)
  List<Reminder> get upcomingReminders => _reminders
      .where((r) => !r.isCompleted && r.isActive)
      .toList()
    ..sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));

  // Load reminders
  Future<void> loadReminders({bool includeCompleted = false}) async {
    _setLoading(true);
    _clearError();

    try {
      _reminders = await _apiClient.getReminders(includeCompleted: includeCompleted);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Create reminder
  Future<Reminder> createReminder(ReminderCreate reminderData) async {
    _clearError();

    try {
      final reminder = await _apiClient.createReminder(reminderData);
      _reminders.add(reminder);
      
      // Schedule local notification
      await _scheduleNotification(reminder);
      
      notifyListeners();
      return reminder;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Update reminder
  Future<Reminder> updateReminder(String id, ReminderUpdate updateData) async {
    _clearError();

    try {
      final updatedReminder = await _apiClient.updateReminder(id, updateData);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
        notifyListeners();
      }
      return updatedReminder;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Delete reminder
  Future<void> deleteReminder(String id) async {
    _clearError();

    try {
      await _apiClient.deleteReminder(id);
      
      // Cancel local notification
      await PlatformNotificationService().cancelNotification(id.hashCode);
      
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Mark reminder as completed
  Future<void> markCompleted(String id) async {
    _clearError();

    try {
      // Use the dedicated completion endpoint
      await _apiClient.markReminderCompleted(id);
      
      // Reload reminders to get updated state
      await loadReminders();
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

  // Schedule local notification for reminder
  Future<void> _scheduleNotification(Reminder reminder) async {
    if (reminder.dueDateTime.isAfter(DateTime.now())) {
      await PlatformNotificationService().scheduleReminder(
        id: reminder.id.hashCode,
        title: reminder.title,
        body: reminder.description ?? 'Health reminder',
        scheduledDate: reminder.dueDateTime,
        payload: reminder.id,
      );
    }
  }
}