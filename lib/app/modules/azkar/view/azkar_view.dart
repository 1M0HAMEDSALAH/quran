import 'package:quran_app/index.dart';

class AzkarController extends GetxController {
  // Tasbih counter
  final RxInt tasbihCount = 0.obs;
  final RxInt dailyTargetCount = 100.obs;

  // Azkar progress tracking - FIXED: Made it properly reactive
  final RxMap<String, Map<int, int>> azkarProgress =
      <String, Map<int, int>>{}.obs;
  final RxString lastCompletionDate = ''.obs;

  // Data
  final RxList<AzkarCategory> allCategories = <AzkarCategory>[].obs;
  final RxList<AzkarCategory> morningAzkar = <AzkarCategory>[].obs;
  final RxList<AzkarCategory> eveningAzkar = <AzkarCategory>[].obs;
  final RxBool isLoading = true.obs;

  static const String _progressKey = 'azkar_progress';
  static const String _lastDateKey = 'last_completion_date';
  static const String _tasbihKey = 'tasbih_count';

  @override
  void onInit() {
    super.onInit();
    initializeAzkar();
  }

  Future<void> initializeAzkar() async {
    isLoading.value = true;

    try {
      // Load azkar data from JSON
      final categories = await AzkarService.loadAzkarCategories();
      allCategories.value = categories;

      // Filter morning and evening azkar
      morningAzkar.value = AzkarService.filterMorningAzkar(categories);
      eveningAzkar.value = AzkarService.filterEveningAzkar(categories);

      // Load saved progress
      await loadProgress();

      // Check if it's a new day and reset if needed
      await checkAndResetDaily();
    } catch (e) {
      print('Error initializing azkar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load azkar progress
      final progressJson = prefs.getString(_progressKey);
      if (progressJson != null) {
        final Map<String, dynamic> decoded = json.decode(progressJson);
        azkarProgress.value = decoded
            .map((key, value) => MapEntry(key, Map<int, int>.from(value)));
      }

      // Load other data
      lastCompletionDate.value = prefs.getString(_lastDateKey) ?? '';
      tasbihCount.value = prefs.getInt(_tasbihKey) ?? 0;
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save azkar progress
      final progressJson = json.encode(azkarProgress);
      await prefs.setString(_progressKey, progressJson);

      // Save other data
      await prefs.setString(_lastDateKey, lastCompletionDate.value);
      await prefs.setInt(_tasbihKey, tasbihCount.value);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  Future<void> checkAndResetDaily() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastCompletionDate.value != today) {
      await resetDailyProgress();
      lastCompletionDate.value = today;
      await saveProgress();
    }
  }

  Future<void> resetDailyProgress() async {
    azkarProgress.clear();
    tasbihCount.value = 0;
  }

  // Tasbih methods
  void incrementTasbih() {
    if (tasbihCount.value < dailyTargetCount.value) {
      tasbihCount.value++;
      saveProgress();
    }

    if (tasbihCount.value == dailyTargetCount.value) {
      Get.snackbar(
        'مبارك!',
        'لقد أكملت العدد المستهدف لليوم',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
      );
    }
  }

  void resetTasbih() {
    tasbihCount.value = 0;
    saveProgress();
  }

  // FIXED: Azkar progress methods - Trigger reactive updates properly
  int getAzkarProgress(String categoryName, int azkarId) {
    return azkarProgress[categoryName]?[azkarId] ?? 0;
  }

  void incrementAzkarProgress(
      String categoryName, int azkarId, int requiredCount) {
    // Create completely new nested maps to trigger reactive update
    final updatedProgress = Map<String, Map<int, int>>.from(azkarProgress);

    if (!updatedProgress.containsKey(categoryName)) {
      updatedProgress[categoryName] = {};
    } else {
      // Create a new nested map
      updatedProgress[categoryName] =
          Map<int, int>.from(updatedProgress[categoryName]!);
    }

    final currentCount = updatedProgress[categoryName]![azkarId] ?? 0;
    if (currentCount < requiredCount) {
      updatedProgress[categoryName]![azkarId] = currentCount + 1;

      // CRITICAL: Assign the new map to trigger reactive update
      azkarProgress.value = updatedProgress;

      if (currentCount + 1 >= requiredCount) {
        Get.snackbar(
          'أحسنت!',
          'تم إكمال الذكر',
          backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
          colorText: Get.theme.colorScheme.secondary,
        );
      }

      saveProgress();
    }
  }

  void decrementAzkarProgress(String categoryName, int azkarId) {
    final currentCount = azkarProgress[categoryName]?[azkarId] ?? 0;
    if (currentCount > 0) {
      // Create completely new nested maps to trigger reactive update
      final updatedProgress = Map<String, Map<int, int>>.from(azkarProgress);

      if (updatedProgress.containsKey(categoryName)) {
        // Create a new nested map
        updatedProgress[categoryName] =
            Map<int, int>.from(updatedProgress[categoryName]!);
        updatedProgress[categoryName]![azkarId] = currentCount - 1;
        // CRITICAL: Assign the new map to trigger reactive update
        azkarProgress.value = updatedProgress;
      }

      saveProgress();
    }
  }

  void resetAzkarItem(String categoryName, int azkarId) {
    // Create a new map to trigger reactive update
    final updatedProgress = Map<String, Map<int, int>>.from(azkarProgress);

    if (updatedProgress.containsKey(categoryName)) {
      // Create a new nested map as well
      updatedProgress[categoryName] =
          Map<int, int>.from(updatedProgress[categoryName]!);
      updatedProgress[categoryName]![azkarId] = 0;
      // CRITICAL: Assign the new map to trigger reactive update
      azkarProgress.value = updatedProgress;
      saveProgress();
    }
  }

  bool isAzkarCompleted(String categoryName, int azkarId, int requiredCount) {
    return getAzkarProgress(categoryName, azkarId) >= requiredCount;
  }

  bool isCategoryCompleted(String categoryName, List<AzkarItem> items) {
    return items
        .every((item) => isAzkarCompleted(categoryName, item.id, item.count));
  }

  double getCategoryProgress(String categoryName, List<AzkarItem> items) {
    if (items.isEmpty) return 0.0;

    int completedCount = 0;
    for (final item in items) {
      if (isAzkarCompleted(categoryName, item.id, item.count)) {
        completedCount++;
      }
    }

    return completedCount / items.length;
  }
}

class AzkarView extends GetView<AzkarController> {
  const AzkarView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AzkarController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأذكار والتسبيح',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "BahijTheSansArabic",
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "BahijTheSansArabic",
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: "BahijTheSansArabic",
                ),
                tabs: [
                  Tab(text: 'المسبحة'),
                  Tab(text: 'جميع الأذكار'),
                  Tab(text: 'أذكار الصباح'),
                  Tab(text: 'أذكار المساء'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTasbihView(context),
                    _buildAllAzkarView(context),
                    _buildAzkarCategoryView(
                        context, controller.morningAzkar, 'morning'),
                    _buildAzkarCategoryView(
                        context, controller.eveningAzkar, 'evening'),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTasbihView(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF0F3E33);
    final Color goldAccent = const Color(0xFFCDA047);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0),
        image: DecorationImage(
          image: const AssetImage('assets/islamic_pattern.png'),
          opacity: isDark ? 0.05 : 0.03,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.diamond_outlined, color: goldAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'المسبحة الإلكترونية',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Amiri",
                        color: isDark ? goldAccent : primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.diamond_outlined, color: goldAccent, size: 20),
                  ],
                ),
                const SizedBox(height: 50),

                // Progress Ring with Counter
                Obx(() {
                  final progress = controller.tasbihCount.value /
                      controller.dailyTargetCount.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: isDark
                              ? Colors.white10
                              : primaryColor.withOpacity(0.1),
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? goldAccent : primaryColor,
                          ),
                        ),
                      ),
                      // Inner Decorative Circle
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: goldAccent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      // Counter Display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.tasbihCount.value}',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Amiri",
                              color: progress >= 1.0
                                  ? goldAccent
                                  : (isDark ? Colors.white : primaryColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'من ${controller.dailyTargetCount.value}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "Amiri",
                                color: isDark
                                    ? Colors.white70
                                    : primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 50),

                // Main Tasbih Button with Animation
                Obx(() {
                  final isCompleted = controller.tasbihCount.value >=
                      controller.dailyTargetCount.value;

                  return GestureDetector(
                    onTap: controller.incrementTasbih,
                    behavior: HitTestBehavior.opaque,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 - (value * 0.02),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isCompleted
                                    ? [goldAccent, const Color(0xFFA67C00)]
                                    : [primaryColor, const Color(0xFF165A4B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isCompleted ? goldAccent : primaryColor)
                                          .withOpacity(0.4),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.white
                                      .withOpacity(isDark ? 0.05 : 0.3),
                                  blurRadius: 10,
                                  // inset: true,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isCompleted
                                        ? Icons.verified
                                        : Icons.touch_app,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isCompleted ? 'اكتمل' : 'سبِّح',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Amiri",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 50),

                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Button
                    Obx(() {
                      final hasProgress = controller.tasbihCount.value > 0;
                      return AnimatedOpacity(
                        opacity: hasProgress ? 1.0 : 0.5,
                        duration: const Duration(milliseconds: 200),
                        child: OutlinedButton.icon(
                          onPressed:
                              hasProgress ? controller.resetTasbih : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: BorderSide(
                              color: hasProgress
                                  ? Colors.redAccent.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            'تصفير',
                            style: TextStyle(
                              fontFamily: "Amiri",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(width: 16),

                    // Set Target Button
                    OutlinedButton.icon(
                      onPressed: () => _showTargetDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? goldAccent : primaryColor,
                        side: BorderSide(
                          color: (isDark ? goldAccent : primaryColor)
                              .withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.flag_outlined, size: 20),
                      label: const Text(
                        'تحديد الهدف',
                        style: TextStyle(
                          fontFamily: "Amiri",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "BahijTheSansArabic",
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: "BahijTheSansArabic",
            color: Get.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showTargetDialog(BuildContext context) {
    final targetController = TextEditingController(
      text: controller.dailyTargetCount.value.toString(),
    );
    
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF0F3E33);
    final Color goldAccent = const Color(0xFFCDA047);

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? Colors.white10 : primaryColor.withOpacity(0.1),
          ),
        ),
        title: Column(
          children: [
            Icon(Icons.flag_circle, color: goldAccent, size: 40),
            const SizedBox(height: 8),
            Text(
              'تعيين الهدف اليومي',
              style: TextStyle(
                fontFamily: "Amiri",
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: isDark ? goldAccent : primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Amiri",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'العدد المستهدف',
                labelStyle: TextStyle(
                  fontFamily: "Amiri",
                  color: isDark ? Colors.white54 : primaryColor.withOpacity(0.6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: goldAccent, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: isDark ? Colors.white24 : primaryColor.withOpacity(0.2)),
                ),
                prefixIcon: Icon(Icons.flag, color: isDark ? goldAccent : primaryColor),
                filled: true,
                fillColor: isDark ? Colors.white10 : primaryColor.withOpacity(0.02),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [33, 100, 200, 500, 1000].map((count) {
                return InkWell(
                  onTap: () {
                    targetController.text = count.toString();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white24 : primaryColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontFamily: "Amiri",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: "Amiri",
                      fontSize: 16,
                      color: isDark ? Colors.white54 : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newTarget = int.tryParse(targetController.text);
                    if (newTarget != null && newTarget > 0) {
                      controller.dailyTargetCount.value = newTarget;
                      controller.saveProgress();
                      Get.back();
                      
                      // Delay snackbar to prevent GetX LateInitializationError during routing pop
                      Future.delayed(const Duration(milliseconds: 250), () {
                        Get.snackbar(
                          'تم',
                          'تمت مراجعة وتحديث الهدف اليومي إلى $newTarget',
                          backgroundColor: isDark ? Colors.white10 : primaryColor.withOpacity(0.1),
                          colorText: isDark ? goldAccent : primaryColor,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 16,
                          icon: Icon(Icons.check_circle, color: isDark ? goldAccent : primaryColor),
                        );
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حفظ الهدف',
                    style: TextStyle(
                      fontFamily: "Amiri",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllAzkarView(BuildContext context) {
    return Obx(() {
      if (controller.allCategories.isEmpty) {
        return const Center(
          child: Text(
            'لا توجد أذكار متاحة',
            style: TextStyle(
              fontFamily: "BahijTheSansArabic",
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.allCategories.length,
        itemBuilder: (context, categoryIndex) {
          final category = controller.allCategories[categoryIndex];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                category.category,
                style: const TextStyle(
                  fontFamily: "BahijTheSansArabic",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${category.array.length} أذكار',
                    style: TextStyle(
                      fontFamily: "BahijTheSansArabic",
                      color: Get.theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final progress = controller.getCategoryProgress(
                        category.category, category.array);
                    final completedCount =
                        (progress * category.array.length).round();
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Get.theme.colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0
                                ? Colors.green
                                : Get.theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'مكتمل: $completedCount/${category.array.length}',
                              style: TextStyle(
                                fontFamily: "BahijTheSansArabic",
                                fontSize: 11,
                                color: Get.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: "BahijTheSansArabic",
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: progress == 1.0
                                    ? Colors.green
                                    : Get.theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
              children: category.array.map((azkarItem) {
                return _buildAzkarItemCard(
                    context, azkarItem, category.category);
              }).toList(),
            ),
          );
        },
      );
    });
  }

  Widget _buildAzkarCategoryView(
      BuildContext context, List<AzkarCategory> categories, String type) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أذكار متاحة',
          style: TextStyle(
            fontFamily: "BahijTheSansArabic",
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              category.category,
              style: const TextStyle(
                fontFamily: "BahijTheSansArabic",
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Obx(() {
              final progress = controller.getCategoryProgress(
                  category.category, category.array);
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Get.theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.colorScheme.primary,
                ),
              );
            }),
            children: category.array.map((azkarItem) {
              return _buildAzkarItemCard(context, azkarItem, category.category);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAzkarItemCard(
      BuildContext context, AzkarItem item, String categoryName) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF0F3E33);
    final Color goldAccent = const Color(0xFFCDA047);

    return Obx(() {
      final currentCount = controller.getAzkarProgress(categoryName, item.id);
      final isCompleted =
          controller.isAzkarCompleted(categoryName, item.id, item.count);
      final progressPercentage =
          ((currentCount / item.count) * 100).clamp(0, 100).toInt();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? goldAccent.withOpacity(0.5)
                : (isDark ? Colors.white10 : primaryColor.withOpacity(0.05)),
            width: isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? goldAccent.withOpacity(0.1)
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Decorative header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.format_quote,
                      color: goldAccent.withOpacity(0.5), size: 28),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? goldAccent.withOpacity(0.1)
                          : primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isCompleted
                              ? goldAccent.withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    child: Text(
                      isCompleted ? 'مكتمل ✓' : '$currentCount / ${item.count}',
                      style: TextStyle(
                        color: isCompleted
                            ? (isDark ? goldAccent : primaryColor)
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Amiri",
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Azkar text with RTL direction
              Text(
                item.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: "Amiri",
                      height: 1.8,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white.withOpacity(0.9) : primaryColor,
                    ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 24),

              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 8,
                    width: MediaQuery.of(context).size.width *
                        (currentCount / item.count),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [goldAccent, const Color(0xFFA67C00)]
                            : [primaryColor, const Color(0xFF165A4B)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: goldAccent.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Increment button
                  Expanded(
                    child: GestureDetector(
                      onTap: isCompleted
                          ? null
                          : () {
                              controller.incrementAzkarProgress(
                                  categoryName, item.id, item.count);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: isCompleted
                              ? LinearGradient(colors: [
                                  goldAccent.withOpacity(0.2),
                                  goldAccent.withOpacity(0.1)
                                ])
                              : LinearGradient(colors: [
                                  primaryColor,
                                  const Color(0xFF165A4B)
                                ]),
                          borderRadius: BorderRadius.circular(14),
                          border: isCompleted
                              ? Border.all(color: goldAccent.withOpacity(0.5))
                              : null,
                          boxShadow: isCompleted
                              ? null
                              : [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: Text(
                            isCompleted ? 'اكتمل الذكر' : 'سبِّح',
                            style: TextStyle(
                              color: isCompleted
                                  ? (isDark ? goldAccent : primaryColor)
                                  : Colors.white,
                              fontFamily: "Amiri",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (isCompleted || currentCount > 0) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (isCompleted) {
                          controller.azkarProgress[categoryName]?[item.id] = 0;
                          controller.saveProgress();
                        } else {
                          controller.decrementAzkarProgress(
                              categoryName, item.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isCompleted ? Icons.refresh : Icons.remove,
                          color: isDark
                              ? Colors.white54
                              : primaryColor.withOpacity(0.7),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (item.audio != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: InkWell(
                    onTap: () {
                      Get.snackbar(
                        'قيد التطوير',
                        'ميزة الصوت ستكون متاحة قريباً',
                        backgroundColor: isDark
                            ? Colors.white10
                            : primaryColor.withOpacity(0.1),
                        colorText: isDark ? goldAccent : primaryColor,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : primaryColor.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up_rounded,
                              color: isDark ? goldAccent : primaryColor,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'الاستماع للذكر',
                            style: TextStyle(
                              fontFamily: "Amiri",
                              color: isDark ? Colors.white70 : primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
