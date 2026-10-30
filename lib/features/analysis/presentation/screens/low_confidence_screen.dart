import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Low Confidence Result Screen matching Stitch design (8032c288eed24cf4bb480f4ec8d9ff8d).
class LowConfidenceScreen extends ConsumerWidget {
  const LowConfidenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surfaceGlass,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.onSurface),
          onPressed: () => context.go(RoutePaths.dashboard),
        ),
        title: Text(
          'DermaScan AI',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: tokens.primary),
            onPressed: () => context.push(RoutePaths.history),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Glassmorphism Center Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Graphic Element: Calm out-of-focus indicator
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.surfaceVariant,
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Icon(
                        Icons.center_focus_weak,
                        size: 40,
                        color: tokens.outline.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Headline & Message
                    Text(
                      "We couldn't reliably analyze this",
                      textAlign: TextAlign.center,
                      style: AppTypography.h3.copyWith(
                        color: tokens.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'The image provided lacks the necessary clarity for a confident assessment. To ensure accurate results, we need a better look.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Bento-style Guidance Guidelines
                    _buildGuidelineTile(
                      tokens,
                      icon: Icons.lightbulb_outline,
                      title: 'Ensure bright, natural lighting',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGuidelineTile(
                      tokens,
                      icon: Icons.crop_free,
                      title: 'Keep the subject in sharp focus',
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildGuidelineTile(
                      tokens,
                      icon: Icons.pan_tool_outlined,
                      title: 'Hold the camera steady',
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Primary Action: Try Another Image
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
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.add_a_photo, size: 20),
                        label: Text(
                          'Try Another Image',
                          style: AppTypography.buttonPrimary.copyWith(
                            color: tokens.onPrimary,
                          ),
                        ),
                        onPressed: () => context.go(RoutePaths.scan),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // TrustStrip Disclaimer Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: tokens.outline),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'DermaScan AI is an educational tool and does not provide medical diagnoses. Always consult a certified dermatologist or healthcare professional for medical advice and treatment.',
                        style: AppTypography.caption.copyWith(
                          color: tokens.outline,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineTile(
    AppThemeTokens tokens, {
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tokens.borderGlass),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surfaceVariant,
            ),
            child: Icon(icon, size: 18, color: tokens.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodySmallSemibold.copyWith(
                color: tokens.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
