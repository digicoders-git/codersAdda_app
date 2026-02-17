import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF0D47A1);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color surfaceVariant = Color(0xFFE3F2FD);
  static const Color onSurfaceVariant = Color(0xFF424242);
  static const Color outline = Color(0xFFBDBDBD);
}



class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.accentColor,
        surface: AppColors.cardColor,
        background: AppColors.backgroundColor,
        onSurface: AppColors.textColor,
      ),
      fontFamily: 'Inter',
    );
  }
}