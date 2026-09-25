import 'package:flutter/material.dart';

/// ألوان التطبيق الأساسية - مستخرجة من تصميم Figma
/// أي لون تستخدمه في أي شاشة، استخدمه من هنا عشان لو غيرنا لون
/// نغيره مكان واحد بس ويتحدث في كل الشاشات.
class AppColors {
  AppColors._();

  // الخلفية الأساسية (غامقة جدًا)
  static const Color background = Color(0xFF1A1A1A);

  // خلفية العناصر (Cards, TextFields, BottomSheets)
  static const Color surface = Color(0xFF232323);
  static const Color surfaceLight = Color(0xFF2C2C2C);

  // اللون الأساسي (الأصفر/الذهبي) - أزرار، أيقونات، تأكيدات
  static const Color primaryYellow = Color(0xFFF5B301);

  // اللون الثانوي (الأحمر) - زرار "Watch"
  static const Color primaryRed = Color(0xFFE50914);

  // النصوص
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);
  static const Color textGreyDark = Color(0xFF6E6E6E);

  // حدود العناصر (Border) زي إطار الـ Avatars
  static const Color borderYellow = Color(0xFFF5B301);
}
