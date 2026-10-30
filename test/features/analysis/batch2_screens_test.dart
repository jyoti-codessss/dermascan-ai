import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/ai_analysis_loading_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/image_preview_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/image_quality_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          extensions: const [AppThemeTokens.dark],
        ),
        home: child,
      ),
    );
  }

  group('Batch 2 Analysis Screens Tests', () {
    testWidgets('ImagePreviewScreen renders review headers, retake and use image buttons', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ImagePreviewScreen(imagePath: '/mock/path/photo.jpg'),
        ),
      );

      expect(find.text('Review Image'), findsOneWidget);
      expect(find.text('Does this clearly show the affected skin area?'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Use Image'), findsOneWidget);
    });

    testWidgets('ImageQualityCheckScreen renders check cards, user confirmation, and disclaimer', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const ImageQualityCheckScreen(imagePath: '/mock/path/photo.jpg'),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Image Quality Check'), findsOneWidget);
      expect(find.text('Client-Side Image Checks'), findsOneWidget);
      expect(find.text('Retake'), findsOneWidget);
      expect(find.text('Analyse'), findsOneWidget);
    });

    testWidgets('AiAnalysisLoadingScreen renders animated radar orb and progress checklist', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AiAnalysisLoadingScreen(imagePath: '/mock/path/photo.jpg'),
        ),
      );

      await tester.pump();
      expect(find.text('Analysis in Progress'), findsOneWidget);
      expect(find.text('Image quality checked'), findsOneWidget);

      // Advance through progression timer
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
