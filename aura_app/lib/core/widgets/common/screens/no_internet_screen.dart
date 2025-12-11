import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/responsive.dart';
import '../../buttons/primary_button.dart';
import '../app_header.dart';

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;
  final bool isOverlay;

  const NoInternetScreen({super.key, this.onRetry, this.isOverlay = false});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late StreamSubscription _subscription;
  late AnimationController _controller;
  late Animation<double> _fade;

  bool _connected = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    _subscription = Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        setState(() => _connected = true);
        Future.delayed(const Duration(milliseconds: 500), () {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

    final content = Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                const AppHeader(
                  title: "No Internet",
                  subtitle: "Connection required",
                  onBack: null,
                ),

                SizedBox(height: responsive.h(10)),

                Icon(
                  Icons.wifi_off_rounded,
                  size: responsive.isTablet
                      ? responsive.w(20)
                      : responsive.w(30),
                  color: Colors.white.withOpacity(0.9),
                ),

                SizedBox(height: responsive.h(4)),

                Text(
                  "You're Offline",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: responsive.isTablet ? 28 : 23,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),

                SizedBox(height: responsive.h(1.5)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(10)),
                  child: Text(
                    "Aura needs an active internet connection to continue. "
                    "Check your network and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: responsive.isTablet ? 18 : 15,
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: responsive.h(6)),

                PrimaryButton(
                  label: "Try Again",
                  responsive: responsive,
                  onPressed:
                      widget.onRetry ??
                      () async {
                        final status = await Connectivity().checkConnectivity();
                        if (status != ConnectivityResult.none) {
                          Navigator.pop(context);
                        }
                      },
                ),

                SizedBox(height: responsive.h(3)),

                if (_connected)
                  Text(
                    "Reconnected! Closing…",
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
      return Positioned.fill(child: content);
    }

    return Scaffold(body: content);
  }
}
