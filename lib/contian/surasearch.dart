import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart';



class SurahSearchDelegate extends SearchDelegate<int> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
         Icons.arrow_back
      ),
      onPressed: () {
        Get.back();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final List<int> surahs = [];
    for (int i = 1; i <= 114; i++) {
      final String arabicName = getSurahNameArabic(i);
      final String englishName = getSurahName(i);
      if (arabicName.contains(query) || englishName.contains(query)) {
        surahs.add(i);
      }
    }

    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final int surahNumber = surahs[index];
        return ListTile(
          title: Text(
            getSurahNameArabic(surahNumber),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(getSurahName(surahNumber)),
          onTap: () {
            close(context, surahNumber);
          },
        );
      },
    );
  }
}