import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isSupportedPlatform = Platform.isAndroid || Platform.isIOS;

  // Notification IDs
  static const int _dailyId = 1;
  static const int _weeklyId = 2;

  // Notification times
  static const int DAILY_HOUR = 9;
  static const int DAILY_MINUTE = 0;
  static const int WEEKLY_WEEKDAY = DateTime.monday;
  static const int WEEKLY_HOUR = 10;
  static const int WEEKLY_MINUTE = 0;

  Future<void> initialize() async {
    if (!_isSupportedPlatform) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _plugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sikkoku_channel',
      'Sikkoku Notifications',
      description: 'Sikkoku reminder notification channel',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermission() async {
    if (!_isSupportedPlatform) return true; // Desktop/Web: izin gereksiz, no-op
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      try {
        final dyn = android as dynamic;
        final granted = await dyn.requestPermission?.call();
        if (granted is bool) return granted;
      } catch (_) {}
      final enabled = await android?.areNotificationsEnabled();
      return enabled ?? true;
    }
    return true;
  }

  Future<void> scheduleDaily(BuildContext context) async {
    if (!_isSupportedPlatform) return;
    await cancelDaily();
    final tz.TZDateTime scheduled = _nextInstanceOfFixedTime(DAILY_HOUR, DAILY_MINUTE);

    await _plugin.zonedSchedule(
      _dailyId,
      'Daily Puzzle',
      'Don\'t forget to solve today\'s puzzle!',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sikkoku_channel',
          'Sikkoku Notifications',
          channelDescription: 'Sikkoku reminder notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_stat_sikkoku',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDaily() async {
    if (!_isSupportedPlatform) return;
    await _plugin.cancel(_dailyId);
  }

  Future<void> scheduleWeekly(BuildContext context) async {
    if (!_isSupportedPlatform) return;
    await cancelWeekly();
    final tz.TZDateTime scheduled = _nextInstanceOfFixedWeekday(WEEKLY_WEEKDAY, WEEKLY_HOUR, WEEKLY_MINUTE);

    await _plugin.zonedSchedule(
      _weeklyId,
      'Weekly Puzzle',
      'Don\'t miss the weekly puzzle!',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sikkoku_channel',
          'Sikkoku Notifications',
          channelDescription: 'Sikkoku reminder notification channel',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_stat_sikkoku',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelWeekly() async {
    if (!_isSupportedPlatform) return;
    await _plugin.cancel(_weeklyId);
  }

  tz.TZDateTime _nextInstanceOfFixedTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfFixedWeekday(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }
}
