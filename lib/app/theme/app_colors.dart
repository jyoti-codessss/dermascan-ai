import 'package:flutter/material.dart';

/// Design tokens for DermaScan AI based on Google Stitch project (9735817361088966162).
/// Supports both Dark (primary Stitch baseline) and Light (clinical daylight) modes.
abstract final class AppColors {
  // Brand Core
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color stitchBlue = Color(0xFFADC6FF);
  static const Color onStitchBlue = Color(0xFF002E69);
  static const Color primaryContainer = Color(0xFF4B8EFF);
  static const Color secondaryLavender = Color(0xFFC0C1FF);
  static const Color tertiaryPeach = Color(0xFFFFB595);

  // Status tokens (Shared)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark Mode Stitch Tokens
  static const Color darkBackground = Color(0xFF10131B);
  static const Color darkSurface = Color(0xFF1C2028);
  static const Color darkSurfaceContainerLow = Color(0xFF181C23);
  static const Color darkSurfaceContainerHigh = Color(0xFF272A32);
  static const Color darkSurfaceVariant = Color(0xFF31353D);
  static const Color darkSurfaceGlass = Color(0xB3111827); // rgba(17, 24, 39, 0.7)
  static const Color darkBorderGlass = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)
  static const Color darkBorder = Color(0x1AFFFFFF);
  static const Color darkOnSurface = Color(0xFFE0E2ED);
  static const Color darkOnSurfaceVariant = Color(0xFFC1C6D7);
  static const Color darkOutline = Color(0xFF8B90A0);
  static const Color darkOutlineVariant = Color(0xFF414755);

  // Light Mode Stitch Tokens
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF1F5F9);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);
  static const Color lightSurfaceGlass = Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)
  static const Color lightBorderGlass = Color(0x14000000); // rgba(0, 0, 0, 0.08)
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutline = Color(0xFF94A3B8);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);

  // Legacy compatibility getters
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color softMint = Color(0xFFCCFBF1);
  static const Color surfaceSecondary = Color(0xFF1C2028);
  static const Color surfaceTealSoft = Color(0x190F766E);
  static const Color background = Color(0xFF10131B);
  static const Color surface = Color(0xFF1C2028);
  static const Color textPrimary = Color(0xFFE0E2ED);
  static const Color textSecondary = Color(0xFFC1C6D7);
  static const Color textMuted = Color(0xFF8B90A0);
  static const Color textOnPrimary = Color(0xFF002E69);
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderSubdued = Color(0x1AFFFFFF);
  static const Color successBackground = Color(0x1910B981);
  static const Color warningBackground = Color(0x19F59E0B);
  static const Color dangerBackground = Color(0x19EF4444);
  static const Color infoBackground = Color(0x193B82F6);

  // Gradients
  static const LinearGradient aiGradient = LinearGradient(
    colors: [stitchBlue, secondaryLavender, tertiaryPeach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, stitchBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Custom Theme Extension for Stitch-specific tokens (glassmorphism, ambient lighting, borders).
@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  final Color background;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceVariant;
  final Color surfaceGlass;
  final Color borderGlass;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color tertiary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color ambientGlow1;
  final Color ambientGlow2;

  const AppThemeTokens({
    required this.background,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceVariant,
    required this.surfaceGlass,
    required this.borderGlass,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.tertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.ambientGlow1,
    required this.ambientGlow2,
  });

  static const dark = AppThemeTokens(
    background: Color(0xFF10131B),
    surface: Color(0xFF1C2028),
    surfaceContainerLow: Color(0xFF181C23),
    surfaceContainerHigh: Color(0xFF272A32),
    surfaceVariant: Color(0xFF31353D),
    surfaceGlass: Color(0xB3111827),
    borderGlass: Color(0x1AFFFFFF),
    onSurface: Color(0xFFE0E2ED),
    onSurfaceVariant: Color(0xFFC1C6D7),
    outline: Color(0xFF8B90A0),
    outlineVariant: Color(0xFF414755),
    primary: Color(0xFFADC6FF),
    onPrimary: Color(0xFF002E69),
    secondary: Color(0xFFC0C1FF),
    tertiary: Color(0xFFFFB595),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    ambientGlow1: Color(0x0C4B8EFF),
    ambientGlow2: Color(0x0C3131C0),
  );

  static const light = AppThemeTokens(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceVariant: Color(0xFFE2E8F0),
    surfaceGlass: Color(0xD9FFFFFF),
    borderGlass: Color(0x14000000),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF475569),
    outline: Color(0xFF94A3B8),
    outlineVariant: Color(0xFFCBD5E1),
    primary: Color(0xFF005BC1),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF3131C0),
    tertiary: Color(0xFFB45309),
    success: Color(0xFF10B981),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    ambientGlow1: Color(0x082563EB),
    ambientGlow2: Color(0x083131C0),
  );

  @override
  AppThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceContainerLow,
    Color? surfaceContainerHigh,
    Color? surfaceVariant,
    Color? surfaceGlass,
    Color? borderGlass,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? tertiary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? ambientGlow1,
    Color? ambientGlow2,
  }) {
    return AppThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      borderGlass: borderGlass ?? this.borderGlass,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      ambientGlow1: ambientGlow1 ?? this.ambientGlow1,
      ambientGlow2: ambientGlow2 ?? this.ambientGlow2,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      borderGlass: Color.lerp(borderGlass, other.borderGlass, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      ambientGlow1: Color.lerp(ambientGlow1, other.ambientGlow1, t)!,
      ambientGlow2: Color.lerp(ambientGlow2, other.ambientGlow2, t)!,
    );
  }
}

/// Convenient extension on BuildContext to access Stitch design tokens.
extension AppThemeContextExtension on BuildContext {
  AppThemeTokens get tokens =>
      Theme.of(this).extension<AppThemeTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppThemeTokens.dark
          : AppThemeTokens.light);

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
