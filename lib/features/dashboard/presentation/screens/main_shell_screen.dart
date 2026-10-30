import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main scaffold shell with bottom navigation for DermaScan AI.
/// Implements navigation destinations: Home, Scan, Nearby, Profile (Stitch layout).
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(
            top: BorderSide(color: tokens.borderGlass, width: 1.0),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: tokens.surface,
              indicatorColor: tokens.primary.withValues(alpha: 0.18),
              elevation: 0,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTypography.captionMedium.copyWith(
                    color: tokens.primary,
                    fontWeight: FontWeight.w700,
                  );
                }
                return AppTypography.captionMedium.copyWith(
                  color: tokens.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: tokens.primary, size: 24);
                }
                return IconThemeData(color: tokens.outline, size: 24);
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: tokens.surface,
            indicatorColor: tokens.primary.withValues(alpha: 0.18),
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.adjust),
                selectedIcon: Icon(Icons.adjust, fill: 1.0),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: 'Nearby',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
