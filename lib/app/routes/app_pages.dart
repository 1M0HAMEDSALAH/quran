import 'package:quran_app/index.dart';


class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => NavigationScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => SearchScreen(),
      //binding: SearchBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingsScreen(),
      //binding: SettingsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.Bookmarks,
      page: () => BookmarkScreen(),
      //binding: AboutBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.PRAYER_TIMES,
      page: () => PrayerTimesView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
