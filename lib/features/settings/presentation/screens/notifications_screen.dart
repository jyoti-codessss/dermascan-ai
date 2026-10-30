import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifications Screen matching Stitch layout (2cf60e3ac9854414b248d616fd264624).
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _analysisUpdates = true;
  bool _careReminders = false;

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.primary),
            onPressed: () => context.push(RoutePaths.settings),
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
              // Notification preferences Bento Cards
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Analysis updates',
                                style: AppTypography.bodySmallSemibold.copyWith(
                                  color: tokens.onSurface,
                                ),
                              ),
                              Switch(
                                value: _analysisUpdates,
                                activeThumbColor: tokens.primary,
                                onChanged: (v) => setState(() => _analysisUpdates = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get notified when a new scan analysis is complete.',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Care reminders',
                                style: AppTypography.bodySmallSemibold.copyWith(
                                  color: tokens.onSurface,
                                ),
                              ),
                              Switch(
                                value: _careReminders,
                                activeThumbColor: tokens.primary,
                                onChanged: (v) => setState(() => _careReminders = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Daily reminders for skin care treatments and check-ins.',
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

              const SizedBox(height: AppSpacing.lg),

              // Recent Notifications Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent',
                    style: AppTypography.h3.copyWith(color: tokens.onSurface),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mark all as read',
                      style: AppTypography.captionMedium.copyWith(
                        color: tokens.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Notification Items
              _buildNotificationItem(
                tokens,
                icon: Icons.summarize_outlined,
                title: 'Analysis Complete',
                time: '2m ago',
                description:
                    'Your recent scan analysis for "Left Forearm" is ready to review. No concerning changes detected.',
                isUnread: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildNotificationItem(
                tokens,
                icon: Icons.medication_outlined,
                title: 'Care Reminder',
                time: '4h ago',
                description: 'Time to apply evening moisturizer to treated areas.',
                isUnread: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildNotificationItem(
                tokens,
                icon: Icons.security_update_good,
                title: 'System Update',
                time: 'Yesterday',
                description:
                    'DermaScan AI has been updated to version 2.4. New AI models included for better clinical accuracy.',
                isUnread: false,
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    AppThemeTokens tokens, {
    required IconData icon,
    required String title,
    required String time,
    required String description,
    required bool isUnread,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? tokens.primary.withValues(alpha: 0.4) : tokens.borderGlass,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isUnread)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(color: tokens.primary),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnread
                        ? tokens.primary.withValues(alpha: 0.15)
                        : tokens.surfaceVariant,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isUnread ? tokens.primary : tokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: AppTypography.bodySmallSemibold.copyWith(
                              color: tokens.onSurface,
                            ),
                          ),
                          Text(
                            time,
                            style: AppTypography.caption.copyWith(
                              color: tokens.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
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
          ),
        ],
      ),
    );
  }
}
