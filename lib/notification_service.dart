import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:quran_app/app/modules/PrayerTimes/models/prayer_times_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // قناة تذكيرات القرآن (بدون صوت أذان)
  static const String _channelId = 'quran_reminder_channel';
  static const String _channelName = 'Quran Reminders';
  static const String _channelDescription = 'تذكيرات بقراءة القرآن الكريم';

  // قناة إشعارات الصلاة (بصوت الأذان)
  static const String _prayerChannelId = 'prayer_times_channel';
  static const String _prayerChannelName = 'Prayer Times';
  static const String _prayerChannelDescription =
      'إشعارات مواقيت الصلاة بصوت الأذان';

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
  final GetStorage _storage = GetStorage();

  String _currentTimeZone = 'Africa/Cairo';
  int _notificationCount = _defaultNotificationCount;
  int _notificationInterval = _defaultInterval;
  bool _isInitialized = false;
  bool _permissionsGranted = false;

  /// تهيئة الخدمة الأساسية بدون طلب الصلاحيات
  Future<void> initialize({
    int notificationCount = _defaultNotificationCount,
    int notificationInterval = _defaultInterval,
    String timeZone = 'Africa/Cairo',
    bool requestPermissions = false,
  }) async {
    if (_isInitialized) return;

    _notificationCount = notificationCount;
    _notificationInterval = notificationInterval;
    _currentTimeZone = timeZone;

    // ترتيب مهم: تهيئة المنطقة الزمنية أولاً
    await _configureLocalTimeZone();

    // ثم تهيئة الإشعارات
    await _initializeNotifications(requestPermissions: requestPermissions);

    // تحميل الإعدادات المحفوظة
    await _loadSettings();

    // إعادة تطبيق المنطقة الزمنية بعد تحميل الإعدادات
    if (_currentTimeZone != timeZone) {
      await _configureLocalTimeZone();
    }

    _isInitialized = true;
    debugPrint('✅ NotificationService: Initialized');

    // جدولة الإشعارات فقط إذا كانت الصلاحيات ممنوحة
    if (_permissionsGranted) {
      await scheduleRepeatedNotifications();
    }
  }

  /// تحميل الإعدادات من التخزين المحلي
  Future<void> _loadSettings() async {
    _notificationCount =
        _storage.read('notification_count') ?? _defaultNotificationCount;
    _notificationInterval =
        _storage.read('notification_interval') ?? _defaultInterval;
    _currentTimeZone = _storage.read('time_zone') ?? 'Africa/Cairo';
    _permissionsGranted = _storage.read('notifications_enabled') ?? false;
  }

  /// حفظ الإعدادات في التخزين المحلي
  Future<void> _saveSettings() async {
    await _storage.write('notification_count', _notificationCount);
    await _storage.write('notification_interval', _notificationInterval);
    await _storage.write('time_zone', _currentTimeZone);
    await _storage.write('notifications_enabled', _permissionsGranted);
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final location = tz.getLocation(_currentTimeZone);
      tz.setLocalLocation(location);

      final testTime = tz.TZDateTime.now(tz.local);
      debugPrint(
          '🌐 Time zone set to $_currentTimeZone, current time: $testTime');
    } catch (e) {
      debugPrint('⚠️ Time zone setup failed: $e');
      try {
        final utcLocation = tz.getLocation('UTC');
        tz.setLocalLocation(utcLocation);
        _currentTimeZone = 'UTC';
        debugPrint('🌐 Fallback to UTC timezone');
      } catch (fallbackError) {
        debugPrint('⚠️ Even UTC fallback failed: $fallbackError');
      }
    }
  }

  Future<void> _initializeNotifications(
      {bool requestPermissions = false}) async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final didInit = await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    debugPrint('🔔 Initialization ${didInit != null ? "succeeded" : "failed"}');

    if (requestPermissions) {
      await _requestPermissions();
    }
  }

  /// طلب الصلاحيات (يتم استدعاؤها عند الحاجة فقط)
  Future<bool> requestPermissions() async {
    if (_permissionsGranted) return true;

    try {
      bool granted = false;

      if (Platform.isAndroid) {
        final androidPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final notifGranted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
        final alarmGranted =
            await androidPlugin?.requestExactAlarmsPermission() ?? false;

        granted = notifGranted && alarmGranted;
      } else if (Platform.isIOS) {
        final iosPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        granted = await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      _permissionsGranted = granted;
      await _saveSettings();

      if (_permissionsGranted) {
        await scheduleRepeatedNotifications();
        debugPrint('🔐 Notification permissions granted');
      } else {
        debugPrint('❌ Notification permissions denied');
      }

      return _permissionsGranted;
    } catch (e) {
      debugPrint('⚠️ Failed to request permissions: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await requestPermissions();
  }

  /// التحقق من حالة الصلاحيات
  Future<bool> checkPermissions() async {
    try {
      bool granted = false;

      if (Platform.isAndroid) {
        final androidPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // requestNotificationsPermission acts as a check if already granted
        final notifGranted =
            await androidPlugin?.requestNotificationsPermission() ?? false;
        // We also check exact alarms for prayer times
        final exactAlarmGranted =
            await androidPlugin?.requestExactAlarmsPermission() ?? false;

        granted = notifGranted && exactAlarmGranted;
      } else if (Platform.isIOS) {
        final iosPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        // On iOS, requestPermissions returns the current status if already requested
        granted = await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      _permissionsGranted = granted;
      debugPrint('🔔 Permissions granted: $granted');
      return granted;
    } catch (e) {
      debugPrint('Permission error: $e');
      return false;
    }
  }

  /// معالج النقر على الإشعار في المقدمة
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.id}');
    _handleNotificationAction(response);
  }

  /// معالج النقر على الإشعار في الخلفية
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Background notification tapped: ${response.id}');
  }

  /// معالجة إجراءات الإشعارات
  void _handleNotificationAction(NotificationResponse response) {
    // يمكنك إضافة منطق التنقل هنا
  }

  /// إشعارات تذكيرات القرآن العادية (بدون صوت أذان)
  NotificationDetails _createNotificationDetails({
    bool enableVibration = true,
    Color? color,
  }) {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: enableVibration,
      color: color,
      styleInformation: const BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('ic_notification'),
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// إشعارات مواقيت الصلاة (بصوت الأذان + صورة مخصصة)
  NotificationDetails _createPrayerNotificationDetails({
    bool enableVibration = true,
    Color? color,
  }) {
    final androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      _prayerChannelName,
      channelDescription: _prayerChannelDescription,
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: enableVibration,
      color: color,
      styleInformation: const BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('ic_notification'),
      sound: const RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'adhan.aiff',
      badgeNumber: 1,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> schedulePrayerNotifications(List<PrayerData> data) async {
    final actuallyGranted = await checkPermissions();
    if (!actuallyGranted) {
      debugPrint(
          '⚠️ Cannot schedule prayer notifications: permissions not granted');
      return;
    }

    try {
      // 1. Cancel existing prayer notifications (using a specific ID range)
      // For simplicity, we'll cancel all if we don't have many others,
      // but let's use IDs 1000-2000 for prayer times.
      // 1. Cancel existing prayer notifications (using a specific ID range)
      // Optimization: We don't need to cancel one by one if we are about to overwrite them,
      // but if we want to be clean, we can do it. To avoid rate limiting, we only cancel
      // a few or use cancelAll if it's the first time.
      // For now, let's just proceed to schedule; zonedSchedule with same ID replaces old one.
      // However, if the user wants to clear them first:
      // await _notificationsPlugin.cancel(id); // inside the loop if needed.

      final now = DateTime.now();
      int scheduledCount = 0;
      int idOffset = 1000;

      // Filter data for today and future days
      for (var day in data) {
        final dateParts = day.date.gregorian.date.split('-');
        final dayDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );

        // Only schedule for next 7 days to avoid hitting limits
        if (dayDate.isBefore(now.subtract(const Duration(days: 1))) ||
            dayDate.isAfter(now.add(const Duration(days: 7)))) {
          continue;
        }

        final timings = {
          'الفجر': day.timings.fajr,
          'الظهر': day.timings.dhuhr,
          'العصر': day.timings.asr,
          'المغرب': day.timings.maghrib,
          'العشاء': day.timings.isha,
        };

        for (var entry in timings.entries) {
          final timeStr = entry.value.split(' ')[0];
          final timeParts = timeStr.split(':');
          final scheduledTime = tz.TZDateTime(
            tz.local,
            dayDate.year,
            dayDate.month,
            dayDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
            await _notificationsPlugin.zonedSchedule(
              idOffset + scheduledCount,
              'حي على الصلاة',
              'حان الآن موعد أذان ${entry.key}',
              scheduledTime,
              _createPrayerNotificationDetails(), // إشعار صلاة بصوت الأذان
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
            scheduledCount++;
          }
        }
      }

      debugPrint('✅ Scheduled $scheduledCount prayer notifications');
    } catch (e) {
      debugPrint('⚠️ Error scheduling prayer notifications: $e');
    }
  }

  Future<void> scheduleRepeatedNotifications() async {
    if (!_permissionsGranted) {
      debugPrint('⚠️ Cannot schedule notifications: permissions not granted');
      return;
    }

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await _notificationsPlugin.cancelAll();
        debugPrint('🗑️ All previous notifications canceled');

        final now = DateTime.now();
        final localNow = tz.TZDateTime.from(now, tz.local);
        debugPrint('📅 Base time for scheduling: $localNow');

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

        debugPrint(
            '✅ $_notificationCount notifications scheduled successfully');
        return;
      } catch (e) {
        retryCount++;
        debugPrint(
            '⚠️ Failed to schedule notifications (Attempt $retryCount/$maxRetries): $e');
        if (retryCount < maxRetries) {
          await Future.delayed(const Duration(seconds: 2));
          await _configureLocalTimeZone();
        }
      }
    }

    debugPrint('❌ Failed to schedule notifications after $maxRetries attempts');
  }

  tz.TZDateTime _calculateNotificationTime(tz.TZDateTime baseTime, int index) {
    try {
      final hours = _notificationInterval * (index + 1);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        baseTime.year,
        baseTime.month,
        baseTime.day,
        6 + (hours % 24), // البدء من الساعة 6 صباحاً
        0,
        0,
      );

      debugPrint(
          '⏰ Calculating notification #$index: Base=$baseTime, Hours=$hours, Scheduled=$scheduledTime');

      if (scheduledTime.isBefore(baseTime)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
        debugPrint('⏰ Adjusted to next day: $scheduledTime');
      }

      return scheduledTime;
    } catch (e) {
      debugPrint('⚠️ Error calculating notification time: $e');
      return baseTime.add(Duration(hours: _notificationInterval * (index + 1)));
    }
  }

  Future<void> setTimeZone(String timeZone) async {
    try {
      _currentTimeZone = timeZone;
      await _configureLocalTimeZone();
      await _saveSettings();

      if (_permissionsGranted) {
        await scheduleRepeatedNotifications();
      }

      debugPrint('🌐 Time zone successfully changed to $timeZone');
    } catch (e) {
      debugPrint('⚠️ Failed to change time zone: $e');
    }
  }

  Future<void> setNotificationCount(int count) async {
    if (count > 0 && count <= 10) {
      _notificationCount = count;
      await _saveSettings();

      if (_permissionsGranted) {
        await scheduleRepeatedNotifications();
      }

      debugPrint('🔢 Notification count set to $count');
    } else {
      debugPrint('⚠️ Invalid notification count: $count');
    }
  }

  Future<void> setNotificationInterval(int hours) async {
    if (hours > 0 && hours <= 12) {
      _notificationInterval = hours;
      await _saveSettings();

      if (_permissionsGranted) {
        await scheduleRepeatedNotifications();
      }

      debugPrint('⏱️ Interval set to $hours hours');
    } else {
      debugPrint('⚠️ Invalid interval: $hours');
    }
  }

  Future<void> enableNotifications(bool enable) async {
    if (enable && !_permissionsGranted) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    if (enable) {
      await scheduleRepeatedNotifications();
    } else {
      await cancelAllNotifications();
    }

    _permissionsGranted = enable;
    await _saveSettings();

    debugPrint('🔔 Notifications ${enable ? "enabled" : "disabled"}');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('❌ All notifications canceled');
  }

  bool get isEnabled => _permissionsGranted;
  int get notificationCount => _notificationCount;
  int get notificationInterval => _notificationInterval;
  String get timeZone => _currentTimeZone;

  Future<void> showTestNotification() async {
    if (!_permissionsGranted) {
      debugPrint('⚠️ Cannot show test notification: permissions not granted');
      return;
    }

    await _notificationsPlugin.show(
      999,
      '🧪 إشعار تجريبي',
      'هذا إشعار تجريبي للتأكد من عمل النظام',
      _createNotificationDetails(),
    );
  }
}
