import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Data model for an item in the AnalysisTimeline.
class AnalysisTimelineItemData {
  final String id;
  final String condition;
  final double confidence;
  final DateTime date;
  final String? imageThumbnailUrl;
  final String modelVersion;

  const AnalysisTimelineItemData({
    required this.id,
    required this.condition,
    required this.confidence,
    required this.date,
    this.imageThumbnailUrl,
    this.modelVersion = 'dermascan-v1.0',
  });
}

/// Signature Component #5: AnalysisTimeline
/// Editorial chronological timeline widget connecting skin analyses across time.
class AnalysisTimeline extends StatelessWidget {
  final List<AnalysisTimelineItemData> items;
  final ValueChanged<AnalysisTimelineItemData>? onItemTap;

  const AnalysisTimeline({
    super.key,
    required this.items,
    this.onItemTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        final percent = (item.confidence * 100).round();

        return InkWell(
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          borderRadius: AppRadius.card,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Timeline Track & Node
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      // Timeline Node Circle
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? AppColors.primary : AppColors.secondary,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (index == 0 ? AppColors.primary : AppColors.secondary)
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      // Connecting Line
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: AppColors.border,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // Card Content
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Left Text Information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatDate(item.date),
                                style: AppTypography.captionMedium.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Possible ${item.condition}',
                                style: AppTypography.bodyMediumSemibold.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs + 2,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.infoBackground,
                                      borderRadius: AppRadius.pill,
                                    ),
                                    child: Text(
                                      'Confidence $percent%',
                                      style: AppTypography.captionMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Trailing Action / Arrow
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
