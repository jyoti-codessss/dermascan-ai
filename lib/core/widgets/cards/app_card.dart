import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Reusable AppCard container using theme tokens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final cardBorderRadius = borderRadius ?? AppRadius.card;

    final container = Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surface,
        borderRadius: cardBorderRadius,
        border: Border.all(
          color: borderColor ?? tokens.borderGlass,
          width: 1.0,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: container,
        ),
      );
    }

    return container;
  }
}
