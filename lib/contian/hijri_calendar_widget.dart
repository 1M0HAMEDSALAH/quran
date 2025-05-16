// Step 1: Add the hijri package to your pubspec.yaml
// dependencies:
//   hijri: ^3.0.0

// hijri_calendar_widget.dart
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:get/get.dart';
import '../const/app_theme.dart';

class HijriCalendarWidget extends StatelessWidget {
  final HijriCalendar _hijriDate = HijriCalendar.now();

  HijriCalendarWidget({Key? key}) : super(key: key);

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
          // Background pattern
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
                      _getFullHijriDate(),
                      style: Get.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "BahijTheSansArabic"),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getGregorianDate(),
                      style: Get.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: "BahijTheSansArabic"),
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
          _hijriDate.hDay.toString(),
          style: Get.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: "BahijTheSansArabic"),
        ),
      ),
    );
  }

  String _getFullHijriDate() {
    return '${_getHijriDayName()} ${_hijriDate.hDay} ${_getHijriMonthName()} ${_hijriDate.hYear}';
  }

  String _getGregorianDate() {
    DateTime now = DateTime.now();
    return '${_getGregorianDayName(now.weekday)} ${now.day}/${now.month}/${now.year}';
  }

  String _getHijriDayName() {
    // Convert Hijri date to Gregorian to get the weekday
    DateTime gregorianDate = _hijriDate.hijriToGregorian(
        _hijriDate.hYear, _hijriDate.hMonth, _hijriDate.hDay);
    int weekday = gregorianDate.weekday; // 1 = Monday, 7 = Sunday

    List<String> weekDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return weekDays[weekday - 1];
  }

  String _getHijriMonthName() {
    List<String> months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة'
    ];
    return months[_hijriDate.hMonth - 1];
  }

  String _getGregorianDayName(int weekday) {
    List<String> weekDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return weekDays[weekday - 1];
  }
}

class HijriCalendarController extends GetxController {
  // Observable for Hijri date
  final Rx<HijriCalendar> currentHijriDate = HijriCalendar.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Set Arabic locale for Hijri dates
    HijriCalendar.setLocal('ar');
  }

  // Method to refresh the date (can be called periodically if needed)
  void refreshDate() {
    currentHijriDate.value = HijriCalendar.now();
    update();
  }
}
