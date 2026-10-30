import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/utils/validators.dart';
import 'package:dermascan_ai/core/widgets/cards/medical_disclaimer_card.dart';
import 'package:dermascan_ai/core/widgets/inputs/app_password_field.dart';
import 'package:dermascan_ai/core/widgets/inputs/app_text_field.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Login screen matching Stitch Mobile Design (a172ac9a010f4696be64241b2e8e670d).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'doctor@clinic.com');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Authenticating;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        context.go(RoutePaths.dashboard);
      } else if (next is AuthFailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF10131B),
      body: Stack(
        children: [
          // Top-left and bottom-right atmospheric background glows
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x334B8EFF),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1F3131C0),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),

                        // Logo / Brand Header (Stitch a172ac9a010f4696be64241b2e8e670d)
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0x1A111827),
                                  borderRadius: AppRadius.lg,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.manage_search_rounded,
                                    size: 36,
                                    color: Color(0xFFADC6FF),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'DermaScan AI',
                                style: AppTypography.h1.copyWith(
                                  fontFamily: AppTypography.displayFontFamily,
                                  color: const Color(0xFFE0E2ED),
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Professional Dermatological Analysis',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFFC1C6D7),
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Login Form Glass Card (Stitch Specs)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0x991C2028),
                            borderRadius: AppRadius.card,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Welcome back',
                                style: AppTypography.h2.copyWith(
                                  fontFamily: AppTypography.displayFontFamily,
                                  color: const Color(0xFFE0E2ED),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Email Field
                              AppTextField(
                                label: 'Email Address',
                                hintText: 'doctor@clinic.com',
                                controller: _emailController,
                                validator: AuthInputValidators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.mail_outline_rounded,
                                  color: Color(0xFF8B90A0),
                                  size: 20,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Password Field
                              AppPasswordField(
                                controller: _passwordController,
                                validator: AuthInputValidators.validatePassword,
                                onSubmitted: (_) => _onLogin(),
                              ),

                              // Forgot Password Action
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.push(RoutePaths.forgotPassword);
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFFADC6FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Stitch Primary Login Action Button
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFADC6FF),
                                    foregroundColor: const Color(0xFF002E69),
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadius.button,
                                    ),
                                  ),
                                  onPressed: isLoading ? null : _onLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002E69)),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Sign In',
                                              style: AppTypography.buttonPrimary.copyWith(
                                                color: const Color(0xFF002E69),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Color(0xFF002E69),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(child: Divider(color: Color(0xFF414755))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                    child: Text(
                                      'Or continue with',
                                      style: AppTypography.caption.copyWith(
                                        color: const Color(0xFF8B90A0),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider(color: Color(0xFF414755))),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Social Login Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1C2028),
                                        side: const BorderSide(color: Color(0xFF414755)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: AppRadius.button,
                                        ),
                                      ),
                                      onPressed: () {
                                        ref.read(authNotifierProvider.notifier).loginWithGoogle();
                                      },
                                      child: Text(
                                        'G  Google',
                                        style: AppTypography.bodyMediumSemibold.copyWith(
                                          color: const Color(0xFFE0E2ED),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1C2028),
                                        side: const BorderSide(color: Color(0xFF414755)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: AppRadius.button,
                                        ),
                                      ),
                                      onPressed: () {
                                        ref.read(authNotifierProvider.notifier).login('doctor@clinic.com', 'Password123!');
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.flash_on_rounded, color: Color(0xFFADC6FF), size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Quick Demo',
                                            style: AppTypography.bodyMediumSemibold.copyWith(
                                              color: const Color(0xFFE0E2ED),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              // Register Link
                              Center(
                                child: Text.rich(
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: const Color(0xFFC1C6D7),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Request Access',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: const Color(0xFFADC6FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            context.push(RoutePaths.register);
                                          },
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Medical Disclaimer Card
                        const MedicalDisclaimerCard(isCompact: true),

                        const SizedBox(height: AppSpacing.lg),

                        // Trust Indicators
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, color: Color(0x998B90A0), size: 20),
                            SizedBox(width: 16),
                            Icon(Icons.health_and_safety_outlined, color: Color(0x998B90A0), size: 20),
                            SizedBox(width: 16),
                            Icon(Icons.verified_outlined, color: Color(0x998B90A0), size: 20),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
