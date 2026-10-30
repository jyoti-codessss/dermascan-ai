import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

/// Standard Primary Button for DermaScan AI.
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;
  final bool isFullWidth;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 52.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final buttonWidget = ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
        elevation: 0,
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTypography.buttonPrimary,
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(trailingIcon, size: 18),
                ],
              ],
            ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget;
  }
}
