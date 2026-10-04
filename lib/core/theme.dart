import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF247BEE);
  static const primaryDark = Color(0xFF0B49B7);
  static const primarySoft = Color(0xFFD9ECFF);
  static const pageTop = Color(0xFFE7F3FF);
  static const pageBottom = Color(0xFFF8FBFF);
  static const cardShadow = Color(0x263A80D8);
  static const avatarTint = Color(0xFFC6E4FF);
  static const blueBorder = Color(0xFFCBE2FA);
  static const headerBlue = Color(0xFF3B8CF4);
  static const lightBlue = Color(0xFFEAF4FF);
  static const logoBlue = Color(0xFF8ED1FF);
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
    colors: [AppColors.pageTop, AppColors.pageBottom],
  );
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF55B8FF),
      AppColors.primary,
      AppColors.primaryDark,
    ],
    stops: [0, .48, 1],
  );
  static const doctorBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1F8FF), Color(0xFFC7E5FF)],
  );
  static const serviceCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFEAF5FF)],
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
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
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
