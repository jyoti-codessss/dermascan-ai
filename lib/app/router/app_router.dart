import 'package:dermascan_ai/features/analysis/presentation/screens/ai_analysis_loading_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/analysis_details_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/analysis_result_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/camera_capture_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/image_preview_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/image_quality_check_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/low_confidence_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/scan_intro_screen.dart';
import 'package:dermascan_ai/features/analysis/presentation/screens/scan_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:dermascan_ai/features/auth/presentation/screens/splash_screen.dart';
import 'package:dermascan_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:dermascan_ai/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:dermascan_ai/features/dashboard/presentation/screens/main_shell_screen.dart';
import 'package:dermascan_ai/features/history/presentation/screens/history_screen.dart';
import 'package:dermascan_ai/features/nearby_care/domain/nearby_provider.dart';
import 'package:dermascan_ai/features/nearby_care/presentation/screens/nearby_care_screen.dart';
import 'package:dermascan_ai/features/nearby_care/presentation/screens/provider_details_screen.dart';
import 'package:dermascan_ai/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:dermascan_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/notifications_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/offline_state_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/privacy_screen.dart';
import 'package:dermascan_ai/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _scanNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'scan');
final _nearbyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'nearby');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Riverpod provider for application GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Stateful Shell Route for Bottom Navigation Bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard / Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardHomeScreen(),
              ),
            ],
          ),

          // Branch 1: Scan
          StatefulShellBranch(
            navigatorKey: _scanNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.scan,
                builder: (context, state) => const ScanScreen(),
              ),
              GoRoute(
                path: RoutePaths.scanIntro,
                builder: (context, state) => const ScanIntroScreen(),
              ),
            ],
          ),

          // Branch 2: Nearby Care
          StatefulShellBranch(
            navigatorKey: _nearbyNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.nearbyCare,
                builder: (context, state) => const NearbyCareScreen(),
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Secondary / Analysis Flow Screens (root navigator — no bottom nav)
      GoRoute(
        path: RoutePaths.chat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final initialQuery = state.extra as String?;
          return ChatScreen(initialQuery: initialQuery);
        },
      ),
      GoRoute(
        path: RoutePaths.history,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.cameraCapture,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraCaptureScreen(),
      ),
      GoRoute(
        path: RoutePaths.imagePreview,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final imagePath = state.extra as String? ?? '';
          return ImagePreviewScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: RoutePaths.imageQualityCheck,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final imagePath = state.extra as String? ?? '';
          return ImageQualityCheckScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: RoutePaths.aiAnalysisLoading,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final imagePath = state.extra as String? ?? '';
          return AiAnalysisLoadingScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: RoutePaths.analysisResult,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final imagePath = extra?['imagePath'] as String? ?? '';
          final conditionName = extra?['conditionName'] as String? ?? 'ACNE VULGARIS';
          final confidencePercent = extra?['confidencePercent'] as int? ?? 87;
          return AnalysisResultScreen(
            imagePath: imagePath,
            conditionName: conditionName,
            confidencePercent: confidencePercent,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.lowConfidenceResult,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LowConfidenceScreen(),
      ),
      GoRoute(
        path: RoutePaths.analysisDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final imagePath = extra?['imagePath'] as String? ?? '';
          final conditionName = extra?['conditionName'] as String? ?? 'Acne Vulgaris';
          final confidencePercent = extra?['confidencePercent'] as int? ?? 87;
          return AnalysisDetailsScreen(
            imagePath: imagePath,
            conditionName: conditionName,
            confidencePercent: confidencePercent,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.providerDetails,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final provider = state.extra as PlaceResult?;
          return ProviderDetailsScreen(provider: provider);
        },
      ),
      GoRoute(
        path: RoutePaths.personalInfo,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.privacy,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.offlineState,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OfflineStateScreen(),
      ),
    ],
  );
});
