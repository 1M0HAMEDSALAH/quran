import 'package:quran/quran.dart' as quran;
import 'package:quran_app/index.dart';

/// Professional Quran search screen with advanced UI and features
class SearchScreen extends StatelessWidget {
  final SearchAyaController searchController = Get.put(SearchAyaController());
  final SettingsController settingsController = Get.find<SettingsController>();
  final TextEditingController textController = TextEditingController();
  final FocusNode searchFocus = FocusNode();

  SearchScreen({super.key});

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
                _buildAdvancedFilters(isDarkMode),
                _buildSearchSuggestions(isDarkMode),
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

  // ==================== App Bar ====================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: const Text('البحث في القرآن الكريم'),
      centerTitle: true,
      actions: [
        Obx(() => searchController.recentSearches.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.history),
                onPressed: _showRecentSearches,
                tooltip: 'عمليات البحث السابقة',
              )
            : const SizedBox()),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search_mode',
              child: ListTile(
                leading: Icon(Icons.search_outlined),
                title: Text('وضع البحث'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'filters',
              child: ListTile(
                leading: Icon(Icons.filter_list),
                title: Text('الفلاتر المتقدمة'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'statistics',
              child: ListTile(
                leading: Icon(Icons.analytics_outlined),
                title: Text('الإحصائيات'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('تصدير النتائج'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'search_mode':
        _showSearchModeDialog();
        break;
      case 'filters':
        _showAdvancedFiltersDialog();
        break;
      case 'statistics':
        _showStatistics();
        break;
      case 'export':
        _exportResults();
        break;
    }
  }

  // ==================== Search Bar ====================

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
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
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
                : const Icon(Icons.search, color: AppColor.primaryColor),
          ),
          suffixIcon: Obx(
            () => searchController.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryColor,
                      ),
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

  // ==================== Search Suggestions ====================

  Widget _buildSearchSuggestions(bool isDarkMode) {
    return Obx(() {
      if (searchController.searchSuggestions.isEmpty ||
          searchController.searchQuery.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: searchController.searchSuggestions.length,
          itemBuilder: (context, index) {
            final suggestion = searchController.searchSuggestions[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ActionChip(
                label: Text(suggestion),
                avatar: const Icon(Icons.history, size: 16),
                backgroundColor:
                    isDarkMode ? Colors.grey[800] : Colors.grey[200],
                onPressed: () {
                  textController.text = suggestion;
                  searchController.updateSearchQuery(suggestion);
                },
              ),
            );
          },
        ),
      );
    });
  }

  // ==================== Advanced Filters ====================

  Widget _buildAdvancedFilters(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                // Search mode chip
                _buildSearchModeChip(isDarkMode),
                const SizedBox(width: 8),

                // Surah filter
                FilterChip(
                  label: const Text('تصفية حسب السورة'),
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

                // Selected surah display
                if (searchController.filterBySurah.value &&
                    searchController.selectedSurah.value > 0)
                  ActionChip(
                    label: Text(
                      'سورة ${quran.getSurahName(searchController.selectedSurah.value)}',
                    ),
                    avatar: const Icon(Icons.book, size: 16),
                    backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                    onPressed: _showSurahSelector,
                   ),
                const SizedBox(width: 8),

                // Case sensitive toggle
                FilterChip(
                  label: const Text('حساس لحالة الأحرف'),
                  selected: searchController.caseSensitive.value,
                  selectedColor: AppColor.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColor.primaryColor,
                  onSelected: (bool value) {
                    searchController.caseSensitive.value = value;
                    searchController.executeSearch();
                  },
                ),
                const SizedBox(width: 8),

                // Active filters indicator
                if (_hasActiveFilters())
                  ActionChip(
                    label: const Text('مسح جميع الفلاتر'),
                    avatar: const Icon(Icons.clear_all, size: 16),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.red),
                    onPressed: () {
                      searchController.clearAllFilters();
                      textController.clear();
                    },
                  ),
              ],
            )),
      ),
    );
  }

  Widget _buildSearchModeChip(bool isDarkMode) {
    return Obx(() {
      final mode = searchController.searchMode.value;
      String label;
      
      switch (mode) {
        case SearchMode.exactWord:
          label = 'كلمة كاملة';
          break;
        case SearchMode.exact:
          label = 'مطابقة تامة';
          break;
        case SearchMode.startsWith:
          label = 'يبدأ بـ';
          break;
        case SearchMode.endsWith:
          label = 'ينتهي بـ';
          break;
        case SearchMode.regex:
          label = 'نمط متقدم';
          break;
        case SearchMode.contains:
        default:
          label = 'يحتوي على';
      }

      return ActionChip(
        label: Text(label),
        avatar: const Icon(Icons.tune, size: 16),
        backgroundColor: AppColor.primaryColor.withOpacity(0.1),
        onPressed: _showSearchModeDialog,
      );
    });
  }

  bool _hasActiveFilters() {
    return searchController.filterBySurah.value ||
        searchController.caseSensitive.value ||
        searchController.selectedJuz.isNotEmpty ||
        searchController.minVerseLength.value > 0 ||
        searchController.maxVerseLength.value > 0 ||
        searchController.searchMode.value != SearchMode.contains;
  }

  // ==================== Results Header ====================

  Widget _buildResultsHeader(bool isDarkMode) {
    return Obx(() {
      if (!searchController.hasSearched.value ||
          searchController.searchQuery.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.grey[850]
              : AppColor.primaryColor.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_outlined,
              size: 16,
              color: AppColor.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'النتائج: ${searchController.resultCount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            const Spacer(),
            if (searchController.resultCount.value > 0) ...[
              Text(
                '${searchController.averageSearchTime.value.toStringAsFixed(2)}s',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ==================== Search Results ====================

  Widget _buildSearchResults(bool isDarkMode) {
    return Obx(() {
      // Show error if exists
      if (searchController.errorMessage.isNotEmpty) {
        return _buildErrorState(isDarkMode);
      }

      if (searchController.isLoading.value) {
        return _buildLoadingState(isDarkMode);
      }

      if (!searchController.hasSearched.value) {
        return _buildInitialSearchState(isDarkMode);
      }

      if (searchController.searchQuery.isEmpty) {
        return _buildPlaceholder(
          icon: Icons.search,
          text: 'ابدأ البحث في القرآن الكريم',
          isDarkMode: isDarkMode,
        );
      }

      if (searchController.searchResults.isEmpty) {
        return _buildEmptyResultsState(isDarkMode);
      }

      return _buildResultsList(isDarkMode);
    });
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColor.primaryColor,
                ),
              ),
              Icon(
                Icons.book,
                size: 32,
                color: AppColor.primaryColor.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'جاري البحث في القرآن الكريم...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                '${searchController.totalVersesIndexed.value} آية مفهرسة',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              searchController.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              searchController.errorMessage.value = '';
              searchController.executeSearch();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'لم يتم العثور على نتائج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'جرب استخدام كلمات بحث مختلفة أو تغيير وضع البحث',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showSearchModeDialog,
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('تغيير وضع البحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => searchController.clearAllFilters(),
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('مسح الفلاتر'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: searchController.searchResults.length,
      itemBuilder: (context, index) {
        final result = searchController.searchResults[index];
        return _buildResultCard(result, isDarkMode);
      },
    );
  }

  Widget _buildInitialSearchState(bool isDarkMode) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            SvgPicture.asset(
              'assets/images/quran_icon.svg',
              height: 100,
              // ignore: deprecated_member_use
              color: isDarkMode
                  ? Colors.white54
                  : AppColor.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'ابحث في القرآن الكريم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'يمكنك البحث عن آية أو كلمة أو جزء من القرآن الكريم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSearchTipsCard(isDarkMode),
            const SizedBox(height: 24),
            _buildSearchFeaturesGrid(isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTipsCard(bool isDarkMode) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColor.primaryColor,
                size: 24,
              ),
             SizedBox(width: 8),
               Text(
                'نصائح للبحث:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('البحث لا يحتاج إلى التشكيل', Icons.check_circle, isDarkMode),
          _buildTipItem('استخدم وضع "كلمة كاملة" للدقة', Icons.check_circle, isDarkMode),
          _buildTipItem('يمكنك التصفية حسب السورة والجزء', Icons.check_circle, isDarkMode),
          _buildTipItem('جرب أوضاع البحث المختلفة', Icons.check_circle, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColor.primaryColor.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFeaturesGrid(bool isDarkMode) {
    final features = [
      {'icon': Icons.speed, 'title': 'بحث سريع', 'desc': 'نتائج فورية'},
      {'icon': Icons.tune, 'title': 'فلاتر متقدمة', 'desc': 'تحكم دقيق'},
      {'icon': Icons.history, 'title': 'سجل البحث', 'desc': 'عمليات سابقة'},
      {'icon': Icons.bookmark, 'title': 'حفظ النتائج', 'desc': 'للرجوع لاحقاً'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  feature['icon'] as IconData,
                  size: 32,
                  color: AppColor.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['desc'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subText != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Result Card ====================

  Widget _buildResultCard(SearchResult result, bool isDarkMode) {
    return Card(
      elevation: isDarkMode ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => SurahDetailScreen(
                surahNumber: result.surahNumber,
                highlightedVerse: result.verseNumber,
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Relevance indicator
              if (result.matchCount > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${result.matchCount} تطابق',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (result.matchCount > 1) const SizedBox(height: 8),

              // Main verse text with highlighting
              _buildHighlightedText(
                result.verse,
                searchController.searchQuery.value,
                result.matchPositions,
                isDarkMode,
              ),
              
              const SizedBox(height: 12),

              // Metadata row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Surah info
                  _buildMetadataChip(
                    icon: Icons.menu_book_rounded,
                    label: result.surah,
                    color: AppColor.primaryColor,
                    isDarkMode: isDarkMode,
                  ),
                  
                  // Verse number
                  _buildMetadataChip(
                    icon: Icons.format_list_numbered,
                    label: 'الآية ${result.verseNumber}',
                    color: Colors.amber[700]!,
                    isDarkMode: isDarkMode,
                  ),
                  
                  // Juz number
                  _buildMetadataChip(
                    icon: Icons.bookmark,
                    label: 'الجزء ${result.juzNumber}',
                    color: Colors.green[700]!,
                    isDarkMode: isDarkMode,
                  ),

                  // Page number
                  _buildMetadataChip(
                    icon: Icons.description,
                    label: 'ص ${result.verseData.pageNumber}',
                    color: Colors.blue[700]!,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Text Highlighting ====================

  Widget _buildHighlightedText(
    String text,
    String searchTerm,
    List<int> matchPositions,
    bool isDarkMode,
  ) {
    if (searchTerm.isEmpty || matchPositions.isEmpty) {
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

    final normalizedSearchTerm =
        searchController.removeDiacritics(searchTerm.toLowerCase());
    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (int position in matchPositions) {
      final end = position + normalizedSearchTerm.length;

      // Add non-highlighted text before match
      if (position > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, position),
          style: TextStyle(
            fontSize: 20,
            height: 1.8,
            color: isDarkMode ? Colors.white : Colors.black87,
            fontFamily: settingsController.arabicFontFamily,
          ),
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(position, end as int?),
        style: TextStyle(
          fontSize: 20,
          height: 1.8,
          backgroundColor: searchController.highlightColor,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontFamily: settingsController.arabicFontFamily,
        ),
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

  // ==================== Dialogs & Bottom Sheets ====================

  void _showRecentSearches() {
    final isDarkMode = settingsController.isDarkMode.value;
    
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                const SizedBox(width: 8),
                const Text(
                  'عمليات البحث السابقة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (searchController.recentSearches.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('تأكيد المسح'),
                          content: const Text('هل تريد مسح جميع عمليات البحث السابقة؟'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('إلغاء'),
                            ),
                            TextButton(
                              onPressed: () {
                                searchController.clearRecentSearches();
                                Get.back(); // Close dialog
                                Get.back(); // Close bottom sheet
                              },
                              child: const Text('مسح', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => searchController.recentSearches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد عمليات بحث سابقة',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: Get.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchController.recentSearches.length,
                        itemBuilder: (context, index) {
                          final item = searchController.recentSearches[index];
                          return ListTile(
                            leading: const Icon(Icons.history, size: 20),
                            title: Text(
                              item.query,
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              '${item.resultsCount} نتيجة • ${_formatDateTime(item.timestamp)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: Colors.red,
                              onPressed: () {
                                searchController.recentSearches.removeAt(index);
                                searchController.saveRecentSearches();
                              },
                            ),
                            onTap: () {
                              textController.text = item.query;
                              searchController.updateSearchQuery(item.query);
                              searchFocus.requestFocus();
                              Get.back();
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showSearchModeDialog() {
    final isDarkMode = settingsController.isDarkMode.value;
    
    Get.dialog(
      AlertDialog(
        title: const Text('اختر وضع البحث'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSearchModeOption(
                SearchMode.contains,
                'يحتوي على',
                'البحث عن أي نص يحتوي على الكلمة',
                Icons.search,
                isDarkMode,
              ),
              _buildSearchModeOption(
                SearchMode.exactWord,
                'كلمة كاملة',
                'البحث عن الكلمة بشكل كامل',
                Icons.text_fields,
                isDarkMode,
              ),
              _buildSearchModeOption(
                SearchMode.exact,
                'مطابقة تامة',
                'مطابقة النص بالكامل',
                Icons.done_all,
                isDarkMode,
              ),
              _buildSearchModeOption(
                SearchMode.startsWith,
                'يبدأ بـ',
                'كلمات تبدأ بالنص المدخل',
                Icons.start,
                isDarkMode,
              ),
              _buildSearchModeOption(
                SearchMode.endsWith,
                'ينتهي بـ',
                'كلمات تنتهي بالنص المدخل',
                Icons.last_page,
                isDarkMode,
              ),
              _buildSearchModeOption(
                SearchMode.regex,
                'نمط متقدم (Regex)',
                'للمستخدمين المتقدمين',
                Icons.code,
                isDarkMode,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchModeOption(
    SearchMode mode,
    String title,
    String description,
    IconData icon,
    bool isDarkMode,
  ) {
    return Obx(() {
      final isSelected = searchController.searchMode.value == mode;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.1)
              : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColor.primaryColor : null,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColor.primaryColor : null,
            ),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppColor.primaryColor)
              : null,
          onTap: () {
            searchController.setSearchMode(mode);
            Get.back();
          },
        ),
      );
    });
  }

  void _showAdvancedFiltersDialog() {
    
    Get.dialog(
      AlertDialog(
        title: const Text('الفلاتر المتقدمة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تصفية حسب الجزء:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(30, (index) {
                  final juz = index + 1;
                  final isSelected = searchController.selectedJuz.contains(juz);
                  return FilterChip(
                    label: Text('$juz'),
                    selected: isSelected,
                    selectedColor: AppColor.primaryColor.withOpacity(0.3),
                    onSelected: (selected) {
                      searchController.toggleJuzFilter(juz);
                    },
                  );
                }),
              )),
              const SizedBox(height: 16),
              const Text(
                'طول الآية (عدد الكلمات):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() => RangeSlider(
                values: RangeValues(
                  searchController.minVerseLength.value.toDouble(),
                  searchController.maxVerseLength.value > 0
                      ? searchController.maxVerseLength.value.toDouble()
                      : 200,
                ),
                min: 0,
                max: 200,
                divisions: 40,
                labels: RangeLabels(
                  searchController.minVerseLength.value.toString(),
                  searchController.maxVerseLength.value > 0
                      ? searchController.maxVerseLength.value.toString()
                      : 'max',
                ),
                onChanged: (values) {
                  searchController.minVerseLength.value = values.start.toInt();
                  searchController.maxVerseLength.value = values.end.toInt();
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchController.clearAllFilters();
              Get.back();
            },
            child: const Text('مسح الكل', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              searchController.executeSearch();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  void _showSurahSelector() {
    final isDarkMode = settingsController.isDarkMode.value;
    final searchQuery = ''.obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
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
              child: Row(
                children: [
                  const Icon(Icons.book),
                  const SizedBox(width: 8),
                  const Text(
                    'اختر سورة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (searchController.selectedSurah.value > 0)
                    TextButton(
                      onPressed: () {
                        searchController.selectSurah(0);
                        searchController.toggleSurahFilter(false);
                      },
                      child: const Text('مسح التحديد'),
                    ),
                ],
              ),
            ),

            // Search field for surahs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) => searchQuery.value = query,
              ),
            ),

            const SizedBox(height: 8),

            // Surahs list
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase();
                final filteredSurahs = List.generate(114, (i) => i + 1)
                    .where((surahNum) {
                  if (query.isEmpty) return true;
                  final arabicName =
                      quran.getSurahName(surahNum).toLowerCase();
                  final englishName =
                      quran.getSurahNameEnglish(surahNum).toLowerCase();
                  return arabicName.contains(query) ||
                      englishName.contains(query) ||
                      surahNum.toString().contains(query);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surahNumber = filteredSurahs[index];
                    final surahName = quran.getSurahName(surahNumber);
                    final surahNameEn =
                        quran.getSurahNameEnglish(surahNumber);
                    final versesCount = quran.getVerseCount(surahNumber);
                    final isSelected =
                        searchController.selectedSurah.value == surahNumber;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primaryColor.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColor.primaryColor
                                : (isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200]),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$surahNumber',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          surahName,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColor.primaryColor : null,
                          ),
                        ),
                        subtitle: Text(
                          '$surahNameEn • $versesCount آيات',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColor.primaryColor,
                              )
                            : null,
                        onTap: () {
                          searchController.selectSurah(surahNumber);
                          Get.back();
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showStatistics() {
    final stats = searchController.getSearchStatistics();
    final isDarkMode = settingsController.isDarkMode.value;

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics),
            SizedBox(width: 8),
            Text('إحصائيات البحث'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem(
              'إجمالي عمليات البحث',
              stats['totalSearches'].toString(),
              Icons.search,
              isDarkMode,
            ),
            _buildStatItem(
              'متوسط وقت البحث',
              '${stats['averageSearchTime'].toStringAsFixed(3)}s',
              Icons.speed,
              isDarkMode,
            ),
            _buildStatItem(
              'الآيات المفهرسة',
              stats['indexedVerses'].toString(),
              Icons.book,
              isDarkMode,
            ),
            _buildStatItem(
              'حجم الذاكرة المؤقتة',
              '${stats['cacheSize']} استعلام',
              Icons.storage,
              isDarkMode,
            ),
            _buildStatItem(
              'عمليات البحث الأخيرة',
              stats['recentSearchCount'].toString(),
              Icons.history,
              isDarkMode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style:const  TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportResults() async {
    if (searchController.searchResults.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد نتائج للتصدير',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // TODO: Implement actual export functionality
    Get.snackbar(
      'نجح',
      'جاري تصدير ${searchController.resultCount.value} نتيجة...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // ==================== Utility Functions ====================

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}