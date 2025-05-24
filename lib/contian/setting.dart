import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/app_theme.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();
  final fontSize = 22.0.obs;
  final isDarkMode = false.obs;
  final arabicFont = "Hafs".obs;
  final autoScrollSpeed = 1.0.obs;
  final lastReadSurah = 1.obs;
  final lastReadAyah = 1.obs;

  // Font options with better organization using a model
  final List<ArabicFontOption> fontOptions = [
    ArabicFontOption(
        id: 'Hafs', arabicName: 'حفص', fontFamily: 'KFGQPCUthmanicScriptHAFS'),
    ArabicFontOption(
        id: 'Uthmani', arabicName: 'عثماني', fontFamily: 'UthmanicScript'),
    ArabicFontOption(id: 'Naskh', arabicName: 'نسخ', fontFamily: 'Amiri'),
    ArabicFontOption(id: 'Qaloon', arabicName: 'قالون', fontFamily: 'Lateef'),
    ArabicFontOption(
        id: 'fontFamily: "BahijTheSansArabic"',
        arabicName: 'اندونيسي',
        fontFamily: 'fontFamily: "BahijTheSansArabic"'),
  ];

  // Getter for current font family
  String get arabicFontFamily {
    final option = fontOptions.firstWhere(
      (font) => font.id == arabicFont.value,
      orElse: () => fontOptions.first,
    );
    return option.fontFamily;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Separated method for better organization
  void _loadSettings() {
    fontSize.value = storage.read('fontSize') ?? 22.0;
    isDarkMode.value = storage.read('isDarkMode') ?? false;
    arabicFont.value = storage.read('arabicFont') ?? "Hafs";
    autoScrollSpeed.value = storage.read('autoScrollSpeed') ?? 1.0;

    // Load last read position
    lastReadSurah.value = storage.read('lastReadSurah') ?? 1;
    lastReadAyah.value = storage.read('lastReadAyah') ?? 1;
  }

  void setFontSize(double size) {
    fontSize.value = size;
    storage.write('fontSize', size);
    HapticFeedback.selectionClick(); // Provide feedback
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    storage.write('isDarkMode', isDarkMode.value);
    HapticFeedback.mediumImpact();
  }

  void setArabicFont(String font) {
    arabicFont.value = font;
    storage.write('arabicFont', font);
    HapticFeedback.lightImpact();
  }

  void setAutoScrollSpeed(double speed) {
    autoScrollSpeed.value = speed;
    storage.write('autoScrollSpeed', speed);
    HapticFeedback.selectionClick();
  }

  // Method to save last read position
  void saveReadingPosition(int surah, int ayah) {
    lastReadSurah.value = surah;
    lastReadAyah.value = ayah;
    storage.write('lastReadSurah', surah);
    storage.write('lastReadAyah', ayah);
  }
}

// Model class for better organization
class ArabicFontOption {
  final String id;
  final String arabicName;
  final String fontFamily;

  ArabicFontOption({
    required this.id,
    required this.arabicName,
    required this.fontFamily,
  });
}

class QuranAboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[850] : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Islamic pattern at the top
            Container(
              width: double.infinity,
              height: 60,
              child: CustomPaint(
                painter: IslamicHeaderPainter(
                  color: isDark
                      ? const Color.fromARGB(255, 161, 161, 161)
                          .withOpacity(0.3)
                      : AppColor.primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // App icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book,
                size: 40,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // App title
            Text(
              'تطبيق القرآن الكريم',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // App version
            Text(
              'الإصدار 1.0.0',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // App dedication
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'هذا التطبيق تم تطويره لوجه الله تعالى\nولا نبتغي به مالاً ولا شهرة',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Prayer
            Text(
              'اللهم اجعله في ميزان حسناتنا',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'إغلاق',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'الإعدادات',
                ),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "إعدادات القراءة",
                      style: TextStyle(fontSize: 20),
                    ),
                    // _buildSectionHeader(
                    //     context, 'إعدادات القراءة', Icons.book),
                    SizedBox(height: 10),
                    _buildSettingsCard(
                      context,
                      [
                        _buildFontSizeControl(),
                        Divider(height: 1, indent: 70),
                        _buildArabicFontSelector(),
                      ],
                    ),
                    SizedBox(height: 25),
                    Text(
                      "المظهر",
                      style: TextStyle(fontSize: 20),
                    ),

                    // _buildSectionHeader(context, 'المظهر', Icons.palette),
                    SizedBox(height: 10),
                    _buildSettingsCard(
                      context,
                      [
                        _buildDarkModeToggle(),
                      ],
                    ),
                    SizedBox(height: 25),
                    Text(
                      "حول التطبيق",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 10),
                    _buildSettingsCard(
                      context,
                      [
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: AppColor.primaryColor,
                          ),
                          title: GetX<SettingsController>(
                            builder: (controller) => Text(
                              'عن التطبيق',
                              style: TextStyle(
                                color: controller.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => QuranAboutDialog(),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 70),
                        ListTile(
                          leading: Icon(
                            Icons.contact_mail,
                            color: AppColor.primaryColor,
                          ),
                          title: GetX<SettingsController>(
                            builder: (controller) => Text(
                              'تواصل معنا',
                              style: TextStyle(
                                color: controller.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            'عبر LinkedIn أو البريد الإلكتروني',
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey,
                          ),
                          onTap: () => _launchLinkedIn(context),
                        ),
                        Divider(height: 1, indent: 70),
                        ListTile(
                          leading: Icon(
                            Icons.star_outline,
                            color: AppColor.primaryColor,
                          ),
                          title: GetX<SettingsController>(
                            builder: (controller) => Text(
                              'تقييم التطبيق',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: controller.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: "BahijTheSansArabic"),
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey,
                          ),
                          onTap: () => _showRatingSnackbar(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControl() {
    return GetX<SettingsController>(
        builder: (controller) => ListTile(
              leading: Icon(
                Icons.format_size,
                color: AppColor.primaryColor,
              ),
              title: Text(
                'حجم الخط',
                style: TextStyle(
                    color: controller.isDarkMode.value
                        ? Colors.white
                        : Colors.black,
                    fontFamily: "BahijTheSansArabic"),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    '${controller.fontSize.value.toStringAsFixed(1)} بكسل',
                  ),
                  Container(
                    height: 40,
                    child: Slider(
                      value: controller.fontSize.value,
                      min: 18,
                      max: 36,
                      divisions: 6,
                      label: controller.fontSize.value.toStringAsFixed(1),
                      activeColor: AppColor.primaryColor,
                      inactiveColor: AppColor.primaryColor.withOpacity(0.2),
                      onChanged: (value) {
                        controller.setFontSize(value);
                      },
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildArabicFontSelector() {
    return GetX<SettingsController>(
        builder: (controller) => ListTile(
              leading: Icon(
                Icons.font_download,
                color: AppColor.primaryColor,
              ),
              title: Text(
                'نوع الخط العربي',
                style: TextStyle(
                  color:
                      controller.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(top: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: controller.fontOptions.map((fontOption) {
                      bool isSelected =
                          controller.arabicFont.value == fontOption.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            fontOption.arabicName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white
                                  : controller.isDarkMode.value
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColor.primaryColor,
                          backgroundColor: controller.isDarkMode.value
                              ? Colors.grey[800]
                              : AppColor.primaryColor.withOpacity(0.1),
                          onSelected: (selected) {
                            if (selected)
                              controller.setArabicFont(fontOption.id);
                          },
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ));
  }

  Widget _buildDarkModeToggle() {
    return GetX<SettingsController>(
        builder: (controller) => SwitchListTile(
              title: Text(
                'الوضع الليلي',
                style: TextStyle(
                  color:
                      controller.isDarkMode.value ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                controller.isDarkMode.value ? 'مفعل' : 'غير مفعل',
              ),
              value: controller.isDarkMode.value,
              onChanged: (value) {
                controller.toggleTheme();
              },
              secondary: Icon(
                controller.isDarkMode.value
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppColor.primaryColor,
              ),
              activeColor: AppColor.primaryColor,
            ));
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return GetX<SettingsController>(
        builder: (controller) => Container(
              decoration: BoxDecoration(
                color: controller.isDarkMode.value
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: controller.isDarkMode.value
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: children,
              ),
            ));
  }

  // Helper methods

  void _launchLinkedIn(BuildContext context) async {
    const linkedInUrl = 'https://www.linkedin.com/in/mohamed-salah-9804a2247/';
    if (await canLaunch(linkedInUrl)) {
      await launch(linkedInUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الرابط'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRatingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('شكرا لدعمكم للتطبيق'),
        backgroundColor: AppColor.primaryColor,
        action: SnackBarAction(
          label: 'التقييم',
          textColor: Colors.white,
          onPressed: () {
            // Open app store
          },
        ),
      ),
    );
  }
}

// Islamic pattern painter for header decoration
class IslamicHeaderPainter extends CustomPainter {
  final Color color;

  IslamicHeaderPainter({this.color = Colors.black12});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create a repeating pattern of Islamic arches
    final patternWidth = size.width / 5;

    for (int i = 0; i < 5; i++) {
      double startX = i * patternWidth;
      double endX = (i + 1) * patternWidth;
      double centerX = (startX + endX) / 2;

      path.moveTo(startX, size.height);
      path.quadraticBezierTo(centerX, size.height * 0.3, endX, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Islamic pattern painter (reused from your original code)
class IslamicPatternPainter extends CustomPainter {
  final Color color;

  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create more elaborate Islamic geometric pattern
    final patternSize = size.width / 10;

    for (int i = 0; i < 10; i++) {
      // Draw geometric elements
      double x = i * patternSize;

      final path = Path();
      path.moveTo(x, 0);
      path.lineTo(x + patternSize, 0);
      path.lineTo(x + patternSize * 0.75, size.height);
      path.lineTo(x + patternSize * 0.25, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
