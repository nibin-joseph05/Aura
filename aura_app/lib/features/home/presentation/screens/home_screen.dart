import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/screens/success_overlay_card.dart';
import '../providers/success_overlay_provider.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_header.dart';
import 'my_account_screen.dart';

final selectedNavItemProvider = StateProvider<HomeNavItem>(
  (ref) => HomeNavItem.home,
);
final _hasCheckedArgsProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive.of(context);
    final overlayData = ref.watch(successOverlayProvider);
    final selectedNavItem = ref.watch(selectedNavItemProvider);
    final hasCheckedArgs = ref.watch(_hasCheckedArgsProvider);

    if (!hasCheckedArgs) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && args['showSuccess'] == true) {
          final successType = args['successType'] as String?;
          if (successType == 'login') {
            ref.read(successOverlayProvider.notifier).showLogin();
          } else if (successType == 'profileComplete') {
            ref.read(successOverlayProvider.notifier).showProfileComplete();
          } else {
            ref.read(successOverlayProvider.notifier).showLogin();
          }
        }
        ref.read(_hasCheckedArgsProvider.notifier).state = true;
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const HomeHeader(),
                  Expanded(child: _buildMainContent(responsive)),
                  HomeFooter(
                    selectedItem: selectedNavItem,
                    onItemSelected: (item) =>
                        _onNavItemSelected(context, ref, item),
                  ),
                ],
              ),
            ),
            if (overlayData.isVisible)
              SuccessOverlayCard(
                title: overlayData.title,
                message: overlayData.message,
                buttonText: overlayData.buttonText,
                icon: overlayData.icon,
                iconColor: overlayData.iconColor,
                onDismiss: () {
                  ref.read(successOverlayProvider.notifier).hide();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _onNavItemSelected(
    BuildContext context,
    WidgetRef ref,
    HomeNavItem item,
  ) {
    if (item == HomeNavItem.account) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyAccountScreen()),
      );
    } else if (item == HomeNavItem.sos) {
    } else {
      ref.read(selectedNavItemProvider.notifier).state = item;
    }
  }

  Widget _buildMainContent(Responsive responsive) {
    return Center(
      child: Padding(
        padding: responsive.horizontal(7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.space(20)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.explore_rounded,
                    size: responsive.isTablet ? 64 : 52,
                    color: AppColors.accent,
                  ),
                  SizedBox(height: responsive.h(2)),
                  Text(
                    'Welcome to Aura',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 22 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: responsive.h(1)),
                  const Text(
                    'More features coming soon. Stay tuned!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
