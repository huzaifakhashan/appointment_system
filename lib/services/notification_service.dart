import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/appointment.dart';

/// Local notifications (Android). On web this is a no-op.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'appointments',
      'Appointments',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tz_data.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
    }
  }

  int _id(String s) => s.hashCode & 0x7fffffff;

  Future<void> show(String title, String body) async {
    if (!_ready) return;
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  /// Reminder one hour before a confirmed appointment. Title/body are passed
  /// in already localized, since this service has no BuildContext of its own.
  Future<void> scheduleReminder(Appointment a,
      {required String title, required String body}) async {
    if (!_ready) return;
    final when = a.start.subtract(const Duration(hours: 1));
    if (when.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: _id(a.id),
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Could not schedule reminder: $e');
    }
  }

  Future<void> cancelReminder(String appointmentId) async {
    if (!_ready) return;
    await _plugin.cancel(id: _id(appointmentId));
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}
