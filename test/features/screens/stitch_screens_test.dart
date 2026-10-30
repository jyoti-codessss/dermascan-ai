import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/analysis_details_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/analysis_result_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/low_confidence_screen.dart';
import 'package:dermascan_ai/features/nearby_care/domain/nearby_provider.dart';
import 'package:dermascan_ai/features/nearby_care/presentation/screens/nearby_care_screen.dart';
import 'package:dermascan_ai/features/nearby_care/presentation/screens/provider_details_screen.dart';
import 'package:dermascan_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/notifications_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/offline_state_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/privacy_screen.dart';
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

  group('Stitch Realigned Screens Widget Tests', () {
    testWidgets('AnalysisDetailsScreen renders image card, confidence, and guidelines',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AnalysisDetailsScreen(
          imagePath: '/mock/path.jpg',
          conditionName: 'Acne Vulgaris',
          confidencePercent: 87,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Analysis Details'), findsOneWidget);
      expect(find.text('AI Confidence Analysis'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
      expect(find.text('Acne Vulgaris Detected'), findsOneWidget);
      expect(find.text('What it may mean'), findsOneWidget);
      expect(find.text('General Care & Next Steps'), findsOneWidget);
      expect(find.text('Find Nearby Providers'), findsOneWidget);
    });

    testWidgets('AnalysisResultScreen renders header, trust strip, and CTAs',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AnalysisResultScreen(
          imagePath: '/mock/path.jpg',
          conditionName: 'Acne Vulgaris',
          confidencePercent: 87,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('DermaScan AI'), findsOneWidget);
      expect(find.text('ANALYSIS COMPLETE'), findsOneWidget);
      expect(find.text('Acne Vulgaris'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
      expect(find.text('AI-generated information · Not a medical diagnosis'), findsOneWidget);
      expect(find.text('What it may mean'), findsOneWidget);
      expect(find.text('What you can do next'), findsOneWidget);
      expect(find.text('Need professional care?'), findsOneWidget);
      expect(find.text('Find nearby care'), findsOneWidget);
      expect(find.text('View Detailed Clinical Breakdown'), findsOneWidget);
    });

    testWidgets('LowConfidenceScreen renders alert, recommendation cards, and retake CTAs',
        (tester) async {
      await tester.pumpWidget(createTestWidget(
        const LowConfidenceScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('DermaScan AI'), findsOneWidget);
      expect(find.text("We couldn't reliably analyze this"), findsOneWidget);
      expect(find.text('Ensure bright, natural lighting'), findsOneWidget);
      expect(find.text('Keep the subject in sharp focus'), findsOneWidget);
      expect(find.text('Hold the camera steady'), findsOneWidget);
      expect(find.text('Try Another Image'), findsOneWidget);
    });

    testWidgets('NearbyCareScreen renders search bar, filters, and configuration/loading states',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const NearbyCareScreen()));
      await tester.pump();

      expect(find.text('Find Nearby Providers'), findsOneWidget);
    });

    testWidgets('ProviderDetailsScreen renders provider info, actions and booking CTA',
        (tester) async {
      const sampleProvider = PlaceResult(
        name: 'City Dermatology Clinic',
        address: '123 Medical Center Blvd',
        rating: 4.8,
        userRatingsTotal: 120,
        openNow: true,
        distanceKm: 1.5,
      );

      await tester.pumpWidget(createTestWidget(const ProviderDetailsScreen(provider: sampleProvider)));
      await tester.pumpAndSettle();

      expect(find.text('Provider Details'), findsOneWidget);
      expect(find.text('City Dermatology Clinic'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);
      expect(find.text('Book Consultation'), findsOneWidget);
    });

    testWidgets('ProfileScreen renders profile header, real statistics, and navigation items',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('STATUS'), findsOneWidget);
      expect(find.text('Skin Journey Active'), findsOneWidget);
      expect(find.text('TOTAL ANALYSES'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Personal Info'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Privacy & Data Consent'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('PrivacyScreen renders encryption, location toggle, and deletion cards',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const PrivacyScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Data & Permissions'), findsOneWidget);
      expect(find.text('End-to-End Encryption'), findsOneWidget);
      expect(find.text('Location Services'), findsOneWidget);
      expect(find.text('Image Data Retention'), findsOneWidget);
      expect(find.text('Delete Account Data'), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders update toggles and notification items',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const NotificationsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Analysis updates'), findsOneWidget);
      expect(find.text('Care reminders'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
    });

    testWidgets('OfflineStateScreen renders offline icon, message and try again button',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const OfflineStateScreen()));
      await tester.pumpAndSettle();

      expect(find.text("You're Offline"), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
    });
  });
}
