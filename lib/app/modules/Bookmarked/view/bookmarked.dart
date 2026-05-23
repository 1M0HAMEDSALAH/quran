import 'package:quran_app/index.dart';

// ignore: use_key_in_widget_constructors
class BookmarkScreen extends StatelessWidget {
  final BookmarkController controller = Get.put(BookmarkController());
  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;
    final primaryColor = const Color(0xFF0F3E33);
    final goldAccent = const Color(0xFFCDA047);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'المفضلة',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? goldAccent : primaryColor,
                fontFamily: "Amiri"),
          ),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkMode ? goldAccent : primaryColor,
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/islamic_pattern.png'),
              opacity: isDarkMode ? 0.05 : 0.03,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Obx(() {
            return _buildBookmarkContent(isDarkMode, primaryColor, goldAccent);
          }),
        ),
      ),
    );
  }

  Widget _buildBookmarkContent(
      bool isDarkMode, Color primaryColor, Color goldAccent) {
    if (controller.bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white10
                    : primaryColor.withOpacity(0.05),
              ),
              child: Icon(
                Icons.bookmark_outline,
                size: 80,
                color: isDarkMode
                    ? goldAccent.withOpacity(0.5)
                    : primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد آيات في المفضلة',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? goldAccent : primaryColor,
                  fontFamily: "Amiri"),
            ),
            const SizedBox(height: 12),
            Text(
              'يمكنك إضافة الآيات إلى المفضلة أثناء القراءة',
              style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                  fontFamily: "Amiri"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: goldAccent,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
              margin: const EdgeInsets.only(bottom: 16),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFC62828)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_sweep,
                color: Colors.white,
                size: 32,
              ),
            ),
            onDismissed: (direction) {
              controller.toggleBookmark(bookmark);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white10
                      : primaryColor.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Get.to(SurahDetailScreen(
                      surahNumber: int.parse(bookmark['surahNumber']),
                      highlightedVerse: int.parse(bookmark['verseNumber']),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? goldAccent.withOpacity(0.1)
                                    : primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.bookmark,
                                color: isDarkMode ? goldAccent : primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'سورة ${bookmark["surah"]}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? goldAccent : primaryColor,
                                  fontFamily: "Amiri"),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDarkMode
                                        ? goldAccent.withOpacity(0.3)
                                        : primaryColor.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'آية ${bookmark["verseNumber"]}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontFamily: "Amiri"),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookmark["verse"]!,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.8,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black87,
                            fontFamily: settingsController.arabicFontFamily,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        Divider(
                            color:
                                isDarkMode ? Colors.white10 : Colors.black12),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.access_time,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.white38
                                    : Colors.black38),
                            const SizedBox(width: 4),
                            Text(
                              'أُضيفت: ${bookmark["date"]}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                  fontFamily: "Amiri"),
                            ),
                          ],
                        ),
                      ],
                    ),
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
