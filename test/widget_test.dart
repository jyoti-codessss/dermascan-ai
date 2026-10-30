import 'package:dermascan_ai/app/app.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('DermaScanApp mounts and displays SplashScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DermaScanApp(),
      ),
    );

    // Initial route is splash
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('DermaScan AI'), findsOneWidget);

    // Complete pending timer on splash screen
    await tester.pump(const Duration(milliseconds: 3000));
  });
}
