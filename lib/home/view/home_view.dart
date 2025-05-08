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

  final List<String> _titles = ['سور', 'بحث', 'العلامات', 'الإعدادات'];
  final List<IconData> _icons = [
    Icons.menu_book_rounded,
    Icons.search_rounded,
    Icons.bookmark_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => Directionality(
            textDirection: TextDirection.rtl,
            child: screens[controller.selectedIndex.value],
          )),
      bottomNavigationBar: Obx(() => Directionality(
            textDirection: TextDirection.rtl,
            child: EnhancedBottomNavBar(
              selectedIndex: controller.selectedIndex.value,
              onTap: controller.updateIndex,
              icons: _icons,
              labels: _titles,
            ),
          )),
    );
  }
}

class EnhancedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  const EnhancedBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
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

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        width: 65,
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[index],
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppTheme.primaryColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Optional: A more stylized alternative with clip path for unique shape
class FancyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  const FancyBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background container with clip path
          ClipPath(
            clipper: NavBarClipper(),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),

          // Navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              icons.length,
              (index) => _buildNavItem(index),
            ),
          ),

          // Selected indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: 60,
            left: selectedIndex * (MediaQuery.of(context).size.width - 32) / 4 +
                ((MediaQuery.of(context).size.width - 32) / 4 - 50) / 2,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icons[selectedIndex],
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Spacer for selected indicator
            SizedBox(height: isSelected ? 20 : 0),

            // Only show icon when not selected
            if (!isSelected)
              Icon(
                icons[index],
                color: Colors.white.withOpacity(0.85),
                size: 22,
              ),

            // Label
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: isSelected ? 30 : 8),
              child: Text(
                labels[index],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Add wave pattern along the top
    final waveWidth = size.width / 16;
    for (int i = 0; i < 16; i++) {
      final waveHeight = (i % 2 == 0) ? 10.0 : 5.0;
      path.lineTo(size.width - (i * waveWidth), waveHeight);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Minimal Islamic-inspired design
class IslamicNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  const IslamicNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.icons,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Decorative Islamic pattern on the sides
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(20, 75),
              painter: IslamicPatternPainter(
                  color: AppTheme.primaryColor.withOpacity(0.08)),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(20, 75),
              painter: IslamicPatternPainter(
                  color: AppTheme.primaryColor.withOpacity(0.08)),
            ),
          ),

          // Navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              icons.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with decorative arch for selected item
            Stack(
              alignment: Alignment.center,
              children: [
                // Decorative arch background for selected item
                if (isSelected)
                  CustomPaint(
                    size: Size(40, 40),
                    painter: ArchPainter(
                        color: AppTheme.primaryColor.withOpacity(0.15)),
                  ),

                // Icon
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[index],
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Label
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppTheme.primaryColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArchPainter extends CustomPainter {
  final Color color;

  ArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create an Islamic arch shape
    path.moveTo(size.width * 0.1, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, -size.height * 0.3,
        size.width * 0.9, size.height * 0.5);

    // Complete the shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IslamicPatternPainter extends CustomPainter {
  final Color color;

  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create repeating geometric patterns
    final patternSize = size.height / 5;

    for (int i = 0; i < 5; i++) {
      final topOffset = i * patternSize;

      // Draw a simple geometric shape
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
