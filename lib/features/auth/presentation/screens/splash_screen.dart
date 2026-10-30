import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/signature/skin_orb.dart';

/// Splash screen matching Stitch Mobile Design (b363ca92ecd7487aaab649de03c6801a).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (mounted) {
      context.go(RoutePaths.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131B),
      body: Stack(
        children: [
          // Background Gradient Ambience (Stitch #b363ca92ecd7487aaab649de03c6801a)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    Color(0x1F4B8EFF), // primary-container/10
                    Color(0xFF10131B), // background
                    Color(0xFF10131B),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  // SkinOrb Central Element
                  const Expanded(
                    child: Center(
                      child: SkinOrb(
                        size: SkinOrbSize.large,
                        customSize: 192,
                        isAnimated: true,
                      ),
                    ),
                  ),
                  // Brand Footer
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: AppTypography.h1.copyWith(
                            fontFamily: AppTypography.displayFontFamily,
                            color: const Color(0xFFE0E2ED),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Precision Skin Intelligence',
                          style: AppTypography.bodyMedium.copyWith(
                            color: const Color(0xFFC1C6D7).withValues(alpha: 0.70),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'v${AppConstants.appVersion}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
