import 'package:flutter/material.dart';
import 'app_colors.dart';

/// الـ Theme الموحد للتطبيق كله.
/// لو حبينا نغير شكل الأزرار أو الخطوط في كل الشاشات مرة واحدة،
/// هنا هو المكان.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryYellow,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryYellow,
        secondary: AppColors.primaryRed,
        surface: AppColors.surface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),

      // الزرار الأصفر الأساسي (Login, Next, Save...)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryYellow,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // الزرار التاني (Back, Cancel) - أوت لاين
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryYellow,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryYellow),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // شكل حقول الإدخال (Email, Password...)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textGrey),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textWhite),
        bodyMedium: TextStyle(color: AppColors.textWhite),
        bodySmall: TextStyle(color: AppColors.textGrey),
      ),
    );
  }
}