import 'package:quran_app/app/modules/Sura/reading_position_service.dart';
import 'package:quran_app/index.dart';
import 'package:just_audio/just_audio.dart';

class QuranVerse {
  final int surah;
  final int verse;
  const QuranVerse({required this.surah, required this.verse});
}

class QuranPageData {
  static final Map<int, List<QuranVerse>> _pageVersesCache = _buildPageCache();

  static Map<int, List<QuranVerse>> _buildPageCache() {
    final Map<int, List<QuranVerse>> map = {
      for (int page = 1; page <= 604; page++) page: <QuranVerse>[],
    };

    for (int surah = 1; surah <= 114; surah++) {
      final int verseCount = getVerseCount(surah);
      for (int verse = 1; verse <= verseCount; verse++) {
        final int page = getPageNumber(surah, verse);
        if (page >= 1 && page <= 604) {
          map[page]!.add(QuranVerse(surah: surah, verse: verse));
        }
      }
    }

    return map;
  }

  static List<QuranVerse> versesOnPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return [];
    return List<QuranVerse>.unmodifiable(
        _pageVersesCache[pageNumber] ?? const []);
  }

  static int surahForPage(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return 1;
    return getPageNumber(surahNumber, 1);
  }

  static String surahNameForPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return '';
    final verses = versesOnPage(pageNumber);
    if (verses.isEmpty) return '';
    return getSurahNameArabic(verses.first.surah);
  }
}

// ─────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────

class QuranPageController extends GetxController {
  final RxInt currentPage = 1.obs;
  final RxInt highlightedSurah = 0.obs;
  final RxInt highlightedVerse = 0.obs;
  final RxBool isAutoReading = false.obs;
  final RxString currentSurahName = ''.obs;

  /// The surah number currently visible/active on screen.
  /// Updated whenever the page changes or a verse is tapped.
  /// Used by the options bottom sheet to know which surah to act on.
  final RxInt activeSurah = 1.obs;

  late final AudioPlayer _player;

  PageController? _pageViewController;

  static const List<int> _ayahOffsets = [
    0,
    7,
    293,
    493,
    669,
    789,
    954,
    1160,
    1235,
    1364,
    1473,
    1596,
    1707,
    1750,
    1802,
    1901,
    2029,
    2140,
    2250,
    2348,
    2483,
    2595,
    2673,
    2791,
    2855,
    2932,
    3159,
    3252,
    3340,
    3409,
    3469,
    3503,
    3533,
    3606,
    3660,
    3705,
    3788,
    3970,
    4058,
    4133,
    4218,
    4272,
    4325,
    4414,
    4473,
    4510,
    4545,
    4583,
    4612,
    4630,
    4675,
    4735,
    4784,
    4846,
    4901,
    4979,
    5075,
    5104,
    5126,
    5150,
    5163,
    5177,
    5188,
    5199,
    5217,
    5229,
    5241,
    5271,
    5323,
    5375,
    5419,
    5447,
    5475,
    5495,
    5551,
    5591,
    5622,
    5672,
    5712,
    5758,
    5800,
    5829,
    5848,
    5884,
    5909,
    5931,
    5948,
    5967,
    5993,
    6023,
    6043,
    6058,
    6079,
    6090,
    6098,
    6106,
    6125,
    6130,
    6138,
    6146,
    6157,
    6168,
    6176,
    6179,
    6188,
    6193,
    6197,
    6204,
    6207,
    6213,
    6216,
    6221,
    6225,
    6230,
    6236,
  ];

  List<QuranVerse> _sessionVerses = [];
  int _sessionIndex = 0;

  /// The surah we are reading — reading stops when this surah ends.
  int _targetSurah = 0;

  @override
  void onInit() {
    super.onInit();
    _player = AudioPlayer();
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }

  void attachPageController(PageController c) => _pageViewController = c;

  void goToPage(int page, {bool save = true}) {
    if (page < 1 || page > 604) return;
    currentPage.value = page;
    currentSurahName.value = QuranPageData.surahNameForPage(page);

    // Keep activeSurah in sync with the first surah on this page.
    final verses = QuranPageData.versesOnPage(page);
    if (verses.isNotEmpty) activeSurah.value = verses.first.surah;

    if (save) _saveCurrentPosition();
  }

  void onVerseTapped({
    required int surah,
    required int verse,
    required List<QuranVerse> pageVerses,
  }) {
    stopAutoRead();

    final startIndex = pageVerses.indexWhere(
      (v) => v.surah == surah && v.verse == verse,
    );
    if (startIndex == -1) return;

    highlightedSurah.value = surah;
    highlightedVerse.value = verse;
    activeSurah.value = surah;
    _savePosition(surah, verse);

    _targetSurah = surah;
    _sessionVerses = _buildSurahSession(surah: surah, fromVerse: verse);
    _sessionIndex = 0;

    isAutoReading.value = true;
    _readCurrentSessionVerse();
  }

  List<QuranVerse> _buildSurahSession({
    required int surah,
    required int fromVerse,
  }) {
    final int totalVerses = getVerseCount(surah);
    return [
      for (int v = fromVerse; v <= totalVerses; v++)
        QuranVerse(surah: surah, verse: v),
    ];
  }

  void stopAutoRead() {
    isAutoReading.value = false;
    highlightedSurah.value = 0;
    highlightedVerse.value = 0;
    _player.stop();
    _sessionVerses = [];
    _sessionIndex = 0;
    _targetSurah = 0;
  }

  Future<void> _readCurrentSessionVerse() async {
    if (!isAutoReading.value) return;

    if (_sessionIndex >= _sessionVerses.length) {
      stopAutoRead();
      return;
    }

    final current = _sessionVerses[_sessionIndex];

    if (current.surah != _targetSurah) {
      stopAutoRead();
      return;
    }

    highlightedSurah.value = current.surah;
    highlightedVerse.value = current.verse;
    _savePosition(current.surah, current.verse);

    final versePage = getPageNumber(current.surah, current.verse);
    if (versePage != currentPage.value) {
      _pageViewController?.animateToPage(
        versePage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      goToPage(versePage, save: false);

      await Future.delayed(const Duration(milliseconds: 450));
      if (!isAutoReading.value) return;
    }

    final globalAyah = _globalAyah(current.surah, current.verse);
    final url =
        'https://cdn.islamic.network/quran/audio/192/ar.abdulbasitmurattal/$globalAyah.mp3';

    try {
      await _player.setUrl(url);
      await _player.play();
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed,
      );
      if (!isAutoReading.value) return;
      _sessionIndex++;
      _readCurrentSessionVerse();
    } catch (_) {
      stopAutoRead();
    }
  }

  int _globalAyah(int surah, int verse) {
    if (surah < 1 || surah > _ayahOffsets.length) return verse;
    return _ayahOffsets[surah - 1] + verse;
  }

  Future<void> _saveCurrentPosition() async {
    final verses = QuranPageData.versesOnPage(currentPage.value);
    if (verses.isEmpty) return;

    final int hs = highlightedSurah.value;
    final int hv = highlightedVerse.value;
    if (hs > 0 && hv > 0 && verses.any((v) => v.surah == hs && v.verse == hv)) {
      _savePosition(hs, hv);
      return;
    }

    _savePosition(verses.first.surah, verses.first.verse);
  }

  void _savePosition(int surah, int verse) {
    ReadingPositionService.savePosition(
      surahNumber: surah,
      verseNumber: verse,
      pageNumber: currentPage.value,
    );
  }

  Future<void> jumpToLastPosition(PageController pageViewController) async {
    final pos = await ReadingPositionService.loadPosition();
    if (pos == null) {
      Get.snackbar(
        'لا يوجد موضع محفوظ',
        'لم تقم بحفظ أي موضع بعد.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    goToPage(pos.pageNumber, save: false);
    pageViewController.jumpToPage(pos.pageNumber - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      highlightedSurah.value = pos.surahNumber;
      highlightedVerse.value = pos.verseNumber;
    });
  }
}

// ─────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────

class QuranPageViewScreen extends StatefulWidget {
  final int initialPage;
  final int? highlightSurah;
  final int? highlightVerse;

  const QuranPageViewScreen({
    super.key,
    this.initialPage = 1,
    this.highlightSurah,
    this.highlightVerse,
  });

  @override
  State<QuranPageViewScreen> createState() => _QuranPageViewScreenState();
}

class _QuranPageViewScreenState extends State<QuranPageViewScreen> {
  late final QuranPageController _ctrl;
  late final PageController _pageCtrl;
  late final SettingsController _settings;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(QuranPageController());
    _settings = Get.find<SettingsController>();
    _pageCtrl = PageController(initialPage: widget.initialPage - 1);

    _ctrl.attachPageController(_pageCtrl);

    _ctrl.currentPage.value = widget.initialPage;
    _ctrl.currentSurahName.value =
        QuranPageData.surahNameForPage(widget.initialPage);

    // Set initial activeSurah
    final initialVerses = QuranPageData.versesOnPage(widget.initialPage);
    if (initialVerses.isNotEmpty) {
      _ctrl.activeSurah.value = initialVerses.first.surah;
    }

    if (widget.highlightSurah != null && widget.highlightVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.highlightedSurah.value = widget.highlightSurah!;
        _ctrl.highlightedVerse.value = widget.highlightVerse!;
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.isDarkMode.value;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0D1117) : const Color(0xFFFDF6E3),
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageCtrl,
                itemCount: 604,
                onPageChanged: (index) => _ctrl.goToPage(index + 1),
                itemBuilder: (context, index) => _QuranPage(
                  pageNumber: index + 1,
                  ctrl: _ctrl,
                  settings: _settings,
                  isDark: isDark,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopBar(
                  ctrl: _ctrl,
                  pageCtrl: _pageCtrl,
                  isDark: isDark,
                ),
              ),
              Obx(() {
                if (!_ctrl.isAutoReading.value) return const SizedBox.shrink();
                return Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _StopReadingButton(onStop: _ctrl.stopAutoRead),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Single Quran page
// ─────────────────────────────────────────────────────────

class _QuranPage extends StatelessWidget {
  final int pageNumber;
  final QuranPageController ctrl;
  final SettingsController settings;
  final bool isDark;

  const _QuranPage({
    required this.pageNumber,
    required this.ctrl,
    required this.settings,
    required this.isDark,
  });

  Color get _verseTextColor =>
      isDark ? const Color(0xFFD4C9A8) : const Color(0xFF2C1F08);

  Color get _accentColor =>
      isDark ? const Color(0xFFCDA047) : const Color(0xFF0F3E33);

  Color get _headerFill =>
      isDark ? const Color(0xFF1F1A10) : const Color(0xFFF6E7C8);

  Color get _headerText =>
      isDark ? const Color(0xFFE5D29A) : const Color(0xFF7A5C1E);

  Color get _headerBorder =>
      isDark ? const Color(0xFFB8A76A) : const Color(0xFF7A5C1E);

  Color get _outerBorder =>
      isDark ? const Color(0xFF8C7A43) : const Color(0xFF8B6B2E);

  Color get _innerBorder =>
      isDark ? const Color(0xFFCFB97B) : const Color(0xFFB0893D);

  @override
  Widget build(BuildContext context) {
    final verses = QuranPageData.versesOnPage(pageNumber);
    final fontFamily = settings.arabicFontFamily;

    return LayoutBuilder(builder: (context, constraints) {
      final baseFontSize = constraints.maxWidth < 500
          ? settings.fontSize.value
          : settings.fontSize.value + 4.0;
      final isCompactHeight = constraints.maxHeight < 700;
      final horizontalPadding =
          constraints.maxWidth * (constraints.maxWidth < 360 ? 0.004 : 0.01);
      final topPadding =
          constraints.maxHeight * (isCompactHeight ? 0.018 : 0.08);
      final bottomPadding =
          constraints.maxHeight * (isCompactHeight ? 0.01 : 0.02);

      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFFDF6E3),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D1A12), Color(0xFF141210)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8E8), Color(0xFFF8E9C9)],
                    ),
              border: Border.all(color: _outerBorder, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _innerBorder, width: 1.1),
                  color: isDark
                      ? const Color(0xFF141210)
                      : const Color(0xFFFFFDF7),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
                  child: Obx(() {
                    final hSurah = ctrl.highlightedSurah.value;
                    final hVerse = ctrl.highlightedVerse.value;
                    final hasSurahStartOnPage = verses.any((v) => v.verse == 1);
                    final contentSpans = _buildSpans(
                      verses: verses,
                      highlightSurah: hSurah,
                      highlightVerse: hVerse,
                      baseFontSize: baseFontSize,
                      fontFamily: fontFamily,
                    );

                    return ClipRect(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: constraints.maxWidth -
                              (horizontalPadding * 2) -
                              6,
                          child: RichText(
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: baseFontSize,
                                height: hasSurahStartOnPage ? 2.0 : 2.15,
                                color: _verseTextColor,
                              ),
                              children: contentSpans,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<InlineSpan> _buildSpans({
    required List<QuranVerse> verses,
    required int highlightSurah,
    required int highlightVerse,
    required double baseFontSize,
    required String fontFamily,
  }) {
    final List<InlineSpan> spans = [];

    for (final v in verses) {
      if (v.verse == 1) {
        spans.add(_buildSurahHeader(
          surah: v.surah,
          baseFontSize: baseFontSize,
          fontFamily: fontFamily,
        ));

        if (_showBasmala(v.surah)) {
          spans.add(_buildBasmala(
            baseFontSize: baseFontSize,
            fontFamily: fontFamily,
          ));
        }
      }

      final text = getVerse(v.surah, v.verse);
      final isHighlight =
          v.surah == highlightSurah && v.verse == highlightVerse;

      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: baseFontSize,
          fontWeight: FontWeight.bold,
          color: isHighlight ? _accentColor : _verseTextColor,
          backgroundColor:
              isHighlight ? _accentColor.withOpacity(0.13) : Colors.transparent,
        ),
      ));

      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: () {
            ctrl.onVerseTapped(
              surah: v.surah,
              verse: v.verse,
              pageVerses: QuranPageData.versesOnPage(ctrl.currentPage.value),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isHighlight
                  ? _accentColor
                  : (isDark
                      ? Colors.white.withOpacity(0.09)
                      : _accentColor.withOpacity(0.10)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHighlight
                  ? [
                      BoxShadow(
                        color: _accentColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '\uFD3F${v.verse}\uFD3E',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: baseFontSize * 0.8,
                fontWeight: FontWeight.bold,
                color: isHighlight
                    ? Colors.white
                    : (isDark ? const Color(0xFFD4C9A8) : _accentColor),
              ),
            ),
          ),
        ),
      ));
    }

    return spans;
  }

  bool _showBasmala(int surah) => surah != 1 && surah != 9;

  InlineSpan _buildSurahHeader({
    required int surah,
    required double baseFontSize,
    required String fontFamily,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(bottom: baseFontSize * 0.7),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: baseFontSize * 1.0,
              vertical: baseFontSize * 0.3,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: _headerBorder, width: 1.4),
              borderRadius: BorderRadius.circular(14),
              color: _headerFill,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF7A5C1E))
                      .withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '۞ سورة ${getSurahNameArabic(surah)} ۞',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: baseFontSize * 0.85,
                fontWeight: FontWeight.w700,
                color: _headerText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  InlineSpan _buildBasmala({
    required double baseFontSize,
    required String fontFamily,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(bottom: baseFontSize * 0.65),
        child: Center(
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: baseFontSize * 0.95,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE5D29A) : const Color(0xFF3D2B0A),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final QuranPageController ctrl;
  final PageController pageCtrl;
  final bool isDark;

  const _TopBar({
    required this.ctrl,
    required this.pageCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E).withOpacity(0.92)
            : Colors.teal.withOpacity(0.92),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Back ─────────────────────────────────────────
          IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
            onPressed: () => Get.back(),
          ),

          // ── Surah name + page number ──────────────────────
          Expanded(
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctrl.currentSurahName.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'صفحة ${ctrl.currentPage.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                )),
          ),

          // ── Options menu ──────────────────────────────────
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
            tooltip: 'خيارات',
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet with surah-level actions.
  /// Uses [ctrl.activeSurah] so it always reflects the current surah,
  /// even after auto page-turns during reading.
  void _showOptions(BuildContext context) {
    // Snapshot the surah number at the moment the sheet opens.
    final int surahNumber = ctrl.activeSurah.value;
    final String surahName = getSurahNameArabic(surahNumber);

    final Color sheetBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final Color textColor = isDark ? const Color(0xFFD4C9A8) : Colors.black87;
    final Color subtitleColor =
        isDark ? const Color(0xFF8A8080) : Colors.black45;
    final Color dividerColor =
        isDark ? const Color(0xFF2A2A3E) : const Color(0xFFEEEEEE);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: sheetBg,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Sheet handle ────────────────────────────
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: subtitleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Sheet title ─────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'سورة $surahName',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
                  ),
                ),

                Divider(color: dividerColor, height: 16),

                // ── Option 1: Tafsir ────────────────────────
                ListTile(
                  leading: Icon(Icons.menu_book,
                      color: isDark
                          ? const Color(0xFF00A896)
                          : const Color(0xFF1F6E8C)),
                  title: Text(
                    'عرض تفسير السورة',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () {
                    Get.back();
                    // TODO: navigate to tafsir screen
                    // e.g. Get.to(TafsirScreen(surahNumber: surahNumber));
                  },
                ),

                Divider(color: dividerColor, height: 1),

                // ── Option 2: Full audio playback ───────────
                ListTile(
                  leading: Icon(Icons.headphones,
                      color: isDark
                          ? const Color(0xFF00A896)
                          : const Color(0xFF1F6E8C)),
                  title: Text(
                    'تشغيل سورة $surahName كاملة',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () {
                    Get.back();
                    Get.to(QuranPlayerScreen(
                      surahNumber: surahNumber,
                      surahName: surahName,
                    ));
                  },
                ),

                Divider(color: dividerColor, height: 1),

                // ── Option 3: Jump to last saved position ───
                ListTile(
                  leading: Icon(Icons.bookmark_outline,
                      color: isDark
                          ? const Color(0xFF00A896)
                          : const Color(0xFF1F6E8C)),
                  title: Text(
                    'العودة لآخر موضع محفوظ',
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () {
                    Get.back();
                    ctrl.jumpToLastPosition(pageCtrl);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Stop reading button
// ─────────────────────────────────────────────────────────

class _StopReadingButton extends StatelessWidget {
  final VoidCallback onStop;
  const _StopReadingButton({required this.onStop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stop_circle_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'إيقاف القراءة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
