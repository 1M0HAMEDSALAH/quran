import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../const/app_theme.dart';
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

  final List<IconData> _icons = [
    Icons.menu_book_rounded,
    Icons.search_rounded,
    Icons.bookmark_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(() {
      final isDarkMode = settingsController.isDarkMode.value;

      return Scaffold(
        extendBody: true,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: screens[controller.selectedIndex.value],
        ),
        bottomNavigationBar: Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controller.isNavBarVisible.value ? 80 : 0,
              child: Wrap(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: IslamicNavBar(
                      selectedIndex: controller.selectedIndex.value,
                      onTap: controller.updateIndex,
                      icons: _icons,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            )),
      );
    });
  }
}

class IslamicNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final bool isDarkMode;

  const IslamicNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppColor.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[700]!
              : AppColor.primaryColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          icons.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = selectedIndex == index;
    final iconColor = isSelected
        ? Colors.white
        : (isDarkMode ? Colors.grey[400] : Colors.grey[600]);
    final bgColor = isSelected ? AppColor.primaryColor : Colors.transparent;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  CustomPaint(
                    size: Size(40, 40),
                    // painter: ArchPainter(
                    //   color: AppColor.primaryColor.withOpacity(0.15),
                    // ),
                  ),
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[index],
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class ArchPainter extends CustomPainter {
//   final Color color;

//   ArchPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     final path = Path();
//     path.moveTo(size.width * 0.1, size.height * 0.5);
//     path.quadraticBezierTo(size.width * 0.5, -size.height * 0.3,
//         size.width * 0.9, size.height * 0.5);
//     path.lineTo(size.width, size.height);
//     path.lineTo(0, size.height);
//     path.close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

class IslamicPatternPainter extends CustomPainter {
  final Color color;

  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final patternSize = size.height / 5;

    for (int i = 0; i < 5; i++) {
      final topOffset = i * patternSize;
      final path = Path();
      path.moveTo(0, topOffset);
      path.lineTo(size.width, topOffset + patternSize * 0.5);
      path.lineTo(0, topOffset + patternSize);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
