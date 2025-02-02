// athkar_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AthkarController extends GetxController {
  final RxInt tasbihCount = 0.obs;
  final RxInt dailyTargetCount = 100.obs;
  final RxList<String> completedAthkar = <String>[].obs;

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
      'reward': 'تكفير الذنوب',
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

  void markAthkarCompleted(String athkarText) {
    if (!completedAthkar.contains(athkarText)) {
      completedAthkar.add(athkarText);
      Get.snackbar(
        'أحسنت!',
        'تم إكمال الذكر',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  void resetDailyAthkar() {
    completedAthkar.clear();
    tasbihCount.value = 0;
  }
}

// athkar_view.dart
class AthkarView extends GetView<AthkarController> {
  AthkarController surahListController = Get.put(AthkarController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأذكار والتسبيح',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.teal[700],
          bottom: TabBar(
            labelStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'المسبحة'),
              Tab(text: 'أذكار الصباح'),
              Tab(text: 'أذكار المساء'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasbihView(),
            _buildMorningAthkarView(),
            _buildEveningAthkarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildTasbihView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => Text(
                '${controller.tasbihCount}',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )),
          SizedBox(height: 20),
          GestureDetector(
            onTap: controller.incrementTasbih,
            child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal[700],
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: controller.resetTasbih,
            child: Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  Widget _buildMorningAthkarView() {
    return ListView.builder(
      itemCount: controller.morningAthkar.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final athkar = controller.morningAthkar[index];
        return _buildAthkarCard(
          athkar['text'],
          athkar['count'],
          athkar['reward'],
        );
      },
    );
  }

  Widget _buildEveningAthkarView() {
    return ListView.builder(
      itemCount: controller.eveningAthkar.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final athkar = controller.eveningAthkar[index];
        return _buildAthkarCard(
          athkar['text'],
          athkar['count'],
          athkar['reward'],
        );
      },
    );
  }

  Widget _buildAthkarCard(String text, int count, String reward) {
    final RxInt currentCount = 0.obs; // عدد المرات التي ذُكر فيها الذكر

    return Obx(() {
      final isCompleted = currentCount.value >= count;
      return Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 8),
              Text(
                'عدد التكرار المطلوب: $count',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'الفضل: $reward',
                style: TextStyle(
                  color: Colors.teal,
                  fontStyle: FontStyle.italic,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 8),
              Text(
                'عدد التكرارات الحالية: ${currentCount.value}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isCompleted
                          ? null
                          : () {
                              currentCount.value++;
                              if (currentCount.value >= count) {
                                controller.markAthkarCompleted(text);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(
                        isCompleted ? 'تم الإكمال' : 'اضغط لزيادة العدد',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (!isCompleted)
                      ElevatedButton(
                        onPressed: () {
                          if (currentCount.value > 0) {
                            currentCount.value--;
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                        ),
                        child: Text(
                          'إنقاص العدد',
                          style: TextStyle(color: Colors.white),
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
