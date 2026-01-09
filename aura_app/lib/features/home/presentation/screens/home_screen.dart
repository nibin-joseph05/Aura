import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/ui/responsive/responsive.dart';
import '../../../user/presentation/providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    ref.read(userProvider.notifier).clearUser();
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
          child: Center(
            child: Padding(
              padding: responsive.horizontal(7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user?.profileImageUrl != null)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(user!.profileImageUrl!),
                    )
                  else
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  SizedBox(height: responsive.h(3)),
                  Text(
                    'Welcome to Aura!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 32 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.h(2)),
                  if (user != null) ...[
                    Text(
                      user.name ?? 'User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.isTablet ? 24 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: responsive.h(1)),
                    if (user.username != null)
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: responsive.isTablet ? 18 : 16,
                        ),
                      ),
                  ],
                  SizedBox(height: responsive.h(4)),
                  Container(
                    padding: EdgeInsets.all(responsive.space(20)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.greenAccent,
                        ),
                        SizedBox(height: responsive.h(2)),
                        const Text(
                          'Your account is all set up!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: responsive.h(1)),
                        const Text(
                          'This is your home screen. More features coming soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: responsive.h(4)),
                  ElevatedButton.icon(
                    onPressed: () => _logout(context, ref),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(6),
                        vertical: responsive.h(1.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
