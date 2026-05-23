import 'package:quran_app/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init storage first (fast, required)
  await GetStorage.init();

  // ✅ Register controllers before runApp
  Get.put(SettingsController(), permanent: true);
  Get.put(QuranPlayerController(), permanent: true);

  // ✅ Run app immediately — don't block on notifications
  runApp(MyApp());

  // ✅ Defer heavy/optional init AFTER first frame is painted
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // ✅ تهيئة خدمة الإشعارات
      await NotificationService().initialize(
        notificationCount: 4,
        notificationInterval: 6,
        timeZone: 'Africa/Cairo',
        requestPermissions: true,
      );

      // ✅ تسجيل PrayerTimesController لجلب مواقيت الصلاة وجدولة إشعارات الأذان تلقائياً
      if (!Get.isRegistered<PrayerTimesController>()) {
        Get.put(PrayerTimesController(), permanent: true);
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing services: $e');
    }
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quran App',
        theme: theme(),
        darkTheme: darkTheme(),
        themeMode: settingsController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppPages.routes[0].name,
        getPages: _wrapRoutesWithLayout(AppPages.routes),
      );
    });
  }

  List<GetPage> _wrapRoutesWithLayout(List<GetPage> routes) {
    return routes.map((route) {
      if (route.name == '/quran-player') return route;
      return GetPage(
        name: route.name,
        page: () => AppLayout(child: route.page()),
        binding: route.binding,
        bindings: route.bindings,
        middlewares: route.middlewares,
        transition: route.transition,
        transitionDuration: route.transitionDuration,
      );
    }).toList();
  }
}
