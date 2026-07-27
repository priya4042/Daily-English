import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Daily study-reminder notifications.
class Notifs {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const int _id = 101;

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try { tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  static Future<bool> requestPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await impl?.requestNotificationsPermission();
    try { await impl?.requestExactAlarmsPermission(); } catch (_) {}
    return granted ?? true;
  }

  static Future<void> scheduleDaily(int hour, int minute) async {
    await cancel();
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      _id,
      'Time to learn English! 📚',
      'Practice a few words or a quick conversation today.',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder', 'Daily Reminders',
          channelDescription: 'Reminds you to practice English every day',
          importance: Importance.high, priority: Priority.high),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel() => _plugin.cancel(_id);
}
