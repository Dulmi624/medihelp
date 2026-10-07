import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF287FEA);
  static const primaryDark = Color(0xFF1E4FD8);
  static const primarySoft = Color(0xFFD4EAFF);
  static const pageTop = Color(0xFF1E4FD8);
  static const pageMid = Color(0xFF4C9BFF);
  static const pageBottom = Color(0xFFEAF5FF);
  static const cardShadow = Color(0x40306FD8);
  static const glass = Color(0xD9FFFFFF);
  static const glassBorder = Color(0x80FFFFFF);
  static const fieldFill = Color(0xFFEAF3FC);
  static const softWhite = Color(0xD9FFFFFF);
  static const blobWhite = Color(0x38FFFFFF);
  static const blobBlue = Color(0x3286C8FF);
  static const errorSurface = Color(0xFFFFE8E8);
  static const errorText = Color(0xFFB63745);
  static const avatarTint = Color(0xFFC6E4FF);
  static const blueBorder = Color(0xFFCBE2FA);
  static const headerBlue = Color(0xFF4CA8FF);
  static const lightBlue = Color(0xFFE3F2FF);
  static const logoBlue = Color(0xFF9AD9FF);
  static const success = Color(0xFF26A269);
  static const warning = Color(0xFFF2994A);
  static const danger = Color(0xFFD64545);
  static const text = Color(0xFF172B4D);
  static const mutedText = Color(0xFF70809A);
  static const border = Color(0xFFD9E2F0);
  static const surface = Color(0xFFFFFFFF);
  static const onPrimary = Color(0xFFFFFFFF);
}

abstract final class AppGradients {
  static const page = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.pageTop, AppColors.pageMid, AppColors.pageBottom],
    stops: [0, .48, 1],
  );
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4C9BFF),
      Color(0xFF287FEA),
      Color(0xFF1E4FD8),
    ],
    stops: [0, .38, 1],
  );
  static const doctorBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1F8FF), Color(0xFFC7E5FF)],
  );
  static const serviceCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFDCEEFF)],
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBlue,
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.blueBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedText),
        prefixIconColor: AppColors.mutedText,
        suffixIconColor: AppColors.mutedText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
