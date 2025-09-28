import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

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
    _notificationCount = _storage.read('notification_count') ?? _defaultNotificationCount;
    _notificationInterval = _storage.read('notification_interval') ?? _defaultInterval;
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
      
      // التأكد من أن tz.local تم تهيئته بشكل صحيح
      final testTime = tz.TZDateTime.now(tz.local);
      debugPrint('🌐 Time zone set to $_currentTimeZone, current time: $testTime');
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

  Future<void> _initializeNotifications({bool requestPermissions = false}) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
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
      // طلب الصلاحيات لـ iOS
      final ios = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await ios?.requestPermissions(
        alert: true, 
        badge: true, 
        sound: true,
      );

      // طلب الصلاحيات لـ Android
      final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await android?.requestNotificationsPermission();

      _permissionsGranted = iosGranted ?? androidGranted ?? false;
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
      final android = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (android != null) {
        final granted = await android.areNotificationsEnabled();
        _permissionsGranted = granted ?? false;
      }
      
      await _saveSettings();
      return _permissionsGranted;
    } catch (e) {
      debugPrint('⚠️ Failed to check permissions: $e');
      return false;
    }
  }

  /// معالج النقر على الإشعار في المقدمة
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Notification tapped: ${response.id}');
    // Navigate or handle the notification tap if needed
    _handleNotificationAction(response);
  }

  /// معالج النقر على الإشعار في الخلفية
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Background notification tapped: ${response.id}');
    // Handle background notification tap
  }

  /// معالجة إجراءات الإشعارات
  void _handleNotificationAction(NotificationResponse response) {
    // يمكنك إضافة منطق التنقل هنا
    // مثال: التوجه إلى صفحة القرآن
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
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: enableVibration,
      color: color,
      // sound: sound.isNotEmpty ? RawResourceAndroidNotificationSound(sound) : null,
      styleInformation: const BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
      ongoing: false,
      autoCancel: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: sound.isNotEmpty ? '$sound.aiff' : null,
      badgeNumber: 1,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> scheduleRepeatedNotifications() async {
    if (!_permissionsGranted) {
      debugPrint('⚠️ Cannot schedule notifications: permissions not granted');
      return;
    }

    // التأكد من أن tz.local مهيأ بشكل صحيح
    try {
      final testTime = tz.TZDateTime.now(tz.local);
      debugPrint('✅ Time zone check passed: $testTime');
    } catch (e) {
      debugPrint('⚠️ Time zone not properly initialized, reinitializing...');
      await _configureLocalTimeZone();
    }

    try {
      await _notificationsPlugin.cancelAll();

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

      debugPrint('✅ $_notificationCount notifications scheduled successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to schedule notifications: $e');
      // إعادة تهيئة المنطقة الزمنية والمحاولة مرة أخرى
      await _configureLocalTimeZone();
    }
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

      // إذا كان الوقت قد مضى، اجعله في اليوم التالي
      if (scheduledTime.isBefore(baseTime)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      return scheduledTime;
    } catch (e) {
      debugPrint('⚠️ Error calculating notification time: $e');
      // في حالة الخطأ، استخدم الوقت الحالي + الساعات المطلوبة
      return baseTime.add(Duration(hours: _notificationInterval * (index + 1)));
    }
  }

  Future<void> setTimeZone(String timeZone) async {
    try {
      _currentTimeZone = timeZone;
      
      // إعادة تهيئة المنطقة الزمنية
      await _configureLocalTimeZone();
      
      // حفظ الإعدادات
      await _saveSettings();
      
      // إعادة جدولة الإشعارات إذا كانت مفعلة
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

  /// تفعيل أو إلغاء تفعيل الإشعارات
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

  /// الحصول على حالة الإشعارات
  bool get isEnabled => _permissionsGranted;
  int get notificationCount => _notificationCount;
  int get notificationInterval => _notificationInterval;
  String get timeZone => _currentTimeZone;

  /// عرض إشعار فوري للاختبار
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