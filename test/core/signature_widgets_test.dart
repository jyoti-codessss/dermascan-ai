import 'package:dermascan_ai/core/widgets/signature/analysis_timeline.dart';
import 'package:dermascan_ai/core/widgets/signature/confidence_ring.dart';
import 'package:dermascan_ai/core/widgets/signature/scan_button.dart';
import 'package:dermascan_ai/core/widgets/signature/skin_orb.dart';
import 'package:dermascan_ai/core/widgets/signature/trust_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Signature Components Widget Tests', () {
    testWidgets('SkinOrb renders with non-animated mode without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SkinOrb(
                size: SkinOrbSize.medium,
                isAnimated: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkinOrb), findsOneWidget);
    });

    testWidgets('ScanButton renders label and triggers callback on tap', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScanButton(
                label: 'Start a skin scan',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Start a skin scan'), findsOneWidget);
      await tester.tap(find.byType(ScanButton));
      await tester.pump(const Duration(milliseconds: 150));

      expect(pressed, isTrue);
    });

    testWidgets('ConfidenceRing displays model confidence and footnote', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConfidenceRing(
                confidence: 0.87,
                isAnimated: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('87%'), findsOneWidget);
      expect(find.text('CONFIDENCE'), findsOneWidget);
      expect(
        find.text('Model confidence does not indicate diagnostic certainty.'),
        findsOneWidget,
      );
    });

    testWidgets('TrustStrip displays disclaimer text and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TrustStrip(
                text: 'AI-generated information · Not a diagnosis',
                showDetailOnTap: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('AI-generated information · Not a diagnosis'), findsOneWidget);
      await tester.tap(find.byType(TrustStrip));
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });

    testWidgets('AnalysisTimeline renders item cards and node paths', (tester) async {
      final items = [
        AnalysisTimelineItemData(
          id: '1',
          condition: 'Acne',
          confidence: 0.87,
          date: DateTime(2026, 8, 12),
        ),
        AnalysisTimelineItemData(
          id: '2',
          condition: 'Eczema',
          confidence: 0.81,
          date: DateTime(2026, 8, 5),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalysisTimeline(
              items: items,
            ),
          ),
        ),
      );

      expect(find.text('Possible Acne'), findsOneWidget);
      expect(find.text('Confidence 87%'), findsOneWidget);
      expect(find.text('Possible Eczema'), findsOneWidget);
      expect(find.text('Confidence 81%'), findsOneWidget);
    });
  });
}
