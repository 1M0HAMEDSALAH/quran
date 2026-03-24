import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../utils/const/debouncer.dart';

/// Professional Quran search controller with advanced features and optimizations.
class SearchAyaController extends GetxController {
  // ==================== Observable State ====================
  final RxString searchQuery = ''.obs;
  final RxList<SearchResult> searchResults = <SearchResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt resultCount = 0.obs;
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;

  // ==================== Search Filters ====================
  final RxBool filterBySurah = false.obs;
  final RxInt selectedSurah = 0.obs;
  final RxBool exactMatch = false.obs;
  final RxBool caseSensitive = false.obs;
  final RxBool searchInTranslation = false.obs;
  
  // Advanced filters
  final Rx<SearchMode> searchMode = SearchMode.contains.obs;
  final RxList<int> selectedJuz = <int>[].obs;
  final RxInt minVerseLength = 0.obs;
  final RxInt maxVerseLength = 0.obs;

  // ==================== Search History & Suggestions ====================
  final RxList<SearchHistoryItem> recentSearches = <SearchHistoryItem>[].obs;
  final RxList<String> searchSuggestions = <String>[].obs;
  final RxInt maxRecentSearches = 20.obs;

  // ==================== Performance Optimization ====================
  late final Debouncer<String> debouncer;
  final Map<String, List<SearchResult>> _searchCache = {};
  final Map<int, List<VerseData>> _versesCache = {};
  final Map<String, List<String>> _suggestionCache = {};
  
  static const int _maxCacheSize = 100;
  static const Duration _searchDelay = Duration(milliseconds: 300);

  // ==================== Statistics ====================
  final RxInt totalVersesIndexed = 0.obs;
  final RxDouble averageSearchTime = 0.0.obs;
  final RxInt totalSearches = 0.obs;

  // ==================== Configuration ====================
  final Color highlightColor = Colors.amber.shade300;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDebouncer();
    _initializeSearchEngine();
  }

  /// Initialize debouncer with optimized settings
  void _initializeDebouncer() {
    debouncer = Debouncer<String>(
      duration: _searchDelay,
      initialValue: '',
      onChanged: _performSearchWithMetrics,
    );
  }

  /// Initialize the search engine
  Future<void> _initializeSearchEngine() async {
    try {
      await _loadRecentSearches();
      await _cacheQuranVerses();
    } catch (e) {
      errorMessage.value = 'Failed to initialize search: ${e.toString()}';
      debugPrint('Search initialization error: $e');
    }
  }

  // ==================== Search History Management ====================
  
  /// Load recent searches from persistent storage
  Future<void> _loadRecentSearches() async {
    try {
      // TODO: Implement with GetStorage or Hive
      // final storage = GetStorage();
      // final searches = storage.read<List>('recent_searches') ?? [];
      // recentSearches.value = searches.map((e) => SearchHistoryItem.fromJson(e)).toList();
      recentSearches.value = [];
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  /// Save recent searches to persistent storage
  Future<void> saveRecentSearches() async {
    try {
      // TODO: Implement with GetStorage or Hive
      // final storage = GetStorage();
      // await storage.write('recent_searches', recentSearches.map((e) => e.toJson()).toList());
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Add search term to history with metadata
  void addToRecentSearches(String term, int resultsCount) {
    if (term.trim().isEmpty) return;

    final historyItem = SearchHistoryItem(
      query: term.trim(),
      timestamp: DateTime.now(),
      resultsCount: resultsCount,
      filters: _getCurrentFilters(),
    );

    // Remove duplicates
    recentSearches.removeWhere((item) => item.query == term);
    
    // Add to beginning
    recentSearches.insert(0, historyItem);
    
    // Maintain size limit
    if (recentSearches.length > maxRecentSearches.value) {
      recentSearches.removeRange(maxRecentSearches.value, recentSearches.length);
    }

    saveRecentSearches();
  }

  /// Clear all search history
  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    await saveRecentSearches();
  }

  /// Get current filter state
  Map<String, dynamic> _getCurrentFilters() {
    return {
      'filterBySurah': filterBySurah.value,
      'selectedSurah': selectedSurah.value,
      'exactMatch': exactMatch.value,
      'searchMode': searchMode.value.toString(),
    };
  }

  // ==================== Verse Caching System ====================
  
  /// Preload and index all Quran verses for fast searching
  Future<void> _cacheQuranVerses() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('Starting Quran verse indexing...');

    try {
      int totalVerses = 0;
      
      for (int surah = 1; surah <= 114; surah++) {
        _versesCache[surah] = [];
        final verseCount = quran.getVerseCount(surah);
        
        for (int verse = 1; verse <= verseCount; verse++) {
          final verseData = _createVerseData(surah, verse);
          _versesCache[surah]!.add(verseData);
          totalVerses++;
        }
      }

      totalVersesIndexed.value = totalVerses;
      stopwatch.stop();
      
      debugPrint('Indexing complete: $totalVerses verses in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('Error caching verses: $e');
      errorMessage.value = 'Failed to index Quran verses';
    }
  }

  /// Create indexed verse data structure
  VerseData _createVerseData(int surah, int verse) {
    final verseText = quran.getVerse(surah, verse, verseEndSymbol: true);
    final normalizedText = _normalizeText(verseText);
    
    return VerseData(
      surahNumber: surah,
      verseNumber: verse,
      arabicText: verseText,
      normalizedText: normalizedText,
      surahName: quran.getSurahName(surah),
      surahNameEn: quran.getSurahNameEnglish(surah),
      juzNumber: quran.getJuzNumber(surah, verse),
      pageNumber: quran.getPageNumber(surah, verse),
      verseLength: normalizedText.length,
      wordCount: normalizedText.split(' ').length,
    );
  }

  // ==================== Search Operations ====================
  
  /// Update search query with debouncing
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    errorMessage.value = '';

    if (query.trim().isEmpty) {
      _resetSearch();
      return;
    }

    isLoading.value = true;
    debouncer.value = query.trim();
    
    // Generate suggestions asynchronously
    _generateSearchSuggestions(query);
  }

  /// Reset search state
  void _resetSearch() {
    searchResults.clear();
    hasSearched.value = false;
    isLoading.value = false;
    searchSuggestions.clear();
  }

  /// Execute search immediately (for filter changes)
  void executeSearch() {
    if (searchQuery.value.isNotEmpty) {
      isLoading.value = true;
      _performSearchWithMetrics(searchQuery.value);
    }
  }

  /// Perform search with performance metrics
  void _performSearchWithMetrics(String query) {
    final stopwatch = Stopwatch()..start();
    
    try {
      _performSearch(query);
      
      stopwatch.stop();
      final searchTime = stopwatch.elapsedMilliseconds / 1000.0;
      
      // Update average search time
      totalSearches.value++;
      averageSearchTime.value = 
        ((averageSearchTime.value * (totalSearches.value - 1)) + searchTime) / 
        totalSearches.value;
      
      debugPrint('Search completed in ${searchTime}s (avg: ${averageSearchTime.value.toStringAsFixed(3)}s)');
    } catch (e) {
      errorMessage.value = 'Search failed: ${e.toString()}';
      debugPrint('Search error: $e');
      isLoading.value = false;
    }
  }

  /// Core search implementation
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _resetSearch();
      return;
    }

    hasSearched.value = true;
    final cacheKey = _generateCacheKey(query);

    // Check cache first
    if (_searchCache.containsKey(cacheKey)) {
      _useCachedResults(cacheKey);
      return;
    }

    final results = _executeSearchAlgorithm(query);
    final sortedResults = _sortResults(results, query);

    // Manage cache size
    _manageCacheSize();
    _searchCache[cacheKey] = sortedResults;

    // Update UI and history
    searchResults.assignAll(sortedResults);
    resultCount.value = sortedResults.length;
    isLoading.value = false;

    addToRecentSearches(query, sortedResults.length);
  }

  /// Use cached search results
  void _useCachedResults(String cacheKey) {
    debugPrint('Using cached results for: $cacheKey');
    searchResults.assignAll(_searchCache[cacheKey]!);
    resultCount.value = searchResults.length;
    isLoading.value = false;
  }

  /// Execute the search algorithm
  List<SearchResult> _executeSearchAlgorithm(String query) {
    final normalizedQuery = _normalizeText(query);
    final results = <SearchResult>[];

    _versesCache.forEach((surahNum, verses) {
      if (_shouldSkipSurah(surahNum)) return;

      for (var verseData in verses) {
        if (_shouldSkipVerse(verseData)) continue;

        final matchResult = _matchVerse(verseData, query, normalizedQuery);
        if (matchResult != null) {
          results.add(matchResult);
        }
      }
    });

    return results;
  }

  /// Check if surah should be skipped based on filters
  bool _shouldSkipSurah(int surahNum) {
    if (filterBySurah.value && selectedSurah.value > 0) {
      return surahNum != selectedSurah.value;
    }
    return false;
  }

  /// Check if verse should be skipped based on filters
  bool _shouldSkipVerse(VerseData verseData) {
    // Juz filter
    if (selectedJuz.isNotEmpty && !selectedJuz.contains(verseData.juzNumber)) {
      return true;
    }

    // Verse length filter
    if (minVerseLength.value > 0 && verseData.verseLength < minVerseLength.value) {
      return true;
    }
    if (maxVerseLength.value > 0 && verseData.verseLength > maxVerseLength.value) {
      return true;
    }

    return false;
  }

  /// Match verse against search query
  SearchResult? _matchVerse(VerseData verseData, String originalQuery, String normalizedQuery) {
    bool matches = false;
    int matchCount = 0;
    List<int> matchPositions = [];

    switch (searchMode.value) {
      case SearchMode.exact:
        matches = verseData.normalizedText == normalizedQuery;
        matchCount = matches ? 1 : 0;
        break;
        
      case SearchMode.exactWord:
        final words = verseData.normalizedText.split(' ');
        matches = words.contains(normalizedQuery);
        matchCount = words.where((w) => w == normalizedQuery).length;
        break;
        
      case SearchMode.startsWith:
        final words = verseData.normalizedText.split(' ');
        matches = words.any((w) => w.startsWith(normalizedQuery));
        matchCount = words.where((w) => w.startsWith(normalizedQuery)).length;
        break;
        
      case SearchMode.endsWith:
        final words = verseData.normalizedText.split(' ');
        matches = words.any((w) => w.endsWith(normalizedQuery));
        matchCount = words.where((w) => w.endsWith(normalizedQuery)).length;
        break;
        
      case SearchMode.regex:
        try {
          final regex = RegExp(originalQuery, caseSensitive: caseSensitive.value);
          final regexMatches = regex.allMatches(verseData.normalizedText);
          matches = regexMatches.isNotEmpty;
          matchCount = regexMatches.length;
          matchPositions = regexMatches.map((m) => m.start).toList();
        } catch (e) {
          debugPrint('Invalid regex: $originalQuery');
        }
        break;
        
      case SearchMode.contains:
      default:
        matches = verseData.normalizedText.contains(normalizedQuery);
        matchCount = _countOccurrences(verseData.normalizedText, normalizedQuery);
        matchPositions = _findAllPositions(verseData.normalizedText, normalizedQuery);
    }

    if (!matches) return null;

    return SearchResult(
      verseData: verseData,
      relevanceScore: _calculateRelevanceScore(verseData, normalizedQuery, matchCount),
      matchCount: matchCount,
      matchPositions: matchPositions,
      highlightedText: _createHighlightedText(verseData.arabicText, originalQuery),
    );
  }

  /// Calculate relevance score for ranking
  double _calculateRelevanceScore(VerseData verse, String query, int matchCount) {
    double score = 0.0;

    // Base score from match count
    score += matchCount * 10.0;

    // Bonus for shorter verses (more relevant)
    score += 5.0 / (verse.wordCount / 10.0 + 1);

    // Bonus for query being a larger portion of the verse
    final queryRatio = query.length / verse.normalizedText.length;
    score += queryRatio * 20.0;

    // Penalty for very long verses
    if (verse.wordCount > 50) {
      score *= 0.8;
    }

    return score;
  }

  /// Sort results by relevance
  List<SearchResult> _sortResults(List<SearchResult> results, String query) {
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results;
  }

  /// Create highlighted text for display
  String _createHighlightedText(String text, String query) {
    // This returns the original text as highlighting is done in UI
    // The matchPositions in SearchResult can be used for RichText highlighting
    return text;
  }

  // ==================== Search Suggestions ====================
  
  /// Generate smart search suggestions
  void _generateSearchSuggestions(String query) {
    if (query.length < 2) {
      searchSuggestions.clear();
      return;
    }

    final normalizedQuery = _normalizeText(query);
    
    // Check suggestion cache
    if (_suggestionCache.containsKey(normalizedQuery)) {
      searchSuggestions.assignAll(_suggestionCache[normalizedQuery]!);
      return;
    }

    final suggestions = <String>{};
    
    // Add from recent searches
    for (var item in recentSearches.take(5)) {
      if (item.query.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(item.query);
      }
    }

    // Add word-based suggestions from verses (limited for performance)
    if (suggestions.length < 5) {
      // TODO: Implement trie-based word suggestion for better performance
      // For now, we keep it simple
    }

    final suggestionList = suggestions.take(8).toList();
    _suggestionCache[normalizedQuery] = suggestionList;
    searchSuggestions.assignAll(suggestionList);
  }

  // ==================== Utility Functions ====================
  
  /// Generate unique cache key including all filters
  String _generateCacheKey(String query) {
    return [
      query,
      'surah:${filterBySurah.value ? selectedSurah.value : "all"}',
      'mode:${searchMode.value.name}',
      'case:${caseSensitive.value}',
      'juz:${selectedJuz.join(",")}',
      'len:${minVerseLength.value}-${maxVerseLength.value}',
    ].join('|');
  }

  /// Manage cache size to prevent memory issues
  void _manageCacheSize() {
    if (_searchCache.length > _maxCacheSize) {
      final keysToRemove = _searchCache.keys.take(_searchCache.length - _maxCacheSize);
      for (var key in keysToRemove) {
        _searchCache.remove(key);
      }
    }
  }

  /// Normalize Arabic text for consistent searching
  String _normalizeText(String text) {
    if (caseSensitive.value) {
      return removeDiacritics(text);
    }
    return removeDiacritics(text.toLowerCase());
  }

  /// Remove Arabic diacritical marks
  String removeDiacritics(String text) {
    const diacritics = [
      '\u0610', '\u0611', '\u0612', '\u0613', '\u0614', '\u0615',
      '\u0616', '\u0617', '\u0618', '\u0619', '\u061A', '\u064B',
      '\u064C', '\u064D', '\u064E', '\u064F', '\u0650', '\u0651',
      '\u0652', '\u0653', '\u0654', '\u0655', '\u0656', '\u0657',
      '\u0658', '\u0659', '\u065A', '\u065B', '\u065C', '\u065D',
      '\u065E', '\u065F', '\u0670',
    ];
    
    String result = text;
    for (final mark in diacritics) {
      result = result.replaceAll(mark, '');
    }
    return result;
  }

  /// Count occurrences of term in text
  int _countOccurrences(String text, String term) {
    if (term.isEmpty) return 0;
    int count = 0;
    int index = 0;
    while ((index = text.indexOf(term, index)) != -1) {
      count++;
      index += term.length;
    }
    return count;
  }

  /// Find all positions of term in text
  List<int> _findAllPositions(String text, String term) {
    final positions = <int>[];
    int index = 0;
    while ((index = text.indexOf(term, index)) != -1) {
      positions.add(index);
      index += term.length;
    }
    return positions;
  }

  // ==================== Filter Management ====================
  
  void toggleSurahFilter(bool value) {
    filterBySurah.value = value;
    if (searchQuery.isNotEmpty) executeSearch();
  }

  void selectSurah(int surahNum) {
    selectedSurah.value = surahNum;
    if (filterBySurah.value && searchQuery.isNotEmpty) executeSearch();
  }

  void toggleExactMatch(bool value) {
    exactMatch.value = value;
    searchMode.value = value ? SearchMode.exactWord : SearchMode.contains;
    if (searchQuery.isNotEmpty) executeSearch();
  }

  void setSearchMode(SearchMode mode) {
    searchMode.value = mode;
    if (searchQuery.isNotEmpty) executeSearch();
  }

  void toggleJuzFilter(int juz) {
    if (selectedJuz.contains(juz)) {
      selectedJuz.remove(juz);
    } else {
      selectedJuz.add(juz);
    }
    if (searchQuery.isNotEmpty) executeSearch();
  }

  void clearAllFilters() {
    filterBySurah.value = false;
    selectedSurah.value = 0;
    exactMatch.value = false;
    caseSensitive.value = false;
    searchMode.value = SearchMode.contains;
    selectedJuz.clear();
    minVerseLength.value = 0;
    maxVerseLength.value = 0;
    if (searchQuery.isNotEmpty) executeSearch();
  }

  // ==================== Export & Analytics ====================
  
  /// Export search results
  Future<String> exportResults({String format = 'json'}) async {
    // TODO: Implement export functionality
    return '';
  }

  /// Get search statistics
  Map<String, dynamic> getSearchStatistics() {
    return {
      'totalSearches': totalSearches.value,
      'averageSearchTime': averageSearchTime.value,
      'cacheSize': _searchCache.length,
      'indexedVerses': totalVersesIndexed.value,
      'recentSearchCount': recentSearches.length,
    };
  }

  @override
  void onClose() {   _searchCache.clear();
    _versesCache.clear();
    _suggestionCache.clear();
    super.onClose();
  }
}

// ==================== Data Models ====================

enum SearchMode {
  contains,
  exactWord,
  exact,
  startsWith,
  endsWith,
  regex,
}

class VerseData {
  final int surahNumber;
  final int verseNumber;
  final String arabicText;
  final String normalizedText;
  final String surahName;
  final String surahNameEn;
  final int juzNumber;
  final int pageNumber;
  final int verseLength;
  final int wordCount;

  VerseData({
    required this.surahNumber,
    required this.verseNumber,
    required this.arabicText,
    required this.normalizedText,
    required this.surahName,
    required this.surahNameEn,
    required this.juzNumber,
    required this.pageNumber,
    required this.verseLength,
    required this.wordCount,
  });
}

class SearchResult {
  final VerseData verseData;
  final double relevanceScore;
  final int matchCount;
  final List<int> matchPositions;
  final String highlightedText;

  SearchResult({
    required this.verseData,
    required this.relevanceScore,
    required this.matchCount,
    required this.matchPositions,
    required this.highlightedText,
  });

  // Convenience getters
  int get surahNumber => verseData.surahNumber;
  int get verseNumber => verseData.verseNumber;
  String get verse => verseData.arabicText;
  String get surah => verseData.surahName;
  String get surahEn => verseData.surahNameEn;
  int get juzNumber => verseData.juzNumber;
}

class SearchHistoryItem {
  final String query;
  final DateTime timestamp;
  final int resultsCount;
  final Map<String, dynamic> filters;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
    required this.resultsCount,
    required this.filters,
  });

  Map<String, dynamic> toJson() => {
    'query': query,
    'timestamp': timestamp.toIso8601String(),
    'resultsCount': resultsCount,
    'filters': filters,
  };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) => SearchHistoryItem(
    query: json['query'],
    timestamp: DateTime.parse(json['timestamp']),
    resultsCount: json['resultsCount'],
    filters: json['filters'],
  );
}