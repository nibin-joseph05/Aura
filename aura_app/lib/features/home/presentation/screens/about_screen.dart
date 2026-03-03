import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.backgroundGradient(brightness),
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: 'About Aura', showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: responsive.horizontal(5),
                  child: Column(
                    children: [
                      SizedBox(height: responsive.h(4)),
                      Container(
                        padding: EdgeInsets.all(responsive.w(6)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.iconButtonFill(brightness),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.spa_outlined,
                          size: responsive.isTablet ? 64 : 48,
                          color: AppColors.accent,
                        ),
                      ),
                      SizedBox(height: responsive.h(2)),
                      Text(
                        'Aura',
                        style: TextStyle(
                          color: AppColors.onSurface(brightness),
                          fontSize: responsive.isTablet ? 32 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: AppColors.onSurfaceMuted(brightness),
                          fontSize: responsive.isTablet ? 14 : 12,
                        ),
                      ),
                      SizedBox(height: responsive.h(3)),
                      Container(
                        padding: EdgeInsets.all(responsive.w(5)),
                        decoration: BoxDecoration(
                          color: AppColors.containerFill(brightness),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.containerBorder(brightness),
                          ),
                        ),
                        child: Text(
                          'Aura is your personal wellness & safety companion. '
                          'Built with love to help you track your wellness journey, '
                          'connect with a supportive community, and stay safe with '
                          'emergency SOS features.\n\n'
                          'Our mission is to empower individuals to take control of '
                          'their health and safety through intuitive technology.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.onSurfaceMuted(brightness),
                            fontSize: responsive.isTablet ? 15 : 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.h(3)),
                      _buildInfoRow(
                        responsive,
                        'Developer',
                        'Aura Team',
                        brightness,
                      ),
                      _buildInfoRow(
                        responsive,
                        'Built with',
                        'Flutter & Firebase',
                        brightness,
                      ),
                      _buildInfoRow(
                        responsive,
                        'License',
                        'MIT License',
                        brightness,
                      ),
                      SizedBox(height: responsive.h(4)),
                      Text(
                        '© 2024 Aura. All rights reserved.',
                        style: TextStyle(
                          color: AppColors.onSurfaceFaint(brightness),
                          fontSize: responsive.isTablet ? 12 : 11,
                        ),
                      ),
                      SizedBox(height: responsive.h(3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    Responsive responsive,
    String label,
    String value,
    Brightness brightness,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: responsive.h(1)),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(4),
        vertical: responsive.h(1.5),
      ),
      decoration: BoxDecoration(
        color: AppColors.containerFill(brightness),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurfaceMuted(brightness),
              fontSize: responsive.isTablet ? 14 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.onSurface(brightness),
              fontSize: responsive.isTablet ? 14 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
