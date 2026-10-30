import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/signature/skin_orb.dart';
import '../../../../core/widgets/signature/trust_strip.dart';

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Onboarding screen matching Stitch Mobile Design (ff45839e2b5a4b85bb9aa9fe457b8c00).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Understand your skin health with AI.',
      description:
          'Experience high-precision dermatological analysis powered by advanced machine learning. Fast, accurate, and completely private.',
      icon: Icons.camera_alt_outlined,
    ),
    OnboardingStep(
      title: 'Understand Your Pattern Results',
      description:
          'Review statistical model patterns, educational condition characteristics, and clear visual indicators.',
      icon: Icons.insights_rounded,
    ),
    OnboardingStep(
      title: 'Find Nearby Care Facilities',
      description:
          'Easily discover certified dermatologists, clinics, and medical centers near your location with direct directions.',
      icon: Icons.map_outlined,
    ),
    OnboardingStep(
      title: 'Privacy First & AI Disclaimer',
      description:
          'Your images remain protected. AI results are strictly educational and do not replace professional medical evaluations.',
      icon: Icons.shield_outlined,
    ),
  ];

  void _onNext() {
    if (_currentIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RoutePaths.login);
    }
  }

  void _onSkip() {
    context.go(RoutePaths.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentIndex == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF10131B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.adjust_rounded,
              color: Color(0xFFADC6FF),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'DermaScan AI',
              style: AppTypography.h3.copyWith(
                fontFamily: AppTypography.displayFontFamily,
                color: const Color(0xFFADC6FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!isLastStep)
            TextButton(
              onPressed: _onSkip,
              child: Text(
                'Skip',
                style: AppTypography.buttonSecondary.copyWith(
                  color: const Color(0xFF8B90A0),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background Radial Mesh Ambience (Stitch Onboarding)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.4),
                  radius: 0.9,
                  colors: [
                    Color(0x264B8EFF),
                    Color(0xFF10131B),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _steps.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SkinOrb(
                              size: SkinOrbSize.large,
                              customSize: 220,
                              isAnimated: true,
                            ),
                            const SizedBox(height: AppSpacing.xxxl),
                            Text(
                              step.title,
                              style: AppTypography.h1.copyWith(
                                fontFamily: AppTypography.displayFontFamily,
                                color: const Color(0xFFE0E2ED),
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              step.description,
                              style: AppTypography.bodyLarge.copyWith(
                                color: const Color(0xFFC1C6D7),
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (index == _steps.length - 1) ...[
                              const SizedBox(height: AppSpacing.lg),
                              const TrustStrip(),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Pagination Dots & Primary Pill Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      // Stitch Onboarding Pager Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _steps.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == dotIndex ? 32 : 8,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == dotIndex
                                  ? const Color(0xFFADC6FF)
                                  : const Color(0xFF31353D),
                              borderRadius: AppRadius.pill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Stitch Primary CTA Pill
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFADC6FF),
                            foregroundColor: const Color(0xFF002E69),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.pill,
                            ),
                          ),
                          onPressed: _onNext,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastStep ? 'Get Started' : 'Continue',
                                style: AppTypography.buttonPrimary.copyWith(
                                  color: const Color(0xFF002E69),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                color: const Color(0xFF002E69),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
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
