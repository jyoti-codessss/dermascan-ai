import 'dart:io';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen matching Stitch Analysis Result design (4fa266f3cd794e5ca1ab2ecab14302fe).
class AnalysisResultScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final String conditionName;
  final int confidencePercent;

  const AnalysisResultScreen({
    super.key,
    this.imagePath = '',
    this.conditionName = 'ACNE VULGARIS',
    this.confidencePercent = 87,
  });

  @override
  ConsumerState<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  bool _isCharacteristicsExpanded = false;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image & Result Hero Card
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                  color: tokens.surfaceVariant,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.imagePath.isNotEmpty && File(widget.imagePath).existsSync())
                      Image.file(File(widget.imagePath), fit: BoxFit.cover)
                    else
                      Container(
                        color: tokens.surfaceVariant,
                        child: Center(
                          child: Icon(
                            Icons.healing_outlined,
                            size: 64,
                            color: tokens.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    // Gradient overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              tokens.background.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Result and Confidence Badge
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ANALYSIS COMPLETE',
                                  style: AppTypography.captionMedium.copyWith(
                                    color: tokens.primary,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Most consistent with',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: tokens.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  widget.conditionName,
                                  style: AppTypography.h2.copyWith(
                                    color: tokens.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Confidence Ring
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.surfaceGlass,
                              border: Border.all(color: tokens.borderGlass),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: CircularProgressIndicator(
                                    value: widget.confidencePercent / 100.0,
                                    strokeWidth: 4,
                                    backgroundColor: tokens.outline.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
                                  ),
                                ),
                                Text(
                                  '${widget.confidencePercent}%',
                                  style: AppTypography.labelBold.copyWith(
                                    color: tokens.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // TrustStrip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tokens.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: tokens.outline),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'AI-generated information · Not a medical diagnosis',
                        style: AppTypography.caption.copyWith(
                          color: tokens.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // What it may mean (Glass Card)
              Container(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science_outlined, color: tokens.primary, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'What it may mean',
                          style: AppTypography.h3.copyWith(color: tokens.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Based on visual analysis, the features in your image are most commonly associated with ${widget.conditionName}. This typically involves blockages and inflammation of hair follicles and their accompanying sebaceous gland.',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Expandable characteristics
                    Container(
                      decoration: BoxDecoration(
                        color: tokens.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isCharacteristicsExpanded = !_isCharacteristicsExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Common Characteristics',
                                    style: AppTypography.bodySmallSemibold.copyWith(
                                      color: tokens.onSurface,
                                    ),
                                  ),
                                  Icon(
                                    _isCharacteristicsExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: tokens.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_isCharacteristicsExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                0,
                                AppSpacing.md,
                                AppSpacing.sm,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildBulletPoint(tokens, 'Comedones (blackheads and whiteheads)'),
                                  _buildBulletPoint(tokens, 'Papules (small red bumps)'),
                                  _buildBulletPoint(tokens, 'Pustules (bumps with pus)'),
                                  _buildBulletPoint(tokens, 'Often found on face, chest, or back'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // What you can do next Section
              Text(
                'What you can do next',
                style: AppTypography.h3.copyWith(color: tokens.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.primary.withValues(alpha: 0.15),
                            ),
                            child: Icon(Icons.water_drop_outlined, color: tokens.primary, size: 18),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'General Care',
                            style: AppTypography.bodySmallSemibold.copyWith(
                              color: tokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Maintain a gentle cleansing routine. Avoid harsh scrubbing.',
                            style: AppTypography.caption.copyWith(
                              color: tokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.tertiary.withValues(alpha: 0.15),
                            ),
                            child: Icon(Icons.visibility_outlined, color: tokens.tertiary, size: 18),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Monitor Changes',
                            style: AppTypography.bodySmallSemibold.copyWith(
                              color: tokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep track of evolution. If symptoms worsen, consult a doctor.',
                            style: AppTypography.caption.copyWith(
                              color: tokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Need Professional Care Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tokens.surfaceVariant,
                      tokens.surface,
                    ],
                  ),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need professional care?',
                      style: AppTypography.h3.copyWith(color: tokens.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find board-certified dermatologists near your location for a definitive diagnosis and personalized treatment plan.',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
                          'Find nearby care',
                          style: AppTypography.buttonPrimary.copyWith(
                            color: tokens.onPrimary,
                          ),
                        ),
                        onPressed: () => context.push(RoutePaths.nearbyCare),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // View Full Details CTA
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.primary,
                    side: BorderSide(color: tokens.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: Text(
                    'View Detailed Clinical Breakdown',
                    style: AppTypography.buttonPrimary.copyWith(
                      color: tokens.primary,
                    ),
                  ),
                  onPressed: () => context.push(
                    RoutePaths.analysisDetails,
                    extra: {
                      'imagePath': widget.imagePath,
                      'conditionName': widget.conditionName,
                      'confidencePercent': widget.confidencePercent,
                    },
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(AppThemeTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: tokens.primary, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: tokens.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
