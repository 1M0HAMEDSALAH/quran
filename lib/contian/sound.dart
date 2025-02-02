// lib/controllers/quran_player_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class QuranPlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer();
  
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = RxString('');
  final RxInt currentSurah = 0.obs;
  final RxBool isPaused = false.obs;

  @override
  void onInit() {
    super.onInit();
    setupAudioPlayerListeners();
  }

  void setupAudioPlayerListeners() {
    // Listen to player state changes
    audioPlayer.playerStateStream.listen((PlayerState state) {
      if (state.processingState == ProcessingState.ready) {
        isLoading.value = false;
      }
      
      isPlaying.value = state.playing;
      isPaused.value = !state.playing && state.processingState != ProcessingState.completed;
      
      // Reset loading when completed
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        currentSurah.value = 0;
        isPaused.value = false;
        isLoading.value = false;
      }
    });

    // Listen for errors through processingStateStream
    audioPlayer.processingStateStream.listen((ProcessingState state) {
      switch (state) {
        case ProcessingState.loading:
          isLoading.value = true;
          break;
        case ProcessingState.ready:
          isLoading.value = false;
          break;
        case ProcessingState.completed:
          isLoading.value = false;
          isPlaying.value = false;
          currentSurah.value = 0;
          isPaused.value = false;
          break;
        case ProcessingState.idle:
          isLoading.value = false;
          break;
        default:
          break;
      }
    });

    // Listen for errors
    audioPlayer.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace stackTrace) {
        print('Error occurred: $e');
        errorMessage.value = 'خطأ في التشغيل: $e';
        isPlaying.value = false;
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> playSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > 114) {
      errorMessage.value = 'رقم السورة يجب أن يكون بين 1 و 114';
      return;
    }

    try {
      // Reset states
      errorMessage.value = '';
      isLoading.value = true;
      
      // Stop any currently playing audio
      await audioPlayer.stop();

      currentSurah.value = surahNumber;
      final url = 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber.mp3';
      
      // Set the audio source
      await audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        preload: true, // Ensure audio is preloaded
      );

      // Start playing
      await audioPlayer.play();
      
    } catch (e) {
      print('Error in playSurah: $e');
      errorMessage.value = 'حدث خطأ أثناء تشغيل السورة: $e';
      isPlaying.value = false;
      currentSurah.value = 0;
      isLoading.value = false;
    }
  }

  Future<void> stopSurah() async {
    try {
      isLoading.value = true;
      await audioPlayer.stop();
      isPlaying.value = false;
      currentSurah.value = 0;
      isPaused.value = false;
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء إيقاف التشغيل: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pauseSurah() async {
    try {
      await audioPlayer.pause();
      isPaused.value = true;
      isPlaying.value = false;
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء إيقاف التشغيل المؤقت: $e';
    }
  }

  Future<void> resumeSurah() async {
    try {
      await audioPlayer.play();
      isPaused.value = false;
      isPlaying.value = true;
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء استئناف التشغيل: $e';
    }
  }
}

class QuranPlayerScreen extends StatelessWidget {
  final int surahNumber;
  final QuranPlayerController controller = Get.put(QuranPlayerController());

  QuranPlayerScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مشغل القرآن الكريم',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'السورة رقم: $surahNumber',
              style: GoogleFonts.tajawal(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const SizedBox.shrink()),

            const SizedBox(height: 20),

            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!controller.isPlaying.value && !controller.isPaused.value)
                      _controlButton(
                        icon: Icons.play_arrow,
                        label: 'تشغيل',
                        onTap: controller.isLoading.value
                            ? null
                            : () => controller.playSurah(surahNumber),
                      )
                    else ...[
                      if (controller.isPlaying.value)
                        _controlButton(
                          icon: Icons.pause,
                          label: 'إيقاف مؤقت',
                          onTap: controller.isLoading.value
                              ? null
                              : controller.pauseSurah,
                        ),
                      if (controller.isPaused.value)
                        _controlButton(
                          icon: Icons.play_arrow,
                          label: 'استئناف',
                          onTap: controller.isLoading.value
                              ? null
                              : controller.resumeSurah,
                        ),
                      const SizedBox(width: 16),
                      _controlButton(
                        icon: Icons.stop,
                        label: 'إيقاف',
                        onTap: controller.isLoading.value
                            ? null
                            : controller.stopSurah,
                      ),
                    ],
                  ],
                )),
            const SizedBox(height: 20),

            Obx(() => controller.errorMessage.value.isNotEmpty
                ? _infoBox(
                    text: controller.errorMessage.value,
                    color: Colors.red.shade300,
                    textColor: Colors.white,
                  )
                : const SizedBox.shrink()),

            Obx(() => controller.currentSurah.value > 0
                ? _infoBox(
                    text: 'جاري تشغيل السورة رقم: ${controller.currentSurah.value}',
                    color: Colors.green.shade300,
                    textColor: Colors.white,
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _infoBox({required String text, required Color color, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.tajawal(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}