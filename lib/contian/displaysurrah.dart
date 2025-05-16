import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart';
import 'package:quran_app/contian/bookmarked.dart';
import 'package:quran_app/contian/setting.dart';
import 'package:quran_app/contian/sound.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int highlightedVerse;

  SurahDetailScreen({required this.surahNumber, this.highlightedVerse = 0});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final bookmarkController = Get.put(BookmarkController());
  final settingsController = Get.put(SettingsController());
  final ScrollController _scrollController = ScrollController();

  // زر تشغيل الصوت مع تحديد رقم الآية
  void _showOptions(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              title: Text(
                "🕌 عرض تفسير السورة",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                "🎧 تشغيل سورة ${getSurahNameArabic(widget.surahNumber)}",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              onTap: () {
                Get.to(QuranPlayerScreen(
                  surahNumber: widget.surahNumber,
                  surahName: getSurahNameArabic(widget.surahNumber),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.teal[700],
                elevation: 0,
                pinned: true,
                expandedHeight: widget.surahNumber != 9 ? 100.0 : 60.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    getSurahNameArabic(widget.surahNumber),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      _showOptions(context);
                    },
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
              if (widget.surahNumber != 9)
                SliverToBoxAdapter(
                  child: Container(
                    //margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.teal[700],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                    ),
                    child: Text(
                      "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ];
          },
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        height: 2.5,
                        color: Colors.black87,
                      ),
                      children: _buildVerses(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(
                            surahNumber: widget.surahNumber + 1,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFF1F6E8C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF1F6E8C),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'اضغط للانتقال إلى السورة التالية',
                            style: TextStyle(
                              color: Color(0xFF1F6E8C),
                              fontSize: 14,
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
        ),
      ),
    );
  }

  List<InlineSpan> _buildVerses() {
    List<InlineSpan> spans = [];
    int verseCount = getVerseCount(widget.surahNumber);
    final settingsController = Get.find<SettingsController>();

    for (int i = 1; i <= verseCount; i++) {
      final verse = getVerse(widget.surahNumber, i);
      final isHighlighted = i == widget.highlightedVerse;

      // Get the font family from settings controller
      final fontFamily = settingsController.arabicFontFamily;

      spans.addAll([
        TextSpan(
          text: verse,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: settingsController.fontSize.value,
            color: isHighlighted ? Colors.red : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onLongPress: () {
              bookmarkController.toggleBookmark({
                'surah': getSurahName(widget.surahNumber),
                'verse': verse,
                'surahNumber': widget.surahNumber.toString(),
                'verseNumber': i.toString(),
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.red.withOpacity(0.1)
                    : Color(0xFF1F6E8C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\uFD3F${i.toString()}\uFD3E',
                        style: TextStyle(
                          fontFamily:
                              fontFamily, // Apply the same font to verse numbers
                          color: isHighlighted ? Colors.red : Color(0xFF1F6E8C),
                          fontSize: settingsController.fontSize.value,
                        ),
                      ),
                      if (bookmarkController.isBookmarked(
                          widget.surahNumber, i))
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.bookmark,
                            color:
                                isHighlighted ? Colors.red : Color(0xFF1F6E8C),
                            size: 16,
                          ),
                        ),
                    ],
                  )),
            ),
          ),
        ),
        TextSpan(text: ' '),
      ]);
    }

    return spans;
  }
}
