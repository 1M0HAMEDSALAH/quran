import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../utils/const/debouncer.dart';

/// Controller for managing advanced Quran search functionality.
class SearchAyaController extends GetxController {
  // Observables for search query and results
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt resultCount = 0.obs;
  final RxBool hasSearched = false.obs;

  // Search filters
  final RxBool filterBySurah = false.obs;
  final RxInt selectedSurah = 0.obs;
  final RxBool exactMatch = false.obs;

  // Recent searches
  final RxList<String> recentSearches = <String>[].obs;

  // Debouncer for search optimization
  late final debouncer;

  // Caches for optimized performance
  final Map<String, List<Map<String, dynamic>>> searchCache = {};
  final Map<int, List<Map<String, dynamic>>> versesCache = {};

  // Highlighted text color
  final Color highlightColor = Colors.amber.shade300;

  @override
  void onInit() {
    super.onInit();
    // Initialize debouncer for better UX (waits 500ms after user stops typing)
    debouncer = Debouncer<String>(
      duration: Duration(milliseconds: 500),
      initialValue: '',
      onChanged: performSearch,
    );

    // Load recent searches from local storage
    loadRecentSearches();

    // Pre-cache all Quran verses for instant searching
    cacheQuranVerses();
  }

  /// Loads recent searches from storage
  void loadRecentSearches() {
    // TODO: Implement persistent storage with GetStorage
    // For now just initialize with empty list
    recentSearches.value = [];
  }

  /// Saves recent searches to storage
  void saveRecentSearches() {
    // TODO: Implement with GetStorage
  }

  /// Adds a search term to recent searches
  void addToRecentSearches(String term) {
    if (term.isEmpty) return;

    // Remove if exists (to reorder)
    recentSearches.remove(term);

    // Add to beginning of list
    recentSearches.insert(0, term);

    // Keep only the last 10 searches
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }

    saveRecentSearches();
  }

  /// Clears all recent searches
  void clearRecentSearches() {
    recentSearches.clear();
    saveRecentSearches();
  }

  /// Preloads Quran verses into a cache for fast search operations.
  void cacheQuranVerses() {
    print("Caching Quran verses...");
    for (int surah = 1; surah <= 114; surah++) {
      versesCache[surah] = [];
      for (int verse = 1; verse <= quran.getVerseCount(surah); verse++) {
        final verseText = quran.getVerse(surah, verse, verseEndSymbol: true);
        final normalizedText = removeDiacritics(verseText.toLowerCase());
        final surahName = quran.getSurahName(surah);
        final surahNameEn = quran.getSurahNameEnglish(surah);

        versesCache[surah]!.add({
          "surah": surahName,
          "surahNameEn": surahNameEn,
          "verse": verseText,
          "surahNumber": surah,
          "verseNumber": verse,
          "normalized": normalizedText,
          "juzNumber": quran.getJuzNumber(surah, verse),
        });
      }
    }
    print("Caching complete. Total Surahs: ${versesCache.length}");
  }

  /// Update search text and trigger search with debounce
  void updateSearchQuery(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    debouncer.value = query;
  }

  /// Execute search immediately (for filter changes)
  void executeSearch() {
    if (searchQuery.isNotEmpty) {
      isLoading.value = true;
      performSearch(searchQuery.value);
    }
  }

  /// Performs the actual search operation
  void performSearch(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      isLoading.value = false;
      hasSearched.value = false;
      return;
    }

    print("Executing search for: $query");
    hasSearched.value = true;

    // Generate a unique cache key that includes filters
    final cacheKey = generateCacheKey(query);

    // Use cached results if available
    if (searchCache.containsKey(cacheKey)) {
      print("Using cached results for: $cacheKey");
      searchResults.assignAll(searchCache[cacheKey]!);
      resultCount.value = searchResults.length;
      isLoading.value = false;
      return;
    }

    final normalizedQuery = removeDiacritics(query.toLowerCase());
    final results = <Map<String, dynamic>>[];

    // Search through the cached verses
    versesCache.forEach((surahNum, verses) {
      // Apply surah filter if enabled
      if (filterBySurah.value &&
          selectedSurah.value > 0 &&
          surahNum != selectedSurah.value) {
        return;
      }

      for (var verseData in verses) {
        bool matches = false;

        if (exactMatch.value) {
          // For exact match, search for whole words
          final normalizedVerse = verseData["normalized"] as String;
          final words = normalizedVerse.split(' ');
          matches = words.contains(normalizedQuery);
        } else {
          // For normal search, check if the verse contains the query
          matches = verseData["normalized"].contains(normalizedQuery);
        }

        if (matches) {
          // Create a copy to avoid modifying the cache
          final resultItem = Map<String, dynamic>.from(verseData);

          // Add highlighted text for display
          resultItem["highlightedText"] = highlightSearchTerms(
            verseData["verse"] as String,
            query,
          );

          results.add(resultItem);
        }
      }
    });

    print("Found ${results.length} results for: $query");

    // Sort results by relevance (more occurrences = higher relevance)
    results.sort((a, b) {
      final aOccurrences =
          countOccurrences(a["normalized"] as String, normalizedQuery);
      final bOccurrences =
          countOccurrences(b["normalized"] as String, normalizedQuery);
      return bOccurrences.compareTo(aOccurrences);
    });

    // Cache and update results
    if (results.isNotEmpty) {
      searchCache[cacheKey] = results;
    }

    // Add to recent searches
    addToRecentSearches(query);

    // Update UI
    searchResults.assignAll(results);
    resultCount.value = results.length;
    isLoading.value = false;
  }

  /// Generates a unique cache key that includes all search parameters
  String generateCacheKey(String query) {
    return '$query-surah:${filterBySurah.value ? selectedSurah.value : "all"}-exact:${exactMatch.value}';
  }

  /// Count occurrences of a term in a text
  int countOccurrences(String text, String term) {
    int count = 0;
    int index = 0;
    while (true) {
      index = text.indexOf(term, index);
      if (index == -1) break;
      count++;
      index += term.length;
    }
    return count;
  }

  /// Creates a highlighted version of the verse text with search terms highlighted
  String highlightSearchTerms(String originalText, String searchTerm) {
    // This function is simplified - in a real app, you'd use rich text or HTML
    // For demo, we'll just return the original text as the actual highlighting
    // would happen in the UI with RichText
    return originalText;
  }

  /// Removes diacritical marks from Arabic text for normalized searches.
  String removeDiacritics(String text) {
    const diacritics = [
      '\u0610',
      '\u0611',
      '\u0612',
      '\u0613',
      '\u0614',
      '\u0615',
      '\u0616',
      '\u0617',
      '\u0618',
      '\u0619',
      '\u061A',
      '\u064B',
      '\u064C',
      '\u064D',
      '\u064E',
      '\u064F',
      '\u0650',
      '\u0651',
      '\u0652',
      '\u0653',
      '\u0654',
      '\u0655',
      '\u0656',
      '\u0657',
      '\u0658',
      '\u0659',
      '\u065A',
      '\u065B',
      '\u065C',
      '\u065D',
      '\u065E',
      '\u065F',
      '\u0670'
    ];
    for (final diacritic in diacritics) {
      text = text.replaceAll(diacritic, '');
    }
    return text;
  }

  /// Toggle filter by surah
  void toggleSurahFilter(bool value) {
    filterBySurah.value = value;
    if (searchQuery.isNotEmpty) {
      executeSearch();
    }
  }

  /// Set selected surah number
  void selectSurah(int surahNum) {
    selectedSurah.value = surahNum;
    if (filterBySurah.value && searchQuery.isNotEmpty) {
      executeSearch();
    }
  }

  /// Toggle exact match filter
  void toggleExactMatch(bool value) {
    exactMatch.value = value;
    if (searchQuery.isNotEmpty) {
      executeSearch();
    }
  }

  @override
  void onClose() {
    searchCache.clear();
    versesCache.clear();
    debouncer.cancel();
    super.onClose();
  }
}
