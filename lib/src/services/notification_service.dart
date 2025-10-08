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

      // Create notification channel for Android
      await _createNotificationChannel();

      // Request permissions for Android 13+
      await _requestPermissions();
      
      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('⚠️ NotificationService initialization error: $e');
      rethrow;
    }
  }

  Future<void> _createNotificationChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'reminders',
        'Health Reminders',
        description: 'Notifications for health reminders and medications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      
      await androidImplementation.createNotificationChannel(channel);
      print('🔔 Notification channel created: ${channel.id}');
    }
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Request notification permission
      final notificationPermission = await androidImplementation.requestNotificationsPermission();
      print('🔔 Notification permission: $notificationPermission');
      
      // Request exact alarm permission for Android 12+
      final exactAlarmPermission = await androidImplementation.requestExactAlarmsPermission();
      print('⏰ Exact alarm permission: $exactAlarmPermission');
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
    try {
      await _notifications.cancel(id);
      print('❌ Notification $id cancelled');
    } catch (e) {
      // Ignore cancellation errors - notification might not exist
      print('⚠️ Could not cancel notification $id: ${e.toString()}');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('🗑️ All notifications cancelled');
    } catch (e) {
      // Ignore cancellation errors
      print('⚠️ Could not cancel all notifications: ${e.toString()}');
    }
  }
}