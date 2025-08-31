import 'package:flutter/material.dart';
import 'package:quran_app/app/modules/Setting/view/widgets/painter_for_dialog.dart';

import '../../../../../utils/const/app_theme.dart';

class QuranAboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[850] : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Islamic pattern at the top
            Container(
              width: double.infinity,
              height: 60,
              child: CustomPaint(
                painter: IslamicHeaderPainter(
                  color: isDark
                      ? const Color.fromARGB(255, 161, 161, 161)
                          .withOpacity(0.3)
                      : AppColor.primaryColor.withOpacity(0.1),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // App icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book,
                size: 40,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // App title
            Text(
              'تطبيق القرآن الكريم',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // App version
            Text(
              'الإصدار 1.0.0',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // App dedication
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'هذا التطبيق تم تطويره لوجه الله تعالى\nولا نبتغي به مالاً ولا شهرة',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Prayer
            Text(
              'اللهم اجعله في ميزان حسناتنا',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'إغلاق',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
