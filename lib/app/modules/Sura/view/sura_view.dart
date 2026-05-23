import 'package:quran_app/index.dart';
import 'package:quran_app/app/modules/Sura/reading_position_service.dart';

class SurahListView extends GetView<SurahListController> {
  SurahListView({super.key});

  final settingsController = Get.find<SettingsController>();
  final SurahListController surahListController =
      Get.put(SurahListController());
  final HijriCalendarController hijriController =
      Get.put(HijriCalendarController());

  // Deep Islamic elegance scheme
  static const Color _primaryDark = Color(0xFF0F3E33);
  static const Color _primaryLight = Color(0xFF165A4B);
  static const Color _goldAccent = Color(0xFFCDA047);
  static const Color _goldLight = Color(0xFFE4C578);
  static const Color _bgLight = Color(0xFFF9F6F0);
  static const Color _bgDark = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AzkarController>()) {
      Get.put(AzkarController());
    }
    final isDarkMode = settingsController.isDarkMode.value;

    return Scaffold(
      backgroundColor: isDarkMode ? _bgDark : _bgLight,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Subtle background texture/pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.05 : 0.03,
              child: CustomPaint(
                painter: QuranBackgroundPainter(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Today's Reflection card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: _buildReflectionCard(),
                ),
              ),

              // Category selector
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildCategorySelector(),
                ),
              ),

              // Surah list
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(color: _goldAccent),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final surahNumber = controller.filteredSurahs[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 30),
                          child: SlideAnimation(
                            verticalOffset: 40.0,
                            curve: Curves.easeOutQuart,
                            child: FadeInAnimation(
                              curve: Curves.easeIn,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSurahCard(surahNumber),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: controller.filteredSurahs.length,
                    ),
                  ),
                );
              }),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: 90),
                sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dark rich green card with gold accents
  Widget _buildReflectionCard() {
    final HijriCalendar hijri = HijriCalendar.now();
    final now = DateTime.now();

    final String hijriDate = _formatHijriDate(hijri);
    final String gregorianDate = _formatGregorianDate(now);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_primaryDark, _primaryLight],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: _goldAccent.withOpacity(0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          // Decorative background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.star_purple500_sharp,
                  size: 150, color: _goldLight),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label row
              Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: _goldAccent.withOpacity(0.9), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "اليوم",
                    style: TextStyle(
                      color: _goldLight.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hijri date large
              Text(
                hijriDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Amiri',
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Gregorian date
              Text(
                gregorianDate,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Bottom row: Read button
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final pos = await ReadingPositionService.loadPosition();
                      if (pos != null) {
                        controller.navigateToSurahDetail(pos.surahNumber);
                      } else {
                        controller.navigateToSurahDetail(1);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _goldAccent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _goldAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'متابعة القراءة',
                            style: TextStyle(
                              color:
                                  Color(0xFF2A1C00),
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Amiri',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded,
                              color: Color(0xFF2A1C00), size: 18),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const QiblaScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: _goldAccent, width: 1.5),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryDark.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'اتجاه القبلة',
                            style: TextStyle(
                              color: _goldAccent,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Amiri',
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.explore, color: _goldAccent, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHijriDate(HijriCalendar hijri) {
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    final greg = hijri.hijriToGregorian(hijri.hYear, hijri.hMonth, hijri.hDay);
    final dayName = days[greg.weekday - 1];
    return '$dayName ${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }

  String _formatGregorianDate(DateTime now) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  /// Elegant Category tabs
  Widget _buildCategorySelector() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: controller.categories.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              final label = category == 'all'
                  ? 'الكل'
                  : category == 'meccan'
                      ? 'مكيّة'
                      : 'مدنيّة';

              return GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(left: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryLight
                        : (settingsController.isDarkMode.value
                            ? const Color(0xFF1E1E1E)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? _primaryLight
                          : (settingsController.isDarkMode.value
                              ? Colors.grey.shade800
                              : Colors.grey.shade300),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primaryLight.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (settingsController.isDarkMode.value
                              ? Colors.white70
                              : Colors.grey.shade800),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontFamily: 'Amiri',
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  /// AppBar matched to premium feel
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final isDarkMode = settingsController.isDarkMode.value;
        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Get.to(
                () => const AzkarView(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
            icon: Image.asset(
              'assets/beads.png',
              width: 26,
              height: 26,
              color: isDarkMode ? _goldLight : _primaryDark,
            ),
          ),
          title: Text(
            'القرآن الكريم',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w700,
              fontSize: 26,
              color: isDarkMode ? Colors.white : _primaryDark,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded,
                  color: isDarkMode ? Colors.white : _primaryDark, size: 28),
              onPressed: () => _handleSearch(context),
            ),
            const SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  Future<void> _handleSearch(BuildContext context) async {
    final int? selectedSurah = await showSearch<int>(
      context: context,
      delegate: SurahSearchDelegate(),
    );
    if (selectedSurah != null) {
      controller.navigateToSurahDetail(selectedSurah);
    }
  }

  /// Beautifully crafted surah row card
  Widget _buildSurahCard(int surahNumber) {
    final isDarkMode = settingsController.isDarkMode.value;
    final arabicName = getSurahNameArabic(surahNumber);
    final englishName = getSurahName(surahNumber);
    final verseCount = getVerseCount(surahNumber);
    final isMakki = getPlaceOfRevelation(surahNumber) == "Makkah";

    return Hero(
      tag: 'surah_$surahNumber',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToSurahDetail(surahNumber),
          borderRadius: BorderRadius.circular(20),
          highlightColor: _primaryLight.withOpacity(0.1),
          splashColor: _goldAccent.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1D1C) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white10
                    : Colors.black.withOpacity(0.04),
                width: 1,
              ),
              boxShadow: isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Arabic name and Ayah count (RTL layout)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabicName,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? _goldLight : _primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '$verseCount آيَات',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Amiri',
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildBadge(isMakki ? 'مكيّة' : 'مدنيّة', isMakki),
                        ],
                      ),
                    ],
                  ),
                ),

                // Beautiful numbered geometric frame
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(54, 54),
                      painter: IslamicBorderPainter(
                        color: isDarkMode
                            ? _goldAccent.withOpacity(0.4)
                            : _primaryDark.withOpacity(0.2),
                      ),
                    ),
                    Text(
                      '$surahNumber',
                      style: TextStyle(
                        color: isDarkMode ? _goldLight : _primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Amiri',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, bool isMakki) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isMakki ? const Color(0xFFF0F5F4) : _primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isMakki ? Colors.grey.shade300 : _primaryLight.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Amiri',
          fontWeight: FontWeight.w700,
          color: isMakki ? Colors.grey.shade700 : _primaryLight,
        ),
      ),
    );
  }
}

class IslamicBorderPainter extends CustomPainter {
  final Color color;

  IslamicBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 360 / 8) * (3.14159 / 180);
      final x = center.dx +
          radius *
              0.85 *
              (i % 2 == 0 ? 1 : 0.7) *
              (i == 0 || i == 4
                  ? 1
                  : (i == 1 || i == 3 || i == 5 || i == 7 ? 0.9 : 1)) *
              1.0 *
              (1.0) *
              (3.14159 / 180).abs();
      // Wait, drawing a proper 8 point star
    }

    // Easier 8 point star:
    canvas.save();
    canvas.translate(center.dx, center.dy);

    final starPath = Path();
    for (int i = 0; i < 8; i++) {
      canvas.rotate(3.1415926535 / 4);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: radius * 1.3, height: radius * 1.3),
          paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuranBackgroundPainter extends CustomPainter {
  final Color color;

  QuranBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double step = 60.0;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), step / 3, paint);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(x, y), width: step / 1.5, height: step / 1.5),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
