import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran_app/contian/displaysurrah.dart';
import 'package:quran_app/contian/setting.dart';

import '../const/app_theme.dart';

class BookmarkController extends GetxController {
  final storage = GetStorage();
  final bookmarks = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    super.onReady();
    loadBookmarks(); // تحميل البيانات عند فتح الشاشة
  }

  void loadBookmarks() {
    final savedBookmarks = storage.read<List>('bookmarks') ?? [];
    bookmarks.assignAll(
        savedBookmarks.map((item) => Map<String, dynamic>.from(item)));
  }

  void toggleBookmark(Map<String, dynamic> verse) {
    final exists = bookmarks.any((bookmark) =>
        bookmark['surahNumber'] == verse['surahNumber'] &&
        bookmark['verseNumber'] == verse['verseNumber']);

    if (exists) {
      bookmarks.removeWhere((bookmark) =>
          bookmark['surahNumber'] == verse['surahNumber'] &&
          bookmark['verseNumber'] == verse['verseNumber']);
      Get.snackbar(
        'تم الحذف',
        'تم حذف الآية من المفضلة',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      bookmarks.add({
        ...verse,
        'date': DateTime.now().toString().split(' ')[0],
      });
      Get.snackbar(
        'تمت الإضافة',
        'تم إضافة الآية إلى المفضلة',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }

    storage.write('bookmarks', bookmarks.toList());
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return bookmarks.any((bookmark) =>
        bookmark['surahNumber'] == surahNumber.toString() &&
        bookmark['verseNumber'] == verseNumber.toString());
  }
}

class BookmarkScreen extends StatelessWidget {
  final BookmarkController controller = Get.put(BookmarkController());
  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'المفضلة',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,fontFamily: "BahijTheSansArabic"
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Obx(() {
          return Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1F6E8C).withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
              color: isDarkMode ? Colors.grey[900] : null,
            ),
            child: _buildBookmarkContent(isDarkMode),
          );
        }),
      ),
    );
  }

  Widget _buildBookmarkContent(bool isDarkMode) {
    if (controller.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد آيات في المفضلة',
              style: TextStyle(
                fontSize: 20,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],fontFamily: "BahijTheSansArabic"
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إضافة الآيات إلى المفضلة أثناء القراءة',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],fontFamily: "BahijTheSansArabic"
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        controller.loadBookmarks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = controller.bookmarks[index];
          return Dismissible(
            key: Key(index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
            onDismissed: (direction) {
              controller.toggleBookmark(bookmark);
            },
            child: Card(
              elevation: isDarkMode ? 0 : 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(SurahDetailScreen(
                    surahNumber: int.parse(bookmark['surahNumber']),
                    highlightedVerse: int.parse(bookmark['verseNumber']),
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            color: AppColor.primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'سورة ${bookmark["surah"]}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primaryColor,fontFamily: "BahijTheSansArabic"
                            ),
                          ),
                          Spacer(),
                          Text(
                            'الآية ${bookmark["verseNumber"]}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],fontFamily: "BahijTheSansArabic"
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        bookmark["verse"]!,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.8,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontFamily: settingsController.arabicFontFamily,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'تمت الإضافة: ${bookmark["date"]}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
