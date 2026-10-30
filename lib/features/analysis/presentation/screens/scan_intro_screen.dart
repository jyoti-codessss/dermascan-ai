import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/widgets/cards/medical_disclaimer_card.dart';
import 'package:dermascan_ai/core/widgets/signature/skin_orb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Scan Introduction screen matching Stitch design (a16212df3e6840998c13f2e7d572a27d).
class ScanIntroScreen extends ConsumerWidget {
  const ScanIntroScreen({super.key});

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
      body: Stack(
        children: [
          // Ambient Background Lighting
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.ambientGlow1,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.ambientGlow2,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Header Section (Stitch)
                  Text(
                    'Scan your skin',
                    style: AppTypography.h1.copyWith(
                      color: tokens.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Our advanced AI models analyze visual patterns to detect anomalies. Ensure clear, well-lit images for the highest accuracy.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: tokens.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // SkinOrb Focal Point (Stitch)
                  const SkinOrb(
                    size: SkinOrbSize.large,
                    customSize: 180,
                    isAnimated: true,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Primary Actions (Stitch: Take Photo + Upload Image)
                  Row(
                    children: [
                      // Take Photo Button
                      Expanded(
                        child: Material(
                          color: tokens.primary,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              context.push(RoutePaths.cameraCapture);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo_camera,
                                    size: 19,
                                    color: tokens.onPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Take Photo',
                                      style: TextStyle(
                                        color: tokens.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        fontFamily: AppTypography.primaryFontFamily,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Upload Image Button
                      Expanded(
                        child: Material(
                          color: tokens.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 2048,
                                maxHeight: 2048,
                                imageQuality: 90,
                              );
                              if (image != null && context.mounted) {
                                context.push(RoutePaths.imagePreview, extra: image.path);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tokens.borderGlass),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 19,
                                    color: tokens.onSurface,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Upload Image',
                                      style: TextStyle(
                                        color: tokens.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: AppTypography.primaryFontFamily,
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Guidance Grid (Stitch Bento Cards)
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.25,
                    children: [
                      _buildGuidelineCard(
                        tokens: tokens,
                        icon: Icons.wb_sunny_outlined,
                        iconColor: tokens.primary,
                        title: 'Good lighting',
                        subtitle: 'Natural light is best',
                      ),
                      _buildGuidelineCard(
                        tokens: tokens,
                        icon: Icons.center_focus_strong,
                        iconColor: tokens.secondary,
                        title: 'Clear focus',
                        subtitle: 'Avoid blurriness',
                      ),
                      _buildGuidelineCard(
                        tokens: tokens,
                        icon: Icons.zoom_in,
                        iconColor: tokens.tertiary,
                        title: 'Area visible',
                        subtitle: 'Center the concern',
                      ),
                      _buildGuidelineCard(
                        tokens: tokens,
                        icon: Icons.filter_b_and_w,
                        iconColor: tokens.warning,
                        title: 'No filters',
                        subtitle: 'Keep it original',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Trust Disclaimer (Stitch)
                  const MedicalDisclaimerCard(isCompact: true),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard({
    required AppThemeTokens tokens,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: tokens.borderGlass),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.surfaceVariant,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: tokens.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: tokens.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
