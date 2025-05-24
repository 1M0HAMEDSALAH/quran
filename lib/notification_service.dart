import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get_storage/get_storage.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GetStorage storage = GetStorage();
  final Random random = Random();

  static const String dailyChannelId = 'daily_quran_reminder';
  static const String dailyChannelName = 'تذكير يومي بالقرآن';
  static const String dailyChannelDescription =
      'تذكير يومي لقراءة القرآن الكريم';

  final List<String> reminderMessages = [
    'حان وقت قراءة القرآن الكريم 🕌',
    'لا تنس نصيبك من كتاب الله 📖',
    'اقرأ القرآن واجعل يومك مباركاً ✨',
    'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا 🌟',
    'اجعل للقرآن نصيباً في يومك 🤲',
  ];

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Handle foreground notifications on iOS
      notificationCategories: [
        DarwinNotificationCategory(
          dailyChannelId,
          actions: [
            DarwinNotificationAction.plain(
              'open',
              'Open',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        )
      ],
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize with proper callback handling
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        handleNotificationTap(response);
      },
      // This is for iOS when app is terminated and opened from notification
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );

    // Set up foreground notification presentation options (show notifications when app is in foreground)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (Platform.isIOS) {
      // This is how we handle foreground notifications on iOS in the newer versions
      // of the plugin by setting up a listener
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    tz.initializeTimeZones();
  }

  // This is needed for Android 12+ background handling
  @pragma('vm:entry-point')
  static void backgroundNotificationHandler(NotificationResponse response) {
    // Navigate to the appropriate screen when app is launched from notification
    if (response.payload != null) {
      // You can parse payload and take action based on it
      Get.toNamed('/quran-page');
    }
  }

  void handleNotificationTap(NotificationResponse response) {
    // Handle notification tap based on payload or notification id
    if (response.payload != null) {
      Map<String, dynamic> payloadData = {};
      try {
        // Parse the payload if it's in JSON format
        // Note: You might want to implement proper JSON parsing here
        final payload = response.payload!;
        Get.toNamed('/quran-page', arguments: payload);
      } catch (e) {
        print('Error parsing notification payload: $e');
        // Default fallback
        Get.toNamed('/quran-page');
      }
    } else {
      // Default navigation when no specific payload
      Get.toNamed('/quran-page');
    }
  }

  Future<bool> requestPermissions() async {
    if (GetPlatform.isIOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (GetPlatform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permissions
      final bool? notificationPermissionGranted =
          await androidImplementation?.requestNotificationsPermission();

      // Request exact alarms permission for Android 12 and above
      final bool? exactAlarmsPermissionGranted =
          await androidImplementation?.requestExactAlarmsPermission();

      return (notificationPermissionGranted ?? false) &&
          (exactAlarmsPermissionGranted ??
              true); // Default to true if null for backward compatibility
    }
    return false;
  }

  Future<bool> checkNotificationPermissions() async {
    if (GetPlatform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      return await androidImplementation?.areNotificationsEnabled() ?? false;
    } else if (GetPlatform.isIOS) {
      // For iOS, we don't have a direct way to check, so we'll rely on the stored value
      // or assume it's enabled if they previously granted it
      return storage.read('notifications_enabled') ?? false;
    }
    return false;
  }

  String _getRandomMessage() {
    return reminderMessages[random.nextInt(reminderMessages.length)];
  }

  // Show immediate notification when app is in foreground
  Future<void> showForegroundNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      dailyChannelId,
      dailyChannelName,
      channelDescription: dailyChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Use dynamic ID to avoid overwriting
      title ?? 'تذكير القرآن اليومي',
      body ?? _getRandomMessage(),
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification({
    int hour = 6,
    int minute = 0,
  }) async {
    final bool granted = await requestPermissions();
    if (!granted) {
      print('لم يتم منح أذونات الإشعارات');
      return;
    }

    // Store that notifications are enabled
    storage.write('notifications_enabled', true);
    storage.write('notification_hour', hour);
    storage.write('notification_minute', minute);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      dailyChannelId,
      dailyChannelName,
      channelDescription: dailyChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      // For Android 13+, this ensures notification appears on lock screen
      visibility: NotificationVisibility.public,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Use a distinct sound for the notification if needed
      // sound: 'slow_spring_board.aiff',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Use ID 0 for the daily notification
        'تذكير القرآن اليومي',
        _getRandomMessage(),
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload:
            'daily_reminder', // Add payload to identify this notification type
      );

      print('تم جدولة الإشعار في الساعة $hour:$minute');
    } catch (e) {
      print('Error scheduling notification: $e');
      // Handle the error appropriately
    }
  }

  // Method to check if a daily notification is currently scheduled
  Future<bool> isNotificationScheduled() async {
    final List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    // Check if notification with ID 0 (our daily notification) exists
    return pendingNotifications.any((notification) => notification.id == 0);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    await storage.write('notifications_enabled', false);
    await storage.remove('notification_hour');
    await storage.remove('notification_minute');
  }

  Future<Map<String, int>> getScheduledTime() async {
    return {
      'hour': storage.read('notification_hour') ?? 15,
      'minute': storage.read('notification_minute') ?? 0,
    };
  }

  Future<void> updateNotificationTime(int hour, int minute) async {
    await cancelAllNotifications();
    await scheduleDailyNotification(hour: hour, minute: minute);
  }
}
