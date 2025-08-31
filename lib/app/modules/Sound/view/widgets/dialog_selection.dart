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
    
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      
      return Dialog(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر القارئ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
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
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? isDarkMode 
                                    ? Colors.teal.shade900
                                    : Colors.teal.withOpacity(0.1)
                                : isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? isDarkMode
                                      ? Colors.tealAccent
                                      : Colors.teal
                                  : isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle : Icons.person,
                                color: isSelected
                                    ? isDarkMode
                                        ? Colors.tealAccent
                                        : Colors.teal
                                    : isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reader.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isDarkMode ? Colors.white : Colors.black87,
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
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: isDarkMode ? Colors.tealAccent : Colors.teal,
                    fontSize: 16,
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