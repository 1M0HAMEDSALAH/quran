// surah_list_controller.dart - updated version
import 'dart:convert';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quran/quran.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:quran_app/contian/setting.dart';
import '../azkar/view/azkar_view.dart';
import '../const/app_theme.dart';
import 'displaysurrah.dart';
import 'surasearch.dart';
import 'hijri_calendar_widget.dart'; // Import the new widget

class SurahListController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedIndex = (-1).obs;

  // Categories for surah filtering
  final RxString selectedCategory = 'all'.obs;

  List<String> get categories => ['all', 'meccan', 'medinan'];

  List<int> get filteredSurahs {
    if (selectedCategory.value == 'all')
      return List.generate(114, (index) => index + 1);
    if (selectedCategory.value == 'meccan')
      return List.generate(114, (index) => index + 1)
          .where((surahNum) => getPlaceOfRevelation(surahNum) == "Makkah")
          .toList();
    if (selectedCategory.value == 'medinan')
      return List.generate(114, (index) => index + 1)
          .where((surahNum) => getPlaceOfRevelation(surahNum) == "Madinah")
          .toList();
    return List.generate(114, (index) => index + 1);
  }

  // API service for fetching tafseer
  Future<void> fetchTafseer(int verseNumber, int surahNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final String url =
          'https://api.quran-tafseer.com/tafseer/1/${surahNumber}/$verseNumber';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String tafseerText = data['text'] ?? 'لا يوجد تفسير متاح لهذه الآية.';
        _showTafseerDialog(verseNumber, tafseerText);
      } else {
        errorMessage.value = 'فشل في جلب التفسير، حاول لاحقًا.';
        _showError(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء جلب التفسير.';
      _showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: Duration(seconds: 3),
    );
  }

  void _showTafseerDialog(int verseNumber, String tafseerText) {
    Get.defaultDialog(
      title: 'تفسير الآية رقم $verseNumber',
      titleStyle: Get.textTheme.headlineMedium?.copyWith(
        color: AppColor.primaryColor,
        fontWeight: FontWeight.bold,
      ),
      content: Container(
        width: Get.width * 0.8,
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tafseerText,
              style: Get.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  void navigateToSurahDetail(int surahNumber) {
    selectedIndex.value = surahNumber - 1;
    Get.to(
      () => SurahDetailScreen(surahNumber: surahNumber),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class SurahListView extends GetView<SurahListController> {
  SurahListView({super.key});
  final settingsController = Get.find<SettingsController>();

  final SurahListController surahListController =
      Get.put(SurahListController());
  final HijriCalendarController hijriController =
      Get.put(HijriCalendarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // Hijri Calendar
          SliverToBoxAdapter(
            child: HijriCalendarWidget(),
          ),

          // Category Selector
          SliverToBoxAdapter(
            child: _buildCategorySelector(),
          ),

          // Surah Grid
          Obx(() {
            if (controller.isLoading.value) {
              return SliverToBoxAdapter(
                child: const Center(
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
                      duration: const Duration(milliseconds: 375),
                      columnCount: 2,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildSurahCard(surahNumber),
                        ),
                      ),
                    );
                  },
                  childCount: controller.filteredSurahs.length,
                ),
              ),
            );
          }),

          SliverPadding(
            padding: const EdgeInsets.only(bottom: 75),
            sliver: SliverToBoxAdapter(child: Container()),
          )
        ],
      ),
    );
  }

  // Keep all your other methods the same (_buildAppBar, _buildCategorySelector,
  // _buildSurahCard, _handleSearch, etc.)
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
                    color:
                        isSelected ? AppColor.primaryColor : Colors.transparent,
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

  AppBar _buildAppBar(BuildContext context) {
    final isDarkMode = settingsController.isDarkMode.value;

    return AppBar(
      title: const Text(
        'القرآن الكريم',
      ),
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
            () => AthkarView(),
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
    final isDarkMode = settingsController.isDarkMode.value;

    return Hero(
      tag: 'surah_$surahNumber',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => controller.navigateToSurahDetail(surahNumber),
          child: Container(
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
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/islamic_pattern.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Surah number
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        '$surahNumber',
                      ),
                    ),
                  ),
                ),

                // Revelation type indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: Text(
                      getPlaceOfRevelation(surahNumber) == "Makkah"
                          ? 'مكية'
                          : 'مدنية',
                    ),
                  ),
                ),

                // Surah name
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getSurahNameArabic(surahNumber),
                        style: Get.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(${getSurahName(surahNumber)})',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${getVerseCount(surahNumber)} آية',
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
  }
}
