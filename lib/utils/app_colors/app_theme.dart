import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  BRAND COLORS  (Based on EdTech Branding Guide)
// ─────────────────────────────────────────────
class AppColors {
  static const Color logoNavy         = Color(0xFF01123F); 
  static const Color logoBlue         = Color(0xFF0145E6); 
  static const Color logoOrange       = Color(0xFFFC6304); 
  static const Color logoGreen        = Color(0xFF25934E); 
  static const Color logoBlueMedium   = Color(0xFF083AA5); 
  static const Color logoOrangeLight  = Color(0xFFFC702E); 
  static const Color logoGreenDark    = Color(0xFF16582E); 
  
  static const Color primaryColor     = logoBlue;       
  static const Color accentColor      = logoOrange;     
  static const Color buttonColor      = logoBlue;       
  static const Color successColor     = logoGreen;      
  
  static const Color backgroundColor  = Color(0xFFF5F8FF); 
  static const Color cardColor        = Color(0xFFFFFFFF); 
  static const Color surfaceVariant   = Color(0xFFF1F5F9); // Added back to fix compilation
  static const Color textColor        = Color(0xFF01123F); 
  static const Color textSecondary    = Color(0xFF64748B); 
  static const Color onSurfaceVariant = Color(0xFF64748B); // Added back to fix compilation
  static const Color outline          = Color(0xFFE2E8F0); 
  static const Color errorColor       = Color(0xFFFC6304); // Using orange/red for errors 
  
  // Dark Mode (if needed, kept minimal)
  static const Color darkBackground   = Color(0xFF060E25);
  static const Color darkSurface      = Color(0xFF0D1B3E);
  static const Color darkCard         = Color(0xFF112259);
  static const Color darkTextPrimary  = Color(0xFFF0F4FF);
  static const Color darkTextSecondary= Color(0xFF8BA3C8);
  static const Color darkOutline      = Color(0xFF1E3470);
}

// ─────────────────────────────────────────────
//  THEME PROVIDER
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
//  APP THEME DATA
// ─────────────────────────────────────────────
class AppTheme {
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
      
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(color: AppColors.logoNavy, fontWeight: FontWeight.w700, fontSize: 30),
        headlineMedium: GoogleFonts.poppins(color: AppColors.logoNavy, fontWeight: FontWeight.w700, fontSize: 26),
        headlineSmall: GoogleFonts.poppins(color: AppColors.logoNavy, fontWeight: FontWeight.w600, fontSize: 22),
        titleLarge: GoogleFonts.poppins(color: AppColors.logoNavy, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.poppins(color: AppColors.logoNavy, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.poppins(color: AppColors.textColor, fontWeight: FontWeight.w400, fontSize: 15),
        bodyMedium: GoogleFonts.poppins(color: AppColors.textColor, fontWeight: FontWeight.w400, fontSize: 14),
        bodySmall: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 12),
        labelLarge: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardColor,
        foregroundColor: AppColors.logoNavy,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.logoNavy),
        actionsIconTheme: const IconThemeData(color: AppColors.logoNavy),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.logoNavy,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.logoBlue,
          backgroundColor: AppColors.backgroundColor,
          side: const BorderSide(color: AppColors.logoBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.logoBlue,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.logoBlue, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w400, fontSize: 15),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardColor,
        selectedItemColor: AppColors.logoBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme; // For now keeping simple or mapping same logic if dark mode requested. (Simplified for constraint).
  }
}