import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen matching Stitch Offline State design (d048d57536604d668f0aa81cbe2ea44c).
class OfflineStateScreen extends ConsumerWidget {
  final VoidCallback? onRetry;

  const OfflineStateScreen({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: AppRadius.card,
                border: Border.all(color: tokens.borderGlass),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wifi off icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.danger.withValues(alpha: 0.12),
                      border: Border.all(
                        color: tokens.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.wifi_off,
                      size: 44,
                      color: tokens.danger,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Headline
                  Text(
                    "You're Offline",
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: tokens.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Description
                  Text(
                    "We can't connect to the network right now. Please check your internet connection or try again later.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: tokens.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Try Again Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.primary,
                        foregroundColor: tokens.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        'TRY AGAIN',
                        style: AppTypography.buttonPrimary.copyWith(
                          color: tokens.onPrimary,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: onRetry ?? () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Diagnostics link
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.build_outlined, size: 16, color: tokens.outline),
                    label: Text(
                      'Run Network Diagnostics',
                      style: AppTypography.caption.copyWith(color: tokens.outline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
