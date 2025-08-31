import 'package:quran_app/index.dart';


class BookmarkController extends GetxController {
  final storage = GetStorage();
  final bookmarks = <Map<String, dynamic>>[].obs;

  @override
  void onReady() {
    super.onReady();
    loadBookmarks(); // تحميل البيانات عند فتح الشاشة
  }

  void loadBookmarks() {
    final savedBookmarks = storage.read<List>('bookmarks') ?? [];
    bookmarks.assignAll(
        savedBookmarks.map((item) => Map<String, dynamic>.from(item)));
  }

  void toggleBookmark(Map<String, dynamic> verse) {
    final exists = bookmarks.any((bookmark) =>
        bookmark['surahNumber'] == verse['surahNumber'] &&
        bookmark['verseNumber'] == verse['verseNumber']);

    if (exists) {
      bookmarks.removeWhere((bookmark) =>
          bookmark['surahNumber'] == verse['surahNumber'] &&
          bookmark['verseNumber'] == verse['verseNumber']);
      Get.snackbar(
        'تم الحذف',
        'تم حذف الآية من المفضلة',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      bookmarks.add({
        ...verse,
        'date': DateTime.now().toString().split(' ')[0],
      });
      Get.snackbar(
        'تمت الإضافة',
        'تم إضافة الآية إلى المفضلة',
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }

    storage.write('bookmarks', bookmarks.toList());
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return bookmarks.any((bookmark) =>
        bookmark['surahNumber'] == surahNumber.toString() &&
        bookmark['verseNumber'] == verseNumber.toString());
  }
}
