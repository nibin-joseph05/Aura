import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/notifications/notification_encourage_card.dart';
import '../../../../core/widgets/screens/success_overlay_card.dart';
import '../../../daily_activity/presentation/widgets/daily_activity_tracker_widget.dart';
import '../providers/success_overlay_provider.dart';
import '../widgets/feed_preview_section.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/wellness_summary_card.dart';
import 'my_account_screen.dart';

final selectedNavItemProvider = StateProvider<HomeNavItem>(
  (ref) => HomeNavItem.home,
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasCheckedArgs = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkArgsAndShowOverlay();
    });
  }

  void _checkArgsAndShowOverlay() {
    if (_hasCheckedArgs) return;
    _hasCheckedArgs = true;

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
  }

  void _onNavItemSelected(HomeNavItem item) {
    if (item == HomeNavItem.account) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyAccountScreen()),
      );
    } else if (item == HomeNavItem.sos) {
      Navigator.pushNamed(context, '/sos-trigger');
    } else if (item == HomeNavItem.feed) {
      Navigator.pushNamed(context, '/wellness-feed');
    } else if (item == HomeNavItem.walk) {
      Navigator.pushNamed(context, '/walking');
    } else {
      ref.read(selectedNavItemProvider.notifier).state = item;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final overlayData = ref.watch(successOverlayProvider);
    final selectedNavItem = ref.watch(selectedNavItemProvider);
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
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const HomeHeader(),
                  Expanded(child: _buildMainContent(responsive)),
                  HomeFooter(
                    selectedItem: selectedNavItem,
                    onItemSelected: _onNavItemSelected,
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

  Widget _buildMainContent(Responsive responsive) {
    final brightness = Theme.of(context).brightness;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      color: brightness == Brightness.dark ? Colors.white : AppColors.primary,
      backgroundColor: brightness == Brightness.dark
          ? AppColors.splashMedium
          : Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: responsive.horizontal(5),
        child: Column(
          children: [
            SizedBox(height: responsive.h(2)),
            const NotificationEncourageCard(),
            const WellnessSummaryCard(),
            SizedBox(height: responsive.h(2.5)),
            QuickActionsRow(
              onSOS: () => Navigator.pushNamed(context, '/sos-trigger'),
              onCreatePost: () =>
                  Navigator.pushNamed(context, '/wellness-create'),
              onWellnessFeed: () =>
                  Navigator.pushNamed(context, '/wellness-feed'),
              onAlarm: () => Navigator.pushNamed(context, '/alarm'),
              onChat: () => Navigator.pushNamed(context, '/chat'),
              onWalking: () => Navigator.pushNamed(context, '/walking'),
            ),
            SizedBox(height: responsive.h(3)),
            const DailyActivityTrackerWidget(),
            SizedBox(height: responsive.h(3)),
            FeedPreviewSection(
              onSeeAll: () => Navigator.pushNamed(context, '/wellness-feed'),
            ),
            SizedBox(height: responsive.h(3)),
          ],
        ),
      ),
    );
  }
}
