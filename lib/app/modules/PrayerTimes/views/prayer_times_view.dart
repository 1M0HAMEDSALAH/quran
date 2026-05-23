import 'package:quran_app/index.dart';
import 'package:quran_app/app/modules/PrayerTimes/controllers/prayer_times_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class PrayerTimesView extends StatelessWidget {
  PrayerTimesView({super.key});

  final PrayerTimesController controller = Get.put(PrayerTimesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3E33),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'مواقيت الصلاة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFCDA047),
            fontFamily: "Amiri",
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/islamic_pattern.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.currentDayData.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDA047)),
              ),
            );
          }

          if (controller.currentDayData.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "لا توجد بيانات متاحة",
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontFamily: "Amiri"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchPrayerTimes(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCDA047)),
                    child: const Text("تحديث",
                        style: TextStyle(color: Color(0xFF0F3E33))),
                  ),
                ],
              ),
            );
          }

          final data = controller.currentDayData.value!;
          return RefreshIndicator(
            onRefresh: () => controller.fetchPrayerTimes(),
            color: const Color(0xFFCDA047),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeader(data),
                  const SizedBox(height: 24),
                  _buildPrayerList(data),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6C58), Color(0xFF0F3E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFCDA047).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            data.date.hijri.weekday.ar,
            style: const TextStyle(
              color: Color(0xFFCDA047),
              fontSize: 22,
              fontFamily: "Amiri",
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${data.date.hijri.day} ${data.date.hijri.month.ar} ${data.date.hijri.year}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontFamily: "Amiri",
            ),
          ),
          const Divider(color: Color(0xFFCDA047), height: 32, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Color(0xFFCDA047), size: 18),
              const SizedBox(width: 8),
              Text(
                data.meta.timezone,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNextPrayer(
              controller.nextPrayerName.value, controller.nextPrayerTime.value),
        ],
      ),
    );
  }

  Widget _buildNextPrayer(String name, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFCDA047).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCDA047).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "الصلاة القادمة",
                style: TextStyle(
                    color: Colors.white70, fontSize: 12, fontFamily: "Amiri"),
              ),
              Text(
                _translatePrayer(name),
                style: const TextStyle(
                  color: Color(0xFFCDA047),
                  fontSize: 20,
                  fontFamily: "Amiri",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(data) {
    final timings = data.timings;
    final List<Map<String, String>> prayerList = [
      {"name": "Fajr", "time": timings.fajr},
      {"name": "Sunrise", "time": timings.sunrise},
      {"name": "Dhuhr", "time": timings.dhuhr},
      {"name": "Asr", "time": timings.asr},
      {"name": "Maghrib", "time": timings.maghrib},
      {"name": "Isha", "time": timings.isha},
    ];

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: prayerList.length,
        itemBuilder: (context, index) {
          final prayer = prayerList[index];
          final bool isNext = prayer['name'] == controller.nextPrayerName.value;

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child:
                    _buildPrayerCard(prayer['name']!, prayer['time']!, isNext),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerCard(String name, String time, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext
            ? const Color(0xFFCDA047).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isNext ? const Color(0xFFCDA047) : Colors.white.withOpacity(0.1),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getPrayerIcon(name),
                color: isNext ? const Color(0xFFCDA047) : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                _translatePrayer(name),
                style: TextStyle(
                  color: isNext ? const Color(0xFFCDA047) : Colors.white,
                  fontSize: 18,
                  fontFamily: "Amiri",
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            time.split(" ")[0],
            style: TextStyle(
              color: isNext ? const Color(0xFFCDA047) : Colors.white,
              fontSize: 18,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _translatePrayer(String name) {
    switch (name) {
      case "Fajr":
        return "الفجر";
      case "Sunrise":
        return "الشروق";
      case "Dhuhr":
        return "الظهر";
      case "Asr":
        return "العصر";
      case "Maghrib":
        return "المغرب";
      case "Isha":
        return "العشاء";
      default:
        return name;
    }
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case "Fajr":
        return Icons.wb_twilight;
      case "Sunrise":
        return Icons.wb_sunny_outlined;
      case "Dhuhr":
        return Icons.wb_sunny;
      case "Asr":
        return Icons.wb_cloudy_outlined;
      case "Maghrib":
        return Icons.nightlight_round;
      case "Isha":
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
