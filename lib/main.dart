import 'package:quran_app/index.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize(
    notificationCount: 4,
    notificationInterval: 6,
    timeZone: 'Africa/Cairo',
  );

  // Initialize the SettingsController to load user preferences
  Get.put(SettingsController(), permanent: true);

  // Initialize QuranPlayerController for global access
  Get.put(QuranPlayerController(), permanent: true);

  runApp(MyApp());
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

  // Helper method to wrap routes with AppLayout
  List<GetPage> _wrapRoutesWithLayout(List<GetPage> routes) {
    return routes.map((route) {
      // Skip wrapping the QuranPlayerScreen route
      if (route.name == '/quran-player') {
        return route;
      }

      // Wrap other routes with AppLayout
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
