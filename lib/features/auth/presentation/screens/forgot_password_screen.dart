import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/utils/validators.dart';
import 'package:dermascan_ai/core/widgets/buttons/app_primary_button.dart';
import 'package:dermascan_ai/core/widgets/inputs/app_text_field.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendReset() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authNotifierProvider.notifier)
          .sendPasswordReset(_emailController.text.trim())
          .then((_) {
        setState(() {
          _emailSent = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is Authenticating;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _emailSent
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.mark_email_read_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Check your email',
                          style: AppTypography.h2.copyWith(
                            fontFamily: AppTypography.displayFontFamily,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'We have sent password reset instructions to ${_emailController.text}.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppPrimaryButton(
                          label: 'Back to Sign In',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Forgot Your Password?',
                            style: AppTypography.h2.copyWith(
                              fontFamily: AppTypography.displayFontFamily,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Enter your registered email address and we will send you instructions to reset your password.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            label: 'Email Address',
                            hintText: 'name@example.com',
                            controller: _emailController,
                            validator: AuthInputValidators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppPrimaryButton(
                            label: 'Send Reset Instructions',
                            isLoading: isLoading,
                            onPressed: _onSendReset,
                          ),
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
