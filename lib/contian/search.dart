import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_app/contian/setting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../const/app_theme.dart';
import '../const/debouncer.dart';
import 'displaysurrah.dart';

/// Controller for managing advanced Quran search functionality.
class SearchController extends GetxController {
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
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  final Map<int, List<Map<String, dynamic>>> _versesCache = {};

  // Highlighted text color
  final Color highlightColor = Colors.amber.shade300;

  @override
  void onInit() {
    super.onInit();
    // Initialize debouncer for better UX (waits 500ms after user stops typing)
    debouncer = Debouncer<String>(
      duration: Duration(milliseconds: 500),
      initialValue: '',
      onChanged: _performSearch,
    );

    // Load recent searches from local storage
    _loadRecentSearches();

    // Pre-cache all Quran verses for instant searching
    _cacheQuranVerses();
  }

  /// Loads recent searches from storage
  void _loadRecentSearches() {
    // TODO: Implement persistent storage with GetStorage
    // For now just initialize with empty list
    recentSearches.value = [];
  }

  /// Saves recent searches to storage
  void _saveRecentSearches() {
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

    _saveRecentSearches();
  }

  /// Clears all recent searches
  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  /// Preloads Quran verses into a cache for fast search operations.
  void _cacheQuranVerses() {
    print("Caching Quran verses...");
    for (int surah = 1; surah <= 114; surah++) {
      _versesCache[surah] = [];
      for (int verse = 1; verse <= quran.getVerseCount(surah); verse++) {
        final verseText = quran.getVerse(surah, verse, verseEndSymbol: true);
        final normalizedText = _removeDiacritics(verseText.toLowerCase());
        final surahName = quran.getSurahName(surah);
        final surahNameEn = quran.getSurahNameEnglish(surah);

        _versesCache[surah]!.add({
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
    print("Caching complete. Total Surahs: ${_versesCache.length}");
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
      _performSearch(searchQuery.value);
    }
  }

  /// Performs the actual search operation
  void _performSearch(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      isLoading.value = false;
      hasSearched.value = false;
      return;
    }

    print("Executing search for: $query");
    hasSearched.value = true;

    // Generate a unique cache key that includes filters
    final cacheKey = _generateCacheKey(query);

    // Use cached results if available
    if (_searchCache.containsKey(cacheKey)) {
      print("Using cached results for: $cacheKey");
      searchResults.assignAll(_searchCache[cacheKey]!);
      resultCount.value = searchResults.length;
      isLoading.value = false;
      return;
    }

    final normalizedQuery = _removeDiacritics(query.toLowerCase());
    final results = <Map<String, dynamic>>[];

    // Search through the cached verses
    _versesCache.forEach((surahNum, verses) {
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
          resultItem["highlightedText"] = _highlightSearchTerms(
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
          _countOccurrences(a["normalized"] as String, normalizedQuery);
      final bOccurrences =
          _countOccurrences(b["normalized"] as String, normalizedQuery);
      return bOccurrences.compareTo(aOccurrences);
    });

    // Cache and update results
    if (results.isNotEmpty) {
      _searchCache[cacheKey] = results;
    }

    // Add to recent searches
    addToRecentSearches(query);

    // Update UI
    searchResults.assignAll(results);
    resultCount.value = results.length;
    isLoading.value = false;
  }

  /// Generates a unique cache key that includes all search parameters
  String _generateCacheKey(String query) {
    return '$query-surah:${filterBySurah.value ? selectedSurah.value : "all"}-exact:${exactMatch.value}';
  }

  /// Count occurrences of a term in a text
  int _countOccurrences(String text, String term) {
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
  String _highlightSearchTerms(String originalText, String searchTerm) {
    // This function is simplified - in a real app, you'd use rich text or HTML
    // For demo, we'll just return the original text as the actual highlighting
    // would happen in the UI with RichText
    return originalText;
  }

  /// Removes diacritical marks from Arabic text for normalized searches.
  String _removeDiacritics(String text) {
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
    _searchCache.clear();
    _versesCache.clear();
    debouncer.cancel();
    super.onClose();
  }
}

class SearchScreen extends StatelessWidget {
  final SearchController searchController = Get.put(SearchController());
  final SettingsController settingsController = Get.find<SettingsController>();
  final TextEditingController textController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Obx(() {
          final isDarkMode = settingsController.isDarkMode.value;
          return Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1F6E8C).withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
              color: isDarkMode ? Colors.grey[900] : null,
            ),
            child: Column(
              children: [
                _buildSearchBar(isDarkMode),
                _buildFilterBar(isDarkMode),
                _buildResultsHeader(isDarkMode),
                Expanded(
                  child: _buildSearchResults(isDarkMode),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        'البحث في القرآن الكريم',
      ),
      centerTitle: true,
      actions: [
        Obx(() => searchController.recentSearches.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _showRecentSearches(),
                tooltip: 'عمليات البحث السابقة',
              )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: TextField(
        controller: textController,
        focusNode: searchFocus,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 18,
          height: 1.5,
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: "BahijTheSansArabic",
        ),
        decoration: InputDecoration(
          hintText: 'ابحث في آيات القرآن الكريم...',
          prefixIcon: Obx(
            () => searchController.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      textController.clear();
                      searchController.updateSearchQuery('');
                    },
                    color: AppColor.primaryColor,
                  )
                : Icon(Icons.search, color: AppColor.primaryColor),
          ),
          suffixIcon: Obx(
            () => searchController.isLoading.value
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
        onChanged: (value) {
          searchController.updateSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Exact match switch
            FilterChip(
              label: Text(
                'مطابقة تامة',

              ),
              selected: searchController.exactMatch.value,
              selectedColor: AppColor.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColor.primaryColor,
              onSelected: (bool value) {
                searchController.toggleExactMatch(value);
              },
            ),
            const SizedBox(width: 8),

            // Surah filter
            FilterChip(
              label: Text(
                'تصفية حسب السورة',
              ),
              selected: searchController.filterBySurah.value,
              selectedColor: AppColor.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColor.primaryColor,
              onSelected: (bool value) {
                searchController.toggleSurahFilter(value);
                if (value && searchController.selectedSurah.value == 0) {
                  _showSurahSelector();
                }
              },
            ),
            const SizedBox(width: 8),

            // Selected surah chip (only show if filter is enabled)
            Obx(
              () => searchController.filterBySurah.value &&
                      searchController.selectedSurah.value > 0
                  ? ActionChip(
                      label: Text(
                        'سورة ${quran.getSurahName(searchController.selectedSurah.value)}',
                      ),
                      avatar: const Icon(Icons.book, size: 16),
                      backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                      onPressed: () => _showSurahSelector(),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(bool isDarkMode) {
    return Obx(() {
      if (!searchController.hasSearched.value ||
          searchController.searchQuery.isEmpty) {
        return const SizedBox();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: isDarkMode
            ? Colors.grey[850]
            : AppColor.primaryColor.withOpacity(0.05),
        child: Row(
          children: [
            Text(
              'النتائج: ${searchController.resultCount}',
            ),
            const Spacer(),
            if (searchController.resultCount.value > 0)
              Text(
                'اضغط على النتيجة للانتقال إلى السورة',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchResults(bool isDarkMode) {
    return Obx(() {
      if (searchController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColor.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري البحث...',
              ),
            ],
          ),
        );
      } else if (!searchController.hasSearched.value) {
        return _buildInitialSearchState(isDarkMode);
      } else if (searchController.searchQuery.isEmpty) {
        return _buildPlaceholder(
          icon: Icons.search,
          text: 'ابدأ البحث في القرآن الكريم',
          isDarkMode: isDarkMode,
        );
      } else if (searchController.searchResults.isEmpty) {
        return _buildPlaceholder(
          icon: Icons.not_interested,
          text: 'لم يتم العثور على نتائج',
          subText: 'جرب كلمات بحث أخرى أو تغيير خيارات التصفية',
          isDarkMode: isDarkMode,
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: searchController.searchResults.length,
          itemBuilder: (context, index) {
            final result = searchController.searchResults[index];
            return _buildResultCard(result, isDarkMode);
          },
        );
      }
    });
  }

  Widget _buildInitialSearchState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/quran_icon.svg',
            height: 100,
            color: isDarkMode
                ? Colors.white54
                : AppColor.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'ابحث في القرآن الكريم',
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'يمكنك البحث عن آية أو كلمة أو جزء من القرآن الكريم',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildSearchTipsCard(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSearchTipsCard(bool isDarkMode) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نصائح للبحث:',
          ),
          const SizedBox(height: 8),
          _buildTipItem('يمكنك البحث بدون تشكيل', isDarkMode),
          _buildTipItem(
              'استخدم "مطابقة تامة" للبحث عن كلمات كاملة', isDarkMode),
          _buildTipItem('يمكنك تصفية النتائج حسب السورة', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            size: 16,
            color: isDarkMode
                ? AppColor.primaryColor.withOpacity(0.7)
                : AppColor.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String text,
    String? subText,
    required bool isDarkMode,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            text,
          ),
          if (subText != null) ...[
            const SizedBox(height: 8),
            Text(
              subText,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => SurahDetailScreen(
                surahNumber: result["surahNumber"],
                highlightedVerse: result["verseNumber"],
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main verse text
              _buildHighlightedText(
                result["verse"],
                searchController.searchQuery.value,
                isDarkMode,
              ),
              const SizedBox(height: 10),

              // Metadata row
              Row(
                children: [
                  // Surah info
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 14,
                          color: AppColor.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${result["surah"]}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Verse number
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered,
                          size: 14,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'الآية ${result["verseNumber"]}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Juz number
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'الجزء ${result["juzNumber"]}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecentSearches() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: settingsController.isDarkMode.value
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'عمليات البحث السابقة',
            ),
            const SizedBox(height: 8),
            Obx(
              () => searchController.recentSearches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'لا توجد عمليات بحث سابقة.',
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: searchController.recentSearches
                          .map(
                            (search) => ListTile(
                              title: Text(
                                search,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  searchController.recentSearches
                                      .remove(search);
                                  searchController._saveRecentSearches();
                                  if (searchController.recentSearches.isEmpty) {
                                    Get.back(); // Close the sheet if no more searches
                                  }
                                },
                              ),
                              onTap: () {
                                textController.text = search;
                                searchController.updateSearchQuery(search);
                                searchFocus.requestFocus();
                                Get.back(); // Close the bottom sheet
                              },
                            ),
                          )
                          .toList(),
                    ),
            ),
            if (searchController.recentSearches.isNotEmpty)
              TextButton(
                child: Text(
                  'مسح السجل',
                ),
                onPressed: () {
                  searchController.clearRecentSearches();
                  Get.back(); // Close the bottom sheet
                },
              ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSurahSelector() {
    final isDarkMode = settingsController.isDarkMode.value;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7, // Take 70% of screen height
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar for the sheet
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'اختر سورة',
              ),
            ),

            // Search field for surahs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  // You can implement search filtering here
                  // For now we'll skip this for simplicity
                },
              ),
            ),

            // Surahs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: 114, // Total number of surahs in Quran
                itemBuilder: (context, index) {
                  final surahNumber = index + 1; // Surah numbers start from 1
                  final surahName = quran.getSurahName(surahNumber);
                  final surahNameEn = quran.getSurahNameEnglish(surahNumber);
                  final versesCount = quran.getVerseCount(surahNumber);

                  return ListTile(
                    title: Text(
                      '$surahNumber. $surahName',
                      textAlign: TextAlign.right,
                    ),
                    subtitle: Text(
                      '$surahNameEn - $versesCount آيات',
                      textAlign: TextAlign.right,
                    ),
                    trailing:
                        searchController.selectedSurah.value == surahNumber
                            ? Icon(
                                Icons.check_circle,
                                color: AppColor.primaryColor,
                              )
                            : null,
                    onTap: () {
                      searchController.selectSurah(surahNumber);
                      Get.back(); // Close the sheet
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildHighlightedText(
      String text, String searchTerm, bool isDarkMode) {
    // For simplicity in this example, we're using RichText with TextSpans
    // In a real app, you might want to use a more sophisticated approach

    if (searchTerm.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 20,
          height: 1.8,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: settingsController.arabicFontFamily,
        ),
        textAlign: TextAlign.right,
      );
    }

    // Normalize search term for case-insensitive matching
    final normalizedSearchTerm =
        searchController._removeDiacritics(searchTerm.toLowerCase());
    final normalizedText =
        searchController._removeDiacritics(text.toLowerCase());

    // Find all occurrences of the search term in the text
    List<int> matchPositions = [];
    int position = 0;
    while (true) {
      position = normalizedText.indexOf(normalizedSearchTerm, position);
      if (position == -1) break;
      matchPositions.add(position);
      position += normalizedSearchTerm.length;
    }

    // If no matches found, return normal text
    if (matchPositions.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.right,
      );
    }

    // Build text spans with highlighted search terms
    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (int i = 0; i < matchPositions.length; i++) {
      final int start = matchPositions[i];
      final int end = start + normalizedSearchTerm.length;

      // Add non-highlighted text before match
      if (start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, start),
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(start, end),
      ));

      lastIndex = end;
    }

    // Add remaining text after last match
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          fontSize: 20,
          height: 1.8,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontFamily: settingsController.arabicFontFamily,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.right,
    );
  }
}
