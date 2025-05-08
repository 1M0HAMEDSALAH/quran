import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/app_theme.dart';

class SettingsController extends GetxController {
  final storage = GetStorage();
  final fontSize = 22.0.obs;
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fontSize.value = storage.read('fontSize') ?? 22.0;
    isDarkMode.value = storage.read('isDarkMode') ?? false;
  }

  void setFontSize(double size) {
    fontSize.value = size;
    storage.write('fontSize', size);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    storage.write('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

class AboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.teal[700]!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book,
                  size: 40,
                  color: Color(0xFF1F6E8C),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'تطبيق القرآن الكريم',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'هذا التطبيق تم تطويره لوجه الله تعالى\nولا نبتغي به مالاً ولا شهرة',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'اللهم اجعله في ميزان حسناتنا',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1F6E8C),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
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
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          title: Text(
            'الإعدادات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.teal[700]!,
                Colors.teal[700]!.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: [
                      // إعدادات حجم الخط والوضع الليلي
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.format_size,
                                color: Color(0xFF1F6E8C),
                              ),
                              title: Text(
                                'حجم الخط',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Obx(() => Slider(
                                    value: controller.fontSize.value,
                                    min: 18,
                                    max: 36,
                                    divisions: 6,
                                    label: controller.fontSize.value
                                        .toStringAsFixed(1),
                                    onChanged: (value) {
                                      controller.setFontSize(value);
                                    },
                                  )),
                            ),
                            Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.dark_mode,
                                color: Color(0xFF1F6E8C),
                              ),
                              title: Text(
                                'الوضع الليلي',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              trailing: Obx(() => Switch(
                                    value: controller.isDarkMode.value,
                                    onChanged: (value) {
                                      controller.toggleTheme();
                                    },
                                    activeColor: Color(0xFF1F6E8C),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // قسم حول التطبيق
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: Color(0xFF1F6E8C),
                          ),
                          title: Text(
                            'حول التطبيق',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AboutDialog(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),

                      // زر LinkedIn
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.contact_mail,
                            color: Color(0xFF1F6E8C),
                          ),
                          title: Text(
                            'تواصل معنا عبر LinkedIn',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () async {
                            const linkedInUrl =
                                'https://www.linkedin.com/in/mohamed-salah-9804a2247/';
                            if (await canLaunch(linkedInUrl)) {
                              await launch(linkedInUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تعذر فتح الرابط'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}