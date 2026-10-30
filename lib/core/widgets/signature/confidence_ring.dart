import 'dart:math' as math;
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Signature Component #3: ConfidenceRing
/// Circular gauge visualizing model statistical confidence percentage.
/// Strictly conveys AI model confidence, never diagnostic certainty.
class ConfidenceRing extends StatefulWidget {
  final double confidence; // Range 0.0 to 1.0
  final double size;
  final bool showFootnote;
  final bool isAnimated;

  const ConfidenceRing({
    super.key,
    required this.confidence,
    this.size = 140.0,
    this.showFootnote = true,
    this.isAnimated = true,
  });

  @override
  State<ConfidenceRing> createState() => _ConfidenceRingState();
}

class _ConfidenceRingState extends State<ConfidenceRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.confidence.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.isAnimated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ConfidenceRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedConfidence = widget.confidence.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final animatedVal = widget.isAnimated ? _animation.value : clampedConfidence;
            final currentPercent = (animatedVal * 100).round();

            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _ConfidenceRingPainter(progress: animatedVal),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentPercent%',
                        style: AppTypography.h1.copyWith(
                          fontSize: widget.size * 0.24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'CONFIDENCE',
                        style: AppTypography.overline.copyWith(
                          fontSize: widget.size * 0.08,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showFootnote) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Model confidence does not indicate diagnostic certainty.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfidenceRingPainter extends CustomPainter {
  final double progress;

  _ConfidenceRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    // 1. Background Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.borderSubdued;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Progress Arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppColors.primary,
          AppColors.secondaryLight,
          AppColors.softMint,
          AppColors.primary,
        ],
        stops: [0.0, 0.45, 0.85, 1.0],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfidenceRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
