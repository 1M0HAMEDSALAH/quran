import 'package:quran_app/index.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran_app/app/modules/PrayerTimes/models/prayer_times_model.dart';
import 'package:quran_app/utils/const/api_endpoint.dart';

class PrayerTimesController extends GetxController {
  final GetStorage _storage = GetStorage();
  final GetConnect _connect = GetConnect();

  var isLoading = false.obs;
  var prayerData = <PrayerData>[].obs;
  var currentDayData = Rxn<PrayerData>();
  var nextPrayerName = "".obs;
  var nextPrayerTime = "".obs;

  final String _storageKey = "prayer_times_list";
  final String _lastUpdateKey = "last_prayer_times_update";

  @override
  void onInit() {
    super.onInit();
    loadCachedData();
    checkAndUpdateIfNeeded();
  }

  Future<void> loadCachedData() async {
    // make it async
    var cached = _storage.read(_storageKey);
    if (cached != null) {
      prayerData.value =
          (cached as List).map((e) => PrayerData.fromJson(e)).toList();
      _updateCurrentDayData();

      // Request permissions first, then schedule
      final granted = await NotificationService().requestPermissions();
      if (granted) {
        NotificationService().schedulePrayerNotifications(prayerData);
      }
    }
  }

  Future<void> checkAndUpdateIfNeeded() async {
    DateTime now = DateTime.now();
    String? lastUpdateStr = _storage.read(_lastUpdateKey);

    bool needsUpdate = false;

    if (lastUpdateStr == null || prayerData.isEmpty) {
      needsUpdate = true;
    } else {
      DateTime lastUpdate = DateTime.parse(lastUpdateStr);
      if (now.difference(lastUpdate).inDays >= 10) {
        needsUpdate = true;
      }

      // Also check if we have data for the current month
      if (prayerData.isNotEmpty) {
        int storedMonth = prayerData.first.date.gregorian.month.number;
        if (storedMonth != now.month) {
          needsUpdate = true;
        }
      }
    }

    if (needsUpdate) {
      await fetchPrayerTimes();
    }
  }

  Future<void> fetchPrayerTimes() async {
    try {
      isLoading.value = true;

      // 1. Get Location
      Position position = await _determinePosition();

      // 2. Fetch from API (Monthly Calendar)
      DateTime now = DateTime.now();
      String url = ApiEndpoint.baseUrl +
          ApiEndpoint.getCalendar(
              now.year, now.month, position.latitude, position.longitude);

      var response = await _connect.get(url);

      if (response.statusCode == 200) {
        var prayerResponse = PrayerTimesResponse.fromJson(response.body);
        prayerData.value = prayerResponse.data;

        // 3. Cache
        _storage.write(
            _storageKey, prayerResponse.data.map((e) => e.toJson()).toList());
        _storage.write(_lastUpdateKey, DateTime.now().toIso8601String());

        _updateCurrentDayData();
        NotificationService().schedulePrayerNotifications(prayerData);
      } else {
        Get.snackbar(
            "Error", "Failed to fetch prayer times: ${response.statusText}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCurrentDayData() {
    if (prayerData.isEmpty) return;

    DateTime now = DateTime.now();
    String todayStr =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    try {
      currentDayData.value = prayerData.firstWhere(
        (element) => element.date.gregorian.date == todayStr,
      );
      _calculateNextPrayer();
    } catch (e) {
      // If not found in current month (e.g. at the end of month), maybe we need next month's data
      print("Today's data not found in cached month.");
    }
  }

  void _calculateNextPrayer() {
    if (currentDayData.value == null) return;

    final timings = currentDayData.value!.timings;
    final now = DateTime.now();

    Map<String, String> prayerTimes = {
      "Fajr": timings.fajr,
      "Sunrise": timings.sunrise,
      "Dhuhr": timings.dhuhr,
      "Asr": timings.asr,
      "Maghrib": timings.maghrib,
      "Isha": timings.isha,
    };

    String? nextName;
    DateTime? nextTime;

    for (var entry in prayerTimes.entries) {
      final timeParts = entry.value.split(" ")[0].split(":");
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      if (prayerDateTime.isAfter(now)) {
        nextName = entry.key;
        nextTime = prayerDateTime;
        break;
      }
    }

    if (nextName == null) {
      // Tomorrow's Fajr
      nextName = "Fajr";
      nextTime = DateTime(now.year, now.month, now.day + 1); // Simplification
    }

    nextPrayerName.value = nextName;
    nextPrayerTime.value = prayerTimes[nextName] ?? "";
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
