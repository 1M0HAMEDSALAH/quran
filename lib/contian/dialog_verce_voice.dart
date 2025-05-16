import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerDialog extends StatefulWidget {
  final int verseNumber;
  final int surahNumber;
  final String verseText;

  const AudioPlayerDialog({
    Key? key,
    required this.verseNumber,
    required this.surahNumber,
    required this.verseText,
  }) : super(key: key);

  @override
  State<AudioPlayerDialog> createState() => _AudioPlayerDialogState();
}

class _AudioPlayerDialogState extends State<AudioPlayerDialog> {
  late AudioPlayer _player;
  bool isPlaying = false;

  final List<int> ayahsPerSurah = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    int globalAyah =
        getGlobalAyahNumber(widget.surahNumber, widget.verseNumber);
    final url =
        'https://cdn.islamic.network/quran/audio/192/ar.abdulbasitmurattal/$globalAyah.mp3';

    try {
      await _player.setUrl(url);
      await _player.play();
      setState(() => isPlaying = true);

      // لما يخلص الصوت، يقفل الديالوج تلقائيًا
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          Navigator.of(context).maybePop(); // إغلاق الديالوج
        }
      });
    } catch (e) {
      print('خطأ أثناء تشغيل الصوت: $e');
    }
  }

  int getGlobalAyahNumber(int surahNumber, int verseNumber) {
    int offset = 0;
    for (int i = 0; i < surahNumber - 1; i++) {
      offset += ayahsPerSurah[i];
    }
    return offset + verseNumber;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الآية ${widget.verseNumber} من السورة ${widget.surahNumber}',
              // style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.verseText,
              // style: const TextStyle(
              //   color: Colors.greenAccent,
              //   fontSize: 24,
              //   fontWeight: FontWeight.bold,
              //   height: 1.8,
              // ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
