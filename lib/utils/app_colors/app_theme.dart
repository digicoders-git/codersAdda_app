import 'package:coders_adda_app/utils/app_colors/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
//  BRAND COLORS  (extracted from CodersAdda logo)
// ─────────────────────────────────────────────
class AppColors {
  // Primary logo colors
  static const Color logoBlue   = Color(0xFF004BFE);
  static const Color logoNavy   = Color(0xFF00113F);
  static const Color logoGreen  = Color(0xFF26954F);
  static const Color logoOrange = Color(0xFFDCA85D);

  // ── Light Mode ──────────────────────────────
  static const Color primaryColor     = logoBlue;
  static const Color accentColor      = logoOrange;
  static const Color buttonColor      = logoNavy;
  static const Color successColor     = logoGreen;
  static const Color backgroundColor  = Color(0xFFF4F6FB);
  static const Color cardColor        = Color(0xFFFFFFFF);
  static const Color textColor        = Color(0xFF0D1B3E);
  static const Color textSecondary    = Color(0xFF5A6A8A);
  static const Color onSurfaceVariant = Color(0xFF5A6A8A);
  static const Color outline          = Color(0xFFD0D7E6);
  static const Color errorColor       = Color(0xFFD32F2F);
  static const Color surfaceVariant   = Color(0xFFE8EEF9);

  // ── Dark Mode ───────────────────────────────
  static const Color darkBackground   = Color(0xFF060E25);
  static const Color darkSurface      = Color(0xFF0D1B3E);
  static const Color darkCard         = Color(0xFF112259);
  static const Color darkTextPrimary  = Color(0xFFF0F4FF);
  static const Color darkTextSecondary= Color(0xFF8BA3C8);
  static const Color darkOutline      = Color(0xFF1E3470);
  static const Color darkSurfaceVariant = Color(0xFF162A6E);
}

// ─────────────────────────────────────────────
//  THEME PROVIDER  (for dark/light toggle)
// ─────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  static const _key = 'isDarkMode';
  bool _isDark = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
//  APP THEME DATA  (static — no context needed)
// ─────────────────────────────────────────────
class AppTheme {
  // ── Light Theme ─────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.logoBlue,
        onPrimary: Colors.white,
        secondary: AppColors.logoOrange,
        onSecondary: Colors.white,
        tertiary: AppColors.logoGreen,
        onTertiary: Colors.white,
        surface: AppColors.cardColor,
        onSurface: AppColors.logoNavy,
        error: AppColors.errorColor,
        outline: AppColors.outline,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      cardColor: AppColors.cardColor,
      dividerColor: AppColors.outline,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.logoNavy,
        elevation: 0.5,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.logoNavy),
        titleTextStyle: TextStyle(
          color: AppColors.logoNavy,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.logoBlue,
          side: const BorderSide(color: AppColors.logoBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.logoBlue),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.logoBlue.withOpacity(0.08),
        labelStyle: TextStyle(color: AppColors.logoBlue),
        side: BorderSide(color: AppColors.logoBlue.withOpacity(0.3)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.logoBlue,
        linearTrackColor: AppColors.outline,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.logoBlue,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.logoBlue,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? AppColors.logoBlue : Colors.white,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? AppColors.logoBlue.withOpacity(0.5)
              : AppColors.outline,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.logoOrange,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardColor,
        selectedItemColor: AppColors.logoBlue,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.logoBlue,
        onPrimary: Colors.white,
        secondary: AppColors.logoOrange,
        onSecondary: Colors.white,
        tertiary: AppColors.logoGreen,
        onTertiary: Colors.white,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.errorColor,
        outline: AppColors.darkOutline,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkOutline,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.logoBlue),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.logoBlue,
          side: const BorderSide(color: AppColors.logoBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.logoBlue),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.logoBlue.withOpacity(0.15),
        labelStyle: TextStyle(color: AppColors.logoBlue),
        side: BorderSide(color: AppColors.logoBlue.withOpacity(0.4)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.logoBlue,
        linearTrackColor: AppColors.darkOutline,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.logoBlue,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.logoBlue,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? AppColors.logoBlue : AppColors.darkTextSecondary,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? AppColors.logoBlue.withOpacity(0.5)
              : AppColors.darkOutline,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.logoBlue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.logoBlue,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),
    );
  }
}