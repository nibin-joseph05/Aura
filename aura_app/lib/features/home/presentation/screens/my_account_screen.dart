import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/navigation/app_header.dart';
import '../../../user/presentation/providers/profile_image_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../widgets/appearance_sheet.dart';

class MyAccountScreen extends ConsumerWidget {
  const MyAccountScreen({super.key});

  String? _buildFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = AppConfig.baseUrl;
    return '$base/uploads/$path';
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    ref.read(userProvider.notifier).clearUser();
    ref.read(profileImageProvider.notifier).reset();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.welcome,
        (_) => false,
      );
    }
  }

  void _showAppearanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppearanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final profileImageUrl = _buildFullImageUrl(user?.profileImageUrl);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(title: 'My Account', showBack: true),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: responsive.horizontal(5),
                  child: Column(
                    children: [
                      SizedBox(height: responsive.h(2)),
                      _buildProfileHeader(
                        context,
                        responsive,
                        user,
                        profileImageUrl,
                      ),
                      SizedBox(height: responsive.h(3)),
                      _buildMenuSection(responsive, 'Account', [
                        _MenuItemData(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.editProfile,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password reset email will be sent',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        ),
                        _MenuItemData(
                          icon: Icons.phone_outlined,
                          title: 'Phone Number',
                          subtitle: user?.phone ?? 'Not added',
                          onTap: () {},
                        ),
                      ]),
                      SizedBox(height: responsive.h(2)),
                      _buildMenuSection(responsive, 'Preferences', [
                        _MenuItemData(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification settings',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notifications enabled'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        _MenuItemData(
                          icon: Icons.language_outlined,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Only English is currently supported',
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                        _MenuItemData(
                          icon: Icons.dark_mode_outlined,
                          title: 'Appearance',
                          subtitle: 'Theme settings',
                          onTap: () => _showAppearanceSheet(context),
                        ),
                      ]),
                      SizedBox(height: responsive.h(2)),
                      _buildMenuSection(responsive, 'Safety', [
                        _MenuItemData(
                          icon: Icons.emergency_outlined,
                          title: 'Emergency Contacts',
                          subtitle: 'Manage SOS contacts',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.sosSettings,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.location_on_outlined,
                          title: 'Location Sharing',
                          subtitle: 'Shared during SOS only',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Location is only shared during SOS alerts',
                                ),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      ]),
                      SizedBox(height: responsive.h(2)),
                      _buildMenuSection(responsive, 'Support', [
                        _MenuItemData(
                          icon: Icons.help_outline,
                          title: 'Help & FAQ',
                          subtitle: 'Get help and find answers',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.helpFaq),
                        ),
                        _MenuItemData(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.privacyPolicy,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.privacyPolicy,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.info_outline,
                          title: 'About Aura',
                          subtitle: 'Version 1.0.0',
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.about),
                        ),
                      ]),
                      SizedBox(height: responsive.h(3)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _logout(context, ref),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withValues(
                              alpha: 0.8,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: responsive.h(1.8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
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

  Widget _buildProfileHeader(
    BuildContext context,
    Responsive responsive,
    dynamic user,
    String? profileImageUrl,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.space(20)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: SizedBox(
                width: responsive.isTablet ? 80 : 70,
                height: responsive.isTablet ? 80 : 70,
                child: profileImageUrl != null
                    ? Image.network(
                        profileImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.white24,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white54,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: responsive.isTablet ? 40 : 35,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: responsive.isTablet ? 40 : 35,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(width: responsive.w(4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.username != null) ...[
                  SizedBox(height: responsive.h(0.3)),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: responsive.isTablet ? 14 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (user?.email != null) ...[
                  SizedBox(height: responsive.h(0.3)),
                  Text(
                    user.email!,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: responsive.isTablet ? 12 : 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.accent,
              size: responsive.isTablet ? 24 : 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    Responsive responsive,
    String title,
    List<_MenuItemData> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: responsive.w(2),
            bottom: responsive.h(1),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: responsive.isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return _buildMenuItem(responsive, item, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    Responsive responsive,
    _MenuItemData item,
    bool isLast,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isLast ? 0 : 0),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(4),
            vertical: responsive.h(1.6),
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.space(10)),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: responsive.isTablet ? 22 : 18,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: responsive.w(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: responsive.h(0.2)),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: responsive.isTablet ? 12 : 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white38,
                size: responsive.isTablet ? 24 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
