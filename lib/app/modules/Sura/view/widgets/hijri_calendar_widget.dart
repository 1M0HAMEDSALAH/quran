import 'package:quran_app/index.dart';

class HijriCalendarWidget extends StatelessWidget {
  // ✅ Computed once at construction, not on every build
  final HijriCalendar _hijriDate = HijriCalendar.now();

  // ✅ Cache all string values at construction time
  late final String _fullHijriDate;
  late final String _gregorianDate;
  late final String _dayNumber;

  HijriCalendarWidget({Key? key}) : super(key: key) {
    _fullHijriDate = _computeFullHijriDate();
    _gregorianDate = _computeGregorianDate();
    _dayNumber = _hijriDate.hDay.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor.withOpacity(0.9),
            AppColor.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/islamic_pattern.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullHijriDate,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "BahijTheSansArabic",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gregorianDate,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: "BahijTheSansArabic",
                      ),
                    ),
                  ],
                ),
              ),
              _buildHijriDayDisplay(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHijriDayDisplay() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          _dayNumber,
          style: Get.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: "BahijTheSansArabic",
          ),
        ),
      ),
    );
  }

  String _computeFullHijriDate() {
    return '${_getHijriDayName()} ${_hijriDate.hDay} ${_getHijriMonthName()} ${_hijriDate.hYear}';
  }

  String _computeGregorianDate() {
    final now = DateTime.now();
    return '${_getGregorianDayName(now.weekday)} ${now.day}/${now.month}/${now.year}';
  }

  String _getHijriDayName() {
    final gregorianDate = _hijriDate.hijriToGregorian(
      _hijriDate.hYear,
      _hijriDate.hMonth,
      _hijriDate.hDay,
    );
    const weekDays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    return weekDays[gregorianDate.weekday - 1];
  }

  String _getHijriMonthName() {
    const months = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
    ];
    return months[_hijriDate.hMonth - 1];
  }

  String _getGregorianDayName(int weekday) {
    const weekDays = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    return weekDays[weekday - 1];
  }
}

class HijriCalendarController extends GetxController {
  final Rx<HijriCalendar> currentHijriDate = HijriCalendar.now().obs;

  @override
  void onInit() {
    super.onInit();
    HijriCalendar.setLocal('ar');
  }

  void refreshDate() {
    currentHijriDate.value = HijriCalendar.now();
    update();
  }
}