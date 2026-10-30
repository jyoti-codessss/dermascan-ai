import 'dart:math' as math;
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum SkinOrbSize {
  small(48.0),
  medium(80.0),
  large(140.0),
  hero(200.0);

  final double dimension;
  const SkinOrbSize(this.dimension);
}

/// Signature Component #1: SkinOrb
/// Soft organic circular form with AI gradient, breathing animation,
/// subtle outer glow, and orbital rings.
class SkinOrb extends StatefulWidget {
  final SkinOrbSize size;
  final double? customSize;
  final bool isAnimated;
  final Widget? child;
  final VoidCallback? onTap;

  const SkinOrb({
    super.key,
    this.size = SkinOrbSize.medium,
    this.customSize,
    this.isAnimated = true,
    this.child,
    this.onTap,
  });

  @override
  State<SkinOrb> createState() => _SkinOrbState();
}

class _SkinOrbState extends State<SkinOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SkinOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = widget.customSize ?? widget.size.dimension;

    Widget orbContent = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.isAnimated ? _pulseAnimation.value : 1.0;
        final rotation = widget.isAnimated ? _rotationAnimation.value : 0.0;

        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size(dimension, dimension),
            painter: _SkinOrbPainter(rotation: rotation),
            child: SizedBox(
              width: dimension,
              height: dimension,
              child: Center(child: widget.child),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: orbContent,
      );
    }

    return orbContent;
  }
}

class _SkinOrbPainter extends CustomPainter {
  final double rotation;

  _SkinOrbPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Soft Outer Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondaryLight.withValues(alpha: 0.35),
          AppColors.primaryLight.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glowPaint);

    // 2. Core Gradient Orb
    final coreRadius = radius * 0.72;
    final corePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        radius: 0.9,
        colors: [
          AppColors.softMint,
          AppColors.secondaryLight,
          AppColors.primary,
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

    canvas.drawCircle(center, coreRadius, corePaint);

    // 3. Thin Concentric Orbital Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = SweepGradient(
        colors: [
          AppColors.primaryLight.withValues(alpha: 0.0),
          AppColors.secondaryLight.withValues(alpha: 0.6),
          AppColors.primaryLight.withValues(alpha: 0.8),
          AppColors.softMint.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.88));

    canvas.drawCircle(center, radius * 0.88, ringPaint);

    // 4. Orbital Data Points
    final orbitalPointPaint = Paint()
      ..color = AppColors.softMint.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final double dotAngle1 = rotation;
    final double dotAngle2 = rotation + math.pi;

    final dotPos1 = Offset(
      center.dx + (radius * 0.88) * math.cos(dotAngle1),
      center.dy + (radius * 0.88) * math.sin(dotAngle1),
    );
    final dotPos2 = Offset(
      center.dx + (radius * 0.88) * math.cos(dotAngle2),
      center.dy + (radius * 0.88) * math.sin(dotAngle2),
    );

    canvas.drawCircle(dotPos1, 2.5, orbitalPointPaint);
    canvas.drawCircle(dotPos2, 1.8, orbitalPointPaint..color = AppColors.primaryLight);
  }

  @override
  bool shouldRepaint(covariant _SkinOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
