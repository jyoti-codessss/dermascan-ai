import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/core/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AppPasswordField({
    super.key,
    this.label = 'Password',
    this.hintText = '••••••••',
    this.controller,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
