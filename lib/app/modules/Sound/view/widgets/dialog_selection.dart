import 'package:quran_app/index.dart';



class ReaderSelectionDialog extends StatelessWidget {
  final QuranPlayerController controller;

  const ReaderSelectionDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<SettingsController>();
    final primaryColor = const Color(0xFF0F3E33);
    final goldAccent = const Color(0xFFCDA047);
    
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      
      return Dialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDarkMode ? goldAccent.withOpacity(0.3) : primaryColor.withOpacity(0.1),
            width: 1,
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر القارئ',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Amiri",
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? goldAccent : primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: controller.availableReaders.map((reader) {
                      final isSelected = controller.currentReaderId.value == reader.id;
                      return InkWell(
                        onTap: () {
                          controller.changeReader(reader.id, reader.quality);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? isDarkMode 
                                    ? goldAccent.withOpacity(0.1)
                                    : primaryColor.withOpacity(0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? isDarkMode
                                      ? goldAccent
                                      : primaryColor
                                  : isDarkMode
                                      ? Colors.white10
                                      : Colors.black12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.person_outline,
                                color: isSelected
                                    ? isDarkMode
                                        ? goldAccent
                                        : primaryColor
                                    : isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reader.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Amiri",
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected 
                                        ? isDarkMode ? goldAccent : primaryColor 
                                        : isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 18,
                    fontFamily: "Amiri",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}