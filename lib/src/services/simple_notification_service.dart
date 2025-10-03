class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  // Store scheduled reminders for reference
  final Map<int, Map<String, dynamic>> _scheduledReminders = {};

  Future<void> initialize() async {
    print('✅ Simple notification service initialized');
    print('📱 Note: For real push notifications, enable flutter_local_notifications');
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // Store reminder info
    _scheduledReminders[id] = {
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
    };
    
    final timeUntil = scheduledDate.difference(DateTime.now());
    print('⏰ Reminder scheduled: "$title"');
    print('📅 Due: $scheduledDate');
    print('⏳ Time until due: ${_formatDuration(timeUntil)}');
    print('💡 Tip: Check the app regularly or enable push notifications for alerts');
  }

  Future<void> cancelNotification(int id) async {
    _scheduledReminders.remove(id);
    print('❌ Reminder $id cancelled');
  }

  Future<void> cancelAllNotifications() async {
    _scheduledReminders.clear();
    print('🗑️ All reminders cancelled');
  }

  // Get upcoming reminders for display
  List<Map<String, dynamic>> getUpcomingReminders() {
    final now = DateTime.now();
    return _scheduledReminders.values
        .where((reminder) => (reminder['scheduledDate'] as DateTime).isAfter(now))
        .toList()
      ..sort((a, b) => (a['scheduledDate'] as DateTime)
          .compareTo(b['scheduledDate'] as DateTime));
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days, ${duration.inHours % 24} hours';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours, ${duration.inMinutes % 60} minutes';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    } else {
      return 'Less than a minute';
    }
  }
}