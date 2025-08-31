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
        elevation: 0,
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
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Colors.white,
        //       Colors.teal.shade50,
        //     ],
        //   ),
        // ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // color: Colors.white,
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
                          '${reader?.name}',
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
