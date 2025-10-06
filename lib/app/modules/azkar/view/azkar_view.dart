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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Get.theme.colorScheme.surface,
            Get.theme.colorScheme.primaryContainer.withOpacity(0.1),
          ],
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
                const Text(
                  'المسبحة الإلكترونية',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "BahijTheSansArabic",
                  ),
                ),
                const SizedBox(height: 40),

                // Progress Ring with Counter
                Obx(() {
                  final progress = controller.tasbihCount.value /
                      controller.dailyTargetCount.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Get.theme.colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? Colors.green
                                : Get.theme.colorScheme.primary,
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
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.15,
                              fontWeight: FontWeight.bold,
                              fontFamily: "BahijTheSansArabic",
                              color: progress >= 1.0
                                  ? Colors.green
                                  : Get.theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'من ${controller.dailyTargetCount.value}',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "BahijTheSansArabic",
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 40),

                // Main Tasbih Button with Animation
                Obx(() {
                  final isCompleted = controller.tasbihCount.value >=
                      controller.dailyTargetCount.value;

                  return GestureDetector(
                    onTap: controller.incrementTasbih,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 - (value * 0.05),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isCompleted
                                    ? [Colors.green, Colors.green.shade700]
                                    : [
                                        Get.theme.colorScheme.primary,
                                        Get.theme.colorScheme.primaryContainer,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isCompleted
                                          ? Colors.green
                                          : Get.theme.colorScheme.primary)
                                      .withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(80),
                                onTap: controller.incrementTasbih,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? Icons.check_circle_outline
                                            : Icons.touch_app,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        isCompleted ? 'مكتمل' : 'اضغط',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "BahijTheSansArabic",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 40),

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
                            foregroundColor: Colors.orange,
                            side: BorderSide(
                              color: hasProgress
                                  ? Colors.orange
                                  : Colors.grey.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            'إعادة تعيين',
                            style: TextStyle(
                              fontFamily: "BahijTheSansArabic",
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
                        foregroundColor: Get.theme.colorScheme.primary,
                        side: BorderSide(
                          color: Get.theme.colorScheme.primary,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.flag_outlined, size: 20),
                      label: const Text(
                        'الهدف',
                        style: TextStyle(
                          fontFamily: "BahijTheSansArabic",
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Stats Card
                Obx(() {
                  final percentage = ((controller.tasbihCount.value /
                              controller.dailyTargetCount.value) *
                          100)
                      .clamp(0, 100)
                      .toInt();
                  final remaining = (controller.dailyTargetCount.value -
                          controller.tasbihCount.value)
                      .clamp(0, controller.dailyTargetCount.value);

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                context,
                                icon: Icons.percent,
                                label: 'النسبة',
                                value: '$percentage%',
                                color: percentage >= 100
                                    ? Colors.green
                                    : Get.theme.colorScheme.primary,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Get.theme.colorScheme.outlineVariant,
                              ),
                              _buildStatItem(
                                context,
                                icon: Icons.trending_up,
                                label: 'المتبقي',
                                value: '$remaining',
                                color: Get.theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'تعيين الهدف اليومي',
          style: TextStyle(
            fontFamily: "BahijTheSansArabic",
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "BahijTheSansArabic",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'العدد المستهدف',
                labelStyle: const TextStyle(
                  fontFamily: "BahijTheSansArabic",
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [33, 100, 200, 500, 1000].map((count) {
                return ChoiceChip(
                  label: Text(
                    '$count',
                    style: const TextStyle(
                      fontFamily: "BahijTheSansArabic",
                    ),
                  ),
                  selected: false,
                  onSelected: (_) {
                    targetController.text = count.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: "BahijTheSansArabic",
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newTarget = int.tryParse(targetController.text);
              if (newTarget != null && newTarget > 0) {
                controller.dailyTargetCount.value = newTarget;
                controller.saveProgress();
                Get.back();
                Get.snackbar(
                  'تم',
                  'تم تحديث الهدف اليومي إلى $newTarget',
                  backgroundColor:
                      Get.theme.colorScheme.primary.withOpacity(0.1),
                  colorText: Get.theme.colorScheme.primary,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(
                fontFamily: "BahijTheSansArabic",
                fontWeight: FontWeight.bold,
              ),
            ),
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
    return Obx(() {
      final currentCount = controller.getAzkarProgress(categoryName, item.id);
      final isCompleted =
          controller.isAzkarCompleted(categoryName, item.id, item.count);
      final progressPercentage =
          ((currentCount / item.count) * 100).clamp(0, 100).toInt();

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: isCompleted ? 3 : 1,
        color: isCompleted ? Colors.green.withOpacity(0.05) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Azkar text with RTL direction
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: "BahijTheSansArabic",
                        height: 1.6,
                        fontSize: 16,
                      ),
                  textDirection: TextDirection.rtl,
                ),
              ),

              const SizedBox(height: 16),

              // Progress information row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العدد المطلوب: ${item.count}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: "BahijTheSansArabic",
                            ),
                      ),
                      Text(
                        'المنجز: $currentCount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: "BahijTheSansArabic",
                              color: isCompleted ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted ? 'مكتمل ✓' : '$progressPercentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "BahijTheSansArabic",
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: currentCount / item.count,
                  minHeight: 8,
                  backgroundColor: Get.theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Get.theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Increment button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCompleted
                          ? null
                          : () {
                              controller.incrementAzkarProgress(
                                  categoryName, item.id, item.count);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? Colors.green
                            : Get.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(
                        isCompleted ? Icons.check : Icons.add,
                        size: 20,
                      ),
                      label: Text(
                        isCompleted ? 'مكتمل' : 'تسبيحة',
                        style: const TextStyle(
                          fontFamily: "BahijTheSansArabic",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Decrement button (only show if not completed and has progress)
                  if (!isCompleted && currentCount > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.decrementAzkarProgress(
                              categoryName, item.id);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.remove, size: 20),
                        label: const Text(
                          'إنقاص',
                          style: TextStyle(
                            fontFamily: "BahijTheSansArabic",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Reset button for completed items
                  if (isCompleted)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Reset this specific azkar
                          controller.azkarProgress[categoryName]?[item.id] = 0;
                          controller.saveProgress();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text(
                          'إعادة',
                          style: TextStyle(
                            fontFamily: "BahijTheSansArabic",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (item.audio != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'الصوت',
                        'ميزة الصوت ستكون متاحة قريباً',
                        backgroundColor: Get.theme.colorScheme.surfaceVariant,
                        colorText: Get.theme.colorScheme.onSurfaceVariant,
                      );
                    },
                    icon: const Icon(Icons.volume_up),
                    label: const Text(
                      'تشغيل الصوت',
                      style: TextStyle(
                        fontFamily: "BahijTheSansArabic",
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
