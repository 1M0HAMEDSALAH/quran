// reading_position_service.dart
// Handles saving and restoring the last Quran reading position.
// Uses SharedPreferences for lightweight, persistent local storage.

import 'package:shared_preferences/shared_preferences.dart';

class ReadingPositionService {
  static const String _keySurahNumber = 'last_surah_number';
  static const String _keyVerseNumber = 'last_verse_number';
  static const String _keyPageNumber  = 'last_page_number';

  /// Save the current reading position.
  static Future<void> savePosition({
    required int surahNumber,
    required int verseNumber,
    required int pageNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurahNumber, surahNumber);
    await prefs.setInt(_keyVerseNumber, verseNumber);
    await prefs.setInt(_keyPageNumber,  pageNumber);
  }

  /// Load the last saved reading position.
  /// Returns null if no position has been saved yet.
  static Future<ReadingPosition?> loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_keySurahNumber);
    final verse = prefs.getInt(_keyVerseNumber);
    final page  = prefs.getInt(_keyPageNumber);

    if (surah == null || verse == null || page == null) return null;
    return ReadingPosition(
      surahNumber: surah,
      verseNumber: verse,
      pageNumber:  page,
    );
  }

  /// Clear the saved position (optional utility).
  static Future<void> clearPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySurahNumber);
    await prefs.remove(_keyVerseNumber);
    await prefs.remove(_keyPageNumber);
  }
}

/// Simple value object representing a reading position.
class ReadingPosition {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;

  const ReadingPosition({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
  });

  @override
  String toString() =>
      'ReadingPosition(surah: $surahNumber, verse: $verseNumber, page: $pageNumber)';
}