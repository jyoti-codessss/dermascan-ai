import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Custom painted framing guide overlay for skin area targeting (design.md #18).
class CameraFramingOverlay extends StatelessWidget {
  final String instructionText;

  const CameraFramingOverlay({
    super.key,
    this.instructionText = 'Position skin concern inside the frame',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _FramingOverlayPainter(),
        ),
        Positioned(
          top: 100,
          left: 24,
          right: 24,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: AppRadius.pill,
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.center_focus_weak_rounded,
                    color: AppColors.softMint,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      instructionText,
                      style: AppTypography.captionMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FramingOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final targetWidth = size.width * 0.75;
    final targetHeight = size.height * 0.42;
    final center = Offset(size.width / 2, size.height / 2 - 20);
    final targetRect = Rect.fromCenter(
      center: center,
      width: targetWidth,
      height: targetHeight,
    );
    final targetRRect = RRect.fromRectAndRadius(
      targetRect,
      const Radius.circular(24),
    );

    // Draw dark overlay with transparent cutout window
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(targetRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw glowing border around cutout
    final borderPaint = Paint()
      ..color = AppColors.softMint.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(targetRRect, borderPaint);

    // Draw 4 corner reticle accents
    final reticlePaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;
    final left = targetRect.left;
    final top = targetRect.top;
    final right = targetRect.right;
    final bottom = targetRect.bottom;

    // Top-Left Corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), reticlePaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), reticlePaint);

    // Top-Right Corner
    canvas.drawLine(Offset(right - cornerLength, top), Offset(right, top), reticlePaint);
    canvas.drawLine(Offset(right, top), Offset(right, top + cornerLength), reticlePaint);

    // Bottom-Left Corner
    canvas.drawLine(Offset(left, bottom - cornerLength), Offset(left, bottom), reticlePaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + cornerLength, bottom), reticlePaint);

    // Bottom-Right Corner
    canvas.drawLine(Offset(right - cornerLength, bottom), Offset(right, bottom), reticlePaint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - cornerLength), reticlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
