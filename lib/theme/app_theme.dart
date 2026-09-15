import 'package:flutter/material.dart';

class AppColors {
  // Primary Blues
  static const Color primaryBlue = Color(0xFF2662EA);
  static const Color primaryDarkBlue = Color(0xFF1A4EC8);
  static const Color deepNavy = Color(0xFF0F1E4A);
  static const Color royalBlueGradientStart = Color(0xFF2E6FF2);
  static const Color royalBlueGradientEnd = Color(0xFF1B53D3);

  // Soft & Accent Blues
  static const Color softBlueBackground = Color(0xFFF3F6FD);
  static const Color skyBlueAccent = Color(0xFFDBEAFE);
  static const Color lightBlueBubble = Color(0x28FFFFFF);
  static const Color lightBlueBubbleDarker = Color(0x1A2662EA);
  static const Color activePillBlue = Color(0xFF2662EA);
  static const Color inactivePillBorder = Color(0xFFE2E8F0);

  // Accent & Semantic
  static const Color mintGreen = Color(0xFF10B981);
  static const Color mintGreenLight = Color(0xFFE3F8EE);
  static const Color mintGreenDark = Color(0xFF059669);
  static const Color coralRed = Color(0xFFEF4444);
  static const Color coralRedLight = Color(0xFFFEE2E2);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);

  // Neutrals & Cards
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE8EEF7);
}

class AppGradients {
  static const LinearGradient royalBlue = LinearGradient(
    colors: [AppColors.royalBlueGradientStart, AppColors.royalBlueGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDeepBlue = LinearGradient(
    colors: [Color(0xFF2B66EC), Color(0xFF1D51D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardSoftBlue = LinearGradient(
    colors: [Color(0xFF94B5F9), Color(0xFFB8D0FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightBackground = LinearGradient(
    colors: [Color(0xFFF8FAFF), Color(0xFFEFF4FC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  static List<BoxShadow> softCard = [
    BoxShadow(
      color: const Color(0xFF1E3A8A).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF1E3A8A).withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> blueGlow = [
    BoxShadow(
      color: AppColors.primaryBlue.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        surface: AppColors.surfaceWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.softBlueBackground,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor: AppColors.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: AppColors.textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
