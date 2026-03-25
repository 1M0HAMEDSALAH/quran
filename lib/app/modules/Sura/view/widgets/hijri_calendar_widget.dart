import 'package:quran_app/index.dart';

class HijriCalendarWidget extends StatelessWidget {
  final HijriCalendar _hijriDate = HijriCalendar.now();

  late final String _fullHijriDate;
  late final String _gregorianDate;

  HijriCalendarWidget({Key? key}) : super(key: key) {
    _fullHijriDate = _computeFullHijriDate();
    _gregorianDate = _computeGregorianDate();
  }

  static const Color _cardDark = Color(0xFF1E6E60);
  static const Color _cardLight = Color(0xFF2A9D8A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_cardDark, _cardLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardLight.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── "TODAY'S REFLECTION" label ──
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white70,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                "TODAY'S REFLECTION",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Large Hijri date ──
          Text(
            _fullHijriDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // ── Gregorian date ──
          Text(
            _gregorianDate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),

          // ── Bottom row: avatar stack + Resume Reading ──
          Row(
            children: [
              _buildAvatarStack(),
              const Spacer(),
              _buildResumeButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 64,
      height: 34,
      child: Stack(
        children: [
          _avatarCircle('A'),
          Positioned(left: 26, child: _avatarCircle('Ω')),
        ],
      ),
    );
  }

  Widget _avatarCircle(String label) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.25),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResumeButton() {
    return GestureDetector(
      onTap: () {
        // TODO: navigate to last read position
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Resume Reading',
          style: TextStyle(
            color: _cardDark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Date helpers ──

  String _computeFullHijriDate() {
    final gregorianDate = _hijriDate.hijriToGregorian(
      _hijriDate.hYear,
      _hijriDate.hMonth,
      _hijriDate.hDay,
    );
    final dayName = _getEnglishDayName(gregorianDate.weekday);
    final monthName = _getEnglishHijriMonthName(_hijriDate.hMonth);
    return '$dayName ${_hijriDate.hDay} $monthName ${_hijriDate.hYear}';
  }

  String _computeGregorianDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _getEnglishDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getEnglishHijriMonthName(int month) {
    const months = [
      'Muharram',
      'Safar',
      "Rabi' al-Awwal",
      "Rabi' al-Thani",
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhu al-Qi'dah",
      'Dhu al-Hijjah',
    ];
    return months[month - 1];
  }
}

// ── Controller (unchanged logic, kept for completeness) ──

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
