import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Design System Tokens Test', () {
    test('AppColors verify Stitch core palette tokens', () {
      expect(AppColors.primaryBlue, const Color(0xFF2563EB));
      expect(AppColors.stitchBlue, const Color(0xFFADC6FF));
      expect(AppColors.darkBackground, const Color(0xFF10131B));
      expect(AppColors.lightBackground, const Color(0xFFF8FAFC));
      expect(AppColors.success, const Color(0xFF10B981));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.danger, const Color(0xFFEF4444));
    });

    test('AppSpacing verify spacing scale', () {
      expect(AppSpacing.xxs, 4.0);
      expect(AppSpacing.xs, 8.0);
      expect(AppSpacing.sm, 12.0);
      expect(AppSpacing.md, 16.0);
      expect(AppSpacing.lg, 20.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
    });

    test('AppRadius verify border radius scale', () {
      expect(AppRadius.xsValue, 4.0);
      expect(AppRadius.smValue, 8.0);
      expect(AppRadius.mdValue, 12.0);
      expect(AppRadius.lgValue, 16.0);
      expect(AppRadius.pillValue, 999.0);
    });

    test('AppTheme creates valid Material 3 light and dark ThemeData', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.scaffoldBackgroundColor, AppColors.lightBackground);

      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, AppColors.darkBackground);
    });
  });
}
