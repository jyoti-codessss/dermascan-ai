import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_provider.dart';

/// Root Application Widget for DermaScan AI.
/// Responds to ThemeMode changes (System Default, Light, Dark).
class DermaScanApp extends ConsumerWidget {
  const DermaScanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // When running Flutter Web on desktop (width > 500), constrain to phone viewport frame
            if (constraints.maxWidth > 500) {
              final frameHeight = constraints.maxHeight > 844 ? 844.0 : constraints.maxHeight;
              return Container(
                color: const Color(0xFF030712), // Dark backdrop outside mobile preview frame
                child: Center(
                  child: Container(
                    width: 390,
                    height: frameHeight,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF1E293B), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.65),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(390, frameHeight),
                      ),
                      child: child!,
                    ),
                  ),
                ),
              );
            }
            // On mobile devices (Android / iOS), naturally use 100% of device width
            return child!;
          },
        );
      },
    );
  }
}
