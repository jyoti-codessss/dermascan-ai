import 'package:dermascan_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Authentication Presentation Screens Widget Tests', () {
    testWidgets('LoginScreen renders email, password inputs and sign in button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('DermaScan AI'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('G  Google'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders full name, email, passwords, and terms checkbox', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      expect(find.text('DermaScan AI'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Professional Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders reset request form', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      expect(find.text('Forgot Your Password?'), findsOneWidget);
      expect(find.text('Send Reset Instructions'), findsOneWidget);
    });
  });
}
