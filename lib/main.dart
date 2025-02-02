import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran_app/contian/setting.dart';
import 'package:quran_app/routes/app_pages.dart';
import 'notification_service.dart';

void main() async {
  await GetStorage.init();   
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SettingsController to load user preferences
  final settingsController = Get.put(SettingsController());

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyNotification();

  // Initialize the theme mode based on the stored value
  bool isDarkMode = settingsController.isDarkMode.value;

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quran App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,  // Dynamically set theme
      initialRoute: AppPages.routes[0].name,
      getPages: AppPages.routes,
    );
  }
}
