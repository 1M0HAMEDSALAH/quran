import 'package:quran_app/index.dart';

class MiniQuranPlayer extends StatelessWidget {
  const MiniQuranPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final QuranPlayerController controller = Get.find<QuranPlayerController>();
    final isDarkMode = Get.find<SettingsController>();

    return Obx(() {
      if (controller.currentSurah.value <= 0) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color:
              isDarkMode.isDarkMode.value ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode.isDarkMode.value
                  ? Colors.black54
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Get.to(QuranPlayerScreen(
              surahName: getSurahNameArabic(controller.currentSurah.value),
              surahNumber: controller.currentSurah.value,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Obx(() {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.hasError.value
                          ? Colors.red.withOpacity(0.2)
                          : isDarkMode.isDarkMode.value
                              ? Colors.teal.shade800
                              : Colors.teal.shade100,
                    ),
                    child: Center(
                      child: controller.hasError.value
                          ? const Icon(Icons.error_outline,
                              color: Colors.red, size: 20)
                          : controller.isLoading.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDarkMode.isDarkMode.value
                                        ? Colors.tealAccent
                                        : Colors.teal,
                                  ),
                                )
                              : Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 20,
                                  color: isDarkMode.isDarkMode.value
                                      ? Colors.white
                                      : Colors.teal.shade700,
                                ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                            getSurahNameArabic(controller.currentSurah.value),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDarkMode.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            controller.currentReader?.name ?? "",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode.isDarkMode.value
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.togglePlayPause,
                  icon: Obx(() => Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: isDarkMode.isDarkMode.value
                            ? Colors.tealAccent
                            : Colors.teal.shade700,
                      )),
                ),
                IconButton(
                  onPressed: () {
                    controller.stopPlayer();
                  },
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode.isDarkMode.value
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
