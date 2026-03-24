import 'package:quran_app/index.dart';

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
  late final AudioPlayer _player;
  bool _isLoading = true;
  bool _hasError = false;

  // ✅ Precomputed cumulative offsets (no loop on every call)
  static const List<int> _ayahOffsets = [
    0, 7, 293, 493, 669, 789, 954, 1160, 1235, 1364, 1473,
    1596, 1707, 1750, 1802, 1901, 2029, 2140, 2250, 2348, 2483,
    2595, 2673, 2791, 2855, 2932, 3159, 3252, 3340, 3409, 3469,
    3503, 3533, 3606, 3660, 3705, 3788, 3970, 4058, 4133, 4218,
    4272, 4325, 4414, 4473, 4510, 4545, 4583, 4612, 4630, 4675,
    4735, 4784, 4846, 4901, 4979, 5075, 5104, 5126, 5150, 5163,
    5177, 5188, 5199, 5217, 5229, 5241, 5271, 5323, 5375, 5419,
    5447, 5475, 5495, 5551, 5591, 5622, 5672, 5712, 5758, 5800,
    5829, 5848, 5884, 5909, 5931, 5948, 5967, 5993, 6023, 6043,
    6058, 6079, 6090, 6098, 6106, 6125, 6130, 6138, 6146, 6157,
    6168, 6176, 6179, 6188, 6193, 6197, 6204, 6207, 6213, 6216,
    6221, 6225, 6230, 6236,
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // ✅ Init audio after first frame so dialog renders immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePlayer());
  }

  Future<void> _initializePlayer() async {
    final globalAyah = _getGlobalAyahNumber(widget.surahNumber, widget.verseNumber);
    final url =
        'https://cdn.islamic.network/quran/audio/192/ar.abdulbasitmurattal/$globalAyah.mp3';

    try {
      await _player.setUrl(url);
      if (!mounted) return;
      setState(() => _isLoading = false);
      await _player.play();

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) {
          Navigator.of(context).maybePop();
        }
      });
    } catch (e) {
      debugPrint('خطأ أثناء تشغيل الصوت: $e');
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  int _getGlobalAyahNumber(int surahNumber, int verseNumber) {
    // ✅ O(1) lookup with precomputed offsets
    if (surahNumber < 1 || surahNumber > _ayahOffsets.length) return verseNumber;
    return _ayahOffsets[surahNumber - 1] + verseNumber;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الآية ${widget.verseNumber} من السورة ${widget.surahNumber}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.verseText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.primaryColor,
                ),
              )
            else if (_hasError)
              const Text(
                'تعذّر تشغيل الصوت',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}