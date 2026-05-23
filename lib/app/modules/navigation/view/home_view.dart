import 'package:quran_app/index.dart';

class NavigationScreen extends GetView<NavigationController> {
  NavigationScreen({super.key});

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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF0F3E33).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.grey[800]!
              : const Color(0xFFCDA047).withOpacity(0.3),
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
        : (isDarkMode
            ? Colors.grey[400]
            : const Color(0xFF0F3E33).withOpacity(0.6));
    final bgColor = isSelected ? const Color(0xFF0F3E33) : Colors.transparent;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: isSelected ? 48 : 40,
              width: isSelected ? 48 : 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0F3E33).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Icon(
                icons[index],
                color: iconColor,
                size: isSelected ? 24 : 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
