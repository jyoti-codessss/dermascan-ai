import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Privacy & Security Screen matching Stitch design (257d94fa0e7b4e3786146d62a72cfdd5).
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _locationServices = true;

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
          'Privacy & Security',
          style: AppTypography.h3.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              Text(
                'Data & Permissions',
                style: AppTypography.h2.copyWith(color: tokens.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your data permissions and understand how we protect your dermatological records.',
                style: AppTypography.bodySmall.copyWith(
                  color: tokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Featured Card: End-to-End Encryption
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.primary.withValues(alpha: 0.15),
                        border: Border.all(color: tokens.primary.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.enhanced_encryption, color: tokens.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End-to-End Encryption',
                            style: AppTypography.bodyMediumSemibold.copyWith(
                              color: tokens.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All image scans and analytical data are encrypted at rest using AES-256 and in transit via TLS 1.3. Your medical records remain mathematically inaccessible to unauthorized parties.',
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

              const SizedBox(height: AppSpacing.md),

              // Location Services Toggle Card
              Container(
                width: double.infinity,
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
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.surfaceVariant,
                              ),
                              child: Icon(Icons.location_on, color: tokens.secondary, size: 18),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Location Services',
                              style: AppTypography.bodyMediumSemibold.copyWith(
                                color: tokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _locationServices,
                          activeThumbColor: tokens.primary,
                          onChanged: (val) => setState(() => _locationServices = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We use your location to identify nearby dermatologists and calculate local UV index risks for contextual analysis.',
                      style: AppTypography.caption.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Image Data Retention Card
              Container(
                width: double.infinity,
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
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.surfaceVariant,
                          ),
                          child: Icon(Icons.storage, color: tokens.secondary, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Image Data Retention',
                          style: AppTypography.bodyMediumSemibold.copyWith(
                            color: tokens.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Control how long your diagnostic images are retained for longitudinal tracking and comparative progress.',
                      style: AppTypography.caption.copyWith(
                        color: tokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: tokens.borderGlass),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Manage Storage & Retention',
                            style: AppTypography.captionMedium.copyWith(
                              color: tokens.onSurface,
                            ),
                          ),
                          Icon(Icons.arrow_forward, size: 16, color: tokens.outline),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Danger Zone: Delete Account Data Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.danger.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete Account Data',
                      style: AppTypography.bodyMediumSemibold.copyWith(
                        color: tokens.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permanently erase all your scans, history timeline, and clinical metadata. This action is irreversible.',
                      style: AppTypography.caption.copyWith(
                        color: tokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.danger,
                        side: BorderSide(color: tokens.danger.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Initiate Data Deletion',
                        style: AppTypography.buttonPrimary.copyWith(
                          color: tokens.danger,
                          fontSize: 13,
                        ),
                      ),
                    ),
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
}
