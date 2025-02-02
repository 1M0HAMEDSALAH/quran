// import 'package:flutter/material.dart';
// import 'package:quran/quran.dart';
// import 'package:audioplayers/audioplayers.dart';

// class SurahDetailScreen extends StatelessWidget {
//   final int surahNumber;

//   SurahDetailScreen({required this.surahNumber});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal[300],
//       appBar: AppBar(
//         title: Text(
//           getSurahName(surahNumber),
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.teal[300],
//         elevation: 0,
//         shadowColor: Colors.teal.withOpacity(0.5),
//       ),
//       body: Container(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 if (surahNumber != 9)
//                   Text(
//                     "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 28,
//                       color: Colors.white,
//                       shadows: [
//                         Shadow(
//                           blurRadius: 5,
//                           color: Colors.black.withOpacity(0.3),
//                           offset: Offset(2, 2),
//                         ),
//                       ],
//                     ),
//                   ),
//                 SizedBox(height: 20),
//                 ..._buildVerses(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildVerses() {
//     List<Widget> verses = [];
//     int verseCount = getVerseCount(surahNumber);

//     for (int i = 1; i <= verseCount; i++) {
//       verses.add(
//         VerseTile(
//           verseNumber: i,
//           surahNumber: surahNumber,
//           verseText: getVerse(surahNumber, i, verseEndSymbol: true),
//         ),
//       );
//     }

//     return verses;
//   }
// }

// class VerseTile extends StatefulWidget {
//   final int verseNumber;
//   final int surahNumber;
//   final String verseText;

//   VerseTile({
//     required this.verseNumber,
//     required this.surahNumber,
//     required this.verseText,
//   });

//   @override
//   _VerseTileState createState() => _VerseTileState();
// }

// class _VerseTileState extends State<VerseTile> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;

//   Future<void> _playVerse() async {
//     if (_isPlaying) {
//       await _audioPlayer.stop();
//       setState(() {
//         _isPlaying = false;
//       });
//     } else {
//       String audioUrl =
//           "https://server12.mp3quran.net/afs/${widget.surahNumber.toString().padLeft(3, '0')}/${widget.verseNumber.toString().padLeft(3, '0')}.mp3";
//       await _audioPlayer.play(UrlSource(audioUrl));
//       setState(() {
//         _isPlaying = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _playVerse,
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16),
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.teal[400]!.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _isPlaying ? Icons.pause : Icons.play_arrow,
//               color: Colors.white,
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: RichText(
//                 textAlign: TextAlign.right,
//                 text: TextSpan(
//                   style: TextStyle(
//                     fontSize: 22,
//                     height: 2.5,
//                     color: Colors.white,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: widget.verseText + ' ',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     WidgetSpan(
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.teal[800]!.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           '${widget.verseNumber}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:quran/quran.dart';

class SurahDetailScreen extends StatelessWidget {
  final int surahNumber;

  SurahDetailScreen({required this.surahNumber});

  // تفسيرات الآيات (يمكن استبدالها ببيانات من ملف JSON)
  final Map<String, String> _tafsirData = {
    "1_1": "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ: البدء بذكر الله واستمداد البركة منه.",
    "1_2": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ: الثناء على الله بصفاته الكاملة.",
    "2_1": "الم: حروف مقطعة، الله أعلم بمرادها.",
    "2_2": "ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ: هذا القرآن لا شك فيه، وهو هدى للمتقين.",
    // أضف المزيد من التفسيرات هنا
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[300],
      appBar: AppBar(
        title: Text(
          getSurahName(surahNumber),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[300],
        elevation: 0,
        shadowColor: Colors.teal.withOpacity(0.5),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (surahNumber != 9)
                  Text(
                    "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                ..._buildVerses(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVerses(BuildContext context) {
    List<Widget> verses = [];
    int verseCount = getVerseCount(surahNumber);

    for (int i = 1; i <= verseCount; i++) {
      verses.add(
        VerseTile(
          verseNumber: i,
          surahNumber: surahNumber,
          verseText: getVerse(surahNumber, i, verseEndSymbol: true),
          tafsir: _tafsirData["${surahNumber}_$i"] ?? "لا يوجد تفسير متاح",
          onTap: () {
            _showTafsirDialog(context, surahNumber, i);
          },
        ),
      );
    }

    return verses;
  }

  void _showTafsirDialog(BuildContext context, int surahNumber, int verseNumber) {
    String tafsir = _tafsirData["${surahNumber}_$verseNumber"] ?? "لا يوجد تفسير متاح";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "تفسير الآية $verseNumber من سورة ${getSurahName(surahNumber)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              tafsir,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "إغلاق",
                style: TextStyle(
                  color: Colors.teal[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class VerseTile extends StatelessWidget {
  final int verseNumber;
  final int surahNumber;
  final String verseText;
  final String tafsir;
  final VoidCallback onTap;

  VerseTile({
    required this.verseNumber,
    required this.surahNumber,
    required this.verseText,
    required this.tafsir,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal[400]!.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    height: 2.5,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: verseText + ' ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal[800]!.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$verseNumber',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}