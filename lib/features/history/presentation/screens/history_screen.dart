import 'dart:io';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/widgets/feedback/app_empty_state.dart';
import 'package:dermascan_ai/features/analysis/domain/analysis_record.dart';
import 'package:dermascan_ai/features/analysis/presentation/providers/analysis_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// History Screen — reads from real persisted AnalysisHistoryNotifier.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final records = ref.watch(analysisHistoryProvider);

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
          'Analysis History',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: records.isEmpty
            ? AppEmptyState(
                icon: Icons.history_rounded,
                title: 'No Scans Yet',
                description:
                    'Your completed skin scans will appear here. Start by scanning a skin concern.',
                actionLabel: 'Start a Scan',
                onAction: () => context.go(RoutePaths.scan),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Skin Journey',
                      style: AppTypography.h2.copyWith(color: tokens.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${records.length} scan${records.length == 1 ? '' : 's'} recorded',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return _buildTimelineCard(context, tokens, records[index]);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    AppThemeTokens tokens,
    AnalysisRecord record,
  ) {
    final dateLabel =
        DateFormat('MMM d, yyyy • HH:mm').format(record.scannedAt).toUpperCase();

    // Assign pill colour based on confidence band
    final Color tagColor;
    if (record.confidencePercent >= 80) {
      tagColor = const Color(0xFF81C784); // green
    } else if (record.confidencePercent >= 60) {
      tagColor = const Color(0xFFFFB74D); // amber
    } else {
      tagColor = const Color(0xFFEF5350); // red
    }

    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: tokens.borderGlass),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Condition Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dateLabel,
                  style: AppTypography.captionMedium.copyWith(
                    color: tokens.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: tagColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.conditionName,
                      style: AppTypography.captionMedium.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Content Row: Thumbnail & Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: record.imagePath.isNotEmpty &&
                          File(record.imagePath).existsSync()
                      ? Image.file(
                          File(record.imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: tokens.surfaceVariant,
                          child: Icon(
                            Icons.healing_outlined,
                            color: tokens.primary.withValues(alpha: 0.5),
                            size: 30,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.summary.isNotEmpty)
                      Text(
                        record.summary,
                        style: AppTypography.caption.copyWith(
                          color: tokens.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confidence: ${record.confidencePercent}%',
                          style: AppTypography.captionMedium.copyWith(
                            color: tokens.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.push(
                              RoutePaths.analysisDetails,
                              extra: {
                                'imagePath': record.imagePath,
                                'conditionName': record.conditionName,
                                'confidencePercent': record.confidencePercent,
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'View Report',
                                style: AppTypography.captionMedium.copyWith(
                                  color: tokens.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.arrow_forward, size: 14, color: tokens.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
