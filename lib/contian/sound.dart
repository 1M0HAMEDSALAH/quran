import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Model for Quran Reader
class QuranReader {
  final String id;
  final String name;
  final String quality;

  QuranReader({
    required this.id,
    required this.name,
    required this.quality,
  });
}

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
  var currentReaderId = 'alafasy'.obs; // Default reader
  var currentQuality = '128'.obs; // Default quality

  // Timer for updating position
  Timer? _positionTimer;

  // Readers list
  final List<QuranReader> availableReaders = [
    QuranReader(id: 'alafasy', name: 'مشاري راشد العفاسي', quality: '128'),
    QuranReader(
        id: 'abdulbasitmurattal', name: 'عبد الباسط عبد الصمد', quality: '192'),
    QuranReader(id: 'mahermuaiqly', name: 'ماهر المعيقلي', quality: '128'),
    // Additional readers for 128kbps
    QuranReader(id: 'alafasy', name: 'مشاري راشد العفاسي', quality: '192'),
    QuranReader(
        id: 'abdulbasitmurattal', name: 'عبد الباسط عبد الصمد', quality: '192'),
    // 192kbps readers
    QuranReader(id: 'alafasy', name: 'مشاري راشد العفاسي', quality: '64'),
    QuranReader(
        id: 'abdulbasitmurattal-2',
        name: 'عبد الباسط عبد الصمد',
        quality: '64'),
    // 64kbps readers
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
  Future<void> playSurah(int surahNumber) async {
    try {
      // Reset states
      currentSurah.value = surahNumber;
      isLoading.value = true;
      errorMessage.value = '';
      hasError.value = false;

      // Check network connection
      bool hasNetwork = await _checkConnection();
      if (!hasNetwork) {
        errorMessage.value = 'تحقق من اتصال الإنترنت';
        hasError.value = true;
        isLoading.value = false;
        return;
      }

      // Create surah number with leading zeros (e.g., 001, 114)
      // String formattedSurahNumber = surahNumber.toString().padLeft(3, '0');

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

class QuranPlayerScreen extends StatelessWidget {
  final int surahNumber;
  final String surahName;

  const QuranPlayerScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranPlayerController());

    // Auto-play when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentSurah.value != surahNumber) {
        controller.playSurah(surahNumber);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مشغل القرآن الكريم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade800, Colors.teal.shade600],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          // Reader selection button
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'اختر القارئ',
            onPressed: () {
              _showReaderSelectionDialog(context, controller);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Surah Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.teal.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        surahName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سورة رقم $surahNumber',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Currently selected reader display
                Obx(() {
                  final reader = controller.currentReader;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person,
                            color: Colors.teal.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${reader?.name} (${reader?.quality} kbps)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () =>
                              _showReaderSelectionDialog(context, controller),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.teal.shade600,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Player Status Animation
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.hasError.value
                          ? Colors.red.withOpacity(0.1)
                          : controller.isLoading.value
                              ? Colors.amber.withOpacity(0.1)
                              : controller.isPlaying.value
                                  ? Colors.teal.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                    ),
                    child: Center(
                      child: controller.hasError.value
                          ? const Icon(Icons.error_outline, color: Colors.red)
                          : controller.isLoading.value
                              ? const SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.amber,
                                  ),
                                )
                              : controller.isPlaying.value
                                  ? _buildPlayingAnimation()
                                  : const Icon(Icons.pause, color: Colors.grey),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Progress Bar
                Obx(() {
                  final duration = controller.totalDuration.value;
                  final position = controller.currentPosition.value;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.teal.shade600,
                          inactiveTrackColor: Colors.teal.withOpacity(0.2),
                          thumbColor: Colors.white,
                          overlayColor: Colors.teal.withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8),
                          trackHeight: 4.0,
                        ),
                        child: Slider(
                          min: 0,
                          max: duration?.inMilliseconds.toDouble() ?? 1,
                          value: position.inMilliseconds.toDouble().clamp(
                              0, duration?.inMilliseconds.toDouble() ?? 1),
                          onChanged: controller.hasError.value
                              ? null
                              : (value) {
                                  controller.seek(
                                      Duration(milliseconds: value.toInt()));
                                },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(position),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatDuration(duration ?? Duration.zero),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 30),

                // Player Controls
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop Button
                      Material(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: controller.stopPlayer,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.stop,
                              size: 28,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Play/Pause/Retry Button
                      Material(
                        elevation: 4,
                        shadowColor: Colors.teal.withOpacity(0.5),
                        shape: const CircleBorder(),
                        color: controller.hasError.value
                            ? Colors.red.shade400
                            : Colors.teal.shade600,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: controller.hasError.value
                              ? controller.retryPlaying
                              : controller.togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              controller.hasError.value
                                  ? Icons.refresh
                                  : controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Status Messages
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: controller.errorMessage.value.isNotEmpty ||
                            controller.isLoading.value
                        ? 50
                        : 0,
                    child: AnimatedOpacity(
                      opacity: controller.errorMessage.value.isNotEmpty ||
                              controller.isLoading.value
                          ? 1.0
                          : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: controller.errorMessage.value.isNotEmpty
                          ? _buildStatusMessage(
                              controller.errorMessage.value,
                              controller.hasError.value
                                  ? Colors.red.shade400
                                  : Colors.amber.shade600,
                            )
                          : controller.isLoading.value
                              ? _buildStatusMessage(
                                  'جاري التحميل...',
                                  Colors.teal.shade600,
                                )
                              : const SizedBox.shrink(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReaderSelectionDialog(
      BuildContext context, QuranPlayerController controller) {
    showDialog(
      context: context,
      builder: (context) => ReaderSelectionDialog(controller: controller),
    );
  }

  Widget _buildPlayingAnimation() {
    return SizedBox(
      height: 20,
      width: 20,
      child: Center(
        child: Stack(
          children: List.generate(
            3,
            (index) => Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 600 + (index * 200)),
                curve: Curves.easeInOut,
                width: 10.0 + (index * 10.0),
                height: 10.0 + (index * 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.3 - (index * 0.1)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            color == Colors.red.shade400
                ? Icons.error_outline
                : color == Colors.amber.shade600
                    ? Icons.warning_amber
                    : Icons.info_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }
}

// New dialog for selecting the reader
class ReaderSelectionDialog extends StatefulWidget {
  final QuranPlayerController controller;

  const ReaderSelectionDialog({
    super.key,
    required this.controller,
  });

  @override
  State<ReaderSelectionDialog> createState() => _ReaderSelectionDialogState();
}

class _ReaderSelectionDialogState extends State<ReaderSelectionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _qualities = ['128', '192', '64'];
  final Map<String, String> _qualityNames = {
    '128': '128 كيلوبت/ثانية (جودة عالية)',
    '192': '192 كيلوبت/ثانية (جودة ممتازة)',
    '64': '64 كيلوبت/ثانية (حجم صغير)',
  };
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Find the initial tab index based on current quality setting
    int initialIndex =
        _qualities.indexOf(widget.controller.currentQuality.value);
    if (initialIndex < 0) initialIndex = 0;

    _tabController = TabController(
        initialIndex: initialIndex, length: _qualities.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Filter readers based on search query
  List<QuranReader> _getFilteredReaders(String quality) {
    return widget.controller.availableReaders
        .where((reader) =>
            reader.quality == quality &&
            (_searchQuery.isEmpty ||
                reader.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                reader.id.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.record_voice_over, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'اختر القارئ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const Spacer(),
                  // Close button
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن قارئ...',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: Icon(Icons.search, color: Colors.teal.shade400),
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // Tab bar for quality selection
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.teal.shade700,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: _qualities
                  .map((quality) => Tab(
                        child: Text(
                          quality,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
              onTap: (_) {
                // Force rebuild to update the reader list
                setState(() {});
              },
            ),

            const SizedBox(height: 8),

            // Quality description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _qualityNames[_qualities[_tabController.index]] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Reader list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _qualities.map((quality) {
                  final readers = _getFilteredReaders(quality);

                  if (readers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'لا يوجد قراء بهذه الجودة'
                                : 'لا توجد نتائج مطابقة',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: readers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final reader = readers[index];
                      final isSelected =
                          widget.controller.currentReaderId.value ==
                                  reader.id &&
                              widget.controller.currentQuality.value ==
                                  reader.quality;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        elevation: isSelected ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isSelected
                              ? BorderSide(
                                  color: Colors.teal.shade400, width: 2)
                              : BorderSide.none,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            widget.controller
                                .changeReader(reader.id, reader.quality);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Colors.teal.shade100
                                      : Colors.grey.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: isSelected
                                        ? Colors.teal.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reader.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.teal.shade800
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        reader.id,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.teal.shade600,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // Bottom action area
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Get the current selected reader in the tab
                      final quality = _qualities[_tabController.index];
                      final readers = _getFilteredReaders(quality);

                      if (readers.isNotEmpty) {
                        // Select the first reader in the current tab if none was selected
                        widget.controller
                            .changeReader(readers.first.id, quality);
                      }
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                    ),
                    child: const Text(
                      'اختيار',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
