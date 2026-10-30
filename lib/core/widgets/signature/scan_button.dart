import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/widgets/signature/skin_orb.dart';
import 'package:flutter/material.dart';

/// Signature Component #2: ScanButton
/// Signature pill-shaped primary action for initiating skin analysis.
class ScanButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final String? subtitle;
  final bool isLoading;
  final bool isFullWidth;

  const ScanButton({
    super.key,
    required this.onPressed,
    this.label = 'Start a skin scan',
    this.subtitle,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  State<ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<ScanButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        height: widget.subtitle != null ? 72 : 60,
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill,
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    const Color(0xFF2563EB),
                    const Color(0xFF0F766E),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isEnabled ? null : tokens.surfaceVariant,
          border: Border.all(
            color: isEnabled ? tokens.primary.withValues(alpha: 0.4) : tokens.borderGlass,
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Embedded mini SkinOrb
            if (widget.isLoading)
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              const SkinOrb(
                size: SkinOrbSize.small,
                customSize: 36,
                isAnimated: true,
              ),

            const SizedBox(width: AppSpacing.md),

            // Button Label & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.buttonPrimary.copyWith(
                      color: isEnabled ? Colors.white : tokens.outline,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: isEnabled
                            ? Colors.white.withValues(alpha: 0.85)
                            : tokens.outline,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Trailing Chevron / Arrow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.transparent,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isEnabled ? Colors.white : tokens.outline,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
