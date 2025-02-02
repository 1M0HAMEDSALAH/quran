import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final GetStorage storage = GetStorage();
  
  static const String dailyChannelId = 'daily_quran_reminder';
  static const String dailyChannelName = 'تذكير يومي بالقرآن';
  static const String dailyChannelDescription = 'تذكير يومي لقراءة القرآن الكريم';

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
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        handleNotificationTap(response);
      },
    );

    tz.initializeTimeZones();
  }

  void handleNotificationTap(NotificationResponse response) {
    // Handle notification tap here
    // Example: Get.toNamed('/quran-page');
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
             (exactAlarmsPermissionGranted ?? false);
    }
    return false;
  }

  Future<bool> checkExactAlarmPermission() async {
    if (!GetPlatform.isAndroid) return true;
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }

  String _getRandomMessage() {
    return reminderMessages[DateTime.now().millisecondsSinceEpoch % 
        reminderMessages.length];
  }

  Future<void> scheduleDailyNotification({
    int hour = 15,
    int minute = 0,
  }) async {
    final bool granted = await requestPermissions();
    if (!granted) {
      print('لم يتم منح أذونات الإشعارات');
      return;
    }

    // Check exact alarm permission
    final bool exactAlarmsPermitted = await checkExactAlarmPermission();
    if (!exactAlarmsPermitted) {
      // If exact alarms aren't permitted, you might want to show a dialog
      // explaining why the feature is needed and guiding the user to settings
      print('لم يتم منح إذن التنبيهات الدقيقة');
      // You could show a dialog here to guide the user
      return;
    }

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
      largeIcon: DrawableResourceAndroidBitmap('assets/image.png'),
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
        0,
        'تذكير القرآن اليومي',
        _getRandomMessage(),
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
      // Handle the error appropriately
    }
  }

  // Rest of the methods remain the same...
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
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