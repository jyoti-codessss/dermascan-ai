import 'dart:io';

import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Image Preview screen matching Stitch design (95b8ded64f714d3b9db889c552e294f2).
/// Displays the ACTUAL captured or gallery-selected image.
class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final file = File(imagePath);
    final fileExists = file.existsSync();

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
          'DermaScan AI',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background (Stitch)
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.ambientGlow1,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.ambientGlow2,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Header (Stitch)
                  Text(
                    'Review Image',
                    style: AppTypography.h1.copyWith(
                      color: tokens.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Does this clearly show the affected skin area?',
                    style: AppTypography.bodyMedium.copyWith(
                      color: tokens.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Image Container (Stitch glassmorphic card with real image)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: tokens.borderGlass,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.primary.withValues(alpha: 0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: fileExists
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 64,
                                      color: tokens.outline,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Image file not found',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: tokens.outline,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      imagePath,
                                      style: AppTypography.caption.copyWith(
                                        color: tokens.outline,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Action Buttons (Stitch: Retake + Use Image)
                  Row(
                    children: [
                      // Retake (Secondary)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: tokens.onSurface,
                              side: BorderSide(
                                color: tokens.borderGlass,
                              ),
                              backgroundColor: tokens.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            icon: const Icon(Icons.replay, size: 20),
                            label: const Text('Retake'),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Use Image (Primary)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.primary,
                              foregroundColor: tokens.onPrimary,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 20),
                            label: Text(
                              'Use Image',
                              style: AppTypography.buttonPrimary.copyWith(
                                color: tokens.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: fileExists
                                ? () {
                                    context.push(
                                      RoutePaths.imageQualityCheck,
                                      extra: imagePath,
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Warning helper (Stitch)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: tokens.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: tokens.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: tokens.warning,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Ensure the image is well-lit and in focus. Blurry images may result in inaccurate analysis.',
                            style: AppTypography.caption.copyWith(
                              color: tokens.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
