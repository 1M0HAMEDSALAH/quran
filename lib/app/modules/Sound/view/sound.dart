import 'package:quran_app/index.dart';


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
    final themeController = Get.find<SettingsController>();

    // Auto-play when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentSurah.value != surahNumber) {
        controller.playSurah(surahNumber);
      }
    });

    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      final primaryColor = const Color(0xFF0F3E33);
      final goldAccent = const Color(0xFFCDA047);

      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: isDarkMode ? goldAccent : primaryColor),
          title: Text(
            'مشغل القرآن الكريم',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontFamily: "Amiri",
              fontSize: 22,
              color: isDarkMode ? goldAccent : primaryColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            // Reader selection button
            IconButton(
              icon: Icon(Icons.person, color: isDarkMode ? goldAccent : primaryColor),
              tooltip: 'اختر القارئ',
              onPressed: () {
                _showReaderSelectionDialog(context, controller);
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/islamic_pattern.png'),
              opacity: isDarkMode ? 0.05 : 0.03,
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDarkMode ? Colors.white10 : primaryColor.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Surah Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          surahName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Amiri",
                            color: Color(0xFFCDA047), // Gold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'سورة رقم $surahNumber',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Amiri",
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Currently selected reader display
                  Obx(() {
                    final reader = controller.currentReader;
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? goldAccent.withOpacity(0.05) : primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDarkMode ? goldAccent.withOpacity(0.2) : primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, color: isDarkMode ? goldAccent : primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${reader?.name}',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Amiri",
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? goldAccent : primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _showReaderSelectionDialog(context, controller),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Player Status Animation
                  Obx(() {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.hasError.value
                            ? Colors.red.withOpacity(0.1)
                            : controller.isLoading.value
                                ? goldAccent.withOpacity(0.1)
                                : controller.isPlaying.value
                                    ? primaryColor.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                      ),
                      child: Center(
                        child: controller.hasError.value
                            ? const Icon(Icons.error_outline, color: Colors.red, size: 28)
                            : controller.isLoading.value
                                ? SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: goldAccent,
                                    ),
                                  )
                                : controller.isPlaying.value
                                    ? _buildPlayingAnimation(primaryColor)
                                    : Icon(Icons.pause, color: isDarkMode ? Colors.white54 : Colors.black54, size: 28),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Progress Bar
                  Obx(() {
                    final duration = controller.totalDuration.value;
                    final position = controller.currentPosition.value;

                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: goldAccent,
                            inactiveTrackColor: isDarkMode ? Colors.white10 : primaryColor.withOpacity(0.1),
                            thumbColor: goldAccent,
                            overlayColor: goldAccent.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
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
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                formatDuration(duration ?? Duration.zero),
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 40),

                  // Player Controls
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Stop Button
                        Material(
                          color: isDarkMode ? const Color(0xFF2C1E1E) : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: controller.stopPlayer,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                Icons.stop,
                                size: 30,
                                color: Colors.red.shade400,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),

                        // Play/Pause/Retry Button
                        Material(
                          elevation: 6,
                          shadowColor: (controller.hasError.value ? Colors.red : primaryColor).withOpacity(0.4),
                          shape: const CircleBorder(),
                          color: controller.hasError.value
                              ? Colors.red.shade600
                              : primaryColor,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: controller.hasError.value
                                ? controller.retryPlaying
                                : controller.togglePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              child: Icon(
                                controller.hasError.value
                                    ? Icons.refresh
                                    : controller.isPlaying.value
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                size: 40,
                                color: goldAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  // Status Messages
                  Obx(() {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: controller.errorMessage.value.isNotEmpty ||
                              controller.isLoading.value
                          ? 60
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
                                    : goldAccent,
                              )
                            : controller.isLoading.value
                                ? _buildStatusMessage(
                                    'جاري التحميل...',
                                    goldAccent,
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
    });
  }

  void _showReaderSelectionDialog(BuildContext context, QuranPlayerController controller) {
    showDialog(
      context: context,
      builder: (context) => ReaderSelectionDialog(controller: controller),
    );
  }

  Widget _buildPlayingAnimation(Color primaryColor) {
    return SizedBox(
      height: 30,
      width: 30,
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
                  color: primaryColor.withOpacity(0.4 - (index * 0.1)),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                : Icons.info_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: "Amiri",
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
