import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran_app/const/app_themee.dart';
import 'package:quran_app/contian/setting.dart';
import 'package:quran_app/routes/app_pages.dart';
import 'notification_service.dart';



void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SettingsController to load user preferences
  Get.put(SettingsController());

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyNotification();

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
        getPages: AppPages.routes,
      );
    });
  }
}
