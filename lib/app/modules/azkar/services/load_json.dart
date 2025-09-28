import 'package:quran_app/index.dart';

class AzkarService {
  static const String _azkarJsonPath = 'assets/azkar.json';
  static List<AzkarCategory>? _cachedCategories;

  static Future<List<AzkarCategory>> loadAzkarCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_azkarJsonPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _cachedCategories = jsonList
          .map((json) => AzkarCategory.fromJson(json))
          .toList();
      
      return _cachedCategories!;
    } catch (e) {
      print('Error loading azkar data: $e');
      return [];
    }
  }

  static AzkarCategory? findCategoryByName(List<AzkarCategory> categories, String categoryName) {
    return categories.firstWhereOrNull(
      (category) => category.category.contains(categoryName)
    );
  }

  static List<AzkarCategory> filterMorningAzkar(List<AzkarCategory> categories) {
    return categories.where((category) => 
      category.category.contains('الصباح') || 
      category.category.contains('أذكار الصباح والمساء')
    ).toList();
  }

  static List<AzkarCategory> filterEveningAzkar(List<AzkarCategory> categories) {
    return categories.where((category) => 
      category.category.contains('المساء') || 
      category.category.contains('أذكار الصباح والمساء')
    ).toList();
  }
}
