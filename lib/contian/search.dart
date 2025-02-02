import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import 'displaysurrah.dart';

/// Controller for managing Quran search functionality.
class SearchController extends GetxController {
  // Observables for search query and results
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, String>> searchResults = <Map<String, String>>[].obs;

  // Caches for optimized performance
  final Map<String, List<Map<String, String>>> _searchCache = {};
  final Map<int, List<Map<String, String>>> _versesCache = {};

  @override
  void onInit() {
    super.onInit();
    _cacheQuranVerses();
  }

  /// Preloads Quran verses into a cache for fast search operations.
  void _cacheQuranVerses() {
    print("Caching Quran verses...");
    for (int surah = 1; surah <= 114; surah++) {
      _versesCache[surah] = [];
      for (int verse = 1; verse <= quran.getVerseCount(surah); verse++) {
        final verseText = quran.getVerse(surah, verse, verseEndSymbol: true);
        final normalizedText = _removeDiacritics(verseText.toLowerCase());

        _versesCache[surah]!.add({
          "surah": quran.getSurahName(surah),
          "verse": verseText,
          "surahNumber": surah.toString(),
          "verseNumber": verse.toString(),
          "normalized": normalizedText,
        });
      }
    }
    print("Caching complete. Total Surahs: ${_versesCache.length}");
  }

  /// Executes a search query and updates the results.
  void search(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    print("Search query: $query");

    // Use cached results if available
    if (_searchCache.containsKey(query)) {
      print("Using cached results for: $query");
      searchResults.assignAll(_searchCache[query]!);
      return;
    }

    final normalizedQuery = _removeDiacritics(query.toLowerCase());
    final results = <Map<String, String>>[];

    // Search through the cached verses
    for (var verses in _versesCache.values) {
      for (var verseData in verses) {
        if (verseData["normalized"]!.contains(normalizedQuery)) {
          results.add({
            "surah": verseData["surah"]!,
            "verse": verseData["verse"]!,
            "surahNumber": verseData["surahNumber"]!,
            "verseNumber": verseData["verseNumber"]!,
          });
        }
      }
    }

    print("Found ${results.length} results for: $query");

    // Cache and update results
    if (results.isNotEmpty) {
      _searchCache[query] = results;
    }
    searchResults.assignAll(results);
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

  @override
  void onClose() {
    _searchCache.clear();
    _versesCache.clear();
    super.onClose();
  }
}

/// UI for searching the Quran.
class SearchScreen extends StatelessWidget {
  final SearchController searchController = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'البحث في القرآن الكريم',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold ,color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal[700],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1F6E8C).withOpacity(0.1), Colors.white],
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Obx(() => _buildSearchResults()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the search bar widget.
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 18, height: 1.5),
        decoration: InputDecoration(
          hintText: 'ابحث في آيات القرآن الكريم...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1F6E8C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        onChanged: (value) {
          searchController.searchQuery.value = value;
          searchController.search(value);
        },
      ),
    );
  }

  /// Builds the search results or appropriate placeholders.
  Widget _buildSearchResults() {
    if (searchController.searchQuery.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.search,
        text: 'ابدأ البحث في القرآن الكريم',
      );
    } else if (searchController.searchResults.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.not_interested,
        text: 'لم يتم العثور على نتائج',
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: searchController.searchResults.length,
        itemBuilder: (context, index) {
          final result = searchController.searchResults[index];
          return _buildResultCard(result);
        },
      );
    }
  }

  /// Builds a placeholder widget for empty or no-result states.
  Widget _buildPlaceholder({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(fontSize: 20, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  /// Builds a result card for a single search result.
  /// Builds a result card for a single search result.
  Widget _buildResultCard(Map<String, String> result) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to the new screen to show the full Surah and highlight the verse
          Get.to(() => SurahDetailScreen(
                surahNumber: int.parse(result["surahNumber"]!),
                highlightedVerse: int.parse(result["verseNumber"]!),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                result["verse"]!,
                style: const TextStyle(fontSize: 20, height: 1.8),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                '${result["surah"]} - الآية ${result["verseNumber"]}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF1F6E8C)),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
