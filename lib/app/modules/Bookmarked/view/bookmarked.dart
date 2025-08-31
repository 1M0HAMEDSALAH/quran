import 'package:quran_app/index.dart';



// ignore: use_key_in_widget_constructors
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
