import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

enum StatusBadgeType {
  completed,
  processing,
  lowConfidence,
  unableToAnalyze,
  failed,
  info,
}

/// Status badge with both icon and text, adhering to design.md (#45)
/// (Never communicates meaning through color alone).
class StatusBadge extends StatelessWidget {
  final StatusBadgeType type;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final (label, icon, fgColor, bgColor) = switch (type) {
      StatusBadgeType.completed => (
          customLabel ?? 'Completed',
          Icons.check_circle_outline_rounded,
          AppColors.success,
          AppColors.successBackground,
        ),
      StatusBadgeType.processing => (
          customLabel ?? 'Analyzing',
          Icons.sync_rounded,
          AppColors.primary,
          AppColors.infoBackground,
        ),
      StatusBadgeType.lowConfidence => (
          customLabel ?? 'Low Confidence',
          Icons.help_outline_rounded,
          AppColors.warning,
          AppColors.warningBackground,
        ),
      StatusBadgeType.unableToAnalyze => (
          customLabel ?? 'Unable to Analyze',
          Icons.warning_amber_rounded,
          AppColors.warning,
          AppColors.warningBackground,
        ),
      StatusBadgeType.failed => (
          customLabel ?? 'Analysis Failed',
          Icons.error_outline_rounded,
          AppColors.danger,
          AppColors.dangerBackground,
        ),
      StatusBadgeType.info => (
          customLabel ?? 'Informational',
          Icons.info_outline_rounded,
          AppColors.secondary,
          AppColors.surfaceTealSoft,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.statusBadge,
        border: Border.all(color: fgColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fgColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.captionMedium.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
