import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../constants/app_constants.dart';

/// Embedded Medical Disclaimer Card following Stitch design (#43).
/// Fully theme-aware using tokens to ensure high contrast in both Light and Dark modes.
class MedicalDisclaimerCard extends StatelessWidget {
  final String text;
  final bool isCompact;

  const MedicalDisclaimerCard({
    super.key,
    this.text = AppConstants.medicalDisclaimerFull,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: tokens.primary.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.sm,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: tokens.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Notice',
                  style: AppTypography.bodyMediumSemibold.copyWith(
                    color: tokens.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: AppTypography.disclaimer.copyWith(
                    color: tokens.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
