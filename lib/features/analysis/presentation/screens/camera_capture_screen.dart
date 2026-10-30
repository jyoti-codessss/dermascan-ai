import 'package:camera/camera.dart';
import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/core/widgets/buttons/app_primary_button.dart';
import 'package:dermascan_ai/core/widgets/feedback/app_error_state.dart';
import 'package:dermascan_ai/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dermascan_ai/features/analysis/presentation/widgets/camera_framing_overlay.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum CameraStateStatus {
  initial,
  loading,
  ready,
  permissionDenied,
  error,
}

/// Camera Capture screen with live preview, framing guide overlay, and shutter controls (design.md #18).
class CameraCaptureScreen extends StatefulWidget {
  final List<CameraDescription>? mockCameras;

  const CameraCaptureScreen({
    super.key,
    this.mockCameras,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  CameraStateStatus _status = CameraStateStatus.initial;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onCameraSelected(cameraController.description);
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _status = CameraStateStatus.loading;
      _errorMessage = null;
    });

    try {
      if (widget.mockCameras != null) {
        _cameras = widget.mockCameras!;
      } else {
        _cameras = await availableCameras();
      }

      if (_cameras.isEmpty) {
        setState(() {
          _status = CameraStateStatus.error;
          _errorMessage = 'No camera devices found on this device.';
        });
        return;
      }

      await _onCameraSelected(_cameras[_selectedCameraIndex]);
    } catch (e) {
      if (e.toString().contains('permission') || e.toString().contains('denied')) {
        setState(() {
          _status = CameraStateStatus.permissionDenied;
          _errorMessage = 'Camera access was denied.';
        });
      } else {
        setState(() {
          _status = CameraStateStatus.error;
          _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _onCameraSelected(CameraDescription description) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _status = CameraStateStatus.ready;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = CameraStateStatus.error;
          _errorMessage = 'Error setting up camera viewfinder.';
        });
      }
    }
  }

  Future<void> _toggleFlashMode() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.auto:
        nextMode = FlashMode.off;
        break;
      case FlashMode.off:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
      case FlashMode.torch:
        nextMode = FlashMode.auto;
        break;
    }

    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _onCameraSelected(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      if (mounted) {
        context.push(RoutePaths.imagePreview, extra: photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Widget _buildTopBar() {
    IconData flashIcon;
    switch (_flashMode) {
      case FlashMode.off:
        flashIcon = Icons.flash_off_rounded;
        break;
      case FlashMode.always:
      case FlashMode.torch:
        flashIcon = Icons.flash_on_rounded;
        break;
      case FlashMode.auto:
        flashIcon = Icons.flash_auto_rounded;
        break;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(flashIcon, color: Colors.white),
                  onPressed: _toggleFlashMode,
                ),
                if (_cameras.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.cameraswitch_outlined,
                      color: Colors.white,
                    ),
                    onPressed: _switchCamera,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        height: 110,
        color: Colors.black.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shutter Button
            GestureDetector(
              onTap: _isCapturing ? null : _takePicture,
              child: Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                ),
                child: _isCapturing
                    ? const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_status == CameraStateStatus.loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: AppLoadingIndicator(
            message: 'Initializing camera...',
            useSkinOrb: true,
          ),
        ),
      );
    }

    if (_status == CameraStateStatus.permissionDenied) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Camera Permission')),
        body: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.camera_enhance_outlined,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Camera Access Required',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'DermaScan AI needs camera permissions to take clear photos of your skin concerns for analysis.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppPrimaryButton(
                label: 'Grant Camera Access / Retry',
                onPressed: _initializeCamera,
              ),
            ],
          ),
        ),
      );
    }

    if (_status == CameraStateStatus.error || _controller == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Camera Error')),
        body: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: AppErrorState(
              title: 'Camera Unavailable',
              message: _errorMessage ?? 'Unable to initialize camera preview.',
              onRetry: _initializeCamera,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_controller!),

          // Framing Guide Overlay
          const CameraFramingOverlay(),

          // Top Controls (Back, Flash, Switch Camera)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Bottom Shutter Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }
}
