import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/features/nearby_care/domain/nearby_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Provider Details Screen — driven by a real PlaceResult passed via route extra.
/// If no provider is passed, shows a "provider not found" state.
class ProviderDetailsScreen extends ConsumerWidget {
  final PlaceResult? provider;

  const ProviderDetailsScreen({
    super.key,
    this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    if (provider == null) {
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
            'Provider Details',
            style: AppTypography.h3.copyWith(color: tokens.primary, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_outlined, size: 64, color: tokens.outline),
              const SizedBox(height: AppSpacing.md),
              Text('No provider selected.', style: AppTypography.h3.copyWith(color: tokens.onSurface)),
              const SizedBox(height: 4),
              Text(
                'Go back and select a provider from the list.',
                style: AppTypography.bodySmall.copyWith(color: tokens.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final item = provider!;

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
          'Provider Details',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Profile Section
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.primary.withValues(alpha: 0.15),
                        border: Border.all(color: tokens.primary, width: 2),
                      ),
                      child: Icon(Icons.medical_services_outlined, size: 52, color: tokens.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: tokens.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.background, width: 2),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                item.name,
                style: AppTypography.h2.copyWith(
                  color: tokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                item.address,
                style: AppTypography.bodySmall.copyWith(
                  color: tokens.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Badges: Rating & Distance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tokens.borderGlass),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: tokens.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${item.rating!.toStringAsFixed(1)}${item.userRatingsTotal != null ? ' (${item.userRatingsTotal})' : ''}',
                            style: AppTypography.captionMedium.copyWith(color: tokens.onSurface),
                          ),
                        ],
                      ),
                    ),
                  if (item.rating != null) const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tokens.borderGlass),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: tokens.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${item.distanceKm.toStringAsFixed(1)} km away',
                          style: AppTypography.captionMedium.copyWith(color: tokens.onSurface),
                        ),
                      ],
                    ),
                  ),
                  if (item.openNow != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (item.openNow! ? tokens.success : tokens.danger).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (item.openNow! ? tokens.success : tokens.danger).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item.openNow! ? 'Open Now' : 'Closed',
                        style: AppTypography.captionMedium.copyWith(
                          color: item.openNow! ? tokens.success : tokens.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(tokens, icon: Icons.call, label: 'Call', onTap: () {}, isPrimary: true),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildActionButton(tokens, icon: Icons.chat_bubble_outline, label: 'Message', onTap: () {}, isPrimary: true),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildActionButton(tokens, icon: Icons.directions_outlined, label: 'Directions', onTap: () {}, isPrimary: false),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Info notice — no hardcoded data
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
                        Icon(Icons.info_outline, color: tokens.primary, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text('About This Provider', style: AppTypography.h3.copyWith(color: tokens.onSurface)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Detailed information such as bio, services, and appointment booking will be available when you connect to a provider directory API.',
                      style: AppTypography.bodySmall.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Book Appointment CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.primary,
                    foregroundColor: tokens.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
                  ),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    'Book Consultation',
                    style: AppTypography.buttonPrimary.copyWith(color: tokens.onPrimary),
                  ),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    AppThemeTokens tokens, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? tokens.primary.withValues(alpha: 0.12)
              : tokens.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? tokens.primary.withValues(alpha: 0.3) : tokens.borderGlass,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isPrimary ? tokens.primary : tokens.onSurface),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.captionMedium.copyWith(
                color: isPrimary ? tokens.primary : tokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
