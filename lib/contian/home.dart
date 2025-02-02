// surah_list_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

import '../azkar/view/azkar_view.dart';
import 'displaysurrah.dart';
import 'surasearch.dart';

class SurahListController extends GetxController {
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // API service could be moved to a separate service class
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
        color: Colors.teal[700],
        fontWeight: FontWeight.bold,
      ),
      content: SingleChildScrollView(
        child: Text(
          tafseerText,
          style: Get.textTheme.bodyLarge,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'إغلاق',
            style: Get.textTheme.labelLarge?.copyWith(
              color: Colors.teal[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: Get.textTheme.titleLarge?.copyWith(
          color: Colors.teal[700],
        ),
      ),
    );
  }

  void navigateToSurahDetail(int surahNumber) {
    Get.to(
      () => SurahDetailScreen(surahNumber: surahNumber),
      transition: Transition.cupertino,
    );
  }
}

class SurahListView extends GetView<SurahListController> {
  SurahListView({Key? key}) : super(key: key);

  final SurahListController surahListController = Get.put(SurahListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody()),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'القرآن الكريم',
        style: Get.textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.teal[700],
      elevation: 10,
      shadowColor: Colors.teal.withOpacity(0.5),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => _handleSearch(context),
        ),
      ],
      leading: IconButton(
        onPressed: () {
          Get.to(AthkarView());
        },
        icon: Image.asset(
          'assets/beads.png',
          width: 30,
          height: 30,
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

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 3 / 2,
        ),
        itemCount: 114,
        itemBuilder: (context, index) => _buildSurahCard(index + 1),
      ),
    );
  }

  Widget _buildSurahCard(int surahNumber) {
    return Hero(
      tag: 'surah_$surahNumber',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => controller.navigateToSurahDetail(surahNumber),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.teal[700]!,
                  Colors.teal[400]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: _buildCardContent(surahNumber),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(int surahNumber) {
    return Stack(
      children: [
        Positioned(
          top: 10,
          right: 10,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              '$surahNumber',
              style: Get.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getSurahNameArabic(surahNumber),
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  // shadows: [
                  //   Shadow(
                  //     blurRadius: 5,
                  //     color: Colors.black.withOpacity(0.3),
                  //     offset: Offset(2, 5),
                  //   ),
                  // ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(${getSurahName(surahNumber)})',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
