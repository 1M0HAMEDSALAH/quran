import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/app/modules/Setting/view/widgets/about_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/const/app_theme.dart';
import '../controller/setting_controller.dart';



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
        content: const Text('شكرا لدعمكم للتطبيق'),
        backgroundColor: AppColor.primaryColor,
      ),
    );
  }
}

