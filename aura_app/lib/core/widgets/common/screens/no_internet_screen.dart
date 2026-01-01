import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../constants/asset_constants.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/connectivity/internet_status_provider.dart';
import '../../../utils/connectivity/offline_mode_provider.dart';
import '../../../utils/responsive.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  final bool isOverlay;

  const NoInternetScreen({super.key, this.isOverlay = false});

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  bool _exitTriggered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );

    _fade = CurvedAnimation(curve: Curves.easeOutQuad, parent: _controller);

    _controller.forward();
  }

  Future<void> _retryConnection() async {
    final hasInternet = ref.read(internetStatusProvider).value;

    if (hasInternet == null || !hasInternet) {
      AppSnackbar.showError(
        context: context,
        message: "Still offline. Check Wi-Fi or mobile data.",
      );
      return;
    }

    ref.read(offlineModeProvider.notifier).state = false;
    AppSnackbar.showSuccess(context: context, message: "Connected!");

    _closeSmoothly();
  }

  void _closeSmoothly() {
    if (_exitTriggered) return;

    _exitTriggered = true;
    _controller.reverse();

    Future.delayed(AppConstants.shortAnimation, () {
      if (!mounted) return;

      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final hasInternet = ref.watch(internetStatusProvider).value ?? false;

    if (hasInternet && !_exitTriggered) {
      _closeSmoothly();
    }

    final content = FadeTransition(
      opacity: _fade,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.w(70),
            child: Image.asset(
              AssetConstants.noInternetBackground,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: responsive.h(3)),

          Text(
            "You're Offline",
            style: AppTextStyles.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: responsive.h(2)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.w(10)),
            child: Text(
              "Our little ghost is sad 😢 — Aura needs an internet connection to continue.",
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
                fontSize: responsive.isTablet ? 18 : 15,
              ),
            ),
          ),

          SizedBox(height: responsive.h(5)),

          GestureDetector(
            onTap: _retryConnection,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: responsive.isTablet
                      ? AppDimensions.iconXL
                      : AppDimensions.iconL,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Text(
                  "Retry",
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: responsive.isTablet ? 20 : 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.splashGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    final body = Stack(
      children: [
        Positioned.fill(child: background),
        SafeArea(child: content),
      ],
    );

    if (widget.isOverlay) {
      return Scaffold(backgroundColor: Colors.transparent, body: body);
    }

    return Scaffold(body: body);
  }
}
