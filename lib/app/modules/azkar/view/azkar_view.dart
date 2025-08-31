import 'package:quran_app/index.dart';


class AthkarController extends GetxController {
  final RxInt tasbihCount = 0.obs;
  final RxInt dailyTargetCount = 100.obs;
  final RxList<String> completedMorningAthkar = <String>[].obs;
  final RxList<String> completedEveningAthkar = <String>[].obs;
  final RxString lastCompletionDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAthkarData();
  }

  // قائمة أذكار الصباح
  final List<Map<String, dynamic>> morningAthkar = [
    {
      'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'count': 100,
      'reward': 'حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ',
    },
    {
      'text': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'count': 3,
      'reward': 'لم يضره شيء',
    },
    {
      'text':
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'count': 100,
      'reward':
          'كان له عدل عشر رقاب، وكتبت له مئة حسنة، ومحيت عنه مئة سيئة، وكانت له حرزًا من الشيطان يومه ذلك حتى يمسي',
    },
    {
      'text':
          'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      'count': 33,
      'reward': 'أحب الكلام إلى الله وأثقلها في الميزان',
    },
    {
      'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      'count': 10,
      'reward': 'يصلي الله عليه بها عشرًا',
    },
    {
      'text': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'count': 100,
      'reward': 'sتكفير الذنوب',
    },
    {
      'text': 'اللَّهُمَّ أَجِرْنِي مِنَ النَّارِ',
      'count': 7,
      'reward':
          'إذا قالها بعد الفجر والمغرب سبع مرات كتب الله له النجاة من النار',
    },
    {
      'text':
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      'count': 3,
      'reward': 'لا يصيبه ضرر في ذلك اليوم أو تلك الليلة',
    },
    {
      'text':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      'count': 1,
      'reward': 'يحصل على العافية في الدين والدنيا والآخرة',
    },
    {
      'text':
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ',
      'count': 1,
      'reward': 'من قالها في الصباح أو المساء ومات دخل الجنة',
    },
  ];

  // قائمة أذكار المساء
  final List<Map<String, dynamic>> eveningAthkar = [
    {
      'text':
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      'count': 1,
      'reward': 'من قالها موقناً بها حين يمسي ومات من ليلته دخل الجنة',
    },
    {
      'text':
          'اللهم أنت ربي، لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي وأبوء بذنبي، فاغفر لي، فإنه لا يغفر الذنوب إلا أنت.',
      'count': 1,
      'reward': 'من قالها موقناً بها حين يمسي فمات من ليلته دخل الجنة',
    },
    {
      'text':
          'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ وَأُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلَائِكَتَكَ وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَهَ إِلَّا أَنْتَ، وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ.',
      'count': 4,
      'reward': 'من قالها أربع مرات أعتقه الله من النار',
    },
    {
      'text':
          'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ.',
      'count': 1,
      'reward': 'من قالها مساءً أدى شكر يومه',
    },
    {
      'text':
          'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.',
      'count': 7,
      'reward': 'من قالها سبع مرات كفاه الله ما أهمه من أمر الدنيا والآخرة',
    },
    {
      'text':
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
      'count': 3,
      'reward': 'من قالها ثلاث مرات لم يضره شيء في ليلته',
    },
    {
      'text': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
      'count': 3,
      'reward': 'من قالها ثلاث مرات لم تضره الحُمَةُ (السم أو الأذى) في ليلته',
    },
    {
      'text':
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي.',
      'count': 1,
      'reward': 'دعاء شامل لحفظ النفس والأهل والمال',
    },
  ];

  Future<void> loadAthkarData() async {
    final prefs = await SharedPreferences.getInstance();
    final today =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

    // Load last completion date
    final storedDate = prefs.getString('lastCompletionDate') ?? '';
    lastCompletionDate.value = storedDate;

    // Reset if it's a new day
    if (storedDate != today) {
      await resetDailyAthkar();
      lastCompletionDate.value = today;
      await prefs.setString('lastCompletionDate', today);
    } else {
      // Load completed morning and evening athkar
      final morningAthkarJson = prefs.getString('completedMorningAthkar');
      final eveningAthkarJson = prefs.getString('completedEveningAthkar');

      if (morningAthkarJson != null) {
        completedMorningAthkar
            .assignAll(List<String>.from(jsonDecode(morningAthkarJson)));
      }
      if (eveningAthkarJson != null) {
        completedEveningAthkar
            .assignAll(List<String>.from(jsonDecode(eveningAthkarJson)));
      }
    }
  }

  Future<void> saveAthkarData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'completedMorningAthkar', jsonEncode(completedMorningAthkar));
    await prefs.setString(
        'completedEveningAthkar', jsonEncode(completedEveningAthkar));
  }

  void incrementTasbih() {
    if (tasbihCount.value < dailyTargetCount.value) {
      tasbihCount.value++;
    }
    if (tasbihCount.value == dailyTargetCount.value) {
      Get.snackbar(
        'مبارك!',
        'لقد أكملت العدد المستهدف لليوم',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    }
  }

  void resetTasbih() {
    tasbihCount.value = 0;
  }

  void markAthkarCompleted(String athkarText, bool isMorning) async {
    final targetList =
        isMorning ? completedMorningAthkar : completedEveningAthkar;
    if (!targetList.contains(athkarText)) {
      targetList.add(athkarText);
      await saveAthkarData();
      Get.snackbar(
        'أحسنت!',
        'تم إكمال الذكر',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resetDailyAthkar() async {
    completedMorningAthkar.clear();
    completedEveningAthkar.clear();
    tasbihCount.value = 0;
    await saveAthkarData();
  }

  bool areAllMorningAthkarCompleted() {
    return morningAthkar
        .every((athkar) => completedMorningAthkar.contains(athkar['text']));
  }

  bool areAllEveningAthkarCompleted() {
    return eveningAthkar
        .every((athkar) => completedEveningAthkar.contains(athkar['text']));
  }
}

class AthkarView extends GetView<AthkarController> {
  const AthkarView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    final athkarController = Get.put(AthkarController());

    return Obx(() {
      final isDarkMode = settingsController.isDarkMode.value;
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'الأذكار والتسبيح',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "BahijTheSansArabic",
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "BahijTheSansArabic",
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: "BahijTheSansArabic",
              ),
              indicatorColor: Colors.teal[700],
              indicatorWeight: 3,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: Get.isDarkMode ? Colors.teal[300] : Colors.teal[700],
              unselectedLabelColor:
                  Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              tabs: const [
                Tab(text: 'المسبحة'),
                Tab(text: 'أذكار الصباح'),
                Tab(text: 'أذكار المساء'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildTasbihView(context, isDarkMode),
              _buildMorningAthkarView(context, isDarkMode),
              _buildEveningAthkarView(context, isDarkMode),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTasbihView(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => Text(
                '${controller.tasbihCount}',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.15,
                  fontWeight: FontWeight.bold,
                  fontFamily: "BahijTheSansArabic",
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: controller.incrementTasbih,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.teal[900]!, Colors.teal[600]!]
                      : [Colors.teal[700]!, Colors.teal[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.teal.withOpacity(0.4)
                        : Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: controller.resetTasbih,
            child: Text(
              'إعادة تعيين',
              style: TextStyle(
                fontFamily: "BahijTheSansArabic",
                color: isDarkMode ? Colors.teal[400] : Colors.teal[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningAthkarView(BuildContext context, bool isDarkMode) {
    return Obx(() {
      if (controller.areAllMorningAthkarCompleted() &&
          controller.lastCompletionDate.value ==
              DateTime.now().toIso8601String().substring(0, 10)) {
        return Center(
          child: Text(
            'غير وقت الأذكار الآن',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                // color: isDarkMode ? Colors.teal[400] : Colors.white,
                ),
            textDirection: TextDirection.rtl,
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.morningAthkar.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final athkar = controller.morningAthkar[index];
          return _buildAthkarCard(
            context,
            athkar['text'],
            athkar['count'],
            athkar['reward'],
            true,
            isDarkMode,
          );
        },
      );
    });
  }

  Widget _buildEveningAthkarView(BuildContext context, bool isDarkMode) {
    return Obx(() {
      if (controller.areAllEveningAthkarCompleted() &&
          controller.lastCompletionDate.value ==
              DateTime.now().toIso8601String().substring(0, 10)) {
        return Center(
          child: Text(
            'غير وقت الأذكار الآن',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                // color: isDarkMode ? Colors.teal[400] : Colors.teal[700],
                ),
            textDirection: TextDirection.rtl,
          ),
        );
      }
      return ListView.builder(
        itemCount: controller.eveningAthkar.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final athkar = controller.eveningAthkar[index];
          return _buildAthkarCard(
            context,
            athkar['text'],
            athkar['count'],
            athkar['reward'],
            false,
            isDarkMode,
          );
        },
      );
    });
  }

  Widget _buildAthkarCard(
    BuildContext context,
    String text,
    int count,
    String reward,
    bool isMorning,
    bool isDarkMode,
  ) {
    final RxInt currentCount = 0.obs;
    return Obx(() {
      final completedList = isMorning
          ? controller.completedMorningAthkar
          : controller.completedEveningAthkar;
      final isCompleted =
          completedList.contains(text) || currentCount.value >= count;
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                'عدد التكرار المطلوب: $count',
                style: Theme.of(context).textTheme.bodySmall,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                'الفضل: $reward',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.teal[400] : Colors.teal[700],
                    ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              Text(
                'عدد التكرارات الحالية: ${currentCount.value}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? (isDarkMode ? Colors.green[300] : Colors.green[700])
                          : (isDarkMode ? Colors.red[300] : Colors.red[700]),
                    ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Increment Button
                    AnimatedScale(
                      scale: isCompleted ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: isCompleted
                            ? null
                            : () {
                                currentCount.value++;
                                if (currentCount.value >= count) {
                                  controller.markAthkarCompleted(
                                      text, isMorning);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted
                              ? Colors.grey[600]
                              : (Get.isDarkMode
                                  ? Colors.teal[700]
                                  : Colors.teal[600]),
                          disabledBackgroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          shadowColor: Get.isDarkMode
                              ? Colors.teal[800]?.withOpacity(0.5)
                              : Colors.teal[100],
                        ),
                        child: Text(
                          isCompleted ? 'تم الإكمال' : 'اضغط لزيادة العدد',
                          style: TextStyle(
                            color:
                                isCompleted ? Colors.grey[300] : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Decrement Button (only shown when not completed)
                    if (!isCompleted)
                      AnimatedScale(
                        scale: currentCount.value > 0 ? 1.0 : 0.95,
                        duration: const Duration(milliseconds: 200),
                        child: Opacity(
                          opacity: currentCount.value > 0 ? 1.0 : 0.7,
                          child: ElevatedButton(
                            onPressed: currentCount.value > 0
                                ? () {
                                    currentCount.value--;
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Get.isDarkMode
                                  ? Colors.red[400]
                                  : Colors.red[500],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              shadowColor: Get.isDarkMode
                                  ? Colors.red[800]?.withOpacity(0.5)
                                  : Colors.red[100],
                            ),
                            child: Text(
                              'إنقاص العدد',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
