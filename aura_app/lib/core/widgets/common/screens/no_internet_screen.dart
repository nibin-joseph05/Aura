import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/asset_constants.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/connectivity/internet_status_provider.dart';
import '../../../utils/connectivity/offline_mode_provider.dart';
import '../../../utils/responsive.dart';
import '../app_header.dart';

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

  bool _connectedShown = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
  }

  Future<void> _retryConnection() async {
    final hasInternet = ref.read(internetStatusProvider).value;

    if (hasInternet == null || hasInternet == false) {
      AppSnackbar.showError(
        context: context,
        message: "Still offline. Check Wi-Fi or mobile data.",
      );
      return;
    }

    ref.read(offlineModeProvider.notifier).state = false;

    AppSnackbar.showSuccess(context: context, message: "Connected!");

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    final hasInternet = ref.watch(internetStatusProvider).value ?? false;

    if (hasInternet && !_connectedShown) {
      _connectedShown = true;

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) Navigator.pop(context);
      });
    }

    final screen = Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF08162B), Color(0xFF0F2F51), Color(0xFF1A4A78)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppHeader(
                  title: "No Internet",
                  subtitle: "Connection required",
                  onBack: null,
                ),

                SizedBox(height: responsive.h(6)),

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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: responsive.h(1.5)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(10)),
                  child: Text(
                    "Aura needs an internet connection to continue.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
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
                        size: responsive.isTablet ? 26 : 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Retry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.isTablet ? 20 : 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: responsive.h(3)),

                if (hasInternet)
                  Text(
                    "Reconnected! Returning…",
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: responsive.isTablet ? 16 : 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isOverlay) {
      return Positioned.fill(child: screen);
    }

    return Scaffold(body: screen);
  }
}
