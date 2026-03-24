import 'package:quran_app/index.dart';

class SurahListView extends GetView<SurahListController> {
  SurahListView({super.key});

  // ✅ Use Get.find — controllers already registered by bindings
  final settingsController = Get.find<SettingsController>();
  final SurahListController surahListController = Get.put(SurahListController());
  final HijriCalendarController hijriController = Get.put(HijriCalendarController());

  @override
  Widget build(BuildContext context) {
    // ✅ Only put if not already registered
    if (!Get.isRegistered<AzkarController>()) {
      Get.put(AzkarController());
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HijriCalendarWidget(),
          ),
          SliverToBoxAdapter(
            child: _buildCategorySelector(),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 3 / 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surahNumber = controller.filteredSurahs[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 2,
                      // ✅ Reduced animation duration for snappier feel
                      duration: const Duration(milliseconds: 250),
                      delay: const Duration(milliseconds: 30),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        curve: Curves.easeOutCubic,
                        child: ScaleAnimation(
                          scale: 0.85,
                          curve: Curves.easeOutBack,
                          child: FadeInAnimation(
                            curve: Curves.easeIn,
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
            padding: EdgeInsets.only(bottom: 75),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.categories.map((category) {
              bool isSelected = controller.selectedCategory.value == category;
              String displayName = category == 'all'
                  ? 'الكل'
                  : category == 'meccan'
                      ? 'مكية'
                      : 'مدنية';

              return GestureDetector(
                onTap: () => controller.selectCategory(category),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  // ✅ Wrap AppBar in Obx so isDarkMode is reactive
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final isDarkMode = settingsController.isDarkMode.value;
        return AppBar(
          title: const Text('القرآن الكريم'),
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => _handleSearch(context),
            ),
          ],
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
              width: 24,
              height: 24,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
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

  Widget _buildSurahCard(int surahNumber) {
    // ✅ Read once outside LayoutBuilder to avoid repeated lookups
    final isDarkMode = settingsController.isDarkMode.value;
    final arabicName = getSurahNameArabic(surahNumber);
    final englishName = getSurahName(surahNumber);
    final verseCount = getVerseCount(surahNumber);
    final revelationPlace = getPlaceOfRevelation(surahNumber);

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        double baseFontSize = width * 0.045;

        return Hero(
          tag: 'surah_$surahNumber',
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => controller.navigateToSurahDetail(surahNumber),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            AppColor.darkPrimaryColor,
                            AppColor.darkPrimaryColor.withOpacity(0.8),
                          ]
                        : [
                            AppColor.primaryColor,
                            AppColor.primaryColor.withOpacity(0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/islamic_pattern.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: width * 0.1,
                        height: width * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            '$surahNumber',
                            style: TextStyle(
                              fontSize: baseFontSize * 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.02,
                          vertical: width * 0.01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Text(
                          revelationPlace == "Makkah" ? 'مكية' : 'مدنية',
                          style: TextStyle(
                            fontSize: baseFontSize * 1.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            arabicName,
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontSize: baseFontSize * 2.8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            '($englishName)',
                            style: TextStyle(
                              fontSize: baseFontSize * 1.8,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: height * 0.01),
                          Text(
                            '$verseCount آية',
                            style: TextStyle(
                              fontSize: baseFontSize * 1.7,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}