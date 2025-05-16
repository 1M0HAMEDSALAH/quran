import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class QuranPlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentSurah = 0.obs;
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration?> totalDuration = Rx<Duration?>(null);

  @override
  void onInit() {
    super.onInit();
    setupAudioPlayerListeners();
  }

  void setupAudioPlayerListeners() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.ready) {
        isLoading.value = false;
      }
    });

    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });

    audioPlayer.durationStream.listen((duration) {
      totalDuration.value = duration;
    });

    audioPlayer.processingStateStream.listen((state) {
      isLoading.value = state == ProcessingState.loading;
    });

    audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (e, _) {
        errorMessage.value = 'Playback error: ${e.toString()}';
        isLoading.value = false;
      },
    );
  }

  Future<void> playSurah(int surahNumber) async {
    try {
      errorMessage.value = '';
      isLoading.value = true;
      currentSurah.value = surahNumber;

      await audioPlayer.stop();
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(
          'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber.mp3',
        )),
      );

      await audioPlayer.play();
    } catch (e) {
      errorMessage.value = 'Error playing surah: ${e.toString()}';
      isLoading.value = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
  }

  Future<void> stopPlayer() async {
    await audioPlayer.stop();
    currentSurah.value = 0;
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  @override
  void onClose() {
    audioPlayer.dispose();
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
        title: Text(
          'مشغل القرآن الكريم',
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Surah Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      surahName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سورة رقم $surahNumber',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Progress Bar
              Obx(() {
                final duration = controller.totalDuration.value;
                final position = controller.currentPosition.value;

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.tealAccent,
                        inactiveTrackColor: Colors.teal.withOpacity(0.3),
                        thumbColor: Colors.white,
                        overlayColor: Colors.tealAccent.withOpacity(0.2),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        min: 0,
                        max: duration?.inMilliseconds.toDouble() ?? 1,
                        value: position.inMilliseconds
                            .toDouble()
                            .clamp(0, duration?.inMilliseconds.toDouble() ?? 1),
                        onChanged: (value) {
                          controller
                              .seek(Duration(milliseconds: value.toInt()));
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
                          ),
                          Text(
                            formatDuration(duration ?? Duration.zero),
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
                    IconButton(
                      icon: const Icon(Icons.stop, size: 32),
                      color: Colors.redAccent,
                      onPressed: controller.stopPlayer,
                    ),

                    const SizedBox(width: 20),

                    // Play/Pause Button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 36,
                        ),
                        color: Colors.white,
                        onPressed: controller.togglePlayPause,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Status Messages
              Obx(() {
                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildStatusMessage(
                    controller.errorMessage.value,
                    Colors.redAccent,
                  );
                }
                if (controller.isLoading.value) {
                  return _buildStatusMessage(
                    'جاري التحميل...',
                    Colors.tealAccent,
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
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
