import 'package:dermascan_ai/core/widgets/cards/medical_disclaimer_card.dart';
import 'package:dermascan_ai/core/widgets/signature/skin_orb.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/scan_intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ScanIntroScreen Widget Tests', () {
    testWidgets('renders ScanIntroScreen title, orb, Stitch guidance cards, and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScanIntroScreen(),
        ),
      );

      // Verify title & SkinOrb
      expect(find.text('Scan your skin'), findsOneWidget);
      expect(find.byType(SkinOrb), findsOneWidget);

      // Verify Stitch guidance bento cards
      expect(find.text('Good lighting'), findsOneWidget);
      expect(find.text('Clear focus'), findsOneWidget);
      expect(find.text('Area visible'), findsOneWidget);
      expect(find.text('No filters'), findsOneWidget);

      // Verify disclaimer
      expect(find.byType(MedicalDisclaimerCard), findsOneWidget);

      // Verify action buttons
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Upload Image'), findsOneWidget);
    });
  });
}
