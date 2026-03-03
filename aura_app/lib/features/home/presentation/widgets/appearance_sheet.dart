import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/ui/responsive/responsive.dart';

class AppearanceSheet extends ConsumerWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;
    final currentThemeMode = ref.watch(themeProvider);

    AppThemeMode currentMode;
    switch (currentThemeMode) {
      case ThemeMode.light:
        currentMode = AppThemeMode.light;
        break;
      case ThemeMode.dark:
        currentMode = AppThemeMode.dark;
        break;
      default:
        currentMode = AppThemeMode.system;
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.w(5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceFaint(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: responsive.h(2)),
            Text(
              'Appearance',
              style: TextStyle(
                color: AppColors.onSurface(brightness),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.h(0.5)),
            Text(
              'Choose your preferred theme',
              style: TextStyle(
                color: AppColors.onSurfaceMuted(brightness),
                fontSize: 14,
              ),
            ),
            SizedBox(height: responsive.h(3)),
            _buildThemeOption(
              responsive,
              brightness: brightness,
              icon: Icons.light_mode,
              title: 'Light',
              subtitle: 'Always use light theme',
              isSelected: currentMode == AppThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: responsive.h(1.5)),
            _buildThemeOption(
              responsive,
              brightness: brightness,
              icon: Icons.dark_mode,
              title: 'Dark',
              subtitle: 'Always use dark theme',
              isSelected: currentMode == AppThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: responsive.h(1.5)),
            _buildThemeOption(
              responsive,
              brightness: brightness,
              icon: Icons.settings_suggest,
              title: 'System',
              subtitle: 'Follow device settings',
              isSelected: currentMode == AppThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: responsive.h(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    Responsive responsive, {
    required Brightness brightness,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.w(4)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.containerFill(brightness),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.containerBorder(brightness),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.space(10)),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.iconButtonFill(brightness),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.onSurfaceMuted(brightness),
                size: 22,
              ),
            ),
            SizedBox(width: responsive.w(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: responsive.isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.onSurfaceMuted(brightness),
                      fontSize: responsive.isTablet ? 12 : 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
