import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../../core/widgets/screens/success_overlay_card.dart';
import '../../../../core/widgets/animations/animated_entry.dart';
import '../../../daily_activity/presentation/widgets/daily_activity_tracker_widget.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/success_overlay_provider.dart';
import '../widgets/daily_insight_card.dart';
import '../widgets/home_footer.dart';
import '../widgets/home_header.dart';
import '../widgets/mood_check_in_widget.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/wellness_summary_card.dart';
import '../../../news/presentation/widgets/news_ticker.dart';

final selectedNavItemProvider = StateProvider<HomeNavItem>(
  (ref) => HomeNavItem.home,
);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  bool _hasCheckedArgs = false;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeFade;
  late Animation<double> _welcomeScale;

  @override
  void initState() {
    super.initState();

    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _welcomeFade = CurvedAnimation(
      parent: _welcomeController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _welcomeScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _welcomeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkArgsAndShowOverlay();
    });
  }

  @override
  void dispose() {
    _welcomeController.dispose();
    super.dispose();
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
    if (item == HomeNavItem.messages) {
      Navigator.pushNamed(context, '/chat');
    } else if (item == HomeNavItem.sos) {
      Navigator.pushNamed(context, '/sos-trigger');
    } else if (item == HomeNavItem.vibes) {
      Navigator.pushNamed(context, '/wellness-feed');
    } else if (item == HomeNavItem.profile) {
      final userId = ref.read(userProvider).user?.uid ?? '';
      if (userId.isNotEmpty) {
        Navigator.pushNamed(context, '/user-profile', arguments: userId);
      }
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
              child: FadeTransition(
                opacity: _welcomeFade,
                child: ScaleTransition(
                  scale: _welcomeScale,
                  child: Column(
                    children: [
                      const HomeHeader(),
                      Expanded(
                        child: _buildMainContent(responsive, brightness),
                      ),
                      HomeFooter(
                        selectedItem: selectedNavItem,
                        onItemSelected: _onNavItemSelected,
                      ),
                    ],
                  ),
                ),
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

  Widget _buildMainContent(Responsive responsive, Brightness brightness) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      color: brightness == Brightness.dark ? Colors.white : AppColors.primary,
      backgroundColor: brightness == Brightness.dark
          ? AppColors.splashMedium
          : Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: responsive.horizontal(5),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: responsive.h(2)),

                const AnimatedEntry(
                  delay: Duration(milliseconds: 80),
                  child: WellnessSummaryCard(),
                ),

                SizedBox(height: responsive.h(2)),

                const AnimatedEntry(
                  delay: Duration(milliseconds: 180),
                  child: MoodCheckInWidget(),
                ),

                SizedBox(height: responsive.h(2)),

                AnimatedEntry(
                  delay: const Duration(milliseconds: 260),
                  child: QuickActionsRow(
                    onSOS: () => Navigator.pushNamed(context, '/sos-trigger'),
                    onCreatePost: () =>
                        Navigator.pushNamed(context, '/wellness-create'),
                    onWellnessFeed: () =>
                        Navigator.pushNamed(context, '/wellness-feed'),
                    onAlarm: () => Navigator.pushNamed(context, '/alarm'),
                    onChat: () => Navigator.pushNamed(context, '/chat'),
                    onWalking: () => Navigator.pushNamed(context, '/walking'),
                  ),
                ),

                SizedBox(height: responsive.h(2)),

                const AnimatedEntry(
                  delay: Duration(milliseconds: 350),
                  child: DailyInsightCard(),
                ),

                SizedBox(height: responsive.h(2.5)),

                AnimatedEntry(
                  delay: const Duration(milliseconds: 430),
                  child: _buildSectionHeader(
                    responsive,
                    icon: Icons.track_changes_rounded,
                    color: const Color(0xFF667EEA),
                    label: 'Activity Tracker',
                  ),
                ),

                SizedBox(height: responsive.h(1.2)),

                const AnimatedEntry(
                  delay: Duration(milliseconds: 480),
                  child: DailyActivityTrackerWidget(),
                ),

                SizedBox(height: responsive.h(2.5)),

                AnimatedEntry(
                  delay: const Duration(milliseconds: 530),
                  child: _buildSectionHeader(
                    responsive,
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF8B5CF6),
                    label: 'Analytics',
                  ),
                ),

                SizedBox(height: responsive.h(1.2)),

                AnimatedEntry(
                  delay: const Duration(milliseconds: 560),
                  child: _buildAnalyticsPlaceholder(responsive),
                ),

                SizedBox(height: responsive.h(2.5)),

                const AnimatedEntry(
                  delay: Duration(milliseconds: 650),
                  child: NewsTicker(),
                ),

                SizedBox(height: responsive.h(4)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    Responsive responsive, {
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: responsive.isTablet ? 34 : 28,
          height: responsive.isTablet ? 34 : 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: responsive.isTablet ? 18 : 15,
          ),
        ),
        SizedBox(width: responsive.w(2.5)),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsPlaceholder(Responsive responsive) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.h(4),
        horizontal: responsive.w(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.area_chart_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            SizedBox(height: responsive.h(1.5)),
            Text(
              "Analytics Coming Soon",
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: responsive.h(0.5)),
            Text(
              "AI-driven wellness trends powered by Gemini.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: responsive.isTablet ? 13 : 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
