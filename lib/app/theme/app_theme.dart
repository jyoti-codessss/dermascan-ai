import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Complete application theme configuration for DermaScan AI.
/// Supports both lightTheme and darkTheme adhering to Google Stitch specifications.
abstract final class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [AppThemeTokens.light],
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD8E2FF),
        onPrimaryContainer: Color(0xFF001A41),
        secondary: AppColors.secondaryLavender,
        onSecondary: Color(0xFF002E69),
        secondaryContainer: Color(0xFFE1E0FF),
        onSecondaryContainer: Color(0xFF1000A9),
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        error: AppColors.danger,
        onError: Colors.white,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: AppTypography.primaryFontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.heroDisplay.copyWith(color: AppColors.lightOnSurface),
        headlineLarge: AppTypography.h1.copyWith(color: AppColors.lightOnSurface),
        headlineMedium: AppTypography.h2.copyWith(color: AppColors.lightOnSurface),
        headlineSmall: AppTypography.h3.copyWith(color: AppColors.lightOnSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightOnSurface),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightOnSurfaceVariant),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightOnSurfaceVariant),
        labelLarge: AppTypography.buttonPrimary.copyWith(color: Colors.white),
        labelMedium: AppTypography.captionMedium.copyWith(color: AppColors.lightOnSurfaceVariant),
        labelSmall: AppTypography.caption.copyWith(color: AppColors.lightOutline),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.lightOnSurface),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightBorderGlass),
          borderRadius: AppRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size.fromHeight(50),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonPrimary.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightOnSurface,
          backgroundColor: AppColors.lightSurface,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.lightBorderGlass, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonSecondary.copyWith(color: AppColors.lightOnSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: AppTypography.buttonSecondary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainerLow,
        contentPadding: AppSpacing.inputPadding,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.lightOutlineVariant),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.lightOutlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.lightOutline),
        labelStyle: AppTypography.bodySmallMedium.copyWith(color: AppColors.lightOnSurfaceVariant),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.lightOutline,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutlineVariant,
        thickness: 1,
        space: 1,
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.primaryBlue,
        textColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [AppThemeTokens.dark],
      colorScheme: const ColorScheme.dark(
        primary: AppColors.stitchBlue,
        onPrimary: AppColors.onStitchBlue,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondaryLavender,
        onSecondary: Color(0xFF1000A9),
        secondaryContainer: Color(0xFF3131C0),
        onSecondaryContainer: Color(0xFFB0B2FF),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        error: AppColors.danger,
        onError: Colors.white,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: AppTypography.primaryFontFamily,
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.heroDisplay.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTypography.h1.copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTypography.h2.copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTypography.h3.copyWith(color: AppColors.darkOnSurface),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkOnSurface),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelLarge: AppTypography.buttonPrimary.copyWith(color: AppColors.onStitchBlue),
        labelMedium: AppTypography.captionMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelSmall: AppTypography.caption.copyWith(color: AppColors.darkOutline),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.darkOnSurface),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.darkBorderGlass),
          borderRadius: AppRadius.card,
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.stitchBlue,
          foregroundColor: AppColors.onStitchBlue,
          elevation: 0,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size.fromHeight(50),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonPrimary.copyWith(
            color: AppColors.onStitchBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkOnSurface,
          backgroundColor: AppColors.darkSurfaceGlass,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.darkBorderGlass, width: 1.2),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonSecondary.copyWith(color: AppColors.darkOnSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.stitchBlue,
          textStyle: AppTypography.buttonSecondary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceContainerLow,
        contentPadding: AppSpacing.inputPadding,
        border: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.darkBorderGlass),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.darkBorderGlass),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.stitchBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOutline),
        labelStyle: AppTypography.bodySmallMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.danger),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurfaceGlass,
        selectedItemColor: AppColors.stitchBlue,
        unselectedItemColor: AppColors.darkOutline,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderGlass,
        thickness: 1,
        space: 1,
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.stitchBlue,
        textColor: AppColors.onStitchBlue,
      ),
    );
  }
}
