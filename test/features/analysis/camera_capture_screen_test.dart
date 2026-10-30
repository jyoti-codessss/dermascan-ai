import 'package:dermascan_ai/features/analysis/presentation/screens/camera_capture_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/widgets/camera_framing_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('CameraCaptureScreen & Overlay Widget Tests', () {
    testWidgets('CameraFramingOverlay renders framing guide and instruction text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraFramingOverlay(
              instructionText: 'Position skin concern inside the frame',
            ),
          ),
        ),
      );

      expect(find.text('Position skin concern inside the frame'), findsOneWidget);
      expect(find.byType(CameraFramingOverlay), findsOneWidget);
    });

    testWidgets('CameraCaptureScreen with empty mock cameras renders no-camera error state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraCaptureScreen(
            mockCameras: [],
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Camera Unavailable'), findsOneWidget);
      expect(find.text('No camera devices found on this device.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
