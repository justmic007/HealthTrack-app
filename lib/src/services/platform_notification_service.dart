import 'dart:io';
import 'notification_service.dart';
import 'simple_notification_service.dart';

class PlatformNotificationService {
  static final PlatformNotificationService _instance = PlatformNotificationService._internal();
  factory PlatformNotificationService() => _instance;
  PlatformNotificationService._internal();

  late final dynamic _service;

  Future<void> initialize() async {
    // Use full notifications on both platforms
    _service = NotificationService();
    await _service.initialize();
    print('✅ Using full NotificationService on ${Platform.isIOS ? 'iOS' : 'Android'}');
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _service.scheduleReminder(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _service.cancelNotification(id);
  }

  Future<void> cancelAllNotifications() async {
    await _service.cancelAllNotifications();
  }
}