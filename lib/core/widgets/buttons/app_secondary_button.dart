import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// Standard Outlined / Secondary Button for DermaScan AI.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;
  final bool isFullWidth;
  final Color? borderColor;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 52.0,
    this.isFullWidth = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final buttonWidget = OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        disabledForegroundColor: AppColors.textMuted,
        side: BorderSide(
          color: isEnabled ? (borderColor ?? AppColors.border) : AppColors.borderSubdued,
          width: 1.2,
        ),
        minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? 52.0),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
        padding: AppSpacing.buttonPadding,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTypography.buttonSecondary.copyWith(
                    color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(trailingIcon, size: 18, color: AppColors.textPrimary),
                ],
              ],
            ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget;
  }
}
