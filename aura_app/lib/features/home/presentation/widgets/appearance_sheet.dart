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
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentMode = themeNotifier.currentAppThemeMode;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: responsive.h(2)),
            const Text(
              'Appearance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.h(0.5)),
            Text(
              'Choose your preferred theme',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            SizedBox(height: responsive.h(3)),
            _buildThemeOption(
              responsive,
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
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.space(10)),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : Colors.white70,
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
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white54,
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
