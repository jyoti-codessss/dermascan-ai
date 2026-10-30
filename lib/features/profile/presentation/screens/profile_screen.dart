import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/features/analysis/presentation/providers/analysis_history_provider.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile screen matching Stitch layout (74e6687c899a451091be268671f3a97e).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.displayName ?? '—';
    final userEmail = user?.email ?? '—';
    final history = ref.watch(analysisHistoryProvider);
    final totalAnalyses = history.length;
    // Streak: consecutive calendar days with at least one scan
    final streakDays = _calculateStreak(history.map((r) => r.scannedAt).toList());

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surfaceGlass,
        elevation: 0,
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
              // User Info Card (Bento Header)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.primary.withValues(alpha: 0.15),
                            border: Border.all(color: tokens.primary, width: 2),
                          ),
                          child: Icon(Icons.person, size: 36, color: tokens.primary),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: AppTypography.h3.copyWith(
                                  color: tokens.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userEmail,
                                style: AppTypography.caption.copyWith(
                                  color: tokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Status & Streak Sub-Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: tokens.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STATUS',
                                style: AppTypography.captionMedium.copyWith(
                                  color: tokens.outline,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.verified, size: 16, color: tokens.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Skin Journey Active',
                                    style: AppTypography.captionMedium.copyWith(
                                      color: tokens.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'STREAK',
                                style: AppTypography.captionMedium.copyWith(
                                  color: tokens.outline,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                streakDays > 0 ? '$streakDays ${streakDays == 1 ? 'Day' : 'Days'}' : '—',
                                style: AppTypography.bodySmallSemibold.copyWith(
                                  color: streakDays > 0 ? tokens.success : tokens.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Total Analyses Stats Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL ANALYSES',
                          style: AppTypography.captionMedium.copyWith(
                            color: tokens.outline,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalAnalyses',
                          style: AppTypography.h1.copyWith(
                            color: tokens.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalAnalyses == 0
                              ? 'No scans yet'
                              : '$totalAnalyses total scan${totalAnalyses == 1 ? '' : 's'}',
                          style: AppTypography.captionMedium.copyWith(
                            color: tokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.query_stats,
                      size: 48,
                      color: tokens.primary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Section Navigation List (Personal Info, Notifications, Privacy, Settings)
              Container(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  children: [
                    _buildNavTile(
                      tokens,
                      icon: Icons.person_outline,
                      title: 'Personal Info',
                      subtitle: 'Manage your account details',
                      onTap: () => context.push(RoutePaths.personalInfo),
                    ),
                    Divider(color: tokens.borderGlass, height: 1),
                    _buildNavTile(
                      tokens,
                      icon: Icons.notifications_none_outlined,
                      title: 'Notifications',
                      subtitle: 'Alerts and scan reminders',
                      onTap: () => context.push(RoutePaths.notifications),
                    ),
                    Divider(color: tokens.borderGlass, height: 1),
                    _buildNavTile(
                      tokens,
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Data Consent',
                      subtitle: 'Data control, retention, and permissions',
                      onTap: () => context.push(RoutePaths.privacy),
                    ),
                    Divider(color: tokens.borderGlass, height: 1),
                    _buildNavTile(
                      tokens,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'Theme, appearance, and preferences',
                      onTap: () => context.push(RoutePaths.settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                    side: BorderSide(color: tokens.danger.withValues(alpha: 0.3)),
                    backgroundColor: tokens.danger.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    'LOGOUT',
                    style: AppTypography.buttonPrimary.copyWith(
                      color: tokens.danger,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).logout();
                    context.go(RoutePaths.login);
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile(
    AppThemeTokens tokens, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.primary.withValues(alpha: 0.10),
              ),
              child: Icon(icon, color: tokens.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMediumSemibold.copyWith(
                      color: tokens.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: tokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: tokens.outline),
          ],
        ),
      ),
    );
  }

  /// Calculates consecutive calendar days from most recent scan going backward.
  /// Deduplicates multiple scans per day so multiple photos in a single day count as 1 streak day.
  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final uniqueDays = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final mostRecent = uniqueDays.first;
    if (mostRecent.isBefore(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDay = mostRecent;
    for (final day in uniqueDays) {
      if (day == expectedDay) {
        streak++;
        expectedDay = expectedDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
