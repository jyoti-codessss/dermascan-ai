import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Image Quality Check screen matching Stitch design (b0e4c237904245df8bf3d292c90f87f3).
///
/// Performs actual client-side image validation:
/// - File readability and existence
/// - Non-empty, valid file size (>10KB and <25MB)
/// - Valid supported image format (.jpg, .jpeg, .png, .webp, .heic)
/// - Minimum resolution check (width >= 200px and height >= 200px)
/// - Decodable, non-corrupted image stream
class ImageQualityCheckScreen extends StatefulWidget {
  final String imagePath;

  const ImageQualityCheckScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ImageQualityCheckScreen> createState() =>
      _ImageQualityCheckScreenState();
}

class _ImageQualityCheckScreenState extends State<ImageQualityCheckScreen> {
  late final File _file;
  bool _fileReady = false;
  bool _userConfirmed = false;

  // Real client-side checks
  bool? _checkFileReadable;
  bool? _checkFileSizeOk;
  bool? _checkExtensionOk;
  bool? _checkResolutionOk;
  int? _imageWidth;
  int? _imageHeight;
  String? _fileSizeText;

  @override
  void initState() {
    super.initState();
    _file = File(widget.imagePath);
    _runValidationChecks();
  }

  Future<void> _runValidationChecks() async {
    final exists = _file.existsSync();
    if (!exists) {
      if (mounted) {
        setState(() {
          _checkFileReadable = false;
          _checkFileSizeOk = false;
          _checkExtensionOk = false;
          _checkResolutionOk = false;
          _fileReady = true;
        });
      }
      return;
    }

    try {
      final bytes = await _file.readAsBytes();
      final sizeInBytes = bytes.length;
      final sizeInKb = sizeInBytes / 1024;
      final ext = widget.imagePath.split('.').last.toLowerCase();
      final validExts = ['jpg', 'jpeg', 'png', 'webp', 'heic'];

      final extOk = validExts.contains(ext);
      final sizeOk = sizeInBytes > 10000 && sizeInBytes < 25000000; // 10KB to 25MB

      // Decode image dimensions to verify it is genuinely a valid image file
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        completer.complete(img);
      });
      final ui.Image decodedImage = await completer.future;

      final resOk = decodedImage.width >= 200 && decodedImage.height >= 200;

      if (mounted) {
        setState(() {
          _checkFileReadable = true;
          _checkFileSizeOk = sizeOk;
          _fileSizeText = '${sizeInKb.toStringAsFixed(1)} KB';
          _checkExtensionOk = extOk;
          _imageWidth = decodedImage.width;
          _imageHeight = decodedImage.height;
          _checkResolutionOk = resOk;
          _fileReady = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _checkFileReadable = true;
          _checkFileSizeOk = false;
          _checkExtensionOk = false;
          _checkResolutionOk = false;
          _fileReady = true;
        });
      }
    }
  }

  bool get _allChecksPassed =>
      (_checkFileReadable == true) &&
      (_checkFileSizeOk == true) &&
      (_checkExtensionOk == true) &&
      (_checkResolutionOk == true);

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Stack(
        children: [
          // Ambient glow (Stitch)
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.ambientGlow1,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Header (Stitch)
                  Text(
                    'Image Quality Check',
                    style: AppTypography.h1.copyWith(
                      color: tokens.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Validating image resolution, integrity & clarity',
                    style: AppTypography.bodyMedium.copyWith(
                      color: tokens.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Thumbnail preview (Stitch)
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: tokens.borderGlass),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.card,
                      child: _file.existsSync()
                          ? Image.file(
                              _file,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 56,
                                color: tokens.outline,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Validation Results Checklist
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: AppRadius.card,
                      border: Border.all(color: tokens.borderGlass),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.fact_check_outlined,
                              color: tokens.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Client-Side Image Checks',
                              style: AppTypography.bodyMediumSemibold.copyWith(
                                color: tokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (!_fileReady) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: tokens.primary,
                              ),
                            ),
                          ),
                        ] else ...[
                          _buildCheckRow(
                            tokens: tokens,
                            label: 'File readable and accessible',
                            passed: _checkFileReadable,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCheckRow(
                            tokens: tokens,
                            label: _fileSizeText != null
                                ? 'File size OK ($_fileSizeText)'
                                : 'File size OK (>10 KB, <25 MB)',
                            passed: _checkFileSizeOk,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCheckRow(
                            tokens: tokens,
                            label: 'Valid image format (JPEG/PNG/WebP)',
                            passed: _checkExtensionOk,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCheckRow(
                            tokens: tokens,
                            label: _imageWidth != null && _imageHeight != null
                                ? 'Resolution OK (${_imageWidth}x$_imageHeight px)'
                                : 'Minimum resolution check (≥ 200x200 px)',
                            passed: _checkResolutionOk,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),

                        // Guidance Notice
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: tokens.surfaceVariant.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tokens.warning.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: tokens.warning,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Ensure that the image is sharply focused and well illuminated before proceeding.',
                                  style: AppTypography.caption.copyWith(
                                    color: tokens.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // User confirmation checkbox (Stitch)
                  GestureDetector(
                    onTap: () => setState(() => _userConfirmed = !_userConfirmed),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _userConfirmed
                            ? tokens.primary.withValues(alpha: 0.10)
                            : tokens.surface,
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: _userConfirmed
                              ? tokens.primary.withValues(alpha: 0.40)
                              : tokens.borderGlass,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: _userConfirmed
                                  ? tokens.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: _userConfirmed
                                    ? tokens.primary
                                    : tokens.outline,
                                width: 1.5,
                              ),
                            ),
                            child: _userConfirmed
                                ? Icon(
                                    Icons.check,
                                    size: 14,
                                    color: tokens.onPrimary,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'I confirm this image clearly displays the skin concern in good lighting.',
                              style: AppTypography.bodySmall.copyWith(
                                color: tokens.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons (Stitch)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: tokens.onSurface,
                              side: BorderSide(color: tokens.borderGlass),
                              backgroundColor: tokens.surface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            icon: const Icon(Icons.replay, size: 20),
                            label: const Text('Retake'),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_allChecksPassed && _userConfirmed)
                                      ? tokens.primary
                                      : tokens.surfaceVariant,
                              foregroundColor:
                                  (_allChecksPassed && _userConfirmed)
                                      ? tokens.onPrimary
                                      : tokens.outline,
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.button,
                              ),
                            ),
                            icon: const Icon(Icons.analytics_outlined, size: 20),
                            label: Text(
                              'Analyse',
                              style: AppTypography.buttonPrimary.copyWith(
                                color: (_allChecksPassed && _userConfirmed)
                                    ? tokens.onPrimary
                                    : tokens.outline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: (_allChecksPassed && _userConfirmed)
                                ? () {
                                    context.push(
                                      RoutePaths.aiAnalysisLoading,
                                      extra: widget.imagePath,
                                    );
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow({
    required AppThemeTokens tokens,
    required String label,
    required bool? passed,
  }) {
    final isLoading = passed == null;
    final color = isLoading
        ? tokens.outline
        : passed
            ? tokens.success
            : tokens.danger;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.10),
            border: Border.all(color: color.withValues(alpha: 0.30)),
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tokens.outline,
                  ),
                )
              : Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 16,
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: tokens.onSurface,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
