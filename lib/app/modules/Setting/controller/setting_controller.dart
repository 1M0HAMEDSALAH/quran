import 'package:quran_app/index.dart';



class SettingsController extends GetxController {
  final storage = GetStorage();
  final fontSize = 22.0.obs;
  final isDarkMode = false.obs;
  final arabicFont = "Hafs".obs;
  final autoScrollSpeed = 1.0.obs;
  final lastReadSurah = 1.obs;
  final lastReadAyah = 1.obs;

  // Font options with better organization using a model
  final List<ArabicFontOption> fontOptions = [
    ArabicFontOption(
        id: 'Hafs', arabicName: 'حفص', fontFamily: 'KFGQPCUthmanicScriptHAFS'),
    ArabicFontOption(
        id: 'Uthmani', arabicName: 'عثماني', fontFamily: 'UthmanicScript'),
    ArabicFontOption(id: 'Naskh', arabicName: 'نسخ', fontFamily: 'Amiri'),
    ArabicFontOption(id: 'Qaloon', arabicName: 'قالون', fontFamily: 'Lateef'),
    ArabicFontOption(
        id: 'fontFamily: "BahijTheSansArabic"',
        arabicName: 'اندونيسي',
        fontFamily: 'fontFamily: "BahijTheSansArabic"'),
  ];

  // Getter for current font family
  String get arabicFontFamily {
    final option = fontOptions.firstWhere(
      (font) => font.id == arabicFont.value,
      orElse: () => fontOptions.first,
    );
    return option.fontFamily;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // Separated method for better organization
  void _loadSettings() {
    fontSize.value = storage.read('fontSize') ?? 22.0;
    isDarkMode.value = storage.read('isDarkMode') ?? false;
    arabicFont.value = storage.read('arabicFont') ?? "Hafs";
    autoScrollSpeed.value = storage.read('autoScrollSpeed') ?? 1.0;

    // Load last read position
    lastReadSurah.value = storage.read('lastReadSurah') ?? 1;
    lastReadAyah.value = storage.read('lastReadAyah') ?? 1;
  }

  void setFontSize(double size) {
    fontSize.value = size;
    storage.write('fontSize', size);
    HapticFeedback.selectionClick(); // Provide feedback
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    storage.write('isDarkMode', isDarkMode.value);
    HapticFeedback.mediumImpact();
  }

  void setArabicFont(String font) {
    arabicFont.value = font;
    storage.write('arabicFont', font);
    HapticFeedback.lightImpact();
  }

  void setAutoScrollSpeed(double speed) {
    autoScrollSpeed.value = speed;
    storage.write('autoScrollSpeed', speed);
    HapticFeedback.selectionClick();
  }

  // Method to save last read position
  void saveReadingPosition(int surah, int ayah) {
    lastReadSurah.value = surah;
    lastReadAyah.value = ayah;
    storage.write('lastReadSurah', surah);
    storage.write('lastReadAyah', ayah);
  }
}
