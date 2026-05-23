import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/app/modules/Setting/view/widgets/about_dialog.dart';
import 'package:quran_app/app/routes/app_routes.dart';
import 'package:quran_app/qibla_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/setting_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  static const Color _primaryDark = Color(0xFF0F3E33);
  static const Color _primaryLight = Color(0xFF165A4B);
  static const Color _goldAccent = Color(0xFFCDA047);
  static const Color _bgLight = Color(0xFFF9F6F0);
  static const Color _bgDark = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetX<SettingsController>(builder: (controller) {
        final isDarkMode = controller.isDarkMode.value;
        return Scaffold(
          backgroundColor: isDarkMode ? _bgDark : _bgLight,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120.0,
                backgroundColor: isDarkMode ? _bgDark : _bgLight,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: isDarkMode ? Colors.white : _primaryDark,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("إعدادات القراءة", isDarkMode),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDarkMode,
                        [
                          _buildFontSizeControl(isDarkMode),
                          Divider(
                              height: 1,
                              indent: 70,
                              color:
                                  isDarkMode ? Colors.white10 : Colors.black12),
                          _buildArabicFontSelector(isDarkMode),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle("المظهر", isDarkMode),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDarkMode,
                        [
                          _buildDarkModeToggle(isDarkMode),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle("أدوات دينية", isDarkMode),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDarkMode,
                        [
                          _buildActionTile(
                            icon: Icons.access_time_filled_rounded,
                            title: 'مواقيت الصلاة',
                            subtitle: 'مواعيد الصلاة والأذان',
                            isDarkMode: isDarkMode,
                            onTap: () => Get.toNamed(Routes.PRAYER_TIMES),
                          ),
                          Divider(
                              height: 1,
                              indent: 70,
                              color:
                                  isDarkMode ? Colors.white10 : Colors.black12),
                          _buildActionTile(
                            icon: Icons.explore_rounded,
                            title: 'اتجاه القبلة',
                            subtitle: 'تحديد اتجاه القبلة باستخدام البوصلة',
                            isDarkMode: isDarkMode,
                            onTap: () => Get.to(() => const QiblaScreen()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle("حول التطبيق", isDarkMode),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDarkMode,
                        [
                          _buildActionTile(
                            icon: Icons.info_outline,
                            title: 'عن التطبيق',
                            isDarkMode: isDarkMode,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => QuranAboutDialog(),
                              );
                            },
                          ),
                          Divider(
                              height: 1,
                              indent: 70,
                              color:
                                  isDarkMode ? Colors.white10 : Colors.black12),
                          _buildActionTile(
                            icon: Icons.contact_mail,
                            title: 'تواصل معنا',
                            subtitle: 'عبر LinkedIn أو البريد الإلكتروني',
                            isDarkMode: isDarkMode,
                            onTap: () => _launchLinkedIn(context),
                          ),
                          Divider(
                              height: 1,
                              indent: 70,
                              color:
                                  isDarkMode ? Colors.white10 : Colors.black12),
                          _buildActionTile(
                            icon: Icons.star_outline,
                            title: 'تقييم التطبيق',
                            isDarkMode: isDarkMode,
                            onTap: () => _showRatingSnackbar(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.diamond_outlined, size: 14, color: _goldAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              color: isDarkMode ? _goldAccent.withOpacity(0.9) : _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeControl(bool isDarkMode) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryLight.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.format_size, color: _primaryDark),
      ),
      title: Text(
        'حجم الخط',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: "Amiri",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${controller.fontSize.value.toStringAsFixed(1)} بكسل',
            style:
                TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
          ),
          SizedBox(
            height: 40,
            child: Slider(
              value: controller.fontSize.value,
              min: 18,
              max: 42,
              divisions: 8,
              label: controller.fontSize.value.toStringAsFixed(1),
              activeColor: _primaryDark,
              inactiveColor: _primaryLight.withOpacity(0.2),
              onChanged: (value) => controller.setFontSize(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicFontSelector(bool isDarkMode) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryLight.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.font_download, color: _primaryDark),
      ),
      title: Text(
        'نوع الخط العربي',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: "Amiri",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            textDirection: TextDirection.rtl,
            children: controller.fontOptions.map((fontOption) {
              bool isSelected = controller.arabicFont.value == fontOption.id;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    fontOption.arabicName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode ? Colors.white70 : Colors.black87),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: _primaryDark,
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : _primaryLight.withOpacity(0.08),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? _primaryDark : Colors.transparent,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) controller.setArabicFont(fontOption.id);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(bool isDarkMode) {
    return SwitchListTile(
      title: Text(
        'الوضع الليلي',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: "Amiri",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        isDarkMode ? 'مفعل' : 'مغلق',
        style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
      ),
      value: isDarkMode,
      onChanged: (value) => controller.toggleTheme(),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryLight.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: _primaryDark,
        ),
      ),
      activeColor: _goldAccent,
      activeTrackColor: _primaryDark,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryLight.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _primaryDark),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: "Amiri",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black54),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingsCard(bool isDarkMode, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  spreadRadius: 2,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Helper methods
  void _launchLinkedIn(BuildContext context) async {
    final Uri linkedInUrl =
        Uri.parse('https://www.linkedin.com/in/mohamed-salah-9804a2247');

    try {
      await launchUrl(
        linkedInUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الرابط'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRatingSnackbar(BuildContext context) async {
    final Uri playStoreUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.mohamedsalah.quran&pli=1');

    try {
      await launchUrl(
        playStoreUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الرابط'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
