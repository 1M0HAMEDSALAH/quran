import 'package:quran_app/index.dart';

class SurahListView extends GetView<SurahListController> {
  SurahListView({super.key});

  final settingsController = Get.find<SettingsController>();
  final SurahListController surahListController =
      Get.put(SurahListController());
  final HijriCalendarController hijriController =
      Get.put(HijriCalendarController());

  // Teal accent color matching the design
  static const Color _teal = Color(0xFF2A9D8A);
  static const Color _tealDark = Color(0xFF1F7A6A);
  static const Color _bgLight = Color(0xFFF0F5F4);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AzkarController>()) {
      Get.put(AzkarController());
    }

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Today's Reflection card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildReflectionCard(),
            ),
          ),

          // Category selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: CircularProgressIndicator(color: _teal),
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
                      duration: const Duration(milliseconds: 300),
                      delay: const Duration(milliseconds: 25),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeIn,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Dark teal card — uses HijriCalendarWidget for date display (no Obx needed)
  Widget _buildReflectionCard() {
    // Compute dates once, purely — no reactive reads here
    final HijriCalendar hijri = HijriCalendar.now();
    final now = DateTime.now();

    final String hijriDate = _formatHijriDate(hijri);
    final String gregorianDate = _formatGregorianDate(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6E60), Color(0xFF2A9D8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white70, size: 13),
              const SizedBox(width: 6),
              Text(
                "TODAY'S REFLECTION",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hijri date large
          Text(
            hijriDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // Gregorian date
          Text(
            gregorianDate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),

          // Bottom row: avatars + resume button
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 34,
                child: Stack(
                  children: [
                    _avatarCircle('A'),
                    Positioned(left: 26, child: _avatarCircle('Ω')),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to last read position
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Resume Reading',
                    style: TextStyle(
                      color: Color(0xFF1E6E60),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarCircle(String label) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatHijriDate(HijriCalendar hijri) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Muharram',
      'Safar',
      "Rabi' al-Awwal",
      "Rabi' al-Thani",
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhu al-Qi'dah",
      'Dhu al-Hijjah',
    ];
    final greg = hijri.hijriToGregorian(hijri.hYear, hijri.hMonth, hijri.hDay);
    final dayName = days[greg.weekday - 1];
    final monthName = months[hijri.hMonth - 1];
    return '$dayName ${hijri.hDay} $monthName ${hijri.hYear}';
  }

  String _formatGregorianDate(DateTime now) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  /// Pill-shaped category tabs: All / Makki / Madani
  Widget _buildCategorySelector() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: controller.categories.map((category) {
            final isSelected = controller.selectedCategory.value == category;
            final label = category == 'all'
                ? 'All'
                : category == 'meccan'
                    ? 'Makki'
                    : 'Madani';

            return GestureDetector(
              onTap: () => controller.selectCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? _teal : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _teal.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  /// AppBar matching the screenshot: centered italic title, search icon, hamburger
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final isDarkMode = settingsController.isDarkMode.value;
        return AppBar(
          backgroundColor: _bgLight,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Get.to(
                () => const AzkarView(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 150),
              );
            },
            icon: Image.asset(
              'assets/beads.png',
              width: 24,
              height: 24,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          title: const Text(
            'القرآن الكريم',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Color(0xFF1E3A35),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search,
                  color: isDarkMode ? Colors.white : Colors.black87),
              onPressed: () => _handleSearch(context),
            ),
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

  /// Each surah row card matching the screenshot layout
  Widget _buildSurahCard(int surahNumber) {
    final isDarkMode = settingsController.isDarkMode.value;
    final arabicName = getSurahNameArabic(surahNumber);
    final englishName = getSurahName(surahNumber);
    // final transliteration = getSurahTransliteration(surahNumber); // e.g. "The Opening"
    final verseCount = getVerseCount(surahNumber);
    final revelationPlace = getPlaceOfRevelation(surahNumber);
    final isMakki = revelationPlace == "Makkah";
    final badgeLabel = isMakki ? 'MAKKI' : 'MADANI';

    return Hero(
      tag: 'surah_$surahNumber',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => controller.navigateToSurahDetail(surahNumber),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1C2E2B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDDF2EE),
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: const TextStyle(
                        color: _teal,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Left text block: name + ayah count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: English name + badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            englishName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1E3A35),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(badgeLabel, isMakki),
                        ],
                      ),
                      // const SizedBox(height: 2),
                      // // Transliteration / meaning
                      // Text(
                      //   transliteration,
                      //   style: TextStyle(
                      //     fontSize: 12.5,
                      //     color: Colors.grey.shade500,
                      //   ),
                      // ),
                      const SizedBox(height: 6),
                      // Ayah count
                      Text(
                        '$verseCount AYAH',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic name on the right
                Text(
                  arabicName,
                  style: TextStyle(
                    fontFamily: 'Amiri', // or your Arabic font
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : const Color(0xFF1E3A35),
                  ),
                  textDirection: TextDirection.rtl,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMakki
            ? const Color(0xFFF0F5F4) // light grey-green for Makki
            : _teal, // solid teal for Madani
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isMakki ? Colors.grey.shade600 : Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Bottom navigation bar with 4 icons
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.menu_book_rounded, true),
          _navItem(Icons.search, false),
          _navItem(Icons.bookmark_outline, false),
          _navItem(Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? _teal : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }
}
