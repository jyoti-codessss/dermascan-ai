import 'dart:io';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/widgets/cards/app_card.dart';
import 'package:dermascan_ai/core/widgets/signature/scan_button.dart';
import 'package:dermascan_ai/core/widgets/signature/skin_orb.dart';
import 'package:dermascan_ai/core/widgets/signature/trust_strip.dart';
import 'package:dermascan_ai/features/analysis/domain/analysis_record.dart';
import 'package:dermascan_ai/features/analysis/presentation/providers/analysis_history_provider.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Dashboard Home Screen with real analysis data.
class DashboardHomeScreen extends ConsumerWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final authState = ref.watch(authNotifierProvider);
    final user = authState is Authenticated ? authState.user : null;
    final greeting = _greeting();
    final history = ref.watch(analysisHistoryProvider);
    final recentRecords = history.take(3).toList();

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surfaceGlass,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'DermaScan AI',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: tokens.onSurface),
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          const SizedBox(width: AppSpacing.xs),
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
              const SizedBox(height: AppSpacing.xs),

              // Hero Greeting Section with SkinOrb
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting${user != null ? ', ${user.displayName.split(' ').first}' : ''} 👋',
                          style: AppTypography.bodyMedium.copyWith(
                            color: tokens.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Let's understand\nyour skin today.",
                          style: AppTypography.h2.copyWith(
                            color: tokens.onSurface,
                            height: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SkinOrb(
                    size: SkinOrbSize.medium,
                    isAnimated: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              const Center(child: TrustStrip()),
              const SizedBox(height: AppSpacing.xl),

              // Signature Scan Button CTA
              ScanButton(
                onPressed: () => context.go(RoutePaths.scan),
                label: 'Start a skin scan',
                subtitle: 'Analyze image for skin condition patterns',
              ),

              const SizedBox(height: AppSpacing.md),

              // AI Chatbot Assistant CTA Card
              AppCard(
                borderRadius: AppRadius.card,
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.push(RoutePaths.chat),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5DD3), Color(0xFF8E82E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.md,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5DD3).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Chat with AI Assistant',
                                  style: AppTypography.bodyMediumSemibold.copyWith(
                                    color: tokens.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5DD3).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Gemini AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6C5DD3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ask questions about skin symptoms & app guidance',
                            style: AppTypography.caption.copyWith(
                              color: tokens.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF6C5DD3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Recent Analysis Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Analysis',
                    style: AppTypography.h3.copyWith(
                      color: tokens.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () => context.push(RoutePaths.history),
                      child: Text(
                        'View All',
                        style: AppTypography.captionMedium.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),

              // Real data or empty state
              if (recentRecords.isEmpty)
                AppCard(
                  borderRadius: AppRadius.card,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () => context.go(RoutePaths.scan),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tokens.primary.withValues(alpha: 0.12),
                          borderRadius: AppRadius.md,
                          border: Border.all(color: tokens.primary.withValues(alpha: 0.25)),
                        ),
                        child: Center(
                          child: Icon(Icons.camera_enhance_outlined, size: 24, color: tokens.primary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No Skin Scans Yet',
                              style: AppTypography.bodyMediumSemibold.copyWith(color: tokens.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scan a skin concern to generate AI analysis history.',
                              style: AppTypography.caption.copyWith(color: tokens.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: tokens.outline),
                    ],
                  ),
                )
              else
                ...recentRecords.map((record) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildRecentCard(context, tokens, record),
                    )),

              const SizedBox(height: AppSpacing.xl),

              // Analysis Timeline Header & Zero/Real State
              Text(
                'Analysis Timeline',
                style: AppTypography.h3.copyWith(color: tokens.onSurface, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: history.isEmpty ? null : () => context.push(RoutePaths.history),
                child: Row(
                  children: [
                    Icon(
                      history.isEmpty ? Icons.history_toggle_off_rounded : Icons.timeline_rounded,
                      color: history.isEmpty ? tokens.outline : tokens.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        history.isEmpty
                            ? 'Your scan timeline will appear here after your first skin analysis.'
                            : '${history.length} scan${history.length == 1 ? '' : 's'} recorded — tap to view full history.',
                        style: AppTypography.caption.copyWith(color: tokens.onSurfaceVariant),
                      ),
                    ),
                    if (history.isNotEmpty)
                      Icon(Icons.chevron_right_rounded, color: tokens.outline),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Nearby Care Quick Card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.push(RoutePaths.nearbyCare),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: tokens.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_hospital_outlined, color: tokens.primary, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Care Nearby',
                            style: AppTypography.bodyMediumSemibold.copyWith(color: tokens.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Locate dermatologists & hospitals near you',
                            style: AppTypography.caption.copyWith(color: tokens.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: tokens.outline),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCard(BuildContext context, AppThemeTokens tokens, AnalysisRecord record) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: () => context.push(
        RoutePaths.analysisDetails,
        extra: {
          'imagePath': record.imagePath,
          'conditionName': record.conditionName,
          'confidencePercent': record.confidencePercent,
        },
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 52,
              height: 52,
              child: record.imagePath.isNotEmpty && File(record.imagePath).existsSync()
                  ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                  : Container(
                      color: tokens.surfaceVariant,
                      child: Icon(Icons.healing_outlined, color: tokens.primary.withValues(alpha: 0.5), size: 26),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.conditionName,
                  style: AppTypography.bodySmallSemibold.copyWith(color: tokens.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(record.scannedAt),
                  style: AppTypography.caption.copyWith(color: tokens.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${record.confidencePercent}%',
              style: AppTypography.captionMedium.copyWith(
                color: tokens.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
