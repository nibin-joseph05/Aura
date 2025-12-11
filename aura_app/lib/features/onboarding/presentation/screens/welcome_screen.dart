import 'package:flutter/material.dart';

import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../auth/presentation/screens/auth_screen/auth_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/asset_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _buttonController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _buttonScale;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOutCubic,
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _buttonScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() {
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _titleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _subtitleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);

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
              padding: responsive.defaultPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedLogo(responsive),
                  SizedBox(height: responsive.h(4)),
                  _buildAnimatedTitle(responsive),
                  SizedBox(height: responsive.h(1.5)),
                  _buildAnimatedSubtitle(responsive),
                  SizedBox(height: responsive.h(6)),
                  _buildAnimatedButton(responsive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(Responsive responsive) {
    
    final logoSize = responsive.isTablet
        ? responsive.w(25)
        : responsive.isLargeTablet
        ? responsive.w(20)
        : responsive.w(35);

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.2),
                    blurRadius: 50,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AssetConstants.auraLogo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade800,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'AURA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: logoSize * 0.21,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle(Responsive responsive) {
    
    final titleSize = responsive.isLargeTablet
        ? 38.0
        : responsive.isTablet
        ? 34.0
        : 28.0;

    return SlideTransition(
      position: _titleSlide,
      child: FadeTransition(
        opacity: _titleOpacity,
        child: Text(
          "Welcome to Aura",
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle(Responsive responsive) {
    
    final subtitleSize = responsive.isLargeTablet
        ? 22.0
        : responsive.isTablet
        ? 19.0
        : 16.0;

    return SlideTransition(
      position: _subtitleSlide,
      child: FadeTransition(
        opacity: _subtitleOpacity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.isTablet ? responsive.w(15) : responsive.w(7),
          ),
          child: Text(
            "Your AI-powered safety, wellness, and social companion — unified into one experience.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: subtitleSize,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(Responsive responsive) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Opacity(
          opacity: _buttonOpacity.value,
          child: Transform.scale(
            scale: _buttonScale.value,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.isTablet ? responsive.w(20) : responsive.w(8),
              ),
              child: AuraPrimaryButton(
                label: "Get Started",
                onPressed: _navigateToAuth,
                responsive: responsive,
              ),
            ),
          ),
        );
      },
    );
  }

}