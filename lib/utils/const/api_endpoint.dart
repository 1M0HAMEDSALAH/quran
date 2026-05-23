class ApiEndpoint {
  static const String baseUrl = "https://api.aladhan.com/v1";

  static const String timings = "/timings";

  static const String calendar = "/calendar";

  static String getTimings(String date, double latitude, double longitude) {
    return "$timings/$date?latitude=$latitude&longitude=$longitude";
  }

  static String getCalendar(int year, int month, double latitude, double longitude, {int method = 3}) {
    return "$calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method";
  }
}