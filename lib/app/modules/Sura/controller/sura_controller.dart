import 'package:quran_app/index.dart';
import 'package:http/http.dart' as http;


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
