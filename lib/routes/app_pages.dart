import 'package:get/get.dart';
import 'package:quran_app/contian/setting.dart';
import 'package:quran_app/contian/bookmarked.dart';
import 'package:quran_app/home/binding/home_binding.dart';
import 'package:quran_app/home/view/home_view.dart';

import '../contian/displaysurrah.dart';
import '../contian/search.dart';
part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
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
  ];
}
