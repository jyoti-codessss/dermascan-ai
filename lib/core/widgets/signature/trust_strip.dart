import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Signature Component #4: TrustStrip
/// Compact, calm trust indicator placed prominently near AI results.
/// Communicates transparency without alarming the user.
class TrustStrip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool showDetailOnTap;

  const TrustStrip({
    super.key,
    this.text = AppConstants.medicalDisclaimerShort,
    this.onTap,
    this.showDetailOnTap = true,
  });

  void _showDisclaimerBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxlValue)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.infoBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'AI Information Notice',
                      style: AppTypography.h3.copyWith(
                        fontFamily: AppTypography.displayFontFamily,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppConstants.medicalDisclaimerFull,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Understood'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? (showDetailOnTap ? () => _showDisclaimerBottomSheet(context) : null),
      borderRadius: AppRadius.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceTealSoft,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: AppColors.secondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                text,
                style: AppTypography.captionMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
            if (showDetailOnTap || onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
