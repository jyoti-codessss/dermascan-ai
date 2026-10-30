import 'package:dermascan_ai/app/router/route_paths.dart';
import 'package:dermascan_ai/app/theme/app_colors.dart';
import 'package:dermascan_ai/app/theme/app_radius.dart';
import 'package:dermascan_ai/app/theme/app_spacing.dart';
import 'package:dermascan_ai/app/theme/app_typography.dart';
import 'package:dermascan_ai/app/theme/theme_mode_provider.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings screen matching Stitch design (6a0d5135fd324ebb8704321fc52d84ec).
/// Includes full functional Theme Selector (System Default, Light, Dark) with persistence.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;

  void _showThemeSelectorDialog(BuildContext context, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.tokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.tokens.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Choose Theme',
                  style: AppTypography.h3.copyWith(
                    color: context.tokens.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Select your preferred visual appearance',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.tokens.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildThemeOption(
                  ctx,
                  title: 'System Default',
                  subtitle: 'Match your operating system setting',
                  icon: Icons.brightness_auto_outlined,
                  isSelected: currentMode == ThemeMode.system,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                _buildThemeOption(
                  ctx,
                  title: 'Dark Theme',
                  subtitle: 'Deep dark healthcare palette (Stitch)',
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentMode == ThemeMode.dark,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                _buildThemeOption(
                  ctx,
                  title: 'Light Theme',
                  subtitle: 'Clinical daylight high-contrast palette',
                  icon: Icons.light_mode_outlined,
                  isSelected: currentMode == ThemeMode.light,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? context.tokens.primary.withValues(alpha: 0.15)
              : context.tokens.surfaceVariant.withValues(alpha: 0.5),
        ),
        child: Icon(
          icon,
          color: isSelected ? context.tokens.primary : context.tokens.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMediumSemibold.copyWith(
          color: context.tokens.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: context.tokens.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.tokens.primary)
          : null,
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.surfaceGlass,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: AppTypography.h3.copyWith(color: tokens.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: tokens.primary),
            onPressed: () => context.push(RoutePaths.history),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section (Stitch)
              _buildSectionHeader('Account'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile Information',
                      subtitle: 'Update your name, email, and avatar',
                      onTap: () => context.push(RoutePaths.personalInfo),
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Password & Security',
                      subtitle: 'Change password and setup 2FA',
                      onTap: () => context.push(RoutePaths.forgotPassword),
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Preferences Section (Stitch)
              _buildSectionHeader('Preferences'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  children: [
                    // Theme Selector Tile
                    InkWell(
                      onTap: () => _showThemeSelectorDialog(context, themeMode),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.primary.withValues(alpha: 0.10),
                              ),
                              child: Icon(
                                context.isDarkMode
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                color: tokens.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appearance / Theme',
                                    style: AppTypography.bodyMediumSemibold.copyWith(
                                      color: tokens.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _themeModeLabel(themeMode),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: tokens.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: tokens.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: tokens.borderGlass, height: 1),

                    // Push Notifications Switch Tile
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.primary.withValues(alpha: 0.10),
                            ),
                            child: Icon(
                              Icons.notifications_none_outlined,
                              color: tokens.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Push Notifications',
                                  style: AppTypography.bodyMediumSemibold.copyWith(
                                    color: tokens.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Receive alerts for analysis results',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: tokens.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _pushNotifications,
                            activeThumbColor: tokens.primary,
                            onChanged: (val) {
                              setState(() => _pushNotifications = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(color: tokens.borderGlass, height: 1),

                    // Language Selection Tile
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English (US)',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Legal Section (Stitch)
              _buildSectionHeader('Legal'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: tokens.borderGlass),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.policy_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Review our data privacy commitment',
                      onTap: () => context.push(RoutePaths.privacy),
                      showDivider: true,
                    ),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'View user agreement and disclaimers',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Danger Zone: Log Out Button (Stitch)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                    side: BorderSide(
                      color: tokens.danger.withValues(alpha: 0.3),
                    ),
                    backgroundColor: tokens.danger.withValues(alpha: 0.05),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text(
                    'Log Out',
                    style: AppTypography.buttonPrimary.copyWith(
                      color: tokens.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).logout();
                    context.go(RoutePaths.login);
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.captionMedium.copyWith(
          color: context.tokens.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    final tokens = context.tokens;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.primary.withValues(alpha: 0.10),
                  ),
                  child: Icon(icon, color: tokens.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMediumSemibold.copyWith(
                          color: tokens.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: tokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: tokens.outline),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(color: tokens.borderGlass, height: 1),
      ],
    );
  }
}
