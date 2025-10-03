import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings);

      // Request permissions for Android 13+
      await _requestPermissions();
      
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('⚠️ NotificationService initialization error: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request notification permission
      await androidImplementation.requestNotificationsPermission();
      
      // Request exact alarm permission for Android 12+
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminders',
      'Health Reminders',
      channelDescription: 'Notifications for health reminders and medications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Try exact scheduling first
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      print('✅ Exact notification scheduled: "$title" at $scheduledDate');
    } catch (e) {
      if (e.toString().contains('exact_alarms_not_permitted')) {
        // Fallback to inexact scheduling
        try {
          await _notifications.zonedSchedule(
            id,
            title,
            body,
            tz.TZDateTime.from(scheduledDate, tz.local),
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            payload: payload,
          );
          print('⚠️ Inexact notification scheduled: "$title" at $scheduledDate (exact alarms not permitted)');
        } catch (fallbackError) {
          print('❌ Failed to schedule notification: $fallbackError');
          rethrow;
        }
      } else {
        print('❌ Failed to schedule notification: $e');
        rethrow;
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('❌ Notification $id cancelled');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cancelled');
  }
}