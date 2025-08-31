import 'package:quran_app/index.dart';


class QuranPlayerController extends GetxController {
  // Audio player instance
  late AudioPlayer audioPlayer;

  // Observable states
  var isPlaying = false.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Rx<Duration?>(null);
  var currentSurah = 0.obs;
  var currentSurahName = ''.obs; // Add this to store current surah name
  var currentReaderId = 'muhammadsiddiqalminshawimujawwad'.obs; // Default reader
  var currentQuality = '128'.obs; // Default quality
  var isMiniPlayerVisible = false.obs; // Track mini player visibility

  // Timer for updating position
  Timer? _positionTimer;

  // Readers list
  final List<QuranReader> availableReaders = [
    QuranReader(
        id: 'muhammadsiddiqalminshawimujawwad',
        name: 'محمد صديق المنشاوي',
        quality: '128'),
    QuranReader(id: 'alafasy', name: 'مشاري راشد العفاسي', quality: '128'),
    QuranReader(id: 'nasseralqatami', name: 'ناصر القطامي', quality: '128'),
    QuranReader(
        id: 'abdulazizazzahrani', name: 'عبدالعزيز الزهراني', quality: '128'),
    QuranReader(id: 'yasseraldossari', name: 'ياسر الدوسري', quality: '128'),
    QuranReader(
        id: 'abdulbasitmurattal',
        name: 'عبد الباسط عبد الصمد مرتل',
        quality: '128'),
    QuranReader(
        id: 'abdulbasitmujawwad',
        name: 'عبد الباسط عبد الصمد مجود',
        quality: '128'),
    QuranReader(id: 'ahmedalajmi', name: 'أحمد العجمي', quality: '128'),
  ];

  // Getter for current reader
  QuranReader? get currentReader {
    try {
      return availableReaders.firstWhere((reader) =>
          reader.id == currentReaderId.value &&
          reader.quality == currentQuality.value);
    } catch (e) {
      // If exact match not found, try to find with just ID
      try {
        return availableReaders
            .firstWhere((reader) => reader.id == currentReaderId.value);
      } catch (e) {
        // If nothing found, return first available reader
        return availableReaders.isNotEmpty ? availableReaders.first : null;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();

    // Set up listeners that are safe from setState after dispose errors
    _setupSafeListeners();

    // REMOVED THE LINE THAT CAUSES STACK OVERFLOW:
    // Get.put(this, permanent: true);
    // This was creating a recursive initialization loop
  }

  void _setupSafeListeners() {
    // Set up listeners with safety checks
    audioPlayer.playerStateStream.listen((state) {
      if (isClosed) return; // Skip if controller is already disposed

      isPlaying.value = state.playing;

      switch (state.processingState) {
        case ProcessingState.loading:
        case ProcessingState.buffering:
          isLoading.value = true;
          break;
        case ProcessingState.ready:
          isLoading.value = false;
          hasError.value = false;
          break;
        case ProcessingState.completed:
          isPlaying.value = false;
          seek(Duration.zero);
          break;
        case ProcessingState.idle:
          break;
      }
    }, onError: (e) {
      if (isClosed) return;
      _handlePlaybackError(e);
    });

    // Duration listener
    audioPlayer.durationStream.listen((d) {
      if (isClosed) return;
      totalDuration.value = d;
    }, onError: (e) {
      if (isClosed) return;
      _handlePlaybackError(e);
    });

    // Start position timer instead of using positions stream
    // This reduces the number of active streams
    _startPositionTimer();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (audioPlayer.playing && !isClosed) {
        try {
          currentPosition.value = audioPlayer.position;
        } catch (e) {
          // Ignore position errors
        }
      }
    });
  }

  // Check if network connection is available
  Future<bool> _checkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } on MissingPluginException {
      // Plugin not available, assume connection exists
      return true;
    } catch (e) {
      // On any error, assume connection exists
      return true;
    }
  }

  // Play a specific surah
  Future<void> playSurah(int surahNumber, {String? surahName}) async {
    try {
      // Reset states
      currentSurah.value = surahNumber;
      if (surahName != null) {
        currentSurahName.value = surahName;
      }
      isLoading.value = true;
      errorMessage.value = '';
      hasError.value = false;

      // Show mini player when playing a surah
      isMiniPlayerVisible.value = true;

      // Check network connection
      bool hasNetwork = await _checkConnection();
      if (!hasNetwork) {
        errorMessage.value = 'تحقق من اتصال الإنترنت';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      // Construct the URL based on reader and quality
      String audioUrl = 'https://cdn.islamic.network/quran/audio-surah/';
      if (currentReaderId.value.isNotEmpty) {
        audioUrl +=
            '${currentQuality}/ar.${currentReaderId.value}/${surahNumber}.mp3';
        print(audioUrl);
      } else {
        audioUrl += 'lafasy/${surahNumber}.mp3';
      }

      // Stop any current playback
      await audioPlayer.stop();

      // Set the audio source with proper error handling
      try {
        await audioPlayer.setUrl(audioUrl);
        await audioPlayer.play();
      } catch (e) {
        _handlePlaybackError(e);
        return;
      }
    } catch (e) {
      _handlePlaybackError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePlaybackError(dynamic error) {
    if (isClosed) return;

    hasError.value = true;
    isLoading.value = false;

    // Determine appropriate error message
    if (error.toString().contains('Connection refused') ||
        error.toString().contains('SocketException')) {
      errorMessage.value = 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
    } else if (error.toString().contains('404') ||
        error.toString().contains('Not Found')) {
      errorMessage.value = 'لم يتم العثور على الملف الصوتي.';
    } else {
      errorMessage.value = 'حدث خطأ أثناء تشغيل الصوت.';
    }

    print('خطأ أثناء تشغيل الصوت: ${error.toString()}');
  }

  // Toggle play/pause
  void togglePlayPause() async {
    try {
      if (audioPlayer.playing) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
    } catch (e) {
      _handlePlaybackError(e);
    }
  }

  // Seek to a specific position
  void seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
      currentPosition.value = position; // Update UI immediately
    } catch (e) {
      // Ignore seek errors as they're usually not critical
      print('خطأ أثناء تغيير موضع التشغيل: ${e.toString()}');
    }
  }

  // Stop playback
  void stopPlayer() async {
    try {
      await audioPlayer.stop();
      currentPosition.value = Duration.zero;
      currentSurah.value = 0; // Reset surah to hide mini player
      isMiniPlayerVisible.value = false;
    } catch (e) {
      print('خطأ أثناء إيقاف التشغيل: ${e.toString()}');
    }
  }

  // Retry playing after an error
  void retryPlaying() async {
    // Reset error state
    hasError.value = false;
    errorMessage.value = '';

    // Replay current surah
    if (currentSurah.value > 0) {
      await playSurah(currentSurah.value);
    }
  }

  // Change reader
  void changeReader(String readerId, String quality) async {
    if (currentReaderId.value == readerId && currentQuality.value == quality) {
      return; // No change needed
    }

    currentReaderId.value = readerId;
    currentQuality.value = quality;

    // If a surah is currently playing, restart it with the new reader
    if (currentSurah.value > 0) {
      await playSurah(currentSurah.value);
    }
  }

  @override
  void onClose() {
    // Clean up resources
    _positionTimer?.cancel();
    _positionTimer = null;

    try {
      audioPlayer.stop();
      audioPlayer.dispose();
    } catch (e) {
      print('خطأ أثناء إغلاق مشغل الصوت: ${e.toString()}');
    }

    super.onClose();
  }
}
