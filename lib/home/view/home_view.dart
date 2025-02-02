import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../contian/search.dart';
import '../../contian/setting.dart';
import '../../contian/home.dart';
import '../../contian/bookmarked.dart';
import '../controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  final List<Widget> screens = [
    SurahListView(),
    SearchScreen(),
    BookmarkScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Directionality(
            textDirection: TextDirection.rtl,
            child: screens[controller.selectedIndex.value],
          )),
      bottomNavigationBar: Obx(
        () => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BottomNavigationBar(
                currentIndex: controller.selectedIndex.value,
                onTap: controller.updateIndex,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.teal, // لون العنصر المحدد
                unselectedItemColor: Colors.grey, // لون العناصر غير المحددة
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ), // نص العنصر المحدد
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ), // نص العناصر غير المحددة
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'سور',
                    activeIcon: Icon(Icons.home, color: Colors.teal),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'بحث',
                    activeIcon: Icon(Icons.search, color: Colors.teal),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    label: 'العلامات',
                    activeIcon: Icon(Icons.bookmark, color: Colors.teal),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'الإعدادات',
                    activeIcon: Icon(Icons.settings, color: Colors.teal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
