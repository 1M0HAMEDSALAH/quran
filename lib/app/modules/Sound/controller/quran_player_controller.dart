import 'dart:io';

import 'package:quran_app/index.dart';


class QuranPlayerController extends GetxController {
  late AudioPlayer audioPlayer;
  
  // Observable states
  var isPlaying = false.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Rx<Duration?>(null);
  var currentSurah = 0.obs;
  var currentSurahName = ''.obs;
  var currentReaderId = 'abdulbasitmurattal'.obs;
  var currentQuality = '128'.obs;
  var isMiniPlayerVisible = false.obs;

  Timer? _positionTimer;

  final List<QuranReader> availableReaders = [
    QuranReader(id: 'muhammadsiddiqalminshawimujawwad', name: 'محمد صديق المنشاوي', quality: '128'),
    QuranReader(id: 'alafasy', name: 'مشاري راشد العفاسي', quality: '128'),
    QuranReader(id: 'nasseralqatami', name: 'ناصر القطامي', quality: '128'),
    QuranReader(id: 'abdulazizazzahrani', name: 'عبدالعزيز الزهراني', quality: '128'),
    QuranReader(id: 'yasseraldossari', name: 'ياسر الدوسري', quality: '128'),
    QuranReader(id: 'abdulbasitmurattal', name: 'عبد الباسط عبد الصمد مرتل', quality: '128'),
    QuranReader(id: 'abdulbasitmujawwad', name: 'عبد الباسط عبد الصمد مجود', quality: '128'),
    QuranReader(id: 'ahmedalajmi', name: 'أحمد العجمي', quality: '128'),
  ];

  QuranReader? get currentReader {
    try {
      return availableReaders.firstWhere((reader) =>
          reader.id == currentReaderId.value &&
          reader.quality == currentQuality.value);
    } catch (e) {
      try {
        return availableReaders.firstWhere((reader) => reader.id == currentReaderId.value);
      } catch (e) {
        return availableReaders.isNotEmpty ? availableReaders.first : null;
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    try {
      audioPlayer = AudioPlayer();
      _setupSafeListeners();
    } catch (e) {
      print('Error initializing audio player: $e');
      hasError.value = true;
      errorMessage.value = 'خطأ في تهيئة مشغل الصوت';
    }
  }

  void _setupSafeListeners() {
    audioPlayer.playerStateStream.listen((state) {
      if (isClosed) return;

      isPlaying.value = state.playing;

      switch (state.processingState) {
        case ProcessingState.loading:
        case ProcessingState.buffering:
          isLoading.value = true;
          hasError.value = false;
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

    audioPlayer.durationStream.listen((d) {
      if (isClosed) return;
      totalDuration.value = d;
    }, onError: (e) {
      if (isClosed) return;
      _handlePlaybackError(e);
    });

    _startPositionTimer();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (audioPlayer.playing && !isClosed) {
        try {
          currentPosition.value = audioPlayer.position;
        } catch (e) {
          // Ignore position errors in release builds
        }
      }
    });
  }

  Future<bool> _checkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Additional check: Try to resolve the domain
      try {
        final result = await InternetAddress.lookup('cdn.islamic.network');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        print('DNS lookup failed: $e');
        return false;
      }
    } on MissingPluginException {
      return true;
    } catch (e) {
      print('Connection check error: $e');
      return false;
    }
  }

  Future<void> playSurah(int surahNumber, {String? surahName}) async {
    try {
      currentSurah.value = surahNumber;
      if (surahName != null) {
        currentSurahName.value = surahName;
      }
      isLoading.value = true;
      errorMessage.value = '';
      hasError.value = false;

      isMiniPlayerVisible.value = true;

      // Enhanced network check
      bool hasNetwork = await _checkConnection();
      if (!hasNetwork) {
        errorMessage.value = 'لا يوجد اتصال بالإنترنت. تأكد من الاتصال وحاول مرة أخرى.';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      // Use HTTPS URL for better security
      String audioUrl = 'https://cdn.islamic.network/quran/audio-surah/${currentQuality.value}/ar.${currentReaderId.value}/$surahNumber.mp3';
      print('Playing audio from: $audioUrl');

      await audioPlayer.stop();

      // Set audio source with timeout and better error handling
      try {
        await audioPlayer.setUrl(audioUrl).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Audio loading timeout', const Duration(seconds: 30));
          },
        );
        await audioPlayer.play();
      } catch (e) {
        print('Audio loading error: $e');
        _handlePlaybackError(e);
        return;
      }
    } catch (e) {
      print('Play surah error: $e');
      _handlePlaybackError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePlaybackError(dynamic error) {
    if (isClosed) return;

    hasError.value = true;
    isLoading.value = false;

    String errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout') || errorStr.contains('timeoutexception')) {
      errorMessage.value = 'انتهت مهلة التحميل. تحقق من اتصال الإنترنت وحاول مرة أخرى.';
    } else if (errorStr.contains('connection refused') || 
               errorStr.contains('socketexception') ||
               errorStr.contains('network')) {
      errorMessage.value = 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
    } else if (errorStr.contains('404') || errorStr.contains('not found')) {
      errorMessage.value = 'لم يتم العثور على الملف الصوتي. جرب قارئ آخر.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      errorMessage.value = 'غير مسموح بالوصول للملف الصوتي.';
    } else if (errorStr.contains('500') || errorStr.contains('server')) {
      errorMessage.value = 'خطأ في الخادم. حاول مرة أخرى لاحقاً.';
    } else {
      errorMessage.value = 'حدث خطأ أثناء تشغيل الصوت. حاول مرة أخرى.';
    }

    print('Audio error: $error');
  }

  void togglePlayPause() async {
    if (hasError.value) {
      await retryPlaying();
      return;
    }

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

  void seek(Duration position) async {
    try {
      await audioPlayer.seek(position);
      currentPosition.value = position;
    } catch (e) {
      print('Seek error: $e');
    }
  }

  void stopPlayer() async {
    try {
      await audioPlayer.stop();
      currentPosition.value = Duration.zero;
      currentSurah.value = 0;
      isMiniPlayerVisible.value = false;
      hasError.value = false;
      errorMessage.value = '';
    } catch (e) {
      print('Stop player error: $e');
    }
  }

  Future<void> retryPlaying() async {
    hasError.value = false;
    errorMessage.value = '';

    if (currentSurah.value > 0) {
      await playSurah(currentSurah.value, surahName: currentSurahName.value);
    }
  }

  void changeReader(String readerId, String quality) async {
    if (currentReaderId.value == readerId && currentQuality.value == quality) {
      return;
    }

    currentReaderId.value = readerId;
    currentQuality.value = quality;

    if (currentSurah.value > 0) {
      await playSurah(currentSurah.value, surahName: currentSurahName.value);
    }
  }

  @override
  void onClose() {
    _positionTimer?.cancel();
    _positionTimer = null;

    try {
      audioPlayer.stop();
      audioPlayer.dispose();
    } catch (e) {
      print('Audio player dispose error: $e');
    }

    super.onClose();
  }
}