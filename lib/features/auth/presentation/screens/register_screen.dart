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

/// Register screen matching Stitch Mobile Design (8545eb9e1be24fdd9300e727d534684e).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy to continue.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFE0E2ED)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mobile Brand Header (Stitch 8545eb9e1be24fdd9300e727d534684e)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xFFADC6FF),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DermaScan AI',
                          style: AppTypography.h2.copyWith(
                            fontFamily: AppTypography.displayFontFamily,
                            color: const Color(0xFFE0E2ED),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Glassmorphic Card Container
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
                            'Create an account',
                            style: AppTypography.h2.copyWith(
                              fontFamily: AppTypography.displayFontFamily,
                              color: const Color(0xFFE0E2ED),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join our platform for intelligent diagnostics.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: const Color(0xFFC1C6D7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Full Name Field
                          AppTextField(
                            label: 'Full Name',
                            hintText: 'Dr. Jane Doe',
                            controller: _nameController,
                            validator: (val) => AuthInputValidators.validateRequired(val, 'full name'),
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF8B90A0),
                              size: 20,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Email Field
                          AppTextField(
                            label: 'Professional Email',
                            hintText: 'jane.doe@clinic.com',
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
                            textInputAction: TextInputAction.next,
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Confirm Password Field
                          AppPasswordField(
                            label: 'Confirm Password',
                            controller: _confirmPasswordController,
                            validator: (val) => AuthInputValidators.validateConfirmPassword(
                              val,
                              _passwordController.text,
                            ),
                            onSubmitted: (_) => _onRegister(),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  activeColor: const Color(0xFFADC6FF),
                                  checkColor: const Color(0xFF002E69),
                                  onChanged: (val) {
                                    setState(() {
                                      _acceptedTerms = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFFC1C6D7),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: const Color(0xFFADC6FF),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: const Color(0xFFADC6FF),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Create Account CTA Button
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
                              onPressed: isLoading ? null : _onRegister,
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
                                          'Create account',
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

                          // Login Footer Link
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: const Color(0xFFC1C6D7),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: const Color(0xFFADC6FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.pop();
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

                    // Medical Disclaimer Notice
                    const MedicalDisclaimerCard(isCompact: true),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
