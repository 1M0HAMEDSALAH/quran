import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

/// خدمة الإشعارات لتطبيق القرآن الكريم
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'quran_reminder_channel';
  static const String _channelName = 'Quran Reminders';
  static const String _channelDescription = 'تذكيرات بقراءة القرآن الكريم';

  static const int _defaultInterval = 6;
  static const int _defaultNotificationCount = 4;

  static const List<String> _notificationTitles = [
    '📖 وردك من القرآن',
    '🕌 حان وقت القرآن',
    '🤲 تذكير بتلاوة القرآن',
    '☪️ لا تنس نصيبك من القرآن',
  ];

  static const List<String> _notificationMessages = [
    'لا تنسَ قراءة القرآن اليوم!',
    'اقرأ آيات من كتاب الله وارفع درجاتك',
    'القرآن شفيع لأصحابه يوم القيامة',
    'من قرأ حرفاً من كتاب الله فله به حسنة',
  ];

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _currentTimeZone = 'Africa/Cairo';
  int _notificationCount = _defaultNotificationCount;
  int _notificationInterval = _defaultInterval;

  /// تهيئة الخدمة بدون استخدام SharedPreferences
  Future<void> initialize({
    int notificationCount = _defaultNotificationCount,
    int notificationInterval = _defaultInterval,
    String timeZone = 'Africa/Cairo',
  }) async {
    _notificationCount = notificationCount;
    _notificationInterval = notificationInterval;
    _currentTimeZone = timeZone;

    await _configureLocalTimeZone();
    await _initializeNotifications();
    await scheduleRepeatedNotifications();

    debugPrint('✅ NotificationService: Initialized without preferences');
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(_currentTimeZone));
      debugPrint('🌐 Time zone set to $_currentTimeZone');
    } catch (e) {
      debugPrint('⚠️ Time zone setup failed: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final didInit = await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('🔔 Initialization ${didInit != null ? "succeeded" : "failed"}');
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    debugPrint('🔐 Notification permissions requested');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.id}');
    // Navigate or handle the notification tap if needed
  }

  NotificationDetails _createNotificationDetails({
    String sound = 'adhan',
    bool enableVibration = true,
    Color? color,
  }) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: enableVibration,
      color: color,
      sound:
          sound.isNotEmpty ? RawResourceAndroidNotificationSound(sound) : null,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound.isNotEmpty ? '$sound.aiff' : null,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> scheduleRepeatedNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();

      final now = DateTime.now();
      final localNow = tz.TZDateTime.from(now, tz.local);

      for (int i = 0; i < _notificationCount; i++) {
        final scheduledTime = _calculateNotificationTime(localNow, i);
        final titleIndex = i % _notificationTitles.length;
        final messageIndex = i % _notificationMessages.length;

        await _notificationsPlugin.zonedSchedule(
          i,
          _notificationTitles[titleIndex],
          _notificationMessages[messageIndex],
          scheduledTime,
          _createNotificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        debugPrint('📅 Notification #$i scheduled at $scheduledTime');
      }

      debugPrint('✅ $_notificationCount notifications scheduled');
    } catch (e) {
      debugPrint('⚠️ Failed to schedule notifications: $e');
    }
  }

  tz.TZDateTime _calculateNotificationTime(tz.TZDateTime baseTime, int index) {
    tz.TZDateTime scheduledTime =
        baseTime.add(Duration(hours: _notificationInterval * index));
    if (scheduledTime.isBefore(baseTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    return scheduledTime;
  }

  Future<void> setTimeZone(String timeZone) async {
    try {
      _currentTimeZone = timeZone;
      tz.setLocalLocation(tz.getLocation(timeZone));
      await scheduleRepeatedNotifications();
      debugPrint('🌐 Time zone changed to $timeZone');
    } catch (e) {
      debugPrint('⚠️ Failed to change time zone: $e');
    }
  }

  Future<void> setNotificationCount(int count) async {
    if (count > 0 && count <= 10) {
      _notificationCount = count;
      await scheduleRepeatedNotifications();
      debugPrint('🔢 Notification count set to $count');
    } else {
      debugPrint('⚠️ Invalid notification count: $count');
    }
  }

  Future<void> setNotificationInterval(int hours) async {
    if (hours > 0 && hours <= 12) {
      _notificationInterval = hours;
      await scheduleRepeatedNotifications();
      debugPrint('⏱️ Interval set to $hours hours');
    } else {
      debugPrint('⚠️ Invalid interval: $hours');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('❌ All notifications canceled');
  }
}
