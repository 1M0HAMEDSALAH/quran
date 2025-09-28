import 'package:quran_app/index.dart';


class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int highlightedVerse;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.highlightedVerse = 0,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final bookmarkController = Get.put(BookmarkController());
  final settingsController = Get.put(SettingsController());
  final ScrollController _scrollController = ScrollController();

  void _showOptions(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl, // ← هذا هو السطر الأهم
          child: Wrap(
            children: [
              ListTile(
                title: Text(
                  "🕌 عرض تفسير السورة",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                // onTap: () {
                //   Navigator.pop(context);
                // },
              ),
              ListTile(
                title: Text(
                  "🎧 تشغيل سورة ${getSurahNameArabic(widget.surahNumber)}",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(QuranPlayerScreen(
                    surahNumber: widget.surahNumber,
                    surahName: getSurahNameArabic(widget.surahNumber),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDarkMode ? null : Colors.white,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: isDarkMode ? null : Colors.teal[700],
                elevation: 0,
                pinned: true,
                expandedHeight: widget.surahNumber != 9 ? 100.0 : 60.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    getSurahNameArabic(widget.surahNumber),
                    style: const TextStyle(
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
                    icon: Icon(
                      Icons.more_vert,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              if (widget.surahNumber != 9)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode ? null : Colors.teal[700],
                      borderRadius: const BorderRadius.only(
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
                            offset: const Offset(2, 2),
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
              color: isDarkMode ? null : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        height: 2.5,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                      children: _buildVerses(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      if (widget.surahNumber == 114) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DuaScreen(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SurahDetailScreen(
                              surahNumber: widget.surahNumber + 1,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white10
                            : const Color(0xFF1F6E8C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            color: isDarkMode
                                ? Colors.white70
                                : const Color(0xFF1F6E8C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'اضغط للانتقال إلى السورة التالية',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF1F6E8C),
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
    final isDarkMode = settingsController.isDarkMode.value;

    for (int i = 1; i <= verseCount; i++) {
      final verse = getVerse(widget.surahNumber, i);
      final isHighlighted = i == widget.highlightedVerse;

      final fontFamily = settingsController.arabicFontFamily;

      spans.addAll([
        TextSpan(
          text: verse,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: settingsController.fontSize.value,
            color: isHighlighted
                ? Colors.red
                : isDarkMode
                    ? Colors.white
                    : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                builder: (context) => AudioPlayerDialog(
                  surahNumber: widget.surahNumber,
                  verseNumber: i,
                  verseText: verse,
                ),
              );
            },
            onLongPress: () {
              bookmarkController.toggleBookmark({
                'surah': getSurahName(widget.surahNumber),
                'verse': verse,
                'surahNumber': widget.surahNumber.toString(),
                'verseNumber': i.toString(),
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.red.withOpacity(0.1)
                    : isDarkMode
                        ? Colors.white12
                        : const Color(0xFF1F6E8C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '\uFD3F${i.toString()}\uFD3E',
                        style: TextStyle(
                          fontFamily: fontFamily,
                          color: isHighlighted
                              ? Colors.red
                              : isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF1F6E8C),
                          fontSize: settingsController.fontSize.value,
                        ),
                      ),
                      if (bookmarkController.isBookmarked(
                          widget.surahNumber, i))
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.bookmark,
                            color: isHighlighted
                                ? Colors.red
                                : isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF1F6E8C),
                            size: 16,
                          ),
                        ),
                    ],
                  )),
            ),
          ),
        ),
        const TextSpan(text: ''),
      ]);
    }

    return spans;
  }
}
