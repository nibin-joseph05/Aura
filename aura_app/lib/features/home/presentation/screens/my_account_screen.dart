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
                  padding: responsive.horizontal(6),
                  child: Column(
                    children: [
                      SizedBox(height: responsive.h(3)),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: SizedBox(
                            width: responsive.isTablet ? 120 : 100,
                            height: responsive.isTablet ? 120 : 100,
                            child: profileImageUrl != null
                                ? Image.network(
                                    profileImageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
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
                                        size: responsive.isTablet ? 60 : 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.white24,
                                    child: Icon(
                                      Icons.person,
                                      size: responsive.isTablet ? 60 : 50,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.h(2)),
                      if (user != null) ...[
                        Text(
                          user.name ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.isTablet ? 26 : 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: responsive.h(0.5)),
                        if (user.username != null)
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: responsive.isTablet ? 16 : 14,
                            ),
                          ),
                        SizedBox(height: responsive.h(0.5)),
                        if (user.email != null)
                          Text(
                            user.email!,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: responsive.isTablet ? 14 : 12,
                            ),
                          ),
                      ],
                      SizedBox(height: responsive.h(4)),
                      _buildInfoCard(responsive, user),
                      SizedBox(height: responsive.h(4)),
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

  Widget _buildInfoCard(Responsive responsive, dynamic user) {
    return Container(
      padding: EdgeInsets.all(responsive.space(20)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          if (user?.phone != null)
            _buildInfoRow(
              responsive,
              Icons.phone_outlined,
              'Phone',
              user.phone!,
            ),
          if (user?.gender != null) ...[
            SizedBox(height: responsive.h(1.5)),
            _buildInfoRow(
              responsive,
              Icons.person_outline,
              'Gender',
              user.gender!,
            ),
          ],
          if (user?.dob != null) ...[
            SizedBox(height: responsive.h(1.5)),
            _buildInfoRow(
              responsive,
              Icons.cake_outlined,
              'Date of Birth',
              user.dob!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    Responsive responsive,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.space(10)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: responsive.isTablet ? 22 : 18,
            color: Colors.white70,
          ),
        ),
        SizedBox(width: responsive.w(3)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.isTablet ? 12 : 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
