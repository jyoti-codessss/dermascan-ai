import 'dart:io';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Analysis Details Screen matching Stitch layout (9f8ea28b183e49d097b28859864c8449).
class AnalysisDetailsScreen extends ConsumerWidget {
  final String imagePath;
  final String conditionName;
  final int confidencePercent;

  const AnalysisDetailsScreen({
    super.key,
    this.imagePath = '',
    this.conditionName = 'Acne Vulgaris',
    this.confidencePercent = 87,
  });

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Analysis Details',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: tokens.primary),
            onPressed: () {},
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan image preview card
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                  color: tokens.surfaceVariant,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imagePath.isNotEmpty && File(imagePath).existsSync())
                      Image.file(File(imagePath), fit: BoxFit.cover)
                    else
                      Container(
                        color: tokens.surfaceVariant,
                        child: Center(
                          child: Icon(
                            Icons.biotech_outlined,
                            size: 56,
                            color: tokens.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              tokens.background.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Timestamp',
                                style: AppTypography.caption.copyWith(
                                  color: tokens.outline,
                                ),
                              ),
                              Text(
                                'Today, Live Assessment',
                                style: AppTypography.bodySmallSemibold.copyWith(
                                  color: tokens.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: tokens.surfaceGlass,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: tokens.borderGlass),
                            ),
                            child: Icon(Icons.fullscreen, color: tokens.primary, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // AI Confidence Analysis Block
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Confidence Analysis',
                      style: AppTypography.bodySmallSemibold.copyWith(
                        color: tokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: confidencePercent / 100.0,
                                strokeWidth: 5,
                                backgroundColor: tokens.outline.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
                              ),
                              Text(
                                '$confidencePercent%',
                                style: AppTypography.h3.copyWith(
                                  color: tokens.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$conditionName Detected',
                                style: AppTypography.bodyMediumSemibold.copyWith(
                                  color: tokens.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Visual pattern analysis indicates characteristic dermatological indicators matching clinical dataset criteria.',
                                style: AppTypography.caption.copyWith(
                                  color: tokens.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Clinical Findings Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: tokens.warning, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'What it may mean',
                          style: AppTypography.h3.copyWith(color: tokens.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'The analyzed scan displays visual attributes associated with $conditionName. These typically feature localized follicular involvement and subtle superficial surface texture variations.',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'While this educational overview provides context, an in-person dermatological examination remains the gold standard for clinical confirmation.',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Care & Action Guidelines
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services_outlined, color: tokens.primary, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'General Care & Next Steps',
                          style: AppTypography.h3.copyWith(color: tokens.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCareItem(
                      tokens,
                      'Schedule a formal assessment with a board-certified dermatologist if you note changes in size, color, or shape.',
                    ),
                    _buildCareItem(
                      tokens,
                      'Avoid aggressive physical exfoliants or attempts to extract lesions, which may aggravate inflammation.',
                    ),
                    _buildCareItem(
                      tokens,
                      'Log repeat scans over time in your DermaScan AI history timeline to monitor visual progression.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Find Nearby Care CTA
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
                  icon: const Icon(Icons.location_on, size: 18),
                  label: Text(
                    'Find Nearby Providers',
                    style: AppTypography.buttonPrimary.copyWith(
                      color: tokens.onPrimary,
                    ),
                  ),
                  onPressed: () => context.push(RoutePaths.nearbyCare),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareItem(AppThemeTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: tokens.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: tokens.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
